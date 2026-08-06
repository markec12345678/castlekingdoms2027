-- objects/UI/RightClickDismiss.lua
-- Stronghold 2027 - Right-Click Dismiss
-- Right-clicking anywhere closes the topmost open panel

local RightClickDismiss = {}

local initialized = false

-- Panels that can be dismissed (checked in priority order)
local dismissiblePanels = {}

function RightClickDismiss.init()
    if initialized then return end
    initialized = true
    print("[RightClickDismiss] Initialized (right-click to close panels)")
end

-- Register a panel as dismissible
function RightClickDismiss.register(name, isVisibleFunc, hideFunc)
    table.insert(dismissiblePanels, {
        name = name,
        isVisible = isVisibleFunc,
        hide = hideFunc,
    })
end

-- Handle right-click — dismiss topmost visible panel
function RightClickDismiss.handleRightClick(x, y, button)
    if not initialized or button ~= 2 then return false end

    -- Check panels in reverse order (topmost first)
    for i = #dismissiblePanels, 1, -1 do
        local panel = dismissiblePanels[i]
        local visible = false
        pcall(function() visible = panel.isVisible() end)

        if visible then
            pcall(panel.hide)
            if _G.SFXLibrary then
                _G.SFXLibrary.playUI("menu_close")
            end
            print("[RightClickDismiss] Closed: " .. panel.name)
            return true
        end
    end

    return false
end

-- Auto-register all known panels
function RightClickDismiss.autoRegister()
    -- Diplomacy panel
    pcall(function()
        local DiplomacyPanel = require("states.ui.multiplayer.diplomacy_panel")
        RightClickDismiss.register("DiplomacyPanel",
            function() return DiplomacyPanel.isVisible() end,
            function() DiplomacyPanel.hide() end)
    end)

    -- Achievement gallery
    pcall(function()
        local AchievementGallery = require("states.ui.hud.achievement_gallery")
        RightClickDismiss.register("AchievementGallery",
            function() return AchievementGallery.isVisible() end,
            function() AchievementGallery.hide() end)
    end)

    -- Unified settings
    pcall(function()
        local UnifiedSettings = require("states.ui.settings.unified_settings")
        RightClickDismiss.register("UnifiedSettings",
            function() return UnifiedSettings.isVisible() end,
            function() UnifiedSettings.hide() end)
    end)

    -- End game screen
    pcall(function()
        local EndGameScreen = require("states.ui.hud.end_game_screen")
        RightClickDismiss.register("EndGameScreen",
            function() return EndGameScreen.isVisible() end,
            function() EndGameScreen.hide() end)
    end)

    -- Game feel settings
    pcall(function()
        local GameFeelSettings = require("states.ui.settings.gamefeel_settings")
        RightClickDismiss.register("GameFeelSettings",
            function() return GameFeelSettings.isVisible() end,
            function() GameFeelSettings.toggle() end)
    end)

    -- Dynamic market UI
    pcall(function()
        local DynamicMarketUI = require("states.ui.economy.dynamic_market_ui")
        RightClickDismiss.register("DynamicMarketUI",
            function() return DynamicMarketUI.isVisible() end,
            function() DynamicMarketUI.toggle() end)
    end)

    -- Caravan UI
    pcall(function()
        local CaravanUI = require("states.ui.economy.caravan_ui")
        RightClickDismiss.register("CaravanUI",
            function() return CaravanUI.isVisible() end,
            function() CaravanUI.toggle() end)
    end)

    -- Keybind help
    pcall(function()
        local KeybindHelp = require("states.ui.hud.keybind_help")
        RightClickDismiss.register("KeybindHelp",
            function() return KeybindHelp.isVisible() end,
            function() KeybindHelp.toggle() end)
    end)

    print("[RightClickDismiss] Auto-registered " .. #dismissiblePanels .. " panels")
end

function RightClickDismiss.getRegisteredCount()
    return #dismissiblePanels
end

return RightClickDismiss
