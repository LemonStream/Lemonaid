--local mq = require('mq')
--local Timer = require("lemonaid/lib/timer")
local State = {}

local Macros = {
    ['pokscribe.mac'] = true
}

function State.StartTimers()
    StickTimer = Timer:new(RESTICK_TIMER)
    StateCheckTimer = Timer:new(STATE_CHECK_DELAY)
end

function State.TradeWindowOpen()
    local wnd = mq.TLO.Window('TradeWnd')
    if wnd.Open() and wnd.HisTradeReady() and not mq.TLO.Cursor.ID() then
        mq.cmd('/notify TradeWnd TRDW_Trade_Button leftmouseup')
    end
end

function State.ClosePopups()
    local wnd = mq.TLO.Window('alertwnd')
    if wnd.Open() then mq.cmd('/nomodkey /notify alertwnd ALW_Dismiss_Button leftmouseup') end
end

function State.GroupRolesAssigned()
    if mq.TLO.Me.AmIGroupLeader() and not mq.TLO.Group.MainAssist.ID() then Write.Debug('Group Role not set. Setting %s to MA',MAName) GroupRoles('set',MAName,2) end
end

function State.clearCursor()
    if mq.TLO.Cursor.ID() and mq.TLO.Me.FreeInventory() > 1 then
        mq.cmd("/autoinventory")
        Write.Debug("Something on my cursor. I have room to autoinventory")
    end
end

function StateCheck()
    Write.Trace('Statecheck')
    State.AmIDead()
    State.clearCursor()
    State.GroupRolesAssigned()
    State.TradeWindowOpen()
    State.ClosePopups()
    State.MacroCheck()
    General.Med()
    if not Killing and not PlayerControlled and mq.TLO.Me.Combat() then mq.cmd('/attack off') end
    StateCheckTimer:reset()
    if fizzled then fizzled = false end
end

function State.AmIDead()
    mq.doevents('IDied')
    if mq.TLO.Me.Hovering() or AmDead then
        Write.Error('Yes, you are dead')
        State.DeathLoop()
    end
end

function State.DeathLoop()
    while mq.TLO.Me.Hovering() and AmDead do
        Write.Debug('Im dead')
        mq.delay(1150)
        if not mq.TLO.Me.Hovering() and mq.TLO.Spawn('pc '..MAName)() then AmDead = false Write.Debug('Back with %s, setting AmDead to false',MAName) end --No longer hovering and MA is here so I'm rezzed or we all died. 
    end
end

function State.MacroCheck()
    if Macros[mq.TLO.Macro()] then
        while mq.TLO.Macro() do
            mq.delay(1000)
            Write.Debug('Waiting for macro %s to end',mq.TLO.Macro())
        end
    end
    
end
return State