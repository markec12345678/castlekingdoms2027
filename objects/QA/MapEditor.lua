-- objects/QA/MapEditor.lua
-- Stronghold 2027 - Map Editor
--
-- Allows players to create and edit custom maps:
-- - Paint terrain (grass, dirt, stone, water)
-- - Place/remove trees and rocks
-- - Set player starting positions
-- - Set map size (small, medium, large)
-- - Save/load custom maps
--
-- Usage:
--   local MapEditor = require("objects.QA.MapEditor")
--   MapEditor.init()
--   MapEditor.toggle()  -- F12 to toggle
--   MapEditor.update(dt)
--   MapEditor.draw()

local MapEditor = {}

local initialized = false
local isActive = false

-- Editor tools
local TOOL = {
    TERRAIN = "terrain",
    TREE = "tree",
    ROCK = "rock",
    START_POS = "start_pos",
    ERASE = "erase",
    PAN = "pan",
}

MapEditor.TOOL = TOOL

-- Terrain types
local TERRAIN = {
    GRASS = 1,
    DIRT = 2,
    STONE = 3,
    WATER = 4,
    SAND = 5,
}

MapEditor.TERRAIN = TERRAIN

local currentTool = TOOL.TERRAIN
local currentTerrain = TERRAIN.GRASS
local brushSize = 1
local mapData = {}
local mapWidth = 64
local mapHeight = 64
local mapName = "custom_map"
local playerStartPositions = {}
local hasUnsavedChanges = false

-- Initialize
function MapEditor.init()
    if initialized then return end
    initialized = true
    print("[MapEditor] Initialized (press F12 to toggle)")
end

-- Toggle editor
function MapEditor.toggle()
    if not initialized then MapEditor.init() end
    isActive = not isActive

    if isActive then
        -- Initialize empty map if needed
        if not mapData or #mapData == 0 then
            MapEditor._newMap(64, 64)
        end
        print("[MapEditor] Editor activated")
    else
        print("[MapEditor] Editor deactivated")
    end
end

function MapEditor.isActive()
    return isActive
end

-- Create new map
function MapEditor._newMap(width, height)
    mapWidth = width or 64
    mapHeight = height or 64
    mapData = {}
    playerStartPositions = {}

    for y = 1, mapHeight do
        mapData[y] = {}
        for x = 1, mapWidth do
            mapData[y][x] = {
                terrain = TERRAIN.GRASS,
                elevation = 0,
                object = nil,  -- "tree", "rock", etc.
            }
        end
    end

    -- Default player 1 start position
    playerStartPositions[1] = {x = math.floor(mapWidth / 4), y = math.floor(mapHeight / 4)}
    playerStartPositions[2] = {x = math.floor(mapWidth * 3 / 4), y = math.floor(mapHeight * 3 / 4)}

    hasUnsavedChanges = true
    print(string.format("[MapEditor] New map created: %dx%d", mapWidth, mapHeight))
end

-- Set current tool
function MapEditor.setTool(tool)
    currentTool = tool
    print("[MapEditor] Tool: " .. tool)
end

-- Set current terrain
function MapEditor.setTerrain(terrain)
    currentTerrain = terrain
end

-- Set brush size
function MapEditor.setBrushSize(size)
    brushSize = math.max(1, math.min(5, size))
end

-- Apply tool at position
function MapEditor.applyAt(gx, gy)
    if not isActive then return end
    if gx < 0 or gy < 0 or gx >= mapWidth or gy >= mapHeight then return end

    for dy = -brushSize + 1, brushSize - 1 do
        for dx = -brushSize + 1, brushSize - 1 do
            local tx, ty = gx + dx, gy + dy
            if tx >= 0 and ty >= 0 and tx < mapWidth and ty < mapHeight then
                if not mapData[ty + 1] then mapData[ty + 1] = {} end
                if not mapData[ty + 1][tx + 1] then
                    mapData[ty + 1][tx + 1] = {terrain = TERRAIN.GRASS, elevation = 0, object = nil}
                end

                local tile = mapData[ty + 1][tx + 1]

                if currentTool == TOOL.TERRAIN then
                    tile.terrain = currentTerrain
                elseif currentTool == TOOL.TREE then
                    tile.object = "tree"
                elseif currentTool == TOOL.ROCK then
                    tile.object = "rock"
                elseif currentTool == TOOL.ERASE then
                    tile.object = nil
                elseif currentTool == TOOL.START_POS then
                    playerStartPositions[1] = {x = tx, y = ty}
                end
            end
        end
    end

    hasUnsavedChanges = true
end

-- Save map
function MapEditor.save(name)
    name = name or mapName
    local filename = "custom_maps/" .. name .. ".map"
    love.filesystem.createDirectory("custom_maps")

    local file = love.filesystem.newFile(filename)
    if file:open("w") then
        -- Serialize map data
        local lines = {}
        table.insert(lines, "return {")
        table.insert(lines, string.format('  name = "%s",', name))
        table.insert(lines, string.format('  width = %d,', mapWidth))
        table.insert(lines, string.format('  height = %d,', mapHeight))
        table.insert(lines, '  terrain = {')
        for y = 1, mapHeight do
            local row = {}
            for x = 1, mapWidth do
                local tile = mapData[y] and mapData[y][x] or {terrain = TERRAIN.GRASS}
                table.insert(row, tostring(tile.terrain))
            end
            table.insert(lines, "    {" .. table.concat(row, ",") .. "},")
        end
        table.insert(lines, '  },')
        table.insert(lines, '  objects = {')
        for y = 1, mapHeight do
            for x = 1, mapWidth do
                local tile = mapData[y] and mapData[y][x]
                if tile and tile.object then
                    table.insert(lines, string.format('    {x=%d, y=%d, type="%s"},', x - 1, y - 1, tile.object))
                end
            end
        end
        table.insert(lines, '  },')
        table.insert(lines, '  startPositions = {')
        for i, pos in ipairs(playerStartPositions) do
            if pos then
                table.insert(lines, string.format('    {player=%d, x=%d, y=%d},', i, pos.x, pos.y))
            end
        end
        table.insert(lines, '  },')
        table.insert(lines, "}")

        file:write(table.concat(lines, "\n"))
        file:close()

        hasUnsavedChanges = false
        mapName = name
        print("[MapEditor] Map saved: " .. name)
        return true
    end
    return false
end

-- Load map
function MapEditor.load(name)
    local filename = "custom_maps/" .. name .. ".map"
    local file = love.filesystem.newFile(filename)
    if not file:open("r") then
        print("[MapEditor] Map not found: " .. name)
        return false
    end

    local content = file:read()
    file:close()

    local ok, chunk = pcall(load, content)
    if not ok or not chunk then
        print("[MapEditor] Failed to parse map: " .. name)
        return false
    end

    local dataOk, data = pcall(chunk)
    if not dataOk or type(data) ~= "table" then
        print("[MapEditor] Invalid map data: " .. name)
        return false
    end

    mapName = name
    mapWidth = data.width or 64
    mapHeight = data.height or 64
    mapData = {}

    -- Load terrain
    for y = 1, mapHeight do
        mapData[y] = {}
        for x = 1, mapWidth do
            local terrain = data.terrain and data.terrain[y] and data.terrain[y][x] or TERRAIN.GRASS
            mapData[y][x] = {terrain = terrain, elevation = 0, object = nil}
        end
    end

    -- Load objects
    if data.objects then
        for _, obj in ipairs(data.objects) do
            local ty, tx = obj.y + 1, obj.x + 1
            if mapData[ty] and mapData[ty][tx] then
                mapData[ty][tx].object = obj.type
            end
        end
    end

    -- Load start positions
    playerStartPositions = {}
    if data.startPositions then
        for _, pos in ipairs(data.startPositions) do
            playerStartPositions[pos.player] = {x = pos.x, y = pos.y}
        end
    end

    hasUnsavedChanges = false
    print("[MapEditor] Map loaded: " .. name)
    return true
end

-- List custom maps
function MapEditor.listMaps()
    local maps = {}
    local files = love.filesystem.getDirectoryItems("custom_maps")
    for _, file in ipairs(files) do
        if file:match("%.map$") then
            table.insert(maps, file:gsub("%.map$", ""))
        end
    end
    return maps
end

-- Get map data
function MapEditor.getMapData()
    return mapData
end

-- Get map dimensions
function MapEditor.getMapSize()
    return mapWidth, mapHeight
end

-- Get player start positions
function MapEditor.getStartPositions()
    return playerStartPositions
end

-- Update (call every frame)
function MapEditor.update(dt)
    if not isActive then return end
    -- Handle continuous painting while mouse is down
end

-- Draw editor overlay
function MapEditor.draw()
    if not isActive then return end

    local w, h = love.graphics.getDimensions()

    -- Draw editor UI bar at top
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, 0, w, 40)
    love.graphics.setColor(1, 1, 1, 1)

    -- Tool info
    local toolText = string.format("Tool: %s | Terrain: %d | Brush: %d | Map: %s %dx%d",
        currentTool, currentTerrain, brushSize, mapName, mapWidth, mapHeight)
    love.graphics.print(toolText, 10, 12)

    -- Instructions
    love.graphics.print("F12: Exit | T: Terrain | O: Tree | R: Rock | E: Erase | S: Start Pos | Ctrl+S: Save",
        10, h - 25)
end

-- Handle key press
function MapEditor.keypressed(key)
    if not isActive then return false end

    if key == "t" then
        MapEditor.setTool(TOOL.TERRAIN)
        return true
    elseif key == "o" then
        MapEditor.setTool(TOOL.TREE)
        return true
    elseif key == "r" then
        MapEditor.setTool(TOOL.ROCK)
        return true
    elseif key == "e" then
        MapEditor.setTool(TOOL.ERASE)
        return true
    elseif key == "s" and not (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        MapEditor.setTool(TOOL.START_POS)
        return true
    elseif key == "s" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        MapEditor.save()
        return true
    elseif key == "n" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        MapEditor._newMap(64, 64)
        return true
    elseif key == "[" then
        MapEditor.setBrushSize(brushSize - 1)
        return true
    elseif key == "]" then
        MapEditor.setBrushSize(brushSize + 1)
        return true
    end

    return false
end

-- Handle mouse press
function MapEditor.mousepressed(x, y, button)
    if not isActive then return false end
    if button == 1 then
        -- Convert screen to grid coordinates
        local gx, gy = _G.getTerrainTileOnMouse(x, y)
        if gx and gy then
            MapEditor.applyAt(gx, gy)
        end
        return true
    end
    return false
end

-- Get editor info
function MapEditor.getInfo()
    return {
        active = isActive,
        tool = currentTool,
        terrain = currentTerrain,
        brushSize = brushSize,
        mapName = mapName,
        mapSize = {mapWidth, mapHeight},
        hasUnsavedChanges = hasUnsavedChanges,
    }
end

return MapEditor
