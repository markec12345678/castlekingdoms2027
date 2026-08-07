-- objects/Gameplay/CustomMapSharing.lua
-- Castle Kingdoms 2027 - Custom Map Sharing
-- Share custom maps between players via network

local MapSharing = {}

local initialized = false
local sharedMaps = {}

function MapSharing.init()
    if initialized then return end
    initialized = true
    love.filesystem.createDirectory("shared_maps")
    print("[MapSharing] Initialized (dir: shared_maps/)")
end

-- Export a custom map for sharing
function MapSharing.export(mapName)
    if not initialized then MapSharing.init() end

    local MapEditor = require("objects.QA.MapEditor")
    local mapData = MapEditor.getMapData()
    if not mapData then
        print("[MapSharing] No map data to export")
        return false
    end

    local w, h = MapEditor.getMapSize()
    local startPositions = MapEditor.getStartPositions()

    local export = {
        name = mapName or "custom_map",
        width = w,
        height = h,
        terrain = {},
        objects = {},
        startPositions = startPositions,
        createdDate = os.date("%Y-%m-%d %H:%M:%S"),
        version = "1.28.0",
    }

    -- Serialize terrain
    for y = 1, h do
        export.terrain[y] = {}
        for x = 1, w do
            local tile = mapData[y] and mapData[y][x] or { terrain = 1 }
            export.terrain[y][x] = tile.terrain or 1
            if tile.object then
                table.insert(export.objects, { x = x - 1, y = y - 1, type = tile.object })
            end
        end
    end

    -- Save to shared_maps directory
    local filename = "shared_maps/" .. (mapName or "custom_map") .. ".mapshare"
    local file = love.filesystem.newFile(filename)
    if file:open("w") then
        -- Simple serialization
        local lines = {}
        table.insert(lines, "return {")
        table.insert(lines, string.format('  name = "%s",', export.name))
        table.insert(lines, string.format('  width = %d,', export.width))
        table.insert(lines, string.format('  height = %d,', export.height))
        table.insert(lines, string.format('  version = "%s",', export.version))
        table.insert(lines, string.format('  createdDate = "%s",', export.createdDate))
        table.insert(lines, "  terrain = {")
        for y = 1, #export.terrain do
            local row = {}
            for x = 1, #export.terrain[y] do
                table.insert(row, tostring(export.terrain[y][x]))
            end
            table.insert(lines, "    {" .. table.concat(row, ",") .. "},")
        end
        table.insert(lines, "  },")
        table.insert(lines, "  objects = {")
        for _, obj in ipairs(export.objects) do
            table.insert(lines, string.format('    {x=%d, y=%d, type="%s"},', obj.x, obj.y, obj.type))
        end
        table.insert(lines, "  },")
        table.insert(lines, "  startPositions = {")
        for i, pos in ipairs(export.startPositions) do
            if pos then
                table.insert(lines, string.format('    {player=%d, x=%d, y=%d},', i, pos.x, pos.y))
            end
        end
        table.insert(lines, "  },")
        table.insert(lines, "}")

        file:write(table.concat(lines, "\n"))
        file:close()
        print("[MapSharing] Exported: " .. filename)

        if _G.ModernUI then
            _G.ModernUI.notifySuccess("Mapa izvozena: " .. (mapName or "custom_map"))
        end

        return filename
    end

    return false
end

-- Import a shared map
function MapSharing.import(filename)
    if not initialized then MapSharing.init() end

    local path = "shared_maps/" .. filename
    local file = love.filesystem.newFile(path)
    if not file:open("r") then
        print("[MapSharing] File not found: " .. path)
        return false
    end

    local content = file:read()
    file:close()

    if not content then return false end

    local ok, chunk = pcall(load, content)
    if not ok or not chunk then
        print("[MapSharing] Failed to parse: " .. filename)
        return false
    end

    local dataOk, data = pcall(chunk)
    if not dataOk or type(data) ~= "table" then
        print("[MapSharing] Invalid map data: " .. filename)
        return false
    end

    -- Load into MapEditor
    local MapEditor = require("objects.QA.MapEditor")
    if MapEditor.load(data.name) then
        print("[MapSharing] Imported: " .. data.name)
        if _G.ModernUI then
            _G.ModernUI.notifySuccess("Mapa uvozena: " .. data.name)
        end
        return true
    end

    return false
end

-- List all shared maps
function MapSharing.listSharedMaps()
    local maps = {}
    local files = love.filesystem.getDirectoryItems("shared_maps")
    for _, file in ipairs(files) do
        if file:match("%.mapshare$") then
            local info = love.filesystem.getInfo("shared_maps/" .. file)
            table.insert(maps, {
                filename = file,
                name = file:gsub("%.mapshare$", ""),
                size = info and info.size or 0,
                modified = info and info.modtime or 0,
            })
        end
    end
    table.sort(maps, function(a, b) return a.modified > b.modified end)
    return maps
end

-- Send map to another player (network)
function MapSharing.sendToPlayer(targetPlayerId, mapName)
    if not initialized then return false end

    -- Export map data
    local filename = MapSharing.export(mapName)
    if not filename then return false end

    -- In production: send file data over network
    if _G.GameClient and _G.GameClient.isConnected() then
        local NetworkProtocol = require("objects.Network.NetworkProtocol")
        -- Custom message type for map sharing
        _G.GameClient.send("MAP_SHARE", {
            targetId = targetPlayerId,
            mapName = mapName,
            filename = filename,
        })
        print("[MapSharing] Sent map '" .. mapName .. "' to player " .. targetPlayerId)
    end

    return true
end

-- Get stats
function MapSharing.getStats()
    return {
        sharedMaps = #MapSharing.listSharedMaps(),
    }
end

return MapSharing
