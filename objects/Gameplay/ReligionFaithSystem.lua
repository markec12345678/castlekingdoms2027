-- objects/Gameplay/ReligionFaithSystem.lua
-- Castle Kingdoms 2027 v3.0.8 - Religion & Faith System
--
-- Manages organized religion, faith-based gameplay, and religious influence on
-- population happiness, diplomacy, and military morale.
--
-- Features:
-- - 5 religions (Catholic, Orthodox, Pagan, Heretic, Custom)
-- - 7 religious buildings (Chapel, Church, Cathedral, Monastery, Shrine, Temple, Holy Site)
-- - 6 faith actions (blessing, excommunication, holy war, conversion, donation, pilgrimage)
-- - Religious tolerance and unrest
-- - Holy days and religious festivals
-- - Religious relics (collectible bonuses)
-- - Heresy outbreaks and inquisition
-- - Inter-faith diplomatic modifiers

local Religion = {}

-- ============================================================
-- RELIGION DEFINITIONS
-- ============================================================
local RELIGIONS = {
    catholic = {
        name = "Katolištvo",
        nameEn = "Catholicism",
        symbol = "✝",
        color = { 0.85, 0.05, 0.05 },
        primaryGod = "Kristus",
        holyBook = "Sveto pismo",
        holyDay = "Nedelja",
        baseHappinessBonus = 8,
        warmongerFactor = 1.0,
        conversionRate = 0.10,
        rivalReligions = { "heretic", "pagan" },
        allies = { "orthodox" },
        description = "Dominantna vero v srednjeveški Evropi, podpora papeža.",
    },
    orthodox = {
        name = "Pravoslavje",
        nameEn = "Orthodoxy",
        symbol = "☦",
        color = { 0.05, 0.55, 0.85 },
        primaryGod = "Kristus",
        holyBook = "Sveto pismo",
        holyDay = "Nedelja",
        baseHappinessBonus = 7,
        warmongerFactor = 0.9,
        conversionRate = 0.08,
        rivalReligions = { "heretic", "pagan" },
        allies = { "catholic" },
        description = "Vzhodna veja krščanstva, močna tradicija in obredi.",
    },
    pagan = {
        name = "Poganstvo",
        nameEn = "Paganism",
        symbol = "☀",
        color = { 0.65, 0.55, 0.10 },
        primaryGod = "Perun",
        holyBook = "Oralne tradicije",
        holyDay = "Sobotni večer",
        baseHappinessBonus = 6,
        warmongerFactor = 1.3,
        conversionRate = 0.05,
        rivalReligions = { "catholic", "orthodox" },
        allies = {},
        description = "Stara vera narave in prednikov, odpora do pokrščevanja.",
    },
    heretic = {
        name = "Herezija",
        nameEn = "Heresy",
        symbol = "☥",
        color = { 0.55, 0.05, 0.55 },
        primaryGod = "Svobodni duh",
        holyBook = "Skriti spisi",
        holyDay = "Luna polna",
        baseHappinessBonus = 4,
        warmongerFactor = 1.1,
        conversionRate = 0.15,
        rivalReligions = { "catholic", "orthodox" },
        allies = {},
        description = "Uporniška vero, širi se v času politične šibkosti cerkve.",
    },
    custom = {
        name = "Državna vera",
        nameEn = "State Religion",
        symbol = "★",
        color = { 0.85, 0.65, 0.10 },
        primaryGod = "Vladar",
        holyBook = "Kronika kraljestva",
        holyDay = "Dan kronanja",
        baseHappinessBonus = 10,
        warmongerFactor = 1.2,
        conversionRate = 0.12,
        rivalReligions = {},
        allies = {},
        description = "Vladar je tudi verski vodja, popoln nadzor nad obredi.",
    },
}

-- ============================================================
-- RELIGIOUS BUILDINGS
-- ============================================================
local RELIGIOUS_BUILDINGS = {
    chapel = {
        name = "Kapela",
        cost = { gold = 150, wood = 50, stone = 20 },
        upkeep = 5,
        faithPerDay = 0.5,
        capacity = 30,
        minPopulation = 10,
        conversionBonus = 0.02,
        description = "Majhna molilnica za lokalno skupnost.",
    },
    church = {
        name = "Cerkev",
        cost = { gold = 500, wood = 100, stone = 150 },
        upkeep = 15,
        faithPerDay = 1.5,
        capacity = 100,
        minPopulation = 50,
        conversionBonus = 0.05,
        description = "Osrednji verski objekt mesta.",
    },
    cathedral = {
        name = "Katedrala",
        cost = { gold = 2500, wood = 200, stone = 800 },
        upkeep = 50,
        faithPerDay = 5.0,
        capacity = 500,
        minPopulation = 250,
        conversionBonus = 0.10,
        description = "Velika verska zgradba, simbol moči cerkve.",
    },
    monastery = {
        name = "Samostan",
        cost = { gold = 800, wood = 200, stone = 300 },
        upkeep = 25,
        faithPerDay = 2.5,
        capacity = 50,
        minPopulation = 100,
        conversionBonus = 0.04,
        producesRelics = true,
        description = "Samoizolirana verska skupnost, proizvaja relikvije.",
    },
    shrine = {
        name = "Svetišče",
        cost = { gold = 100, wood = 30 },
        upkeep = 2,
        faithPerDay = 0.3,
        capacity = 10,
        minPopulation = 5,
        conversionBonus = 0.01,
        description = "Majhen domači oltar, lokalno čaščenje.",
    },
    temple = {
        name = "Tempelj",
        cost = { gold = 1200, wood = 150, stone = 400 },
        upkeep = 35,
        faithPerDay = 3.0,
        capacity = 200,
        minPopulation = 150,
        conversionBonus = 0.06,
        description = "Velik poganski tempelj za skupne obrede.",
    },
    holy_site = {
        name = "Sveto mesto",
        cost = { gold = 5000, wood = 500, stone = 1500 },
        upkeep = 100,
        faithPerDay = 10.0,
        capacity = 1000,
        minPopulation = 500,
        conversionBonus = 0.20,
        producesRelics = true,
        description = "Romaniško sveto mesto, privablja vernike od vsepovsod.",
    },
}

-- ============================================================
-- FAITH ACTIONS
-- ============================================================
local FAITH_ACTIONS = {
    blessing = {
        name = "Blagoslov",
        faithCost = 10,
        cooldownDays = 7,
        effect = { happinessBonus = 5, duration = 3 },
        description = "Začasno poveča srečo prebivalstva.",
    },
    excommunication = {
        name = "Izobčenje",
        faithCost = 50,
        cooldownDays = 30,
        effect = { targetHappiness = -25, targetProduction = 0.7 },
        description = "Izobči nasprotnika, zmanjša njegovo srečo in produktivnost.",
    },
    holy_war = {
        name = "Sveta vojna",
        faithCost = 100,
        cooldownDays = 90,
        effect = { attackBonus = 1.5, moraleBonus = 25, duration = 30 },
        description = "Razglasi sveto vojno, poveča napad in moralo vojakov.",
    },
    conversion = {
        name = "Pokrščevanje",
        faithCost = 25,
        cooldownDays = 14,
        effect = { conversionChance = 0.15 },
        description = "Poskusi spreobrniti prebivalstvo v svojo vero.",
    },
    donation = {
        name = "Donacija",
        faithCost = 0,
        goldCost = 200,
        cooldownDays = 7,
        effect = { happinessBonus = 3, faithGain = 15 },
        description = "Doniraj zlato cerkvi za srečo in vero.",
    },
    pilgrimage = {
        name = "Romanje",
        faithCost = 30,
        cooldownDays = 60,
        effect = { happinessBonus = 15, faithGain = 50, populationMovement = 0.05 },
        description = "Pošlji romanje v sveto mesto za velik bonus vere.",
    },
}

-- ============================================================
-- HOLY DAYS & FESTIVALS
-- ============================================================
local HOLY_DAYS = {
    { name = "Božič", dayOfYear = 355, faithBonus = 20, happinessBonus = 15 },
    { name = "Velika noč", dayOfYear = 100, faithBonus = 25, happinessBonus = 20 },
    { name = "Binkošti", dayOfYear = 150, faithBonus = 15, happinessBonus = 10 },
    { name = "Vsi svetniki", dayOfYear = 305, faithBonus = 18, happinessBonus = 12 },
    { name = "Kronanje", dayOfYear = 1, faithBonus = 30, happinessBonus = 25 },
    { name = "Pomladni festival", dayOfYear = 80, faithBonus = 12, happinessBonus = 8 },
    { name = "Letni summit", dayOfYear = 200, faithBonus = 20, happinessBonus = 18 },
}

-- ============================================================
-- STATE
-- ============================================================
Religion.faith = 100            -- Current faith points (0-1000)
Religion.maxFaith = 1000
Religion.stateReligion = "catholic"
Religion.populationReligions = {
    catholic = 70,    -- percentages
    orthodox = 5,
    pagan = 20,
    heretic = 5,
    custom = 0,
}
Religion.relics = {}            -- Collected relics
Religion.activeHolyWars = {}    -- Active holy war effects
Religion.activeBlessings = {}   -- Active blessings
Religion.cooldowns = {}         -- Action cooldowns
Religion.religiousBuildings = {}-- Built religious buildings
Religion.heresyLevel = 0        -- 0-100, chance of heresy outbreak
Religion.tolerance = 50         -- 0-100, higher = more tolerant
Religion.lastUpdate = 0
Religion.activeEvents = {}      -- Active religious events
Religion.dayOfYear = 1

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Religion.init()
    Religion.faith = 100
    Religion.stateReligion = "catholic"
    Religion.populationReligions = {
        catholic = 70, orthodox = 5, pagan = 20, heretic = 5, custom = 0,
    }
    Religion.relics = {}
    Religion.activeHolyWars = {}
    Religion.activeBlessings = {}
    Religion.cooldowns = {}
    Religion.religiousBuildings = {}
    Religion.heresyLevel = 0
    Religion.tolerance = 50
    Religion.activeEvents = {}
    Religion.dayOfYear = 1
    print("[Religion] Religion & Faith System initialized (state religion: catholic)")
end

-- ============================================================
-- FAITH GENERATION
-- ============================================================
function Religion.calculateDailyFaith()
    local total = 0
    for _, building in ipairs(Religion.religiousBuildings) do
        local def = RELIGIOUS_BUILDINGS[building.type]
        if def then
            total = total + def.faithPerDay
        end
    end
    -- State religion bonus
    local stateRel = RELIGIONS[Religion.stateReligion]
    if stateRel then
        local followers = Religion.populationReligions[Religion.stateReligion] or 0
        total = total + (followers / 100) * 2  -- 2 faith/day for 100% followers
    end
    return total
end

function Religion.addFaith(amount)
    Religion.faith = math.min(Religion.maxFaith, Religion.faith + amount)
end

function Religion.spendFaith(amount)
    if Religion.faith >= amount then
        Religion.faith = Religion.faith - amount
        return true
    end
    return false
end

-- ============================================================
-- BUILDING CONSTRUCTION
-- ============================================================
function Religion.canBuild(buildingType)
    local def = RELIGIOUS_BUILDINGS[buildingType]
    if not def then return false, "Neznana zgradba" end
    if not _G.state then return false, "Brez stanja" end
    -- Check resources
    if _G.state.gold < (def.cost.gold or 0) then return false, "Premalo zlata" end
    if _G.state.resources then
        if (_G.state.resources.wood or 0) < (def.cost.wood or 0) then return false, "Premalo lesa" end
        if (_G.state.resources.stone or 0) < (def.cost.stone or 0) then return false, "Premalo kamna" end
    end
    -- Check population
    local pop = (_G.state.population or _G.state.maxPopulation or 100)
    if pop < (def.minPopulation or 0) then return false, "Premajhna populacija" end
    return true
end

function Religion.buildReligiousBuilding(buildingType, x, y)
    local ok, err = Religion.canBuild(buildingType)
    if not ok then
        return false, err
    end
    local def = RELIGIOUS_BUILDINGS[buildingType]
    -- Deduct resources
    _G.state.gold = _G.state.gold - (def.cost.gold or 0)
    if _G.state.resources then
        _G.state.resources.wood = (_G.state.resources.wood or 0) - (def.cost.wood or 0)
        _G.state.resources.stone = (_G.state.resources.stone or 0) - (def.cost.stone or 0)
    end
    -- Register building
    table.insert(Religion.religiousBuildings, {
        type = buildingType,
        x = x or 0,
        y = y or 0,
        builtDay = Religion.dayOfYear,
        relicChance = def.producesRelics or false,
    })
    -- Notify
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Verska zgradba zgrajena: " .. def.name, "success")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "RELIGIOUS_BUILDING_BUILT", {
            type = buildingType, x = x, y = y,
        })
    end
    return true
end

-- ============================================================
-- FAITH ACTIONS
-- ============================================================
function Religion.canPerformAction(actionId)
    local def = FAITH_ACTIONS[actionId]
    if not def then return false, "Neznana akcija" end
    -- Check faith
    if Religion.faith < (def.faithCost or 0) then return false, "Premalo vere" end
    -- Check gold
    if def.goldCost and _G.state and (_G.state.gold or 0) < def.goldCost then
        return false, "Premalo zlata"
    end
    -- Check cooldown
    local cd = Religion.cooldowns[actionId]
    if cd and cd > 0 then return false, "Akcija je v pripravljenosti" end
    return true
end

function Religion.performAction(actionId, targetId)
    local ok, err = Religion.canPerformAction(actionId)
    if not ok then return false, err end
    local def = FAITH_ACTIONS[actionId]
    -- Deduct costs
    Religion.spendFaith(def.faithCost or 0)
    if def.goldCost and _G.state then
        _G.state.gold = _G.state.gold - def.goldCost
    end
    -- Apply effects
    local eff = def.effect or {}
    if actionId == "blessing" then
        table.insert(Religion.activeBlessings, {
            happinessBonus = eff.happinessBonus or 5,
            daysRemaining = eff.duration or 3,
        })
    elseif actionId == "excommunication" then
        if _G.DiplomacyController and targetId then
            pcall(_G.DiplomacyController.changeRelation, targetId, -40)
        end
    elseif actionId == "holy_war" then
        table.insert(Religion.activeHolyWars, {
            attackBonus = eff.attackBonus or 1.5,
            moraleBonus = eff.moraleBonus or 25,
            daysRemaining = eff.duration or 30,
            targetId = targetId,
        })
    elseif actionId == "conversion" then
        Religion.attemptConversion(targetId, eff.conversionChance or 0.15)
    elseif actionId == "donation" then
        Religion.addFaith(eff.faithGain or 15)
    elseif actionId == "pilgrimage" then
        Religion.addFaith(eff.faithGain or 50)
    end
    -- Set cooldown
    Religion.cooldowns[actionId] = def.cooldownDays or 7
    -- Notify
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Verska akcija: " .. def.name, "info")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "FAITH_ACTION", { action = actionId, target = targetId })
    end
    return true
end

function Religion.attemptConversion(regionId, chance)
    -- Convert some population to state religion
    local converted = 0
    for rel, pct in pairs(Religion.populationReligions) do
        if rel ~= Religion.stateReligion and pct > 5 then
            local amount = math.floor(pct * chance)
            Religion.populationReligions[rel] = pct - amount
            converted = converted + amount
        end
    end
    Religion.populationReligions[Religion.stateReligion] =
        (Religion.populationReligions[Religion.stateReligion] or 0) + converted
    return converted
end

-- ============================================================
-- RELICS
-- ============================================================
function Religion.addRelic(name, bonus)
    table.insert(Religion.relics, {
        name = name,
        bonus = bonus,  -- { faithPerDay = 1, happinessBonus = 3, ... }
        acquiredDay = Religion.dayOfYear,
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Nova relikvija pridobljena: " .. name, "rare")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "RELIC_ACQUIRED", { name = name })
    end
end

function Religion.checkRelicGeneration()
    for _, building in ipairs(Religion.religiousBuildings) do
        if building.relicChance then
            if math.random() < 0.001 then  -- 0.1% chance per day
                local relicNames = {
                    "Križ sv. Andreja",
                    "Rožni venec Device Marije",
                    "Relikvija sv. Nikolaja",
                    "Kapljica svete krvi",
                    "Krona mučenikov",
                    "Sveti kelih",
                    "Knjiga psalmov",
                }
                local bonuses = {
                    { faithPerDay = 1, happinessBonus = 2 },
                    { faithPerDay = 2, happinessBonus = 3 },
                    { faithPerDay = 3, happinessBonus = 5 },
                    { faithPerDay = 5, happinessBonus = 8 },
                }
                Religion.addRelic(
                    relicNames[math.random(#relicNames)],
                    bonuses[math.random(#bonuses)]
                )
            end
        end
    end
end

function Religion.getRelicBonuses()
    local total = { faithPerDay = 0, happinessBonus = 0 }
    for _, relic in ipairs(Religion.relics) do
        for k, v in pairs(relic.bonus or {}) do
            total[k] = (total[k] or 0) + v
        end
    end
    return total
end

-- ============================================================
-- HOLY DAYS
-- ============================================================
function Religion.checkHolyDay()
    for _, day in ipairs(HOLY_DAYS) do
        if Religion.dayOfYear == day.dayOfYear then
            Religion.addFaith(day.faithBonus)
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify, "Sveti dan: " .. day.name, "festival")
            end
            if _G.GameEventBus then
                pcall(_G.GameEventBus.publish, "HOLY_DAY", { name = day.name })
            end
        end
    end
end

-- ============================================================
-- HERESY & INQUISITION
-- ============================================================
function Religion.updateHeresy()
    -- Heresy grows based on unrest, low tolerance, and lack of religious buildings
    local unrest = 0
    if _G.state and _G.state.happiness then
        unrest = math.max(0, 50 - _G.state.happiness)
    end
    Religion.heresyLevel = Religion.heresyLevel + (unrest * 0.001) - (Religion.tolerance * 0.0005)
    Religion.heresyLevel = math.max(0, math.min(100, Religion.heresyLevel))
    -- Outbreak
    if Religion.heresyLevel > 70 and math.random() < 0.005 then
        Religion.triggerHeresyOutbreak()
    end
end

function Religion.triggerHeresyOutbreak()
    local converted = math.floor((Religion.populationReligions[Religion.stateReligion] or 0) * 0.10)
    Religion.populationReligions[Religion.stateReligion] =
        (Religion.populationReligions[Religion.stateReligion] or 0) - converted
    Religion.populationReligions.heretic = (Religion.populationReligions.heretic or 0) + converted
    Religion.heresyLevel = 30  -- Reset after outbreak
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "IZBRUH HEREZIJE! 10% prebivalstva se je odvrnilo!", "danger")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "HERESY_OUTBREAK", { converted = converted })
    end
end

function Religion.inquisition()
    -- Spend faith to reduce heresy
    if Religion.spendFaith(40) then
        local removed = (Religion.populationReligions.heretic or 0) * 0.5
        Religion.populationReligions.heretic =
            (Religion.populationReligions.heretic or 0) - removed
        Religion.populationReligions[Religion.stateReligion] =
            (Religion.populationReligions[Religion.stateReligion] or 0) + removed
        Religion.heresyLevel = 0
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify, "Inkvizicija uspešna, herezija zatrtana!", "success")
        end
        return true
    end
    return false
end

-- ============================================================
-- ACTIVE EFFECTS
-- ============================================================
function Religion.getActiveBonuses()
    local bonuses = {
        happinessBonus = 0,
        attackBonus = 1.0,
        moraleBonus = 0,
        faithPerDay = 0,
    }
    -- State religion base bonus
    local stateRel = RELIGIONS[Religion.stateReligion]
    if stateRel then
        bonuses.happinessBonus = bonuses.happinessBonus + stateRel.baseHappinessBonus
    end
    -- Active blessings
    for _, b in ipairs(Religion.activeBlessings) do
        bonuses.happinessBonus = bonuses.happinessBonus + b.happinessBonus
    end
    -- Active holy wars
    for _, hw in ipairs(Religion.activeHolyWars) do
        bonuses.attackBonus = bonuses.attackBonus * hw.attackBonus
        bonuses.moraleBonus = bonuses.moraleBonus + hw.moraleBonus
    end
    -- Relic bonuses
    local relicB = Religion.getRelicBonuses()
    bonuses.faithPerDay = bonuses.faithPerDay + (relicB.faithPerDay or 0)
    bonuses.happinessBonus = bonuses.happinessBonus + (relicB.happinessBonus or 0)
    -- Religious buildings
    for _, b in ipairs(Religion.religiousBuildings) do
        local def = RELIGIOUS_BUILDINGS[b.type]
        if def then bonuses.faithPerDay = bonuses.faithPerDay + def.faithPerDay end
    end
    return bonuses
end

-- ============================================================
-- UPDATE
-- ============================================================
function Religion.update(dt)
    if not _G.state then return end
    Religion.lastUpdate = Religion.lastUpdate + dt
    -- Day cycle (simplified - 1 day per ~30 seconds)
    local dayProgress = Religion.lastUpdate % 30
    if dayProgress < dt then
        Religion.dayOfYear = (Religion.dayOfYear % 365) + 1
        -- Generate faith
        Religion.addFaith(Religion.calculateDailyFaith())
        -- Reduce cooldowns
        for action, cd in pairs(Religion.cooldowns) do
            if cd > 0 then Religion.cooldowns[action] = cd - 1 end
        end
        -- Reduce blessing/holy war durations
        for i = #Religion.activeBlessings, 1, -1 do
            Religion.activeBlessings[i].daysRemaining = Religion.activeBlessings[i].daysRemaining - 1
            if Religion.activeBlessings[i].daysRemaining <= 0 then
                table.remove(Religion.activeBlessings, i)
            end
        end
        for i = #Religion.activeHolyWars, 1, -1 do
            Religion.activeHolyWars[i].daysRemaining = Religion.activeHolyWars[i].daysRemaining - 1
            if Religion.activeHolyWars[i].daysRemaining <= 0 then
                table.remove(Religion.activeHolyWars, i)
            end
        end
        -- Holy day check
        Religion.checkHolyDay()
        -- Relic generation
        Religion.checkRelicGeneration()
        -- Heresy
        Religion.updateHeresy()
    end
    -- Apply happiness bonus from religion
    if _G.state.happiness then
        local bonuses = Religion.getActiveBonuses()
        -- This is applied via query from PopulationSystem
    end
end

-- ============================================================
-- DRAW (UI OVERLAY)
-- ============================================================
function Religion.draw()
    if not _G.state then return end
    -- Draw faith meter in top-right
    if _G.fontManager then
        pcall(function()
            local x = love.graphics.getWidth() - 220
            local y = 100
            love.graphics.setColor(0.2, 0.1, 0.3, 0.7)
            love.graphics.rectangle("fill", x, y, 200, 60)
            love.graphics.setColor(0.85, 0.65, 0.10, 1)
            love.graphics.rectangle("fill", x, y, 200 * (Religion.faith / Religion.maxFaith), 20)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.print(string.format("Vera: %d/%d", math.floor(Religion.faith), Religion.maxFaith), x + 5, y + 5)
            local stateRel = RELIGIONS[Religion.stateReligion]
            if stateRel then
                love.graphics.print(stateRel.symbol .. " " .. stateRel.name, x + 5, y + 30)
            end
            -- Heresy indicator
            if Religion.heresyLevel > 30 then
                love.graphics.setColor(0.8, 0.2, 0.4, 1)
                love.graphics.print(string.format("Herezija: %d%%", math.floor(Religion.heresyLevel)), x + 100, y + 30)
                love.graphics.setColor(1, 1, 1, 1)
            end
        end)
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Religion.getReligionInfo(religionId)
    return RELIGIONS[religionId]
end

function Religion.getBuildingInfo(buildingId)
    return RELIGIOUS_BUILDINGS[buildingId]
end

function Religion.getActionInfo(actionId)
    return FAITH_ACTIONS[actionId]
end

function Religion.getStats()
    return {
        faith = Religion.faith,
        maxFaith = Religion.maxFaith,
        stateReligion = Religion.stateReligion,
        numBuildings = #Religion.religiousBuildings,
        numRelics = #Religion.relics,
        heresyLevel = Religion.heresyLevel,
        tolerance = Religion.tolerance,
        populationReligions = Religion.populationReligions,
        activeBlessings = #Religion.activeBlessings,
        activeHolyWars = #Religion.activeHolyWars,
    }
end

function Religion.setTolerance(level)
    Religion.tolerance = math.max(0, math.min(100, level))
end

function Religion.getStateReligion()
    return Religion.stateReligion, RELIGIONS[Religion.stateReligion]
end

function Religion.setStateReligion(religionId)
    if RELIGIONS[religionId] then
        local old = Religion.stateReligion
        Religion.stateReligion = religionId
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify, "Državna vera spremenjena: " ..
                (RELIGIONS[religionId].name), "important")
        end
        if _G.GameEventBus then
            pcall(_G.GameEventBus.publish, "STATE_RELIGION_CHANGED", {
                old = old, new = religionId,
            })
        end
    end
end

return Religion
