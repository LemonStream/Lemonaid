--[[
    Instead of a classic ini based system with a tool to autocreate it based on level, I could instead create a logic system
    that chooses what to do based on what's available and what is toggled in the UI. Problem is that's harder to do without having the UI etc
]]

local Cast = {}
fizzled = false


local typeToFunction = {
    spell = 'Cast.Spell',
    ability = 'Cast.Ability',
    disc = Cast.Disc,
    aa = Cast.AA,
    item = Cast.Item,
}

function Cast.Type(type)
    if string.find(type,'spell') then
        type = 'spell'
    elseif string.find(type,'disc') then
        type = 'disc'
    elseif string.find(type,'ability') then
        type = 'ability'
    elseif string.find(type,'aa') then
        type = 'aa'
    elseif string.find(type,'item') then
        type = 'item'
    end
    return type
end

function Cast.Target(target)
    if string.find(target,'enemy') then
        target = MATargetID or "NOENEMY"
    elseif string.find(target,'self') then
        target = mq.TLO.Me.ID()
    elseif string.find(target,'tank') then
        target = MAID
    else target = mq.TLO.Spawn(target).ID() end
    Write.Debug('Target is %s %s',target, mq.TLO.Spawn(target)())
    return target
end

function Cast.Events()
    mq.doevents('fizzle')
end

function Cast.Wait()--Need to add in emergency healing and stop healing if healed
    Write.Debug('Wait window %s %s',tobool(mq.TLO.Window('CastingWindow')()),mq.TLO.Window('CastingWindow')())
    mq.delay(200, function() return tobool(mq.TLO.Window('CastingWindow')()) end)
    Write.Debug('Wait window %s %s',tobool(mq.TLO.Window('CastingWindow')()),mq.TLO.Window('CastingWindow')())
    Cast.Events()
    if mq.TLO.Me.BardSongPlaying() then Write.Debug('Returning cause I\'m playing a song') return end
    while tobool(mq.TLO.Window('CastingWindow')()) do
        mq.delay(1)
        Cast.Events()
    end
end

function Cast.Spell(spell)
    mq.cmdf('/cast "%s"',spell)
    Write.Debug('Casting %s on %s',spell,mq.TLO.Target())
    Cast.Wait()
end

function Cast.Ability(ability)
    mq.cmdf('/doability %s',ability)
end

function Cast.Disc(disc)
end

function Cast.AA(aa)--Type 1-6. Don't know what the issue is. Note about 5 for some reason
    mq.cmdf('/alt activate %s',mq.TLO.Me.AltAbility(aa).ID())
    Cast.Wait()
end

function Cast.Item(item)
    mq.cmdf('/cast item "%s"',item)
    Cast.Wait()
end

function Cast.HaveResources(spell,type)
    local haveResources = false
    local haveReagents = true
    local reagentID = mq.TLO.Spell(spell).ReagentID(1)() or -1
    Write.Debug('spell %s type %s reagent %s',spell,type,reagentID)
    if type == "spell" then haveResources = mq.TLO.Spell(spell).Mana() < mq.TLO.Me.CurrentMana() 
    elseif type == "disc" then haveResources = mq.TLO.Spell(spell).EnduranceCost() < mq.TLO.Me.Endurance() 
    else haveResources = true end
    if reagentID > -1 then Write.Debug("need a reagent") --Probably need to change spell to account for the spell that is actually cast from AAs/items etc eventually
        if mq.TLO.FindItemCount(reagentID)() >= mq.TLO.Spell(spell).ReagentCount(1)() then
            Write.Debug("I have enough %s to cast %s",mq.TLO.FindItem(reagentID)(),spell)
        else haveReagents = false end
    end
    return haveReagents and haveResources
end

function Cast.CastTheThing(spell,type)
    if type == 'ability' then Cast.Ability(spell) elseif
        type == 'spell' then Cast.Spell(spell) elseif
        type == 'aa' then Cast.AA(spell) elseif
        type == 'disc' then Cast.Disc(spell) elseif
        type == 'item' then Cast.Item(spell)
    end
end

function Cast.HaveSpell(spell,type)
    local haveIt = false
    if type == 'ability' and mq.TLO.Me.Skill(spell)() > 0 then haveIt = true elseif
        type == 'spell' and mq.TLO.Me.Spell(spell).ID()then haveIt = true elseif --Need to account for Rk? Or always strip? Will always stripping cause issues?
        type == 'aa' and mq.TLO.AltAbility(spell).ID() then haveIt = true elseif
        type == 'disc' and mq.TLO.Me.CombatAbility(spell).ID() then haveIt = true elseif
        type == 'item' and mq.TLO.FindItem(spell).ID() then haveIt = true
    end
    return haveIt
end

function Cast.InRange(spell,target,type) --Do I add LoS here? Is there a spell info where I can check if it's required? MyRange?
    local castRange = false
    if type == 'ability' and mq.TLO.Spawn(target).Distance() < mq.TLO.Target.MaxMeleeTo() then castRange = true elseif
        type == 'spell' and mq.TLO.Spawn(target).Distance() <  mq.TLO.Me.Spell(spell).Range() then castRange = true elseif --Need to account for Rk? Or always strip? Will always stripping cause issues?
        type == 'aa' and mq.TLO.Spawn(target).Distance() <  mq.TLO.AltAbility(spell).Range() then castRange = true elseif
        type == 'disc' and mq.TLO.Spawn(target).Distance() <  mq.TLO.Me.CombatAbility(spell).Range() then castRange = true elseif
        type == 'item' and mq.TLO.Spawn(target).Distance() <  mq.TLO.FindItem(spell).Range() then castRange = true
    end
    Write.Debug('CastRange %s',castRange)
    return castRange
end

function Cast.CanCast() --Not stunned silenced etc
    return not mq.TLO.Me.Stunned() and not mq.TLO.Me.Silenced() and mq.TLO.Me.Standing()
end
--Need to implement a return on how long the cast lockout is so the caller can call for weaves? Gotta figure out weaving in general
--Figure out how to handle spells I have but aren't memmed. Just combat? Have it as a setting for combat?
function Cast.Cast(spell,targ,type,weave)--gonna need to figure out spell ranks
    local count = 0
    local cast_result = "fail"
    type = type:lower()
    Write.Debug('spell %s target %s type %s',spell,targ,type)
    if not Cast.HaveSpell(spell,type) then cast_result = "unknown" else
        type = Cast.Type(type)
        target = Cast.Target(targ) --spawn ID of your target
        readyToCast,cooldownTimer = Cast.IsReady(spell,type)
        if not readyToCast and cooldownTimer == 0 then Write.Debug('delaying 1.5s for non-weave global cooldown',cooldoownTimer) mq.delay(1600, function () return Cast.IsReady(spell,type) == true end) end --Wait for the global cooldown of 1.5s
        if cooldownTimer > 0 and not weave and cooldownTimer < 2 then Write.Debug('delaying %ss for non-weave spell cooldown',cooldoownTimer) mq.delay(cooldownTimer..'s') end
        readyToCast,cooldownTimer = Cast.IsReady(spell,type)
        if readyToCast and Cast.CanCast() and Cast.InRange(spell,target,type) then
            Write.Debug('ready %s cooldownTimer %s',readyToCast,cooldownTimer)
            if Cast.HaveResources(spell,type) then
                Write.Debug('I have the resources')
                if mq.TLO.Target.ID() ~= target then Target.Target(target) end
                if shortName ~= "BRD" then move.Pause() end
                if not mq.TLO.Me.Standing() then mq.cmd('/stand') end
                General.DanNetMessage("g",f('Casting %s',spell))
                Cast.CastTheThing(spell,type)
                mq.doevents('fizzle')
                while fizzled and count <= COMBAT_CAST_RETRIES do
                    Write.Debug('Recasting due to fizzle attempt %s out of %s',count,COMBAT_CAST_RETRIES)
                    mq.flushevents('fizzle')
                    Write.Info('Casting \ag%s',spell)
                    Cast.CastTheThing(spell,type)
                    count = count +1
                end
                cast_result = 'success'
                fizzled = false
                move.Resume()
            end
        else Write.Debug("%s isn't ready or global cooldown is active",spell) cast_result = 'not ready' end
    end
    Write.Debug('Returning from Cast.Cast with %s',cast_result)
    return cast_result
end

function Cast.IsReady(spell,type)
    local castready
    local ready
    local castreadytime

    ready = (mq.TLO.Navigation.Velocity() < 1 or shortName == "BRD") --eventually account for things bards can't cast while moving
    if type == "spell" then
        castready = mq.TLO.Me.SpellReady(spell)()
        castreadytime = mq.TLO.Me.GemTimer(spell)() or 10
    elseif type == 'disc' then
        castready = mq.TLO.Me.CombatAbilityReady(spell)()
        castreadytime = mq.TLO.Me.CombatAbilityTimer(spell)() or 10
    elseif type == 'ability' then
        castready = mq.TLO.Me.AbilityReady(spell)()
        castreadytime = mq.TLO.Me.AbilityTimer(spell)() or 10
    elseif type == 'aa' then
        castready = mq.TLO.Me.AltAbilityReady(spell)()
        castreadytime = mq.TLO.Me.AltAbilityTimer(spell)() or 10
    elseif type == 'item' then
        castready = mq.TLO.Me.ItemReady(spell)()
        castreadytime = mq.TLO.FindItem(spell).Timer() or 10
    end
    return castready and ready, castreadytime
end

function Event_CastFizzle(line, ...)
    if not fizzled then
        local arg = {...}
        Write.Debug('I fizzed \ar%s',arg[1])
        fizzled = true
    end
end
mq.event('fizzle', 'Your #1# spell fizzles!', Event_CastFizzle)

return Cast