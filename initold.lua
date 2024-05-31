local mq = require('mq')
local Timer = require("lib/timer")
local PackageMan = require('mq/PackageMan')
local sql = PackageMan.Require('lsqlite3')
local sqlite3 = require('lsqlite3')
local LT = require('lib/LemonTools')
local move = require('lib/LemonMove')
local targ = require('lib/LemonTarget')
local cmd = require('lib/LemonCommands')
--local memdb = require('overlord/overlord') Don't need to include it. Just need to have it run in parallel to create the data in memory
local settingsdb = sqlite3.open(mq.luaDir .. '\\lemonaid\\lemonaid_settings.db')
local dbo = sqlite3.open(mq.luaDir .. '\\lemonaid\\overlord\\overlord.db')
local Lemonaid_data = require("Lemonaid_data")
local Write = require("lib/Write")
Write.loglevel = 'Debug'

local run = true
local myName = mq.TLO.Me.CleanName.Lower()
arg = {...}

local function End()
    mq.cmdf("/lua stop lemonaid/overlord/overlord")
    mq.exit()
end

local function readDBO(wdb,table,columns, where) -- readSQL("MePctHPs","meID = 'characterName'"). Only designed to return 1 value entry
    local data
    if wdb == "overlord" then
        for row in dbo:nrows(string.format("SELECT %s FROM %s WHERE %s", columns, table, where)) do
            for k,v in pairs(row) do --k = MePctHPs v=100
                data = v
            end
        end
    else
        for row in settingsdb:nrows(string.format("SELECT %s FROM %s WHERE %s", columns, table, where)) do
            for k,v in pairs(row) do --k = MePctHPs v=100
                data = v
            end
        end
    end
    return data
end

local function updateSettings(col,val)
    settingsdb:exec(string.format("UPDATE lemonaid_settings SET %s = '%s';",col,val))
end

local function createTable(t,col)
    local columns = ""
    for k in pairs(col) do
        columns =  columns..", "..k
    end
    settingsdb:exec("CREATE TABLE IF NOT EXISTS "..t.." (Character TEXT PRIMARY KEY"..columns..");")
    settingsdb:exec(string.format("INSERT INTO %s (Character) VALUES ('%s');",t,myName))
    local update = ""
    for k,v in pairs(Lemonaid_data.Settings) do
        local found = false
        for row in settingsdb:nrows(string.format("SELECT * FROM lemonaid_settings WHERE Character = '%s';",myName)) do
            for c,d in pairs(row) do
                if k:lower() == c:lower() then found = c break end
            end
            if not found then 
                if #update < 1 then update = update..k..' = "'..v..'"'
                else update = update..', '..k..' = "'..v..'"' end
            end
        end
    end
    if #update > 1 and t == "lemonaid_settings" then settingsdb:exec(string.format("UPDATE lemonaid_settings SET %s ;",update)) end
end

local function loadSettings()
    local data
    for row in settingsdb:nrows("SELECT * FROM lemonaid_settings;") do
        for k,v in pairs(row) do
            if tonumber(v) ~= nil then
                v = tonumber(v)
            end
            _G[k] = v
            data = v
        end
    end
    return data
end

local function getMA()
    maID = mq.TLO.Spawn("pc ="..MANAME).ID()
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
    if ROLE ~= "tank" and FOLLOW == "follow" and move.TooFar(Follow_Distance,MAID) then
        move.getToTarget(Follow_Distance,MAID,10)
    end
end

createTable("lemonaid_settings",Lemonaid_data.Settings)
createTable("Mon_Vars",Lemonaid_data.MonVars)
loadSettings()
Lemonaid_data.Declares()
mq.cmdf("/lua run lemonaid/overlord/overlord")

if #arg > 0 then
    for i=1, #arg do
        if string.find("assist,tank",arg[i]:lower()) then
            printf("Arg %s is %s",i,arg[i])
            ROLE = arg[i]
            updateSettings("ROLE",ROLE)
        elseif mq.TLO.Spawn("pc ="..arg[i])() then
            MANAME = arg[i]
            MAID = mq.TLO.Spawn("pc ="..arg[i]).ID()
            updateSettings("MANAME",MANAME)
            printf("Found my MA %s %s",MANAME,MAID)
        else
            Write.Error(string.format("Can't find MA %s %s. Stopping",MANAME, MAID))
            mq.exit()
        end
    end
else
    Write.Error(string.format("Can't find MA %s %s. Stopping. Start the lua with your role and assist name",MANAME, MAID))
    End()
end
getMA()

local function getTarget()
    local tempMTID = readDBO(nil,"Mon_Vars","MTID","Character = '"..MANAME.."'")
    if ROLE == "tank" then
        checkMobs()
    else
        if MTID ~= tempMTID then
            Write.Debug(string.format("MTID is wrong %s %s",MTID,tempMTID))
            MTID = tempMTID
        end
    end
end

while run do
    mq.delay(10)
    getMA()
    moveToMA()
    getTarget()
end