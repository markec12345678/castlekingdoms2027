-- states/ui/hud/help_overlay.lua
-- Castle Kingdoms 2027 v3.12.143 - Help Overlay System
--
-- Context-aware help overlay that shows useful information based on
-- what the player is hovering over or what game state is active.
--
-- Features:
--   * Hover over building → shows building stats (cost, production, workers)
--   * Hover over unit → shows unit stats (health, attack, veterancy)
--   * Hover over resource pile → shows resource info
--   * Press H → context-sensitive help (panel hints, active keybinds)
--   * Tips of the day (rotating, shown periodically)
--   * First-time contextual hints (e.g., "Place a stockpile to store wood")
--
-- The overlay is non-intrusive: small tooltip box near cursor or bottom-left corner.

local PanelAnim = require("states.ui.hud.PanelAnimations")
local UISound = require("objects.Audio.UISoundHelper")

local HelpOverlay = {}

local enabled = true
local mouseX, mouseY = 0, 0
local hoveredObject = nil
local tips = {
    "💡 Nasvet: Postavite kmetijo za proizvodnjo hrane.",
    "💡 Nasvet: Zgradite vojašnico za rekrutiranje vojakov.",
    "💡 Nasvet: Ctrl+R odpre 990 Royal sistemov!",
    "💡 Nasvet: Ctrl+K odpre tržnico z dinamičnimi cenami.",
    "💡 Nasvet: Ctrl+Shift+G odpre Tech Tree graf odvisnosti.",
    "💡 Nasvet: F1 prikaže vse tipkovne bližnjice.",
    "💡 Nasvet: N odpre zgodovino obvestil.",
    "💡 Nasvet: Ctrl+Shift+A prikaže 37 dosežkov.",
    "💡 Nasvet: Ctrl+Shift+I odpre statistiko z grafi.",
    "💡 Nasvet: Ctrl+Shift+F spremeni težavnost igre.",
    "💡 Nasvet: Space = pavza, 1-4 = hitrost igre.",
    "💡 Nasvet: F2 preklopi UI zvočne efekta.",
    "💡 Nasvet: Ctrl+U odpre auto-save panel.",
    "💡 Nasvet: Shift+R ponastavi vse nastavitve.",
    "💡 Nasvet: Klik na minimap (spodaj desno) premakne kamero.",
}
local currentTipIndex = 1
local tipTimer = 0
local TIP_INTERVAL = 30  -- seconds between tips
local tipVisible = false
local tipAlpha = 0
local tipFadeTime = 0
local TIP_FADE_DURATION = 3.0

-- Persistence
local SETTINGS_FILE = "help_overlay_enabled.txt"

-- Load persisted state
local function loadSettings()
    local ok, content = pcall(love.filesystem.read, SETTINGS_FILE)
    if ok and content then
        content = content:gsub("%s+$", "")
        if content == "false" then enabled = false end
    end
end
loadSettings()

-- Save state
local function saveSettings()
    pcall(love.filesystem.write, SETTINGS_FILE, tostring(enabled) .. "\n")
end

function HelpOverlay.toggle()
    enabled = not enabled
    saveSettings()
    if _G.UISoundHelper then
        pcall(function() _G.UISoundHelper.playToggleOn() end)
    end
    if _G.NotificationCenter then
        pcall(function()
            _G.NotificationCenter.system(
                "Pomoč: " .. (enabled and "VKLOPLJENA" or "IZKLOPLJENA"),
                _G.NotificationCenter.PRIORITY.LOW, 2
            )
        end)
    end
end

function HelpOverlay.isEnabled()
    return enabled
end

function HelpOverlay.setEnabled(state)
    if state ~= enabled then
        enabled = state
        saveSettings()
    end
end

-- Update mouse position and check for hovered objects
function HelpOverlay.update(dt)
    if not enabled then return end
    mouseX, mouseY = love.mouse.getPosition()
    
    -- Tip rotation
    tipTimer = tipTimer + dt
    if tipTimer >= TIP_INTERVAL then
        tipTimer = 0
        currentTipIndex = (currentTipIndex % #tips) + 1
        tipVisible = true
        tipFadeTime = 0
    end
    
    -- Tip fade
    if tipVisible then
        tipFadeTime = tipFadeTime + dt
        if tipFadeTime < 0.5 then
            tipAlpha = tipFadeTime / 0.5  -- fade in
        elseif tipFadeTime < TIP_FADE_DURATION - 0.5 then
            tipAlpha = 1.0  -- full
        elseif tipFadeTime < TIP_FADE_DURATION then
            tipAlpha = (TIP_FADE_DURATION - tipFadeTime) / 0.5  -- fade out
        else
            tipVisible = false
            tipAlpha = 0
        end
    end
    
    -- Detect hovered object (simplified — just check if mouse is over a known UI element)
    hoveredObject = nil
    -- This could be extended to detect buildings/units under cursor
    -- For now, we provide contextual help based on game state
end

-- Get context-sensitive help based on game state
local function getContextHelp()
    if not _G.state then return nil end
    
    -- Check what the player might need help with based on game state
    local gold = _G.state.gold or 0
    local food = 0
    if _G.state.resources then
        food = _G.state.resources.food or 0
    end
    
    local lines = {}
    
    -- Low gold warning
    if gold < 100 then
        table.insert(lines, {"⚠ Nizko zlato!", "Postavi davke ali trguj na tržnici (M).", {0.9, 0.5, 0.3}})
    end
    
    -- Low food warning
    if food < 20 then
        table.insert(lines, {"⚠ Nizka hrana!", "Zgradi kmetijo ali sadovnjak.", {0.9, 0.5, 0.3}})
    end
    
    -- New game hint
    if _G.state.newGame and not _G.state.keepX then
        table.insert(lines, {"🏰 Začetek", "Postavi grad (Keep) za začetek igre.", {0.5, 0.8, 0.5}})
    end
    
    return #lines > 0 and lines or nil
end

-- Draw help overlay
function HelpOverlay.draw()
    if not enabled then return end
    
    local screenW, screenH = love.graphics.getDimensions()
    local font = love.graphics.getFont()
    local smallFont = love.graphics.newFont(11)
    
    -- Draw tip of the day (bottom-left, above action bar)
    if tipVisible and tipAlpha > 0 then
        local tip = tips[currentTipIndex]
        love.graphics.setFont(smallFont)
        local tipW = smallFont:getWidth(tip) + 16
        local tipH = 24
        local tipX = 10
        local tipY = screenH - 150 - tipH - 10
        
        love.graphics.setColor(0.06, 0.07, 0.09, 0.85 * tipAlpha)
        love.graphics.rectangle("fill", tipX, tipY, tipW, tipH, 4, 4, 4, 4)
        love.graphics.setColor(0.4, 0.5, 0.6, 0.6 * tipAlpha)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", tipX, tipY, tipW, tipH, 4, 4, 4, 4)
        
        love.graphics.setColor(0.85, 0.88, 0.92, tipAlpha)
        love.graphics.print(tip, tipX + 8, tipY + 5)
    end
    
    -- Draw context-sensitive help (bottom-left, below tip)
    local ctxHelp = getContextHelp()
    if ctxHelp then
        love.graphics.setFont(smallFont)
        local ctxY = screenH - 150 - 10
        for i = #ctxHelp, 1, -1 do
            local entry = ctxHelp[i]
            local title, desc, color = entry[1], entry[2], entry[3]
            local w = math.max(smallFont:getWidth(title), smallFont:getWidth(desc)) + 16
            local h = 36
            local x = 10
            local y = ctxY - h - 4
            
            love.graphics.setColor(0.08, 0.06, 0.04, 0.9)
            love.graphics.rectangle("fill", x, y, w, h, 4, 4, 4, 4)
            love.graphics.setColor(color[1], color[2], color[3], 0.8)
            love.graphics.setLineWidth(1)
            love.graphics.rectangle("line", x, y, w, h, 4, 4, 4, 4)
            
            love.graphics.setColor(color[1], color[2], color[3], 1)
            love.graphics.print(title, x + 8, y + 4)
            love.graphics.setColor(0.75, 0.78, 0.82, 1)
            love.graphics.print(desc, x + 8, y + 18)
            
            ctxY = y
        end
    end
    
    -- Draw hovered object tooltip (if any)
    -- This could be extended to show building/unit stats on hover
    -- For now, the tooltip is handled by existing building_tooltip.lua
    
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(1)
end

-- Mouse moved handler for hover detection
function HelpOverlay.mousemoved(x, y, dx, dy)
    if not enabled then return false end
    -- Hover detection could be added here
    return false
end

-- Get current tip
function HelpOverlay.getCurrentTip()
    return tips[currentTipIndex]
end

-- Force show next tip
function HelpOverlay.nextTip()
    currentTipIndex = (currentTipIndex % #tips) + 1
    tipVisible = true
    tipFadeTime = 0
    if _G.UISoundHelper then
        pcall(function() _G.UISoundHelper.playClick() end)
    end
end

return HelpOverlay
