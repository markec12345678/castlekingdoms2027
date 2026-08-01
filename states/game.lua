local game = {}
local loveframes = require("libraries.loveframes")
local ActionBar = require("states.ui.ActionBar")
local states = require("states.ui.states")
local core = require("misc")
local thread, thread2, objects
---@type Terrain
local Terrain
require("shaders.postshader")
local renderLoadingScreen = require("states.ui.loading_screen")
local renderLoadingBar = require("states.ui.loading_bar")
local loadState, progress = 1, 15
local SaveManager = require("objects.Controllers.SaveManager")
local keybindManager = require("objects.Controllers.KeybindManager")
local EVENT = require("objects.Enums.KeyEvents")
-- Stronghold 2027 - Combat system integration
local CombatIntegration = require("objects.Combat.CombatIntegration")
local CombatTestScenario = require("objects.Combat.CombatTestScenario")
-- Stronghold 2027 - Immersion systems
local AnimationSystem = require("objects.Animation.AnimationSystem")
local SoundSystem = require("objects.Audio.SoundSystem")
local WeatherSystem = require("objects.Weather.WeatherSystem")
local ModernUI = require("objects.UI.ModernUISystem")
local LightingSystem = require("objects.Environment.LightingSystem")
-- Stronghold 2027 - AI system
local AIIntegration = require("objects.AI.AIIntegration")
-- Stronghold 2027 - Economy systems
local DynamicMarket = require("objects.Economy.DynamicMarketSystem")
local SeasonalSystem = require("objects.Economy.SeasonalSystem")
local EconomicEvents = require("objects.Economy.EconomicEventsSystem")
local TradeCaravans = require("objects.Economy.TradeCaravanSystem")
-- Stronghold 2027 - Mission framework
local MissionFramework = require("objects.Mission.MissionFramework")
-- Stronghold 2027 - Economy UI
local DynamicMarketUI = require("states.ui.economy.dynamic_market_ui")
local CaravanUI = require("states.ui.economy.caravan_ui")
-- Stronghold 2027 - HUD widgets
local SeasonWidget = require("states.ui.hud.season_info_widget")
local EventLog = require("states.ui.hud.economic_event_log")
-- Stronghold 2027 - Performance profiling
local PerformanceManager = require("objects.Performance.PerformanceManager")
local PriorityUpdate = require("objects.Performance.PriorityUpdateSystem")
local AITickOptimizer = require("objects.Performance.AITickOptimizer")
local MemoryProfiler = require("objects.Performance.MemoryProfiler")
local PerformanceOverlay = require("states.ui.hud.performance_overlay")
-- Stronghold 2027 - Game feel feedback
local GameFeel = require("objects.Feedback.GameFeelSystem")
local BuildPreview = require("objects.Feedback.BuildPreviewSystem")
local SelectionFeedback = require("objects.Feedback.SelectionFeedbackSystem")
local savegame
local playlist = require("sounds.music_playlist")
local RationController
local groupTypeMarket = require("states.ui.market.market_trade_main")
local ArmouryUI = require("states.ui.armoury.armoury_ui")
local _, MarketUI = unpack(require("states.ui.market.market_trade"))
local BarracksUI = require("states.ui.barracks.units_recruitment")
local GuildsUI = require("states.ui.guilds.guild_ui")
local WorkshopsUI = require("states.ui.workshops.workshops_ui")
local UnitsUI = require("states.ui.units.units_control")
local UnitDetails = require("states.ui.unit_details.unit_details")
local console = require "libraries.console"

local function updateProgress(prgs, lState)
    progress = prgs or progress
    loadState = lState or loadState
    game:draw()
    love.graphics.present()
end

local function delayedInit()
    updateProgress(20)
    objects = love.filesystem.load("objects/objects.lua")(objectAtlas)
    package.loaded["objects.objects"] = objects
    updateProgress(30)
    _G.BrushController = require("objects.Controllers.BrushController")
    _G.DestructionController = require("objects.Controllers.DestructionController"):new()
    _G.SleepController = require("objects.Controllers.SleepController"):new()
    RationController = require("objects.Controllers.RationController")
    _G.AleController = require("objects.Controllers.AleController")
    _G.ReligionController = require("objects.Controllers.ReligionController")
    _G.HerdController = require("objects.Controllers.HerdController")
    _G.TaxController = require("objects.Controllers.TaxController")
    _G.TimeController = require("objects.Controllers.TimeController")
    _G.MissionController = require("objects.Controllers.MissionController")
    _G.PopularityController = require("objects.Controllers.PopularityController")
    _G.ScribeController = require("objects.Controllers.ScribeController")
    _G.BuildController = love.filesystem.load("objects/Controllers/BuildController.lua")(
        package.loaded["objects.objects"].object, objectAtlas)
    _G.JobController = require("objects.Controllers.JobController")
    _G.BuildingManager = require("objects.Controllers.BuildingManager")
    _G.Commander = require("objects.Controllers.Commander")
    _G.ArrowController = require("objects.Controllers.ArrowController")
    _G.DebugView = require("objects.Controllers.DebugView")
    updateProgress(35)
    ----Pathfinding setup
    updateProgress(40)
    _G.finder = require("objects.Controllers.PathController")
    _G.state.newGame = savegame == "map_Fernhaven" or savegame == "map_Grasslands"
    if _G.state.newGame then
        if savegame == "map_Grasslands" then
            _G.state.viewYview = -50
            _G.state:allocateMeshes()
            for i = 0, _G.chunksWide - 1 do
                for o = 0, _G.chunksHigh - 1 do -- usually both are 32 (jumper is set like that with magic numbers)
                    _G.state.Terrain:genTerrain(i, o)
                end
            end
            _G.channel.mapUpdate:push("final")
            _G.channel2.mapUpdate:push("final")
        else
            SaveManager:load(savegame)
        end
        updateProgress(70)
    else
        updateProgress(70, 3)
        SaveManager:load(savegame)
    end
    core.update()
    updateProgress(80, 4)
    objects.update(_G.dt)
    updateProgress(90, 5)
    _G.state.Terrain:update()
    updateProgress(95)
    _G.BuildController:update()
    loveframes.update()
    _G.finder:update()
    updateProgress(97)
    _G.state.map:forceRefresh()
    _G.state.Terrain:update()
    updateProgress(100)
    love.timer.sleep(0.4)
    if _G.state.missionNr then
        _G.MissionController:setMissionState(_G.state.missionNr)
    end
    loveframes.SetState(states.STATE_INGAME_CONSTRUCTION)
    ActionBar:updateGoldCount()
    ActionBar:updatePopularityCount()
    _G.state:shadeBuildings()
    _G.loaded = true
    _G.speedModifier = 1
    -- Stronghold 2027: Initialize combat system
    CombatIntegration.init()
    -- Stronghold 2027: Initialize immersion systems
    SoundSystem.init()
    WeatherSystem.init()
    ModernUI.init()
    LightingSystem.init()
    -- Stronghold 2027: Initialize economy systems
    DynamicMarket.init()
    SeasonalSystem.init()
    EconomicEvents.init()
    TradeCaravans.init()
    -- Stronghold 2027: Initialize performance profiling
    PerformanceManager.init()
    PriorityUpdate.init()
    AITickOptimizer.init()
    MemoryProfiler.init()
    -- Stronghold 2027: Initialize game feel feedback
    GameFeel.init()
    BuildPreview.init()
    SelectionFeedback.init()
    -- Register globally for other systems to access
    _G.GameFeel = GameFeel
    _G.BuildPreview = BuildPreview
    _G.SelectionFeedback = SelectionFeedback
    ModernUI.notifySuccess("Stronghold 2027 loaded! Press F8 for combat test.")
    if _G.state.newGame then
        _G.playSpeech("place_a_keep")
        _G.BuildController.start = true
        ActionBar:showGroup("start")
        local buttons = require("states.ui.construction.level_1_new_game")
        buttons.castleButton:enable()
        buttons.stockpileButton:disable()
        buttons.granaryButton:disable()
    else
        ActionBar:showGroup("main")
    end
    _G.paused = false
    loveframes.SetState(states.STATE_INGAME_CONSTRUCTION)
end

function game:init()
end

local scrolledAmountWithinShortPeriod = 0
local scrollCountDown = 0.05
function game:update(dt)
    if (not _G.state or not _G.state.initialized) then
        delayedInit()
        _G.state.initialized = true
    else
        prof.push("core")
        ActionBar:animate()
        core.update()
        if scrollCountDown > 0 then
            scrollCountDown = scrollCountDown - love.timer.getDelta()
        elseif scrollCountDown < 0 then
            scrollCountDown = 0
            core.scale(scrolledAmountWithinShortPeriod)
        end
        prof.pop("core")
        if not _G.paused then
            local HighlightView = require("objects.Controllers.HighlightView")
            prof.push("objects")
            objects.update(dt)
            prof.pop("objects")
            _G.state.Terrain:update()
            prof.push("bcontr")
            HighlightView:update()
            _G.BuildController:update()
            _G.DebugView:update()
            _G.BrushController:update()
            if not _G.BuildController.start then
                _G.TimeController:update()
                RationController:update()
                _G.AleController:update()
                _G.ReligionController:update()
                _G.HerdController:update()
                _G.TaxController:update()
                _G.PopularityController:update()
                _G.ScribeController:update()
                _G.DestructionController:update()
                _G.SleepController:update()
                -- Stronghold 2027: Update combat system
                CombatIntegration.update(dt)
                -- Stronghold 2027: Update immersion systems
                AnimationSystem.updateAll(dt)
                SoundSystem.update(dt)
                WeatherSystem.update(dt)
                ModernUI.update(dt)
                LightingSystem.update(dt)
                -- Stronghold 2027: Update AI system (with profiling)
                PerformanceManager.beginSection("ai_update")
                AIIntegration.update(dt)
                PerformanceManager.endSection("ai_update")
                -- Stronghold 2027: Update economy systems (with profiling)
                PerformanceManager.beginSection("economy")
                DynamicMarket.update(dt)
                DynamicMarket.updateEvents()
                SeasonalSystem.update(dt)
                EconomicEvents.update(dt)
                TradeCaravans.update(dt)
                PerformanceManager.endSection("economy")
                -- Stronghold 2027: Update mission framework
                MissionFramework.update(dt)
                -- Stronghold 2027: Update economy UI
                DynamicMarketUI.update(dt)
                CaravanUI.update(dt)
                -- Stronghold 2027: Update HUD widgets
                SeasonWidget.update(dt)
                EventLog.update(dt)
                -- Stronghold 2027: Update performance profiling
                PerformanceManager.update(dt)
                MemoryProfiler.update(dt)
                AITickOptimizer.update(dt)
                -- Stronghold 2027: Update game feel feedback
                GameFeel.update(dt)
                BuildPreview.update(dt)
                SelectionFeedback.update(dt)
                -- Update selection box position while dragging
                if _G.Commander and _G.Commander.isDown then
                    local mx, my = love.mouse.getPosition()
                    SelectionFeedback.updateBox(mx, my)
                end
                _G.MissionStart = true
                if (loveframes.GetState() == states.STATE_ARMOURY) then
                    ArmouryUI.DisplayCurrentStock()
                end
                if (loveframes.GetState() == states.STATE_MARKET) then
                    MarketUI(groupTypeMarket.name)
                end
                if (loveframes.GetState() == states.STATE_BARRACKS) then
                    BarracksUI.DisplayCurrentStock()
                end
                if (loveframes.GetState() == states.STATE_GUILDS) then
                    GuildsUI.DisplayButtons()
                end
                if (loveframes.GetState() == states.STATE_INGAME_CONSTRUCTION) then
                    WorkshopsUI.CheckTooltip()
                end
            end
            prof.pop("bcontr")
        end
        prof.push("ui")
        loveframes.update()
        prof.pop("ui")
        prof.push("pathfind")
        _G.finder:update()
        prof.pop("pathfind")
        local error = _G.state.thread:getError()
        assert(not error, error)
        error = _G.state.thread2:getError()
        assert(not error, error)
        -- Stop playing main menu music at game start
        if _G.BuildController.start then
            if _G.CURRENT_MUSIC and _G.CURRENT_MUSIC:isPlaying() then
                love.audio.stop(_G.CURRENT_MUSIC)
                _G.CURRENT_MUSIC = nil
                _G.CURRENT_PLAYLIST_INDEX = 0
            end
        else
            playlist()
        end
    end
end

function game:enter(_, savegameName, w, h)
    love.graphics.setBackgroundColor(26 / 255, 26 / 255, 26 / 255, 1)
    savegame = savegameName
    collectgarbage()
    collectgarbage()
    _G.chunksWide, _G.chunksHigh = w, h
    if _G.loaded then
        _G.paused = false
        loveframes.SetState(states.STATE_INGAME_CONSTRUCTION)
    end
end

function game:draw()
    if not _G.testMode then
        if _G.loaded then
            local HighlightView = require("objects.Controllers.HighlightView")
            if _G.state.scaleX >= 2.1 or _G.paused then
                love.postshader.setBuffer("render")
            end
            love.graphics.push()
            love.graphics.translate((love.graphics.getWidth() / 2), (love.graphics.getHeight() / 2))
            objects.draw()
            if not _G.paused then
                HighlightView:draw()
                _G.BuildController:draw()
                _G.DebugView:draw()
                _G.BrushController:draw()
                _G.ArrowController:draw()
            end
            _G.Commander:draw()
            -- Stronghold 2027: Draw combat system (projectiles, damage numbers, health bars)
            CombatIntegration.draw()
            -- Stronghold 2027: Draw light sources (torches, fires)
            LightingSystem.drawLights()
            -- Stronghold 2027: Draw weather (rain, snow, fog)
            WeatherSystem.draw()
            love.graphics.pop()
            if _G.paused then
                love.postshader.addTiltshift(12)
            elseif _G.state.scaleX >= 2.1 then
                love.postshader.addTiltshift(4)
            end
            core.draw()
            prof.push("ui_draw")
            loveframes.draw()
            ActionBar:draw()
            prof.pop("ui_draw")
            if not _G.paused then
                _G.ScribeController:draw()
            end
            if _G.state.scaleX >= 2.1 or _G.paused then
                love.postshader.draw()
            end
            _G.Commander:drawMouse()
            if not _G.paused then
                local WallController = require("objects.Controllers.WallController")
                WallController:drawMouse()
            end
            console.draw()
            -- Stronghold 2027: Draw modern UI (tooltips, notifications)
            ModernUI.draw()
            -- Stronghold 2027: Draw mission UI (objectives, timer)
            MissionFramework.draw()
            -- Stronghold 2027: Draw economy UI (market, caravans)
            DynamicMarketUI.draw()
            CaravanUI.draw()
            -- Stronghold 2027: Draw HUD widgets (season, events)
            SeasonWidget.draw()
            EventLog.draw()
            -- Stronghold 2027: Draw performance overlay (F3/F4)
            PerformanceOverlay.draw()
            -- Stronghold 2027: Draw game feel feedback (selection rings, build preview)
            SelectionFeedback.draw()
            BuildPreview.draw()
        else
            renderLoadingScreen("")
            renderLoadingBar(loadState, progress)
            loveframes.draw()
        end
    end
end

function game:mousepressed(x, y, button, istouch)
    if not _G.loaded then return end
    if loveframes.mousepressed(x, y, button) then
        return
    end
    -- Stronghold 2027: Handle economy UI clicks first
    if DynamicMarketUI.isVisible() then
        if DynamicMarketUI.mousepressed(x, y, button) then return end
    end
    if CaravanUI.isVisible() then
        if CaravanUI.mousepressed(x, y, button) then return end
    end
    if _G.paused then return end
    if objects.mousepressed(x, y, button, istouch) then
        return
    end
    if _G.Commander:mousepressed(x, y, button) then
        return
    end
    if button == 2 then
        if not _G.BuildController.start then
            _G.BuildController:disable()
            local WallController = require("objects.Controllers.WallController")
            WallController.clicked = false
            if _G.BuildController.onBuildCallback then
                _G.BuildController.onBuildCallback()
                _G.BuildController.onBuildCallback = nil
            end
        end
        if not _G.BuildController.start and (loveframes.GetState() ~= states.STATE_INGAME_CONSTRUCTION or not ActionBar.hasSelectedButton) then
            if #_G.Commander.selectedUnits < 1 then
                ActionBar.lastCommand = nil
                ActionBar:switchMode()
            end
        else
            ActionBar:unselectAll()
        end
    end
    _G.BrushController:mousepressed(button)
end

function game:textinput(text)
    console.textinput(text)
end

function game:keypressed(key, scancode, isRepeat)
    if love.keyboard.isScancodeDown("`") and love.keyboard.isScancodeDown("lshift") then
        console:toggleEnable()
        return
    end
    if console.isEnabled() then
        console.keypressed(key, scancode, isRepeat)
        return
    end
    ActionBar:keypressed(key, scancode)

    local event = keybindManager:getEventForKeypress(key)

    -- Stronghold 2027: F8 = Toggle combat test scenario
    if key == "f8" then
        CombatTestScenario.activate()
        return
    end
    -- F9 = Print combat stats
    if key == "f9" then
        if CombatIntegration.isInitialized() then
            local stats = CombatIntegration.getStats()
            print("=== Combat Stats ===")
            print(string.format("Total attacks: %d", stats.totalAttacks))
            print(string.format("Total kills: %d", stats.totalKills))
            print(string.format("Total damage: %d", stats.totalDamage))
            print(string.format("Active projectiles: %d", stats.activeProjectiles))
            print(string.format("Visible health bars: %d", stats.visibleHealthBars))
            if stats.aiStats then
                print(string.format("AI units: %d", stats.aiStats.totalUnits))
            end
        end
        return
    end
    -- F7 = Spawn AI opponent (Stronghold 2027)
    if key == "f7" then
        if not _G.state or not _G.state.initialized then
            ModernUI.notifyError("Game not initialized")
            return
        end
        -- Find player's keep as reference
        local playerKeepX, playerKeepY = 50, 50
        if _G.state.gameObjectList then
            for _, obj in ipairs(_G.state.gameObjectList) do
                if obj.class and obj.class.name then
                    local name = obj.class.name
                    if (name == "Keep" or name == "WoodenKeep" or name == "SaxonHall")
                        and (not obj.faction or obj.faction == 1) then
                        playerKeepX, playerKeepY = obj.gx, obj.gy
                        break
                    end
                end
            end
        end
        -- Spawn AI at distance from player
        local personalities = {"aggressive", "balanced", "defensive", "economic"}
        local difficulties = {"easy", "medium", "hard"}
        local personality = personalities[math.random(#personalities)]
        local difficulty = difficulties[math.random(#difficulties)]
        local aiX = playerKeepX + math.random(30, 50)
        local aiY = playerKeepY + math.random(30, 50)
        AIIntegration.spawnAIFaction(personality, difficulty, aiX, aiY)
        ModernUI.notifySuccess(string.format("AI spawned! %s/%s at (%d, %d)",
            personality, difficulty, aiX, aiY))
        return
    end
    -- F10 = Print AI debug info (Stronghold 2027)
    if key == "f10" then
        AIIntegration.printDebugInfo()
        return
    end
    -- F11 = Print economy debug info (Stronghold 2027)
    if key == "f11" then
        print("\n=== Economy Debug Info ===")
        local marketStats = DynamicMarket.getStats()
        print(string.format("Inflation: %.3f", marketStats.inflation))
        print(string.format("Total gold in circulation: %d", marketStats.totalGold))
        print(string.format("Active events: %d", marketStats.activeEvents))
        print(string.format("Most volatile resource: %s (%.0f%%)", marketStats.mostVolatile, marketStats.maxVolatility * 100))

        local seasonInfo = SeasonalSystem.getSeasonInfo()
        print(string.format("\nSeason: %s (Year %d)", seasonInfo.nameSlv, seasonInfo.year))
        print(string.format("Time remaining: %.0fs", seasonInfo.timeRemaining))
        print(string.format("Next season: %s", SeasonalSystem.getNextSeason()))

        local eventStats = EconomicEvents.getStats()
        print(string.format("\nActive events: %d", eventStats.activeCount))
        print(string.format("History: %d events", eventStats.historyCount))

        local caravanStats = TradeCaravans.getStats()
        print(string.format("\nCaravans: %d active, %d completed", caravanStats.activeCount, caravanStats.completedCount))
        print(string.format("Success rate: %.0f%%", caravanStats.successRate * 100))
        print(string.format("Total profit: %d gold", caravanStats.totalProfit))
        print("=========================\n")
        return
    end
    -- F12 = Load campaign mission 1 (Stronghold 2027)
    if key == "f12" then
        local success = MissionFramework.loadMission("campaign.mission1_return_to_fernhaven")
        if success then
            MissionFramework.startMission()
            ModernUI.notifySuccess("Campaign mission loaded: Return to Fernhaven")
        else
            ModernUI.notifyError("Could not load mission")
        end
        return
    end
    -- M = Toggle dynamic market UI (Stronghold 2027)
    if key == "m" then
        DynamicMarketUI.toggle()
        return
    end
    -- C = Toggle caravan UI (Stronghold 2027)
    if key == "c" then
        CaravanUI.toggle()
        return
    end
    -- F5 = Cycle weather (Stronghold 2027)
    if key == "f5" then
        local weathers = {"clear", "rain", "heavy_rain", "fog", "snow", "storm"}
        local current = WeatherSystem.getCurrentWeather()
        local idx = 1
        for i, w in ipairs(weathers) do
            if w == current then idx = i; break end
        end
        local next = weathers[(idx % #weathers) + 1]
        WeatherSystem.setWeather(next)
        ModernUI.notifyInfo("Weather: " .. next)
        return
    end
    -- F6 = Cycle time of day (Stronghold 2027)
    if key == "f6" then
        local periods = {"dawn", "day", "dusk", "night"}
        local current = LightingSystem.getTimePeriod():lower()
        local idx = 1
        for i, p in ipairs(periods) do
            if p == current then idx = i; break end
        end
        local next = periods[(idx % #periods) + 1]
        LightingSystem.setTimePeriod(next)
        ModernUI.notifyInfo("Time: " .. next .. " (" .. LightingSystem.getTimeString() .. ")")
        return
    end

    if event == EVENT.Screenshot then
        -- Screenshot
        local filename = string.format("%s_%d.png", _G.version, os.time())
        love.graphics.captureScreenshot(filename)
        print(string.format("Screenshot [%s] saved in [%s]", filename, love.filesystem.getSaveDirectory()))
    elseif event == EVENT.IncreaseGameSpeed then
        if _G.speedModifier == 0.5 then
            _G.speedModifier = _G.speedModifier + 0.5
        elseif _G.speedModifier < 10 then
            _G.speedModifier = _G.speedModifier + 1
        end
    elseif event == EVENT.NormalizeGameSpeed then
        _G.speedModifier = 1
    elseif event == EVENT.DecreaseGameSpeed then
        if _G.speedModifier <= 1 then
            _G.speedModifier = _G.speedModifier - 0.5
        else
            _G.speedModifier = _G.speedModifier - 1
        end
        if _G.speedModifier < 0.5 then
            _G.speedModifier = 0.5
        end
    elseif event == EVENT.Escape then
        if _G.BuildController.start then
            if loveframes.GetState() ~= states.STATE_PAUSE_MENU then
                loveframes.SetState(states.STATE_PAUSE_MENU)
                loveframes.TogglePause()
                ActionBar:showGroup("start")
                return
            end
            if loveframes.GetState() == states.STATE_INGAME_CONSTRUCTION then
                loveframes.SetState(states.STATE_INGAME_CONSTRUCTION)
                loveframes.TogglePause()
                return
            end
        elseif (loveframes.GetState() == states.STATE_PAUSE_MENU or
                loveframes.GetState() == states.STATE_INGAME_CONSTRUCTION) then
            if _G.BuildController.active and not _G.BuildController.start then
                ActionBar:unselectAll()
                _G.BuildController:disable()
                return
            end
            if _G.DestructionController.active then
                -- unselect the demolish button
                ActionBar:unselectAll()
                _G.DestructionController:disable()
                return
            end
            if ActionBar.currentGroup ~= "main" then
                if not _G.BuildController.start then
                    ActionBar:showGroup("main")
                end
                return
            end
        elseif (loveframes.GetState() == states.STATE_MARKET or
                loveframes.GetState() == states.STATE_STOCKPILE or
                loveframes.GetState() == states.STATE_GRANARY or
                loveframes.GetState() == states.STATE_MARKET_MAIN or
                loveframes.GetState() == states.STATE_KEEP_TAX or
                loveframes.GetState() == states.STATE_ARMOURY or
                loveframes.GetState() == states.STATE_UNIT_DETAILS or
                loveframes.GetState() == states.STATE_UNITS or
                loveframes.GetState() == states.STATE_INN or
                loveframes.GetState() == states.STATE_RELIGION) then
            ActionBar:switchMode()
            return
        end
        loveframes.TogglePause()
    elseif event == EVENT.ToggleDebugView then
        _G.DebugView:toggle()
        -- Stronghold 2027: Toggle performance overlay with F3
        PerformanceOverlay.toggle()
    elseif event == EVENT.CenterViewToKeep and _G.state.keepX then
        _G.state.viewXview = _G.IsoToScreenX(_G.state.keepX, _G.state.keepY)
        _G.state.viewYview = _G.IsoToScreenY(_G.state.keepX, _G.state.keepY)
    elseif event == EVENT.CenterViewToGranary and _G.state.granaryX then
        _G.state.viewXview = _G.IsoToScreenX(_G.state.granaryX, _G.state.granaryY)
        _G.state.viewYview = _G.IsoToScreenY(_G.state.granaryX, _G.state.granaryY)
    end
end

function game:mousereleased(x, y, button, istouch)
    -- TODO: Check if event is consumed
    if _G.Commander:mousereleased(x, y, button) then
        return
    end
    loveframes.mousereleased(x, y, button)
    _G.BrushController:mousereleased(button)
end

function game:wheelmoved(x, y)
    if scrollCountDown == 0 then
        scrollCountDown = 0.05
        scrolledAmountWithinShortPeriod = y
    else
        scrolledAmountWithinShortPeriod = scrolledAmountWithinShortPeriod + y
    end
end

function game:keyreleased(key, scancode)
    if console.isEnabled() then
        return
    end
    -- if not _G.BuildController.start then
    if key == "b" then
        _G.BrushController:toggle()
    elseif key == "delete" then
        _G.DestructionController:toggle()
    end

    if _G.BrushController:activated() then
        _G.BrushController:keyReleased(key)
    end
    -- end
end

return game
