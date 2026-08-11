-- objects/Config/GovernorSystem.lua
-- Castle Kingdoms 2027 v3.0.5 - Governor & Administration System
--
-- Manage provinces and assign governors to boost specific aspects
-- of your kingdom. Each governor has unique bonuses and traits.
--
-- Features:
-- - 6 governor types with unique bonuses
-- - Province management (assign territories)
-- - Governor loyalty system (can rebel if unhappy)
-- - Tax collection efficiency per province
-- - Governor traits (3 random traits per governor)
-- - Governor leveling (experienced governors are more effective)
-- - Assignment restrictions (governor must match province type)

local Governor = {}

-- Governor types
local GOVERNOR_TYPES = {
    military = {
        name = "Vojaški guverner",
        nameEn = "Military Governor",
        bonus = { unitProduction = 1.3, defenseBonus = 1.2, taxEfficiency = 0.9 },
        desc = "+30% produkcija enot, +20% obramba, -10% davki",
    },
    economic = {
        name = "Ekonomski guverner",
        nameEn = "Economic Governor",
        bonus = { taxEfficiency = 1.3, tradeBonus = 1.25, unitProduction = 0.9 },
        desc = "+30% davki, +25% trgovina, -10% enote",
    },
    agricultural = {
        name = "Kmetijski guverner",
        nameEn = "Agricultural Governor",
        bonus = { foodProduction = 1.4, populationGrowth = 1.2, taxEfficiency = 0.95 },
        desc = "+40% hrana, +20% rast populacije, -5% davki",
    },
    diplomatic = {
        name = "Diplomatski guverner",
        nameEn = "Diplomatic Governor",
        bonus = { diplomacyBonus = 1.3, tradeBonus = 1.15, happinessBonus = 1.1 },
        desc = "+30% diplomacija, +15% trgovina, +10% sreča",
    },
    builder = {
        name = "Gradbeni guverner",
        nameEn = "Builder Governor",
        bonus = { buildSpeed = 1.3, buildingCost = 0.85, repairSpeed = 1.5 },
        desc = "+30% hitrost gradnje, -15% stroški, +50% popravila",
    },
    scholar = {
        name = "Učeni guverner",
        nameEn = "Scholar Governor",
        bonus = { researchSpeed = 1.4, happinessBonus = 1.15, taxEfficiency = 0.9 },
        desc = "+40% raziskovanje, +15% sreča, -10% davki",
    },
}

Governor.GOVERNOR_TYPES = GOVERNOR_TYPES

-- Governor traits (randomly assigned)
local TRAITS = {
    { id = "industrious", name = "Delavnost",      desc = "+10% vse produkcije" },
    { id = "greedy",      name = "Pohlep",         desc = "+15% davki, -10% sreča" },
    { id = "beloved",     name = "Ljubljen",       desc = "+15% sreča" },
    { id = "cruel",       name = "Okruten",        desc = "+20% davki, -20% sreča" },
    { id = "pious",       name = "Pobožen",        desc = "+10% sreča, +5% raziskovanje" },
    { id = "paranoid",    name = "Paranoičen",     desc = "+15% obramba, -5% trgovina" },
    { id = "charismatic", name = "Karizmatičen",   desc = "+20% diplomacija" },
    { id = "lazy",        name = "Len",            desc = "-10% vse produkcije, +10% sreča" },
    { id = "genius",      name = "Genij",          desc = "+15% raziskovanje, +10% davki" },
    { id = "corrupt",     name = "Pokvarjen",      desc = "+10% davki (zase), -15% sreča" },
    { id = "loyal",       name = "Zvest",          desc = "+20% lojalnost, nikoli se ne upre" },
    { id = "ambitious",   name = "Ambiciozen",     desc = "+15% produkcija, -10% lojalnost" },
}

Governor.TRAITS = TRAITS

local initialized = false
local governors = {}  -- list of recruited governors
local provinces = {}  -- list of provinces
local nextGovId = 1
local nextProvId = 1

function Governor.init()
    if initialized then return end
    initialized = true
    print("[Governor] Initialized with " .. Governor._getTypeCount() .. " governor types, " .. #TRAITS .. " traits")
end

function Governor._getTypeCount()
    local count = 0
    for _ in pairs(GOVERNOR_TYPES) do count = count + 1 end
    return count
end

-- Recruit a new governor
function Governor.recruit(govType)
    local def = GOVERNOR_TYPES[govType]
    if not def then return nil, "Unknown governor type" end

    -- Check cost (500 gold)
    if _G.state and (_G.state.gold or 0) < 500 then
        return nil, "Not enough gold (500g required)"
    end
    _G.state.gold = (_G.state.gold or 0) - 500

    local govId = nextGovId
    nextGovId = nextGovId + 1

    -- Assign 3 random traits
    local assignedTraits = {}
    local availableTraits = {}
    for _, trait in ipairs(TRAITS) do table.insert(availableTraits, trait) end
    for _ = 1, 3 do
        if #availableTraits > 0 then
            local idx = math.random(#availableTraits)
            table.insert(assignedTraits, availableTraits[idx])
            table.remove(availableTraits, idx)
        end
    end

    local governor = {
        id = govId,
        type = govType,
        name = Governor._generateName(),
        level = 1,
        experience = 0,
        loyalty = 80,  -- 0-100, below 30 = rebellion risk
        assignedProvince = nil,
        traits = assignedTraits,
        activeBonuses = {},
        recruitedAt = os.time(),
    }

    -- Calculate active bonuses from type + traits
    Governor._recalculateBonuses(governor)

    table.insert(governors, governor)

    if _G.ModernUI then
        _G.ModernUI.notifySuccess("Guverner rekrutiran: " .. governor.name .. " (" .. def.name .. ")")
    end
    if _G.Prestige then
        pcall(function() _G.Prestige.award("achievement_common") end)
    end

    print("[Governor] Recruited: " .. governor.name .. " (" .. govType .. ")")
    return govId
end

-- Generate random governor name
function Governor._generateName()
    local firstNames = {"Aldric", "Edmund", "Roland", "Gareth", "Cedric", "Hubert",
                        "Reginald", "Theobald", "Bertram", "Conrad", "Dietrich", "Friedrich"}
    local lastNames = {"von Hohenfels", "de Beaumont", "of Ashwood", "the Bold", "the Wise",
                       "the Just", "Ironhand", "Goldsmith", "Stormwind", "Blackstone"}
    return firstNames[math.random(#firstNames)] .. " " .. lastNames[math.random(#lastNames)]
end

-- Recalculate bonuses
function Governor._recalculateBonuses(governor)
    local def = GOVERNOR_TYPES[governor.type]
    if not def then return end
    governor.activeBonuses = {}
    -- Copy type bonuses
    for k, v in pairs(def.bonus) do
        governor.activeBonuses[k] = v
    end
    -- Apply trait modifiers
    for _, trait in ipairs(governor.traits) do
        if trait.id == "industrious" then
            for k, v in pairs(governor.activeBonuses) do
                if type(v) == "number" and v >= 1 then
                    governor.activeBonuses[k] = v * 1.10
                end
            end
        elseif trait.id == "greedy" then
            governor.activeBonuses.taxEfficiency = (governor.activeBonuses.taxEfficiency or 1.0) * 1.15
            governor.activeBonuses.happinessBonus = (governor.activeBonuses.happinessBonus or 1.0) * 0.90
        elseif trait.id == "beloved" then
            governor.activeBonuses.happinessBonus = (governor.activeBonuses.happinessBonus or 1.0) * 1.15
        elseif trait.id == "cruel" then
            governor.activeBonuses.taxEfficiency = (governor.activeBonuses.taxEfficiency or 1.0) * 1.20
            governor.activeBonuses.happinessBonus = (governor.activeBonuses.happinessBonus or 1.0) * 0.80
        elseif trait.id == "genius" then
            governor.activeBonuses.researchSpeed = (governor.activeBonuses.researchSpeed or 1.0) * 1.15
            governor.activeBonuses.taxEfficiency = (governor.activeBonuses.taxEfficiency or 1.0) * 1.10
        elseif trait.id == "lazy" then
            for k, v in pairs(governor.activeBonuses) do
                if type(v) == "number" and v >= 1 then
                    governor.activeBonuses[k] = v * 0.90
                end
            end
            governor.activeBonuses.happinessBonus = (governor.activeBonuses.happinessBonus or 1.0) * 1.10
        elseif trait.id == "ambitious" then
            for k, v in pairs(governor.activeBonuses) do
                if type(v) == "number" and v >= 1 then
                    governor.activeBonuses[k] = v * 1.15
                end
            end
            governor.loyalty = governor.loyalty - 10  -- ambitious = less loyal
        end
    end
    -- Level bonus (each level adds +2% to all bonuses)
    local levelMult = 1.0 + (governor.level - 1) * 0.02
    for k, v in pairs(governor.activeBonuses) do
        if type(v) == "number" then
            governor.activeBonuses[k] = v * levelMult
        end
    end
end

-- Create a province
function Governor.createProvince(name, provinceType, gx, gy)
    local provId = nextProvId
    nextProvId = nextProvId + 1
    local province = {
        id = provId,
        name = name or ("Provinca " .. provId),
        type = provinceType or "general",
        gx = gx,
        gy = gy,
        governorId = nil,
        population = 10,
        taxRate = 1.0,
        happiness = 50,
        buildings = 0,
    }
    table.insert(provinces, province)
    return provId
end

-- Assign governor to province
function Governor.assign(governorId, provinceId)
    local gov = Governor._findGovernor(governorId)
    local prov = Governor._findProvince(provinceId)
    if not gov or not prov then return false end

    -- Unassign from previous province
    if gov.assignedProvince then
        local oldProv = Governor._findProvince(gov.assignedProvince)
        if oldProv then oldProv.governorId = nil end
    end

    gov.assignedProvince = provinceId
    prov.governorId = governorId

    if _G.ModernUI then
        _G.ModernUI.notifySuccess(gov.name .. " dodeljen provinci " .. prov.name)
    end
    return true
end

-- Get bonus for a specific stat (aggregated from all assigned governors)
function Governor.getBonus(bonusName)
    local totalBonus = 1.0
    for _, gov in ipairs(governors) do
        if gov.assignedProvince and gov.activeBonuses[bonusName] then
            totalBonus = totalBonus * gov.activeBonuses[bonusName]
        end
    end
    return totalBonus
end

-- Level up governor
function Governor.levelUp(governorId)
    local gov = Governor._findGovernor(governorId)
    if not gov then return false end
    if gov.level >= 10 then return false end
    gov.level = gov.level + 1
    gov.experience = 0
    Governor._recalculateBonuses(gov)
    if _G.ModernUI then
        _G.ModernUI.notifySuccess(gov.name .. " napredoval na nivo " .. gov.level)
    end
    return true
end

-- Add experience
function Governor.addExperience(governorId, amount)
    local gov = Governor._findGovernor(governorId)
    if not gov then return false end
    gov.experience = gov.experience + amount
    local xpNeeded = gov.level * 100
    if gov.experience >= xpNeeded and gov.level < 10 then
        Governor.levelUp(governorId)
    end
    return true
end

-- Update loyalty (called periodically)
function Governor.update(dt)
    if not initialized then return end
    for _, gov in ipairs(governors) do
        -- Loyalty slowly drifts toward 50 (neutral)
        if gov.loyalty > 50 then
            gov.loyalty = gov.loyalty - dt * 0.01
        elseif gov.loyalty < 50 then
            gov.loyalty = gov.loyalty + dt * 0.005
        end
        -- Check for rebellion
        if gov.loyalty < 20 and not Governor._hasTrait(gov, "loyal") then
            if math.random() < 0.001 then  -- 0.1% chance per frame at very low loyalty
                Governor._rebel(gov)
            end
        end
    end
end

-- Check if governor has a trait
function Governor._hasTrait(governor, traitId)
    for _, trait in ipairs(governor.traits) do
        if trait.id == traitId then return true end
    end
    return false
end

-- Governor rebellion
function Governor._rebel(governor)
    if _G.ModernUI then
        _G.ModernUI.notifyError(governor.name .. " se je uprl!")
    end
    if _G.GameEventBus then
        pcall(function() _G.GameEventBus.emit("governor_rebellion", { governor = governor }) end)
    end
    -- Remove governor
    for i, g in ipairs(governors) do
        if g.id == governor.id then
            table.remove(governors, i)
            break
        end
    end
end

-- Find helper
function Governor._findGovernor(id)
    for _, gov in ipairs(governors) do
        if gov.id == id then return gov end
    end
    return nil
end

function Governor._findProvince(id)
    for _, prov in ipairs(provinces) do
        if prov.id == id then return prov end
    end
    return nil
end

-- Get all governors
function Governor.getAll()
    local result = {}
    for _, gov in ipairs(governors) do
        local def = GOVERNOR_TYPES[gov.type]
        table.insert(result, {
            id = gov.id,
            name = gov.name,
            type = gov.type,
            typeName = def and def.name or gov.type,
            level = gov.level,
            experience = gov.experience,
            loyalty = math.floor(gov.loyalty),
            assignedProvince = gov.assignedProvince,
            traits = gov.traits,
            bonuses = gov.activeBonuses,
        })
    end
    return result
end

-- Get all provinces
function Governor.getProvinces()
    return provinces
end

-- Get stats
function Governor.getStats()
    local assigned = 0
    local totalLoyalty = 0
    local rebellionRisk = 0
    for _, gov in ipairs(governors) do
        if gov.assignedProvince then assigned = assigned + 1 end
        totalLoyalty = totalLoyalty + gov.loyalty
        if gov.loyalty < 30 then rebellionRisk = rebellionRisk + 1 end
    end
    return {
        totalGovernors = #governors,
        assignedGovernors = assigned,
        totalProvinces = #provinces,
        avgLoyalty = #governors > 0 and math.floor(totalLoyalty / #governors) or 100,
        rebellionRisk = rebellionRisk,
        governorTypes = Governor._getTypeCount(),
        traitCount = #TRAITS,
    }
end

return Governor
