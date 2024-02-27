local Combat = {}
StickTimer = Timer:new(10)
--Killing is either fasle or the ID of what we are actively killing. Always check if killing before comparing killing

--isNULL because AssistName returns a blank string instead of nil
function Combat.IsTargetFree(id)
    local assistname = mq.TLO.Spawn(id).AssistName()
    local friendlyTargeted = false --If they have a friendly char targeted. 
    Write.Debug('IsTargetFree blank(free) %s name %s',isNULL(assistname),assistname)
    if isNULL(assistname) then
        assistname = true
    else --Check group and raid to see if they're targeting a friendly. When offtanking I think I'll need to keep a list of active offtanks in a file to reference.
        for i=0,mq.TLO.Group() do
            local member = mq.TLO.Group.Member(i)()
            if member == assistname then
                Write.Debug('%s is targeting group member %s',id,member)
                friendlyTargeted = true
                break
            end
        end
        if not friendlyTargeted and mq.TLO.Raid.Members() > 0 then
            for i=0,mq.TLO.Raid.Members() do
                local member = mq.TLO.Raid.Member(i)()
                if member == assistname then
                    Write.Debug('%s is targeting raid member %s',id,member)
                    friendlyTargeted = true
                    break
                end
            end
        end
        if not friendlyTargeted then
            if tableHasValue(DefaultCharacter.PCWhiteList,assistname) then
                Write.Debug('%s is targeting raid member a whitelisted character',id)
                friendlyTargeted = true
            end
        end
    end
    Write.Debug('Free return %s %s %s',assistname,friendlyTargeted,assistname or friendlyTargeted)
    return assistname or friendlyTargeted
end

function Combat.ShouldWeTankMob(id)
    Write.Debug(string.format("id %s table %s radius %s",id,campMobsTable[id]["dist"] or "xtarget",CAMP_RADIUS))
    if not id or not campMobsTable[id]["dist"] then return false end
    
    if campMobsTable[id]["dist"] < CAMP_RADIUS  and not Killing then
        Write.Debug(string.format("I should tank %s it's at %s within %s",mq.TLO.Spawn(id)(),campMobsTable[id]["dist"],CAMP_RADIUS))
        Killing = id
        MATargetID = id
        mq.cmdf("/dgt %s AssistTarget:%s",DChannel,MATargetID)
        return true
    end
end

function Combat.TargetInCamp(id)
    id = tonumber(id)
    if id > 0 then
        Write.Trace('TargetInCamp id is %s', id)
        if CampX then
            --Write.Debug("ReadyToKillCamp: id:%s dist:%s<%s HPs:%s<%s",id,move.CalcDist(spawn.X(),spawn.Y(),spawn.Z(),CampX,CampY,CampZ),CAMP_RADIUS,mq.TLO.Spawn(id).PctHPs(),ASSIST_AT))
            local spawn = mq.TLO.Spawn(id)
            return move.CalcDist(spawn.X(),spawn.Y(),spawn.Z(),CampX,CampY,CampZ) < CAMP_RADIUS
        else
            local MA = mq.TLO.Spawn(MAID)
            local spawn = mq.TLO.Spawn(id)
            Write.Trace("ReadyToKill: id:%s sx %s sy %s sz %s mx %s my %s mz %s rad %s calc %s HPs:%s<%s",id,spawn.X(),spawn.Y(),spawn.Z(),MA.X(),MA.Y(),MA.Z(),CAMP_RADIUS,move.CalcDist(spawn.X(),spawn.Y(),spawn.Z(),MA.X(),MA.Y(),MA.Z()),mq.TLO.Spawn(id).PctHPs(),ASSIST_AT)
            return move.CalcDist(spawn.X(),spawn.Y(),spawn.Z(),MA.X(),MA.Y(),MA.Z()) < CAMP_RADIUS
        end
    end
end

function Combat.ReadyToKill(id)
    id = tonumber(id)
    if id > 0 then
        Write.Trace('ReadyToKill id is %s %s', id,mq.TLO.Spawn(id)())
        return Combat.TargetInCamp(id) and mq.TLO.Spawn(id).PctHPs() <= ASSIST_AT and goodTarget(id)
    end
end

function Combat.ShouldWeAssist()--Single call to check for group, raid and xtarget. Need to add raid
    return Combat.AssistGroupMA() or Combat.AssistOnXTarget()
end

function Combat.AssistGroupMA() --This only works if you're in group. 
    local GroupAssistID = mq.TLO.Me.GroupAssistTarget.ID() --This is just TargetOfTarget for group role
    local shouldAssist = not ASSIST_ONLY_ON_COMMAND and Target.GetXTargetTableCount()>0 and Combat.ReadyToKill(GroupAssistID)
    Write.Trace('AssistGroupMA ID %s shouldAssist %s MATargetID %s',GroupAssistID,shouldAssist,MATargetID)
    --Kinda doing two things here which is meh. Is it within camp and under our engage % and a good target, but also should I switch mid combat to what the MA is currently targeting
    if shouldAssist and (Killing and (Killing ~= GroupAssistID and SWITCH_WITH_MA) or not Killing and MATargetID == 0) then MATargetID = GroupAssistID Write.Debug('XTarget setting MATargetID to %s %s',MATargetID,mq.TLO.Spawn(MATargetID)()) end
    return shouldAssist
end

function Combat.AssistOnXTarget()--for deciding to assist when MA is not in group
    --Same logic as lemonassist
    local ToT = mq.TLO.Spawn(mq.TLO.Spawn(MAID).AssistName())
    local ToTID = ToT.ID()
    Write.Trace('AssistName is %s ',mq.TLO.Spawn(MAID).AssistName()) --If their assistname is populated and I have it on my xtarget (thanks to lemonassist running)
    if mq.TLO.Spawn(MAID).AssistName() ~= nil then
        Write.Trace('MAID has %s on AssistName. On my XTarget %s %s type %s',ToT,mq.TLO.Me.XTarget(ToTID)(),ToTID,ToT.Type())
        if ToTID and mq.TLO.Me.XTarget(IDtoCN(ToTID))() and ToT.Type() == "NPC" then
            Write.Trace("AssistOnXTarget Should Engage")
            MATargetID = ToTID
            return true
        end
    else
        return false
    end
end

function Combat.EngageTarget(id)
    id = tonumber(id)
    Write.Debug("Engaging %s %s %s",id,mq.TLO.Target.ID() == id,mq.TLO.Target.ID())
    Killing = id
    Target.Target(id)
    move.NavID(id,2000)
    Write.Debug("Engaging %s %s %s",id,mq.TLO.Spawn(id)(),mq.TLO.Target.ID() == id,type(id))
    Target.Target(id)
    if MELEE then move.StickID(id,STICK_SETTINGS) mq.cmdf("/attack on") end
    return true
end

function Combat.StickCheck(id)
    if Killing and Combat.TargetInCamp(id) and STICK_SETTINGS and goodTarget(id) and StickTimer:timer_expired() then
        if mq.TLO.Stick.Status() ~= "ON" then move.DefaultStick(id)  StickTimer:reset(RESTICK_TIMER) Write.Debug("Killing and id %s %s %s. Resticking",id,mq.TLO.Spawn(id)(),mq.TLO.Spawn(id).Type()) end
    end
end

function Combat.CheckTarget(id)
    Target.Target(id)
end

function Combat.PreEngage()--All preengage will be done before normal items
    
end

function Combat.Burn()--Check if I should burn
    
end

function Combat.DPS(id)--All regular DPS entries
    local spawn = mq.TLO.Spawn(id)
    local tar
    for DPSName,t in pairs(myconfig["DPS"]) do
        --Write.Debug('DPSName is %s Target HP %s Ready %s',DPSName, spawn.PctHPs(),t.Ready())
        tar = t.Target:lower() or 'enemy' --entry or default use it on the enemy
        if t.Enabled and Cast.IsReady(DPSName,t.Type) and spawn.PctHPs() and spawn.PctHPs() <= t.HP and t.Ready() then
            Write.Debug('%s condition is true delay %s',DPSName,t.Delay)
            if t.Delay and t.Delay > 0 then
                if not _G[DPSName..'_Timer'] then
                    Write.Debug('First cast of %s will delay %s',DPSName,t.Delay)
                    Cast.Cast(DPSName,tar,t.Type)
                    if not _G[DPSName..'_Timer'] then _G[DPSName..'_Timer'] = Timer:new(t.Delay) end
                elseif
                _G[DPSName..'_Timer']:timer_expired() then
                    Write.Debug('Timer is expired. Casting %s %s',DPSName,_G[DPSName..'_Timer'])
                    Cast.Cast(DPSName,tar,t.Type)
                    _G[DPSName..'_Timer'] = Timer:reset()
                end
            else
                Write.Debug('No delay, casting %s',DPSName)
                Cast.Cast(DPSName,tar,t.Type)
            end
        end
    end
end

function Combat.CheckAttack(id)
    --Shouldn't need to check target cause we did it earlier in InCombat
    if not mq.TLO.Me.Combat() and MELEE then
        mq.cmdf('/attack on')
        mq.delay(1000, function () return mq.TLO.Me.Combat() end)
    end
end

function Combat.Aggro(id)--Get aggro on id
    if Role == 'tank' or AmOfftank then
        local mobTarget = mq.TLO.Spawn(mq.TLO.Spawn(id).AssistName()).ID()
        Write.Trace('Aggro mobTarget %s MAID %s me %s Taunt? %s %s',mobTarget,MAID,mq.TLO.Me.ID(),mq.TLO.Me.ID() ~= mobTarget,mobTarget ~= MAID)
        if mq.TLO.Me.ID() ~= mobTarget and mobTarget ~= MAID then
            --taunt
            if Cast.IsReady("taunt","ability") then
                Cast.Cast("taunt",id,"ability",true)
            end
            --Hard code or flag abilities as aggro abilities
            --find spells with a certain spell effect (whatever the agro is, stun too). Might have to hardcode per class for optimization
        end
    end
end

--We call this repeatedly while Killing
function Combat.InCombat(id)
    --while Killing do --Not sure how a loop is gonna work here
        if mq.TLO.Me.Hovering() then State.DeathLoop() end
        AssistEvents()
        Combat.ExitCombat(id)
        if Killing then
            Combat.CheckTarget(id)
            Combat.StickCheck(id)
            Combat.CheckAttack(id)
            Combat.PreEngage()
            Combat.Aggro(id)
            Combat.Burn()
            Combat.DPS(id)
            General.CombatMed()
        end
end

function Combat.ExitCombat(id)
    if Killing and not goodTarget(id) then
        --if not campMobsTable[id] then
            Killing = false
            MATargetID = 0
            if mq.TLO.Me.Combat() then mq.cmd('/attack off') end
            if Target.MyTarget() then Target.ClearTarget() end
            Write.Debug("Exiting Combat")
        --end
    end
end


return Combat