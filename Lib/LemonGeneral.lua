--Catchall. Sitting, medding
local General = {}

function General.CombatMed() --add a timer after getting hit along with agro check
    --Write.Debug('Combat Med myname %s AssistName %s equals %s',myName,mq.TLO.Spawn(MATargetID).AssistName(),mq.TLO.Spawn(MATargetID).AssistName() ~= myName)
    if Killing and not MELEE and mq.TLO.Me.Standing() and mq.TLO.Me.PctMana() < MED_AT and mq.TLO.Spawn(MATargetID).AssistName() ~= myName then
        --if 
        Write.Debug('Sitting in combat')
        mq.cmd('/sit')
        mq.delay(300, function() return mq.TLO.Me.Sitting() end)
    end
end

function General.Med() --add a timer after getting hit along with agro check
    if haveMana and not Killing and not following and mq.TLO.Me.Standing() and mq.TLO.Me.PctMana() < MED_AT then
        Write.Debug('Sitting out of combat')
        mq.cmd('/sit')
        mq.delay(300, function() return mq.TLO.Me.Sitting() end)
    end
end

function General.DanNetMessage(color,msg)
    mq.cmdf("/dgt %s [/ayLemonaid]/a%s %s",DChannel,color,msg)

end

return General