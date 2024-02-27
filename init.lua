mq = require('mq')
Timer = require("lemonaid/lib/timer")
local PackageMan = require('mq/PackageMan')
LT = require('lemonaid/lib/LemonTools')
move = require('lemonaid/lib/LemonMove')
Target = require('lemonaid/lib/LemonTarget')
Combat = require('lemonaid/lib/LemonCombat')
Command = require('lemonaid/lib/LemonCommands')
events = require('lemonaid/lib/LemonEvents')
Lemonaid_data = require("Lemonaid_data")
DefaultCharacter = require("DefaultCharacter")
Binds = require("lemonaid/lib/LemonBinds")
Write = require("lemonaid/lib/Write")
State = require("lemonaid/lib/LemonState")
Heals = require("lemonaid/lib/LemonHeals")
Cast = require("lemonaid/lib/LemonCast")
General = require("lemonaid/lib/LemonGeneral")
Buff = require("lemonaid/lib/LemonBuff")
Class_Schema = require("lemonaid/lib/class_schemas")

--Build a level appropriate ini file on command. Only issue is it won't have conditions on DPS items unless they're hardcoded. 
--Could hardcode to a family of spells? Or just build the AI to handle things like taunt
--Issues with that: Shock of many. How am I selecting spells to cast
--Probably a lot of hardcoding. 
--Taunt default to off but added. Could just add everything and the UI could let you enable entries. Still want to have some amount defaulted to on though
--Global prestige flag and a prestige check function to determine if someone can be used

Write.prefix = function() return string.format('\aw[%s][\ayLemonAid\aw]\at ', mq.TLO.Time()) end
Write.loglevel = 'debug'

local run = true
tempMATargetID = 0
shortName = mq.TLO.Me.Class.ShortName()
myName = mq.TLO.Me.CleanName.Lower()
print(myName)
arg = {...}

if mq.TLO.Lua.Script("lemonaid/lib/lemonassist").Status() ~= "RUNNING" then mq.cmd("/lua run lemonaid/lib/lemonassist") end
if not mq.TLO.Alias("lpause")() then mq.cmd("/alias /lpause /lua pause lemonaid") mq.cmd("/alias /lp /lua pause lemonaid") end

--Create character specific settings
configFileName = '/lemonaid/'..myName..'_config.lua'
path = mq.configDir..configFileName
local configData, err = loadfile(path)
if err then
    configFileName = '/lemonaid/'..myName..'_autoconfig.lua' --If no player created settings, then create an auto settings file. This way we can separate the auto selected spells etc
    path = mq.configDir..configFileName
    -- failed to read the config file, create it using pickle
    ChooseSchema() --Go autoselect spells etc
    mq.pickle(path, DefaultCharacter)
    myconfig = loadfile(path)()
elseif configData then --Once all schemas in, will want to check if we're running
    -- file loaded, put content into your config table
    myconfig = configData()
end

--_G is global table
function SetVariable(newValue, setting)
    rawset(_G,setting,newValue)
    Write.Debug("setting %s value %s",setting,newValue)
end

--Set up all of our global variables from data file. Loading as default setting. Will need to update to store default in another section of lemonaid data
for k,v in pairs(Lemonaid_data.Declares) do
    SetVariable(v,k)
end

for _,v in pairs(myconfig) do
    for key,value in pairs(v) do
        SetVariable(value,key)
    end
end

StartTimers()
Heals.Setup()
haveMana = mq.TLO.Me.CurrentMana()
if haveMana > 0 then haveMana = true else haveMana = false end

local function EndScript()
    run = false
    mq.exit()
end

local function DanNetSettings() --Eventually have this as a setting entry
    DChannel = 'lemonaid-'..mq.TLO.EverQuest.Server()
    mq.cmd("/dnet evasive 5000")
    mq.cmd("/dnet expired 30000")
    mq.cmd("/dnet evasiverefresh off")
    mq.cmdf("/djoin %s all",DChannel)
    mq.cmd('/dnet fullnames off')
end

local function checkMAZoneID()
    maID = mq.TLO.Spawn("pc ="..MAName).ID()
    --Write.Debug('CheckMAID %s %s name: me:%s',maID,MAID,MAName,mq.TLO.Me.ID())
    if maID and maID ~= MAID and maID ~= mq.TLO.Me.ID() then Write.Info(string.format("Updated MAID from %s to %s",MAID,maID)) MAID = maID  end
    if MAID == 0 then State.DeathLoop() end --This is called every loop as a check to see if we are dead while MAID is 0
end

local function moveToMA()
    --Write.Debug('Should move %s %s %s',Role,Follow,MAID)
    if (not Killing or (Killing and not MELEE and mq.TLO.Spawn(MAID).Distance() >= CAMP_RADIUS)) and Role ~= "tank" and Follow == "Follow" and MAID > 0 and move.TooFar(FOLLOW_DISTANCE,MAID) then 
        following = true
        move.GetToTarget(FOLLOW_DISTANCE,MAID,10)
    end
    if following and mq.TLO.Me.Speed() == 0 then following = false end
end

--Set MAName and MAID on startup
--Kinda janky. Seems like it could fail in the wild
if #arg > 0 then
    for i=1, #arg do
        Write.Debug('Startup arg is %s %s',arg[i],string.find("assist,tank,hunter",arg[i]:lower()))
        if string.find("assist,tank,hunter",arg[i]:lower()) then
            Write.Trace("Arg %s is %s",i,arg[i])
            Role = arg[i]
        elseif mq.TLO.Spawn("pc ="..arg[i])() then
            MAName = arg[i]
            MAID = mq.TLO.Spawn("pc ="..arg[i]).ID()
            SetVariable("MAName",MAName)
            printf("Found my MA %s %s",MAName,MAID)
        else
            MAName = arg[i]
            while not mq.TLO.Spawn("pc ="..arg[i])() do
                Write.Error(string.format("Can't find MA %s %s. Waiting",arg[i], MAID))
                mq.delay(10000, function () return mq.TLO.Spawn("pc ="..arg[i])() end)
            end
        end
    end
    if #arg < 1 or not Role or not MAName then
            Write.Error(string.format("Can't find MA %s %s. Stopping. Start the lua with your Role and assist name",MAName, MAID))
            EndScript()
    end
else
    Write.Error('LemonAid started with no parameters')
    mq.exit()
end
checkMAZoneID()

--Just use LemonAssist?
function AssistGetTarget() --Eventually want this running in parallel updating tempMATargetID. Could just write to a file atm
    local tempMATargetID = MATargetID --Used to read DB which was updated by MT
    if MATargetID ~= tempMATargetID then
        Write.Debug(string.format("MATargetID is wrong %s %s",MATargetID,tempMATargetID))
        MATargetID = tempMATargetID
    end
end

DanNetSettings()
GroupRoles('set',MAName,2)

--Main loops
if Role == "tank" then
    mq.cmdf("/lassist %s",MAID)
    while run do
        if mq.TLO.EverQuest.GameState() ~= "INGAME" then run = false return end
        mq.delay(100)
        if mq.TLO.Me.Hovering() then State.DeathLoop() end
        Write.Trace(string.format("kill %s id %s %s",Killing,MATargetID,TankGetTarget()))
        checkMAZoneID()
        if StateCheckTimer:timer_expired() then StateCheck() end
        moveToMA()
        TankEvents()
        if TankGetTarget() ~= 0 then
            Write.Debug('Tank Target')
            if Combat.ShouldWeTankMob(TankGetTarget()) then
                Combat.EngageTarget(MATargetID)
            end
        end
        Heals.Mainloop()
        if Killing then Combat.InCombat(MATargetID) end
    end
elseif Role == "assist" then
    mq.cmdf("/lassist %s",MAID)
    while run do
        if mq.TLO.EverQuest.GameState() ~= "INGAME" then run = false return end
        mq.delay(1)
        if mq.TLO.Me.Hovering() then State.DeathLoop() end
        checkMAZoneID()
        if StateCheckTimer:timer_expired() then StateCheck() end
        moveToMA()
        Heals.Mainloop()
        AssistEvents()
        Write.Trace('Killing %s Count %s parens %s first %s second %s',Killing, Target.GetXTargetTableCount(),((MATargetID ~= 0 and Combat.ReadyToKill(MATargetID)) or (Combat.ShouldWeAssist())),(MATargetID ~= 0 and Combat.ReadyToKill(MATargetID)),Combat.AssistGroupMA())
        if not Killing and ((MATargetID ~= 0 and Combat.ReadyToKill(MATargetID)) or (Combat.ShouldWeAssist()))  then --If I'm moving forward cause of XTarget then I need to account for MATargetID being 0.
            Write.Debug("Should engage MATID %s temp:%s",MATargetID,tempMATargetID)
            Combat.EngageTarget(MATargetID)
        end
        if Killing then Combat.InCombat(MATargetID) end
        Buff.CheckBuffs()
    end
elseif Role:lower() == "hunter" then
    mq.cmdf("/lassist %s",MAID)
    while run do
        if mq.TLO.EverQuest.GameState() ~= "INGAME" then run = false return end
        mq.delay(1000)
        if mq.TLO.Me.Hovering() then State.DeathLoop() end
        checkMAZoneID()
        if StateCheckTimer:timer_expired() then StateCheck() end
        HunterEvents()
        if not Killing and Target.HunterPossibleTargets() ~= 0 then
            SetHunterTargetID()
            Write.Debug('path exists %s',move.NavPathExists(HunterTargetID))
            if move.NavPathExists(HunterTargetID) then
                Write.Debug('path exists %s',Combat.IsTargetFree(HunterTargetID))
                if Combat.IsTargetFree(HunterTargetID) then
                    move.NavID(HunterTargetID,10000)
                    Write.Debug('Hunter Within %s Free %s',WithinRange(HunterTargetID), Combat.IsTargetFree(HunterTargetID))
                    if WithinRange(HunterTargetID) and Combat.IsTargetFree(HunterTargetID) then
                        mq.cmdf("/dgt %s ~%s~ AssistTarget:%s",DChannel,myName,HunterTargetID)
                        Combat.EngageTarget(HunterTargetID)
                    end
                end
            end
        end
        Heals.Mainloop()
        if Killing then Combat.InCombat(HunterTargetID) end
        --Combat.StickCheck(HunterTargetID)
        --Combat.ExitCombat(HunterTargetID)
    end
end