-- objects/UI/MinimapDragScroll.lua
-- Stronghold 2027 - Minimap Drag Scroll
-- Drag on minimap to pan camera smoothly

local MinimapDrag = {}

local initialized = false
local isDragging = false
local lastDragX = 0
local lastDragY = 0

function MinimapDrag.init()
    if initialized then return end
    initialized = true
    print("[MinimapDrag] Initialized (drag on minimap to pan)")
end

-- Check if a position is on the minimap
function MinimapDrag.isOnMinimap(x, y)
    local Minimap = require("objects.UI.MinimapSystem")
    if not Minimap.isVisible() then return false end
    local mx, my, ms = Minimap.getBounds()
    return x >= mx and x <= mx + ms and y >= my and y <= my + ms
end

-- Handle mouse press on minimap
function MinimapDrag.mousepressed(x, y, button)
    if not initialized or button ~= 1 then return false end
    if not MinimapDrag.isOnMinimap(x, y) then return false end

    isDragging = true
    lastDragX = x
    lastDragY = y

    -- Initial camera move
    MinimapDrag._moveCamera(x, y)
    return true
end

-- Handle mouse drag on minimap
function MinimapDrag.mousemoved(x, y, dx, dy)
    if not initialized or not isDragging then return false end
    if not MinimapDrag.isOnMinimap(x, y) then return false end

    -- Only move if moved enough
    if math.abs(x - lastDragX) < 2 and math.abs(y - lastDragY) < 2 then
        return false
    end

    lastDragX = x
    lastDragY = y
    MinimapDrag._moveCamera(x, y)
    return true
end

-- Handle mouse release
function MinimapDrag.mousereleased(x, y, button)
    if not initialized then return false end
    if button == 1 and isDragging then
        isDragging = false
        return true
    end
    return false
end

-- Move camera to minimap position
function MinimapDrag._moveCamera(x, y)
    local Minimap = require("objects.UI.MinimapSystem")
    if not Minimap.isVisible() then return end

    local mx, my, ms = Minimap.getBounds()
    if ms <= 0 then return end

    local mapW = _G.chunkWidth * _G.chunksWide or 256
    local mapH = _G.chunkHeight * _G.chunksHigh or 256

    local relX = (x - mx) / ms
    local relY = (y - my) / ms

    local worldGx = relX * mapW
    local worldGy = relY * mapH

    if _G.state then
        _G.state.viewXview = -_G.IsoToScreenX(worldGx, worldGy) + love.graphics.getWidth() / 2
        _G.state.viewYview = -_G.IsoToScreenY(worldGx, worldGy) + love.graphics.getHeight() / 2
    end
end

function MinimapDrag.isDragging()
    return isDragging
end

return MinimapDrag
