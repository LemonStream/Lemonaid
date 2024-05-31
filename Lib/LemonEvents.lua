--local mq = require('mq')
--local Timer = require("lemonaid/lib/timer")
--local DefaultCharacter = require("DefaultCharacter")Event_AcceptInvite
AmDead = false

function TankEvents()
    mq.doevents('makecamp')
end

function AssistEvents()
    mq.doevents('makecamp')
    mq.doevents("assist")
    mq.doevents()
end

function HunterEvents()
    mq.doevents('makecamp')
    mq.doevents("assist")
end

--Accept invite
function Event_AcceptInvite(line, arg1)
    if tableHasValue(DefaultCharacter.PCWhiteList,arg1) then
        Write.Info('Accepting invite from %s',arg1)
        mq.cmd('/invite')
    end
end
mq.event('invite', '#1# invites you to join a group.#*#', Event_AcceptInvite)

--MA Zoned
function Event_IZoned(line, arg1)
    Write.Debug('I zoned')
    if Role == "tank" then
        mq.cmdf("/dgt %s izoned:%s",DChannel,arg1)
    elseif not mq.TLO.Me.Zoning() then 
        mq.cmdf("/travelto %s",DChannel,mq.TLO.Zone(arg1).ShortName())
    end

end
mq.event('izoned', 'You have entered #1#.', Event_IZoned)

function Event_SetAssistTarget(line, ...)
    local arg = {...}
    local sender = arg[2]
    Write.Debug(string.format('assist event %s %s',arg[1],arg[2]))
    if not myName == sender then
        MATargetID = arg[1]
        AssistCalled = true
        Write.Debug(string.format('Told to assist on [%s]',MATargetID))
    end
end
mq.event('assist', '~#2#~*#AssistTarget:#1#', Event_SetAssistTarget)

function Event_IDied(line, ...)
    local arg = {...}
    Write.Info('%s has killed me',arg[1])
    AmDead = true
    State.DeathLoop()
end
mq.event('died', '#*#You have been slain by #1#', Event_IDied)


