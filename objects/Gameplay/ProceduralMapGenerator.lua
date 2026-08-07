-- objects/Gameplay/ProceduralMapGenerator.lua
-- Castle Kingdoms 2027 v2.9.0 - Procedural Map Generator
--
-- Generates random maps with varied terrain, resource distribution,
-- and strategic features for endless replayability.
--
-- Map features:
-- - 6 terrain types (grass, dirt, stone, water, sand, mountain)
-- - Resource placement (wood, stone, iron, food sources)
-- - Strategic features (rivers, forests, hills, chokepoints)
-- - Player and AI starting positions
-- - 4 map sizes (small, medium, large, huge)
-- - 5 biome types (temperate, arid, mountainous, coastal, mixed)

local MapGen = {}

local BIOMES = {
    temperate = {
        name = "Temperat",
        nameEn = "Temperate",
        baseTerrain = "grass",
        forestChance = 0.15,
        waterChance = 0.05,
        mountainChance = 0.03,
        stoneChance = 0.05,
        dirtChance = 0.08,
        sandChance = 0.02,
    },
    arid = {
        name = "Ariden",
        nameEn = "Arid",
        baseTerrain = "dirt",
        forestChance = 0.05,
        waterChance = 0.02,
        mountainChance = 0.08,
        stoneChance = 0.10,
        dirtChance = 0.30,
        sandChance = 0.15,
    },
    mountainous = {
        name = "Gorat",
        nameEn = "Mountainous",
        baseTerrain = "stone",
        forestChance = 0.08,
        waterChance = 0.03,
        mountainChance = 0.25,
        stoneChance = 0.20,
        dirtChance = 0.05,
        sandChance = 0.02,
    },
    coastal = {
        name = "Obalni",
        nameEn = "Coastal",
        baseTerrain = "grass",
        forestChance = 0.10,
        waterChance = 0.20,
        mountainChance = 0.02,
        stoneChance = 0.05,
        dirtChance = 0.05,
        sandChance = 0.15,
    },
    mixed = {
        name = "Mešan",
        nameEn = "Mixed",
        baseTerrain = "grass",
        forestChance = 0.12,
        waterChance = 0.08,
        mountainChance = 0.10,
        stoneChance = 0.08,
        dirtChance = 0.10,
        sandChance = 0.05,
    },
}

MapGen.BIOMES = BIOMES

local MAP_SIZES = {
    small =  { tiles = 128, name = "Majhna" },
    medium = { tiles = 192, name = "Srednja" },
    large =  { tiles = 256, name = "Velika" },
    huge =   { tiles = 384, name = "Ogromna" },
}

MapGen.MAP_SIZES = MAP_SIZES

local initialized = false

function MapGen.init()
    if initialized then return end
    initialized = true
    print("[MapGen] Initialized with " .. MapGen._getBiomeCount() .. " biomes, " .. MapGen._getSizeCount() .. " sizes")
end

function MapGen._getBiomeCount()
    local count = 0
    for _ in pairs(BIOMES) do count = count + 1 end
    return count
end

function MapGen._getSizeCount()
    local count = 0
    for _ in pairs(MAP_SIZES) do count = count + 1 end
    return count
end

-- Generate a procedural map
function MapGen.generate(biomeType, sizeName, seed, playerCount)
    biomeType = biomeType or "temperate"
    sizeName = sizeName or "medium"
    seed = seed or os.time()
    playerCount = playerCount or 2

    local biome = BIOMES[biomeType] or BIOMES.temperate
    local size = MAP_SIZES[sizeName] or MAP_SIZES.medium
    local mapSize = size.tiles

    math.randomseed(seed)

    local mapData = {
        name = "Procedural_" .. biome.name .. "_" .. mapSize,
        biome = biomeType,
        size = mapSize,
        sizeName = sizeName,
        seed = seed,
        terrain = {},
        features = {},
        resources = {},
        startPositions = {},
        playerCount = playerCount,
    }

    -- Generate terrain grid
    MapGen._generateTerrain(mapData, biome, mapSize)

    -- Generate rivers
    MapGen._generateRivers(mapData, biome, mapSize)

    -- Generate forests
    MapGen._generateForests(mapData, biome, mapSize)

    -- Generate mountains
    MapGen._generateMountains(mapData, biome, mapSize)

    -- Place resources
    MapGen._placeResources(mapData, mapSize)

    -- Place starting positions
    MapGen._placeStartPositions(mapData, mapSize, playerCount)

    -- Identify strategic features
    MapGen._identifyFeatures(mapData, mapSize)

    print("[MapGen] Generated: " .. mapData.name .. " (" .. mapSize .. "x" .. mapSize .. ", seed: " .. seed .. ")")
    return mapData
end

-- Generate base terrain
function MapGen._generateTerrain(mapData, biome, mapSize)
    for y = 0, mapSize - 1 do
        mapData.terrain[y] = {}
        for x = 0, mapSize - 1 do
            local r = math.random()
            local terrain = biome.baseTerrain
            if r < biome.waterChance then terrain = "water"
            elseif r < biome.waterChance + biome.mountainChance then terrain = "mountain"
            elseif r < biome.waterChance + biome.mountainChance + biome.stoneChance then terrain = "stone"
            elseif r < biome.waterChance + biome.mountainChance + biome.stoneChance + biome.dirtChance then terrain = "dirt"
            elseif r < biome.waterChance + biome.mountainChance + biome.stoneChance + biome.dirtChance + biome.sandChance then terrain = "sand"
            end
            mapData.terrain[y][x] = terrain
        end
    end
end

-- Generate rivers (simple line from edge to edge)
function MapGen._generateRivers(mapData, biome, mapSize)
    local riverCount = math.random(0, 3)
    for r = 1, riverCount do
        local startX = math.random(0, mapSize - 1)
        local startY = 0
        local endX = math.random(0, mapSize - 1)
        local endY = mapSize - 1
        local steps = mapSize
        for i = 0, steps do
            local t = i / steps
            local x = math.floor(startX + (endX - startX) * t + math.random(-3, 3))
            local y = math.floor(startY + (endY - startY) * t)
            if x >= 0 and x < mapSize and y >= 0 and y < mapSize then
                mapData.terrain[y][x] = "water"
                -- Widen river
                if x + 1 < mapSize then mapData.terrain[y][x + 1] = "water" end
            end
        end
    end
end

-- Generate forest clusters
function MapGen._generateForests(mapData, biome, mapSize)
    local forestCount = math.floor(mapSize * mapSize * biome.forestChance / 20)
    for f = 1, forestCount do
        local cx = math.random(5, mapSize - 6)
        local cy = math.random(5, mapSize - 6)
        local radius = math.random(3, 8)
        for dy = -radius, radius do
            for dx = -radius, radius do
                local x = cx + dx
                local y = cy + dy
                if x >= 0 and x < mapSize and y >= 0 and y < mapSize then
                    local dist = math.sqrt(dx * dx + dy * dy)
                    if dist <= radius and math.random() < 0.7 then
                        if mapData.terrain[y][x] ~= "water" then
                            mapData.terrain[y][x] = "forest"
                        end
                    end
                end
            end
        end
    end
end

-- Generate mountain ranges
function MapGen._generateMountains(mapData, biome, mapSize)
    local mountainCount = math.floor(mapSize * mapSize * biome.mountainChance / 30)
    for m = 1, mountainCount do
        local cx = math.random(5, mapSize - 6)
        local cy = math.random(5, mapSize - 6)
        local radius = math.random(4, 10)
        for dy = -radius, radius do
            for dx = -radius, radius do
                local x = cx + dx
                local y = cy + dy
                if x >= 0 and x < mapSize and y >= 0 and y < mapSize then
                    local dist = math.sqrt(dx * dx + dy * dy)
                    if dist <= radius and math.random() < 0.6 then
                        mapData.terrain[y][x] = "mountain"
                    end
                end
            end
        end
    end
end

-- Place resources on the map
function MapGen._placeResources(mapData, mapSize)
    -- Wood resources (near forests)
    for i = 1, math.floor(mapSize / 10) do
        table.insert(mapData.resources, {
            type = "wood",
            gx = math.random(5, mapSize - 6),
            gy = math.random(5, mapSize - 6),
            amount = math.random(200, 500),
        })
    end
    -- Stone resources (near mountains)
    for i = 1, math.floor(mapSize / 15) do
        table.insert(mapData.resources, {
            type = "stone",
            gx = math.random(5, mapSize - 6),
            gy = math.random(5, mapSize - 6),
            amount = math.random(100, 300),
        })
    end
    -- Iron resources
    for i = 1, math.floor(mapSize / 20) do
        table.insert(mapData.resources, {
            type = "iron",
            gx = math.random(5, mapSize - 6),
            gy = math.random(5, mapSize - 6),
            amount = math.random(50, 150),
        })
    end
    -- Food resources
    for i = 1, math.floor(mapSize / 8) do
        table.insert(mapData.resources, {
            type = "food",
            gx = math.random(5, mapSize - 6),
            gy = math.random(5, mapSize - 6),
            amount = math.random(100, 250),
        })
    end
end

-- Place starting positions for players
function MapGen._placeStartPositions(mapData, mapSize, playerCount)
    local margin = math.floor(mapSize * 0.15)
    local positions = {}

    if playerCount == 2 then
        positions = {
            { x = margin, y = mapSize - margin },
            { x = mapSize - margin, y = margin },
        }
    elseif playerCount == 3 then
        positions = {
            { x = margin, y = mapSize - margin },
            { x = mapSize - margin, y = margin },
            { x = mapSize / 2, y = mapSize / 2 },
        }
    elseif playerCount == 4 then
        positions = {
            { x = margin, y = margin },
            { x = mapSize - margin, y = margin },
            { x = margin, y = mapSize - margin },
            { x = mapSize - margin, y = mapSize - margin },
        }
    else
        -- Distribute in a circle
        for i = 1, playerCount do
            local angle = (i / playerCount) * math.pi * 2
            local radius = mapSize * 0.35
            positions[i] = {
                x = math.floor(mapSize / 2 + math.cos(angle) * radius),
                y = math.floor(mapSize / 2 + math.sin(angle) * radius),
            }
        end
    end

    for i, pos in ipairs(positions) do
        pos.x = math.max(5, math.min(mapSize - 6, pos.x))
        pos.y = math.max(5, math.min(mapSize - 6, pos.y))
        pos.faction = i
        table.insert(mapData.startPositions, pos)
        -- Clear terrain around start position
        for dy = -3, 3 do
            for dx = -3, 3 do
                local x = pos.x + dx
                local y = pos.y + dy
                if x >= 0 and x < mapSize and y >= 0 and y < mapSize then
                    mapData.terrain[y][x] = "grass"
                end
            end
        end
    end
end

-- Identify strategic features
function MapGen._identifyFeatures(mapData, mapSize)
    -- Count terrain types
    local counts = {}
    for y = 0, mapSize - 1 do
        for x = 0, mapSize - 1 do
            local t = mapData.terrain[y] and mapData.terrain[y][x] or "grass"
            counts[t] = (counts[t] or 0) + 1
        end
    end
    mapData.terrainCounts = counts

    -- Find chokepoints (narrow passages between water/mountains)
    local chokepoints = 0
    for y = 1, mapSize - 2 do
        for x = 1, mapSize - 2 do
            local t = mapData.terrain[y][x]
            if t ~= "water" and t ~= "mountain" then
                local blockedN = (mapData.terrain[y-1][x] == "water" or mapData.terrain[y-1][x] == "mountain")
                local blockedS = (mapData.terrain[y+1][x] == "water" or mapData.terrain[y+1][x] == "mountain")
                local blockedE = (mapData.terrain[y][x+1] == "water" or mapData.terrain[y][x+1] == "mountain")
                local blockedW = (mapData.terrain[y][x-1] == "water" or mapData.terrain[y][x-1] == "mountain")
                if (blockedN and blockedS and not blockedE and not blockedW) or
                   (blockedE and blockedW and not blockedN and not blockedS) then
                    chokepoints = chokepoints + 1
                end
            end
        end
    end
    mapData.features.chokepoints = chokepoints
    mapData.features.resourceCount = #mapData.resources
    mapData.features.totalTiles = mapSize * mapSize
end

-- Get map summary
function MapGen.getSummary(mapData)
    if not mapData then return nil end
    local biome = BIOMES[mapData.biome] or {}
    local size = MAP_SIZES[mapData.sizeName] or {}
    return {
        name = mapData.name,
        biome = mapData.biome,
        biomeName = biome.name,
        size = mapData.size,
        sizeName = size.name,
        seed = mapData.seed,
        playerCount = mapData.playerCount,
        resourceCount = #mapData.resources,
        chokepoints = mapData.features.chokepoints or 0,
        terrainCounts = mapData.terrainCounts,
    }
end

-- Get all available biomes
function MapGen.getBiomes()
    local result = {}
    for id, biome in pairs(BIOMES) do
        table.insert(result, { id = id, name = biome.name, nameEn = biome.nameEn })
    end
    return result
end

-- Get all map sizes
function MapGen.getSizes()
    local result = {}
    for id, size in pairs(MAP_SIZES) do
        table.insert(result, { id = id, name = size.name, tiles = size.tiles })
    end
    return result
end

-- Get stats
function MapGen.getStats()
    return {
        biomeCount = MapGen._getBiomeCount(),
        sizeCount = MapGen._getSizeCount(),
        totalCombinations = MapGen._getBiomeCount() * MapGen._getSizeCount(),
    }
end

return MapGen
