-- states/ui/hud/minimap_widget.lua
-- Castle Kingdoms 2027 v3.12.142 - Minimap HUD Widget
--
-- Compact always-on minimap showing:
--   * World terrain overview (simplified colors)
--   * Player units (green dots)
--   * Enemy units (red dots)
--   * Buildings (yellow squares)
--   * Viewport indicator (white rectangle)
--   * Click-to-navigate (click on minimap to move camera)
--
-- Toggle with Ctrl+M (M is used for market without Ctrl).

local MinimapWidget = {}

local visible = true
local minimapArea = nil  -- {x, y, w, h} set during draw
local isDragging = false

-- Minimap configuration
local MINIMAP_SIZE = 160  -- square size in pixels
local MINIMAP_MARGIN = 10  -- margin from screen edge

-- Persistence
local SETTINGS_FILE = "minimap_visible.txt"

-- Load persisted state
local function loadSettings()
    local ok, content = pcall(love.filesystem.read, SETTINGS_FILE)
    if ok and content then
        content = content:gsub("%s+$", "")
        if content == "false" then visible = false end
    end
end
loadSettings()

-- Save state
local function saveSettings()
    pcall(love.filesystem.write, SETTINGS_FILE, tostring(visible) .. "\n")
end

function MinimapWidget.toggle()
    visible = not visible
    saveSettings()
    if _G.UISoundHelper then
        pcall(function() _G.UISoundHelper.playToggleOn() end)
    end
    if _G.NotificationCenter then
        pcall(function()
            _G.NotificationCenter.system(
                "Minimap: " .. (visible and "VKLOPLJEN" or "IZKLOPLJEN"),
                _G.NotificationCenter.PRIORITY.LOW, 2
            )
        end)
    end
end

function MinimapWidget.isVisible()
    return visible
end

function MinimapWidget.setVisible(state)
    if state ~= visible then
        visible = state
        saveSettings()
    end
end

function MinimapWidget.draw()
    if not visible then return end
    if not _G.state or not _G.state.initialized then return end

    local screenW, screenH = love.graphics.getDimensions()
    -- Position: bottom-right, above action bar
    local mmX = screenW - MINIMAP_SIZE - MINIMAP_MARGIN
    local mmY = screenH - 150 - MINIMAP_SIZE - MINIMAP_MARGIN
    local mmW = MINIMAP_SIZE
    local mmH = MINIMAP_SIZE

    minimapArea = { x = mmX, y = mmY, w = mmW, h = mmH }

    -- Background
    love.graphics.setColor(0.04, 0.05, 0.07, 0.9)
    love.graphics.rectangle("fill", mmX, mmY, mmW, mmH, 4, 4, 4, 4)

    -- Border
    love.graphics.setColor(0.4, 0.5, 0.6, 0.8)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", mmX, mmY, mmW, mmH, 4, 4, 4, 4)

    -- World dimensions
    local worldW = _G.chunksWide or 32
    local worldH = _G.chunksHigh or 32
    -- Each chunk is ~16 tiles, each tile is ~1 unit
    local totalTilesW = worldW * 16
    local totalTilesH = worldH * 16
    -- Scale: map world to minimap
    local scaleX = mmW / totalTilesW
    local scaleY = mmH / totalTilesH

    -- Draw simplified terrain (just background color based on terrain type)
    -- For performance, just draw a dark green background representing grass
    love.graphics.setColor(0.08, 0.15, 0.08, 0.8)
    love.graphics.rectangle("fill", mmX + 1, mmY + 1, mmW - 2, mmH - 2)

    -- Draw water areas if available (blue)
    -- This is a simplified version — full terrain rendering would be too slow
    -- For now, just show the base terrain color

    -- Draw buildings (yellow squares)
    if _G.state.gameObjectList then
        for _, obj in ipairs(_G.state.gameObjectList) do
            if obj.gx and obj.gy and not obj.toBeDeleted then
                local px = mmX + obj.gx * scaleX
                local py = mmY + obj.gy * scaleY
                if px >= mmX and px <= mmX + mmW and py >= mmY and py <= mmY + mmH then
                    if obj.faction == 1 or not obj.faction then
                        -- Player building (yellow)
                        if obj._combatAttached then
                            -- Combat unit (green dot)
                            love.graphics.setColor(0.3, 0.85, 0.3, 0.9)
                            love.graphics.circle("fill", px, py, 2)
                        else
                            -- Building (gold)
                            love.graphics.setColor(0.85, 0.75, 0.3, 0.8)
                            love.graphics.rectangle("fill", px - 1, py - 1, 2, 2)
                        end
                    elseif obj.faction and obj.faction > 1 then
                        -- Enemy (red dot)
                        love.graphics.setColor(0.9, 0.3, 0.3, 0.9)
                        love.graphics.circle("fill", px, py, 2)
                    end
                end
            end
        end
    end

    -- Draw viewport indicator (white rectangle)
    if _G.state.viewXview and _G.state.viewYview then
        local viewW = love.graphics.getWidth() * scaleX * 0.3
        local viewH = love.graphics.getHeight() * scaleY * 0.3
        -- Convert camera position to minimap coordinates
        local camX = mmX + (-_G.state.viewXview / (love.graphics.getWidth() / 2)) * mmW * 0.15 + mmW * 0.5
        local camY = mmY + (-_G.state.viewYview / (love.graphics.getHeight() / 2)) * mmH * 0.15 + mmH * 0.5
        -- Clamp to minimap bounds
        camX = math.max(mmX, math.min(mmX + mmW - viewW, camX))
        camY = math.max(mmY, math.min(mmY + mmH - viewH, camY))
        love.graphics.setColor(1, 1, 1, 0.6)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", camX, camY, math.max(10, viewW), math.max(8, viewH))
    end

    -- Title
    love.graphics.setColor(0.6, 0.65, 0.7, 0.9)
    local font = love.graphics.getFont()
    local smallFont = love.graphics.newFont(9)
    love.graphics.setFont(smallFont)
    love.graphics.print("MINIMAP", mmX + 4, mmY + 2)

    -- Click hint
    love.graphics.setColor(0.4, 0.45, 0.5, 0.6)
    love.graphics.print("klik: navigiraj", mmX + 4, mmY + mmH - 12)

    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(1)
end

-- Convert minimap click position to world coordinates
function MinimapWidget.mousepressed(x, y, button)
    if not visible or button ~= 1 then return false end
    if not minimapArea then return false end

    local ma = minimapArea
    if x < ma.x or x > ma.x + ma.w or y < ma.y or y > ma.y + ma.h then
        return false
    end

    -- Click on minimap — navigate camera
    local worldW = (_G.chunksWide or 32) * 16
    local worldH = (_G.chunksHigh or 32) * 16
    local scaleX = ma.w / worldW
    local scaleY = ma.h / worldH

    -- Click position in world coordinates
    local worldGx = (x - ma.x) / scaleX
    local worldGy = (y - ma.y) / scaleY

    -- Move camera to this position
    if _G.state and _G.IsoToScreenX then
        _G.state.viewXview = _G.IsoToScreenX(worldGx, worldGy) - love.graphics.getWidth() / 2
        _G.state.viewYview = _G.IsoToScreenY(worldGx, worldGy) - love.graphics.getHeight() / 2
    end

    -- Play sound
    if _G.UISoundHelper then
        pcall(function() _G.UISoundHelper.playClick() end)
    end

    isDragging = true
    return true
end

function MinimapWidget.mousemoved(x, y, dx, dy)
    if not visible or not isDragging then return false end
    -- Continue navigating while dragging
    return MinimapWidget.mousepressed(x, y, 1)
end

function MinimapWidget.mousereleased(x, y, button)
    isDragging = false
    return false
end

function MinimapWidget.getArea()
    return minimapArea
end

return MinimapWidget
