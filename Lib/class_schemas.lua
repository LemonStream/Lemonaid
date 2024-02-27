local lvl = mq.TLO.Me.Level()
Schemas = {
    ["SHM"] = {
        [1] = {
            Buffs = {
                [165] = { --Talisman line spell_category (emu)
                    who = "all",
                    enabled = true,
                    combat = false,
                }
            },
            Heals = {
                [20] = {
                    who = "all",
                    enabled = true,
                    healpct = 50,
                    weave = false,
                }
            },
            DPS = { --Kick etc isn't grabbed in the file. WIll just need to add a manual entry in the schema?
                [125] = {
                    type = "spell",
                    startattacking = 60,
                    target = "enemy",
                    weave = false
                }
            }
        }
    }
}

function ChooseSchema()
    printf("Schemas.shortname %s",Schemas[shortName])
    for Category,spellcat in Schemas[shortName] do
        Write.Debug("Category %s spellcat %s Schemas.shortname %s",Category,spellcat,Schemas[shortName])
        DefaultCharacter[Category] = {} --Blank out defaultcharacter.lua file section
        local schemalevel = Schemas[shortName][lvl] or function ()--Find what level of the schema to load (matching level or closest lower #)
            for i=1,100 do
                if Schemas[shortName][lvl-i] then return i end
            end 
        end
        Write.Debug("schemalLevel is %s",schemalevel)
        --Iterate over each spell_category in that category (buffs/dps/heals)
            --Find the spell that matches the criteria in the schema from the CLS_data.lua

    end
    
end