-- objects/Economy/RoyalBeekeeperHoneySystem.lua
-- Castle Kingdoms 2027 v3.3.7 - Royal Beekeeper & Honey System
--
-- Manages beekeeping, honey production, beeswax, and mead brewing.
-- Bees provide honey (food/luxury), wax (candles, seals), and pollination bonuses.
--
-- Features:
-- - 6 hive types (log hive, skep, box hive, frame hive, royal hive, apiary)
-- - 4 products (honey, beeswax, propolis, royal jelly)
-- - Beekeeper NPC (skill affects yield)
-- - Seasonal production (more in spring/summer)
-- - Mead brewing (from honey)
-- - Wax candles (light + faith bonus)
-- - Pollination bonus (increases crop yield)
-- - Swarm events (bees multiply or abscond)
-- - Disease management

local Beekeeper = {}

-- ============================================================
-- HIVE TYPES
-- ============================================================
local HIVES = {
    log_hive = {
        name = "Brosten panj",
        nameEn = "Log Hive",
        cost = 50,
        upkeep = 1,
        capacity = 1,
        productionBonus = 0.5,
        description = "Preprost panj iz debla.",
    },
    skep = {
        name = "Slamnati panj",
        nameEn = "Skep",
        cost = 80,
        upkeep = 2,
        capacity = 1,
        productionBonus = 0.8,
        description = "Tradicionalni slamnati panj.",
    },
    box_hive = {
        name = "Škatlasti panj",
        nameEn = "Box Hive",
        cost = 150,
        upkeep = 3,
        capacity = 2,
        productionBonus = 1.0,
        description = "Leseni panj z okvirji.",
    },
    frame_hive = {
        name = "Okvirni panj",
        nameEn = "Frame Hive",
        cost = 300,
        upkeep = 5,
        capacity = 3,
        productionBonus = 1.5,
        description = "Napreden panj z premičnimi okvirji.",
    },
    royal_hive = {
        name = "Kraljevski panj",
        nameEn = "Royal Hive",
        cost = 800,
        upkeep = 12,
        capacity = 5,
        productionBonus = 2.5,
        prestigeBonus = 5,
        description = "Veliki kraljevski panj z najboljšo proizvodnjo.",
    },
    apiary = {
        name = "Apiarij",
        nameEn = "Apiary",
        cost = 2000,
        upkeep = 30,
        capacity = 20,
        productionBonus = 2.0,
        prestigeBonus = 10,
        description = "Velika čebelnjak z mnogimi panji.",
    },
}

-- ============================================================
-- PRODUCTS
-- ============================================================
local PRODUCTS = {
    honey = {
        name = "Med",
        nameEn = "Honey",
        value = 20,
        foodValue = 5,
        luxuryValue = 8,
        description = "Sladka hrana in luksuz.",
    },
    beeswax = {
        name = "Čebelji vosek",
        nameEn = "Beeswax",
        value = 30,
        candleValue = 10,
        sealValue = 15,
        description = "Za sveče, pečate in kiparstvo.",
    },
    propolis = {
        name = "Propolis",
        nameEn = "Propolis",
        value = 50,
        medicineValue = 20,
        description = "Zdravilna čebelja smola.",
    },
    royal_jelly = {
        name = "Matični mleček",
        nameEn = "Royal Jelly",
        value = 200,
        rarity = 5,
        description = "Redka super-hrana za kraljico.",
    },
}

-- ============================================================
-- MEAD TYPES
-- ============================================================
local MEADS = {
    basic_mead = {
        name = "Navadni medovec",
        nameEn = "Basic Mead",
        honeyRequired = 5,
        brewTime = 14,
        value = 100,
        happinessBonus = 3,
        description = "Preprost medovec.",
    },
    spiced_mead = {
        name = "Začinjeni medovec",
        nameEn = "Spiced Mead",
        honeyRequired = 8,
        brewTime = 21,
        value = 200,
        happinessBonus = 6,
        description = "Medovec z začimbami.",
    },
    royal_mead = {
        name = "Kraljevski medovec",
        nameEn = "Royal Mead",
        honeyRequired = 15,
        brewTime = 60,
        value = 600,
        happinessBonus = 12,
        prestigeBonus = 5,
        description = "Najboljši medovec za dvor.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Beekeeper.hives = {}                      -- Built hives
Beekeeper.productStockpile = {}           -- Stored products
Beekeeper.meadStockpile = {}              -- Stored mead
Beekeeper.activeBrewing = {}              -- Mead being brewed
Beekeeper.beekeeper = nil                 -- Hired beekeeper NPC
Beekeeper.totalHoneyProduced = 0
Beekeeper.totalWaxProduced = 0
Beekeeper.totalMeadBrewed = 0
Beekeeper.dayTimer = 0
Beekeeper.seasonalMultiplier = 1.0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Beekeeper.init()
    Beekeeper.hives = {}
    Beekeeper.productStockpile = {}
    Beekeeper.meadStockpile = {}
    Beekeeper.activeBrewing = {}
    Beekeeper.beekeeper = nil
    Beekeeper.totalHoneyProduced = 0
    Beekeeper.totalWaxProduced = 0
    Beekeeper.totalMeadBrewed = 0
    Beekeeper.dayTimer = 0
    Beekeeper.seasonalMultiplier = 1.0
    print("[Beekeeper] Royal Beekeeper & Honey System initialized (6 hives, 4 products, 3 meads)")
end

-- ============================================================
-- BEEKEEPER NPC
-- ============================================================
function Beekeeper.hireBeekeeper(name, skill)
    skill = skill or math.random(40, 80)
    local cost = 200 + skill * 5
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    Beekeeper.beekeeper = {
        name = name or ("Čebelar " .. math.random(1, 99)),
        skill = skill,
        hiredDay = os.time(),
    }
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Čebelar najet: %s (spretnost: %d)", Beekeeper.beekeeper.name, skill), "success")
    end
    return true
end

-- ============================================================
-- HIVE CONSTRUCTION
-- ============================================================
function Beekeeper.canBuild(hiveType)
    local def = HIVES[hiveType]
    if not def then return false, "Neznan panj" end
    if not _G.state or (_G.state.gold or 0) < def.cost then
        return false, "Premalo zlata"
    end
    if _G.state.resources and (_G.state.resources.wood or 0) < math.floor(def.cost / 10) then
        return false, "Premalo lesa"
    end
    return true
end

function Beekeeper.buildHive(hiveType)
    local ok, err = Beekeeper.canBuild(hiveType)
    if not ok then return false, err end
    local def = HIVES[hiveType]
    _G.state.gold = _G.state.gold - def.cost
    if _G.state.resources then
        _G.state.resources.wood = (_G.state.resources.wood or 0) - math.floor(def.cost / 10)
    end
    table.insert(Beekeeper.hives, {
        id = "hive_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        type = hiveType,
        health = 100,
        population = 50,  -- bee count (in thousands)
        builtDay = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Panj postavljen: " .. def.name, "success")
    end
    return true
end

function Beekeeper.getTotalProductionBonus()
    local bonus = 0
    for _, h in ipairs(Beekeeper.hives) do
        local def = HIVES[h.type]
        if def and h.health > 50 then
            bonus = bonus + def.productionBonus * (h.population / 50)
        end
    end
    return bonus
end

function Beekeeper.getPrestigeBonus()
    local bonus = 0
    for _, h in ipairs(Beekeeper.hives) do
        local def = HIVES[h.type]
        if def and def.prestigeBonus then bonus = bonus + def.prestigeBonus end
    end
    return bonus
end

-- ============================================================
-- PRODUCTION
-- ============================================================
function Beekeeper.produceProducts()
    local production = Beekeeper.getTotalProductionBonus()
    -- Beekeeper skill bonus
    if Beekeeper.beekeeper then
        production = production * (1 + Beekeeper.beekeeper.skill / 100)
    end
    -- Seasonal modifier
    production = production * Beekeeper.seasonalMultiplier
    -- Honey (main product)
    local honey = math.floor(production * 2)
    Beekeeper.productStockpile.honey = (Beekeeper.productStockpile.honey or 0) + honey
    Beekeeper.totalHoneyProduced = Beekeeper.totalHoneyProduced + honey
    -- Beeswax (secondary)
    local wax = math.floor(production * 0.5)
    Beekeeper.productStockpile.beeswax = (Beekeeper.productStockpile.beeswax or 0) + wax
    Beekeeper.totalWaxProduced = Beekeeper.totalWaxProduced + wax
    -- Propolis (rare)
    if math.random() < 0.30 then
        local propolis = math.floor(production * 0.1)
        Beekeeper.productStockpile.propolis = (Beekeeper.productStockpile.propolis or 0) + propolis
    end
    -- Royal jelly (very rare)
    if math.random() < 0.05 then
        local jelly = math.random(1, 3)
        Beekeeper.productStockpile.royal_jelly = (Beekeeper.productStockpile.royal_jelly or 0) + jelly
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify, "Redki matični mleček pridelan!", "rare")
        end
    end
end

-- ============================================================
-- MEAD BREWING
-- ============================================================
function Beekeeper.canBrewMead(meadType)
    local def = MEADS[meadType]
    if not def then return false, "Neznan medovec" end
    if (Beekeeper.productStockpile.honey or 0) < def.honeyRequired then
        return false, "Premalo medu"
    end
    return true
end

function Beekeeper.brewMead(meadType)
    local ok, err = Beekeeper.canBrewMead(meadType)
    if not ok then return false, err end
    local def = MEADS[meadType]
    Beekeeper.productStockpile.honey = Beekeeper.productStockpile.honey - def.honeyRequired
    local brewing = {
        id = "brew_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        meadType = meadType,
        meadName = def.name,
        daysRemaining = def.brewTime,
        value = def.value,
        happinessBonus = def.happinessBonus,
        prestigeBonus = def.prestigeBonus or 0,
        started = os.time(),
    }
    table.insert(Beekeeper.activeBrewing, brewing)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Medovec v pripravi: %s (%d dni)", def.name, def.brewTime), "info")
    end
    return true
end

function Beekeeper.completeBrewing(brewing)
    Beekeeper.meadStockpile[brewing.meadType] = (Beekeeper.meadStockpile[brewing.meadType] or 0) + 1
    Beekeeper.totalMeadBrewed = Beekeeper.totalMeadBrewed + 1
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Medovec pripravljen: %s!", brewing.meadName), "success")
    end
end

function Beekeeper.consumeMead(meadType)
    if (Beekeeper.meadStockpile[meadType] or 0) <= 0 then
        return false, "Ni medovca na zalogi"
    end
    local def = MEADS[meadType]
    Beekeeper.meadStockpile[meadType] = Beekeeper.meadStockpile[meadType] - 1
    if _G.state and _G.state.happiness and def.happinessBonus then
        _G.state.happiness = math.min(100, _G.state.happiness + def.happinessBonus)
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Medovec postrežen: " .. def.name, "info")
    end
    return true
end

-- ============================================================
-- SELL PRODUCTS
-- ============================================================
function Beekeeper.sellProduct(productType, quantity)
    if (Beekeeper.productStockpile[productType] or 0) < quantity then
        return false, "Premalo na zalogi"
    end
    local def = PRODUCTS[productType]
    if not def then return false, "Neznan produkt" end
    local revenue = def.value * quantity
    Beekeeper.productStockpile[productType] = Beekeeper.productStockpile[productType] - quantity
    if _G.state then
        _G.state.gold = (_G.state.gold or 0) + revenue
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Prodano: %d %s za %d zlata", quantity, def.name, revenue), "success")
    end
    return true
end

-- ============================================================
-- CANDLE MAKING (from wax)
-- ============================================================
function Beekeeper.makeCandles(quantity)
    local waxNeeded = quantity
    if (Beekeeper.productStockpile.beeswax or 0) < waxNeeded then
        return false, "Premalo voska"
    end
    Beekeeper.productStockpile.beeswax = Beekeeper.productStockpile.beeswax - waxNeeded
    -- Candles provide faith bonus (church lighting)
    if _G.Religion and _G.Religion.addFaith then
        pcall(_G.Religion.addFaith, quantity * 2)
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Sveče iz voska: %d (faith bonus)", quantity), "info")
    end
    return true
end

-- ============================================================
-- POLLINATION BONUS
-- ============================================================
function Beekeeper.getPollinationBonus()
    -- More hives = better crop yields
    local hiveCount = #Beekeeper.hives
    if hiveCount == 0 then return 0 end
    return math.min(0.30, hiveCount * 0.03)  -- up to 30% bonus
end

-- ============================================================
-- SWARM EVENTS
-- ============================================================
function Beekeeper.checkSwarmEvents()
    for _, h in ipairs(Beekeeper.hives) do
        -- Healthy hives may swarm (multiply)
        if h.health > 80 and h.population > 80 then
            if math.random() < 0.05 then
                -- Swarm! New hive created (if capacity)
                h.population = math.floor(h.population * 0.6)
                if _G.NotificationCenter then
                    pcall(_G.NotificationCenter.notify, "Čebele so se rojile! Nov panj možen.", "info")
                end
                -- Auto-create a new basic hive
                if #Beekeeper.hives < 50 then  -- soft cap
                    table.insert(Beekeeper.hives, {
                        id = "hive_swarm_" .. tostring(os.time()),
                        type = "skep",
                        health = 70,
                        population = 30,
                        builtDay = os.time(),
                    })
                end
            end
        end
        -- Unhealthy hives may abscond
        if h.health < 30 and math.random() < 0.10 then
            h.population = 0
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify, "Čebele so pobegnile iz panja!", "warning")
            end
        end
    end
    -- Remove dead hives
    for i = #Beekeeper.hives, 1, -1 do
        if Beekeeper.hives[i].population <= 0 then
            table.remove(Beekeeper.hives, i)
        end
    end
end

-- ============================================================
-- UPDATE
-- ============================================================
function Beekeeper.update(dt)
    if not _G.state then return end
    Beekeeper.dayTimer = Beekeeper.dayTimer + dt
    if Beekeeper.dayTimer >= 30 then
        Beekeeper.dayTimer = 0
        -- Update seasonal modifier
        if _G.SeasonalSystem and _G.SeasonalSystem.getCurrentSeason then
            local season = _G.SeasonalSystem.getCurrentSeason()
            if season == "spring" then Beekeeper.seasonalMultiplier = 1.5
            elseif season == "summer" then Beekeeper.seasonalMultiplier = 2.0
            elseif season == "autumn" then Beekeeper.seasonalMultiplier = 0.8
            elseif season == "winter" then Beekeeper.seasonalMultiplier = 0.1
            else Beekeeper.seasonalMultiplier = 1.0 end
        end
        -- Produce
        Beekeeper.produceProducts()
        -- Check swarms
        Beekeeper.checkSwarmEvents()
        -- Process brewing
        for i = #Beekeeper.activeBrewing, 1, -1 do
            local b = Beekeeper.activeBrewing[i]
            b.daysRemaining = b.daysRemaining - 1
            if b.daysRemaining <= 0 then
                Beekeeper.completeBrewing(b)
                table.remove(Beekeeper.activeBrewing, i)
            end
        end
        -- Pay upkeep
        local totalUpkeep = 0
        for _, h in ipairs(Beekeeper.hives) do
            local def = HIVES[h.type]
            if def then totalUpkeep = totalUpkeep + def.upkeep end
        end
        if Beekeeper.beekeeper then totalUpkeep = totalUpkeep + 10 end
        if totalUpkeep > 0 and _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep)
        end
        -- Apply pollination to food production
        local pollBonus = Beekeeper.getPollinationBonus()
        if pollBonus > 0 and _G.state and _G.state.resources then
            local baseFood = _G.state.resources.foodProduction or 50
            _G.state.resources.food = (_G.state.resources.food or 0) + math.floor(baseFood * pollBonus * 0.1)
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Beekeeper.getHiveInfo(hiveId) return HIVES[hiveId] end
function Beekeeper.getProductInfo(productId) return PRODUCTS[productId] end
function Beekeeper.getMeadInfo(meadId) return MEADS[meadId] end

function Beekeeper.getStats()
    return {
        numHives = #Beekeeper.hives,
        productStockpile = Beekeeper.productStockpile,
        meadStockpile = Beekeeper.meadStockpile,
        activeBrewing = #Beekeeper.activeBrewing,
        hasBeekeeper = Beekeeper.beekeeper ~= nil,
        beekeeperName = Beekeeper.beekeeper and Beekeeper.beekeeper.name or "—",
        totalHoneyProduced = Beekeeper.totalHoneyProduced,
        totalWaxProduced = Beekeeper.totalWaxProduced,
        totalMeadBrewed = Beekeeper.totalMeadBrewed,
        pollinationBonus = Beekeeper.getPollinationBonus(),
        prestigeBonus = Beekeeper.getPrestigeBonus(),
        seasonalMultiplier = Beekeeper.seasonalMultiplier,
    }
end

return Beekeeper
