local overlordData = {}

overlordData.MonitoredStats = {
    Me = {
        PctHPs = {ext1 = nil, ext2 = nil, value = 0},
        CurrentHPs = {ext1 = nil, ext2 = nil, value = 0},
        PctMana = {ext1 = nil, ext2 = nil, value = 0},
        CurrentMana = {ext1 = nil, ext2 = nil, value = 0},
        PctEndurance = {ext1 = nil, ext2 = nil, value = 0},
        CurrentEndurance = {ext1 = nil, ext2 = nil, value = 0},
        CombatState = {ext1 = nil, ext2 = nil, value = 0},
        CountersDisease = {ext1 = nil, ext2 = nil, value = 0},
        CountersCurse = {ext1 = nil, ext2 = nil, value = 0},
        CountersPoison = {ext1 = nil, ext2 = nil, value = 0},
        CountersCorruption = {ext1 = nil, ext2 = nil, value = 0},
        Casting = {ext1 = "ID", ext2 = nil, value = nil},
        Buff = {ext1 = nil, ext2 = nil, value = nil}, --This and short will be nil, but will fill in it's own function.
        ShortBuff = {ext1 = nil, ext2 = nil, value = nil},
        },
    Target = {
        ID = {ext1 = nil, ext2 = nil, value = 0}
        }

   

}

return overlordData

--[[ PctHPs = {tlo = "Me",value = 0},
    CurrentHPs = {tlo = "Me",value = 0},
    PctMana = {tlo = "Me",value = 0},
    CurrentMana = {tlo = "Me",value = 0},
    PctEndurance = {tlo = "Me",value = 0},
    CurrentEndurance = {tlo = "Me",value = 0},
    CombatState = {tlo = "Me",value = 0},
    CountersCurse = {tlo = "Me",value = 0},
    CountersDisease = {tlo = "Me",value = 0},
    CountersPoison = {tlo = "Me",value = 0},
    CountersCorruption = {tlo = "Me",value = 0},
    CastingID = {tlo = "Me",value = 0},
    ID = {tlo = "Target",value = 0},]]