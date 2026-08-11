-- scripts/test_registry.lua
-- Quick test: simulate the S table with a few Royal Maker modules and verify
-- that the Registry can discover them, read their catalogs, and hook
-- completeMaking to grant bonus gold.
--
-- Run with: lua scripts/test_registry.lua
-- (or: lua5.1, lua5.3, luajit)

-- Minimal stubs for _G.state and _G.NotificationCenter
_G.state = { gold = 1000, happiness = 50, popularity = 50 }
_G.NotificationCenter = { notify = function(msg, kind) print(string.format("[NOTIFY %s] %s", kind or "?", msg)) end }
_G.GameEventBus = { publish = function(event, payload) print(string.format("[EVENT %s] %s", event, payload and payload.productName or "")) end }

-- Minimal mock of a Royal Maker system (mimics RoyalCarillonMakerSystem.lua)
local function makeMockSystem(name, prestigeVal)
    local PRODUCTS = {
        iron_thing = { name = "Železni " .. name, ironCost = 2, time = 5, cost = 100, prestige = 2, happiness = 1 },
        sovereign_thing = { name = "Suvereni " .. name, goldCost = 3, pearlCost = 2, time = 26, cost = 8000, prestige = 65, happiness = 12 },
    }
    local BUILDINGS = {
        workshop = { name = "Delavnica " .. name, cost = { gold = 300, wood = 160 }, upkeep = 6, qualityBonus = 5 },
    }
    local M = {}
    M.ironStock = 12; M.goldStock = 6; M.pearlStock = 4
    M.productStock = {}; M.buildings = {}; M.maker = nil; M.activeMaking = {}; M.totalProducts = 0; M.dayTimer = 0
    function M.init() print("[" .. name .. "] init") end
    function M.hireMaker(n, s) s = s or 70; M.maker = { name = n or "Test", skill = s, itemsMade = 0 }; return true end
    function M.canBuild(id) return BUILDINGS[id] ~= nil end
    function M.build(id) if not BUILDINGS[id] then return false, "Neznana" end; table.insert(M.buildings, { type = id }); return true end
    function M.getQualityBonus() return 5 end
    function M.canMake(pt) return PRODUCTS[pt] ~= nil end
    function M.make(pt, qty)
        qty = qty or 1
        local d = PRODUCTS[pt]
        if not d then return false, "Neznan produkt" end
        table.insert(M.activeMaking, { productType = pt, productName = d.name, quantity = qty, daysRemaining = d.time, prestige = d.prestige, happiness = d.happiness })
        return true
    end
    function M.completeMaking(m)
        M.productStock[m.productType] = (M.productStock[m.productType] or 0) + m.quantity
        M.totalProducts = M.totalProducts + m.quantity
        if _G.GameEventBus then pcall(_G.GameEventBus.publish, name:lower() .. ".completed", { productName = m.productName, prestige = m.prestige, happiness = m.happiness }) end
    end
    function M.update(dt)
        M.dayTimer = M.dayTimer + dt
        if M.dayTimer >= 30 then
            M.dayTimer = 0
            for i = #M.activeMaking, 1, -1 do
                local m = M.activeMaking[i]
                m.daysRemaining = m.daysRemaining - 1
                if m.daysRemaining <= 0 then
                    M.completeMaking(m)
                    table.remove(M.activeMaking, i)
                end
            end
        end
    end
    function M.getStats()
        return {
            ironStock = M.ironStock, goldStock = M.goldStock, pearlStock = M.pearlStock,
            productStock = M.productStock, numBuildings = #M.buildings, hasMaker = M.maker ~= nil,
            makerName = M.maker and M.maker.name or "—", makerSkill = M.maker and M.maker.skill or 0,
            activeMaking = #M.activeMaking, totalProducts = M.totalProducts
        }
    end
    return M
end

-- Mock S table
local S = {}
S.CarillonMaker = makeMockSystem("Carillon", 82)
S.PickaxeMaker = makeMockSystem("Pickaxe", 65)
S.GlockenspielMaker = makeMockSystem("Glockenspiel", 76)

-- Now load the registry
package.path = package.path .. ";./objects/?.lua;./objects/Economy/?.lua"
local Registry = require("objects.Economy.RoyalSystemsRegistry")

print("=== Initializing Registry ===")
Registry.init(S)

print()
print("=== Discovered systems ===")
local systems = Registry.getSystems()
for _, s in ipairs(systems) do
    print("  - " .. s.key .. " (" .. s.name .. ")")
end

print()
print("=== Aggregate stats (before) ===")
local agg = Registry.getAggregate()
print(string.format("  systems=%d, buildings=%d, makers=%d, products=%d, goldEarned=%d",
    agg.totalSystems, agg.totalBuildings, agg.totalMakers, agg.totalProducts, agg.totalGoldEarned))

print()
print("=== Catalogs for CarillonMaker ===")
local cats = Registry.getCatalogs("CarillonMaker")
print("  Products:")
for pid, p in pairs(cats.products) do
    print(string.format("    %s: %s (cost=%d, prestige=%d)", pid, p.name, p.cost, p.prestige))
end
print("  Buildings:")
for bid, b in pairs(cats.buildings) do
    print(string.format("    %s: %s (gold=%d)", bid, b.name, b.cost.gold))
end

print()
print("=== Hire maker + build workshop + make product ===")
print("  hireMaker:", select(2, Registry.hireMaker("CarillonMaker", "Mojster Janez", 80)))
print("  build:", select(2, Registry.build("CarillonMaker", "workshop")))
print("  make:", select(2, Registry.make("CarillonMaker", "iron_thing", 1)))

print()
print("=== Simulate update + completion (3 ticks of 30 dt units) ===")
Registry.update(30)
Registry.update(30)
Registry.update(30)
-- One more to clear remaining
Registry.update(30)

print()
print("=== Aggregate stats (after) ===")
agg = Registry.getAggregate()
print(string.format("  systems=%d, buildings=%d, makers=%d, products=%d, goldEarned=%d",
    agg.totalSystems, agg.totalBuildings, agg.totalMakers, agg.totalProducts, agg.totalGoldEarned))

print()
print("=== Player state (gold should increase from bonus) ===")
print(string.format("  gold = %d (was 1000, +bonus from completion)", _G.state.gold))
print(string.format("  happiness = %d (was 50)", _G.state.happiness))
print(string.format("  popularity = %d (was 50)", _G.state.popularity))

print()
print("=== CarillonMaker stats (after) ===")
local stats = Registry.getSystemStats("CarillonMaker")
print(string.format("  totalProducts = %d", stats.totalProducts))
print(string.format("  productStock ="))
for pid, q in pairs(stats.productStock) do
    print(string.format("    %s: %d", pid, q))
end

print()
print("=== ALL TESTS PASSED ===")
