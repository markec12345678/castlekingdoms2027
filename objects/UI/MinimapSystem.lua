-- objects/UI/MinimapSystem.lua
-- Stronghold 2027 - Minimap System
-- Overview of map showing terrain, buildings, units, and camera viewport

local Minimap = {}

local initialized = false
local minimapCanvas = nil
local minimapSize = 180  -- pixels
local minimapX = 0
local minimapY = 0
local updateTimer = 0
local updateInterval = 0.25  -- Update 4 times per second
local isVisible = true

-- Colors for minimap
local COLORS = {
    terrain = {
        grass = {0.2, 0.5, 0.15},
        dirt = {0.45, 0.35, 0.2},
        stone = {0.5, 0.5, 0.5},
        water = {0.1, 0.3, 0.6},
        sand = {0.7, 0.65, 0.4},
    },
    player = {0.3, 0.6, 1.0},      -- Blue
    enemy = {1.0, 0.2, 0.2},       -- Red
    ally = {0.2, 0.8, 0.3},        -- Green
    neutral = {0.6, 0.6, 0.6},    -- Gray
    viewport = {1.0, 1.0, 1.0},   -- White
    background = {0.05, 0.05, 0.08},
}

function Minimap.init()
    if initialized then return end
    initialized = true

    local w, h = love.graphics.getDimensions()
    minimapX = w - minimapSize - 10
    minimapY = 10

    print("[Minimap] Initialized (" .. minimapSize .. "x" .. minimapSize .. ")")
end

function Minimap.setSize(size)
    minimapSize = size
    local w, h = love.graphics.getDimensions()
    minimapX = w - minimapSize - 10
    minimapY = 10
end

function Minimap.toggle()
    isVisible = not isVisible
end

function Minimap.setVisible(visible)
    isVisible = visible
end

function Minimap.isVisible()
    return isVisible
end

function Minimap.update(dt)
    if not initialized or not isVisible then return end
    updateTimer = updateTimer + dt
    if updateTimer < updateInterval then return end
    updateTimer = 0

    -- Update minimap canvas
    Minimap._renderToCanvas()
end

function Minimap._renderToCanvas()
    if not _G.state or not _G.state.map then return end

    local mapW = _G.chunkWidth * _G.chunksWide or 256
    local mapH = _G.chunkHeight * _G.chunksHigh or 256

    if not minimapCanvas or minimapCanvas:getWidth() ~= minimapSize then
        minimapCanvas = love.graphics.newCanvas(minimapSize, minimapSize)
    end

    love.graphics.setCanvas(minimapCanvas)
    love.graphics.clear(COLORS.background[1], COLORS.background[2], COLORS.background[3], 0.9)

    -- Draw terrain (simplified — sample every N tiles)
    local stepX = mapW / minimapSize
    local stepY = mapH / minimapSize

    if _G.state.map and _G.state.map.terrainType then
        for py = 0, minimapSize - 1 do
            for px = 0, minimapSize - 1 do
                local gx = math.floor(px * stepX)
                local gy = math.floor(py * stepY)

                -- Get terrain type (simplified)
                local terrainType = "grass"
                if _G.state.map.terrainType[gx] and _G.state.map.terrainType[gx][gy] then
                    terrainType = _G.state.map.terrainType[gx][gy]
                end

                local color = COLORS.terrain[terrainType] or COLORS.terrain.grass
                love.graphics.setColor(color[1], color[2], color[3], 0.8)
                love.graphics.points(px + 0.5, py + 0.5)
            end
        end
    end

    -- Draw buildings
    if _G.state.gameObjectList then
        for _, obj in ipairs(_G.state.gameObjectList) do
            if obj.gx and obj.gy then
                local mx = (obj.gx / mapW) * minimapSize
                local my = (obj.gy / mapH) * minimapSize

                local color
                if not obj.faction or obj.faction == 1 then
                    color = COLORS.player
                elseif obj.faction == 2 then
                    color = COLORS.enemy
                else
                    color = COLORS.neutral
                end

                love.graphics.setColor(color[1], color[2], color[3], 1)
                love.graphics.rectangle("fill", mx - 1, my - 1, 2, 2)
            end
        end
    end

    -- Draw camera viewport
    if _G.state.viewXview and _G.state.viewYview then
        local camX = -_G.state.viewXview / (_G.tileWidth * 2)
        local camY = -_G.state.viewYview / (_G.tileHeight * 2)
        local camW = love.graphics.getWidth() / (_G.tileWidth * 2 * (_G.state.scaleX or 1))
        local camH = love.graphics.getHeight() / (_G.tileHeight * 2 * (_G.state.scaleX or 1))

        local mx = (camX / mapW) * minimapSize
        local my = (camY / mapH) * minimapSize
        local mw = (camW / mapW) * minimapSize
        local mh = (camH / mapH) * minimapSize

        love.graphics.setColor(COLORS.viewport[1], COLORS.viewport[2], COLORS.viewport[3], 0.8)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", mx, my, mw, mh)
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setCanvas()
end

function Minimap.draw()
    if not initialized or not isVisible or not minimapCanvas then return end

    -- Draw border
    love.graphics.setColor(0.3, 0.3, 0.35, 0.9)
    love.graphics.rectangle("fill", minimapX - 3, minimapY - 3, minimapSize + 6, minimapSize + 6)

    -- Draw minimap
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(minimapCanvas, minimapX, minimapY)

    -- Draw border line
    love.graphics.setColor(0.6, 0.5, 0.2, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", minimapX - 3, minimapY - 3, minimapSize + 6, minimapSize + 6)

    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 1, 1, 1)
end

-- Handle minimap click (move camera to clicked position)
function Minimap.mousepressed(x, y, button)
    if not initialized or not isVisible then return false end
    if button ~= 1 then return false end

    if x >= minimapX and x <= minimapX + minimapSize and
       y >= minimapY and y <= minimapY + minimapSize then

        -- Convert minimap click to world coordinates
        local mapW = _G.chunkWidth * _G.chunksWide or 256
        local mapH = _G.chunkHeight * _G.chunksHigh or 256

        local relX = (x - minimapX) / minimapSize
        local relY = (y - minimapY) / minimapSize

        local worldGx = relX * mapW
        local worldGy = relY * mapH

        -- Move camera
        if _G.state then
            _G.state.viewXview = -_G.IsoToScreenX(worldGx, worldGy) + love.graphics.getWidth() / 2
            _G.state.viewYview = -_G.IsoToScreenY(worldGx, worldGy) + love.graphics.getHeight() / 2
        end

        return true
    end
    return false
end

function Minimap.getBounds()
    return minimapX, minimapY, minimapSize, minimapSize
end

function Minimap.getStats()
    return {
        size = minimapSize,
        visible = isVisible,
        updateInterval = updateInterval,
    }
end

return Minimap
