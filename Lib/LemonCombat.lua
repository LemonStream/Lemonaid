local Combat = {}
StickTimer = Timer:new(10)

--isNULL because AssistName returns a blank string instead of nil
function Combat.IsTargetFree(id)
    return isNULL(mq.TLO.Spawn(id).AssistName())
end

function Combat.ShouldWeTankMob(id)
    Write.Debug(string.format("id %s table %s radius %s",id,campMobsTable[id]["dist"] or "xtarget",CAMP_RADIUS))
    if not id or not campMobsTable[id]["dist"] then return false end
    
    if campMobsTable[id]["dist"] < CAMP_RADIUS  and not Killing then
        Write.Debug(string.format("I should tank %s it's at %s within %s",mq.TLO.Spawn(id)(),campMobsTable[id]["dist"],CAMP_RADIUS))
        Killing = true
        MATargetID = id
        mq.cmdf("/dgt %s AssistTarget:%s",DChannel,MATargetID)
        return true
    end
end

function Combat.TargetInCamp(id)
    id = tonumber(id)
    if id > 0 then
        Write.Debug('TargetInCamp id is %s', id)
        if CampX then
            --Write.Debug("ShouldWeAssistCamp: id:%s dist:%s<%s HPs:%s<%s",id,move.CalcDist(spawn.X(),spawn.Y(),spawn.Z(),CampX,CampY,CampZ),CAMP_RADIUS,mq.TLO.Spawn(id).PctHPs(),ASSIST_AT))
            local spawn = mq.TLO.Spawn(id)
            return move.CalcDist(spawn.X(),spawn.Y(),spawn.Z(),CampX,CampY,CampZ) < CAMP_RADIUS
        else
            local MA = mq.TLO.Spawn(MAID)
            local spawn = mq.TLO.Spawn(id)
            Write.Debug("ShouldWeAssist: id:%s dist:%s<%s HPs:%s<%s",id,spawn.X(),spawn.Y(),spawn.Z(),MA.X(),MA.Y(),MA.Z(),CAMP_RADIUS,mq.TLO.Spawn(id).PctHPs(),ASSIST_AT)
            return move.CalcDist(spawn.X(),spawn.Y(),spawn.Z(),MA.X(),MA.Y(),MA.Z()) < CAMP_RADIUS
        end
    end
end

function Combat.ShouldWeAssist(id)
    id = tonumber(id)
    if id > 0 then
        Write.Debug('ShouldWeAssist id is %s', id)
        return Combat.TargetInCamp(id) and mq.TLO.Spawn(id).PctHPs() <= ASSIST_AT
    end
end

function Combat.AssistOnXTarget()
    return not ASSIST_ONLY_ON_COMMAND and GetXTargetTableCount()>0 and Combat.ShouldWeAssist(mq.TLO.Me.GroupAssistTarget.ID())
end

function Combat.EngageTarget(id)
    id = tonumber(id)
    Write.Debug("Engaging %s %s %s",id,mq.TLO.Target.ID() == id,mq.TLO.Target.ID())
    Killing = true
    mq.cmdf("/target id %s",id)
    move.NavID(id,2000)
    Write.Debug("Engaging %s %s %s",id,mq.TLO.Target.ID() == id,type(id))
    mq.delay(2000, function() return mq.TLO.Target.ID() == id end)
    move.StickID(id,STICK_SETTINGS)
    mq.cmdf("/attack on")
    return true
end

function Combat.StickCheck(id)
    if Killing and goodTarget(id) and StickTimer:timer_expired() then
        if mq.TLO.Stick.Status() ~= "ON" then move.DefaultStick(id)  StickTimer:reset(RESTICK_TIMER) Write.Debug("Killing and id %s %s %s. Resticking",id,mq.TLO.Spawn(id)(),mq.TLO.Spawn(id).Type()) end
    end
end

function Combat.ExitCombat(id)
    if Killing and not goodTarget(id) then
        --if not campMobsTable[id] then
            Killing = false
            MATargetID = 0
            Write.Debug("Exiting Combat")
        --end
    end
    if not Killing and not PlayerControlled and mq.TLO.Me.Combat() then mq.cmd('/attack off') end
end

function DeathLoop()
    while mq.TLO.Me.Hovering() do
        mq.delay(50)
    end
    
end



function Event_SetAssistTarget(line, arg1)
    MATargetID = arg1
    AssistCalled = true
    Write.Debug(string.format('Told to assist on [%s]',MATargetID))
end
mq.event('assist', '#*#AssistTarget:#1#', Event_SetAssistTarget)
return Combat