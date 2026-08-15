-- states/ui/hud/autosave_status_overlay.lua
-- Castle Kingdoms 2027 - Auto-Save Status Overlay
--
-- Compact on-screen indicator in top-right corner showing:
--   * Auto-save enabled/disabled status (icon + color)
--   * Time until next auto-save (mm:ss)
--   * Mini progress bar
--
-- Always visible during gameplay (no toggle needed - too useful to hide).
-- Click to open full Auto-Save Panel (Ctrl+U).
-- Lazy-loaded to avoid circular deps.

local AutoSaveOverlay = {}

local AutoSaveSystem = require("objects.AutoSaveSystem")

-- Cached state
local lastStats = nil
local updateTimer = 0
local UPDATE_INTERVAL = 0.5  -- refresh stats every 500ms (not every frame)

-- Hover detection
local boxX, boxY, boxW, boxH

function AutoSaveOverlay.update(dt)
    updateTimer = updateTimer + dt
    if updateTimer >= UPDATE_INTERVAL then
        updateTimer = 0
        lastStats = AutoSaveSystem.getStats()
    end
end

function AutoSaveOverlay.draw()
    if not lastStats then return end
    -- Don't draw if a full-screen overlay panel is open (avoid clutter)
    -- Lazy require (defensive pcall in case of circular dep)
    local skip = false
    pcall(function()
        local RSP = require("states.ui.hud.royal_systems_panel")
        if RSP.isVisible and RSP.isVisible() then skip = true end
    end)
    if not skip then
        pcall(function()
            local MD = require("states.ui.hud.market_dashboard")
            if MD.isVisible and MD.isVisible() then skip = true end
        end)
    end
    if not skip then
        pcall(function()
            local ASP = require("states.ui.hud.autosave_panel")
            if ASP.isVisible and ASP.isVisible() then skip = true end
        end)
    end
    if skip then return end

    local screenW = love.graphics.getWidth()
    local font = love.graphics.getFont()
    local smallFont = love.graphics.newFont(10)

    -- Box dimensions (compact)
    boxW = 180
    boxH = 38
    boxX = screenW - boxW - 12
    boxY = 12  -- top-right corner

    -- Background
    love.graphics.setColor(0.08, 0.1, 0.14, 0.85)
    love.graphics.rectangle("fill", boxX, boxY, boxW, boxH, 4, 4, 4, 4)
    love.graphics.setColor(0.3, 0.4, 0.5, 0.7)
    love.graphics.rectangle("line", boxX, boxY, boxW, boxH, 4, 4, 4, 4)

    -- Hover highlight
    local mx, my = love.mouse.getPosition()
    local hovered = mx >= boxX and mx <= boxX + boxW and my >= boxY and my <= boxY + boxH
    if hovered then
        love.graphics.setColor(0.5, 0.7, 0.9, 0.3)
        love.graphics.rectangle("fill", boxX, boxY, boxW, boxH, 4, 4, 4, 4)
    end

    -- Status icon + label
    local icon, statusColor, statusText
    if lastStats.enabled then
        icon = "💾"
        statusColor = {0.4, 0.85, 0.4, 1}
        statusText = "Auto-save"
    else
        icon = "⏸"
        statusColor = {0.7, 0.5, 0.5, 1}
        statusText = "Auto-save OFF"
    end

    love.graphics.setFont(smallFont)
    love.graphics.setColor(statusColor)
    love.graphics.print(icon .. " " .. statusText, boxX + 8, boxY + 5)

    -- Timer / next save info
    if lastStats.enabled then
        local nextMin = math.floor(lastStats.nextSaveIn / 60)
        local nextSec = math.floor(lastStats.nextSaveIn % 60)
        love.graphics.setColor(0.7, 0.78, 0.85, 1)
        love.graphics.print(string.format("naslednji: %dm %02ds", nextMin, nextSec),
            boxX + 8, boxY + 18)

        -- Mini progress bar (bottom of box)
        local progress = 1 - (lastStats.nextSaveIn / lastStats.interval)
        local barW = boxW - 16
        local barH = 3
        local barX = boxX + 8
        local barY = boxY + boxH - 6
        love.graphics.setColor(0.15, 0.18, 0.22, 1)
        love.graphics.rectangle("fill", barX, barY, barW, barH)
        -- Color: green (just saved) -> yellow -> orange (almost due)
        local r, g, b
        if progress < 0.5 then r, g, b = 0.3, 0.85, 0.3
        elseif progress < 0.85 then r, g, b = 0.85, 0.85, 0.3
        else r, g, b = 0.95, 0.5, 0.2 end
        love.graphics.setColor(r, g, b, 0.95)
        love.graphics.rectangle("fill", barX, barY, barW * progress, barH)
    else
        love.graphics.setColor(0.6, 0.5, 0.5, 1)
        love.graphics.print("(onemogočeno - Shift+U)", boxX + 8, boxY + 18)
    end

    -- Hover hint
    if hovered then
        love.graphics.setColor(0.7, 0.8, 0.9, 0.9)
        love.graphics.print("klik: odpri panel (Ctrl+U)", boxX + 8, boxY + boxH + 4)
    end

    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1, 1)
end

function AutoSaveOverlay.mousepressed(x, y, button)
    if button ~= 1 then return false end
    if not boxX then return false end
    if x >= boxX and x <= boxX + boxW and y >= boxY and y <= boxY + boxH then
        -- Open full auto-save panel
        local AutoSavePanel = require("states.ui.hud.autosave_panel")
        AutoSavePanel.toggle()
        return true
    end
    return false
end

return AutoSaveOverlay
