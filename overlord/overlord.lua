--[[For calling buffs, you can just check buffList and songList
]]
local mq = require('mq')
local Timer = require("lib/timer")
local PackageMan = require('mq/PackageMan')
local sql = PackageMan.Require('lsqlite3')
local sqlite3 = require('lsqlite3')
local overlordData = require('lemonaid/overlord/overlordData')
local LT = require('lib/Lemons/LemonTools')
local Write = require("lib/Write")
Write.loglevel = 'Info'

--local db = sqlite3.open('file:memdb1?mode=memory&cache=shared')
local dbo = sqlite3.open(mq.luaDir .. '\\lemonaid\\overlord\\overlord.db')
local meID = mq.TLO.Me.CleanName()
local exists = false
local columnsTable = {}
local valuesTable = {}
local buffList = ""
local songList = ""
local buffTimer = Timer:new(5000)

--db:execute('DROP TABLE IF EXISTS overlord')

local function createTable()
    local columns = ""
    for tlo,_ in pairs(overlordData.MonitoredStats) do
        for statName,statTable in pairs(overlordData.MonitoredStats[tlo]) do
            columns =  columns..", "..tlo..statName
        end
    end
    --print("CREATE TABLE IF NOT EXISTS overlord (meID TEXT PRIMARY KEY"..columns..";")
    dbo:exec("CREATE TABLE IF NOT EXISTS overlord (meID TEXT PRIMARY KEY"..columns..");")
end

createTable()
--db:exec[[
--    CREATE TABLE IF NOT EXISTS overlord (meID TEXT PRIMARY KEY, MePctHPs, MeCurrentHPs, MePctMana, MePctEndurance, MeCurrentEndurance, MeCombatState, MeCountersDisease, MeCountersCurse, MeCounterspoison, MeCountersCorruption, MeCasting);
--]]
dbo:exec(string.format("INSERT INTO overlord (meID) VALUES ('%s');",meID))

local function getStat(tlo,stat,stat2,stat3)
    Write.Debug(string.format("tlo %s stat %s stat2 %s stat3 %s base ",tlo,stat,stat2,stat3))
    if stat3 then
        tempStatValue = mq.TLO[tlo][stat][stat2][stat3]()
    elseif stat2 then
        tempStatValue = mq.TLO[tlo][stat][stat2]()
    else
        tempStatValue = mq.TLO[tlo][stat]()
    end
    return tempStatValue
end

local function statChanged(tlo,stat,stat2,stat3) --Has it changed since we checked it
    return tostring(getStat(tlo,stat,stat2,stat3)):lower() ~= tostring(overlordData.MonitoredStats[tlo][stat]["value"]):lower()
end

local function prepSQL()
    local sqlCommand = ""
    if #columnsTable ~= #valuesTable then print("Your tables are fucked") return false end
    for i=1,#columnsTable do
        if i==1 then
            sqlCommand = columnsTable[i]..' = "'..valuesTable[i]..'"'
        else
            sqlCommand = sqlCommand..", "..columnsTable[i]..' = "'..valuesTable[i]..'"'
        end
    end
    --print(sqlCommand)
    return sqlCommand
end

local function insertSQL(firstTime,table,columns,values)
    dbo:exec(string.format("UPDATE overlord SET "..prepSQL().." WHERE meID = '%s';",meID))
    --print(string.format("UPDATE overlord SET "..prepSQL().." WHERE meID = '%s';",meID))
end

local function writeBuffs()--Have a timer and only check when it's up or something resets it. Write data without comparing
    --Loop through all buffs and short buffs to update them
    table.insert(columnsTable,"MeBuff")
    for i=1,mq.TLO.Me.MaxBuffSlots() do
        local cbuff = mq.TLO.Me.Buff(i)()
        local numbuff = mq.TLO.Me.CountBuffs()
        local count = 0
        --printf("Count %s list %s i %s buff %s",mq.TLO.Me.CountBuffs(),buffList,i,mq.TLO.Me.Buff(i)())
        if cbuff then
            buffList = buffList..mq.TLO.Me.Buff(i)().."|"
            count = count+1
        else
        end
        if count == numbuff then break end
    end
    table.insert(valuesTable,buffList)
    insertSQL()
    columnsTable = {}
    valuesTable = {}
    table.insert(columnsTable,"MeShortBuff")
    for i=1,mq.TLO.Me.CountSongs() do
        songList = songList..mq.TLO.Me.Song(i)().."|"
    end
    table.insert(valuesTable,songList)
    insertSQL()
    columnsTable = {}
    valuesTable = {}
end

local function writeAllStats()
    for tlo,_ in pairs(overlordData.MonitoredStats) do
        for statName,statTable in pairs(overlordData.MonitoredStats[tlo]) do
            Write.Debug(string.format("statName %s tlo %s changed %s",statName,tlo,string.find(statName:lower(),"buff")))
            if not string.find(statName:lower(),"buff") and statChanged(tlo,statName,statTable[ext1],statTable[ext2]) then
                Write.Debug(string.format("%s has changed %s value %s",statName,tlo..statName,tempStatValue))
                isChanged = true
                table.insert(columnsTable,tlo..statName)
                table.insert(valuesTable,tempStatValue)
            end
        end
    end
    if isChanged then
        insertSQL()
        columnsTable = {}
        valuesTable = {}
    end
end

local function readSQL(columns, where) -- readSQL("MePctHPs","meID = 'characterName'"). Only designed to return 1 value entry
    local data
    for row in dbo:nrows(string.format("SELECT %s FROM overlord WHERE %s", columns, where)) do 
        for k,v in pairs(row) do --k = MePctHPs v=100
            data = v
        end
    end
    return data
end

writeAllStats()

while true do
    mq.delay(1000)
    writeAllStats()
    if buffTimer:timer_expired() then
        writeBuffs()
        buffTimer = Timer:new(5000)
    end
end


--[[local function insertSQL(firstTime,table,columns,values)
    local text = string.format("%s (meID, %s) VALUES('%s', %s)",table,columns,meID,values)
    Write.Info('INSERT INTO '..text..";")
    if firstTime then
        db:exec('INSERT INTO '..text)
    else
        db:exec('INSERT INTO '..text)
        --db:exec('UPDATE overlord SET'..text) --Need to finish
    end
end


local function writeAllStats()
    local columns = ""
    local values =  ""
    for tlo,_ in pairs(overlordData.MonitoredStats) do
        for statName,statTable in pairs(overlordData.MonitoredStats[tlo]) do
            if statChanged(tlo,statName,statTable[ext1],statTable[ext2]) then
                Write.Debug(string.format("%s was %s but it changed",statName,overlordData.MonitoredStats[tlo][statName]["value"]))
                overlordData.MonitoredStats[tlo][statName]["value"] = tempStatValue
                Write.Debug(string.format("New value is %s",overlordData.MonitoredStats[tlo][statName]["value"]))
                columns = columns..tlo..statName..","
                values = values.."'"..tempStatValue.."'"..","
            end
        end
    end
    if exists or db:exec('EXISTS(SELECT * FROM overlord)') > 0 then
        insertSQL(false,"overlord",columns,values)
    else
        insertSQL(true,"overlord",columns,values)
        exists = true
    end
end
]]