local Heals = {}
healData = {} --for storing data like hp etc

dir = mq.luaDir
savePath = dir.."\\test.lua"

--Need to figure out how to choose which heal spell to cast
function Heals.Mainloop()
    if DO_HEALS then
        healData,numHurt = damagedFriends()
        if numHurt > 0 then
            sortHealList()
            for priority,healTargetTable in ipairs(healData) do --Should have our list of targets and their order by now
                Write.Trace('Priority %s is %s at %s',priority,healTargetTable.name,healTargetTable.hp)
                Heals.FindSpell(healTargetTable.name,healTargetTable.hp,healTargetTable.type)
            end
        end
    end
end

function sortHealList()
    table.sort(healData, function(a,b)
        if a.hp < b.hp then return true else return false end
    end)
    local tempHealData = healData
    local moved = false
    for k,v in ipairs(healData) do
        --printf('k %s vname %s vhp %s %s %s',k,v.name,v.hp,MAName,v.name:lower() == MAName)
        if v.name:lower() == MAName and v.hp <= TANK_HEAL_THRESHOLD then tempHealData = tableMove(healData,k,1) moved = true end
        for key,val in pairs(v) do
            --print(key,val)
        end
    end
    if moved then
        healData = tempHealData
        for k,v in ipairs(healData) do
            --print(k..'temp')
            for key,val in pairs(v) do
                --print(key,val)
            end
        end
    end
end

function damagedFriends()
    local temphealList = {}
    local count = 0
    --iterate through heal targets (group raid xtarget) add to table, sort the table based on need (MT always #1 if below a certain %) and return it
    --Need to add pets too
    if mq.TLO.Group() then
        for i=0,tonumber(mq.TLO.Group()) do --first add group. XTarget etc healing later
            local hp = mq.TLO.Group.Member(i).PctHPs()
            local name = mq.TLO.Group.Member(i)()
            if hp < 100 then
                count = count +1
                Write.Trace('Member %s %s at %s',i,name,hp)
                temphealList[count] = {name = name,hp = hp, type = "group"}
            end
        end
    end
    return temphealList,count
end

function Heals.FindSpell(healTarget,curHP,type)
    Write.Trace('Find a heal spell for %s at %s in %s',healTarget,curHP,type)
    for curTier,tieredSpellsT in ipairs(healSpellsTable) do
        Write.Trace('curTier %s',curTier)
        for healSpell,spellTable in pairs(tieredSpellsT) do
            local enabled = spellTable["Enabled"]
            local threshold = spellTable["HP"]
            local tier = spellTable["Tier"]
            local ready = spellTable["Ready"]
            local targetType = spellTable["Target"]
            local spellType = spellTable["Type"]
            Write.Trace('Checking spell %s enabled %s threshold %s tier %s ready %s target %s',healSpell,enabled,threshold,tier,ready,targetType)
            if enabled and curHP <= threshold and (targetType == 'any' or targetType == type) and ready then
                Write.Debug('Should heal %s with %s',healTarget,healSpell)
                Cast.Cast(healSpell,healTarget,spellType)
            end
        end
    end
end

function Heals.Setup()--Called at beginning to create the tier list of heals and whenever we save settings
    if not myconfig["Heals"] then return end
    Write.Debug('Heals Setup %s',os.time())
    healSpellsTable = {}
    highestTier = 0
    --Find highest tier
    for _,spellTable in pairs(myconfig["Heals"]) do
         if spellTable.Tier > highestTier then highestTier = spellTable.Tier end
    end
    Write.Debug('Highest tier spell is %s',highestTier)
    for i=1,highestTier do
        healSpellsTable[i] = {}
    end
    for healSpell,spellTable in pairs(myconfig["Heals"]) do
        healSpellsTable[spellTable.Tier][healSpell] = spellTable
    end
    --mq.pickle(savePath,healSpellsTable)
    Write.Debug('Heals Setup leave %s',os.time())
end
return Heals
