--Target picking decision for the MT 

--local mq = require('mq')
--local dannet = require('lib/dannet/helpers')
--local LT = require('lemonaid/lib/LemonTools')
--defs
local Var = mq.TLO.Macro.Variable
mobsInCamp = 0
local selectedTarget = 0
local meLvl = mq.TLO.Me.Level()
--local tChoiceID = 0
local returnData
local numSlots = mq.TLO.Me.XTargetSlots()
local XTargetAgroTable = {}
campMobsTable = {}

function TankGetTarget()
    --printf('TankGetTarget good? %s %s killing %s',goodTarget(MATargetID), MATargetID,Killing)
    if Killing and goodTarget(MATargetID) then return 0 else checkMobs() return MATargetID end
end

local function fillTable() --Fill the table with keys of mobID and relevant data. Currently adds anything in camp that fits the spawnsearch to the kill list. Can remove that if I want to later. Kinda acting as hunter
    Write.Trace('Filltable: %s',mobsInCamp < 1  and tableLength(XTargetAgroTable) < 1)
    if mobsInCamp < 1  and tableLength(XTargetAgroTable) < 1 then return end
    Write.Trace(string.format("Mobs in camp is %s\ay XTargetAgroTable is %s",mobsInCamp, tableLength(XTargetAgroTable))) --mobsInCamp Working
    for i=1,mobsInCamp do --Adding all mobs in MELEE_DISTANCE
        local mobID = mq.TLO.NearestSpawn(i..",npc targetable los radius "..MELEE_DISTANCE.." zradius 50 noalert 3").ID()
        if not mobID then else
            local spawn = mq.TLO.Spawn(mobID)
            local dist
            if not Hunting and CampX then dist = move.calcDist(CampX,CampY,CampZ,spawn.X(),spawn.Y(),spawn.Z()) printf("dist %s radarcamp",dist) else dist = spawn.Distance() end
            campMobsTable[mobID] = {points = 0,HP = spawn.PctHPs(), dist = dist, type = spawn.Type(), level = spawn.Level()}
            Write.Debug(string.format("Adding spawn %s from radar to campMobsTable with entry %s %s %s %s %s",mobID,campMobsTable[mobID]["points"],campMobsTable[mobID]["HP"],campMobsTable[mobID]["dist"],campMobsTable[mobID]["type"],campMobsTable[mobID]["level"]))
        end
    end
end

function cleanTable()--Clean up the camp table of dead or gone mobs
    for mobID, stat in pairs(campMobsTable) do
        local spawn = mq.TLO.Spawn(mobID)
        local type = spawn.Type()
        Write.Trace('cleanTable: id %s XTtable %s',mobID,XTargetAgroTable[mobID])
        if not tableHasValue(XTargetAgroTable,mobID) then --If it was on XTarget then we'll see if it should stay
            if (type ~= "NPC" or (type == "Pet" and spawn.Master.Type() ~= "PC")) or not mq.TLO.NearestSpawn("id "..mobID.." radius "..MELEE_DISTANCE)() or spawn.Feigning() then --If it's not an NPC anymore or if it's not within melee distance
                Write.Debug(string.format("\arRemoving %d %s because %s or %s",mobID,mq.TLO.Spawn(mobID)(),type, mq.TLO.NearestSpawn("id "..mobID.." radius "..MELEE_DISTANCE)()))
                campMobsTable[mobID] = nil
                XTargetAgroTable[mobID] = nil
                MATargetID = 0
            end
        end
    end
end

local function sortMobs()--Table filled and cleaned. Now sort them for priority. Fill priority array list that we will use for target selection
    if tableLength(campMobsTable) < 1 then return end
    local priorityList = {}
    for mobID in pairs(campMobsTable) do
        campMobsTable[mobID]["points"] = ((100-campMobsTable[mobID]["HP"])+(CAMP_RADIUS-campMobsTable[mobID]["dist"])+((campMobsTable[mobID]["level"] - meLvl)*5)) --Assign priority values weighted towards level. Named isn't reliable enough without using our named list from lemonsinfo
        Write.Trace(string.format("Now: mobID %s name %s campMobsTable %s points %s",mobID,mq.TLO.Spawn(mobID),campMobsTable[mobID],campMobsTable[mobID]["points"]))
        table.insert(priorityList,{id = mobID, pts = campMobsTable[mobID]["points"]})
    end
    table.sort(priorityList, function(a,b) return a.pts > b.pts end) --Sort by pts value in descending order
    --if priorityList[1]["id"] and tChoiceID and priorityList[1]["id"] ~= tChoiceID then tChoiceID = priorityList[1]["id"] else return end --set target choice to position 1 after sort otherwise leave if no id.
    local tSpawn = mq.TLO.Spawn(priorityList[1]["id"])()
    Write.Info(string.format("Target choice is \ay %s \ag %s \ar %s other is %s|||%s",priorityList[1]["id"],priorityList[1]["pts"], mq.TLO.Spawn(priorityList[1]["id"]),tChoiceID, tSpawn))
    MATargetID = priorityList[1]["id"]
    
end

function pickTarget()
    mq.cmdf("/dgt %s AssistTarget:%s",DChannel,MATargetID)
end

function GetXTargetTableCount()
    local count = 0
    for i=1, numSlots do
        xtslot = mq.TLO.Me.XTarget(i)
        local id = xtslot.ID()
        local type = xtslot.Type()
        local dist
        if xtslot.TargetType() == "Auto Hater" and id and id ~= 0 and type ~= "PC" and type ~= "Corpse" then
            count = count + 1
            XTargetAgroTable[xtslot.ID()] = i --Key mobID data is slot # in XTarget
            if not Hunting and CampX then dist = move.calcDist(CampX,CampY,CampZ,xtslot.X(),xtslot.Y(),xtslot.Z()) else dist = xtslot.Distance() end
            campMobsTable[id] = {points = 0,HP = xtslot.PctHPs(), dist = dist, type = type, level = xtslot.Level()}
            Write.Trace(string.format("Adding xtslot %s spawn %s from XTarget to campMobsTable with count %s entry %s %s %s %s %s",i,id,count,campMobsTable[id]["points"],campMobsTable[id]["HP"],campMobsTable[id]["dist"],campMobsTable[id]["type"],campMobsTable[id]["level"]))
        end
    end
    return count
end

local function mobRadar()
    --mobsInCamp = mq.TLO.SpawnCount("npc targetable los radius "..MELEE_DISTANCE.." zradius "..ZRADIUS_TARGETING.." noalert 3 range "..ATTACK_LEVEL_RANGE)()
    mobsInCamp = 0 --Currently will attack any valid thing in the above. I don't want that as a general feature. Will want to add it as a mode but I have to refactor how target choice works
    Write.Trace("mobsInCamp is set to %s",mobsInCamp)
    if mq.TLO.Me.XTarget() > 0 then --Only loop if something on XTarget. Will include self added items though. 
        GetXTargetTableCount()
    end
end

function HunterGetTarget()
    HunterTargetID = mq.TLO.NearestSpawn("npc targetable radius "..HUNTER_RADIUS.." zradius "..ZRADIUS_TARGETING.." noalert 3 range "..ATTACK_LEVEL_RANGE).ID()
    return mq.TLO.SpawnCount("npc targetable radius "..HUNTER_RADIUS.." zradius "..ZRADIUS_TARGETING.." noalert 3 range "..ATTACK_LEVEL_RANGE)()
end

local function tarCommand(arg)
    Write.Info("Setting MTID to ",tChoiceID)
end

function checkMobs()
    mobRadar()
    fillTable()
    cleanTable()
    sortMobs()
end

--[[while true do
    mobRadar()
    refreshDefs()
    fillTable()
    cleanTable()
    sortMobs()
    mq.delay(100)
end]]

return returnData
    