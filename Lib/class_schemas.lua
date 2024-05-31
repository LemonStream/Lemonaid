local lvl = mq.TLO.Me.Level()
local categories = {"Buffs","Heals","DPS","OOC_Songs","Combat_Songs"}
local Schemas = require("lemonaid/lib/Schemas")


local function calcSchemaLevel()--Find what level of the schema to load (matching level or closest lower #)
    if Schemas[shortName][lvl] then Write.Debug('its my level') return lvl else 
        for i=1,100 do
            local num = lvl-i
            if Schemas[shortName][num] then Write.Debug('Using schema lower level %s',num) return num end
        end
    end
end

--Could just add all hits right now, but it will create problems eventually on buffs and DPS especially
--Need to have a datapoint that it uses to choose a spell (Top level, requires tracking spell level or looking it up with mq.)
--Buffs might need to know HP increase and if I can find stacking, great. 
--Barebones working with adding all or just one/first found a good starting point.
local function findSpell (spell_cat,type_of_ability,section,how_many) --returns #how_many potential spells that match the criteria 
    if type_of_ability == "Song" then type_of_ability = "Spell" end
    Write.Info('Looking for %s cat# %s in %s which are %ss',how_many,spell_cat,section,type_of_ability)
    local clsdata = require('lemonaid/lib/Class Data/'..shortName..'_data')
    local potentialEntries = {}
    local matching_spells = 0
    for abilityLevel = mq.TLO.Me.Level() ,1,-1 do --We go down the list of spells starting at my level so we find the highest level possible for our spell_cat. 
        Write.Debug('level %s matching spells %s entries wanted %s',abilityLevel,matching_spells,how_many)
        if not clsdata[abilityLevel] or not clsdata[abilityLevel][type_of_ability] then Write.Debug('No spells in class data for level %s',abilityLevel) else 
            for spellName, spellDataTable in pairs(clsdata[abilityLevel][type_of_ability]) do --SHM_Data.Level.Spell
                if matching_spells == how_many then Write.Debug('Found %s spells, stopping',matching_spells) break end --Only find the first how_many spells to return. No intelligent logic to choose a spell yet. 
                local curSpellCat = spellDataTable["spell_category"]
                Write.Debug('spellName: %s category %s = %s current matching %s out of %s',spellName,curSpellCat,spell_cat,matching_spells,how_many)
                --Only matching logic is category. Would want to match cat, and then match everything in the (unused) criteria field
                --Write this loop to accept any criteria and have spell_category included in criteria? Or leave as-is and add additional checks cause this is just for me. 
                if tonumber(curSpellCat) == spell_cat and matching_spells ~= how_many then --Spell category match, add it to the list of things we might add
                    schemaInfo = Schemas[shortName][schemalevel][section][spell_cat]
                    matching_spells = matching_spells+1
                    Write.Info('%s is a spell category match on cat# %s = %s section %s',spellName,curSpellCat, spell_cat,section)
                    if section == "Buffs" then
                        potentialEntries[spellName] = {
                            Enabled = true, InCombat = schemaInfo.combat, weave = schemaInfo.weave, Target=schemaInfo.who, Type =schemaInfo.type, Tier=1, Ready = "function() return true"
                        }
                    elseif section == "Heals" then
                        potentialEntries[spellName] = {
                            Enabled = true, HP = schemaInfo.healpct, weave = schemaInfo.weave, Target=schemaInfo.who, Type =schemaInfo.type, Tier=1, Ready = "function() return true"
                        }
                    else --Catching other categories atm. Since the stuff is nil though, it essentially skips it and only includes what's in the schema. Do I really need 3 separate sections? Just one section with all possible schema entries would work too
                        potentialEntries[spellName] = {
                            Enabled = true, HP = schemaInfo.startattacking, weave = schemaInfo.weave, Target=schemaInfo.target, Type =schemaInfo.type, Delay=schemaInfo.delay, Ready = "function() return true"
                        }
                    end
                    if matching_spells == how_many then Write.Debug('Found %s spells, stopping',matching_spells) break end
                end
            end
        end
    end
    
        --We've added all matching spells, now need to choose just #entries
    Write.Debug('returning %s spells',tableLength(potentialEntries))
    printTable(potentialEntries)
    return potentialEntries, matching_spells
end

function ChooseSchema()
        schemalevel = calcSchemaLevel() or -1 --Highest/closest level schema entry
        Write.Debug("schemalLevel is %s",schemalevel)
        for _,Category in ipairs(categories) do --Iterate over each Category in that spell type (buffs/dps/heals)
            DefaultCharacter[Category] = {} --Blank out defaultcharacter.lua file section
            Write.Error('Creating %s lvl %s',Category,schemalevel)
            local SchemaSection = Schemas[shortName][schemalevel][Category]
            local numFoundEntries = 0
            local spellsToWrite = {}
            if not SchemaSection then elseif SchemaSection.entries > 0 then
                for spell_category,_ in pairs(SchemaSection) do --for each Spell_cat in our schema category (buffs etc) we try and find a matching one at our current abilityLevel in our _data from findSpell
                    if spell_category == 'entries' then else
                        Write.Debug('spell_category %s',spell_category)
                        local foundSpells,tempFound = findSpell(spell_category,SchemaSection[spell_category].type,Category,1)
                        if tempFound > 0 then
                            for spellnamekey in pairs(foundSpells) do
                                Write.Debug('extracting spellname %s',spellnamekey)
                                spellsToWrite[spellnamekey] = foundSpells[spellnamekey]
                            end
                        end
                        numFoundEntries = numFoundEntries + tempFound
                        if numFoundEntries == SchemaSection.entries then
                            Write.Debug('Found %s entries for %s, done with this section',numFoundEntries,Category)
                            DefaultCharacter[Category] = spellsToWrite
                            numFoundEntries = 0
                            break
                        end
                    end
                end
            end
            Write.Debug('Found %s entries for %s, done with this section',numFoundEntries,Category)
            DefaultCharacter[Category] = spellsToWrite
            numFoundEntries = 0
        end

    
end