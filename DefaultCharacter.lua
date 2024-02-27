local DefaultCharacter = {}

DefaultCharacter.Settings = {
    FOLLOW_DISTANCE = 10,
    MAName = "",
    Role = "",
    CAMP_RADIUS = 35,
    MELEE_DISTANCE = 29,
    STICK_SETTINGS = "!front 30%",
    ASSIST_AT = 100,
    ATTACK_LEVEL_RANGE = (mq.TLO.Me.Level()-7)..' '..(mq.TLO.Me.Level()+3),
    HUNTER_RADIUS = 300,
    RESTICK_TIMER = 3000,
    ZRADIUS_TARGETING = 50,
    ASSIST_ONLY_ON_COMMAND = false,
    STATE_CHECK_DELAY = 5000,
    MED_AT = 80,

}

DefaultCharacter.GeneralCombat = {
    Pre_Engage = "",
    MELEE = true,
    COMBAT_CAST_RETRIES = 3,--Fizzles and resists atm. Will reset after the delay on the spell though. Probably need to split that out
    

}

DefaultCharacter.DPS = {
    ['Kick'] = { Enabled = true, HP = 100, weave = true, Target='Enemy', Type ='ability', Delay=0, Ready = 'function() return mq.TLO.Me.Combat() and mq.TLO.Me.Standing() end' }

}

DefaultCharacter.HealSettings = {
    DO_HEALS = true,
    TANK_HEAL_THRESHOLD = 80 --If at or below this number, the tank will be the first to be healed regardless of other's HP
}

DefaultCharacter.Heals = {--Any, tank, group, pet. Tier 1 cast before tier 2 if you meet both criteria
    ['Minor Healing'] = { Enabled = true, HP = 100, weave = false, Target='any', Type ='spell', Tier=1, Ready = 'function() return mq.TLO.Me.Combat() and mq.TLO.Me.Standing() end' }
    
}

DefaultCharacter.PCWhiteList = {
    "Diasi",
    "Shroog",
    "Cuddlybear"

}

DefaultCharacter.Ignore = {
    ["Emmisary Tinnvin"] = true,

}

return DefaultCharacter
--[[
DefaultCharacter[1][Spells]["Sense Animals"][]
DefaultCharacter.1.Spells.Sense_Animals.Type
]]