-- objects/Economy/RoyalTaxCollectorRevenueSystem.lua
-- Castle Kingdoms 2027 v3.7.3 - Royal Tax Collector & Revenue System
--
-- Manages tax collection, revenue assessment, and audit operations.
-- Provides systematic revenue collection beyond the basic Treasury system.
--
-- Features:
-- - 6 tax collection methods (poll, land, property, trade, tithe, customs)
-- - 8 collection districts (capital, north, south, east, west, port, mining, frontier)
-- - 4 collector buildings (tax office, counting house, mint branch, royal exchequer)
-- - Tax Collector NPC (skill affects efficiency)
-- - District-based collection
-- - Tax evasion detection
-- - Revenue forecasting

local TaxCollector = {}

local METHODS = {
    poll = { name = "Glavarski davek", baseRate = 5, efficiency = 0.80, happiness = -3, description = "Davek na glavo." },
    land = { name = "Zemljiški davek", baseRate = 10, efficiency = 0.75, happiness = -2, description = "Davek na zemljo." },
    property = { name = "Premoženjski davek", baseRate = 8, efficiency = 0.70, happiness = -4, description = "Davek na premoženje." },
    trade = { name = "Trgovski davek", baseRate = 12, efficiency = 0.85, happiness = -1, description = "Carine na trgovino." },
    tithe = { name = "Desetina", baseRate = 10, efficiency = 0.90, happiness = -1, faith = 5, description = "Cerkveni davek." },
    customs = { name = "Carina", baseRate = 15, efficiency = 0.80, happiness = -2, description = "Carina na uvoz/izvoz." },
}

local DISTRICTS = {
    capital = { name = "Glavno mesto", population = 500, wealth = 100, description = "Prestolnica z visokim bogastvom." },
    north = { name = "Sever", population = 300, wealth = 60, description = "Hribovito območje." },
    south = { name = "Jug", population = 400, wealth = 80, description = "Plodna kmetijska zemlja." },
    east = { name = "Vzhod", population = 250, wealth = 50, description = "Gozdnato območje." },
    west = { name = "Zahod", population = 350, wealth = 70, description = "Mejno območje." },
    port = { name = "Pristanišče", population = 200, wealth = 120, description = "Bogato trgovsko pristanišče." },
    mining = { name = "Rudnik", population = 150, wealth = 90, description = "Rudarsko območje." },
    frontier = { name = "Meja", population = 100, wealth = 40, description = "Revno mejno območje." },
}

local BUILDINGS = {
    tax_office = { name = "Davčna pisarna", cost = { gold = 300, wood = 100, stone = 50 }, upkeep = 10, efficiencyBonus = 5, description = "Lokalna davčna pisarna." },
    counting_house = { name = "Računovodstvo", cost = { gold = 1000, wood = 200, stone = 200 }, upkeep = 25, efficiencyBonus = 15, description = "Osrednja računovodska ustanova." },
    mint_branch = { name = "Filiala kovnice", cost = { gold = 2000, wood = 300, stone = 400 }, upkeep = 40, efficiencyBonus = 25, prestigeBonus = 5, description = "Filiala kraljeve kovnice." },
    royal_exchequer = { name = "Kraljeva blagajna", cost = { gold = 5000, wood = 400, stone = 1000 }, upkeep = 80, efficiencyBonus = 40, prestigeBonus = 15, description = "Najvišja finančna ustanova." },
}

TaxCollector.buildings = {}
TaxCollector.collector = nil
TaxCollector.activeCollections = {}
TaxCollector.collectedRevenue = 0
TaxCollector.totalEvasionCaught = 0
TaxCollector.dayTimer = 0

function TaxCollector.init()
    TaxCollector.buildings = {}
    TaxCollector.collector = nil
    TaxCollector.activeCollections = {}
    TaxCollector.collectedRevenue = 0
    TaxCollector.totalEvasionCaught = 0
    TaxCollector.dayTimer = 0
    print("[TaxCollector] Royal Tax Collector & Revenue System initialized (6 methods, 8 districts, 4 buildings)")
end

function TaxCollector.hireCollector(name, skill)
    skill = skill or math.random(35, 80)
    local cost = 300 + skill * 5
    if not _G.state or (_G.state.gold or 0) < cost then return false, "Premalo zlata" end
    _G.state.gold = _G.state.gold - cost
    TaxCollector.collector = { name = name or ("Pobiralec " .. math.random(1, 99)), skill = skill, hiredDay = os.time(), collectionsMade = 0 }
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Davčni pobiralec najet: %s (spretnost: %d)", TaxCollector.collector.name, skill), "success") end
    return true
end

function TaxCollector.canBuild(id) local d = BUILDINGS[id]; if not d then return false, "Neznana zgradba" end; if not _G.state then return false, "Brez stanja" end; if _G.state.gold < (d.cost.gold or 0) then return false, "Premalo zlata" end; if _G.state.resources then for r,a in pairs(d.cost) do if r ~= "gold" and (_G.state.resources[r] or 0) < a then return false, "Premalo " .. r end end end; return true end
function TaxCollector.build(id) local ok,e = TaxCollector.canBuild(id); if not ok then return false, e end; local d = BUILDINGS[id]; _G.state.gold = _G.state.gold - (d.cost.gold or 0); if _G.state.resources then for r,a in pairs(d.cost) do if r ~= "gold" then _G.state.resources[r] = (_G.state.resources[r] or 0) - a end end end; table.insert(TaxCollector.buildings, {type = id, builtDay = os.time()}); if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. d.name, "success") end; return true end
function TaxCollector.getEfficiencyBonus() local b = 0; for _,bd in ipairs(TaxCollector.buildings) do local d = BUILDINGS[bd.type]; if d and d.efficiencyBonus then b = b + d.efficiencyBonus end end; return b end

function TaxCollector.canCollect(methodId, districtId)
    local mDef = METHODS[methodId]; local dDef = DISTRICTS[districtId]
    if not mDef or not dDef then return false, "Neznana metoda ali okrožje" end
    if #TaxCollector.buildings == 0 then return false, "Potrebna davčna zgradba" end
    if not TaxCollector.collector then return false, "Potreben pobiralec" end
    return true
end

function TaxCollector.collect(methodId, districtId)
    local ok, err = TaxCollector.canCollect(methodId, districtId)
    if not ok then return false, err end
    local mDef = METHODS[methodId]; local dDef = DISTRICTS[districtId]
    local efficiency = mDef.efficiency + (TaxCollector.getEfficiencyBonus() / 100)
    if TaxCollector.collector then efficiency = efficiency + (TaxCollector.collector.skill / 200) end
    efficiency = math.min(0.99, efficiency)
    local expectedRevenue = dDef.population * mDef.baseRate * dDef.wealth / 100
    local actualRevenue = math.floor(expectedRevenue * efficiency)
    -- Evasion detection
    local evasionChance = 0.15 - (TaxCollector.collector and TaxCollector.collector.skill / 500 or 0)
    evasionChance = math.max(0.02, evasionChance)
    local evasionCaught = false
    if math.random() < evasionChance then
        evasionCaught = true
        TaxCollector.totalEvasionCaught = TaxCollector.totalEvasionCaught + 1
        local penalty = math.floor(actualRevenue * 0.5)
        actualRevenue = actualRevenue + penalty
        if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Davčna utaja odkrita v %s! + %d zlata", dDef.name, penalty), "success") end
    end
    local collectTime = 5
    if TaxCollector.collector then collectTime = math.max(1, collectTime - math.floor(TaxCollector.collector.skill / 15)) end
    table.insert(TaxCollector.activeCollections, {
        id = "collect_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        methodId = methodId, methodName = mDef.name, districtId = districtId, districtName = dDef.name,
        expectedRevenue = expectedRevenue, actualRevenue = actualRevenue, evasionCaught = evasionCaught,
        happiness = mDef.happiness, faith = mDef.faith or 0,
        daysRemaining = collectTime, started = os.time(),
    })
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Davčna pobiranje: %s v %s (%d dni)", mDef.name, dDef.name, collectTime), "info") end
    return true
end

function TaxCollector.completeCollection(c)
    if _G.state then _G.state.gold = (_G.state.gold or 0) + c.actualRevenue end
    TaxCollector.collectedRevenue = TaxCollector.collectedRevenue + c.actualRevenue
    if _G.state and _G.state.happiness then _G.state.happiness = math.max(0, _G.state.happiness + c.happiness) end
    if c.faith > 0 and _G.Religion then pcall(_G.Religion.addFaith, c.faith) end
    if TaxCollector.collector then TaxCollector.collector.collectionsMade = TaxCollector.collector.collectionsMade + 1; if math.random() < 0.15 then TaxCollector.collector.skill = math.min(100, TaxCollector.collector.skill + 1) end end
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Davek pobran: %s — %s (+%d zlata)", c.methodName, c.districtName, c.actualRevenue), "success") end
end

function TaxCollector.update(dt)
    if not _G.state then return end
    TaxCollector.dayTimer = TaxCollector.dayTimer + dt
    if TaxCollector.dayTimer >= 30 then
        TaxCollector.dayTimer = 0
        for i = #TaxCollector.activeCollections, 1, -1 do
            local c = TaxCollector.activeCollections[i]
            c.daysRemaining = c.daysRemaining - 1
            if c.daysRemaining <= 0 then TaxCollector.completeCollection(c); table.remove(TaxCollector.activeCollections, i) end
        end
        local totalUpkeep = 0
        for _, bd in ipairs(TaxCollector.buildings) do local d = BUILDINGS[bd.type]; if d and d.upkeep then totalUpkeep = totalUpkeep + d.upkeep end end
        if TaxCollector.collector then totalUpkeep = totalUpkeep + 12 end
        if totalUpkeep > 0 and _G.state then _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep) end
    end
end

function TaxCollector.getMethodInfo(id) return METHODS[id] end
function TaxCollector.getDistrictInfo(id) return DISTRICTS[id] end
function TaxCollector.getBuildingInfo(id) return BUILDINGS[id] end
function TaxCollector.getStats()
    return { numBuildings = #TaxCollector.buildings, hasCollector = TaxCollector.collector ~= nil,
        collectorName = TaxCollector.collector and TaxCollector.collector.name or "—",
        collectorSkill = TaxCollector.collector and TaxCollector.collector.skill or 0,
        activeCollections = #TaxCollector.activeCollections,
        collectedRevenue = TaxCollector.collectedRevenue, totalEvasionCaught = TaxCollector.totalEvasionCaught }
end

return TaxCollector
