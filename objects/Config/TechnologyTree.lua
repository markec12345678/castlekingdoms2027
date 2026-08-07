-- objects/Config/TechnologyTree.lua
-- Castle Kingdoms 2027 v2.6.4 - Technology Tree System
--
-- Research technologies to unlock new units, buildings, and bonuses.
-- Technologies require gold and research time to unlock.
--
-- Tech categories:
-- - Military: unlock new units, improve combat stats
-- - Economy: improve production, reduce costs
-- - Defense: improve walls, towers, fortifications
-- - Civil: improve population, popularity, food

local TechnologyTree = {}

-- Technology definitions
local TECHNOLOGIES = {
    -- Military technologies
    military_archery = {
        name = "Izboljšana lokostrelstvo",
        nameEn = "Advanced Archery",
        category = "military",
        cost = { gold = 500 },
        researchTime = 60,  -- seconds
        description = "Lokostrelci dobi +20% damage in +1 range",
        effects = { unitBonus = { Archer = { damage = 1.2, range = 1 }, Longbowman = { damage = 1.2, range = 1 } } },
        requires = {},
    },
    military_steel = {
        name = "Jekleno orožje",
        nameEn = "Steel Weapons",
        category = "military",
        cost = { gold = 800 },
        researchTime = 90,
        description = "Vsi melee enote dobi +15% damage",
        effects = { unitBonus = { Swordsman = { damage = 1.15 }, Knight = { damage = 1.15 }, NormanKnight = { damage = 1.15 }, Huscarl = { damage = 1.15 } } },
        requires = {},
    },
    military_cavalry = {
        name = "Konjeniška šola",
        nameEn = "Cavalry School",
        category = "military",
        cost = { gold = 1200 },
        researchTime = 120,
        description = "Vsi vitezi dobi +25% hitrosti in +10% HP",
        effects = { unitBonus = { Knight = { speed = 1.25, health = 1.10 }, NormanKnight = { speed = 1.25, health = 1.10 } } },
        requires = { "military_steel" },
    },
    military_siege = {
        name = "Oblegovalna tehnologija",
        nameEn = "Siege Technology",
        category = "military",
        cost = { gold = 1500 },
        researchTime = 150,
        description = "Oblegovalna orožja dobi +30% damage in -20% cost",
        effects = { siegeBonus = { damage = 1.3, cost = 0.8 } },
        requires = { "military_steel" },
    },

    -- Economy technologies
    economy_agriculture = {
        name = "Napredno kmetijstvo",
        nameEn = "Advanced Agriculture",
        category = "economy",
        cost = { gold = 400 },
        researchTime = 60,
        description = "Kmetije proizvajajo +25% hrane",
        effects = { productionBonus = { food = 1.25 } },
        requires = {},
    },
    economy_mining = {
        name = "Izboljšano rudarstvo",
        nameEn = "Improved Mining",
        category = "economy",
        cost = { gold = 600 },
        researchTime = 75,
        description = "Kamnolomi in rudniki železa +30% produkcije",
        effects = { productionBonus = { stone = 1.30, iron = 1.30 } },
        requires = {},
    },
    economy_trade = {
        name = "Trgovski dodatki",
        nameEn = "Trade Routes",
        category = "economy",
        cost = { gold = 1000 },
        researchTime = 100,
        description = "Tržnice +20% profit, karavane +25% reward",
        effects = { tradeBonus = { marketProfit = 1.2, caravanReward = 1.25 } },
        requires = { "economy_trade_routes" },
    },
    economy_trade_routes = {
        name = "Trgovske poti",
        nameEn = "Trade Routes",
        category = "economy",
        cost = { gold = 700 },
        researchTime = 80,
        description = "Odklene trgovske karavane z AI frakcijami",
        effects = { unlockCaravans = true },
        requires = {},
    },

    -- Defense technologies
    defense_walls = {
        name = "Okrepitveni zidovi",
        nameEn = "Reinforced Walls",
        category = "defense",
        cost = { gold = 500 },
        researchTime = 70,
        description = "Kamniti zidovi dobi +50% HP",
        effects = { buildingBonus = { StoneWall = { health = 1.5 } } },
        requires = {},
    },
    defense_towers = {
        name = "Stolp izboljšave",
        nameEn = "Tower Improvements",
        category = "defense",
        cost = { gold = 800 },
        researchTime = 90,
        description = "Obrambni stolpi dobi +2 range in +25% damage",
        effects = { buildingBonus = { SquareTower = { range = 2, damage = 1.25 }, RoundTower = { range = 2, damage = 1.25 } } },
        requires = { "defense_walls" },
    },
    defense_gates = {
        name = "Oklepna vrata",
        nameEn = "Armored Gates",
        category = "defense",
        cost = { gold = 600 },
        researchTime = 60,
        description = "Kamnita vrata dobi +100% HP",
        effects = { buildingBonus = { StoneGateSouth = { health = 2.0 }, StoneGateEast = { health = 2.0 } } },
        requires = { "defense_walls" },
    },

    -- Civil technologies
    civil_housing = {
        name = "Napredna stanovanja",
        nameEn = "Advanced Housing",
        category = "civil",
        cost = { gold = 400 },
        researchTime = 50,
        description = "Vse hiše +2 kapaciteta populacije",
        effects = { buildingBonus = { Hovel = { capacity = 2 }, Flat = { capacity = 2 }, Residence = { capacity = 2 } } },
        requires = {},
    },
    civil_religion = {
        name = "Verske institucije",
        nameEn = "Religious Institutions",
        category = "civil",
        cost = { gold = 700 },
        researchTime = 80,
        description = "Kapele in cerkve +50% popularnost bonus",
        effects = { buildingBonus = { Chapel = { popularityBonus = 1.5 }, Church = { popularityBonus = 1.5 } } },
        requires = {},
    },
    civil_education = {
        name = "Izobraževanje",
        nameEn = "Education",
        category = "civil",
        cost = { gold = 1000 },
        researchTime = 120,
        description = "Enote začnejo z +1 veterancy level",
        effects = { unitBonus = { all = { startLevel = 2 } } },
        requires = { "civil_housing" },
    },
}

TechnologyTree.TECHNOLOGIES = TECHNOLOGIES

local initialized = false
local researchedTechs = {}  -- set of tech IDs
local currentResearch = nil  -- { id, progress, time }
local researchQueue = {}

function TechnologyTree.init()
    if initialized then return end
    initialized = true
    print("[TechnologyTree] Initialized with " .. TechnologyTree._getTechCount() .. " technologies")
end

function TechnologyTree._getTechCount()
    local count = 0
    for _ in pairs(TECHNOLOGIES) do count = count + 1 end
    return count
end

-- Check if a technology is researched
function TechnologyTree.isResearched(techId)
    return researchedTechs[techId] == true
end

-- Check if a technology can be researched (requirements met)
function TechnologyTree.canResearch(techId)
    local tech = TECHNOLOGIES[techId]
    if not tech then return false, "Unknown technology" end
    if TechnologyTree.isResearched(techId) then return false, "Already researched" end
    if currentResearch then return false, "Already researching" end
    -- Check requirements
    for _, req in ipairs(tech.requires or {}) do
        if not TechnologyTree.isResearched(req) then
            return false, "Requires: " .. req
        end
    end
    -- Check cost
    if _G.state and tech.cost then
        local gold = _G.state.gold or 0
        if tech.cost.gold and gold < tech.cost.gold then
            return false, "Not enough gold (" .. gold .. "/" .. tech.cost.gold .. ")"
        end
    end
    return true
end

-- Start researching a technology
function TechnologyTree.startResearch(techId)
    local canResearch, reason = TechnologyTree.canResearch(techId)
    if not canResearch then
        print("[TechnologyTree] Cannot research: " .. tostring(reason))
        return false
    end

    local tech = TECHNOLOGIES[techId]
    -- Deduct cost
    if _G.state and tech.cost and tech.cost.gold then
        _G.state.gold = (_G.state.gold or 0) - tech.cost.gold
    end

    currentResearch = {
        id = techId,
        progress = 0,
        time = tech.researchTime,
    }

    print("[TechnologyTree] Started research: " .. tech.name)
    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Raziskovanje: " .. tech.name .. " (" .. tech.researchTime .. "s)")
    end
    return true
end

-- Update research progress
function TechnologyTree.update(dt)
    if not initialized then return end
    if not currentResearch then return end

    currentResearch.progress = currentResearch.progress + dt
    if currentResearch.progress >= currentResearch.time then
        TechnologyTree._completeResearch()
    end
end

-- Complete current research
function TechnologyTree._completeResearch()
    local techId = currentResearch.id
    local tech = TECHNOLOGIES[techId]
    researchedTechs[techId] = true
    currentResearch = nil

    print("[TechnologyTree] Research complete: " .. tech.name)
    if _G.ModernUI then
        _G.ModernUI.notifySuccess("Raziskano: " .. tech.name .. "!")
    end

    -- Apply effects
    TechnologyTree._applyEffects(tech)

    -- Fire event
    if _G.GameEventBus then
        pcall(function() _G.GameEventBus.emit("technology_researched", { id = techId, tech = tech }) end)
    end

    -- Start next in queue
    if #researchQueue > 0 then
        local next = table.remove(researchQueue, 1)
        TechnologyTree.startResearch(next)
    end
end

-- Apply technology effects
function TechnologyTree._applyEffects(tech)
    -- Effects are queried via getUnitBonus, getBuildingBonus, etc.
    -- No immediate application needed — systems check bonuses dynamically
    print("[TechnologyTree] Applied effects for: " .. tech.name)
end

-- Get unit bonus from researched techs
function TechnologyTree.getUnitBonus(unitType, stat)
    local bonus = 1.0
    for techId, _ in pairs(researchedTechs) do
        local tech = TECHNOLOGIES[techId]
        if tech and tech.effects and tech.effects.unitBonus then
            local unitBonus = tech.effects.unitBonus[unitType] or tech.effects.unitBonus.all
            if unitBonus and unitBonus[stat] then
                bonus = bonus * unitBonus[stat]
            end
        end
    end
    return bonus
end

-- Get building bonus from researched techs
function TechnologyTree.getBuildingBonus(buildingType, stat)
    local bonus = 1.0
    for techId, _ in pairs(researchedTechs) do
        local tech = TECHNOLOGIES[techId]
        if tech and tech.effects and tech.effects.buildingBonus then
            local bBonus = tech.effects.buildingBonus[buildingType]
            if bBonus and bBonus[stat] then
                bonus = bonus * bBonus[stat]
            end
        end
    end
    return bonus
end

-- Get production bonus
function TechnologyTree.getProductionBonus(resource)
    local bonus = 1.0
    for techId, _ in pairs(researchedTechs) do
        local tech = TECHNOLOGIES[techId]
        if tech and tech.effects and tech.effects.productionBonus then
            if tech.effects.productionBonus[resource] then
                bonus = bonus * tech.effects.productionBonus[resource]
            end
        end
    end
    return bonus
end

-- Get current research progress
function TechnologyTree.getCurrentResearch()
    if not currentResearch then return nil end
    return {
        id = currentResearch.id,
        name = TECHNOLOGIES[currentResearch.id].name,
        progress = currentResearch.progress,
        time = currentResearch.time,
        percent = (currentResearch.progress / currentResearch.time) * 100,
    }
end

-- Get all researched techs
function TechnologyTree.getResearchedTechs()
    local list = {}
    for techId, _ in pairs(researchedTechs) do
        table.insert(list, techId)
    end
    return list
end

-- Get all available technologies with status
function TechnologyTree.getAllTechs()
    local result = {}
    for techId, tech in pairs(TECHNOLOGIES) do
        local canResearch, reason = TechnologyTree.canResearch(techId)
        table.insert(result, {
            id = techId,
            name = tech.name,
            nameEn = tech.nameEn,
            category = tech.category,
            cost = tech.cost,
            researchTime = tech.researchTime,
            description = tech.description,
            requires = tech.requires,
            researched = TechnologyTree.isResearched(techId),
            canResearch = canResearch,
            reason = reason,
        })
    end
    return result
end

-- Get stats
function TechnologyTree.getStats()
    local researched = 0
    for _ in pairs(researchedTechs) do researched = researched + 1 end
    return {
        totalTechs = TechnologyTree._getTechCount(),
        researched = researched,
        currentlyResearching = currentResearch ~= nil,
    }
end

return TechnologyTree
