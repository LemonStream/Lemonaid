--Movement lua to handle movement commands
--Call the relevant sub, first is options for nav, second is wait time if you want to wait for nav to get to the target

--local mq = require('mq')
local move = {}

local function waitToStop(howLong)
    mq.delay(300, function() return mq.TLO.Navigation.Active() end)
    mq.delay(howLong, function() return not mq.TLO.Navigation.Active() end)
end

function move.CalcDistSq(x1, y1, x2, y2)
    return (x2 - x1)*(x2 - x1) + (y2 - y1)*(y2 - y1)
end

function move.CalcDist(x1, y1, z1, x2, y2, z2)
    return math.sqrt((x2 - x1)*(x2 - x1)  + (y2 - y1)*(y2 - y1) + (z2 - z1)*(z2 - z1))
end

function move.TooFar(dist,target)
    --if mq.TLO.Spawn(target).Distance() > dist then return true else return false end
    --return CalcDistSq(mq.TLO.Spawn(target).X(),mq.TLO.Spawn(target).Y(),mq.TLO.Me.X(),mq.TLO.Me.Y()) > dist * dist
    return move.CalcDist(mq.TLO.Spawn(target).X(),mq.TLO.Spawn(target).Y(),mq.TLO.Spawn(target).Z(),mq.TLO.Me.X(),mq.TLO.Me.Y(),mq.TLO.Me.Z()) > dist
end

function move.NavTarget(options, wait)
    mq.cmdf("/nav target")
    if wait then waitToStop(wait) end
end

function move.NavID(id, wait)
    mq.cmdf("/nav id %s",id)
    if wait then waitToStop(wait) end
end

function move.StickID(id, options)
    if not options then options = '' end
    mq.cmdf("/stick id %s %s", id, options)
end

function move.DefaultStick(id)
    move.StickID(id,STICK_SETTINGS)
end

function move.Door(wait)
    mq.cmdf("/nav door")
    if wait then waitToStop(wait) end
end

function move.NavPathExists(id)
    return mq.TLO.Navigation.PathExists("id "..id)()
end

function move.GetToTarget(distance,target,wait) --Add logic for lev on cliffs later
    --Write.Debug('Stickuw %s nav active %s Velocity %s exists %s los %s',StickUW,mq.TLO.Navigation.Active(),mq.TLO.Navigation.Velocity(),mq.TLO.Navigation.PathExists("id "..target)(),mq.TLO.LineOfSight(mq.TLO.Spawn(target).Y(),mq.TLO.Spawn(target).X(),mq.TLO.Spawn(target).Z()))
    if StickUW then
        mq.cmd('/stick set heading fast')
        move.StickID(target,'uw 4')
    elseif not mq.TLO.Navigation.Active() and mq.TLO.Navigation.Velocity() < 1 then
        if mq.TLO.Navigation.PathExists("id "..target)() then
            move.NavID(target,wait)
        elseif mq.TLO.LineOfSight(mq.TLO.Spawn(target).Y(),mq.TLO.Spawn(target).X(),mq.TLO.Spawn(target).Z()) then
            --Write.Debug("should stick to %s",target)
            move.StickID(target,FOLLOW_DISTANCE-1)
        end
    end
end

--Make and break camp for boxes. This is not the /makecamp command
function move.MakeCamp(x,y,z)
    CampX = x or mq.TLO.Me.X()
    CampY = y or mq.TLO.Me.Y()
    CampZ = z or mq.TLO.Me.Z()
    Write.Info(string.format("Camp set at my location"))
end
function move.BreakCamp()
    CampX = nil
    CampY = nil
    CampZ = nil
    Write.Info(string.format("I'm breaking camp"))
end
function Event_SetMakeCamp(line, arg1, arg2, arg3)
    move.MakeCamp(arg1,arg2,arg3)
end
function Event_BreakCamp(line)
    move.BreakCamp()
end
mq.event('makecamp', '#*#MakeCamp #1#|#2#|#3#', Event_SetMakeCamp)
mq.event('breakcamp', '#*#BreakCamp#*#', Event_BreakCamp)
return move