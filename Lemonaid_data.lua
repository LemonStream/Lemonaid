local Lemonaid_data = {}

Lemonaid_data.Declares = {
    Zombie = false,
    Killing = false,
    Following = false,
    Hunting = false,
    Hunter = false,
    Follow = "Follow",
    MAID = 0,
    MEID = 0,
    MATargetID = 0,
    CampX = nil,
    CampY = nil,
    CampZ = nil,
    AssistCalled = true,
    PlayerControlled = false,
    StickUW = false,
    AmOfftank = false,
}

Lemonaid_data.MonVars = {
    MTID = 0,
}

Lemonaid_data.NonCombatZones = {
    "PoKnowledge",
    "GuildHall",
    "GuildLobby",
    "Nexus",
    "Bazaar",
    "AbysmalSea",
    "PoTranquility",

}

return Lemonaid_data