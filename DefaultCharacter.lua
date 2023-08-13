local DefaultCharacter = {}

DefaultCharacter.Settings = {
    FOLLOW_DISTANCE = 10,
    MAName = "",
    Role = "",
    CAMP_RADIUS = 35,
    MELEE_DISTANCE = 29,
    STICK_SETTINGS = "!front true useflex flexdist 5.15",
    ASSIST_AT = 100,
    ATTACK_LEVEL_RANGE = (mq.TLO.Me.Level()-7)..' '..(mq.TLO.Me.Level()+3),
    HUNTER_RADIUS = 300,
    RESTICK_TIMER = 3000,
    ZRADIUS_TARGETING = 50,
    ASSIST_ONLY_ON_COMMAND = false,

}

DefaultCharacter.GeneralCombat = {
    Pre_Engage = ""

}

DefaultCharacter.PCWhiteList = {
    "Diasi",

}


return DefaultCharacter
--[[
DefaultCharacter[1][Spells]["Sense Animals"][]
DefaultCharacter.1.Spells.Sense_Animals.Type
]]