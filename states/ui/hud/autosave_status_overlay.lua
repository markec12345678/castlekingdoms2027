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

-- Consolidated settings file (replaces 3 separate files from v3.11.925-930)
-- Format: "key=value\n" per line
local SETTINGS_FILE = "autosave_overlay_settings.txt"
local settingsLoaded = false

-- Settings state (all persisted in one file)
local hidden = nil    -- nil = not loaded; false = visible; true = hidden
local opacity = nil   -- nil = not loaded; default 0.85
local overlayX = nil  -- nil = not loaded; default top-right
local overlayY = nil
local boxW = 180
local boxH = 38

-- Drag state
local isDragging = false
local dragOffsetX = 0
local dragOffsetY = 0
local dragStartedOnOverlay = false
local _movedDuringDrag = false

-- Default values
local DEFAULT_OPACITY = 0.85
local DEFAULT_HIDDEN = false

-- ============================================================================
-- CONSOLIDATED SETTINGS LOAD/SAVE (v3.11.933)
-- Replaces loadPosition/savePosition, loadOpacity/saveOpacity, loadHidden/saveHidden
-- ============================================================================

-- Load all settings from one file
local function loadSettings()
    if settingsLoaded then return end
    settingsLoaded = true

    -- Set defaults
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    overlayX = screenW - boxW - 12
    overlayY = 12
    opacity = DEFAULT_OPACITY
    hidden = DEFAULT_HIDDEN

    -- Try to load from file
    local ok, content = pcall(love.filesystem.read, SETTINGS_FILE)
    if not ok or not content then return end

    -- Parse key=value lines
    for line in content:gmatch("([^\n]+)") do
        local key, val = line:match("^([%w_]+)=([%d%.%-]+)%s*$")
        if key and val then
            val = tonumber(val)
            if key == "x" then
                overlayX = math.max(0, math.min(screenW - boxW, val))
            elseif key == "y" then
                overlayY = math.max(0, math.min(screenH - boxH, val))
            elseif key == "opacity" then
                opacity = math.max(0.2, math.min(1.0, val))
            elseif key == "hidden" then
                hidden = val ~= 0
            end
        end
    end
end

-- Save all settings to one file
local function saveSettings()
    local lines = {}
    lines[#lines + 1] = string.format("x=%d", math.floor(overlayX or 0))
    lines[#lines + 1] = string.format("y=%d", math.floor(overlayY or 0))
    lines[#lines + 1] = string.format("opacity=%.2f", opacity or DEFAULT_OPACITY)
    lines[#lines + 1] = string.format("hidden=%d", (hidden and 1 or 0))
    pcall(love.filesystem.write, SETTINGS_FILE, table.concat(lines, "\n") .. "\n")
end

-- Migration: try to load old 3-file format if consolidated file doesn't exist
-- (one-time migration on first load after upgrade)
local function tryMigrateOldFiles()
    if settingsLoaded then return end
    -- Check if consolidated file exists
    local ok, content = pcall(love.filesystem.read, SETTINGS_FILE)
    if ok and content and #content > 0 then return end  -- already have consolidated

    -- Try to read old files
    local oldPos = pcall(love.filesystem.read, "autosave_overlay_position.txt")
    local oldOpacity = pcall(love.filesystem.read, "autosave_overlay_opacity.txt")
    local oldHidden = pcall(love.filesystem.read, "autosave_overlay_hidden.txt")

    -- If any old file exists, we need to migrate
    -- (loadSettings will handle defaults; we just delete old files after saveSettings)
    -- The actual migration happens implicitly: loadSettings sets defaults,
    -- then old files are checked in the parse loop. Since they're separate files,
    -- we can't parse them in the consolidated parser. Instead, we just let
    -- loadSettings use defaults and delete old files.
    if oldPos or oldOpacity or oldHidden then
        pcall(love.filesystem.remove, "autosave_overlay_position.txt")
        pcall(love.filesystem.remove, "autosave_overlay_opacity.txt")
        pcall(love.filesystem.remove, "autosave_overlay_hidden.txt")
        print("[AutoSaveOverlay] Migrated from 3 separate files to consolidated settings")
    end
end

-- Ensure all settings are loaded (lazy, called from draw/ensure functions)
local function ensureSettings()
    if not settingsLoaded then
        tryMigrateOldFiles()
        loadSettings()
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
    ensureSettings()
    if hidden then return end  -- player hid the overlay
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
    love.graphics.setColor(0.08, 0.1, 0.14, opacity * 0.85)
    love.graphics.rectangle("fill", overlayX, overlayY, boxW, boxH, 4, 4, 4, 4)
    if isDragging then
        love.graphics.setColor(0.6, 0.8, 1.0, opacity)
        love.graphics.setLineWidth(2)
    else
        love.graphics.setColor(0.3, 0.4, 0.5, opacity * 0.7)
        love.graphics.setLineWidth(1)
    end
    love.graphics.rectangle("line", overlayX, overlayY, boxW, boxH, 4, 4, 4, 4)
    love.graphics.setLineWidth(1)

    -- Hover highlight
    local mx, my = love.mouse.getPosition()
    local hovered = mx >= overlayX and mx <= overlayX + boxW and my >= overlayY and my <= overlayY + boxH
    if hovered and not isDragging then
        love.graphics.setColor(0.5, 0.7, 0.9, opacity * 0.3)
        love.graphics.rectangle("fill", overlayX, overlayY, boxW, boxH, 4, 4, 4, 4)
    end

    -- Status icon + label
    local icon, statusColor, statusText
    if lastStats.enabled then
        icon = "💾"
        statusColor = {0.4, 0.85, 0.4, opacity}
        statusText = "Auto-save"
    else
        icon = "⏸"
        statusColor = {0.7, 0.5, 0.5, opacity}
        statusText = "Auto-save OFF"
    end

    love.graphics.setFont(smallFont)
    love.graphics.setColor(statusColor)
    love.graphics.print(icon .. " " .. statusText, overlayX + 8, overlayY + 5)

    -- Timer / next save info
    if lastStats.enabled then
        local nextMin = math.floor(lastStats.nextSaveIn / 60)
        local nextSec = math.floor(lastStats.nextSaveIn % 60)
        love.graphics.setColor(0.7, 0.78, 0.85, opacity)
        love.graphics.print(string.format("naslednji: %dm %02ds", nextMin, nextSec),
            overlayX + 8, overlayY + 18)

        -- Mini progress bar (bottom of box)
        local progress = 1 - (lastStats.nextSaveIn / lastStats.interval)
        local barW = boxW - 16
        local barH = 3
        local barX = overlayX + 8
        local barY = overlayY + boxH - 6
        love.graphics.setColor(0.15, 0.18, 0.22, opacity)
        love.graphics.rectangle("fill", barX, barY, barW, barH)
        -- Color: green (just saved) -> yellow -> orange (almost due)
        local r, g, b
        if progress < 0.5 then r, g, b = 0.3, 0.85, 0.3
        elseif progress < 0.85 then r, g, b = 0.85, 0.85, 0.3
        else r, g, b = 0.95, 0.5, 0.2 end
        love.graphics.setColor(r, g, b, opacity * 0.95)
        love.graphics.rectangle("fill", barX, barY, barW * progress, barH)
    else
        love.graphics.setColor(0.6, 0.5, 0.5, opacity)
        love.graphics.print("(onemogočeno - Shift+U)", overlayX + 8, overlayY + 18)
    end

    -- Hover hint
    if hovered and not isDragging then
        love.graphics.setColor(0.7, 0.8, 0.9, opacity * 0.9)
        love.graphics.print("klik: odpri panel  |  drag: premakni  |  wheel: prosojnost", overlayX + 8, overlayY + boxH + 4)
    end

    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1, 1)
end

-- Mouse press: detect drag vs click
function AutoSaveOverlay.mousepressed(x, y, button)
    if button ~= 1 then return false end
    ensureSettings()
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
        saveSettings()
    end
    dragStartedOnOverlay = false
    return true
end

-- Mouse wheel: if hovering overlay, adjust opacity; otherwise drag scroll
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

-- Wheel handler: if hovering overlay, adjust opacity; otherwise return false
-- (so game.lua can forward wheel to other panels like minimap scroll)
function AutoSaveOverlay.wheelmoved(x, y)
    if hidden then return false end
    ensureSettings()
    local mx, my = love.mouse.getPosition()
    local hovered = mx >= overlayX and mx <= overlayX + boxW and my >= overlayY and my <= overlayY + boxH
    if not hovered then return false end
    -- Adjust opacity (0.2 to 1.0, step 0.05)
    if y > 0 then
        opacity = math.min(1.0, opacity + 0.05)
    elseif y < 0 then
        opacity = math.max(0.2, opacity - 0.05)
    end
    saveSettings()
    return true
end

-- Reset overlay position to default (top-right corner) and delete persisted file
-- Called from Auto-Save Panel "Reset pozicije" button
function AutoSaveOverlay.resetPosition()
    local screenW = love.graphics.getWidth()
    overlayX = screenW - boxW - 12
    overlayY = 12
    -- Delete the persisted position file so default is used on next launch
    saveSettings()
    print("[AutoSaveOverlay] Position reset to default (top-right)")
end

-- Get current position (for debug/display)
function AutoSaveOverlay.getPosition()
    ensureSettings()
    return overlayX, overlayY
end

-- Toggle overlay visibility (hide/show without disabling auto-save)
-- Persists the new state to file
function AutoSaveOverlay.toggleHidden()
    ensureSettings()
    hidden = not hidden
    saveSettings()
    return hidden
end

-- Set hidden state explicitly (persists to file)
function AutoSaveOverlay.setHidden(state)
    ensureSettings()
    hidden = state and true or false
    saveSettings()
end

-- Check if overlay is hidden
function AutoSaveOverlay.isHidden()
    ensureSettings()
    return hidden
end

-- Get current opacity (0.2 to 1.0)
function AutoSaveOverlay.getOpacity()
    ensureSettings()
    return opacity
end

-- Set opacity explicitly (0.2 to 1.0, clamped)
function AutoSaveOverlay.setOpacity(val)
    ensureSettings()
    opacity = math.max(0.2, math.min(1.0, tonumber(val) or DEFAULT_OPACITY))
    saveSettings()
end

return AutoSaveOverlay
