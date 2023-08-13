--mq = require('mq')
--local Write = require("lib/Write")
--local move = require('lemonaid/lib/LemonMove')
local Command = {}


function Command.clickZone()
    Write.Debug('Told to clickzone Zombie %s',ZOMBIE)
    if not ZOMBIE then
        if mq.TLO.Window("LargeDialogWindow").Open() then mq.cmd("/notify LargeDialogWindow LDW_YesButton leftmouseup") return end
        if mq.TLO.Stick.Status.Equal("on")() then mq.cmd("/stick off") end
        mq.cmd("/doortarget")
        mq.delay(math.random(10,2000))
        move.Door(4000)
        local meX = mq.TLO.Me.X()
        local meY = mq.TLO.Me.Y()
        mq.cmd("/face fast door")
        mq.cmd("/click left door")
        mq.delay(20000,function () return meX ~= mq.TLO.Me.X() and meY ~= mq.TLO.Me.Y() end)
    end
end
mq.bind('/clickzone', Command.clickZone)

function Command.MakeCamp(arg)
    if not arg or arg:lower() == "on" then 
        move.MakeCamp()
        mq.cmdf('/dgt %s MakeCamp %s|%s|%s',DChannel,CampX,CampY,CampZ)
    else
        move.BreakCamp()
        mq.cmdf('/dgt %s BreakCamp',DChannel)
    end
end
mq.bind('/lcamp', Command.MakeCamp)

function Command.StickUW(...)
    local args = {...}
    printf('Stickuw called with |%s| |%s|',args[1],args[2])
    if not args[1] then
        if StickUW then StickUW = false else StickUW = true end
    elseif args[1] then
        StickUW = true
    else
        StickUW = false
    end
    if not args[2] then mq.cmdf('/dgex %s /lstick %s true',DChannel,StickUW) print('command sent') end
    Write.Debug('StickUW set to %s %s', StickUW, args[2])
end
mq.bind('/lstick', Command.StickUW)
return Command