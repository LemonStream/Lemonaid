--local mq = require('mq')
--local Timer = require("lemonaid/lib/timer")

function StartTimers()
    StickTimer = Timer:new(RESTICK_TIMER)
    StateCheckTimer = Timer:new(1500)
end

function TradeWindowOpen()
    local wnd = mq.TLO.Window('TradeWnd')
    if wnd.Open() and wnd.HisTradeReady() and not mq.TLO.Cursor.ID() then
        mq.cmd('/notify TradeWnd TRDW_Trade_Button leftmouseup')
    end
end

function ClosePopups()
    local wnd = mq.TLO.Window('alertwnd')
    if wnd.Open() then mq.cmd('/nomodkey /notify alertwnd ALW_Dismiss_Button leftmouseup') end
end

function GroupRolesAssigned()
    if mq.TLO.Me.AmIGroupLeader() and not mq.TLO.Group.MainAssist.ID() then Write.Debug('Group Role not set. Setting %s to MA',MAName) GroupRoles('set',MAName,2) end
end
function StateCheck()
    Write.Trace('Statecheck')
    GroupRolesAssigned()
    TradeWindowOpen()
    ClosePopups()
    StateCheckTimer:reset()
end