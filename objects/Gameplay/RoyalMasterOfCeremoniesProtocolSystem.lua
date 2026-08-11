-- objects/Gameplay/RoyalMasterOfCeremoniesProtocolSystem.lua
-- Castle Kingdoms 2027 v3.5.2 - Royal Master of Ceremonies & Protocol System
--
-- Manages court ceremonies, protocol, etiquette, and formal events.
-- Provides prestige, diplomatic bonuses, and proper court functioning.
--
-- Features:
-- - 8 ceremony types (coronation, investiture, audience, reception, ...)
-- - 6 protocol rules (seating, addressing, gift-giving, ...)
-- - 4 protocol buildings (throne room, great hall, audience chamber, reception hall)
-- - Master of Ceremonies NPC (skill affects event quality)
-- - Etiquette training for courtiers
-- - Formal event organization
-- - Diplomatic protocol bonuses
-- - Court hierarchy management

local Ceremonies = {}

-- ============================================================
-- CEREMONY TYPES
-- ============================================================
local CEREMONIES = {
    coronation = {
        name = "Kronanje",
        nameEn = "Coronation",
        cost = 5000,
        duration = 3,
        prestigeReward = 50,
        happinessBonus = 20,
        description = "Največja slovesnost — kronanje monarha.",
    },
    investiture = {
        name = "Investitura",
        nameEn = "Investiture",
        cost = 1000,
        duration = 1,
        prestigeReward = 15,
        happinessBonus = 8,
        description = "Podelitev naslova ali fevda.",
    },
    audience = {
        name = "Audienco",
        nameEn = "Audience",
        cost = 200,
        duration = 1,
        prestigeReward = 5,
        diplomaticBonus = 10,
        description = "Formalni sprejem pri monarhu.",
    },
    reception = {
        name = "Recepcija",
        nameEn = "Reception",
        cost = 500,
        duration = 1,
        prestigeReward = 8,
        happinessBonus = 5,
        description = "Sprejem za veleposlanike in plemiče.",
    },
    banquet = {
        name = "Državni banket",
        nameEn = "State Banquet",
        cost = 2000,
        duration = 1,
        prestigeReward = 20,
        happinessBonus = 15,
        diplomaticBonus = 15,
        description = "Veliki banket za posebne priložnosti.",
    },
    tournament_opening = {
        name = "Otvoritev turnirja",
        nameEn = "Tournament Opening",
        cost = 800,
        duration = 1,
        prestigeReward = 12,
        happinessBonus = 10,
        description = "Slovesna otvoritev turnirja.",
    },
    wedding_ceremony = {
        name = "Porokna slovesnost",
        nameEn = "Wedding Ceremony",
        cost = 3000,
        duration = 2,
        prestigeReward = 30,
        happinessBonus = 25,
        description = "Kraljevska poroka.",
    },
    funeral = {
        name = "Državni pogreb",
        nameEn = "State Funeral",
        cost = 1500,
        duration = 3,
        prestigeReward = 10,
        happinessBonus = -5,  -- sad occasion
        description = "Pogreb pomembne osebe.",
    },
}

-- ============================================================
-- PROTOCOL RULES
-- ============================================================
local PROTOCOL = {
    seating = {
        name = "Sedežni red",
        nameEn = "Seating Order",
        importance = 5,
        description = "Hierarhični red sedenja pri slovesnostih.",
    },
    addressing = {
        name = "Obravnava",
        nameEn = "Forms of Address",
        importance = 4,
        description = "Pravilna titulatura in nagovarjanje.",
    },
    gift_giving = {
        name = "Darovanje",
        nameEn = "Gift-Giving",
        importance = 4,
        description = "Protokol darovanja pri diplomatskih srečanjih.",
    },
    precedence = {
        name = "Prednost",
        nameEn = "Precedence",
        importance = 5,
        description = "Vrstni red pri procesijah in slovesnostih.",
    },
    dress_code = {
        name = "Obleka",
        nameEn = "Dress Code",
        importance = 3,
        description = "Pravila o primerni obleki za dvor.",
    },
    audience_protocol = {
        name = "Audiencni protokol",
        nameEn = "Audience Protocol",
        importance = 4,
        description = "Kako pristopiti monarhu in govoriti z njim.",
    },
}

-- ============================================================
-- PROTOCOL BUILDINGS
-- ============================================================
local BUILDINGS = {
    throne_room = {
        name = "Prestolna dvorana",
        cost = { gold = 3000, wood = 500, stone = 800, gold_ornament = 200 },
        upkeep = 60,
        ceremonyBonus = 20,
        prestigeBonus = 15,
        description = "Velika dvorana s prestolom za slovesnosti.",
    },
    great_hall = {
        name = "Velika dvorana",
        cost = { gold = 2000, wood = 400, stone = 500 },
        upkeep = 40,
        ceremonyBonus = 15,
        capacity = 100,
        description = "Dvorana za bankete in sprejeme.",
    },
    audience_chamber = {
        name = "Audiencna dvorana",
        cost = { gold = 1500, wood = 300, stone = 400 },
        upkeep = 30,
        ceremonyBonus = 10,
        diplomaticBonus = 10,
        description = "Manjša dvorana za formalne audiencе.",
    },
    reception_hall = {
        name = "Recepcijska dvorana",
        cost = { gold = 1000, wood = 200, stone = 300 },
        upkeep = 20,
        ceremonyBonus = 8,
        capacity = 50,
        description = "Dvorana za sprejeme diplomatov.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Ceremonies.activeCeremonies = {}
Ceremonies.buildings = {}
Ceremonies.masterOfCeremonies = nil
Ceremonies.protocolAdoption = {}  -- Which protocols are adopted
Ceremonies.courtierEtiquette = 50  -- 0-100
Ceremonies.totalCeremonies = 0
Ceremonies.prestigeFromCeremonies = 0
Ceremonies.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Ceremonies.init()
    Ceremonies.activeCeremonies = {}
    Ceremonies.buildings = {}
    Ceremonies.masterOfCeremonies = nil
    Ceremonies.protocolAdoption = {}
    Ceremonies.courtierEtiquette = 50
    Ceremonies.totalCeremonies = 0
    Ceremonies.prestigeFromCeremonies = 0
    Ceremonies.dayTimer = 0
    print("[Ceremonies] Royal Master of Ceremonies & Protocol System initialized (8 ceremonies, 6 protocols, 4 buildings)")
end

-- ============================================================
-- MASTER OF CEREMONIES NPC
-- ============================================================
function Ceremonies.hireMasterOfCeremonies(name, skill)
    skill = skill or math.random(50, 90)
    local cost = 500 + skill * 10
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    Ceremonies.masterOfCeremonies = {
        name = name or ("Mojster ceremonij " .. math.random(1, 99)),
        skill = skill,
        hiredDay = os.time(),
        ceremoniesOrganized = 0,
    }
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Mojster ceremonij najet: %s (spretnost: %d)", Ceremonies.masterOfCeremonies.name, skill), "success")
    end
    return true
end

-- ============================================================
-- BUILDINGS
-- ============================================================
function Ceremonies.canBuild(buildingId)
    local def = BUILDINGS[buildingId]
    if not def then return false, "Neznana zgradba" end
    if not _G.state then return false, "Brez stanja" end
    if _G.state.gold < (def.cost.gold or 0) then return false, "Premalo zlata" end
    if _G.state.resources then
        for res, amt in pairs(def.cost) do
            if res ~= "gold" and (_G.state.resources[res] or 0) < amt then
                return false, "Premalo " .. res
            end
        end
    end
    return true
end

function Ceremonies.build(buildingId)
    local ok, err = Ceremonies.canBuild(buildingId)
    if not ok then return false, err end
    local def = BUILDINGS[buildingId]
    _G.state.gold = _G.state.gold - (def.cost.gold or 0)
    if _G.state.resources then
        for res, amt in pairs(def.cost) do
            if res ~= "gold" then
                _G.state.resources[res] = (_G.state.resources[res] or 0) - amt
            end
        end
    end
    table.insert(Ceremonies.buildings, {
        type = buildingId,
        builtDay = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. def.name, "success")
    end
    return true
end

function Ceremonies.getCeremonyBonus()
    local bonus = 0
    for _, b in ipairs(Ceremonies.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.ceremonyBonus then bonus = bonus + def.ceremonyBonus end
    end
    return bonus
end

function Ceremonies.getPrestigeBonus()
    local bonus = 0
    for _, b in ipairs(Ceremonies.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.prestigeBonus then bonus = bonus + def.prestigeBonus end
    end
    return bonus
end

-- ============================================================
-- PROTOCOL ADOPTION
-- ============================================================
function Ceremonies.adoptProtocol(protocolId)
    local def = PROTOCOL[protocolId]
    if not def then return false, "Neznan protokol" end
    if Ceremonies.protocolAdoption[protocolId] then
        return false, "Protokol že sprejet"
    end
    -- Cost: 200 gold per importance level
    local cost = def.importance * 200
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    Ceremonies.protocolAdoption[protocolId] = true
    -- Etiquette boost
    Ceremonies.courtierEtiquette = math.min(100, Ceremonies.courtierEtiquette + def.importance * 2)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Protokol sprejet: %s (+%d etiquette)", def.name, def.importance * 2), "success")
    end
    return true
end

-- ============================================================
-- CEREMONY ORGANIZATION
-- ============================================================
function Ceremonies.canOrganize(ceremonyType)
    local def = CEREMONIES[ceremonyType]
    if not def then return false, "Neznana slovesnost" end
    if not _G.state or (_G.state.gold or 0) < def.cost then
        return false, "Premalo zlata"
    end
    -- Need at least one ceremony building
    if #Ceremonies.buildings == 0 then
        return false, "Potrebna slovesna dvorana"
    end
    return true
end

function Ceremonies.organize(ceremonyType)
    local ok, err = Ceremonies.canOrganize(ceremonyType)
    if not ok then return false, err end
    local def = CEREMONIES[ceremonyType]
    _G.state.gold = _G.state.gold - def.cost
    -- Calculate quality
    local quality = 1.0
    quality = quality + (Ceremonies.getCeremonyBonus() / 100)
    if Ceremonies.masterOfCeremonies then
        quality = quality + (Ceremonies.masterOfCeremonies.skill / 200)
    end
    quality = quality + (Ceremonies.courtierEtiquette / 200)
    quality = math.min(2.0, quality)
    local ceremony = {
        id = "ceremony_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        type = ceremonyType,
        name = def.name,
        daysRemaining = def.duration,
        prestigeReward = math.floor(def.prestigeReward * quality),
        happinessBonus = math.floor(def.happinessBonus * quality),
        diplomaticBonus = math.floor((def.diplomaticBonus or 0) * quality),
        quality = quality,
        started = os.time(),
    }
    table.insert(Ceremonies.activeCeremonies, ceremony)
    Ceremonies.totalCeremonies = Ceremonies.totalCeremonies + 1
    if Ceremonies.masterOfCeremonies then
        Ceremonies.masterOfCeremonies.ceremoniesOrganized = Ceremonies.masterOfCeremonies.ceremoniesOrganized + 1
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Slovesnost organizirana: %s (kakovost: %.1f)", def.name, quality), "important")
    end
    return true
end

function Ceremonies.completeCeremony(ceremony)
    -- Apply rewards
    if _G.state and _G.state.happiness then
        _G.state.happiness = math.max(0, math.min(100, _G.state.happiness + ceremony.happinessBonus))
    end
    Ceremonies.prestigeFromCeremonies = Ceremonies.prestigeFromCeremonies + ceremony.prestigeReward
    -- Diplomatic bonus
    if ceremony.diplomaticBonus > 0 and _G.DiplomacyController then
        pcall(_G.DiplomacyController.changeRelation, "all", ceremony.diplomaticBonus)
    end
    -- Master of Ceremonies skill progression
    if Ceremonies.masterOfCeremonies and math.random() < 0.25 then
        Ceremonies.masterOfCeremonies.skill = math.min(100, Ceremonies.masterOfCeremonies.skill + 1)
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Slovesnost končana: %s (+%d prestiža, +%d sreče)",
                ceremony.name, ceremony.prestigeReward, ceremony.happinessBonus), "success")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "CEREMONY_COMPLETED", {
            type = ceremony.type, prestige = ceremony.prestigeReward,
        })
    end
end

-- ============================================================
-- ETIQUETTE TRAINING
-- ============================================================
function Ceremonies.trainEtiquette()
    if not _G.state or (_G.state.gold or 0) < 300 then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - 300
    local gain = 5
    if Ceremonies.masterOfCeremonies then
        gain = gain + math.floor(Ceremonies.masterOfCeremonies.skill / 10)
    end
    Ceremonies.courtierEtiquette = math.min(100, Ceremonies.courtierEtiquette + gain)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Etiketa urjena! +%d (skupaj: %d)", gain, Ceremonies.courtierEtiquette), "info")
    end
    return true
end

-- ============================================================
-- UPDATE
-- ============================================================
function Ceremonies.update(dt)
    if not _G.state then return end
    Ceremonies.dayTimer = Ceremonies.dayTimer + dt
    if Ceremonies.dayTimer >= 30 then
        Ceremonies.dayTimer = 0
        -- Process ceremonies
        for i = #Ceremonies.activeCeremonies, 1, -1 do
            local c = Ceremonies.activeCeremonies[i]
            c.daysRemaining = c.daysRemaining - 1
            if c.daysRemaining <= 0 then
                Ceremonies.completeCeremony(c)
                table.remove(Ceremonies.activeCeremonies, i)
            end
        end
        -- Pay upkeep
        local totalUpkeep = 0
        for _, b in ipairs(Ceremonies.buildings) do
            local def = BUILDINGS[b.type]
            if def and def.upkeep then totalUpkeep = totalUpkeep + def.upkeep end
        end
        if Ceremonies.masterOfCeremonies then totalUpkeep = totalUpkeep + 25 end
        if totalUpkeep > 0 and _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep)
        end
        -- Etiquette slowly decays
        if Ceremonies.courtierEtiquette > 50 then
            Ceremonies.courtierEtiquette = Ceremonies.courtierEtiquette - 0.5
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Ceremonies.getCeremonyInfo(ceremonyId) return CEREMONIES[ceremonyId] end
function Ceremonies.getProtocolInfo(protocolId) return PROTOCOL[protocolId] end
function Ceremonies.getBuildingInfo(buildingId) return BUILDINGS[buildingId] end

function Ceremonies.getStats()
    return {
        activeCeremonies = #Ceremonies.activeCeremonies,
        numBuildings = #Ceremonies.buildings,
        hasMasterOfCeremonies = Ceremonies.masterOfCeremonies ~= nil,
        masterOfCeremoniesName = Ceremonies.masterOfCeremonies and Ceremonies.masterOfCeremonies.name or "—",
        masterOfCeremoniesSkill = Ceremonies.masterOfCeremonies and Ceremonies.masterOfCeremonies.skill or 0,
        adoptedProtocols = #Ceremonies.protocolAdoption,
        courtierEtiquette = Ceremonies.courtierEtiquette,
        totalCeremonies = Ceremonies.totalCeremonies,
        prestigeFromCeremonies = Ceremonies.prestigeFromCeremonies,
    }
end

return Ceremonies
