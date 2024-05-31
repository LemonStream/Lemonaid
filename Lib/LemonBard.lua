Bard = {}
Performing = false

function Bard.Sing(what)
    if what == 'ooc' then
        local tempSongList = 0
        for songname,songdata in pairs(myconfig['OOC_Songs']) do --Get the gem#s from our char data
            local gemNum = mq.TLO.Me.Gem(songname)()
            if gemNum then 
                Write.Debug('songname %s %s',songname,tempSongList)
                tempSongList = tempSongList..gemNum..' '
            else 
                Write.Error("I don't have %s memmed",songname ) --Do I want to put error handling here to mem it if I have it? Don't think so...
            end
        end
        Write.Debug('Twisting %s',tempSongList)
        mq.cmdf('/twist %s ',tempSongList)
        mq.delay(500, function () return tobool(mq.TLO.Twist()) end)     
        if tobool(mq.TLO.Twist()) then Performing = 'ooc' Write.Debug('Should be twisting OOC') end
    elseif what == 'combat' then
        mq.cmdf('/twist %s %s %s %s',myconfig['Combat_Songs'][1],myconfig['Combat_Songs'][2],myconfig['Combat_Songs'][3],myconfig['Combat_Songs'][4])
        mq.delay(500, function () return tobool(mq.TLO.Twist()) end)     
        if tobool(mq.TLO.Twist()) then Performing = 'combat' Write.Debug('Should be twisting combat') end
    else
        --Twist 'what'
    end
end

function Bard.DoBardThings()
    --Should I twist my OOC songs
    if shortName ~= "BRD" then return end
    if Performing ~= 'ooc' and not Killing then
        --Check if I should be playing my songs
        Write.Debug('I need to sing')
        Bard.Sing("ooc")
    end
end

function Bard.BardCombat()
    --Do Combat_Songs. Rely on existing combat stuff
    if shortName ~= "BRD" then return end
    if Performing ~= 'combat' and Killing then
        Write.Debug('I need to sing for Combat')
        Bard.Sing("combat")
    end
end

return Bard