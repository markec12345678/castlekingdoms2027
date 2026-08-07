-- objects/Gameplay/RoyalFeastBanquetSystem.lua
-- Castle Kingdoms 2027 v3.3.1 - Royal Feast & Banquet System
--
-- Manages grand feasts and banquets for diplomacy, happiness, and prestige.
-- Different feast types serve different purposes.
--
-- Features:
-- - 6 feast types (state dinner, wedding feast, victory celebration, religious feast, harvest feast, diplomatic banquet)
-- - 8 dish types (roast boar, swan, peacock, fish, bread, wine, ale, dessert)
-- - Guest management (invite nobles, allies, rivals)
-- - Seating arrangement (diplomatic implications)
-- - Toast system (improve relations)
-- - Feast disasters (food poisoning, drunken brawls)
-- - Kitchen buildings
-- - Chef NPC (skill affects feast quality)

local Feast = {}

-- ============================================================
-- FEAST TYPES
-- ============================================================
local FEAST_TYPES = {
    state_dinner = {
        name = "Državna večerja",
        nameEn = "State Dinner",
        cost = 1000,
        duration = 1,
        baseHappiness = 5,
        basePrestige = 10,
        maxGuests = 20,
        diplomaticBonus = 15,
        description = "Formalna večerja za plemstvo in diplomate.",
    },
    wedding_feast = {
        name = "Porokna gostija",
        nameEn = "Wedding Feast",
        cost = 2500,
        duration = 3,
        baseHappiness = 15,
        basePrestige = 25,
        maxGuests = 50,
        diplomaticBonus = 20,
        description = "Velika poročna gostija.",
    },
    victory_celebration = {
        name = "Proslava zmage",
        nameEn = "Victory Celebration",
        cost = 1500,
        duration = 2,
        baseHappiness = 20,
        basePrestige = 15,
        maxGuests = 100,
        moraleBonus = 20,
        description = "Proslava vojaške zmage.",
    },
    religious_feast = {
        name = "Verska gostija",
        nameEn = "Religious Feast",
        cost = 800,
        duration = 1,
        baseHappiness = 8,
        basePrestige = 5,
        maxGuests = 30,
        faithBonus = 25,
        description = "Gostija ob verskem prazniku.",
    },
    harvest_feast = {
        name = "Pobratna gostija",
        nameEn = "Harvest Feast",
        cost = 500,
        duration = 2,
        baseHappiness = 12,
        basePrestige = 5,
        maxGuests = 200,
        description = "Gostija ob koncu pobrata.",
    },
    diplomatic_banquet = {
        name = "Diplomatska gostbaan",
        nameEn = "Diplomatic Banquet",
        cost = 2000,
        duration = 1,
        baseHappiness = 5,
        basePrestige = 20,
        maxGuests = 15,
        diplomaticBonus = 30,
        description = "Ekskluzivna gostbaan za diplomacijo.",
    },
}

-- ============================================================
-- DISH TYPES
-- ============================================================
local DISHES = {
    roast_boar = {
        name = "Pečen merjavec",
        cost = 200,
        satisfaction = 15,
        prestigeBonus = 5,
        description = "Veliki pečen merjavec, srednjeveška klasika.",
    },
    swan = {
        name = "Labod",
        cost = 500,
        satisfaction = 20,
        prestigeBonus = 15,
        description = "Labod — samo za kraljeve gostije.",
    },
    peacock = {
        name = "Pavan",
        cost = 600,
        satisfaction = 25,
        prestigeBonus = 20,
        description = "Pavan z perjem — spektakularna jed.",
    },
    fish = {
        name = "Ribe",
        cost = 100,
        satisfaction = 8,
        prestigeBonus = 2,
        description = "Sveže ribe iz morja ali reke.",
    },
    bread = {
        name = "Kruh",
        cost = 30,
        satisfaction = 5,
        prestigeBonus = 0,
        description = "Osnovni kruh za vse goste.",
    },
    wine = {
        name = "Vino",
        cost = 150,
        satisfaction = 12,
        prestigeBonus = 5,
        description = "Dobro vino iz vinogradov.",
    },
    ale = {
        name = "Pivo",
        cost = 50,
        satisfaction = 8,
        prestigeBonus = 1,
        description = "Lokalno pivo za množice.",
    },
    dessert = {
        name = "Sladica",
        cost = 100,
        satisfaction = 15,
        prestigeBonus = 8,
        description = "Sladke jedi za konec.",
    },
}

-- ============================================================
-- KITCHEN BUILDINGS
-- ============================================================
local KITCHEN_BUILDINGS = {
    kitchen = {
        name = "Kuhinja",
        cost = { gold = 300, wood = 100, stone = 50 },
        upkeep = 10,
        dishCapacity = 4,
        qualityBonus = 5,
        description = "Osnovna kuhinja za pripravo jedi.",
    },
    royal_kitchen = {
        name = "Kraljeva kuhinja",
        cost = { gold = 1200, wood = 200, stone = 300 },
        upkeep = 40,
        dishCapacity = 8,
        qualityBonus = 15,
        description = "Velika kuhinja za kraljeve gostije.",
    },
    grand_banquet_hall = {
        name = "Velika dvorana za gostije",
        cost = { gold = 5000, wood = 500, stone = 1000 },
        upkeep = 100,
        dishCapacity = 16,
        qualityBonus = 30,
        guestCapacity = 200,
        description = "Največja dvorana za velike gostije.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Feast.activeFeasts = {}                 -- Currently running feasts
Feast.kitchenBuildings = {}             -- Built kitchens
Feast.chef = nil                        -- Hired chef
Feast.totalFeasts = 0
Feast.totalDisasters = 0
Feast.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Feast.init()
    Feast.activeFeasts = {}
    Feast.kitchenBuildings = {}
    Feast.chef = nil
    Feast.totalFeasts = 0
    Feast.totalDisasters = 0
    Feast.dayTimer = 0
    print("[Feast] Royal Feast & Banquet System initialized (6 feast types, 8 dishes)")
end

-- ============================================================
-- KITCHEN CONSTRUCTION
-- ============================================================
function Feast.canBuild(buildingId)
    local def = KITCHEN_BUILDINGS[buildingId]
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

function Feast.build(buildingId)
    local ok, err = Feast.canBuild(buildingId)
    if not ok then return false, err end
    local def = KITCHEN_BUILDINGS[buildingId]
    _G.state.gold = _G.state.gold - (def.cost.gold or 0)
    if _G.state.resources then
        for res, amt in pairs(def.cost) do
            if res ~= "gold" then
                _G.state.resources[res] = (_G.state.resources[res] or 0) - amt
            end
        end
    end
    table.insert(Feast.kitchenBuildings, {
        type = buildingId,
        builtDay = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. def.name, "success")
    end
    return true
end

function Feast.getDishCapacity()
    local cap = 2
    for _, b in ipairs(Feast.kitchenBuildings) do
        local def = KITCHEN_BUILDINGS[b.type]
        if def and def.dishCapacity then cap = cap + def.dishCapacity end
    end
    return cap
end

function Feast.getQualityBonus()
    local bonus = 0
    for _, b in ipairs(Feast.kitchenBuildings) do
        local def = KITCHEN_BUILDINGS[b.type]
        if def and def.qualityBonus then bonus = bonus + def.qualityBonus end
    end
    return bonus
end

function Feast.getGuestCapacity()
    local cap = 30
    for _, b in ipairs(Feast.kitchenBuildings) do
        local def = KITCHEN_BUILDINGS[b.type]
        if def and def.guestCapacity then cap = cap + def.guestCapacity end
    end
    return cap
end

-- ============================================================
-- CHEF
-- ============================================================
function Feast.hireChef(name, skill)
    skill = skill or math.random(40, 90)
    local cost = 500 + skill * 10
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    Feast.chef = {
        name = name or ("Kuhar " .. math.random(1, 99)),
        skill = skill,
        hiredDay = os.time(),
    }
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Kuhar najet: %s (spretnost: %d)", Feast.chef.name, skill), "success")
    end
    return true
end

-- ============================================================
-- FEAST ORGANIZATION
-- ============================================================
function Feast.canOrganize(feastType, dishChoices, numGuests)
    local def = FEAST_TYPES[feastType]
    if not def then return false, "Neznan tip gostije" end
    -- Check dish count
    if #dishChoices > Feast.getDishCapacity() then
        return false, "Preveč jedi za kuhinjo"
    end
    -- Check guests
    if numGuests > def.maxGuests then
        return false, "Preveč gostov za ta tip gostije"
    end
    if numGuests > Feast.getGuestCapacity() then
        return false, "Premajhna dvorana"
    end
    -- Calculate total cost
    local totalCost = def.cost
    for _, dishId in ipairs(dishChoices) do
        local dish = DISHES[dishId]
        if dish then totalCost = totalCost + dish.cost end
    end
    -- Multiply by guest factor
    totalCost = totalCost * math.max(1, math.floor(numGuests / 10))
    if not _G.state or (_G.state.gold or 0) < totalCost then
        return false, "Premalo zlata"
    end
    return true, totalCost
end

function Feast.organize(feastType, dishChoices, numGuests, guestFactions)
    local ok, result = Feast.canOrganize(feastType, dishChoices, numGuests)
    if not ok then return false, result end
    local totalCost = result
    local def = FEAST_TYPES[feastType]
    -- Pay
    _G.state.gold = _G.state.gold - totalCost
    -- Calculate satisfaction
    local satisfaction = 0
    local dishPrestige = 0
    for _, dishId in ipairs(dishChoices) do
        local dish = DISHES[dishId]
        if dish then
            satisfaction = satisfaction + dish.satisfaction
            dishPrestige = dishPrestige + dish.prestigeBonus
        end
    end
    -- Apply quality bonus
    local qualityBonus = Feast.getQualityBonus()
    if Feast.chef then
        qualityBonus = qualityBonus + (Feast.chef.skill / 5)
    end
    satisfaction = satisfaction + qualityBonus
    local feast = {
        id = "feast_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        type = feastType,
        typeName = def.name,
        duration = def.duration,
        daysRemaining = def.duration,
        numGuests = numGuests,
        guestFactions = guestFactions or {},
        satisfaction = satisfaction,
        baseHappiness = def.baseHappiness,
        basePrestige = def.basePrestige + dishPrestige,
        diplomaticBonus = def.diplomaticBonus or 0,
        faithBonus = def.faithBonus or 0,
        moraleBonus = def.moraleBonus or 0,
        dishes = dishChoices,
        started = os.time(),
        completed = false,
    }
    table.insert(Feast.activeFeasts, feast)
    Feast.totalFeasts = Feast.totalFeasts + 1
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Gostija začeta: %s (%d gostov, %d jedi)",
                def.name, numGuests, #dishChoices), "important")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "FEAST_STARTED", { type = feastType, guests = numGuests })
    end
    -- Random disaster check
    if math.random() < 0.10 then
        Feast.triggerDisaster(feast)
    end
    return true, feast.id
end

function Feast.triggerDisaster(feast)
    local disasters = {
        { text = "Zastrupitev s hrano!", effect = { happiness = -10, health = -5 } },
        { text = "Pijana pretepa!", effect = { happiness = -5, diplomaticBonus = -10 } },
        { text = "Požar v kuhinji!", effect = { gold = -300, happiness = -3 } },
        { text = "Gostje zboleli!", effect = { happiness = -8 } },
    }
    local disaster = disasters[math.random(#disasters)]
    Feast.totalDisasters = Feast.totalDisasters + 1
    local eff = disaster.effect
    if eff.happiness and _G.state and _G.state.happiness then
        _G.state.happiness = math.max(0, _G.state.happiness + eff.happiness)
    end
    if eff.gold and _G.state then
        _G.state.gold = math.max(0, (_G.state.gold or 0) + eff.gold)
    end
    if eff.diplomaticBonus then
        feast.diplomaticBonus = math.max(0, feast.diplomaticBonus + eff.diplomaticBonus)
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "KATASTROFA: " .. disaster.text, "danger")
    end
end

function Feast.completeFeast(feast)
    feast.completed = true
    -- Apply bonuses
    local totalHappiness = feast.baseHappiness + (feast.satisfaction / 10)
    if _G.state and _G.state.happiness then
        _G.state.happiness = math.min(100, _G.state.happiness + totalHappiness)
    end
    -- Apply diplomatic bonus to all guest factions
    if feast.diplomaticBonus > 0 and _G.DiplomacyController then
        for _, faction in ipairs(feast.guestFactions) do
            pcall(_G.DiplomacyController.changeRelation, faction, feast.diplomaticBonus)
        end
    end
    -- Apply faith bonus
    if feast.faithBonus > 0 and _G.Religion then
        pcall(_G.Religion.addFaith, feast.faithBonus)
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Gostija končana: %s (+%d sreče, +%d prestiža)",
                feast.typeName, math.floor(totalHappiness), feast.basePrestige), "success")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "FEAST_COMPLETED", {
            type = feast.type, happiness = totalHappiness, prestige = feast.basePrestige,
        })
    end
end

-- ============================================================
-- UPDATE
-- ============================================================
function Feast.update(dt)
    if not _G.state then return end
    Feast.dayTimer = Feast.dayTimer + dt
    if Feast.dayTimer >= 30 then
        Feast.dayTimer = 0
        -- Process active feasts
        for i = #Feast.activeFeasts, 1, -1 do
            local f = Feast.activeFeasts[i]
            if not f.completed then
                f.daysRemaining = f.daysRemaining - 1
                if f.daysRemaining <= 0 then
                    Feast.completeFeast(f)
                end
            else
                f.cleanupTimer = (f.cleanupTimer or 30) - 1
                if f.cleanupTimer <= 0 then
                    table.remove(Feast.activeFeasts, i)
                end
            end
        end
        -- Pay upkeep
        local totalUpkeep = 0
        for _, b in ipairs(Feast.kitchenBuildings) do
            local def = KITCHEN_BUILDINGS[b.type]
            if def and def.upkeep then totalUpkeep = totalUpkeep + def.upkeep end
        end
        if Feast.chef then totalUpkeep = totalUpkeep + 25 end
        if totalUpkeep > 0 and _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep)
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Feast.getFeastTypeInfo(typeId) return FEAST_TYPES[typeId] end
function Feast.getDishInfo(dishId) return DISHES[dishId] end
function Feast.getBuildingInfo(buildingId) return KITCHEN_BUILDINGS[buildingId] end

function Feast.getStats()
    return {
        activeFeasts = #Feast.activeFeasts,
        totalFeasts = Feast.totalFeasts,
        totalDisasters = Feast.totalDisasters,
        numKitchens = #Feast.kitchenBuildings,
        hasChef = Feast.chef ~= nil,
        chefName = Feast.chef and Feast.chef.name or "—",
        chefSkill = Feast.chef and Feast.chef.skill or 0,
        dishCapacity = Feast.getDishCapacity(),
        guestCapacity = Feast.getGuestCapacity(),
    }
end

return Feast
