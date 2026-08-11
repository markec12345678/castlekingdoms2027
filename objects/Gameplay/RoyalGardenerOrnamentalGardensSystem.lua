-- objects/Gameplay/RoyalGardenerOrnamentalGardensSystem.lua
-- Castle Kingdoms 2027 v3.4.0 - Royal Gardener & Ornamental Gardens System
--
-- Manages ornamental gardens, gardeners, and botanical collections.
-- Gardens provide happiness, prestige, and medicinal herbs.
--
-- Features:
-- - 6 garden types (rose garden, herb garden, knot garden, water garden, topiary, botanical)
-- - 8 plant types (roses, lilies, tulips, lavender, boxwood, fountains, statues, hedges)
-- - Gardener NPC (skill affects garden quality)
-- - Seasonal blooming (different plants in different seasons)
-- - Garden tours (visitors bring prestige and gold)
-- - Botanical collection (rare plants from exploration)
-- - Garden competitions
-- - Meditation bonus (happiness from peaceful gardens)

local Gardens = {}

-- ============================================================
-- GARDEN TYPES
-- ============================================================
local GARDEN_TYPES = {
    rose_garden = {
        name = "Vrt vrtnic",
        nameEn = "Rose Garden",
        cost = 500,
        upkeep = 15,
        happinessBonus = 8,
        prestigeBonus = 5,
        bloomSeason = "summer",
        description = "Klasični vrt vrtnic z različnimi sortami.",
    },
    herb_garden = {
        name = "Zeliščni vrt",
        nameEn = "Herb Garden",
        cost = 300,
        upkeep = 8,
        happinessBonus = 4,
        prestigeBonus = 2,
        herbProduction = true,
        description = "Vrt z zdravilnimi in aromatičnimi zelišči.",
    },
    knot_garden = {
        name = "Vozliščni vrt",
        nameEn = "Knot Garden",
        cost = 800,
        upkeep = 25,
        happinessBonus = 10,
        prestigeBonus = 12,
        bloomSeason = "spring",
        description = "Geometrijski vrt z okrasnimi vzorci.",
    },
    water_garden = {
        name = "Vodni vrt",
        nameEn = "Water Garden",
        cost = 1500,
        upkeep = 40,
        happinessBonus = 15,
        prestigeBonus = 15,
        description = "Vrt z ribniki, fontanami in vodnim rastlinjem.",
    },
    topiary = {
        name = "Topiarij",
        nameEn = "Topiary Garden",
        cost = 1200,
        upkeep = 35,
        happinessBonus = 12,
        prestigeBonus = 18,
        description = "Vrt z oblikovanimi grmi in drevesi.",
    },
    botanical = {
        name = "Botanični vrt",
        nameEn = "Botanical Garden",
        cost = 3000,
        upkeep = 80,
        happinessBonus = 20,
        prestigeBonus = 25,
        researchBonus = 10,
        description = "Znanstveni vrt z eksotičnimi rastlinami.",
    },
}

-- ============================================================
-- PLANT/DECORATION TYPES
-- ============================================================
local PLANTS = {
    roses = {
        name = "Vrtnice",
        cost = 50,
        beautyBonus = 8,
        bloomSeason = "summer",
        description = "Kraljevske vrtnice.",
    },
    lilies = {
        name = "Lilije",
        cost = 40,
        beautyBonus = 6,
        bloomSeason = "summer",
        description = "Elegantne lilije.",
    },
    tulips = {
        name = "Tulipani",
        cost = 30,
        beautyBonus = 5,
        bloomSeason = "spring",
        description = "Barviti tulipani.",
    },
    lavender = {
        name = "Sivka",
        cost = 25,
        beautyBonus = 4,
        aromaBonus = 5,
        bloomSeason = "summer",
        description = "Dišeča sivka.",
    },
    boxwood = {
        name = "Bukvica",
        cost = 60,
        beautyBonus = 3,
        structureBonus = 10,
        description = "Za oblikovanje in žive meje.",
    },
    fountain = {
        name = "Fontana",
        cost = 300,
        beautyBonus = 15,
        soundBonus = 8,
        description = "Vodna fontana za sprostitev.",
    },
    statue = {
        name = "Kip",
        cost = 500,
        beautyBonus = 20,
        prestigeBonus = 10,
        description = "Marmorni kip za okras.",
    },
    hedge = {
        name = "Živa meja",
        cost = 80,
        beautyBonus = 2,
        structureBonus = 15,
        description = "Zelena živa meja za strukturo.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Gardens.gardens = {}                      -- Built gardens
Gardens.plants = {}                       -- Planted items
Gardens.gardener = nil                    -- Hired gardener NPC
Gardens.activeTours = {}                  -- Garden tours
Gardens.botanicalCollection = {}          -- Rare plants
Gardens.totalGardensBuilt = 0
Gardens.totalToursHosted = 0
Gardens.totalCompetitionsWon = 0
Gardens.dayTimer = 0
Gardens.currentSeason = "spring"

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Gardens.init()
    Gardens.gardens = {}
    Gardens.plants = {}
    Gardens.gardener = nil
    Gardens.activeTours = {}
    Gardens.botanicalCollection = {}
    Gardens.totalGardensBuilt = 0
    Gardens.totalToursHosted = 0
    Gardens.totalCompetitionsWon = 0
    Gardens.dayTimer = 0
    Gardens.currentSeason = "spring"
    print("[Gardens] Royal Gardener & Ornamental Gardens System initialized (6 gardens, 8 plants)")
end

-- ============================================================
-- GARDENER NPC
-- ============================================================
function Gardens.hireGardener(name, skill)
    skill = skill or math.random(40, 85)
    local cost = 300 + skill * 6
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    Gardens.gardener = {
        name = name or ("Vrtnar " .. math.random(1, 99)),
        skill = skill,
        hiredDay = os.time(),
        gardensMaintained = 0,
    }
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Vrtnar najet: %s (spretnost: %d)", Gardens.gardener.name, skill), "success")
    end
    return true
end

-- ============================================================
-- GARDEN CONSTRUCTION
-- ============================================================
function Gardens.canBuild(gardenType)
    local def = GARDEN_TYPES[gardenType]
    if not def then return false, "Neznan vrt" end
    if not _G.state or (_G.state.gold or 0) < def.cost then
        return false, "Premalo zlata"
    end
    return true
end

function Gardens.buildGarden(gardenType)
    local ok, err = Gardens.canBuild(gardenType)
    if not ok then return false, err end
    local def = GARDEN_TYPES[gardenType]
    _G.state.gold = _G.state.gold - def.cost
    local garden = {
        id = "garden_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        type = gardenType,
        name = def.name,
        health = 100,
        beauty = 50,  -- will improve with plants
        plantedItems = {},
        builtDay = os.time(),
    }
    table.insert(Gardens.gardens, garden)
    Gardens.totalGardensBuilt = Gardens.totalGardensBuilt + 1
    -- Apply immediate happiness
    if _G.state and _G.state.happiness and def.happinessBonus then
        _G.state.happiness = math.min(100, _G.state.happiness + def.happinessBonus)
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Vrt postavljen: " .. def.name, "success")
    end
    return true, garden.id
end

function Gardens.findGarden(gardenId)
    for _, g in ipairs(Gardens.gardens) do
        if g.id == gardenId then return g end
    end
    return nil
end

-- ============================================================
-- PLANTING
-- ============================================================
function Gardens.canPlant(gardenId, plantType)
    local garden = Gardens.findGarden(gardenId)
    if not garden then return false, "Vrt ne obstaja" end
    local def = PLANTS[plantType]
    if not def then return false, "Neznana rastlina" end
    if not _G.state or (_G.state.gold or 0) < def.cost then
        return false, "Premalo zlata"
    end
    return true
end

function Gardens.plantItem(gardenId, plantType)
    local ok, err = Gardens.canPlant(gardenId, plantType)
    if not ok then return false, err end
    local garden = Gardens.findGarden(gardenId)
    local def = PLANTS[plantType]
    _G.state.gold = _G.state.gold - def.cost
    table.insert(garden.plantedItems, {
        type = plantType,
        name = def.name,
        beautyBonus = def.beautyBonus,
        bloomSeason = def.bloomSeason,
        plantedDay = os.time(),
    })
    -- Improve garden beauty
    garden.beauty = math.min(100, garden.beauty + def.beautyBonus)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Posajeno: %s v %s", def.name, garden.name), "info")
    end
    return true
end

-- ============================================================
-- GARDEN TOURS
-- ============================================================
function Gardens.canOrganizeTour()
    if #Gardens.gardens == 0 then return false, "Ni vrtov za obisk" end
    if not _G.state or (_G.state.gold or 0) < 100 then
        return false, "Premalo zlata za pripravo"
    end
    return true
end

function Gardens.organizeTour()
    local ok, err = Gardens.canOrganizeTour()
    if not ok then return false, err end
    _G.state.gold = _G.state.gold - 100
    -- Calculate total beauty
    local totalBeauty = 0
    for _, g in ipairs(Gardens.gardens) do
        totalBeauty = totalBeauty + g.beauty
    end
    local tour = {
        id = "tour_" .. tostring(os.time()),
        daysRemaining = 3,
        totalBeauty = totalBeauty,
        expectedVisitors = math.floor(totalBeauty / 10),
        started = os.time(),
    }
    table.insert(Gardens.activeTours, tour)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Vodenje po vrtovih organizirano! %d obiskovalcev pričakovanih",
                tour.expectedVisitors), "info")
    end
    return true
end

function Gardens.completeTour(tour)
    -- Revenue from visitors
    local revenue = tour.expectedVisitors * 10
    if _G.state then
        _G.state.gold = (_G.state.gold or 0) + revenue
    end
    -- Happiness boost
    if _G.state and _G.state.happiness then
        _G.state.happiness = math.min(100, _G.state.happiness + 5)
    end
    Gardens.totalToursHosted = Gardens.totalToursHosted + 1
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Vodenje končano! +%d zlata, +%d sreče", revenue, 5), "success")
    end
end

-- ============================================================
-- BOTANICAL COLLECTION
-- ============================================================
function Gardens.addToCollection(plantName, rarity)
    table.insert(Gardens.botanicalCollection, {
        name = plantName,
        rarity = rarity or 1,
        acquiredDay = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Redka rastlina dodana v zbirko: %s!", plantName), "rare")
    end
end

function Gardens.discoverPlant()
    -- Random chance to discover a new plant
    if math.random() < 0.05 then
        local plantNames = {
            "Zmajevec", "Pticecvec", "Srebrni papir", "Zlata dišečnica",
            "Kraljevska orhideja", "Črni tulipan", "Modra vrtnica",
        }
        local name = plantNames[math.random(#plantNames)]
        local rarity = math.random(2, 5)
        Gardens.addToCollection(name, rarity)
        -- Prestige bonus
        if _G.state and _G.state.happiness then
            _G.state.happiness = math.min(100, _G.state.happiness + rarity)
        end
    end
end

-- ============================================================
-- COMPETITIONS
-- ============================================================
function Gardens.enterCompetition(gardenId)
    local garden = Gardens.findGarden(gardenId)
    if not garden then return false, "Vrt ne obstaja" end
    if garden.beauty < 60 then return false, "Vrt ni dovolj lep" end
    if not _G.state or (_G.state.gold or 0) < 500 then
        return false, "Premalo zlata za vstopnino"
    end
    _G.state.gold = _G.state.gold - 500
    -- Win chance based on beauty
    local winChance = garden.beauty / 150
    if Gardens.gardener then
        winChance = winChance + (Gardens.gardener.skill / 200)
    end
    winChance = math.min(0.85, winChance)
    if math.random() < winChance then
        local prize = math.random(1000, 3000)
        if _G.state then
            _G.state.gold = (_G.state.gold or 0) + prize
        end
        Gardens.totalCompetitionsWon = Gardens.totalCompetitionsWon + 1
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                string.format("ZMAGA na vrtnarskem tekmovanju! %s (+%d zlata)",
                    garden.name, prize), "success")
        end
    else
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                string.format("Poraz na tekmovanju: %s", garden.name), "info")
        end
    end
    return true
end

-- ============================================================
-- UPDATE
-- ============================================================
function Gardens.update(dt)
    if not _G.state then return end
    Gardens.dayTimer = Gardens.dayTimer + dt
    if Gardens.dayTimer >= 30 then
        Gardens.dayTimer = 0
        -- Update season
        if _G.SeasonalSystem and _G.SeasonalSystem.getCurrentSeason then
            Gardens.currentSeason = _G.SeasonalSystem.getCurrentSeason() or "spring"
        end
        -- Garden maintenance
        local gardenerSkill = Gardens.gardener and Gardens.gardener.skill or 30
        for _, g in ipairs(Gardens.gardens) do
            -- Health slowly decreases without maintenance
            local healthChange = (gardenerSkill / 100) - 0.5
            g.health = math.max(0, math.min(100, g.health + healthChange))
            -- Blooming bonus
            local def = GARDEN_TYPES[g.type]
            if def and def.bloomSeason == Gardens.currentSeason then
                g.beauty = math.min(100, g.beauty + 1)
            end
        end
        -- Random plant discovery
        if #Gardens.gardens > 0 then
            Gardens.discoverPlant()
        end
        -- Process tours
        for i = #Gardens.activeTours, 1, -1 do
            local t = Gardens.activeTours[i]
            t.daysRemaining = t.daysRemaining - 1
            if t.daysRemaining <= 0 then
                Gardens.completeTour(t)
                table.remove(Gardens.activeTours, i)
            end
        end
        -- Pay upkeep
        local totalUpkeep = 0
        for _, g in ipairs(Gardens.gardens) do
            local def = GARDEN_TYPES[g.type]
            if def and g.health > 50 then totalUpkeep = totalUpkeep + def.upkeep end
        end
        if Gardens.gardener then totalUpkeep = totalUpkeep + 20 end
        if totalUpkeep > 0 and _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep)
        end
        -- Gardener skill progression
        if Gardens.gardener and math.random() < 0.10 then
            Gardens.gardener.skill = math.min(100, Gardens.gardener.skill + 1)
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Gardens.getGardenTypeInfo(typeId) return GARDEN_TYPES[typeId] end
function Gardens.getPlantInfo(plantId) return PLANTS[plantId] end

function Gardens.getActiveBonuses()
    local bonuses = {
        happinessBonus = 0,
        prestigeBonus = 0,
        researchBonus = 0,
    }
    for _, g in ipairs(Gardens.gardens) do
        if g.health > 50 then
            local def = GARDEN_TYPES[g.type]
            if def then
                bonuses.happinessBonus = bonuses.happinessBonus + (def.happinessBonus or 0)
                bonuses.prestigeBonus = bonuses.prestigeBonus + (def.prestigeBonus or 0)
                bonuses.researchBonus = bonuses.researchBonus + (def.researchBonus or 0)
            end
        end
    end
    return bonuses
end

function Gardens.getStats()
    return {
        numGardens = #Gardens.gardens,
        hasGardener = Gardens.gardener ~= nil,
        gardenerName = Gardens.gardener and Gardens.gardener.name or "—",
        gardenerSkill = Gardens.gardener and Gardens.gardener.skill or 0,
        activeTours = #Gardens.activeTours,
        botanicalCollection = #Gardens.botanicalCollection,
        totalGardensBuilt = Gardens.totalGardensBuilt,
        totalToursHosted = Gardens.totalToursHosted,
        totalCompetitionsWon = Gardens.totalCompetitionsWon,
        currentSeason = Gardens.currentSeason,
    }
end

return Gardens
