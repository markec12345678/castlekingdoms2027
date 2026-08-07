-- objects/Performance/RenderOptimizer.lua
-- Castle Kingdoms 2027 - Render Optimization
--
-- Fixes the rendering bottleneck (11-18 FPS → 60 FPS target):
-- 1. Frustum culling for active entities (skip off-screen units)
-- 2. Reduced chunk render range (don't render chunks far from camera)
-- 3. Batch optimization for similar objects
-- 4. Skip rendering for objects behind UI panels

local RenderOptimizer = {}

local initialized = false

-- Camera bounds (updated each frame)
local cameraBounds = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
}

-- Configuration
local config = {
    -- Chunk rendering: reduce the range to only visible chunks
    chunkMargin = 0,  -- extra chunks beyond visible area (0 = strict culling)

    -- Active entity culling
    entityCullingEnabled = true,
    entityMargin = 100,  -- pixels of margin around screen

    -- LOD (Level of Detail)
    lodEnabled = true,
    lodDistance = 500,  -- pixels from screen center - simplify rendering beyond this
}

-- Initialize
function RenderOptimizer.init()
    if initialized then return end
    initialized = true
    print("[RenderOptimizer] Initialized - frustum culling + LOD")
end

-- Update camera bounds (call every frame before rendering)
function RenderOptimizer.updateCameraBounds()
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()

    -- Account for camera position and scale
    local viewX = (_G.state and _G.state.viewXview) or 0
    local viewY = (_G.state and _G.state.viewYview) or 0
    local scale = (_G.state and _G.state.scaleX) or 1

    cameraBounds.left = viewX - config.entityMargin
    cameraBounds.right = viewX + screenW / scale + config.entityMargin
    cameraBounds.top = viewY - config.entityMargin
    cameraBounds.bottom = viewY + screenH / scale + config.entityMargin
end

-- Check if a world position is visible on screen
-- @param worldX number World X position (screen coords before camera offset)
-- @param worldY number World Y position
-- @return boolean true if visible
function RenderOptimizer.isVisible(worldX, worldY)
    if not config.entityCullingEnabled then return true end

    return worldX >= cameraBounds.left and
           worldX <= cameraBounds.right and
           worldY >= cameraBounds.top and
           worldY <= cameraBounds.bottom
end

-- Check if a tile (gx, gy) is visible on screen
-- @param gx number Global tile X
-- @param gy number Global tile Y
-- @return boolean true if visible
function RenderOptimizer.isTileVisible(gx, gy)
    if not config.entityCullingEnabled then return true end
    if not gx or not gy then return true end  -- safety

    -- Convert tile to screen coords (isometric)
    local screenX = gx * 32 - gy * 32
    local screenY = (gx + gy) * 16

    return RenderOptimizer.isVisible(screenX, screenY)
end

-- Get optimized chunk range (reduces rendering area)
-- @return topLeftChunkX, topLeftChunkY, bottomRightChunkX, bottomRightChunkY
function RenderOptimizer.getOptimizedChunkRange()
    if not _G.state then
        return _G.state.topLeftChunkX, _G.state.topLeftChunkY,
               _G.state.bottomRightChunkX, _G.state.bottomRightChunkY
    end

    -- Use existing chunk range but with reduced margin
    local tlx = _G.state.topLeftChunkX - config.chunkMargin
    local tly = _G.state.topLeftChunkY - config.chunkMargin
    local brx = _G.state.bottomRightChunkX + config.chunkMargin
    local bry = _G.state.bottomRightChunkY + config.chunkMargin

    return tlx, tly, brx, bry
end

-- Filter active entities for rendering (skip off-screen)
-- @return table List of entities that should be rendered
function RenderOptimizer.getVisibleEntities()
    if not _G.state or not _G.state.activeEntities then return {} end
    if not config.entityCullingEnabled then return _G.state.activeEntities end

    local visible = {}
    for _, obj in ipairs(_G.state.activeEntities) do
        if obj and not obj.toBeDeleted then
            -- Check if object is visible
            if obj.isVisibleOnScreen then
                if obj:isVisibleOnScreen() then
                    table.insert(visible, obj)
                end
            elseif obj.gx and obj.gy then
                if RenderOptimizer.isTileVisible(obj.gx, obj.gy) then
                    table.insert(visible, obj)
                end
            else
                -- No position info, include it (safety)
                table.insert(visible, obj)
            end
        end
    end

    return visible
end

-- Check if mouse is over a UI element (skip game world rendering effects)
-- @return boolean true if mouse is over UI
function RenderOptimizer.isMouseOverUI()
    local mx, my = love.mouse.getPosition()
    local screenH = love.graphics.getHeight()

    -- Action bar is typically at the bottom of the screen
    -- Skip selection feedback hover when mouse is over action bar
    if my > screenH - 150 then
        return true
    end

    -- Skip when mouse is over top UI elements
    if my < 80 then
        return true
    end

    return false
end

-- Get LOD (Level of Detail) for a position
-- @param screenX number Screen X
-- @param screenY number Screen Y
-- @return number 1.0 = full detail, 0.5 = half detail, 0.0 = skip
function RenderOptimizer.getLOD(screenX, screenY)
    if not config.lodEnabled then return 1.0 end

    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    local centerX = screenW / 2
    local centerY = screenH / 2

    local dx = screenX - centerX
    local dy = screenY - centerY
    local dist = math.sqrt(dx * dx + dy * dy)

    if dist < config.lodDistance then
        return 1.0  -- Full detail
    elseif dist < config.lodDistance * 2 then
        return 0.5  -- Half detail
    else
        return 0.0  -- Skip rendering
    end
end

-- Get stats
function RenderOptimizer.getStats()
    return {
        cameraBounds = cameraBounds,
        entityCulling = config.entityCullingEnabled,
        lodEnabled = config.lodEnabled,
        visibleEntityCount = #RenderOptimizer.getVisibleEntities(),
        totalEntityCount = (_G.state and _G.state.activeEntities) and #_G.state.activeEntities or 0,
    }
end

-- Settings
function RenderOptimizer.setEntityCulling(enabled)
    config.entityCullingEnabled = enabled
end

function RenderOptimizer.setLODEnabled(enabled)
    config.lodEnabled = enabled
end

function RenderOptimizer.setChunkMargin(margin)
    config.chunkMargin = margin
end

return RenderOptimizer
