-- objects/Gameplay/MapSizeSelector.lua
-- Castle Kingdoms 2027 - Map Size Selector
-- Allows players to choose map size: Small, Medium, Large, Huge

local MapSizeSelector = {}

local MAP_SIZES = {
    small  = { name = "Majhna",   chunks = 4,  tiles = 128,  description = "Hitra igra za 1v1" },
    medium = { name = "Srednja",  chunks = 8,  tiles = 256,  description = "Standardna velikost" },
    large  = { name = "Velika",   chunks = 16, tiles = 512,  description = "Vec prostora za gradnjo" },
    huge   = { name = "Ogromna",  chunks = 24, tiles = 768,  description = "Epicne bitke, dolge igre" },
}

MapSizeSelector.MAP_SIZES = MAP_SIZES

local currentSize = "medium"
local initialized = false

function MapSizeSelector.init()
    if initialized then return end
    initialized = true
    print("[MapSizeSelector] Initialized (default: " .. currentSize .. ")")
end

function MapSizeSelector.set(sizeName)
    if not MAP_SIZES[sizeName] then
        print("[MapSizeSelector] Unknown size: " .. tostring(sizeName))
        return false
    end
    currentSize = sizeName
    print("[MapSizeSelector] Map size: " .. sizeName .. " (" .. MAP_SIZES[sizeName].name .. ", " .. MAP_SIZES[sizeName].tiles .. " tiles)")
    return true
end

function MapSizeSelector.get()
    return currentSize
end

function MapSizeSelector.getInfo()
    return MAP_SIZES[currentSize]
end

function MapSizeSelector.getChunks()
    return MAP_SIZES[currentSize].chunks
end

function MapSizeSelector.getTiles()
    return MAP_SIZES[currentSize].tiles
end

function MapSizeSelector.getAll()
    local list = {}
    for name, info in pairs(MAP_SIZES) do
        table.insert(list, {
            name = name,
            displayName = info.name,
            tiles = info.tiles,
            chunks = info.chunks,
            description = info.description,
            isCurrent = name == currentSize,
        })
    end
    table.sort(list, function(a, b) return a.tiles < b.tiles end)
    return list
end

function MapSizeSelector.cycle()
    local order = {"small", "medium", "large", "huge"}
    local idx = 1
    for i, s in ipairs(order) do
        if s == currentSize then idx = i break end
    end
    local next = order[(idx % #order) + 1]
    MapSizeSelector.set(next)
    return next
end

-- Apply map size to game state
function MapSizeSelector.applyToGame()
    local info = MAP_SIZES[currentSize]
    if not info then return end

    -- Set chunk counts
    _G.chunksWide = info.chunks
    _G.chunksHigh = info.chunks

    print("[MapSizeSelector] Applied: " .. currentSize .. " (" .. info.chunks .. "x" .. info.chunks .. " chunks)")
end

return MapSizeSelector
