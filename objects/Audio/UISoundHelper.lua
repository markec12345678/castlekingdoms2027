-- objects/Audio/UISoundHelper.lua
-- Castle Kingdoms 2027 v3.12.130 - Centralized UI Sound Helper
--
-- Provides semantic functions for triggering UI sound effects across all
-- modern panels (Tech Tree, Royal Systems, Market, Auto-Save, Keybind Help,
-- Toast History, Achievement, Stats).
--
-- All sounds are gated by _G.OPTIONS.UI_SFX_ENABLED (toggle with F2 key).
-- Volume is gated by _G.OPTIONS.SFX_VOLUME and MASTER_VOLUME (already in SFXLibrary).
--
-- Sound palette (defined in objects/Audio/SFXLibrary.lua → ui category):
--   button_click         — generic button click
--   button_hover         — generic button hover
--   menu_open            — panel opens (legacy name, kept for compat)
--   menu_close           — panel closes
--   tab_switch           — tab/button group change
--   search_focus         — search input gains focus
--   search_match         — search returns results
--   toggle_on            — feature toggled ON
--   toggle_off           — feature toggled OFF
--   achievement_common   — common achievement unlocked
--   achievement_rare     — rare achievement unlocked
--   achievement_epic     — epic achievement unlocked (fanfare)
--   achievement_legendary — legendary achievement unlocked (legendary fanfare)
--   error                — error beep
--   success              — success chime
--   notification         — generic notification
--
-- Usage:
--   local UISound = require("objects.Audio.UISoundHelper")
--   UISound.playPanelOpen()
--   UISound.playClick()
--   UISound.playAchievementUnlock("legendary")

local UISoundHelper = {}

-- v3.12.130: Persist UI_SFX_ENABLED state across sessions
local SETTINGS_FILE = "ui_sfx_enabled.txt"

-- Track last hover time to debounce (avoid sound spam when mousing over list)
local lastHoverTime = 0
local HOVER_DEBOUNCE = 0.05  -- 50ms minimum between hover sounds

-- Check if UI sounds are enabled
local function isEnabled()
    return _G.OPTIONS and _G.OPTIONS.UI_SFX_ENABLED ~= false
end

-- Internal: play a UI sound via SFXLibrary
local function play(soundName)
    if not isEnabled() then return end
    if not _G.SFXLibrary then return end
    pcall(function() _G.SFXLibrary.playUI(soundName) end)
end

-- ============================================================
-- SEMANTIC API
-- ============================================================

-- Panel opens/closes (triggered by toggle())
function UISoundHelper.playPanelOpen()
    play("menu_open")
end

function UISoundHelper.playPanelClose()
    play("menu_close")
end

-- Generic button click (any clickable button)
function UISoundHelper.playClick()
    play("button_click")
end

-- Button hover (debounced to prevent sound spam)
function UISoundHelper.playHover()
    local now = love.timer and love.timer.getTime() or 0
    if now - lastHoverTime < HOVER_DEBOUNCE then return end
    lastHoverTime = now
    play("button_hover")
end

-- Tab/button group change (cycle between tabs)
function UISoundHelper.playTabSwitch()
    play("tab_switch")
end

-- Search input gains focus
function UISoundHelper.playSearchFocus()
    play("search_focus")
end

-- Search returns at least one match
function UISoundHelper.playSearchMatch()
    play("search_match")
end

-- Search returns no matches (slightly different — use error)
function UISoundHelper.playSearchNoMatch()
    play("error")
end

-- Feature toggled ON (e.g. auto-save enable, depth filter on)
function UISoundHelper.playToggleOn()
    play("toggle_on")
end

-- Feature toggled OFF
function UISoundHelper.playToggleOff()
    play("toggle_off")
end

-- Generic error
function UISoundHelper.playError()
    play("error")
end

-- Generic success
function UISoundHelper.playSuccess()
    play("success")
end

-- Achievement unlock with rarity-based sound
function UISoundHelper.playAchievementUnlock(rarity)
    if not rarity then
        play("achievement_common")
        return
    end
    local soundName = "achievement_" .. rarity
    play(soundName)
end

-- Toast appeared (use 'notification' sound for non-critical, 'success' for high/critical)
function UISoundHelper.playToastAppear(priority)
    -- priority: 1=CRITICAL, 2=HIGH, 3=NORMAL, 4=LOW
    if priority == 1 then
        play("achievement_legendary")  -- most prominent
    elseif priority == 2 then
        play("success")
    else
        play("notification")
    end
end

-- Toast dismissed manually (click-to-dismiss)
function UISoundHelper.playToastDismiss()
    play("toggle_off")
end

-- ============================================================
-- SETTINGS (persistence)
-- ============================================================

-- Load UI_SFX_ENABLED state from persisted file (called on init)
function UISoundHelper.loadSettings()
    local ok, content = pcall(love.filesystem.read, SETTINGS_FILE)
    if ok and content then
        content = content:gsub("%s+$", "")
        if content == "false" then
            if _G.OPTIONS then _G.OPTIONS.UI_SFX_ENABLED = false end
        elseif content == "true" then
            if _G.OPTIONS then _G.OPTIONS.UI_SFX_ENABLED = true end
        end
    end
end

-- Save current UI_SFX_ENABLED state to persisted file
function UISoundHelper.saveSettings()
    local state = _G.OPTIONS and _G.OPTIONS.UI_SFX_ENABLED or true
    pcall(love.filesystem.write, SETTINGS_FILE, tostring(state) .. "\n")
end

-- Toggle UI_SFX_ENABLED and persist
-- @return boolean new state
function UISoundHelper.toggle()
    if not _G.OPTIONS then return false end
    _G.OPTIONS.UI_SFX_ENABLED = not _G.OPTIONS.UI_SFX_ENABLED
    UISoundHelper.saveSettings()
    -- Play a sound to confirm the new state (only if just turned ON)
    if _G.OPTIONS.UI_SFX_ENABLED then
        play("success")
    end
    return _G.OPTIONS.UI_SFX_ENABLED
end

-- Get current state
function UISoundHelper.isEnabled()
    return isEnabled()
end

-- Initialize on game load
function UISoundHelper.init()
    UISoundHelper.loadSettings()
    print("[UISoundHelper] Initialized — UI SFX: " .. (isEnabled() and "ON" or "OFF"))
end

return UISoundHelper
