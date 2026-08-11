-- objects/QA/MapEditorEnhanced.lua
-- Castle Kingdoms 2027 v2.9.7 - Enhanced Map Editor
--
-- Advanced map editor with terrain painting, object placement,
-- brush sizes, undo/redo, layers, and export/import.
--
-- Features:
-- - 6 terrain brush types (grass, dirt, stone, water, sand, mountain)
-- - 5 brush sizes (1x1 to 7x7)
-- - Object placement (trees, rocks, buildings, units)
-- - Undo/redo history (50 steps)
-- - 3 layers (terrain, objects, triggers)
-- - Grid overlay toggle
-- - Height map editing
-- - Resource placement
-- - Export/import as .map files
-- - Minimap preview

local MapEditorEnhanced = {}

-- Brush types
local BRUSH_TYPES = {
    grass = { name = "Trava",   color = {0.2, 0.5, 0.15} },
    dirt = { name = "Zemlja",   color = {0.45, 0.35, 0.2} },
    stone = { name = "Kamen",   color = {0.5, 0.5, 0.5} },
    water = { name = "Voda",    color = {0.1, 0.3, 0.6} },
    sand = { name = "Pesek",    color = {0.7, 0.65, 0.4} },
    mountain = { name = "Gora",  color = {0.3, 0.3, 0.35} },
    erase = { name = "Briši",   color = {0.1, 0.1, 0.1} },
}

MapEditorEnhanced.BRUSH_TYPES = BRUSH_TYPES

local BRUSH_SIZES = {1, 3, 5, 7, 9}

-- Object types for placement
local OBJECT_TYPES = {
    tree = { name = "Drevo",     category = "nature" },
    rock = { name = "Skala",     category = "nature" },
    bush = { name = "Grm",       category = "nature" },
    gold_mine = { name = "Rudnik zlata", category = "resource" },
    iron_mine = { name = "Rudnik železa", category = "resource" },
    stone_quarry = { name = "Kamnolom", category = "resource" },
    keep = { name = "Grad",      category = "building" },
    barracks = { name = "Barake", category = "building" },
    spawn_point = { name = "Točka rojstva", category = "trigger" },
    victory_point = { name = "Točka zmage", category = "trigger" },
}

MapEditorEnhanced.OBJECT_TYPES = OBJECT_TYPES

local initialized = false
local isActive = false
local currentBrush = "grass"
local currentBrushSize = 3
local currentBrushSizeIndex = 2
local currentLayer = "terrain"  -- terrain, objects, triggers
local currentObject = "tree"
local gridVisible = true
local undoHistory = {}
local redoHistory = {}
local maxHistory = 50
local mapData = nil
local cursorGx = 0
local cursorGy = 0

-- Layers
local layers = {
    terrain = {},   -- [y][x] = terrainType
    objects = {},   -- [y][x] = { type, faction }
    triggers = {},  -- [y][x] = { type, data }
}

function MapEditorEnhanced.init()
    if initialized then return end
    initialized = true
    print("[MapEditorEnhanced] Initialized")
end

-- Toggle editor
function MapEditorEnhanced.toggle()
    if not isActive then
        MapEditorEnhanced.open()
    else
        MapEditorEnhanced.close()
    end
    return isActive
end

-- Open editor
function MapEditorEnhanced.open()
    isActive = true
    -- Initialize map data if not set
    if not mapData then
        local mapSize = (_G.chunksWide or 32) * (_G.chunkWidth or 32)
        MapEditorEnhanced._initLayers(mapSize)
    end
    if _G.ModernUI then
        _G.ModernUI.notifySuccess("Map Editor odprt — F4 za zaprtje")
    end
    print("[MapEditorEnhanced] Editor opened")
end

-- Close editor
function MapEditorEnhanced.close()
    isActive = false
    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Map Editor zaprt")
    end
    print("[MapEditorEnhanced] Editor closed")
end

-- Initialize layers
function MapEditorEnhanced._initLayers(size)
    mapData = { size = size }
    layers.terrain = {}
    layers.objects = {}
    layers.triggers = {}
    for y = 0, size - 1 do
        layers.terrain[y] = {}
        layers.objects[y] = {}
        layers.triggers[y] = {}
        for x = 0, size - 1 do
            layers.terrain[y][x] = "grass"
            layers.objects[y][x] = nil
            layers.triggers[y][x] = nil
        end
    end
end

-- Set brush type
function MapEditorEnhanced.setBrush(brushType)
    if not BRUSH_TYPES[brushType] then return false end
    currentBrush = brushType
    return true
end

-- Cycle brush type
function MapEditorEnhanced.cycleBrush()
    local brushes = {}
    for k, _ in pairs(BRUSH_TYPES) do table.insert(brushes, k) end
    table.sort(brushes)
    local idx = 1
    for i, b in ipairs(brushes) do
        if b == currentBrush then idx = i break end
    end
    currentBrush = brushes[(idx % #brushes) + 1]
    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Čopič: " .. BRUSH_TYPES[currentBrush].name)
    end
    return currentBrush
end

-- Set brush size
function MapEditorEnhanced.setBrushSize(size)
    for i, s in ipairs(BRUSH_SIZES) do
        if s == size then
            currentBrushSize = size
            currentBrushSizeIndex = i
            return true
        end
    end
    return false
end

-- Cycle brush size
function MapEditorEnhanced.cycleBrushSize()
    currentBrushSizeIndex = (currentBrushSizeIndex % #BRUSH_SIZES) + 1
    currentBrushSize = BRUSH_SIZES[currentBrushSizeIndex]
    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Velikost čopiča: " .. currentBrushSize .. "x" .. currentBrushSize)
    end
    return currentBrushSize
end

-- Set layer
function MapEditorEnhanced.setLayer(layer)
    if layer ~= "terrain" and layer ~= "objects" and layer ~= "triggers" then return false end
    currentLayer = layer
    return true
end

-- Cycle layer
function MapEditorEnhanced.cycleLayer()
    local layerOrder = {"terrain", "objects", "triggers"}
    local idx = 1
    for i, l in ipairs(layerOrder) do
        if l == currentLayer then idx = i break end
    end
    currentLayer = layerOrder[(idx % #layerOrder) + 1]
    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Sloj: " .. currentLayer)
    end
    return currentLayer
end

-- Set current object
function MapEditorEnhanced.setObject(objType)
    if not OBJECT_TYPES[objType] then return false end
    currentObject = objType
    return true
end

-- Apply brush at position
function MapEditorEnhanced.applyBrush(gx, gy)
    if not isActive or not mapData then return false end

    -- Save state for undo
    MapEditorEnhanced._pushUndo()

    local half = math.floor(currentBrushSize / 2)
    for dy = -half, half do
        for dx = -half, half do
            local x = gx + dx
            local y = gy + dy
            if x >= 0 and x < mapData.size and y >= 0 and y < mapData.size then
                if currentLayer == "terrain" then
                    if currentBrush == "erase" then
                        layers.terrain[y][x] = "grass"
                    else
                        layers.terrain[y][x] = currentBrush
                    end
                elseif currentLayer == "objects" then
                    if currentBrush == "erase" then
                        layers.objects[y][x] = nil
                    else
                        layers.objects[y][x] = { type = currentObject, faction = 1 }
                    end
                elseif currentLayer == "triggers" then
                    if currentBrush == "erase" then
                        layers.triggers[y][x] = nil
                    else
                        layers.triggers[y][x] = { type = currentObject }
                    end
                end
            end
        end
    end
    return true
end

-- Undo
function MapEditorEnhanced.undo()
    if #undoHistory == 0 then return false end
    -- Push current state to redo
    local current = MapEditorEnhanced._snapshotLayers()
    table.insert(redoHistory, current)
    -- Pop and restore from undo
    local state = table.remove(undoHistory)
    MapEditorEnhanced._restoreLayers(state)
    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Undo (" .. #undoHistory .. " preostalo)")
    end
    return true
end

-- Redo
function MapEditorEnhanced.redo()
    if #redoHistory == 0 then return false end
    local current = MapEditorEnhanced._snapshotLayers()
    table.insert(undoHistory, current)
    local state = table.remove(redoHistory)
    MapEditorEnhanced._restoreLayers(state)
    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Redo (" .. #redoHistory .. " preostalo)")
    end
    return true
end

-- Push undo state
function MapEditorEnhanced._pushUndo()
    local snapshot = MapEditorEnhanced._snapshotLayers()
    table.insert(undoHistory, snapshot)
    while #undoHistory > maxHistory do
        table.remove(undoHistory, 1)
    end
    -- Clear redo on new action
    redoHistory = {}
end

-- Snapshot layers (shallow copy)
function MapEditorEnhanced._snapshotLayers()
    local snapshot = { terrain = {}, objects = {}, triggers = {} }
    for y, row in pairs(layers.terrain) do
        snapshot.terrain[y] = {}
        for x, v in pairs(row) do snapshot.terrain[y][x] = v end
    end
    for y, row in pairs(layers.objects) do
        snapshot.objects[y] = {}
        for x, v in pairs(row) do
            snapshot.objects[y][x] = v and { type = v.type, faction = v.faction } or nil
        end
    end
    for y, row in pairs(layers.triggers) do
        snapshot.triggers[y] = {}
        for x, v in pairs(row) do
            snapshot.triggers[y][x] = v and { type = v.type } or nil
        end
    end
    return snapshot
end

-- Restore layers from snapshot
function MapEditorEnhanced._restoreLayers(snapshot)
    layers.terrain = snapshot.terrain
    layers.objects = snapshot.objects
    layers.triggers = snapshot.triggers
end

-- Toggle grid
function MapEditorEnhanced.toggleGrid()
    gridVisible = not gridVisible
    return gridVisible
end

-- Export map to file
function MapEditorEnhanced.export(filename)
    if not mapData then return false end
    local name = filename or "custom_map"
    name = name:gsub("[^%w_]", "_"):lower()
    local path = "maps/" .. name .. ".map"
    love.filesystem.createDirectory("maps")

    local file = love.filesystem.newFile(path)
    if file:open("w") then
        local lines = {"return {"}
        table.insert(lines, string.format("  size = %d,", mapData.size))
        -- Terrain
        table.insert(lines, "  terrain = {")
        for y, row in pairs(layers.terrain) do
            local rowParts = {}
            for x, v in pairs(row) do
                table.insert(rowParts, string.format("[%d]=%q", x, v))
            end
            table.insert(lines, string.format("    [%d] = {%s},", y, table.concat(rowParts, ",")))
        end
        table.insert(lines, "  },")
        -- Objects
        table.insert(lines, "  objects = {")
        for y, row in pairs(layers.objects) do
            for x, v in pairs(row) do
                if v then
                    table.insert(lines, string.format("    [%d] = { [%d] = { type=%q, faction=%d } },", y, x, v.type, v.faction or 1))
                end
            end
        end
        table.insert(lines, "  },")
        -- Triggers
        table.insert(lines, "  triggers = {")
        for y, row in pairs(layers.triggers) do
            for x, v in pairs(row) do
                if v then
                    table.insert(lines, string.format("    [%d] = { [%d] = { type=%q } },", y, x, v.type))
                end
            end
        end
        table.insert(lines, "  },")
        table.insert(lines, "}")
        file:write(table.concat(lines, "\n"))
        file:close()
        if _G.ModernUI then
            _G.ModernUI.notifySuccess("Mapa izvožena: " .. name)
        end
        return true
    end
    return false
end

-- Import map from file
function MapEditorEnhanced.import(filename)
    local name = filename:gsub("[^%w_]", "_"):lower()
    local path = "maps/" .. name .. ".map"
    local file = love.filesystem.newFile(path)
    if file:open("r") then
        local content = file:read()
        file:close()
        if content then
            local ok, chunk = pcall(load, content)
            if ok and chunk then
                local dataOk, data = pcall(chunk)
                if dataOk and type(data) == "table" then
                    mapData = { size = data.size or 128 }
                    layers.terrain = data.terrain or {}
                    layers.objects = data.objects or {}
                    layers.triggers = data.triggers or {}
                    undoHistory = {}
                    redoHistory = {}
                    if _G.ModernUI then
                        _G.ModernUI.notifySuccess("Mapa uvožena: " .. name)
                    end
                    return true
                end
            end
        end
    end
    return false
end

-- Mouse handler
function MapEditorEnhanced.mousepressed(x, y, button)
    if not isActive then return false end
    if button == 1 then
        -- Apply brush
        if _G.getTerrainTileOnMouse then
            local gx, gy = _G.getTerrainTileOnMouse(x, y)
            if gx and gy then
                MapEditorEnhanced.applyBrush(gx, gy)
                return true
            end
        end
    end
    return false
end

-- Mouse move handler
function MapEditorEnhanced.mousemoved(x, y)
    if not isActive then return end
    if _G.getTerrainTileOnMouse then
        local gx, gy = _G.getTerrainTileOnMouse(x, y)
        if gx and gy then
            cursorGx = gx
            cursorGy = gy
        end
    end
end

-- Key handler
function MapEditorEnhanced.keypressed(key)
    if not isActive then return false end

    if key == "z" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        MapEditorEnhanced.undo()
        return true
    elseif key == "y" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        MapEditorEnhanced.redo()
        return true
    elseif key == "b" then
        MapEditorEnhanced.cycleBrush()
        return true
    elseif key == "s" then
        MapEditorEnhanced.cycleBrushSize()
        return true
    elseif key == "l" then
        MapEditorEnhanced.cycleLayer()
        return true
    elseif key == "g" then
        MapEditorEnhanced.toggleGrid()
        return true
    elseif key == "e" then
        MapEditorEnhanced.export()
        return true
    end
    return false
end

-- Draw editor overlay
function MapEditorEnhanced.draw()
    if not isActive or not mapData then return end

    -- Draw grid
    if gridVisible and _G.state and _G.state.viewXview then
        love.graphics.setColor(0.5, 0.5, 0.5, 0.2)
        local tileSize = _G.tileWidth or 32
        local startX = -(_G.state.viewXview or 0) % tileSize
        local startY = -(_G.state.viewYview or 0) % tileSize
        local screenWidth = love.graphics.getWidth()
        local screenHeight = love.graphics.getHeight()
        for x = startX, screenWidth, tileSize do
            love.graphics.line(x, 0, x, screenHeight)
        end
        for y = startY, screenHeight, tileSize do
            love.graphics.line(0, y, screenWidth, y)
        end
    end

    -- Draw brush preview at cursor
    if _G.state and _G.state.viewXview then
        local brush = BRUSH_TYPES[currentBrush]
        local half = math.floor(currentBrushSize / 2)
        local sx = _G.IsoToScreenX(cursorGx, cursorGy) - (_G.state.viewXview or 0)
        local sy = _G.IsoToScreenY(cursorGx, cursorGy) - (_G.state.viewYview or 0)
        love.graphics.setColor(brush.color[1], brush.color[2], brush.color[3], 0.4)
        love.graphics.circle("fill", sx, sy, currentBrushSize * 8)
        love.graphics.setColor(brush.color[1], brush.color[2], brush.color[3], 0.8)
        love.graphics.circle("line", sx, sy, currentBrushSize * 8)
    end

    -- Draw editor HUD
    local hudY = 5
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 5, hudY, 300, 90)
    love.graphics.setColor(1, 1, 1, 1)
    local brush = BRUSH_TYPES[currentBrush]
    love.graphics.print("MAP EDITOR", 10, hudY + 5)
    love.graphics.print("Čopič: " .. brush.name .. " (" .. currentBrushSize .. "x" .. currentBrushSize .. ")", 10, hudY + 22)
    love.graphics.print("Sloj: " .. currentLayer, 10, hudY + 39)
    love.graphics.print("Undo: " .. #undoHistory .. " | Redo: " .. #redoHistory, 10, hudY + 56)
    love.graphics.print("[B]ruš [S]velikost [L]sloj [G]mreža [E]izvoz [Ctrl+Z]undo", 10, hudY + 73)
    love.graphics.setColor(1, 1, 1, 1)
end

-- Check if active
function MapEditorEnhanced.isActive()
    return isActive
end

-- Get stats
function MapEditorEnhanced.getStats()
    return {
        active = isActive,
        brush = currentBrush,
        brushSize = currentBrushSize,
        layer = currentLayer,
        object = currentObject,
        gridVisible = gridVisible,
        undoCount = #undoHistory,
        redoCount = #redoHistory,
        mapSize = mapData and mapData.size or 0,
    }
end

return MapEditorEnhanced
