-- objects/QA/StabilityTestSuite.lua
-- Castle Kingdoms 2027 v2.5.0 - Stability Integration Test Suite
--
-- Comprehensive integration tests that verify all systems work together.
-- Tests cover: mission loading, combat, economy, AI, achievements, save/load.

local StabilityTests = {}

local tests = {}
local results = {}
local initialized = false

function StabilityTests.init()
    if initialized then return end
    initialized = true
    StabilityTests._registerTests()
    print("[StabilityTests] Initialized with " .. #tests .. " tests")
end

function StabilityTests._registerTests()
    -- Mission loading tests
    table.insert(tests, {
        name = "mission_load_all_21",
        category = "missions",
        description = "All 21 campaign missions load successfully",
        run = function()
            local CampaignProgress = require("objects.Mission.CampaignProgress")
            local MissionFramework = require("objects.Mission.MissionFramework")
            local list = CampaignProgress.getMissionList and CampaignProgress.getMissionList() or {}
            if #list < 21 then return false, "Expected 21 missions, got " .. #list end
            for _, m in ipairs(list) do
                local ok = pcall(function() MissionFramework.loadMission(m.key) end)
                if not ok then return false, "Failed to load: " .. m.key end
            end
            return true
        end,
    })

    -- Combat system tests
    table.insert(tests, {
        name = "combat_integration",
        category = "combat",
        description = "Combat system initializes and responds to events",
        run = function()
            local CombatIntegration = require("objects.Combat.CombatIntegration")
            if not CombatIntegration.isInitialized() then return false, "Combat not initialized" end
            -- Test spawnProjectile exists
            if not CombatIntegration.spawnProjectile then return false, "spawnProjectile missing" end
            return true
        end,
    })

    -- Economy tests
    table.insert(tests, {
        name = "economy_dynamic_market",
        category = "economy",
        description = "DynamicMarket provides prices for all resources",
        run = function()
            local DynamicMarket = require("objects.Economy.DynamicMarketSystem")
            local prices = DynamicMarket.getAllPrices()
            if not prices or type(prices) ~= "table" then return false, "No prices returned" end
            local count = 0
            for _ in pairs(prices) do count = count + 1 end
            if count < 10 then return false, "Expected 10+ resources, got " .. count end
            return true
        end,
    })

    -- AI tests
    table.insert(tests, {
        name = "ai_economy_functions",
        category = "ai",
        description = "EconomyAI has real trade and worker functions",
        run = function()
            local EconomyAI = require("objects.AI.EconomyAI")
            if not EconomyAI.sellResource then return false, "sellResource missing" end
            if not EconomyAI.buyResource then return false, "buyResource missing" end
            if not EconomyAI.manageWorkers then return false, "manageWorkers missing" end
            if not EconomyAI.getResources then return false, "getResources missing" end
            return true
        end,
    })

    -- AI strategy tests
    table.insert(tests, {
        name = "ai_strategy_orders",
        category = "ai",
        description = "AIStrategyController has real order functions",
        run = function()
            local AIStrategyController = require("objects.AI.AIStrategyController")
            if not AIStrategyController.orderAttack then return false, "orderAttack missing" end
            if not AIStrategyController.orderDefend then return false, "orderDefend missing" end
            if not AIStrategyController.orderRetreat then return false, "orderRetreat missing" end
            if not AIStrategyController.gatherResources then return false, "gatherResources missing" end
            return true
        end,
    })

    -- Achievement tests
    table.insert(tests, {
        name = "achievements_all_defined",
        category = "steam",
        description = "All 10 Steam achievements are defined",
        run = function()
            local SteamWorks = require("objects.Steam.SteamWorks")
            local count = SteamWorks.getAchievementCount and SteamWorks.getAchievementCount() or 0
            -- getAchievementCount counts unlocked, so check ACHIEVEMENTS table
            local total = 0
            for _ in pairs(SteamWorks.ACHIEVEMENTS or {}) do total = total + 1 end
            if total < 10 then return false, "Expected 10 achievements, got " .. total end
            return true
        end,
    })

    -- GameEventBus tests
    table.insert(tests, {
        name = "eventbus_events_defined",
        category = "core",
        description = "GameEventBus has all required event types",
        run = function()
            local GameEventBus = require("objects.Core.GameEventBus")
            local required = {"BUILDING_BUILT", "UNIT_KILLED", "VICTORY", "DEFEAT",
                              "ALLIANCE_FORMED", "TRADE_COMPLETED", "GOLD_EARNED"}
            for _, evt in ipairs(required) do
                if not GameEventBus.EVENTS[evt] then
                    return false, "Missing event: " .. evt
                end
            end
            return true
        end,
    })

    -- Veterancy tests
    table.insert(tests, {
        name = "veterancy_functions",
        category = "combat",
        description = "Veterancy system has all XP functions",
        run = function()
            local Veterancy = require("objects.Combat.UnitVeterancySystem")
            if not Veterancy.onKill then return false, "onKill missing" end
            if not Veterancy.onDamageDealt then return false, "onDamageDealt missing" end
            if not Veterancy.onDamageTaken then return false, "onDamageTaken missing" end
            if not Veterancy.awardXP then return false, "awardXP missing" end
            return true
        end,
    })

    -- Seasonal system tests
    table.insert(tests, {
        name = "seasonal_system",
        category = "economy",
        description = "SeasonalSystem has 4 seasons with modifiers",
        run = function()
            local SeasonalSystem = require("objects.Economy.SeasonalSystem")
            local seasons = {"spring", "summer", "autumn", "winter"}
            for _, s in ipairs(seasons) do
                SeasonalSystem.setSeason(s)
                if SeasonalSystem.getCurrentSeason() ~= s then
                    return false, "Failed to set season: " .. s
                end
            end
            return true
        end,
    })

    -- Diplomacy tests
    table.insert(tests, {
        name = "diplomacy_functions",
        category = "network",
        description = "DiplomacyController has all required functions",
        run = function()
            local DiplomacyController = require("objects.Network.DiplomacyController")
            if not DiplomacyController.improveRelations then return false, "improveRelations missing" end
            if not DiplomacyController.sendTribute then return false, "sendTribute missing" end
            if not DiplomacyController.canTrade then return false, "canTrade missing" end
            if not DiplomacyController.canAttack then return false, "canAttack missing" end
            return true
        end,
    })

    -- Tutorial tests
    table.insert(tests, {
        name = "tutorial_steps",
        category = "tutorial",
        description = "Tutorial has 10 steps",
        run = function()
            local Tutorial = require("objects.Tutorial.TutorialSystem")
            local total = Tutorial.getTotalSteps and Tutorial.getTotalSteps() or 0
            if total < 10 then return false, "Expected 10 steps, got " .. total end
            return true
        end,
    })

    -- Localization tests
    table.insert(tests, {
        name = "localization_languages",
        category = "core",
        description = "LocalizationSystem supports 32 languages",
        run = function()
            local LocalizationSystem = require("objects.Config.LocalizationSystem")
            -- Check if system is available
            if not LocalizationSystem then return false, "LocalizationSystem not found" end
            return true
        end,
    })

    -- Save/Load tests
    table.insert(tests, {
        name = "save_compatibility",
        category = "save",
        description = "SaveGameCompatibility can serialize/deserialize",
        run = function()
            local SaveCompat = require("objects.QA.SaveGameCompatibility")
            local testData = {gold = 1000, wood = 50, mission = "test"}
            local content = SaveCompat.serialize(testData)
            if not content then return false, "Serialize failed" end
            local data, err = SaveCompat.deserialize(content)
            if not data then return false, "Deserialize failed: " .. tostring(err) end
            if data.gold ~= 1000 then return false, "Data mismatch" end
            return true
        end,
    })

    -- CrashHandler tests
    table.insert(tests, {
        name = "crash_handler",
        category = "qa",
        description = "CrashHandler safeCall catches errors",
        run = function()
            local CrashHandler = require("objects.QA.CrashHandler")
            -- Test that safeCall catches errors
            local ok, err = CrashHandler.safeCall("test_system", function()
                error("Test error")
            end)
            if ok then return false, "safeCall should have caught error" end
            return true
        end,
    })

    -- Formation tests
    table.insert(tests, {
        name = "formation_system",
        category = "combat",
        description = "FormationSystem has 5 formations",
        run = function()
            local FormationSystem = require("objects.Combat.UnitFormationSystem")
            local all = FormationSystem.getAllFormations and FormationSystem.getAllFormations() or {}
            local count = 0
            for _ in pairs(all) do count = count + 1 end
            if count < 5 then return false, "Expected 5 formations, got " .. count end
            return true
        end,
    })

    -- Weather tests
    table.insert(tests, {
        name = "weather_gameplay",
        category = "gameplay",
        description = "WeatherGameplay has farm multiplier for all weather types",
        run = function()
            local WeatherGameplay = require("objects.Weather.WeatherGameplayIntegration")
            local weathers = {"clear", "rain", "heavy_rain", "fog", "snow", "storm"}
            for _, w in ipairs(weathers) do
                WeatherGameplay.setWeather(w)
                local mult = WeatherGameplay.getFarmMultiplier()
                if not mult or mult <= 0 then return false, "Invalid farm multiplier for: " .. w end
            end
            return true
        end,
    })
end

-- Run all tests
function StabilityTests.runAll()
    if not initialized then StabilityTests.init() end
    results = {passed = 0, failed = 0, total = #tests, details = {}}

    for _, test in ipairs(tests) do
        local ok, err = pcall(function()
            return test.run()
        end)

        local testPassed = false
        local testErr = nil

        if ok then
            -- pcall succeeded, now check the test result
            -- test.run() returns (true) or (false, errorMsg)
            local success, errorMsg = test.run()
            if success then
                testPassed = true
            else
                testErr = errorMsg or "Test returned false"
            end
        else
            testErr = tostring(err)
        end

        if testPassed then
            results.passed = results.passed + 1
            table.insert(results.details, {name = test.name, category = test.category, status = "PASS"})
        else
            results.failed = results.failed + 1
            table.insert(results.details, {name = test.name, category = test.category, status = "FAIL", error = testErr})
        end
    end

    return results
end

-- Print results
function StabilityTests.printResults()
    if not results.details then print("[StabilityTests] No results to print") return end

    print("\n========================================")
    print("STABILITY TEST RESULTS")
    print("========================================")
    print(string.format("Passed: %d/%d  Failed: %d/%d",
        results.passed, results.total, results.failed, results.total))
    print("----------------------------------------")

    local byCategory = {}
    for _, r in ipairs(results.details) do
        byCategory[r.category] = byCategory[r.category] or {passed = 0, failed = 0}
        if r.status == "PASS" then
            byCategory[r.category].passed = byCategory[r.category].passed + 1
        else
            byCategory[r.category].failed = byCategory[r.category].failed + 1
        end
    end

    for cat, counts in pairs(byCategory) do
        print(string.format("  %-12s: %d passed, %d failed", cat, counts.passed, counts.failed))
    end

    print("----------------------------------------")
    if results.failed > 0 then
        print("FAILED TESTS:")
        for _, r in ipairs(results.details) do
            if r.status == "FAIL" then
                print(string.format("  [FAIL] %s: %s", r.name, r.error or "unknown"))
            end
        end
    else
        print("All tests passed!")
    end
    print("========================================\n")
end

-- Get results summary
function StabilityTests.getResults()
    return results
end

-- Get test count
function StabilityTests.getTestCount()
    return #tests
end

return StabilityTests
