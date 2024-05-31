local Schemas = {}
Schemas = {
    ["SHM"] = {
        [1] = {
            Buffs = {
                entries = 3,
                [165] = { --Talisman line spell_category (emu),
                    criteria = {
                        effectid = 11
                    },
                    who = "all",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
                [41] = { --SoW
                    criteria = {
                        effectid = 3
                    },
                    who = "all",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
                [35] = { --Haste
                    criteria = {
                        effectid = 3
                    },
                    who = "melee",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
            },
            Heals = {
                entries = 2,
                [20] = {
                    criteria = {
                        effectid = 11
                    },
                    who = "all",
                    enabled = true,
                    healpct = 50,
                    weave = false,
                    type = "Spell",
                }
            },
            DPS = { --Kick etc isn't grabbed in the csv parser. Not sure how I will handle
                entries = 2,
                [125] = {
                    criteria = {
                        effectid = 0
                    },
                    type = "Spell",
                    startattacking = 60,
                    target = "enemy",
                    weave = false,
                    delay = 10000
                },
                [38] = { --Slow
                    criteria = {
                        effectid = 11
                    },
                    type = "Spell",
                    startattacking = 60,
                    target = "enemy",
                    weave = false,
                    delay = "debuff"
                }
            }
        }
    },
    ["CLR"] = {
        [1] = {
            Buffs = {
                entries = 2,
                [30] = { --Aego?
                    criteria = {
                        effectid = 11
                    },
                    who = "all",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
                [122] = { --Ward of Vie
                    criteria = {
                        effectid = 3
                    },
                    who = "tank",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
                
            },
            Heals = {
                entries = 2,
                [20] = {--normal heal
                    criteria = {
                        effectid = 11
                    },
                    who = "all",
                    enabled = true,
                    healpct = 60,
                    weave = false,
                    type = "Spell",
                },
                [21] = { --HoT
                    criteria = {
                        effectid = 11
                    },
                    who = "tank", --Not sure on syntax
                    enabled = true,
                    healpct = 80,
                    weave = false,
                    type = "Spell",
                },
                [22] = { --Group Heal
                    criteria = {
                        effectid = 11
                    },
                    who = "group", --Need to add group heal logic
                    enabled = true,
                    healpct = 40,
                    weave = false,
                    type = "Spell",
                },
            },
            Rez = {
                entries = 1,
                [27] = {
                    criteria = {
                        effectid = 11
                    },
                    who = "all",
                    enabled = true,
                    combat = 1, --0 off, 1 tank only, 2 all group/raid
                    weave = false,
                    type = "Spell",
                }
            },
            DPS = {
                entries = 0,
                [0] = {
                    criteria = {
                        effectid = 0
                    },
                    type = "Spell",
                    startattacking = 60,
                    target = "enemy",
                    weave = false,
                    delay = 10000
                },
                
            }
        }
        
    },
    ["BRD"] = {
        [1] = { --Up to level 15
            OOC_Songs = {
                entries = 4,
                [42] = { --Selos
                    criteria = {
                        effectid = 11
                    },
                    enabled = true,
                    type = "Song",
                },
                [202] = { --Chant of Battle
                    criteria = {
                        effectid = 11
                    },
                    enabled = true,
                    type = "Song",
                },
                [25] = { --Chant Regen
                    criteria = {
                        effectid = 11
                    },
                    enabled = true,
                    type = "Song",
                },
                [200] = { --Sustenance
                    criteria = {
                        effectid = 11
                    },
                    enabled = true,
                    type = "Song",
                },
                
            },
            Combat_Songs = {
                entries = 4,
                [42] = { --Selos
                    criteria = {
                        effectid = 11
                    },
                    enabled = true,
                    type = "Song",
                },
                [202] = { --Chant of Battle
                    criteria = {
                        effectid = 11
                    },
                    enabled = true,
                    type = "Song",
                },
                [-99] = { --Chant of <damage>
                    criteria = {
                        effectid = 11
                    },
                    target="enemy",
                    enabled = true,
                    type = "Song",
                },
                [1] = { --Boastful Bellow
                    criteria = {
                        effectid = 11
                    },
                    enabled = true,
                    type = "Song",
                },
                
            },
            DPS = {
                entries = 0,
                [0] = {
                    criteria = {
                        effectid = 0
                    },
                    type = "Spell",
                    startattacking = 60,
                    target = "enemy",
                    weave = false,
                    delay = 10000
                },
            }
        }
    },
    ["WAR"] = {
        [1] = {
            Buffs = {
                entries = 0,
                [165] = { --Talisman line spell_category (emu),
                    criteria = {
                        effectid = 11
                    },
                    who = "all",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
            },
            Heals = {
                entries = 0,
                [20] = {
                    criteria = {
                        effectid = 11
                    },
                    who = "all",
                    enabled = true,
                    healpct = 50,
                    weave = false,
                    type = "Spell",
                }
            },
            DPS = { --Kick etc isn't grabbed in the csv parser. Not sure how I will handle
                entries = 0,
                [125] = {
                    criteria = {
                        effectid = 0
                    },
                    type = "Spell",
                    startattacking = 60,
                    target = "enemy",
                    weave = false,
                    delay = 10000
                },
            }
        }
    },
    ["BST"] = {
        [1] = {
            Buffs = {
                entries = 3,
                [165] = { --Talisman line spell_category (emu),
                    criteria = {
                        effectid = 11
                    },
                    who = "all",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
                [41] = { --SoW
                    criteria = {
                        effectid = 3
                    },
                    who = "all",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
                [35] = { --Haste
                    criteria = {
                        effectid = 3
                    },
                    who = "melee",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
            },
            Heals = {
                entries = 2,
                [20] = {
                    criteria = {
                        effectid = 11
                    },
                    who = "all",
                    enabled = true,
                    healpct = 50,
                    weave = false,
                    type = "Spell",
                }
            },
            DPS = { --Kick etc isn't grabbed in the csv parser. Not sure how I will handle
                entries = 2,
                [125] = {
                    criteria = {
                        effectid = 0
                    },
                    type = "Spell",
                    startattacking = 60,
                    target = "enemy",
                    weave = false,
                    delay = 10000
                },
                [38] = { --Slow
                    criteria = {
                        effectid = 11
                    },
                    type = "Spell",
                    startattacking = 60,
                    target = "enemy",
                    weave = false,
                    delay = "debuff"
                }
            }
        }
    },
    ["ROG"] = {
        [1] = {
            Buffs = {
                entries = 3,
                [165] = { --Talisman line spell_category (emu),
                    criteria = {
                        effectid = 11
                    },
                    who = "all",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
                [41] = { --SoW
                    criteria = {
                        effectid = 3
                    },
                    who = "all",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
                [35] = { --Haste
                    criteria = {
                        effectid = 3
                    },
                    who = "melee",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
            },
            Heals = {
                entries = 2,
                [20] = {
                    criteria = {
                        effectid = 11
                    },
                    who = "all",
                    enabled = true,
                    healpct = 50,
                    weave = false,
                    type = "Spell",
                }
            },
            DPS = { --Kick etc isn't grabbed in the csv parser. Not sure how I will handle
                entries = 2,
                [125] = {
                    criteria = {
                        effectid = 0
                    },
                    type = "Spell",
                    startattacking = 60,
                    target = "enemy",
                    weave = false,
                    delay = 10000
                },
                [38] = { --Slow
                    criteria = {
                        effectid = 11
                    },
                    type = "Spell",
                    startattacking = 60,
                    target = "enemy",
                    weave = false,
                    delay = "debuff"
                }
            }
        }
    },
    ["MNK"] = {
        [1] = {
            Buffs = {
                entries = 3,
                [165] = { --Talisman line spell_category (emu),
                    criteria = {
                        effectid = 11
                    },
                    who = "all",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
                [41] = { --SoW
                    criteria = {
                        effectid = 3
                    },
                    who = "all",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
                [35] = { --Haste
                    criteria = {
                        effectid = 3
                    },
                    who = "melee",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
            },
            Heals = {
                entries = 2,
                [20] = {
                    criteria = {
                        effectid = 11
                    },
                    who = "all",
                    enabled = true,
                    healpct = 50,
                    weave = false,
                    type = "Spell",
                }
            },
            DPS = { --Kick etc isn't grabbed in the csv parser. Not sure how I will handle
                entries = 2,
                [125] = {
                    criteria = {
                        effectid = 0
                    },
                    type = "Spell",
                    startattacking = 60,
                    target = "enemy",
                    weave = false,
                    delay = 10000
                },
                [38] = { --Slow
                    criteria = {
                        effectid = 11
                    },
                    type = "Spell",
                    startattacking = 60,
                    target = "enemy",
                    weave = false,
                    delay = "debuff"
                }
            }
        }
    },
    ["SHD"] = {
        [1] = {
            Buffs = {
                entries = 3,
                [165] = { --Talisman line spell_category (emu),
                    criteria = {
                        effectid = 11
                    },
                    who = "all",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
                [41] = { --SoW
                    criteria = {
                        effectid = 3
                    },
                    who = "all",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
                [35] = { --Haste
                    criteria = {
                        effectid = 3
                    },
                    who = "melee",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
            },
            Heals = {
                entries = 2,
                [20] = {
                    criteria = {
                        effectid = 11
                    },
                    who = "all",
                    enabled = true,
                    healpct = 50,
                    weave = false,
                    type = "Spell",
                }
            },
            DPS = { --Kick etc isn't grabbed in the csv parser. Not sure how I will handle
                entries = 2,
                [125] = {
                    criteria = {
                        effectid = 0
                    },
                    type = "Spell",
                    startattacking = 60,
                    target = "enemy",
                    weave = false,
                    delay = 10000
                },
                [38] = { --Slow
                    criteria = {
                        effectid = 11
                    },
                    type = "Spell",
                    startattacking = 60,
                    target = "enemy",
                    weave = false,
                    delay = "debuff"
                }
            }
        }
    },
    ["RNG"] = {
        [1] = {
            Buffs = {
                entries = 3,
                [165] = { --Talisman line spell_category (emu),
                    criteria = {
                        effectid = 11
                    },
                    who = "all",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
                [41] = { --SoW
                    criteria = {
                        effectid = 3
                    },
                    who = "all",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
                [35] = { --Haste
                    criteria = {
                        effectid = 3
                    },
                    who = "melee",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
            },
            Heals = {
                entries = 2,
                [20] = {
                    criteria = {
                        effectid = 11
                    },
                    who = "all",
                    enabled = true,
                    healpct = 50,
                    weave = false,
                    type = "Spell",
                }
            },
            DPS = { --Kick etc isn't grabbed in the csv parser. Not sure how I will handle
                entries = 2,
                [125] = {
                    criteria = {
                        effectid = 0
                    },
                    type = "Spell",
                    startattacking = 60,
                    target = "enemy",
                    weave = false,
                    delay = 10000
                },
                [38] = { --Slow
                    criteria = {
                        effectid = 11
                    },
                    type = "Spell",
                    startattacking = 60,
                    target = "enemy",
                    weave = false,
                    delay = "debuff"
                }
            }
        }
    },
    ["ENC"] = {
        [1] = {
            Buffs = {
                entries = 3,
                [165] = { --Talisman line spell_category (emu),
                    criteria = {
                        effectid = 11
                    },
                    who = "all",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
                [41] = { --SoW
                    criteria = {
                        effectid = 3
                    },
                    who = "all",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
                [35] = { --Haste
                    criteria = {
                        effectid = 3
                    },
                    who = "melee",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
            },
            Heals = {
                entries = 2,
                [20] = {
                    criteria = {
                        effectid = 11
                    },
                    who = "all",
                    enabled = true,
                    healpct = 50,
                    weave = false,
                    type = "Spell",
                }
            },
            DPS = { --Kick etc isn't grabbed in the csv parser. Not sure how I will handle
                entries = 2,
                [125] = {
                    criteria = {
                        effectid = 0
                    },
                    type = "Spell",
                    startattacking = 60,
                    target = "enemy",
                    weave = false,
                    delay = 10000
                },
                [38] = { --Slow
                    criteria = {
                        effectid = 11
                    },
                    type = "Spell",
                    startattacking = 60,
                    target = "enemy",
                    weave = false,
                    delay = "debuff"
                }
            }
        }
    },
    ["MAG"] = {
        [1] = {
            Buffs = {
                entries = 3,
                [165] = { --Talisman line spell_category (emu),
                    criteria = {
                        effectid = 11
                    },
                    who = "all",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
                [41] = { --SoW
                    criteria = {
                        effectid = 3
                    },
                    who = "all",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
                [35] = { --Haste
                    criteria = {
                        effectid = 3
                    },
                    who = "melee",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
            },
            Heals = {
                entries = 2,
                [20] = {
                    criteria = {
                        effectid = 11
                    },
                    who = "all",
                    enabled = true,
                    healpct = 50,
                    weave = false,
                    type = "Spell",
                }
            },
            DPS = { --Kick etc isn't grabbed in the csv parser. Not sure how I will handle
                entries = 2,
                [125] = {
                    criteria = {
                        effectid = 0
                    },
                    type = "Spell",
                    startattacking = 60,
                    target = "enemy",
                    weave = false,
                    delay = 10000
                },
                [38] = { --Slow
                    criteria = {
                        effectid = 11
                    },
                    type = "Spell",
                    startattacking = 60,
                    target = "enemy",
                    weave = false,
                    delay = "debuff"
                }
            }
        }
    },
    ["SHM"] = {
        [1] = {
            Buffs = {
                entries = 3,
                [165] = { --Talisman line spell_category (emu),
                    criteria = {
                        effectid = 11
                    },
                    who = "all",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
                [41] = { --SoW
                    criteria = {
                        effectid = 3
                    },
                    who = "all",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
                [35] = { --Haste
                    criteria = {
                        effectid = 3
                    },
                    who = "melee",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
            },
            Heals = {
                entries = 2,
                [20] = {
                    criteria = {
                        effectid = 11
                    },
                    who = "all",
                    enabled = true,
                    healpct = 50,
                    weave = false,
                    type = "Spell",
                }
            },
            DPS = { --Kick etc isn't grabbed in the csv parser. Not sure how I will handle
                entries = 2,
                [125] = {
                    criteria = {
                        effectid = 0
                    },
                    type = "Spell",
                    startattacking = 60,
                    target = "enemy",
                    weave = false,
                    delay = 10000
                },
                [38] = { --Slow
                    criteria = {
                        effectid = 11
                    },
                    type = "Spell",
                    startattacking = 60,
                    target = "enemy",
                    weave = false,
                    delay = "debuff"
                }
            }
        }
    },
    ["SHM"] = {
        [1] = {
            Buffs = {
                entries = 3,
                [165] = { --Talisman line spell_category (emu),
                    criteria = {
                        effectid = 11
                    },
                    who = "all",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
                [41] = { --SoW
                    criteria = {
                        effectid = 3
                    },
                    who = "all",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
                [35] = { --Haste
                    criteria = {
                        effectid = 3
                    },
                    who = "melee",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
            },
            Heals = {
                entries = 2,
                [20] = {
                    criteria = {
                        effectid = 11
                    },
                    who = "all",
                    enabled = true,
                    healpct = 50,
                    weave = false,
                    type = "Spell",
                }
            },
            DPS = { --Kick etc isn't grabbed in the csv parser. Not sure how I will handle
                entries = 2,
                [125] = {
                    criteria = {
                        effectid = 0
                    },
                    type = "Spell",
                    startattacking = 60,
                    target = "enemy",
                    weave = false,
                    delay = 10000
                },
                [38] = { --Slow
                    criteria = {
                        effectid = 11
                    },
                    type = "Spell",
                    startattacking = 60,
                    target = "enemy",
                    weave = false,
                    delay = "debuff"
                }
            }
        }
    },
    ["SHM"] = {
        [1] = {
            Buffs = {
                entries = 3,
                [165] = { --Talisman line spell_category (emu),
                    criteria = {
                        effectid = 11
                    },
                    who = "all",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
                [41] = { --SoW
                    criteria = {
                        effectid = 3
                    },
                    who = "all",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
                [35] = { --Haste
                    criteria = {
                        effectid = 3
                    },
                    who = "melee",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
            },
            Heals = {
                entries = 2,
                [20] = {
                    criteria = {
                        effectid = 11
                    },
                    who = "all",
                    enabled = true,
                    healpct = 50,
                    weave = false,
                    type = "Spell",
                }
            },
            DPS = { --Kick etc isn't grabbed in the csv parser. Not sure how I will handle
                entries = 2,
                [125] = {
                    criteria = {
                        effectid = 0
                    },
                    type = "Spell",
                    startattacking = 60,
                    target = "enemy",
                    weave = false,
                    delay = 10000
                },
                [38] = { --Slow
                    criteria = {
                        effectid = 11
                    },
                    type = "Spell",
                    startattacking = 60,
                    target = "enemy",
                    weave = false,
                    delay = "debuff"
                }
            }
        }
    },
    ["SHM"] = {
        [1] = {
            Buffs = {
                entries = 3,
                [165] = { --Talisman line spell_category (emu),
                    criteria = {
                        effectid = 11
                    },
                    who = "all",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
                [41] = { --SoW
                    criteria = {
                        effectid = 3
                    },
                    who = "all",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
                [35] = { --Haste
                    criteria = {
                        effectid = 3
                    },
                    who = "melee",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
            },
            Heals = {
                entries = 2,
                [20] = {
                    criteria = {
                        effectid = 11
                    },
                    who = "all",
                    enabled = true,
                    healpct = 50,
                    weave = false,
                    type = "Spell",
                }
            },
            DPS = { --Kick etc isn't grabbed in the csv parser. Not sure how I will handle
                entries = 2,
                [125] = {
                    criteria = {
                        effectid = 0
                    },
                    type = "Spell",
                    startattacking = 60,
                    target = "enemy",
                    weave = false,
                    delay = 10000
                },
                [38] = { --Slow
                    criteria = {
                        effectid = 11
                    },
                    type = "Spell",
                    startattacking = 60,
                    target = "enemy",
                    weave = false,
                    delay = "debuff"
                }
            }
        }
    },
    ["SHM"] = {
        [1] = {
            Buffs = {
                entries = 3,
                [165] = { --Talisman line spell_category (emu),
                    criteria = {
                        effectid = 11
                    },
                    who = "all",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
                [41] = { --SoW
                    criteria = {
                        effectid = 3
                    },
                    who = "all",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
                [35] = { --Haste
                    criteria = {
                        effectid = 3
                    },
                    who = "melee",
                    enabled = true,
                    combat = false,
                    type = "Spell",
                    weave = false,
                },
            },
            Heals = {
                entries = 2,
                [20] = {
                    criteria = {
                        effectid = 11
                    },
                    who = "all",
                    enabled = true,
                    healpct = 50,
                    weave = false,
                    type = "Spell",
                }
            },
            DPS = { --Kick etc isn't grabbed in the csv parser. Not sure how I will handle
                entries = 2,
                [125] = {
                    criteria = {
                        effectid = 0
                    },
                    type = "Spell",
                    startattacking = 60,
                    target = "enemy",
                    weave = false,
                    delay = 10000
                },
                [38] = { --Slow
                    criteria = {
                        effectid = 11
                    },
                    type = "Spell",
                    startattacking = 60,
                    target = "enemy",
                    weave = false,
                    delay = "debuff"
                }
            }
        }
    },
}
return Schemas