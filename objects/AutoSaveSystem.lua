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
            end
        end
    end

    -- Show notification
    if config.showNotification and _G.ModernUI then
        _G.ModernUI.notifyInfo("Samodejno shranjevanje...", 2)
    end

    -- Track campaign progress
    local CampaignProgress = require("objects.Mission.CampaignProgress")
    CampaignProgress.addPlaytime(config.interval)
    CampaignProgress.save()
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
