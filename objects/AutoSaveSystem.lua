-- objects/AutoSaveSystem.lua
-- Castle Kingdoms 2027 - Auto-Save System
--
-- Periodically saves game state to prevent progress loss.
-- - Auto-saves every 5 minutes (configurable)
-- - Shows notification when saving
-- - Keeps last 3 auto-saves (rotating)
-- - Can be disabled in settings

local AutoSaveSystem = {}

local initialized = false
local enabled = true
local saveTimer = 0
local saveInterval = 300  -- 5 minutes (seconds)
local lastSaveTime = 0
local saveCount = 0

-- Configuration
local config = {
    interval = 300,          -- 5 minutes
    maxAutoSaves = 3,        -- keep last 3
    showNotification = true,
    savePrefix = "autosave_",
}

function AutoSaveSystem.init()
    if initialized then return end
    initialized = true
    saveTimer = 0
    print("[AutoSave] Initialized - interval: " .. config.interval .. "s")
end

function AutoSaveSystem.setEnabled(state)
    enabled = state
end

function AutoSaveSystem.setEnabledFromSettings()
    local SettingsPersistence = require("objects.Config.SettingsPersistence")
    enabled = SettingsPersistence.get("autoSave") ~= false
end

function AutoSaveSystem.update(dt)
    if not initialized or not enabled then return end
    if not _G.state or not _G.state.initialized then return end
    if not _G.loaded then return end
    if _G.paused then return end

    saveTimer = saveTimer + dt

    if saveTimer >= config.interval then
        saveTimer = 0
        AutoSaveSystem.save()
    end
end

-- Perform auto-save
function AutoSaveSystem.save()
    saveCount = saveCount + 1
    lastSaveTime = love.timer.getTime()

    -- Generate save name (rotating)
    local slot = (saveCount % config.maxAutoSaves) + 1
    local saveName = config.savePrefix .. tostring(slot)

    print("[AutoSave] Saving to " .. saveName)

    -- Try to save using SaveManager
    if _G.state and _G.state.savename then
        local SaveManager = require("objects.Controllers.SaveManager")
        if SaveManager and SaveManager.save then
            local ok, err = pcall(SaveManager.save, SaveManager, saveName)
            if not ok then
                print("[AutoSave] Save error: " .. tostring(err))
            else
                -- Collect Royal system stats for diagnostic info
                AutoSaveSystem.lastSaveStats = AutoSaveSystem._collectRoyalStats()
            end
        end
    end

    -- Show notification
    if config.showNotification and _G.ModernUI then
        local stats = AutoSaveSystem.lastSaveStats or {}
        local msg = "Samodejno shranjevanje..."
        if stats.royalSystems and stats.royalSystems > 0 then
            msg = string.format("Shranjeno: %d Royal sistemov, %d produktov, %d dogodkov",
                stats.royalSystems or 0, stats.royalProducts or 0, stats.marketEvents or 0)
        end
        _G.ModernUI.notifyInfo(msg, 2)
    end

    -- Track campaign progress
    local CampaignProgress = require("objects.Mission.CampaignProgress")
    CampaignProgress.addPlaytime(config.interval)
    CampaignProgress.save()
end

-- Internal: collect Royal system stats for diagnostic display
-- Returns a table with counts of saved Royal subsystems' data
function AutoSaveSystem._collectRoyalStats()
    local stats = {
        royalSystems = 0,
        royalProducts = 0,
        marketEvents = 0,
        autoSellEnabled = false,
        comparisonItems = 0,
        saveVersion = 0,
    }
    -- Royal Systems count
    local ok1, Registry = pcall(require, "objects.Economy.RoyalSystemsRegistry")
    if ok1 and Registry then
        local systems = Registry.getSystems and Registry.getSystems() or {}
        stats.royalSystems = #systems
    end
    -- Royal products + market events
    local ok2, DM = pcall(require, "objects.Economy.DynamicMarketSystem")
    if ok2 and DM then
        local rpStats = DM.getRoyalStats and DM.getRoyalStats() or {}
        stats.royalProducts = rpStats.registeredProducts or 0
        local evStats = DM.getEventStats and DM.getEventStats() or {}
        stats.marketEvents = evStats.total or 0
    end
    -- Auto-sell state
    local ok3, RMI = pcall(require, "objects.Economy.RoyalMarketIntegration")
    if ok3 and RMI then
        local rmiStats = RMI.getStats and RMI.getStats() or {}
        stats.autoSellEnabled = rmiStats.autoSellEnabled or false
    end
    -- Comparison list count
    local ok4, MD = pcall(require, "states.ui.hud.market_dashboard")
    if ok4 and MD and MD.serialize then
        local md = MD.serialize()
        stats.comparisonItems = md.comparisonList and #md.comparisonList or 0
    end
    -- Save version
    local ok5, SV = pcall(require, "objects.Economy.SaveVersioner")
    if ok5 and SV then
        stats.saveVersion = SV.CURRENT_VERSION or 0
    end
    return stats
end

-- Force save now
function AutoSaveSystem.forceSave()
    saveTimer = config.interval  -- trigger save on next update
end

-- Get stats
function AutoSaveSystem.getStats()
    return {
        enabled = enabled,
        timer = saveTimer,
        interval = config.interval,
        nextSaveIn = math.max(0, config.interval - saveTimer),
        saveCount = saveCount,
        lastSaveTime = lastSaveTime,
        lastSaveStats = AutoSaveSystem.lastSaveStats or {},
    }
end

-- Set interval (in seconds)
function AutoSaveSystem.setInterval(seconds)
    config.interval = seconds or 300
end

function AutoSaveSystem.reset()
    saveTimer = 0
    saveCount = 0
end

return AutoSaveSystem
