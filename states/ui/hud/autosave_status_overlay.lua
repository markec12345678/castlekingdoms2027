-- states/ui/hud/autosave_status_overlay.lua
-- Castle Kingdoms 2027 - Auto-Save Status Overlay
--
-- Compact on-screen indicator showing:
--   * Auto-save enabled/disabled status (icon + color)
--   * Time until next auto-save (mm:ss)
--   * Mini progress bar
--
-- Always visible during gameplay (no toggle needed - too useful to hide).
-- Click to open full Auto-Save Panel (Ctrl+U).
-- Drag with mouse to reposition (position persists between sessions).
-- Lazy-loaded to avoid circular deps.

local AutoSaveOverlay = {}

local AutoSaveSystem = require("objects.AutoSaveSystem")

-- Cached state
local lastStats = nil
local updateTimer = 0
local UPDATE_INTERVAL = 0.5  -- refresh stats every 500ms (not every frame)

-- Position state (persisted to file)
local POSITION_FILE = "autosave_overlay_position.txt"
local overlayX = nil  -- nil = use default (top-right)
local overlayY = nil
local boxW = 180
local boxH = 38

-- Drag state
local isDragging = false
local dragOffsetX = 0
local dragOffsetY = 0
local dragStartedOnOverlay = false  -- distinguishes drag from click
local _movedDuringDrag = false  -- tracks if mouse moved during drag

-- Helper: serialize a small table to a simple Lua-parsable string
local function serializePosition(x, y)
    return string.format("%d\n%d\n", math.floor(x), math.floor(y))
end

-- Helper: deserialize position from file
local function loadPosition()
    local ok, content = pcall(love.filesystem.read, POSITION_FILE)
    if not ok or not content then return nil, nil end
    -- Parse two lines as integers
    local x, y = content:match("^(%d+)%s+(%d+)%s*$")
    if not x then
        -- Try newline-separated
        x, y = content:match("^(%d+)\n(%d+)\n$")
    end
    if x and y then
        local xi, yi = tonumber(x), tonumber(y)
        -- Clamp to screen bounds
        local screenW = love.graphics.getWidth()
        local screenH = love.graphics.getHeight()
        xi = math.max(0, math.min(screenW - boxW, xi))
        yi = math.max(0, math.min(screenH - boxH, yi))
        return xi, yi
    end
    return nil, nil
end

local function savePosition(x, y)
    pcall(love.filesystem.write, POSITION_FILE, serializePosition(x, y))
end

-- Lazy-load position on first draw
local function ensurePosition()
    if overlayX == nil then
        local screenW = love.graphics.getWidth()
        -- Default: top-right corner
        overlayX, overlayY = loadPosition()
        if overlayX == nil then
            overlayX = screenW - boxW - 12
            overlayY = 12
        end
    end
end

function AutoSaveOverlay.update(dt)
    updateTimer = updateTimer + dt
    if updateTimer >= UPDATE_INTERVAL then
        updateTimer = 0
        lastStats = AutoSaveSystem.getStats()
    end
end

function AutoSaveOverlay.draw()
    if not lastStats then return end
    ensurePosition()
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

    -- Clamp position to screen (in case of resolution change)
    overlayX = math.max(0, math.min(screenW - boxW, overlayX))

    -- Background (highlight when dragging)
    love.graphics.setColor(0.08, 0.1, 0.14, 0.85)
    love.graphics.rectangle("fill", overlayX, overlayY, boxW, boxH, 4, 4, 4, 4)
    if isDragging then
        love.graphics.setColor(0.6, 0.8, 1.0, 1)
        love.graphics.setLineWidth(2)
    else
        love.graphics.setColor(0.3, 0.4, 0.5, 0.7)
        love.graphics.setLineWidth(1)
    end
    love.graphics.rectangle("line", overlayX, overlayY, boxW, boxH, 4, 4, 4, 4)
    love.graphics.setLineWidth(1)

    -- Hover highlight
    local mx, my = love.mouse.getPosition()
    local hovered = mx >= overlayX and mx <= overlayX + boxW and my >= overlayY and my <= overlayY + boxH
    if hovered and not isDragging then
        love.graphics.setColor(0.5, 0.7, 0.9, 0.3)
        love.graphics.rectangle("fill", overlayX, overlayY, boxW, boxH, 4, 4, 4, 4)
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
    love.graphics.print(icon .. " " .. statusText, overlayX + 8, overlayY + 5)

    -- Timer / next save info
    if lastStats.enabled then
        local nextMin = math.floor(lastStats.nextSaveIn / 60)
        local nextSec = math.floor(lastStats.nextSaveIn % 60)
        love.graphics.setColor(0.7, 0.78, 0.85, 1)
        love.graphics.print(string.format("naslednji: %dm %02ds", nextMin, nextSec),
            overlayX + 8, overlayY + 18)

        -- Mini progress bar (bottom of box)
        local progress = 1 - (lastStats.nextSaveIn / lastStats.interval)
        local barW = boxW - 16
        local barH = 3
        local barX = overlayX + 8
        local barY = overlayY + boxH - 6
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
        love.graphics.print("(onemogočeno - Shift+U)", overlayX + 8, overlayY + 18)
    end

    -- Hover hint
    if hovered and not isDragging then
        love.graphics.setColor(0.7, 0.8, 0.9, 0.9)
        love.graphics.print("klik: odpri panel  |  drag: premakni", overlayX + 8, overlayY + boxH + 4)
    end

    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1, 1)
end

-- Mouse press: detect drag vs click
function AutoSaveOverlay.mousepressed(x, y, button)
    if button ~= 1 then return false end
    ensurePosition()
    if x >= overlayX and x <= overlayX + boxW and y >= overlayY and y <= overlayY + boxH then
        -- Start potential drag
        isDragging = true
        dragStartedOnOverlay = true
        dragOffsetX = x - overlayX
        dragOffsetY = y - overlayY
        return true  -- consume the event
    end
    return false
end

-- Mouse release: if it was a drag (mouse moved), don't open panel;
-- if it was a click (no movement), open panel
function AutoSaveOverlay.mousereleased(x, y, button)
    if button ~= 1 then return false end
    if not isDragging then return false end
    local wasClick = not _movedDuringDrag
    isDragging = false
    _movedDuringDrag = false
    if wasClick and dragStartedOnOverlay then
        -- Open full auto-save panel
        local AutoSavePanel = require("states.ui.hud.autosave_panel")
        AutoSavePanel.toggle()
    else
        -- Was a drag - save new position
        savePosition(overlayX, overlayY)
    end
    dragStartedOnOverlay = false
    return true
end

-- Mouse move: update overlay position if dragging
-- (tracks _movedDuringDrag to distinguish click from drag)
function AutoSaveOverlay.mousemoved(x, y, dx, dy)
    if not isDragging then return false end
    if dx ~= 0 or dy ~= 0 then
        _movedDuringDrag = true
    end
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    -- Update position (clamped to screen)
    overlayX = math.max(0, math.min(screenW - boxW, x - dragOffsetX))
    overlayY = math.max(0, math.min(screenH - boxH, y - dragOffsetY))
    return true
end

-- Reset overlay position to default (top-right corner) and delete persisted file
-- Called from Auto-Save Panel "Reset pozicije" button
function AutoSaveOverlay.resetPosition()
    local screenW = love.graphics.getWidth()
    overlayX = screenW - boxW - 12
    overlayY = 12
    -- Delete the persisted position file so default is used on next launch
    pcall(love.filesystem.remove, POSITION_FILE)
    print("[AutoSaveOverlay] Position reset to default (top-right)")
end

-- Get current position (for debug/display)
function AutoSaveOverlay.getPosition()
    ensurePosition()
    return overlayX, overlayY
end

return AutoSaveOverlay
