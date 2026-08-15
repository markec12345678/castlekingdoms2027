-- states/ui/hud/autosave_panel.lua
-- Castle Kingdoms 2027 - Auto-Save UI Panel
--
-- Compact panel showing auto-save status:
--   * Time until next auto-save (progress bar)
--   * Last save info (when, what was saved)
--   * Royal stats from last save (royalSystems, products, events, etc.)
--   * Toggle enable/disable
--   * Force-save now button
--   * Interval adjustment (1/5/15/30 min presets)
--
-- Toggle with Ctrl+U. Click outside to close.

local AutoSaveSystem = require("objects.AutoSaveSystem")

local AutoSavePanel = {}

local visible = false
local actionMessage = ""
local actionMessageTime = 0

-- Click areas for buttons (rebuilt each draw)
local clickAreas = {}

function AutoSavePanel.toggle()
    visible = not visible
end

function AutoSavePanel.isVisible()
    return visible
end

function AutoSavePanel.update(dt)
    if not visible then return end
    if actionMessageTime > 0 then
        actionMessageTime = actionMessageTime - dt
        if actionMessageTime <= 0 then actionMessage = "" end
    end
end

local function showMessage(msg)
    actionMessage = msg
    actionMessageTime = 3.0
end

-- Register a clickable button area
local function registerClick(id, x, y, w, h, action)
    clickAreas[#clickAreas + 1] = { id = id, x = x, y = y, w = w, h = h, action = action }
end

-- Draw a button with hover/active states
local function drawButton(id, x, y, w, h, label, enabled, action)
    local mx, my = love.mouse.getPosition()
    local hovered = enabled and mx >= x and mx <= x + w and my >= y and my <= y + h
    local alpha = enabled and (hovered and 0.95 or 0.7) or 0.3

    love.graphics.setColor(0.3, 0.4, 0.6, alpha)
    love.graphics.rectangle("fill", x, y, w, h, 4, 4, 4, 4)
    love.graphics.setColor(0.5, 0.6, 0.8, enabled and 1 or 0.4)
    love.graphics.rectangle("line", x, y, w, h, 4, 4, 4, 4)

    love.graphics.setColor(0.95, 0.95, 0.95, enabled and 1 or 0.5)
    local font = love.graphics.getFont()
    local tw = font:getWidth(label)
    love.graphics.print(label, x + (w - tw) / 2, y + (h - font:getHeight()) / 2)

    if enabled then
        registerClick(id, x, y, w, h, action)
    end
end

function AutoSavePanel.draw()
    if not visible then return end
    clickAreas = {}

    local W = love.graphics.getWidth()
    local H = love.graphics.getHeight()

    -- Dim background
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, W, H)

    -- Panel
    local panelW = math.min(560, W - 80)
    local panelH = 480
    local panelX = (W - panelW) / 2
    local panelY = (H - panelH) / 2

    love.graphics.setColor(0.12, 0.14, 0.18, 1)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH, 8, 8, 8, 8)
    love.graphics.setColor(0.5, 0.7, 0.9, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", panelX, panelY, panelW, panelH, 8, 8, 8, 8)
    love.graphics.setLineWidth(1)

    local font = love.graphics.getFont()
    local titleFont = love.graphics.newFont(16)
    local smallFont = love.graphics.newFont(11)

    -- Title
    love.graphics.setFont(titleFont)
    love.graphics.setColor(0.9, 0.85, 0.5, 1)
    love.graphics.print("💾 SAMODEJNO SHRANJEVANJE", panelX + 16, panelY + 12)
    love.graphics.setFont(font)
    love.graphics.setColor(0.5, 0.6, 0.7, 1)
    if smallFont then love.graphics.setFont(smallFont) end
    love.graphics.print("Ctrl+U: zapri  |  click zunaj: zapri", panelX + 16, panelY + 36)
    love.graphics.setFont(font)

    local stats = AutoSaveSystem.getStats()
    local y = panelY + 60

    -- Status block
    love.graphics.setColor(0.2, 0.25, 0.35, 1)
    love.graphics.rectangle("fill", panelX + 16, y, panelW - 32, 60, 4, 4, 4, 4)
    love.graphics.setColor(0.95, 0.85, 0.5, 1)
    love.graphics.print("Status", panelX + 24, y + 6)

    love.graphics.setColor(0.85, 0.88, 0.9, 1)
    local statusStr = stats.enabled and "✓ VKLOPLJENO" or "✗ IZKLOPLJENO"
    love.graphics.print(string.format("Stanje: %s", statusStr), panelX + 24, y + 24)

    local intervalMin = stats.interval / 60
    love.graphics.print(string.format("Interval: %.0f min", intervalMin), panelX + 200, y + 24)

    if stats.enabled then
        local nextMin = math.floor(stats.nextSaveIn / 60)
        local nextSec = math.floor(stats.nextSaveIn % 60)
        love.graphics.print(string.format("Naslednji save čez: %dm %02ds", nextMin, nextSec),
            panelX + 24, y + 42)
    else
        love.graphics.setColor(0.7, 0.5, 0.5, 1)
        love.graphics.print("(avto-shranjevanje izklopljeno)", panelX + 24, y + 42)
    end

    y = y + 72

    -- Progress bar (visual countdown)
    if stats.enabled and stats.interval > 0 then
        local progress = 1 - (stats.nextSaveIn / stats.interval)
        local barW = panelW - 32
        local barH = 12
        love.graphics.setColor(0.1, 0.12, 0.16, 1)
        love.graphics.rectangle("fill", panelX + 16, y, barW, barH, 3, 3, 3, 3)
        -- Color shifts from green (just saved) to yellow (mid) to orange (almost due)
        local r, g, b
        if progress < 0.5 then r, g, b = 0.3, 0.85, 0.3
        elseif progress < 0.85 then r, g, b = 0.85, 0.85, 0.3
        else r, g, b = 0.95, 0.5, 0.2 end
        love.graphics.setColor(r, g, b, 0.9)
        love.graphics.rectangle("fill", panelX + 16, y, barW * progress, barH, 3, 3, 3, 3)
        love.graphics.setColor(0.5, 0.55, 0.6, 1)
        love.graphics.rectangle("line", panelX + 16, y, barW, barH, 3, 3, 3, 3)
    end
    y = y + 22

    -- Last save info
    love.graphics.setColor(0.95, 0.85, 0.5, 1)
    love.graphics.print("Zadnje shranjevanje", panelX + 16, y)
    y = y + 20

    love.graphics.setColor(0.2, 0.25, 0.35, 1)
    love.graphics.rectangle("fill", panelX + 16, y, panelW - 32, 90, 4, 4, 4, 4)

    love.graphics.setColor(0.85, 0.88, 0.9, 1)
    if stats.lastSaveTime and stats.lastSaveTime > 0 then
        local now = (love.timer and love.timer.getTime()) or 0
        local age = now - stats.lastSaveTime
        local ageStr
        if age < 60 then ageStr = string.format("%ds nazaj", math.floor(age))
        elseif age < 3600 then ageStr = string.format("%dm nazaj", math.floor(age / 60))
        else ageStr = string.format("%dh nazaj", math.floor(age / 3600)) end
        love.graphics.print(string.format("Čas: %s", ageStr), panelX + 24, y + 8)
        love.graphics.print(string.format("Število save-ov: %d", stats.saveCount or 0), panelX + 24, y + 26)
    else
        love.graphics.setColor(0.6, 0.6, 0.6, 1)
        love.graphics.print("(še ni bilo save-a)", panelX + 24, y + 8)
        love.graphics.setColor(0.85, 0.88, 0.9, 1)
    end

    -- Royal stats from last save
    local ls = stats.lastSaveStats or {}
    if ls.royalSystems and ls.royalSystems > 0 then
        if smallFont then love.graphics.setFont(smallFont) end
        love.graphics.setColor(0.7, 0.85, 0.7, 1)
        love.graphics.print(string.format("Royal: %d sistemov, %d produktov, %d dogodkov",
            ls.royalSystems or 0, ls.royalProducts or 0, ls.marketEvents or 0),
            panelX + 24, y + 46)
        love.graphics.setColor(0.7, 0.8, 0.9, 1)
        love.graphics.print(string.format("Auto-sell: %s  |  Primerjava: %d  |  Verzija: v%d",
            ls.autoSellEnabled and "ON" or "OFF",
            ls.comparisonItems or 0,
            ls.saveVersion or 0),
            panelX + 24, y + 62)
        love.graphics.setFont(font)
    else
        if smallFont then love.graphics.setFont(smallFont) end
        love.graphics.setColor(0.6, 0.6, 0.6, 1)
        love.graphics.print("(Royal statistika bo prikazana po prvem save-u)", panelX + 24, y + 46)
        love.graphics.setFont(font)
    end
    y = y + 102

    -- Action buttons
    love.graphics.setColor(0.95, 0.85, 0.5, 1)
    love.graphics.print("Akcije", panelX + 16, y)
    y = y + 22

    local btnW = 140
    local btnH = 28
    local gap = 8

    -- Toggle enable/disable
    local toggleLabel = stats.enabled and "Izklopi" or "Vklopi"
    drawButton("toggle", panelX + 16, y, btnW, btnH, toggleLabel, true, function()
        AutoSaveSystem.setEnabled(not stats.enabled)
        showMessage(stats.enabled and "Auto-save VKLOPLJEN" or "Auto-save IZKLOPLJEN")
    end)

    -- Force save now
    drawButton("force", panelX + 16 + btnW + gap, y, btnW, btnH, "Shrani zdaj", true, function()
        AutoSaveSystem.forceSave()
        showMessage("Save sprožen - izvedba naslednji frame")
    end)

    -- Reset overlay position (Castle Kingdoms 2027 v3.11.926)
    drawButton("resetPos", panelX + 16 + 2 * (btnW + gap), y, btnW, btnH, "Reset pozicije", true, function()
        local AutoSaveOverlay = require("states.ui.hud.autosave_status_overlay")
        AutoSaveOverlay.resetPosition()
        showMessage("Pozicija overlay-a resetirana (zgornji desni kot)")
    end)
    y = y + btnH + gap

    -- Interval presets
    love.graphics.setColor(0.95, 0.85, 0.5, 1)
    love.graphics.print("Interval (min)", panelX + 16, y)
    y = y + 20

    local intervals = {60, 300, 900, 1800}  -- 1, 5, 15, 30 min
    local intervalLabels = {"1 min", "5 min", "15 min", "30 min"}
    for i, secs in ipairs(intervals) do
        local isCurrent = (stats.interval == secs)
        local label = intervalLabels[i] .. (isCurrent and " ✓" or "")
        drawButton("interval_" .. i, panelX + 16 + (i - 1) * (btnW + gap), y, btnW, btnH, label,
            not isCurrent,  -- disable current
            function()
                AutoSaveSystem.setInterval(secs)
                showMessage("Interval nastavljen na " .. intervalLabels[i])
            end)
    end
    y = y + btnH + gap + 12

    -- Action feedback message
    if actionMessage ~= "" then
        love.graphics.setColor(0, 0, 0, 0.7)
        local msgW = font:getWidth(actionMessage) + 20
        love.graphics.rectangle("fill", panelX + (panelW - msgW) / 2, panelY + panelH - 36, msgW, 24, 4, 4, 4, 4)
        love.graphics.setColor(1, 0.95, 0.7, 1)
        love.graphics.print(actionMessage, panelX + (panelW - font:getWidth(actionMessage)) / 2, panelY + panelH - 30)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function AutoSavePanel.mousepressed(x, y, button, istouch, presses)
    if not visible then return false end
    -- Click outside panel closes
    local W = love.graphics.getWidth()
    local H = love.graphics.getHeight()
    local panelW = math.min(560, W - 80)
    local panelH = 480
    local panelX = (W - panelW) / 2
    local panelY = (H - panelH) / 2
    if x < panelX or x > panelX + panelW or y < panelY or y > panelY + panelH then
        AutoSavePanel.toggle()
        return true
    end
    -- Check button clicks
    for _, area in ipairs(clickAreas) do
        if x >= area.x and x <= area.x + area.w and y >= area.y and y <= area.y + area.h then
            if area.action then area.action() end
            return true
        end
    end
    return false
end

function AutoSavePanel.keypressed(key, scancode, isrepeat)
    if not visible then return false end
    -- Ctrl+U toggles off
    if key == "u" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        AutoSavePanel.toggle()
        return true
    end
    -- Escape closes
    if key == "escape" then
        AutoSavePanel.toggle()
        return true
    end
    return false
end

return AutoSavePanel
