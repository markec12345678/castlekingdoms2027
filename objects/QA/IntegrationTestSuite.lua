-- objects/QA/IntegrationTestSuite.lua
-- Castle Kingdoms 2027 - Integration Test Suite
-- Verifies all systems work together correctly

local IntegrationTestSuite = {}

local tests = {}

function IntegrationTestSuite.init()
    -- Register integration tests
    tests = {
        {
            name = "GameEventBus emit/receive",
            category = "Core",
            run = function()
                local EventBus = require("objects.Core.GameEventBus")
                local received = false
                local unsub = EventBus.on("test_event", function(data)
                    received = true
                end)
                EventBus.emit("test_event", {value = 42})
                unsub()
                return received
            end,
        },
        {
            name = "LocalizationSystem loads English",
            category = "Localization",
            run = function()
                local L10n = require("objects.Config.LocalizationSystem")
                L10n.init()
                L10n.setLanguage("eng")
                return L10n.getLanguage() == "eng"
            end,
        },
        {
            name = "AccessibilitySystem initializes",
            category = "Accessibility",
            run = function()
                local A11y = require("objects.Config.AccessibilitySystem")
                A11y.init()
                return A11y.getStats() ~= nil
            end,
        },
        {
            name = "ConfigProfiles loads profiles",
            category = "Config",
            run = function()
                local Profiles = require("objects.Config.ConfigProfileSystem")
                Profiles.init()
                local all = Profiles.getAllProfiles()
                return #all >= 4  -- At least Ultra, High, Medium, Low
            end,
        },
        {
            name = "DiplomacyController initializes",
            category = "Multiplayer",
            run = function()
                local Diplomacy = require("objects.Network.DiplomacyController")
                Diplomacy.init()
                Diplomacy.setMyPlayerId(1)
                local rel = Diplomacy.getRelation(1, 2)
                return rel == "neutral"
            end,
        },
        {
            name = "TradeController initializes",
            category = "Multiplayer",
            run = function()
                local Trade = require("objects.Network.TradeController")
                Trade.init()
                Trade.setMyPlayerId(1)
                return Trade.getPendingTrades() ~= nil
            end,
        },
        {
            name = "ModLoader scans directory",
            category = "Modding",
            run = function()
                local ModLoader = require("objects.Modding.ModLoader")
                ModLoader.init()
                local mods = ModLoader.scanMods()
                return #mods >= 1  -- At least sample_mod
            end,
        },
        {
            name = "SteamWorks initializes",
            category = "Steam",
            run = function()
                local SteamWorks = require("objects.Steam.SteamWorks")
                SteamWorks.init()
                local info = SteamWorks.getInfo()
                return info.initialized == true
            end,
        },
        {
            name = "AudioMixSystem initializes",
            category = "Audio",
            run = function()
                local AudioMix = require("objects.Audio.AudioMixSystem")
                AudioMix.init()
                local vols = AudioMix.getAllVolumes()
                return vols.master ~= nil and vols.sfx ~= nil
            end,
        },
        {
            name = "DynamicMusicManager initializes",
            category = "Audio",
            run = function()
                local DynamicMusic = require("objects.Audio.DynamicMusicManager")
                DynamicMusic.init()
                local info = DynamicMusic.getInfo()
                return info.state ~= nil
            end,
        },
        {
            name = "SFXLibrary initializes",
            category = "Audio",
            run = function()
                local SFX = require("objects.Audio.SFXLibrary")
                SFX.init()
                local stats = SFX.getStats()
                return stats.categories >= 3
            end,
        },
        {
            name = "VoiceOver initializes",
            category = "Audio",
            run = function()
                local VoiceOver = require("objects.Audio.SlovenianVoiceOver")
                VoiceOver.init()
                local info = VoiceOver.getInfo()
                return info.messageCount > 0
            end,
        },
        {
            name = "CrashHandler initializes",
            category = "QA",
            run = function()
                local CrashHandler = require("objects.QA.CrashHandler")
                CrashHandler.init()
                return CrashHandler.getSummary() ~= nil
            end,
        },
        {
            name = "PerformanceWatchdog initializes",
            category = "QA",
            run = function()
                local PerfWatchdog = require("objects.QA.PerformanceWatchdog")
                PerfWatchdog.init()
                local stats = PerfWatchdog.getStats()
                return stats.quality ~= nil
            end,
        },
        {
            name = "ReplaySystem initializes",
            category = "QA",
            run = function()
                local Replay = require("objects.QA.ReplaySystem")
                Replay.init()
                return Replay.getInfo() ~= nil
            end,
        },
        {
            name = "StatisticsDashboard initializes",
            category = "QA",
            run = function()
                local Stats = require("objects.QA.StatisticsDashboard")
                Stats.init()
                return Stats.getSessionStats() ~= nil
            end,
        },
        {
            name = "MapEditor initializes",
            category = "Tools",
            run = function()
                local MapEditor = require("objects.QA.MapEditor")
                MapEditor.init()
                return MapEditor.getInfo() ~= nil
            end,
        },
        {
            name = "TutorialSystem initializes",
            category = "UX",
            run = function()
                local Tutorial = require("objects.Tutorial.TutorialSystem")
                Tutorial.init()
                return Tutorial.getTotalSteps() == 10
            end,
        },
        {
            name = "CampaignStory initializes",
            category = "Content",
            run = function()
                local Story = require("objects.Mission.CampaignStorySystem")
                Story.init()
                return not Story.isActive()
            end,
        },
        {
            name = "SiegeWeapons initializes",
            category = "Combat",
            run = function()
                local Siege = require("objects.Combat.SiegeWeaponsSystem")
                Siege.init()
                return Siege.SIEGE_TYPES.catapult ~= nil
            end,
        },
        {
            name = "SaveCompat initializes",
            category = "QA",
            run = function()
                local SaveCompat = require("objects.QA.SaveGameCompatibility")
                SaveCompat.init()
                return SaveCompat.getVersion() > 0
            end,
        },
        {
            name = "DebugConsole initializes",
            category = "Tools",
            run = function()
                local Console = require("objects.QA.DebugConsoleSystem")
                Console.init()
                return Console.isVisible() == false
            end,
        },
        {
            name = "CommunityFeedback initializes",
            category = "QA",
            run = function()
                local Feedback = require("objects.QA.CommunityFeedbackSystem")
                Feedback.init()
                return Feedback.getCount() == 0
            end,
        },
        {
            name = "FinalBugFix safety check",
            category = "QA",
            run = function()
                local FinalBugFix = require("objects.QA.FinalBugFixPass")
                FinalBugFix.init()
                local results = FinalBugFix.runSafetyCheck()
                return results.passed > 0
            end,
        },
        {
            name = "GameEventBus integrateAll",
            category = "Core",
            run = function()
                local EventBus = require("objects.Core.GameEventBus")
                EventBus.integrateAll()
                local events = EventBus.getRegisteredEvents()
                return #events >= 5  -- At least 5 event types registered
            end,
        },
    }
end

function IntegrationTestSuite.runAll()
    if #tests == 0 then IntegrationTestSuite.init() end

    local results = {
        total = #tests,
        passed = 0,
        failed = 0,
        tests = {},
    }

    for _, test in ipairs(tests) do
        local ok, result = pcall(test.run)
        local passed = ok and result == true

        table.insert(results.tests, {
            name = test.name,
            category = test.category,
            passed = passed,
            error = not ok and tostring(result) or nil,
        })

        if passed then
            results.passed = results.passed + 1
        else
            results.failed = results.failed + 1
        end
    end

    return results
end

function IntegrationTestSuite.printResults()
    local results = IntegrationTestSuite.runAll()

    print("\n" .. string.rep("=", 60))
    print("INTEGRATION TEST SUITE RESULTS")
    print(string.rep("=", 60))
    print(string.format("Total: %d | Passed: %d | Failed: %d",
        results.total, results.passed, results.failed))
    print(string.rep("-", 60))

    local currentCategory = ""
    for _, test in ipairs(results.tests) do
        if test.category ~= currentCategory then
            currentCategory = test.category
            print("\n  [" .. currentCategory .. "]")
        end
        local status = test.passed and "PASS" or "FAIL"
        local line = string.format("  [%s] %s", status, test.name)
        if test.error then line = line .. " (" .. test.error:sub(1, 50) .. ")" end
        print(line)
    end

    print("\n" .. string.rep("=", 60))
    if results.failed == 0 then
        print("ALL INTEGRATION TESTS PASSED!")
    else
        print(string.format("%d TESTS FAILED", results.failed))
    end
    print(string.rep("=", 60))

    return results
end

return IntegrationTestSuite
