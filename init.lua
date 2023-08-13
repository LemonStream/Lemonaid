mq = require('mq')
Timer = require("lemonaid/lib/timer")
local PackageMan = require('mq/PackageMan')
LT = require('lemonaid/lib/LemonTools')
move = require('lemonaid/lib/LemonMove')
TankTarg = require('lemonaid/lib/LemonTarget')
Combat = require('lemonaid/lib/LemonCombat')
Command = require('lemonaid/lib/LemonCommands')
events = require('lemonaid/lib/LemonEvents')
Lemonaid_data = require("Lemonaid_data")
DefaultCharacter = require("DefaultCharacter")
Binds = require("lemonaid/lib/LemonBinds")
Write = require("lemonaid/lib/Write")
State = require("lemonaid/lib/LemonState")


Write.prefix = function() return string.format('\aw[%s][\ayLemonAid\aw]\at ', mq.TLO.Time()) end
Write.loglevel = 'debug'

local run = true
tempMATargetID = 0
local myName = mq.TLO.Me.CleanName.Lower()
arg = {...}

if mq.TLO.Lua.Script("lemonaid/lib/lemonassist").Status() ~= "RUNNING" then mq.cmd("/lua run lemonaid/lib/lemonassist") end
if not mq.TLO.Alias("lpause")() then mq.cmd("/alias /lpause /lua pause lemonaid") mq.cmd("/alias /lp /lua pause lemonaid") end

local function EndScript()
    run = false
    mq.exit()
end

local function DanNetSettings() --Eventually have this as a setting entry
    DChannel = 'lemonaid_'..mq.TLO.EverQuest.Server()
    mq.cmd("/dnet evasive 5000")
    mq.cmd("/dnet expired 30000")
    mq.cmd("/dnet evasiverefresh off")
    mq.cmdf("/djoin %s all",DChannel)
    mq.cmd('/dnet fullnames off')
end

--_G is global table
function UpdateSettings(newValue, setting)
    rawset(_G,setting,newValue)
    Write.Trace("setting %s value %s",setting,newValue)
end

--Set up all of our global variables from data file. Loading as default setting. Will need to update to store default in another section of lemonaid data
for k,v in pairs(Lemonaid_data.Declares) do
    UpdateSettings(v,k)
end
local path = mq.configDir..'/Lemonaid/'..mq.TLO.Me.CleanName()..'.lua'
local charData, err = loadfile(path)
for k,v in pairs(DefaultCharacter.Settings) do
    UpdateSettings(v,k)
end
StartTimers()



local function checkMAZoneID()
    maID = mq.TLO.Spawn("pc ="..MAName).ID()
    if maID ~= MAID and maID then Write.Info(string.format("Updated MAID from %s to %s",MAID,maID)) MAID = maID  end
end

--[[
    New variable for user change? Or just not call this sub all the time?
    Not in combat, 
]]
local function ShouldFollowMA()
    if not mq.TLO.Me.CombatState.Equal["COMBAT"]() then
        
    end

end

local function moveToMA()
    if Role ~= "tank" and Follow == "Follow" and MAID > 0 and move.TooFar(FOLLOW_DISTANCE,MAID) then
        move.GetToTarget(FOLLOW_DISTANCE,MAID,10)
    end
end

--Set MAName and MAID on startup
if #arg > 0 then
    for i=1, #arg do
        if string.find("assist,tank,hunter",arg[i]:lower()) then
            Write.Trace("Arg %s is %s",i,arg[i])
            Role = arg[i]
            UpdateSettings("Role",Role)
        elseif mq.TLO.Spawn("pc ="..arg[i])() then
            MAName = arg[i]
            MAID = mq.TLO.Spawn("pc ="..arg[i]).ID()
            UpdateSettings("MAName",MAName)
            printf("Found my MA %s %s",MAName,MAID)
        else
            Write.Error(string.format("Can't find MA %s %s. Stopping",MAName, MAID))
            mq.exit()
        end
    end
    if #arg < 1 or not Role or not MAName then
            Write.Error(string.format("Can't find MA %s %s. Stopping. Start the lua with your Role and assist name",MAName, MAID))
            EndScript()
    end
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
        if mq.TLO.Me.Hovering() then DeathLoop() end
        Write.Trace(string.format("kill %s id %s %s",Killing,MATargetID,TankGetTarget()))
        checkMAZoneID()
        if StateCheckTimer:timer_expired() then StateCheck() end
        moveToMA()
        TankEvents()
        if TankGetTarget() ~= 0 then
            if Combat.ShouldWeTankMob(TankGetTarget()) then
                Combat.EngageTarget(MATargetID)
            end
        end
        Combat.StickCheck(MATargetID)
        Combat.ExitCombat(MATargetID)
    end
elseif Role == "assist" then
    mq.cmdf("/lassist %s",MAID)
    while run do
        if mq.TLO.EverQuest.GameState() ~= "INGAME" then run = false return end
        mq.delay(100)
        if mq.TLO.Me.Hovering() then DeathLoop() end
        checkMAZoneID()
        if StateCheckTimer:timer_expired() then StateCheck() end
        moveToMA()
        AssistEvents()
        Write.Trace('Killing %s Count %s parens %s first %s second %s',Killing, GetXTargetTableCount(),((MATargetID ~= 0 and Combat.ShouldWeAssist(MATargetID)) or (Combat.AssistOnXTarget())),(MATargetID ~= 0 and Combat.ShouldWeAssist(MATargetID)),Combat.AssistOnXTarget())
        if not Killing and ((MATargetID ~= 0 and Combat.ShouldWeAssist(MATargetID)) or (Combat.AssistOnXTarget()))  then --If I'm moving forward cause of XTarget then I need to account for MATargetID being 0.
            Write.Trace("Should engage %s temp:%s",MATargetID,tempMATargetID)
            Combat.EngageTarget(MATargetID)
        end
        Combat.ExitCombat(MATargetID)
        Combat.StickCheck(MATargetID)
    end
elseif Role:lower() == "hunter" then
    mq.cmdf("/lassist %s",MAID)
    while run do
        if mq.TLO.EverQuest.GameState() ~= "INGAME" then run = false return end
        mq.delay(1000)
        if mq.TLO.Me.Hovering() then DeathLoop() end
        checkMAZoneID()
        if StateCheckTimer:timer_expired() then StateCheck() end
        HunterEvents()
        if not Killing and HunterGetTarget() ~= 0 then
            if move.NavPathExists(HunterTargetID) then
                if Combat.IsTargetFree(HunterTargetID) then
                    move.NavID(HunterTargetID,10000)
                    if WithinRange(HunterTargetID) and Combat.IsTargetFree(HunterTargetID) then
                        mq.cmdf("/dgt %s AssistTarget:%s",DChannel,HunterTargetID)
                        Combat.EngageTarget(HunterTargetID)
                    end
                end
            end
        end
        Combat.StickCheck(HunterTargetID)
        Combat.ExitCombat(HunterTargetID)
    end
end