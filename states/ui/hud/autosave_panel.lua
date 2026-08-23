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
local PanelAnim = require("states.ui.hud.PanelAnimations")
local UISound = require("objects.Audio.UISoundHelper")

local AutoSavePanel = {}

local visible = false
local actionMessage = ""
local actionMessageTime = 0
local sliderArea = nil  -- {x, y, w, h} set during draw
local sliderDragging = false

-- Click areas for buttons (rebuilt each draw)
local clickAreas = {}

-- v3.12.126: Panel animation state (fade-in/out + slide-up)
local animState = PanelAnim.createState({
    duration = 0.18,
    slideDir = "up",
    slideDist = 18,
    easing = "easeOut",
})

function AutoSavePanel.toggle()
    if not visible then
        visible = true
        PanelAnim.open(animState)
        UISound.playPanelOpen()
    else
        PanelAnim.close(animState)
        UISound.playPanelClose()
    end
end

function AutoSavePanel.isVisible()
    return visible or PanelAnim.isAnimating(animState)
end

function AutoSavePanel.update(dt)
    if not visible and not PanelAnim.isAnimating(animState) then return end
    PanelAnim.update(animState, dt)
    if animState.phase == "closed" then
        visible = false
    end
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
    if not visible and not PanelAnim.isAnimating(animState) then return end
    clickAreas = {}

    -- v3.12.126: Apply panel animation (alpha + slide offset)
    local alpha = PanelAnim.getProgress(animState)
    local offsetX, offsetY = PanelAnim.getOffset(animState)

    local W = love.graphics.getWidth()
    local H = love.graphics.getHeight()

    -- Dim background (fades in/out)
    love.graphics.setColor(0, 0, 0, 0.6 * alpha)
    love.graphics.rectangle("fill", 0, 0, W, H)

    -- Panel
    local panelW = math.min(560, W - 80)
    local panelH = 530
    local panelX = (W - panelW) / 2
    local panelY = (H - panelH) / 2

    love.graphics.push("all")
    love.graphics.translate(offsetX, offsetY)

    love.graphics.setColor(0.12, 0.14, 0.18, alpha)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH, 8, 8, 8, 8)
    love.graphics.setColor(0.5, 0.7, 0.9, alpha)
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
    love.graphics.print("Ctrl+U: zapri  |  click zunaj: zapri  |  wheel: interval  |  R: reset pozicije  |  O: skrij/prikaži overlay", panelX + 16, panelY + 36)
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

    -- Overlay opacity slider (Castle Kingdoms 2027 v3.11.931)
    local AutoSaveOverlay = require("states.ui.hud.autosave_status_overlay")
    local currentOpacity = AutoSaveOverlay.getOpacity()
    love.graphics.setColor(0.95, 0.85, 0.5, 1)
    love.graphics.print("Prosojnost overlay-a", panelX + 16, y)
    love.graphics.setColor(0.7, 0.78, 0.85, 1)
    if smallFont then love.graphics.setFont(smallFont) end
    love.graphics.print(string.format("%.0f%%", currentOpacity * 100), panelX + panelW - 60, y + 2)
    love.graphics.setFont(font)
    y = y + 20

    -- Slider track
    local sliderX = panelX + 16
    local sliderW = panelW - 32
    local sliderH = 10
    local sliderY = y
    love.graphics.setColor(0.1, 0.12, 0.16, 1)
    love.graphics.rectangle("fill", sliderX, sliderY, sliderW, sliderH, 3, 3, 3, 3)
    love.graphics.setColor(0.3, 0.35, 0.4, 1)
    love.graphics.rectangle("line", sliderX, sliderY, sliderW, sliderH, 3, 3, 3, 3)
    -- Filled portion
    local fillW = sliderW * ((currentOpacity - 0.2) / 0.8)  -- 0.2=0%, 1.0=100%
    love.graphics.setColor(0.4, 0.6, 0.85, 0.9)
    love.graphics.rectangle("fill", sliderX + 1, sliderY + 1, math.max(0, fillW - 2), sliderH - 2, 2, 2, 2, 2)
    -- Thumb (draggable handle)
    local thumbX = sliderX + fillW - 5
    love.graphics.setColor(0.7, 0.8, 0.95, 1)
    love.graphics.rectangle("fill", thumbX, sliderY - 2, 10, sliderH + 4, 3, 3, 3, 3)

    -- Store slider area for click/drag handling
    sliderArea = { x = sliderX, y = sliderY - 4, w = sliderW, h = sliderH + 8 }

    y = y + sliderH + 16

    -- Action feedback message
    if actionMessage ~= "" then
        love.graphics.setColor(0, 0, 0, 0.7 * alpha)
        local msgW = font:getWidth(actionMessage) + 20
        love.graphics.rectangle("fill", panelX + (panelW - msgW) / 2, panelY + panelH - 36, msgW, 24, 4, 4, 4, 4)
        love.graphics.setColor(1, 0.95, 0.7, alpha)
        love.graphics.print(actionMessage, panelX + (panelW - font:getWidth(actionMessage)) / 2, panelY + panelH - 30)
    end

    -- v3.12.126: Close the slide-offset transform
    love.graphics.pop()

    love.graphics.setColor(1, 1, 1, 1)
end

function AutoSavePanel.mousepressed(x, y, button, istouch, presses)
    if not visible then return false end
    -- Click outside panel closes
    local W = love.graphics.getWidth()
    local H = love.graphics.getHeight()
    local panelW = math.min(560, W - 80)
    local panelH = 530
    local panelX = (W - panelW) / 2
    local panelY = (H - panelH) / 2
    if x < panelX or x > panelX + panelW or y < panelY or y > panelY + panelH then
        AutoSavePanel.toggle()
        return true
    end
    -- Check slider click (start drag)
    if sliderArea and x >= sliderArea.x and x <= sliderArea.x + sliderArea.w
                  and y >= sliderArea.y and y <= sliderArea.y + sliderArea.h then
        sliderDragging = true
        -- Immediately update opacity based on click position
        local frac = (x - sliderArea.x) / sliderArea.w
        frac = math.max(0, math.min(1, frac))
        local newOpacity = 0.2 + frac * 0.8  -- range 0.2 to 1.0
        local AutoSaveOverlay = require("states.ui.hud.autosave_status_overlay")
        AutoSaveOverlay.setOpacity(newOpacity)
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

-- Slider drag: update opacity as mouse moves
function AutoSavePanel.mousemoved(x, y, dx, dy)
    if not visible then return false end
    if not sliderDragging then return false end
    if not sliderArea then return false end
    local frac = (x - sliderArea.x) / sliderArea.w
    frac = math.max(0, math.min(1, frac))
    local newOpacity = 0.2 + frac * 0.8
    local AutoSaveOverlay = require("states.ui.hud.autosave_status_overlay")
    AutoSaveOverlay.setOpacity(newOpacity)
    return true
end

function AutoSavePanel.mousereleased(x, y, button)
    if not visible then return false end
    if sliderDragging then
        sliderDragging = false
        showMessage("Prosojnost nastavljena")
        return true
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
    -- R: reset overlay position
    if key == "r" then
        local AutoSaveOverlay = require("states.ui.hud.autosave_status_overlay")
        AutoSaveOverlay.resetPosition()
        showMessage("Pozicija overlay-a resetirana (zgornji desni kot)")
        return true
    end
    -- O: toggle overlay visibility
    if key == "o" then
        local AutoSaveOverlay = require("states.ui.hud.autosave_status_overlay")
        if AutoSaveOverlay.toggleHidden then
            AutoSaveOverlay.toggleHidden()
            showMessage("Overlay preklopljen")
        end
        return true
    end
    return false
end

-- Castle Kingdoms 2027 v3.11.942: Wheel stub for 100% wheel coverage
-- v3.11.950: Implemented actual wheel functionality — cycles interval presets
function AutoSavePanel.wheelmoved(x, y)
    if not visible then return false end
    -- Only respond to vertical wheel
    if y == 0 then return false end

    local stats = AutoSaveSystem.getStats()
    -- Same presets as the interval buttons
    local intervals = {60, 300, 900, 1800}  -- 1, 5, 15, 30 min
    local intervalLabels = {"1 min", "5 min", "15 min", "30 min"}

    -- Find current interval index
    local currentIdx = nil
    for i, secs in ipairs(intervals) do
        if stats.interval == secs then
            currentIdx = i
            break
        end
    end

    -- If current interval is not a preset (custom value), snap to nearest
    if not currentIdx then
        local nearest = 1
        local nearestDiff = math.abs(stats.interval - intervals[1])
        for i = 2, #intervals do
            local diff = math.abs(stats.interval - intervals[i])
            if diff < nearestDiff then
                nearest = i
                nearestDiff = diff
            end
        end
        currentIdx = nearest
    end

    -- y > 0 = wheel up = shorter interval (decrease index)
    -- y < 0 = wheel down = longer interval (increase index)
    local newIdx = currentIdx
    if y > 0 then
        newIdx = math.max(1, currentIdx - 1)
    elseif y < 0 then
        newIdx = math.min(#intervals, currentIdx + 1)
    end

    -- Only change if index actually changed
    if newIdx ~= currentIdx then
        AutoSaveSystem.setInterval(intervals[newIdx])
        showMessage("Interval: " .. intervalLabels[newIdx] .. " (wheel)")
        return true
    end
    -- At boundary — still consume the event to prevent background scroll
    return true
end

return AutoSavePanel
