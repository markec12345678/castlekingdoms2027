-- objects/Config/RoyalAstrologerOmensSystem.lua
-- Castle Kingdoms 2027 v3.3.3 - Royal Astrologer & Omens System
--
-- Manages court astrologers, star readings, omens, and prophecies.
-- Provides insights into future events and happiness modifiers.
--
-- Features:
-- - 6 omen types (comet, eclipse, blood moon, shooting star, planetary alignment, northern lights)
-- - 8 prophecy types (victory, defeat, famine, plague, birth, death, alliance, betrayal)
-- - Astrologer NPC (skill affects accuracy)
-- - Observatory building (better readings)
-- - Star chart tracking
-- - Omen interpretation (player choices affect outcomes)
-- - Prophecy fulfillment tracking
-- - Superstition level (affects population happiness)

local Astrology = {}

-- ============================================================
-- OMEN TYPES
-- ============================================================
local OMENS = {
    comet = {
        name = "Komet",
        nameEn = "Comet",
        rarity = 3,
        happinessEffect = -8,
        defaultInterpretation = "Slaba znamenja — komet napoveduje nesrečo.",
        duration = 7,
    },
    eclipse = {
        name = "Mrk",
        nameEn = "Eclipse",
        rarity = 4,
        happinessEffect = -5,
        defaultInterpretation = "Mrk — božje nezadovoljstvo.",
        duration = 1,
    },
    blood_moon = {
        name = "Krvavi mesec",
        nameEn = "Blood Moon",
        rarity = 5,
        happinessEffect = -12,
        defaultInterpretation = "Krvavi mesec — vojna in prelivanje krvi.",
        duration = 1,
    },
    shooting_star = {
        name = "Padajoča zvezda",
        nameEn = "Shooting Star",
        rarity = 1,
        happinessEffect = 3,
        defaultInterpretation = "Padajoča zvezda — želja se bo izpolnila.",
        duration = 1,
    },
    planetary_alignment = {
        name = "Poravnava planetov",
        nameEn = "Planetary Alignment",
        rarity = 5,
        happinessEffect = 8,
        defaultInterpretation = "Poravnava planetov — velika sreča in blagoslov.",
        duration = 3,
    },
    northern_lights = {
        name = "Severni siji",
        nameEn = "Northern Lights",
        rarity = 2,
        happinessEffect = 5,
        defaultInterpretation = "Severni siji — božanski znak odobravanja.",
        duration = 2,
    },
}

-- ============================================================
-- PROPHECY TYPES
-- ============================================================
local PROPHECIES = {
    victory = {
        name = "Prerokba zmage",
        nameEn = "Victory Prophecy",
        fulfillmentChance = 0.40,
        duration = 60,
        description = "Napovedana zmaga v prihajajoči bitki.",
    },
    defeat = {
        name = "Prerokba poraza",
        nameEn = "Defeat Prophecy",
        fulfillmentChance = 0.30,
        duration = 60,
        description = "Napovedan poraz — nevarno obdobje.",
    },
    famine = {
        name = "Prerokba lakote",
        nameEn = "Famine Prophecy",
        fulfillmentChance = 0.25,
        duration = 90,
        description = "Napovedana lakota v prihodnjih letih.",
    },
    plague = {
        name = "Prerokba kuge",
        nameEn = "Plague Prophecy",
        fulfillmentChance = 0.20,
        duration = 90,
        description = "Napovedana kuga — smrtonosna bolezen.",
    },
    birth = {
        name = "Prerokba rojstva",
        nameEn = "Birth Prophecy",
        fulfillmentChance = 0.60,
        duration = 120,
        description = "Napovedano rojstvo dediča.",
    },
    death = {
        name = "Prerokba smrti",
        nameEn = "Death Prophecy",
        fulfillmentChance = 0.35,
        duration = 90,
        description = "Napovedana smrt pomembne osebe.",
    },
    alliance = {
        name = "Prerokba zveze",
        nameEn = "Alliance Prophecy",
        fulfillmentChance = 0.45,
        duration = 60,
        description = "Napovedana močna zveza.",
    },
    betrayal = {
        name = "Prerokba izdaje",
        nameEn = "Betrayal Prophecy",
        fulfillmentChance = 0.30,
        duration = 60,
        description = "Napovedana izdaja znotraj dvora.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Astrology.astrologer = nil               -- Hired astrologer
Astrology.observatory = false            -- Has observatory
Astrology.activeOmens = {}               -- Currently visible omens
Astrology.activeProphecies = {}          -- Pending prophecies
Astrology.fulfilledProphecies = {}       -- Completed prophecies
Astrology.superstitionLevel = 50         -- 0-100, affects happiness from omens
Astrology.totalOmensObserved = 0
Astrology.totalPropheciesFulfilled = 0
Astrology.totalPropheciesFailed = 0
Astrology.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Astrology.init()
    Astrology.astrologer = nil
    Astrology.observatory = false
    Astrology.activeOmens = {}
    Astrology.activeProphecies = {}
    Astrology.fulfilledProphecies = {}
    Astrology.superstitionLevel = 50
    Astrology.totalOmensObserved = 0
    Astrology.totalPropheciesFulfilled = 0
    Astrology.totalPropheciesFailed = 0
    Astrology.dayTimer = 0
    print("[Astrology] Royal Astrologer & Omens System initialized (6 omens, 8 prophecies)")
end

-- ============================================================
-- ASTROLOGER HIRING
-- ============================================================
function Astrology.hireAstrologer(name, skill)
    skill = skill or math.random(40, 90)
    local cost = 400 + skill * 10
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    Astrology.astrologer = {
        name = name or ("Astrolog " .. math.random(1, 99)),
        skill = skill,
        accuracy = 0.40 + (skill / 200),  -- 40-85% accuracy
        hiredDay = os.time(),
        readings = 0,
    }
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Astrolog najet: %s (spretnost: %d, natančnost: %.0f%%)",
                Astrology.astrologer.name, skill, Astrology.astrologer.accuracy * 100), "success")
    end
    return true
end

-- ============================================================
-- OBSERVATORY
-- ============================================================
function Astrology.buildObservatory()
    if Astrology.observatory then return false, "Že imaš observatorij" end
    if not _G.state or (_G.state.gold or 0) < 2000 then
        return false, "Premalo zlata"
    end
    if not _G.state.resources or (_G.state.resources.stone or 0) < 500 then
        return false, "Premalo kamna"
    end
    _G.state.gold = _G.state.gold - 2000
    _G.state.resources.stone = _G.state.resources.stone - 500
    Astrology.observatory = true
    if Astrology.astrologer then
        Astrology.astrologer.accuracy = math.min(0.95, Astrology.astrologer.accuracy + 0.15)
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Observatorij zgrajen! Izboljšana natančnost.", "success")
    end
    return true
end

-- ============================================================
-- OMEN GENERATION
-- ============================================================
function Astrology.generateOmen()
    -- Pick omen by rarity (rarer = less likely)
    local totalWeight = 0
    local weights = {}
    for id, def in pairs(OMENS) do
        local weight = 6 - def.rarity  -- rarer = lower weight
        weights[id] = weight
        totalWeight = totalWeight + weight
    end
    local roll = math.random() * totalWeight
    local cumulative = 0
    local selected = nil
    for id, weight in pairs(weights) do
        cumulative = cumulative + weight
        if roll <= cumulative then
            selected = id
            break
        end
    end
    if not selected then return end
    local def = OMENS[selected]
    local omen = {
        id = "omen_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        type = selected,
        name = def.name,
        happinessEffect = def.happinessEffect,
        daysRemaining = def.duration,
        observedDay = os.time(),
        interpretation = def.defaultInterpretation,
    }
    table.insert(Astrology.activeOmens, omen)
    Astrology.totalOmensObserved = Astrology.totalOmensObserved + 1
    -- Apply happiness effect (modified by superstition)
    local effectMod = Astrology.superstitionLevel / 50  -- 1.0 at 50, 2.0 at 100
    local actualEffect = omen.happinessEffect * effectMod
    if _G.state and _G.state.happiness then
        _G.state.happiness = math.max(0, math.min(100, _G.state.happiness + actualEffect))
    end
    if _G.NotificationCenter then
        local msg = string.format("Znamenje opaženo: %s!", def.name)
        if omen.happinessEffect > 0 then
            pcall(_G.NotificationCenter.notify, msg, "info")
        else
            pcall(_G.NotificationCenter.notify, msg, "warning")
        end
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "OMEN_OBSERVED", { type = selected, name = def.name })
    end
end

function Astrology.interpretOmen(omenId, interpretation)
    for _, o in ipairs(Astrology.activeOmens) do
        if o.id == omenId then
            o.interpretation = interpretation
            -- Different interpretations affect happiness differently
            if interpretation == "positive" then
                if _G.state and _G.state.happiness then
                    _G.state.happiness = math.min(100, _G.state.happiness + 3)
                end
            elseif interpretation == "negative" then
                if _G.state and _G.state.happiness then
                    _G.state.happiness = math.max(0, _G.state.happiness - 3)
                end
            end
            return true
        end
    end
    return false
end

-- ============================================================
-- PROPHECY GENERATION
-- ============================================================
function Astrology.generateProphecy()
    if not Astrology.astrologer then return false, "Potreben astrolog" end
    -- Pick random prophecy type
    local prophecyKeys = {}
    for k, _ in pairs(PROPHECIES) do
        table.insert(prophecyKeys, k)
    end
    local selected = prophecyKeys[math.random(#prophecyKeys)]
    local def = PROPHECIES[selected]
    -- Accuracy affects fulfillment chance
    local adjustedChance = def.fulfillmentChance * (0.5 + Astrology.astrologer.accuracy)
    local prophecy = {
        id = "prophecy_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        type = selected,
        name = def.name,
        fulfillmentChance = adjustedChance,
        daysRemaining = def.duration,
        totalDays = def.duration,
        made = os.time(),
        fulfilled = false,
        failed = false,
    }
    table.insert(Astrology.activeProphecies, prophecy)
    Astrology.astrologer.readings = Astrology.astrologer.readings + 1
    -- Increase skill with use
    if math.random() < 0.20 then
        Astrology.astrologer.skill = math.min(100, Astrology.astrologer.skill + 1)
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Prerokba: %s (natančnost: %.0f%%)",
                def.name, adjustedChance * 100), "important")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "PROPHECY_MADE", { type = selected, name = def.name })
    end
    return true
end

function Astrology.checkProphecyFulfillment()
    for i = #Astrology.activeProphecies, 1, -1 do
        local p = Astrology.activeProphecies[i]
        p.daysRemaining = p.daysRemaining - 1
        -- Try fulfillment each day
        if not p.fulfilled and not p.failed then
            local dailyChance = p.fulfillmentChance / p.totalDays
            if math.random() < dailyChance then
                p.fulfilled = true
                Astrology.totalPropheciesFulfilled = Astrology.totalPropheciesFulfilled + 1
                if _G.NotificationCenter then
                    pcall(_G.NotificationCenter.notify,
                        string.format("PREROKBA IZPOLNJENA: %s!", p.name), "rare")
                end
                if _G.GameEventBus then
                    pcall(_G.GameEventBus.publish, "PROPHECY_FULFILLED", { type = p.type, name = p.name })
                end
                table.insert(Astrology.fulfilledProphecies, p)
                table.remove(Astrology.activeProphecies, i)
            elseif p.daysRemaining <= 0 then
                p.failed = true
                Astrology.totalPropheciesFailed = Astrology.totalPropheciesFailed + 1
                table.remove(Astrology.activeProphecies, i)
            end
        end
    end
end

-- ============================================================
-- UPDATE
-- ============================================================
function Astrology.update(dt)
    if not _G.state then return end
    Astrology.dayTimer = Astrology.dayTimer + dt
    if Astrology.dayTimer >= 30 then
        Astrology.dayTimer = 0
        -- Random omen chance (5% per day, modified by observatory)
        local omenChance = 0.05
        if Astrology.observatory then omenChance = omenChance + 0.05 end
        if math.random() < omenChance then
            Astrology.generateOmen()
        end
        -- Random prophecy generation if astrologer hired
        if Astrology.astrologer and math.random() < 0.02 then
            Astrology.generateProphecy()
        end
        -- Update omens
        for i = #Astrology.activeOmens, 1, -1 do
            local o = Astrology.activeOmens[i]
            o.daysRemaining = o.daysRemaining - 1
            if o.daysRemaining <= 0 then
                table.remove(Astrology.activeOmens, i)
            end
        end
        -- Check prophecies
        Astrology.checkProphecyFulfillment()
        -- Pay upkeep
        if Astrology.astrologer and _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - 20)
        end
        -- Superstition slowly changes based on omens
        if #Astrology.activeOmens > 0 then
            Astrology.superstitionLevel = math.min(100, Astrology.superstitionLevel + 0.5)
        else
            Astrology.superstitionLevel = math.max(0, Astrology.superstitionLevel - 0.2)
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Astrology.getOmenInfo(omenId) return OMENS[omenId] end
function Astrology.getProphecyInfo(prophecyId) return PROPHECIES[prophecyId] end

function Astrology.getStats()
    return {
        hasAstrologer = Astrology.astrologer ~= nil,
        astrologerName = Astrology.astrologer and Astrology.astrologer.name or "—",
        astrologerSkill = Astrology.astrologer and Astrology.astrologer.skill or 0,
        astrologerAccuracy = Astrology.astrologer and Astrology.astrologer.accuracy or 0,
        hasObservatory = Astrology.observatory,
        activeOmens = #Astrology.activeOmens,
        activeProphecies = #Astrology.activeProphecies,
        totalOmensObserved = Astrology.totalOmensObserved,
        totalPropheciesFulfilled = Astrology.totalPropheciesFulfilled,
        totalPropheciesFailed = Astrology.totalPropheciesFailed,
        superstitionLevel = Astrology.superstitionLevel,
    }
end

return Astrology
