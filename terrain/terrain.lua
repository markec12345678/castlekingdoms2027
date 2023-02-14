local tileQuads = require("objects.object_quads")
local ScreenToIsoX, ScreenToIsoY = _G.ScreenToIsoX, _G.ScreenToIsoY
local tileWidth, tileHeight = _G.tileWidth, _G.tileHeight
-- Terrain Initialize
----Rows and columns
local chunkWidth, chunkHeight = _G.chunkWidth, _G.chunkHeight
local tilesToUpdateInChunk = _G.newAutotable(4)
local secondaryTilesToUpdateInChunk = _G.newAutotable(4)
local tertiaryTilesToUpdateInChunk = _G.newAutotable(4)
local chunksSet = newAutotable(2)
----Chunk 2D array
-- Statuses: (DEPRECATED)
-- [1] loaded unsaved
-- [2] unloaded - chunk exist on hard disk
-- [3] loaded saved - chunk hasn't been changed so no need to save it
-- nil - chunk needs to be generated first

----Generate spriteBatch
local terrainImage = _G.objectAtlas
local heightmap = _G.state.map.heightmap
_G.buildingheightmap = _G.state.map.buildingheightmap
local tileheight = _G.buildingheightmap
local terrainTile = _G.state.map.terrainTile
_G.terrainBiome = {
    abundantGrass = "abundant_grass",
    dirt = "dirt",
    none = "none",
    scarceGrass = "scarce_grass",
    yellowGrass = "yellow_grass",
    orangeGrass = "orange_grass",
    pitchGrass = "pitch_grass",
    mountainGrass = "mountain_grass_b",
    beach = "beach",
    sea = "sea_deep",
    seaBeach = "sea_beach",
    seaWalkable = "sea_walkable",
    abundantGrassStonesWhite = "land_stones_1_white_rock"
}
local terrain = _G.state.map.terrain
_G.terrainBatch = newAutotable(2)
local terrainBatch = _G.terrainBatch
terrainBatch[0][0] = love.graphics.newSpriteBatch(terrainImage, chunkWidth * chunkHeight)

local function checkMaxSizeBiome(biome, cx, cy, i, o, keysToSkip)
    local currentHeight = 0
    if _G.state.map.shadowmap[cx][cy][i][o] ~= 0 and _G.state.map.shadowmap[cx][cy][i][o] ~= nil then
        return 1
    end
    if heightmap[cx][cy][i + 0][o + 0] ~= nil and heightmap[cx][cy][i + 0][o + 0] ~= currentHeight then
        return 1
    end
    if i + 1 >= chunkWidth - 1 or o + 1 >= chunkHeight - 1 then
        return 1
    end
    if _G.state.map.terrain[cx][cy][i + 0][o + 1] ~= biome or keysToSkip[cx][cy][i + 0][o + 1] then
        return 1
    end
    if heightmap[cx][cy][i + 0][o + 1] ~= nil and heightmap[cx][cy][i + 0][o + 1] ~= currentHeight then
        return 1
    end
    if _G.state.map.shadowmap[cx][cy][i + 0][o + 1] ~= 0 and _G.state.map.shadowmap[cx][cy][i + 0][o + 1] ~= nil then
        return 1
    end
    if _G.state.map.terrain[cx][cy][i + 1][o + 1] ~= biome or keysToSkip[cx][cy][i + 1][o + 1] then
        return 1
    end
    if heightmap[cx][cy][i + 1][o + 1] ~= nil and heightmap[cx][cy][i + 1][o + 1] ~= currentHeight then
        return 1
    end
    if _G.state.map.shadowmap[cx][cy][i + 1][o + 1] ~= 0 and _G.state.map.shadowmap[cx][cy][i + 1][o + 1] ~= nil then
        return 1
    end
    if _G.state.map.terrain[cx][cy][i + 1][o + 0] ~= biome or keysToSkip[cx][cy][i + 1][o + 0] then
        return 1
    end
    if heightmap[cx][cy][i + 1][o + 0] ~= nil and heightmap[cx][cy][i + 1][o + 0] ~= currentHeight then
        return 1
    end
    if _G.state.map.shadowmap[cx][cy][i + 1][o + 0] ~= 0 and _G.state.map.shadowmap[cx][cy][i + 1][o + 0] ~= nil then
        return 1
    end
    if i + 2 >= chunkWidth - 1 or o + 2 >= chunkHeight - 1 then
        return 2
    end
    if _G.state.map.shadowmap[cx][cy][i + 2][o + 2] ~= 0 and _G.state.map.shadowmap[cx][cy][i + 2][o + 2] ~= nil then
        return 2
    end
    if _G.state.map.terrain[cx][cy][i + 2][o + 0] ~= biome or keysToSkip[cx][cy][i + 2][o + 0] then
        return 2
    end
    if heightmap[cx][cy][i + 2][o + 0] ~= nil and heightmap[cx][cy][i + 2][o + 0] ~= currentHeight then
        return 2
    end
    if _G.state.map.shadowmap[cx][cy][i + 2][o + 0] ~= 0 and _G.state.map.shadowmap[cx][cy][i + 2][o + 0] ~= nil then
        return 2
    end
    if _G.state.map.terrain[cx][cy][i + 2][o + 1] ~= biome or keysToSkip[cx][cy][i + 2][o + 1] then
        return 2
    end
    if heightmap[cx][cy][i + 2][o + 1] ~= nil and heightmap[cx][cy][i + 2][o + 1] ~= currentHeight then
        return 2
    end
    if _G.state.map.shadowmap[cx][cy][i + 2][o + 1] ~= 0 and _G.state.map.shadowmap[cx][cy][i + 2][o + 1] ~= nil then
        return 2
    end
    if _G.state.map.terrain[cx][cy][i + 2][o + 2] ~= biome or keysToSkip[cx][cy][i + 2][o + 2] then
        return 2
    end
    if heightmap[cx][cy][i + 2][o + 2] ~= nil and heightmap[cx][cy][i + 2][o + 2] ~= currentHeight then
        return 2
    end
    if _G.state.map.shadowmap[cx][cy][i + 2][o + 2] ~= 0 and _G.state.map.shadowmap[cx][cy][i + 2][o + 2] ~= nil then
        return 2
    end
    if _G.state.map.terrain[cx][cy][i + 0][o + 2] ~= biome or keysToSkip[cx][cy][i + 0][o + 2] then
        return 2
    end
    if heightmap[cx][cy][i + 0][o + 2] ~= nil and heightmap[cx][cy][i + 0][o + 2] ~= currentHeight then
        return 2
    end
    if _G.state.map.shadowmap[cx][cy][i + 0][o + 2] ~= 0 and _G.state.map.shadowmap[cx][cy][i + 0][o + 2] ~= nil then
        return 2
    end
    if _G.state.map.terrain[cx][cy][i + 1][o + 2] ~= biome or keysToSkip[cx][cy][i + 1][o + 2] then
        return 2
    end
    if heightmap[cx][cy][i + 1][o + 2] ~= nil and heightmap[cx][cy][i + 1][o + 2] ~= currentHeight then
        return 2
    end
    if _G.state.map.shadowmap[cx][cy][i + 1][o + 2] ~= 0 and _G.state.map.shadowmap[cx][cy][i + 1][o + 2] ~= nil then
        return 2
    end
    if i + 3 >= chunkWidth - 1 or o + 3 >= chunkHeight - 1 then
        return 3
    end
    if _G.state.map.shadowmap[cx][cy][i + 3][o + 3] ~= 0 and _G.state.map.shadowmap[cx][cy][i + 3][o + 3] ~= nil then
        return 1
    end
    if _G.state.map.terrain[cx][cy][i + 3][o + 0] ~= biome or keysToSkip[cx][cy][i + 3][o + 0] then
        return 3
    end
    if heightmap[cx][cy][i + 3][o + 0] ~= nil and heightmap[cx][cy][i + 3][o + 0] ~= currentHeight then
        return 3
    end
    if _G.state.map.shadowmap[cx][cy][i + 3][o + 0] ~= 0 and _G.state.map.shadowmap[cx][cy][i + 3][o + 0] ~= nil then
        return 3
    end
    if _G.state.map.terrain[cx][cy][i + 3][o + 1] ~= biome or keysToSkip[cx][cy][i + 3][o + 1] then
        return 3
    end
    if heightmap[cx][cy][i + 3][o + 1] ~= nil and heightmap[cx][cy][i + 3][o + 1] ~= currentHeight then
        return 3
    end
    if _G.state.map.shadowmap[cx][cy][i + 3][o + 1] ~= 0 and _G.state.map.shadowmap[cx][cy][i + 3][o + 1] ~= nil then
        return 3
    end
    if _G.state.map.terrain[cx][cy][i + 3][o + 2] ~= biome or keysToSkip[cx][cy][i + 3][o + 2] then
        return 3
    end
    if heightmap[cx][cy][i + 3][o + 2] ~= nil and heightmap[cx][cy][i + 3][o + 2] ~= currentHeight then
        return 3
    end
    if _G.state.map.shadowmap[cx][cy][i + 3][o + 2] ~= 0 and _G.state.map.shadowmap[cx][cy][i + 3][o + 2] ~= nil then
        return 3
    end
    if _G.state.map.terrain[cx][cy][i + 3][o + 3] ~= biome or keysToSkip[cx][cy][i + 3][o + 3] then
        return 3
    end
    if heightmap[cx][cy][i + 3][o + 3] ~= nil and heightmap[cx][cy][i + 3][o + 3] ~= currentHeight then
        return 3
    end
    if _G.state.map.shadowmap[cx][cy][i + 3][o + 3] ~= 0 and _G.state.map.shadowmap[cx][cy][i + 3][o + 3] ~= nil then
        return 3
    end
    if _G.state.map.terrain[cx][cy][i + 0][o + 3] ~= biome or keysToSkip[cx][cy][i + 0][o + 3] then
        return 3
    end
    if heightmap[cx][cy][i + 0][o + 3] ~= nil and heightmap[cx][cy][i + 0][o + 3] ~= currentHeight then
        return 3
    end
    if _G.state.map.shadowmap[cx][cy][i + 0][o + 3] ~= 0 and _G.state.map.shadowmap[cx][cy][i + 0][o + 3] ~= nil then
        return 3
    end
    if _G.state.map.terrain[cx][cy][i + 1][o + 3] ~= biome or keysToSkip[cx][cy][i + 1][o + 3] then
        return 3
    end
    if heightmap[cx][cy][i + 1][o + 3] ~= nil and heightmap[cx][cy][i + 1][o + 3] ~= currentHeight then
        return 3
    end
    if _G.state.map.shadowmap[cx][cy][i + 1][o + 3] ~= 0 and _G.state.map.shadowmap[cx][cy][i + 1][o + 3] ~= nil then
        return 3
    end
    if _G.state.map.terrain[cx][cy][i + 2][o + 3] ~= biome or keysToSkip[cx][cy][i + 2][o + 3] then
        return 3
    end
    if heightmap[cx][cy][i + 2][o + 3] ~= nil and heightmap[cx][cy][i + 2][o + 3] ~= currentHeight then
        return 3
    end
    if _G.state.map.shadowmap[cx][cy][i + 2][o + 3] ~= 0 and _G.state.map.shadowmap[cx][cy][i + 2][o + 3] ~= nil then
        return 3
    end
    return 4
end

local function freeMultiTileTerrain(size, keysToSkip, cx, cy, i, o)
    keysToSkip[cx][cy][i][o] = false
    terrainTile[cx][cy][i][o] = nil
    secondaryTilesToUpdateInChunk[cx][cy][i][o] = true
    tertiaryTilesToUpdateInChunk[cx][cy][i][o] = true
    keysToSkip[cx][cy][i + 1][o] = false
    terrainTile[cx][cy][i + 1][o] = nil
    secondaryTilesToUpdateInChunk[cx][cy][i + 1][o] = true
    tertiaryTilesToUpdateInChunk[cx][cy][i + 1][o] = true
    keysToSkip[cx][cy][i + 1][o + 1] = false
    terrainTile[cx][cy][i + 1][o + 1] = nil
    secondaryTilesToUpdateInChunk[cx][cy][i + 1][o + 1] = true
    tertiaryTilesToUpdateInChunk[cx][cy][i + 1][o + 1] = true
    keysToSkip[cx][cy][i][o + 1] = false
    terrainTile[cx][cy][i][o + 1] = nil
    secondaryTilesToUpdateInChunk[cx][cy][i][o + 1] = true
    tertiaryTilesToUpdateInChunk[cx][cy][i][o + 1] = true
    if size >= 3 then
        keysToSkip[cx][cy][i + 2][o] = false
        terrainTile[cx][cy][i + 2][o] = nil
        secondaryTilesToUpdateInChunk[cx][cy][i + 2][o] = true
        tertiaryTilesToUpdateInChunk[cx][cy][i + 2][o] = true
        keysToSkip[cx][cy][i + 2][o + 1] = false
        terrainTile[cx][cy][i + 2][o + 1] = nil
        secondaryTilesToUpdateInChunk[cx][cy][i + 2][o + 1] = true
        tertiaryTilesToUpdateInChunk[cx][cy][i + 2][o + 1] = true
        keysToSkip[cx][cy][i + 2][o + 2] = false
        terrainTile[cx][cy][i + 2][o + 2] = nil
        secondaryTilesToUpdateInChunk[cx][cy][i + 2][o + 2] = true
        tertiaryTilesToUpdateInChunk[cx][cy][i + 2][o + 2] = true
        keysToSkip[cx][cy][i][o + 2] = false
        terrainTile[cx][cy][i][o + 2] = nil
        secondaryTilesToUpdateInChunk[cx][cy][i][o + 2] = true
        tertiaryTilesToUpdateInChunk[cx][cy][i][o + 2] = true
        keysToSkip[cx][cy][i + 1][o + 2] = false
        terrainTile[cx][cy][i + 1][o + 2] = nil
        secondaryTilesToUpdateInChunk[cx][cy][i + 1][o + 2] = true
        tertiaryTilesToUpdateInChunk[cx][cy][i + 1][o + 2] = true
    end
    if size >= 4 then
        keysToSkip[cx][cy][i + 3][o] = false
        terrainTile[cx][cy][i + 3][o] = nil
        secondaryTilesToUpdateInChunk[cx][cy][i + 3][o] = true
        tertiaryTilesToUpdateInChunk[cx][cy][i + 3][o] = true
        keysToSkip[cx][cy][i + 3][o + 1] = false
        terrainTile[cx][cy][i + 3][o + 1] = nil
        secondaryTilesToUpdateInChunk[cx][cy][i + 3][o + 1] = true
        tertiaryTilesToUpdateInChunk[cx][cy][i + 3][o + 1] = true
        keysToSkip[cx][cy][i + 3][o + 2] = false
        terrainTile[cx][cy][i + 3][o + 2] = nil
        secondaryTilesToUpdateInChunk[cx][cy][i + 3][o + 2] = true
        tertiaryTilesToUpdateInChunk[cx][cy][i + 3][o + 2] = true
        keysToSkip[cx][cy][i + 3][o + 3] = false
        terrainTile[cx][cy][i + 3][o + 3] = nil
        secondaryTilesToUpdateInChunk[cx][cy][i + 3][o + 3] = true
        tertiaryTilesToUpdateInChunk[cx][cy][i + 3][o + 3] = true
        keysToSkip[cx][cy][i][o + 3] = false
        terrainTile[cx][cy][i][o + 3] = nil
        secondaryTilesToUpdateInChunk[cx][cy][i][o + 3] = true
        tertiaryTilesToUpdateInChunk[cx][cy][i][o + 3] = true
        keysToSkip[cx][cy][i + 1][o + 3] = false
        terrainTile[cx][cy][i + 1][o + 3] = nil
        secondaryTilesToUpdateInChunk[cx][cy][i + 1][o + 3] = true
        tertiaryTilesToUpdateInChunk[cx][cy][i + 1][o + 3] = true
        keysToSkip[cx][cy][i + 2][o + 3] = false
        terrainTile[cx][cy][i + 2][o + 3] = nil
        secondaryTilesToUpdateInChunk[cx][cy][i + 2][o + 3] = true
        tertiaryTilesToUpdateInChunk[cx][cy][i + 2][o + 3] = true
    end
end

local function multiTileTerrain(size, keysToSkip, cx, cy, i, o, biome)
    terrainTile[cx][cy][i][o] = nil
    keysToSkip[cx][cy][i][o] = {
        i,
        o,
        ["size"] = 2,
        ["biome"] = biome,
        ["cx"] = cx,
        ["cy"] = cy
    }
    keysToSkip[cx][cy][i + 1][o] = {i, o}
    terrainTile[cx][cy][i + 1][o] = nil
    keysToSkip[cx][cy][i + 1][o + 1] = {i, o}
    terrainTile[cx][cy][i + 1][o + 1] = nil
    keysToSkip[cx][cy][i][o + 1] = {i, o}
    terrainTile[cx][cy][i][o + 1] = nil
    if size >= 3 then
        terrainTile[cx][cy][i][o] = nil
        keysToSkip[cx][cy][i][o] = {
            i,
            o,
            ["size"] = 3,
            ["biome"] = biome,
            ["cx"] = cx,
            ["cy"] = cy
        }
        keysToSkip[cx][cy][i + 2][o] = {i, o}
        terrainTile[cx][cy][i + 2][o] = nil
        keysToSkip[cx][cy][i + 2][o + 1] = {i, o}
        terrainTile[cx][cy][i + 2][o + 1] = nil
        keysToSkip[cx][cy][i + 2][o + 2] = {i, o}
        terrainTile[cx][cy][i + 2][o + 2] = nil
        keysToSkip[cx][cy][i][o + 2] = {i, o}
        terrainTile[cx][cy][i][o + 2] = nil
        keysToSkip[cx][cy][i + 1][o + 2] = {i, o}
        terrainTile[cx][cy][i + 1][o + 2] = nil
    end
    if size >= 4 then
        terrainTile[cx][cy][i][o] = nil
        keysToSkip[cx][cy][i][o] = {
            i,
            o,
            ["size"] = 4,
            ["biome"] = biome,
            ["cx"] = cx,
            ["cy"] = cy
        }
        keysToSkip[cx][cy][i + 3][o] = {i, o}
        terrainTile[cx][cy][i + 3][o] = nil
        keysToSkip[cx][cy][i + 3][o + 1] = {i, o}
        terrainTile[cx][cy][i + 3][o + 1] = nil
        keysToSkip[cx][cy][i + 3][o + 2] = {i, o}
        terrainTile[cx][cy][i + 3][o + 2] = nil
        keysToSkip[cx][cy][i + 3][o + 3] = {i, o}
        terrainTile[cx][cy][i + 3][o + 3] = nil
        keysToSkip[cx][cy][i][o + 3] = {i, o}
        terrainTile[cx][cy][i][o + 3] = nil
        keysToSkip[cx][cy][i + 1][o + 3] = {i, o}
        terrainTile[cx][cy][i + 1][o + 3] = nil
        keysToSkip[cx][cy][i + 2][o + 3] = {i, o}
        terrainTile[cx][cy][i + 2][o + 3] = nil
    end
end

local chunksToUpdate = {}
function _G.scheduleTerrainUpdate(cx, cy, i, o)
    tilesToUpdateInChunk[cx][cy][i][o] = true
    tertiaryTilesToUpdateInChunk[cx][cy][i][o] = true
    for x = -4, 4 do
        for y = -4, 4 do
            secondaryTilesToUpdateInChunk[cx][cy][i + x][o + y] = true
            tertiaryTilesToUpdateInChunk[cx][cy][i + x][o + y] = true
        end
    end
    if not chunksSet[cx][cy] then
        chunksToUpdate[#chunksToUpdate + 1] = {cx, cy}
        chunksSet[cx][cy] = true
    end
end

function _G.scheduleTightTerrainUpdate(cx, cy, i, o)
    tertiaryTilesToUpdateInChunk[cx][cy][i][o] = true
    if not chunksSet[cx][cy] then
        chunksToUpdate[#chunksToUpdate + 1] = {cx, cy}
        chunksSet[cx][cy] = true
    end
end

function _G.terrainElevateTileAt(gx, gy)
    local cx, cy, i, o = _G.getLocalCoordinatesFromGlobal(gx, gy)
    if _G.state.map.terrain[cx] and _G.state.map.terrain[cx][cy] then
        if heightmap[cx][cy][i][o] then
            heightmap[cx][cy][i][o] = heightmap[cx][cy][i][o] + 1
        else
            heightmap[cx][cy][i][o] = 1
        end
        heightmap[cx][cy][i][o] = math.min(heightmap[cx][cy][i][o], 80)
        _G.scheduleTerrainUpdate(cx, cy, i, o)
    end
end

function _G.terrainSetHeight(gx, gy, value)
    local cx, cy, i, o = _G.getLocalCoordinatesFromGlobal(gx, gy)
    heightmap[cx][cy][i][o] = value
    _G.scheduleTerrainUpdate(cx, cy, i, o)
end

local keysToSkip = newAutotable(4)

local function multiTileCalculate(currentBiome, cx, cy, i, o)
    local gx = chunkWidth * cx + i
    local gy = chunkWidth * cy + o
    local lScale = 1.0666
    local maxSize = checkMaxSizeBiome(currentBiome, cx, cy, i, o, keysToSkip)
    local upperBorder
    if maxSize == 1 then
        upperBorder = 16
    elseif maxSize == 2 then
        upperBorder = 20
    elseif maxSize == 3 then
        upperBorder = 24
    elseif maxSize == 4 then
        upperBorder = 28
    end
    if currentBiome == _G.terrainBiome.abundantGrassStonesWhite then
        upperBorder = 16
    elseif currentBiome == _G.terrainBiome.sea then
        upperBorder = 8
    elseif currentBiome == _G.terrainBiome.seaWalkable then
        upperBorder = 8
    end
    local rand = love.math.random(1, upperBorder)
    if currentBiome ~= _G.terrainBiome.abundantGrassStonesWhite and currentBiome ~= _G.terrainBiome.sea and currentBiome ~=
        _G.terrainBiome.seaWalkable then
        local rand2 = love.math.random(1, upperBorder)
        local rand3 = love.math.random(1, upperBorder)
        rand = math.max(rand, rand2, rand3)
    end
    if currentBiome == _G.terrainBiome.none then
        rand = 0
    end
    local tileKey
    local lOffsetX, lOffsetY = 0, 0
    if currentBiome == _G.terrainBiome.seaBeach then
        local north = _G.getTerrainBiomeAt(gx, gy - 1) == _G.terrainBiome.sea or _G.getTerrainBiomeAt(gx, gy - 1) ==
            _G.terrainBiome.seaWalkable
        local south = _G.getTerrainBiomeAt(gx, gy + 1) == _G.terrainBiome.sea or _G.getTerrainBiomeAt(gx, gy + 1) ==
            _G.terrainBiome.seaWalkable
        local east = _G.getTerrainBiomeAt(gx + 1, gy) == _G.terrainBiome.sea or _G.getTerrainBiomeAt(gx + 1, gy) ==
            _G.terrainBiome.seaWalkable
        local west = _G.getTerrainBiomeAt(gx - 1, gy) == _G.terrainBiome.sea or _G.getTerrainBiomeAt(gx - 1, gy) ==
            _G.terrainBiome.seaWalkable
        local ne =
        _G.getTerrainBiomeAt(gx + 1, gy - 1) == _G.terrainBiome.sea or _G.getTerrainBiomeAt(gx + 1, gy - 1) ==
            _G.terrainBiome.seaWalkable
        local nw =
        _G.getTerrainBiomeAt(gx - 1, gy - 1) == _G.terrainBiome.sea or _G.getTerrainBiomeAt(gx - 1, gy - 1) ==
            _G.terrainBiome.seaWalkable
        local se =
        _G.getTerrainBiomeAt(gx + 1, gy + 1) == _G.terrainBiome.sea or _G.getTerrainBiomeAt(gx + 1, gy + 1) ==
            _G.terrainBiome.seaWalkable
        local sw =
        _G.getTerrainBiomeAt(gx - 1, gy + 1) == _G.terrainBiome.sea or _G.getTerrainBiomeAt(gx - 1, gy + 1) ==
            _G.terrainBiome.seaWalkable
        tileKey = "yellow_grass_1x1 (1)"
        if north then
            if east then
                tileKey = "sea_beach_sw_outside (" .. tostring(love.math.random(1, 2)) .. ")"
            elseif west then
                tileKey = "sea_beach_se_outside (" .. tostring(love.math.random(1, 2)) .. ")"
            else
                tileKey = "sea_beach_s (" .. tostring(love.math.random(1, 4)) .. ")"
            end
        elseif south then
            if east then
                tileKey = "sea_beach_nw_outside (" .. tostring(love.math.random(1, 2)) .. ")"
            elseif west then
                tileKey = "sea_beach_ne_outside (" .. tostring(love.math.random(1, 2)) .. ")"
            else
                tileKey = "sea_beach_n (" .. tostring(love.math.random(1, 4)) .. ")"
            end
        elseif east then
            tileKey = "sea_beach_w (" .. tostring(love.math.random(1, 4)) .. ")"
        elseif west then
            tileKey = "sea_beach_e (" .. tostring(love.math.random(1, 4)) .. ")"
        elseif ne then
            tileKey = "sea_beach_sw_inside (" .. tostring(love.math.random(1, 2)) .. ")"
        elseif nw then
            tileKey = "sea_beach_se_inside (" .. tostring(love.math.random(1, 2)) .. ")"
        elseif se then
            tileKey = "sea_beach_nw_inside (" .. tostring(love.math.random(1, 2)) .. ")"
        elseif sw then
            tileKey = "sea_beach_ne_inside (" .. tostring(love.math.random(1, 2)) .. ")"
        end
    elseif currentBiome ~= _G.terrainBiome.none then
        if rand > 0 and rand <= 16 then
            tileKey = terrain[cx][cy][i][o] .. "_1x1 (" .. tostring(rand) .. ")"
            local _, _, _, lh = tileQuads[tileKey]:getViewport()
            lOffsetY = lOffsetY + 16 - lh
        elseif rand > 16 and rand <= 20 then
            lOffsetX = -16 - 4
            multiTileTerrain(2, keysToSkip, cx, cy, i, o, currentBiome)
            tileKey = terrain[cx][cy][i][o] .. "_2x2 (" .. tostring(21 - rand) .. ")"
            local _, _, lw, lh = tileQuads[tileKey]:getViewport()
            lOffsetY = lOffsetY + 32 - lh
            lOffsetX = lOffsetX + 62 - lw
        elseif rand > 20 and rand <= 24 then
            lOffsetX = -32
            multiTileTerrain(3, keysToSkip, cx, cy, i, o, currentBiome)
            tileKey = terrain[cx][cy][i][o] .. "_3x3 (" .. tostring(25 - rand) .. ")"
            local _, _, lw, lh = tileQuads[tileKey]:getViewport()
            lOffsetY = lOffsetY + 48 - lh
            lOffsetX = lOffsetX + 94 - lw
        else
            lOffsetX = -32 - 16
            multiTileTerrain(4, keysToSkip, cx, cy, i, o, currentBiome)
            tileKey = terrain[cx][cy][i][o] .. "_4x4 (" .. tostring(29 - rand) .. ")"
            local _, _, lw, lh = tileQuads[tileKey]:getViewport()
            lOffsetY = lOffsetY + 64 - lh
            lOffsetX = lOffsetX + 124 - lw
        end
    end
    if currentBiome == _G.terrainBiome.abundantGrass then
        lOffsetY = lOffsetY + 1
    end
    if rand == 0 then
        terrainTile[cx][cy][i][o] = nil
    else
        terrainTile[cx][cy][i][o] = {tileQuads[tileKey], _G.IsoX + (i - o) * tileWidth * 0.5 + lOffsetX,
            _G.IsoY + (i + o) * tileHeight * 0.5 + lOffsetY, 0, lScale, lScale}
    end
end

local function updateTerrain2ndPass(chunkX, chunkY)
    local cx = chunkX or _G.currentChunkX
    local cy = chunkY or _G.currentChunkY
    for i = 0, chunkWidth - 1, 1 do
        for o = 0, chunkWidth - 1, 1 do
            if secondaryTilesToUpdateInChunk[cx][cy][i] and secondaryTilesToUpdateInChunk[cx][cy][i][o] then
                local currentBiome = terrain[cx][cy][i][o]
                local multiTileOrigin
                if keysToSkip[cx][cy][i][o] then
                    local curIdx = keysToSkip[cx][cy][i][o]
                    if curIdx["size"] then
                        multiTileOrigin = curIdx
                    else
                        multiTileOrigin = keysToSkip[cx][cy][curIdx[1]][curIdx[2]]
                    end
                    local mt = multiTileOrigin
                    if mt.biome ~= currentBiome then
                        terrainTile[cx][cy][curIdx[1]][curIdx[2]] = {}
                        freeMultiTileTerrain(multiTileOrigin.size, keysToSkip, cx, cy, mt[1], mt[2])
                    end
                end
                if keysToSkip[cx][cy][i][o] then
                    goto endMultiTile
                end
                multiTileCalculate(currentBiome, cx, cy, i, o)

            end
            ::endMultiTile::
        end
    end
    secondaryTilesToUpdateInChunk[cx][cy] = nil
end

local emptyTable = newAutotable(4)
local function updateTerrain(chunkX, chunkY)
    local cx = chunkX or _G.currentChunkX
    local cy = chunkY or _G.currentChunkY
    if terrainBatch[chunkX][chunkY] == nil then
        terrainBatch[chunkX][chunkY] = love.graphics.newSpriteBatch(terrainImage, chunkWidth * chunkHeight)
    end
    terrainBatch[chunkX][chunkY]:clear()
    for i = 0, chunkWidth - 1, 1 do
        for o = 0, chunkWidth - 1, 1 do
            if not tilesToUpdateInChunk[cx][cy][i][o] and not tertiaryTilesToUpdateInChunk[cx][cy][i][o] then
                goto endFirstPass
            end
            local gx = chunkWidth * cx + i
            local gy = chunkWidth * cy + o
            local totalHeight = 0
            for sx = -1, 1 do
                for sy = -1, 1 do
                    if not (sx == 0 and sy == 0) then
                        local curI = (gx + sx) % (chunkWidth)
                        local curO = (gy + sy) % (chunkWidth)
                        local curCx = math.floor((gx + sx) / chunkWidth)
                        local curCy = math.floor((gy + sy) / chunkWidth)
                        if heightmap[curCx] and heightmap[curCx][curCy] then
                            totalHeight = totalHeight + (heightmap[curCx][curCy][curI][curO] or 0)
                        end
                    end
                end
            end
            local prevCx, prevCy, prevI, prevO = _G.getLocalCoordinatesFromGlobal(gx - 1, gy + 1)

            local prevHeight, prevShadow, prevTileheight = 0, 0, 0
            if _G.state.map.terrain[prevCx] and _G.state.map.terrain[prevCx][prevCy] then
                prevHeight = heightmap[prevCx][prevCy][prevI][prevO] or 0
                prevHeight = 75 * prevHeight / (40 + prevHeight)
                prevShadow = _G.state.map.shadowmap[prevCx][prevCy][prevI][prevO] or 0
                prevTileheight = tileheight[prevCx][prevCy][prevI][prevO] or 0
            end
            local lastShadow = _G.state.map.shadowmap[cx][cy][i][o]
            _G.state.map.shadowmap[cx][cy][i][o] = math.max(math.max(prevHeight + prevTileheight, prevShadow) - 3.5, 0)
            if not _G.BuildController.start and lastShadow ~= _G.state.map.shadowmap[cx][cy][i][o] then
                local cx, cy, i, o = _G.getLocalCoordinatesFromGlobal(gx + 1, gy - 1)
                if cx < chunksWide and cy < chunksHigh and cx >= 0 and cy >= 0 then
                    if not _G.BuildController.start then
                        _G.scheduleTightTerrainUpdate(cx, cy, i, o)
                    end
                end
            end

            local prev1I = (gx - 1) % (chunkWidth)
            local prev1O = (gy) % (chunkWidth)
            local prev1Cx = math.floor((gx - 1) / chunkWidth)
            local prev1Cy = math.floor((gy) / chunkWidth)
            local prev2I = (gx) % (chunkWidth)
            local prev2O = (gy + 1) % (chunkWidth)
            local prev2Cx = math.floor((gx) / chunkWidth)
            local prev2Cy = math.floor((gy + 1) / chunkWidth)
            local prev1Height = heightmap[prev1Cx][prev1Cy][prev1I][prev1O] or 0
            prev1Height = 75 * prev1Height / (40 + prev1Height)
            local prev1Shadow = _G.state.map.shadowmap[prev1Cx][prev1Cy][prev1I][prev1O] or 0
            local prev1Tileheight = tileheight[prev1Cx][prev1Cy][prev1I][prev1O] or 0
            local prev2Height = heightmap[prev2Cx][prev2Cy][prev2I][prev2O] or 0
            prev2Height = 75 * prev2Height / (40 + prev2Height)
            local prev2Shadow = _G.state.map.shadowmap[prev2Cx][prev2Cy][prev2I][prev2O] or 0
            local prev2Tileheight = tileheight[prev2Cx][prev2Cy][prev2I][prev2O] or 0
            local prev1ShadowValue = math.max(math.max(prev1Height + prev1Tileheight, prev1Shadow) - 3.5, 0)
            local prev2ShadowValue = math.max(math.max(prev2Height + prev2Tileheight, prev2Shadow) - 3.5, 0)

            local prev3I = (gx + 1) % (chunkWidth)
            local prev3O = (gy) % (chunkWidth)
            local prev3Cx = math.floor((gx + 1) / chunkWidth)
            local prev3Cy = math.floor((gy) / chunkWidth)
            local prev3Height = heightmap[prev3Cx][prev3Cy][prev3I][prev3O] or 0
            prev3Height = 75 * prev3Height / (40 + prev3Height)
            local prev3Tileheight = tileheight[prev3Cx][prev3Cy][prev3I][prev3O] or 0
            local prev3Shadow = _G.state.map.shadowmap[prev3Cx][prev3Cy][prev3I][prev3O] or 0
            local prev3ShadowValue = math.max(math.max(prev3Height + prev3Tileheight, prev3Shadow) - 3.5, 0)

            local prev4I = (gx) % (chunkWidth)
            local prev4O = (gy - 1) % (chunkWidth)
            local prev4Cx = math.floor((gx) / chunkWidth)
            local prev4Cy = math.floor((gy - 1) / chunkWidth)
            local prev4Height = heightmap[prev4Cx][prev4Cy][prev4I][prev4O] or 0
            prev4Height = 75 * prev4Height / (40 + prev4Height)
            local prev4Tileheight = tileheight[prev4Cx][prev4Cy][prev4I][prev4O] or 0
            local prev4Shadow = _G.state.map.shadowmap[prev4Cx][prev4Cy][prev4I][prev4O] or 0
            local prev4ShadowValue = math.max(math.max(prev4Height + prev4Tileheight, prev4Shadow) - 3.5, 0)
            -- _G.state.map.shadowmap[cx][cy][i][o] = math.max(shadowmap[cx][cy][i][o], prev1ShadowValue / 2, prev2ShadowValue / 2)
            if (prev1ShadowValue == prev2ShadowValue) and prev1ShadowValue > _G.state.map.shadowmap[cx][cy][i][o] then
                _G.state.map.shadowmap[cx][cy][i][o] = prev1ShadowValue
            end
            local currentShadow = _G.state.map.shadowmap[cx][cy][i][o] or 0
            local elevationOffsetY = heightmap[cx][cy][i][o] or 0
            local elevationValue = 75 * elevationOffsetY / (40 + elevationOffsetY)
            local isInShadow = currentShadow > elevationOffsetY or currentShadow > elevationValue
            if not isInShadow then
                local interpolatedShadowVal = (prev1ShadowValue * 2 + prev2ShadowValue * 2 + prev3ShadowValue +
                    prev4ShadowValue) / 6
                _G.state.map.shadowmap[cx][cy][i][o] = interpolatedShadowVal
            end

            if tilesToUpdateInChunk[cx][cy][i] and tilesToUpdateInChunk[cx][cy][i][o] then
                local currentBiome = terrain[cx][cy][i][o]
                local multiTileOrigin
                if keysToSkip[cx][cy][i][o] then
                    local curIdx = keysToSkip[cx][cy][i][o]
                    if curIdx["size"] then
                        multiTileOrigin = curIdx
                    else
                        multiTileOrigin = keysToSkip[cx][cy][curIdx[1]][curIdx[2]]
                    end
                    local mt = multiTileOrigin
                    local maxSize = checkMaxSizeBiome(currentBiome, mt.cx, mt.cy, mt[1], mt[2], keysToSkip)
                    if maxSize ~= mt.size or multiTileOrigin.biome ~= currentBiome then
                        terrainTile[cx][cy][mt[1]][mt[2]] = {}
                        freeMultiTileTerrain(multiTileOrigin.size, keysToSkip, cx, cy, mt[1], mt[2])
                    end
                end
                if keysToSkip[cx][cy][i][o] then
                    goto continue
                end
                multiTileCalculate(currentBiome, cx, cy, i, o)
            end
            ::continue::
            tilesToUpdateInChunk[cx][cy][i][o] = nil
            if _G.state.map.shadowmap[cx][cy][i][o] and _G.state.map.shadowmap[cx][cy][i][o] > 0 and terrain[cx][cy] then
                local currentBiome = terrain[cx][cy][i][o]
                local multiTileOrigin
                if keysToSkip[cx][cy][i][o] then
                    local curIdx = keysToSkip[cx][cy][i][o]
                    if curIdx["size"] then
                        multiTileOrigin = curIdx
                    else
                        multiTileOrigin = keysToSkip[cx][cy][curIdx[1]][curIdx[2]]
                    end
                    local mt = multiTileOrigin
                    local maxSize = checkMaxSizeBiome(currentBiome, mt.cx, mt.cy, mt[1], mt[2], emptyTable)
                    if maxSize ~= mt.size then
                        terrainTile[cx][cy][mt[1]][mt[2]] = {}
                        freeMultiTileTerrain(multiTileOrigin.size, keysToSkip, cx, cy, mt[1], mt[2])
                    end
                end
            end
            ::endFirstPass::
        end
    end
    updateTerrain2ndPass(cx, cy)
end

function _G.tileShouldBeCliff(myGx, myGy, allDirections)
    local cx, cy, i, o = _G.getLocalCoordinatesFromGlobal(myGx, myGy)
    local myHeight = heightmap[cx][cy][i][o] or 0
    cx, cy, i, o = _G.getLocalCoordinatesFromGlobal(myGx + 1, myGy)
    local tileLeftHeight = heightmap[cx][cy][i][o] or 0
    if (myHeight - tileLeftHeight) > 13 then
        _G.state.map:setWalkable(myGx, myGy, 1)
        return true
    end
    cx, cy, i, o = _G.getLocalCoordinatesFromGlobal(myGx, myGy + 1)
    local tileRightHeight = heightmap[cx][cy][i][o] or 0
    if (myHeight - tileRightHeight) > 13 then
        _G.state.map:setWalkable(myGx, myGy, 1)
        return true
    end
    cx, cy, i, o = _G.getLocalCoordinatesFromGlobal(myGx + 1, myGy + 1)
    if terrain[cx][cy] and terrain[cx][cy][i] and terrain[cx][cy][i][o] == _G.terrainBiome.none then
        return true
    end
    cx, cy, i, o = _G.getLocalCoordinatesFromGlobal(myGx, myGy - 1)
    if myHeight - (heightmap[cx][cy][i][o] or 0) > 13 then
        _G.state.map:setWalkable(myGx, myGy, 1)
        if allDirections then
            return true
        end
    end
    cx, cy, i, o = _G.getLocalCoordinatesFromGlobal(myGx - 1, myGy - 1)
    if myHeight - (heightmap[cx][cy][i][o] or 0) > 13 then
        _G.state.map:setWalkable(myGx, myGy, 1)
        if allDirections then
            return true
        end
    end
    cx, cy, i, o = _G.getLocalCoordinatesFromGlobal(myGx - 1, myGy)
    if myHeight - (heightmap[cx][cy][i][o] or 0) > 13 then
        _G.state.map:setWalkable(myGx, myGy, 1)
        if allDirections then
            return true
        end
    end
    local gx, gy = myGx + 1, myGy
    i = (gx) % (chunkWidth)
    o = (gy) % (chunkWidth)
    cx = math.floor(gx / chunkWidth)
    cy = math.floor(gy / chunkWidth)
    if terrain[cx][cy] and terrain[cx][cy][i] and terrain[cx][cy][i][o] == _G.terrainBiome.none then
        return true
    end
end

function _G.refreshTile(cx, cy, i, o, force)
    local vertId = _G.getTerrainVertex(cx, cy, i, o)
    local chevronLeftId = _G.getChevronVertexLeft(cx, cy, i, o)
    local chevronRightId = _G.getChevronVertexRight(cx, cy, i, o)
    local instancemesh = _G.state.objectMesh[cx][cy]
    if terrain[cx][cy][i][o] ~= _G.terrainBiome.none and tertiaryTilesToUpdateInChunk[cx][cy][i][o] == true and
        terrain[cx][cy][i][o] ~= _G.terrainBiome.none or force then
        instancemesh:setVertex(vertId)
        local elevationOffsetY = heightmap[cx][cy][i][o] or 0
        local elevationValue = 75 * elevationOffsetY / (40 + elevationOffsetY)
        local shadowValue = _G.state.map.shadowmap[cx][cy][i][o] or 0
        local thisTileheight = tileheight[cx][cy][i][o] or 0
        local isInShadow = shadowValue > elevationOffsetY or shadowValue > elevationValue
        shadowValue = math.min((shadowValue - elevationValue) / 40, 0.6)

        -- -- CHECK IF PREVIOUS TILE HAS THE SAME HEIGHT
        local gx = chunkWidth * cx + i
        local gy = chunkWidth * cy + o
        local horizontalX = math.floor(_G.IsoToScreenX(gx, gy) / (_G.tileWidth / 2))
        local prevI = (gx - 1) % (chunkWidth)
        local prevO = (gy + 1) % (chunkWidth)
        local prevCx = math.floor((gx - 1) / chunkWidth)
        local prevCy = math.floor((gy + 1) / chunkWidth)

        local prevHeight, prevShadow, prevTileheight
        prevHeight = heightmap[prevCx][prevCy][prevI][prevO] or 0
        prevShadow = _G.state.map.shadowmap[prevCx][prevCy][prevI][prevO] or 0
        prevTileheight = tileheight[prevCx][prevCy][prevI][prevO] or 0
        local prevInShadow = prevShadow > prevHeight
        if prevHeight <= elevationOffsetY and prevTileheight <= thisTileheight and not prevInShadow and shadowValue >
            elevationValue then
            isInShadow = false
        end
        if thisTileheight > 0 then
            isInShadow = true
        end

        -- shadowValue = math.min((shadowValue - elevationValue / 40) / 40, 0.45) / 1.25
        local tileHasSlope = false
        local tilesWithSlope = 0
        for xx = -1, 1 do
            for yy = -1, 1 do
                local pi = (gx + xx) % (chunkWidth)
                local po = (gy + yy) % (chunkWidth)
                local pcx = math.floor((gx + xx) / chunkWidth)
                local pcy = math.floor((gy + yy) / chunkWidth)
                if heightmap[pcx][pcy][pi][po] and heightmap[pcx][pcy][pi][po] ~= elevationOffsetY then
                    tilesWithSlope = tilesWithSlope + 1
                end
            end
        end
        if tilesWithSlope > 5 then
            tileHasSlope = true
        end
        local hillTileBase, hillTileSunnySide, hillTileNormal
        local skipMultiTile = false
        local t = terrainTile[cx][cy][i][o]
        if not t or #t <= 0 then
            skipMultiTile = true
            t = {nil, _G.IsoX + (i - o) * tileWidth * 0.5, _G.IsoY + (i + o) * tileHeight * 0.5, 0, 1.06, 1.06}
        end
        local isCliff = tileShouldBeCliff(gx, gy)
        if not tileShouldBeCliff(gx, gy, true) then
            if _G.shouldTileBeWalkable(gx, gy) and _G.state.map:getWalkable(gx, gy) == 1 then
                _G.state.map:setWalkable(gx, gy, 0)
            end
            instancemesh:setVertex(chevronLeftId)
            instancemesh:setVertex(chevronRightId)
        end
        local isIron = _G.objectFromClassAtGlobal(gx, gy, "Iron")
        local isStone = _G.objectFromClassAtGlobal(gx, gy, "Stone")
        local isTree = _G.objectFromClassAtGlobal(gx, gy, "PineTree")
        local cliffChevron
        local tileOverriden = false
        local hillChevronBase

        local hillChevronNormalLeft
        local hillChevronNormalRight
        local hillChevronSunnySideLeft
        local hillChevronSunnySideRight
        local hillChevronIronLeft
        local hillChevronIronRight
        local lScale = 1.06666
        if elevationOffsetY ~= 0 then
            local num = tostring(math.max(1, math.min(math.floor(elevationOffsetY / 6), 15) + 1))
            local rng = love.math.newRandomGenerator(i + o * 100)
            local sunnyRand = rng:random(1, 4) + 4
            local normalRand = rng:random(4, 8) + 4
            if terrain[cx][cy][i][o] == _G.terrainBiome.scarceGrass then
                normalRand = rng:random(1, 16)
                if elevationOffsetY > 33 and elevationOffsetY < 66 then
                    hillTileBase = "mountain_grass_a_1x1 ("
                elseif elevationOffsetY >= 66 then
                    hillTileBase = "mountain_grass_b_1x1 ("
                else
                    hillTileBase = "hill_" .. num .. " ("
                    normalRand = rng:random(5, 8)
                end
            else
                hillTileBase = "hill_" .. num .. " ("
            end
            hillChevronBase = "hill_chevron_" .. num .. " ("
            hillTileSunnySide = hillTileBase .. sunnyRand .. ")"
            local hillChevronSunnySide = hillChevronBase .. sunnyRand .. ")"
            hillTileNormal = hillTileBase .. normalRand .. ")"
            local hillChevronNormal = hillChevronBase .. normalRand .. ")"
            hillTileNormal = tileQuads[hillTileNormal]
            hillTileSunnySide = tileQuads[hillTileSunnySide]

            hillChevronNormal = tileQuads[hillChevronNormal]
            hillChevronSunnySide = tileQuads[hillChevronSunnySide]

            cliffChevron = tileQuads["rock_cliff (" .. tostring(horizontalX % 31 + 1) .. ")"]
            if isIron then
                local hillChevronIron = "hill_chevron_14 (" .. normalRand + 4 .. ")"
                hillChevronIron = tileQuads[hillChevronIron]
                local x, y, w, h = hillChevronIron:getViewport()
                hillChevronIronLeft = love.graphics.newQuad(x, y, w / 2, h, _G.objectAtlas)
                hillChevronIronRight = love.graphics.newQuad(x + w / 2, y, w / 2, h, _G.objectAtlas)
            else
                local x, y, w, h = hillChevronNormal:getViewport()
                hillChevronNormalLeft = love.graphics.newQuad(x, y, w / 2, h, _G.objectAtlas)
                hillChevronNormalRight = love.graphics.newQuad(x + w / 2, y, w / 2, h, _G.objectAtlas)
                x, y, w, h = hillChevronSunnySide:getViewport()
                hillChevronSunnySideLeft = love.graphics.newQuad(x, y, w / 2, h, _G.objectAtlas)
                hillChevronSunnySideRight = love.graphics.newQuad(x + w / 2, y, w / 2, h, _G.objectAtlas)
            end
        end
        local lightValue = 1
        if isInShadow then
            local maxShadow = math.min(0.9, 1 - shadowValue)
            if elevationOffsetY ~= 0 then
                if isCliff then
                    local qx, qy, qw, qh = cliffChevron:getViewport()
                    instancemesh:setVertex(chevronLeftId, t[2], t[3] - elevationOffsetY * 2 + 8, qx, qy, qw, qh,
                        1 - shadowValue, lScale)
                    instancemesh:setVertex(chevronRightId)
                elseif isIron then
                    local qx, qy, qw, qh = hillChevronIronLeft:getViewport()
                    instancemesh:setVertex(chevronLeftId, t[2], t[3] - elevationOffsetY * 2 + 8, qx, qy, qw, qh,
                        1 - shadowValue - 0.01, lScale, 2)
                    qx, qy, qw, qh = hillChevronIronRight:getViewport()
                    instancemesh:setVertex(chevronRightId, t[2] + qw, t[3] - elevationOffsetY * 2 + 8, qx, qy, qw, qh,
                        1 - shadowValue - 0.12, lScale, 2)
                else
                    local qx, qy, qw, qh = hillChevronNormalLeft:getViewport()
                    instancemesh:setVertex(chevronLeftId, t[2], t[3] - elevationOffsetY * 2 + 8, qx, qy, qw, qh,
                        1 - shadowValue - 0.01, lScale, 2)
                    qx, qy, qw, qh = hillChevronNormalRight:getViewport()
                    instancemesh:setVertex(chevronRightId, t[2] + qw, t[3] - elevationOffsetY * 2 + 8, qx, qy, qw, qh,
                        1 - shadowValue - 0.12, lScale, 2)
                end
                local qx, qy, qw, qh = hillTileNormal:getViewport()
                instancemesh:setVertex(vertId, t[2], t[3] - elevationOffsetY * 2, qx, qy, qw, qh, 1 - shadowValue,
                    lScale)
                tileOverriden = true
            end
            lightValue = maxShadow
        else
            local lightModifier = elevationOffsetY / 50
            if lightModifier > 0 and tileHasSlope and elevationOffsetY ~= 0 then
                lightValue = 0.9 + math.min(lightModifier, 0.1)
                if isCliff then
                    local qx, qy, qw, qh = cliffChevron:getViewport()
                    instancemesh:setVertex(chevronLeftId, t[2], t[3] - elevationOffsetY * 2 + 8, qx, qy, qw, qh,
                        0.9 + math.min(lightModifier, 0.1), lScale)
                    instancemesh:setVertex(chevronRightId)
                elseif isIron then
                    local qx, qy, qw, qh = hillChevronIronLeft:getViewport()
                    instancemesh:setVertex(chevronLeftId, t[2], t[3] - elevationOffsetY * 2 + 8, qx, qy, qw, qh,
                        0.9 + math.min(lightModifier, 0.1) - 0.01, lScale, 2)
                    qx, qy, qw, qh = hillChevronIronRight:getViewport()
                    instancemesh:setVertex(chevronRightId, t[2] + qw, t[3] - elevationOffsetY * 2 + 8, qx, qy, qw, qh,
                        0.9 + math.min(lightModifier, 0.1) - 0.08, lScale, 2)
                else
                    local qx, qy, qw, qh = hillChevronSunnySideLeft:getViewport()
                    instancemesh:setVertex(chevronLeftId, t[2], t[3] - elevationOffsetY * 2 + 8, qx, qy, qw, qh,
                        0.9 + math.min(lightModifier, 0.1) - 0.01, lScale, 2)
                    qx, qy, qw, qh = hillChevronSunnySideRight:getViewport()
                    instancemesh:setVertex(chevronRightId, t[2] + qw, t[3] - elevationOffsetY * 2 + 8, qx, qy, qw, qh,
                        0.9 + math.min(lightModifier, 0.1) - 0.08, lScale, 2)
                end
                local qx, qy, qw, qh = hillTileSunnySide:getViewport()
                instancemesh:setVertex(vertId, t[2], t[3] - elevationOffsetY * 2, qx, qy, qw, qh,
                    0.9 + math.min(lightModifier, 0.1), lScale)
                tileOverriden = true
            elseif elevationOffsetY ~= 0 then
                lightValue = 1
                if isCliff then
                    local qx, qy, qw, qh = cliffChevron:getViewport()
                    instancemesh:setVertex(chevronLeftId, t[2], t[3] - elevationOffsetY * 2 + 8, qx, qy, qw, qh, 1,
                        lScale)
                    instancemesh:setVertex(chevronRightId)
                elseif isIron then
                    local qx, qy, qw, qh = hillChevronIronLeft:getViewport()
                    instancemesh:setVertex(chevronLeftId, t[2], t[3] - elevationOffsetY * 2 + 8, qx, qy, qw, qh,
                        1 - 0.03, lScale, 2)
                    qx, qy, qw, qh = hillChevronIronRight:getViewport()
                    instancemesh:setVertex(chevronRightId, t[2] + qw, t[3] - elevationOffsetY * 2 + 8, qx, qy, qw, qh,
                        1 - 0.1, lScale, 2)
                else
                    local qx, qy, qw, qh = hillChevronNormalLeft:getViewport()
                    instancemesh:setVertex(chevronLeftId, t[2], t[3] - elevationOffsetY * 2 + 8, qx, qy, qw, qh,
                        1 - 0.03, lScale, 2)
                    qx, qy, qw, qh = hillChevronNormalRight:getViewport()
                    instancemesh:setVertex(chevronRightId, t[2] + qw, t[3] - elevationOffsetY * 2 + 8, qx, qy, qw, qh,
                        1 - 0.1, lScale, 2)
                end
                local qx, qy, qw, qh = hillTileNormal:getViewport()
                instancemesh:setVertex(vertId, t[2], t[3] - elevationOffsetY * 2, qx, qy, qw, qh, 1, lScale)
                tileOverriden = true
            end
        end
        if isIron and isInShadow then
            isIron:shadeFromTerrain()
        end
        if isStone and isInShadow then
            isStone:shadeFromTerrain()
        end
        if isTree and isInShadow then
            isTree:shadeFromTerrain()
        end
        if not skipMultiTile and not tileOverriden and t[1] then
            local qx, qy, qw, qh = t[1]:getViewport()
            instancemesh:setVertex(vertId, t[2], t[3] - elevationOffsetY * 2, qx, qy, qw, qh, lightValue, lScale)
        end
    elseif terrain[cx][cy][i][o] == _G.terrainBiome.none then
        instancemesh:setVertex(vertId)
        instancemesh:setVertex(chevronLeftId)
        instancemesh:setVertex(chevronRightId)
    end
end

local function refreshTerrain(chunkX, chunkY)
    local cx = chunkX or _G.currentChunkX
    local cy = chunkY or _G.currentChunkY
    tilesToUpdateInChunk[cx][cy] = nil
    for i = 0, chunkWidth - 1, 1 do
        for o = 0, chunkWidth - 1, 1 do
            _G.refreshTile(cx, cy, o, i)
        end
    end
    tertiaryTilesToUpdateInChunk[cx][cy] = nil
end

function _G.getTerrainTileOnMouse(mx, my)
    local MX, MY, rMX, rMY
    rMX = (mx - _G.ScreenWidth / 2) / _G.state.scaleX + _G.state.viewXview - 16
    rMY = (my - _G.ScreenHeight / 2) / _G.state.scaleX + _G.state.viewYview
    local maxTiles = 20
    local offsetY
    local LocalX = math.round(ScreenToIsoX(rMX, rMY))
    local LocalY = math.round(ScreenToIsoY(rMX, rMY))
    local lastValidGx, lastValidGy = LocalX, LocalY
    for tilesIterated = 0, maxTiles do
        offsetY = tilesIterated * 8
        MX = (mx - _G.ScreenWidth / 2) / _G.state.scaleX + _G.state.viewXview - 16
        MY = (my + offsetY * _G.state.scaleX - _G.ScreenHeight / 2) / _G.state.scaleX + _G.state.viewYview - 8
        LocalX = math.round(ScreenToIsoX(MX, MY))
        LocalY = math.round(ScreenToIsoY(MX, MY))
        local gx = LocalX
        local gy = LocalY
        local cx, cy, i, o = _G.getLocalCoordinatesFromGlobal(LocalX, LocalY)
        local elevationOffsetY = (heightmap[cx][cy][i][o] or 0) * 2
        local t = terrainTile[cx][cy][i][o]
        local cyOffset = (cx + cy) * chunkHeight * tileHeight * 0.5
        if not t or #t <= 0 then
            t = {nil, _G.IsoX + (i - o) * tileWidth * 0.5, _G.IsoY + (i + o) * tileHeight * 0.5, 0, 1.06, 1.06}
        end
        local recty = t[3] - elevationOffsetY + cyOffset
        if rMY >= recty then
            lastValidGx, lastValidGy = gx, gy
        end
    end
    return lastValidGx, lastValidGy
end

local function update()
    for _, chunk in ipairs(chunksToUpdate) do
        updateTerrain(chunk[1], chunk[2])
        refreshTerrain(chunk[1], chunk[2])
        chunksSet[chunk[1]][chunk[2]] = nil
    end
    chunksToUpdate = {}
end

local function genTerrain(cx, cy)
    _G.allocateMesh(cx, cy)
    terrain[cx][cy] = newAutotable(2)
    for i = 0, chunkWidth - 1, 1 do
        for o = 0, chunkHeight - 1, 1 do
            terrain[cx][cy][i][o] = _G.terrainBiome.abundantGrass
            _G.scheduleTerrainUpdate(cx, cy, i, o)
        end
    end
end

function _G.terrainSetTileAt(gx, gy, biome, from, force)
    local cx, cy, i, o = _G.getLocalCoordinatesFromGlobal(gx, gy)
    if _G.state.map.terrain[cx] and _G.state.map.terrain[cx][cy] then
        if from then
            if _G.state.map.terrain[cx][cy][i][o] == from then
                _G.state.map.terrain[cx][cy][i][o] = biome
                _G.scheduleTerrainUpdate(cx, cy, i, o)
            end
        else
            if force or _G.state.map.terrain[cx][cy][i][o] ~= _G.terrainBiome.none then
                _G.state.map.terrain[cx][cy][i][o] = biome
                _G.scheduleTerrainUpdate(cx, cy, i, o)
            end
        end
    end
end

function _G.getTerrainBiomeAt(gx, gy)
    local cx, cy, i, o = _G.getLocalCoordinatesFromGlobal(gx, gy)
    if _G.state.map.terrain[cx] and _G.state.map.terrain[cx][cy] then
        return _G.state.map.terrain[cx][cy][i][o]
    end
end

local function genForest()
    _G.forestGen = {}
    local forestGen = _G.forestGen

    for x = 1, math.round((_G.chunksWide * _G.chunkWidth) / 8) + 1 do
        forestGen[x] = {}
        for y = 1, math.round((_G.chunksHigh * _G.chunkHeight) / 8) + 1 do
            local Value = love.math.random(0, 100)
            if Value < 41 then
                forestGen[x][y] = true
            else
                forestGen[x][y] = false
            end
        end
    end

    local forestUpdateCounter = 0
    local forestUpdateLimit = 3

    repeat
        for x = 1, #forestGen do
            for y = 1, #forestGen[x] do
                local tile = forestGen[x][y]
                local neighborsAlive = 0
                for I = 0, 9 do
                    if I ~= 4 then
                        offsetX = math.floor(I % 3) - 1
                        offsetY = math.floor(I / 3) - 1

                        if forestGen[x + offsetX] and forestGen[x + offsetX][y + offsetY] and
                            forestGen[x + offsetX][y + offsetY] then
                            neighborsAlive = neighborsAlive + 1
                        end
                    end
                end

                if tile and neighborsAlive < 4 then
                    forestGen[x][y] = false
                end
                if not tile and neighborsAlive > 5 then
                    forestGen[x][y] = true
                end
            end
        end

        forestUpdateCounter = forestUpdateCounter + 1
    until (forestUpdateCounter == forestUpdateLimit)
end

local function genStone()
    _G.stoneGen = {}
    local stoneGen = _G.stoneGen

    local totalStones = 0
    for x = 1, math.round((_G.chunksWide * _G.chunkWidth) / 3) + 1 do
        stoneGen[x] = {}
        for y = 1, math.round((_G.chunksHigh * _G.chunkHeight) / 3) + 1 do
            local Value = love.math.random(0, 100)
            if Value < 37 then
                if not (_G.forestGen[math.round((x * 2.66) / 8) + 1][math.round((y * 2.66) / 8) + 1] ~= false) then
                    stoneGen[x][y] = true
                    totalStones = totalStones + 1
                else
                    stoneGen[x][y] = false
                end
            else
                stoneGen[x][y] = false
            end
        end
    end

    local stoneUpdateCounter = 0
    local stoneUpdateLimit = 20

    repeat
        for x = 1, #stoneGen do
            for y = 1, #stoneGen[x] do
                local tile = stoneGen[x][y]
                local neighborsAlive = 0
                for I = 0, 9 do
                    if I ~= 4 then
                        offsetX = math.floor(I % 3) - 1
                        offsetY = math.floor(I / 3) - 1

                        if stoneGen[x + offsetX] and stoneGen[x + offsetX][y + offsetY] and
                            stoneGen[x + offsetX][y + offsetY] then
                            neighborsAlive = neighborsAlive + 1
                        end
                    end
                end

                if tile and neighborsAlive < 4 then
                    stoneGen[x][y] = false
                    totalStones = totalStones - 1
                end
                if not tile and neighborsAlive > 5 then
                    stoneGen[x][y] = true
                    totalStones = totalStones + 1
                end
            end
        end

        stoneUpdateCounter = stoneUpdateCounter + 1
    until (stoneUpdateCounter == stoneUpdateLimit)
    return totalStones
end

local function genIron()
    _G.ironGen = {}
    local ironGen = _G.ironGen

    local totalIron = 0
    for x = 1, math.round((_G.chunksWide * _G.chunkWidth) / 3) + 1 do
        ironGen[x] = {}
        for y = 1, math.round((_G.chunksHigh * _G.chunkHeight) / 3) + 1 do
            local Value = love.math.random(0, 100)
            if Value < 38 then
                if not (_G.forestGen[math.round((x * 2.66) / 8) + 1][math.round((y * 2.66) / 8) + 1] ~= false) and
                    not (_G.stoneGen[x][y] ~= false) then
                    ironGen[x][y] = true
                    totalIron = totalIron + 1
                else
                    ironGen[x][y] = false
                end
            else
                ironGen[x][y] = false
            end
        end
    end

    local ironUpdateCounter = 0
    local ironUpdateLimit = 20

    repeat
        for x = 1, #ironGen do
            for y = 1, #ironGen[x] do
                local tile = ironGen[x][y]
                local neighborsAlive = 0
                for I = 0, 9 do
                    if I ~= 4 then
                        offsetX = math.floor(I % 3) - 1
                        offsetY = math.floor(I / 3) - 1

                        if ironGen[x + offsetX] and ironGen[x + offsetX][y + offsetY] and
                            ironGen[x + offsetX][y + offsetY] then
                            neighborsAlive = neighborsAlive + 1
                        end
                    end
                end

                if tile and neighborsAlive < 4 then
                    ironGen[x][y] = false
                    totalIron = totalIron - 1
                end
                if not tile and neighborsAlive > 5 then
                    ironGen[x][y] = true
                    totalIron = totalIron + 1
                end
            end
        end

        ironUpdateCounter = ironUpdateCounter + 1
    until (ironUpdateCounter == ironUpdateLimit)
    return totalIron
end

local function genMap()
    genForest()
    _G.stoneGen = {}
    local _ = genStone()
    _G.ironGen = {}
    local _ = genIron()
    for i = 0, _G.chunksWide - 1 do
        for o = 0, _G.chunksHigh - 1 do -- usually both are 32 (jumper is set like that with magic numbers)
            genTerrain(i, o)
        end
    end
end

local function allocateSpriteBatches()
    -- FIXME MAGIC NUMBERS
    for i = 0, _G.chunksWide do
        for o = 0, _G.chunksHigh do
            if terrainBatch[i][o] == nil then
                terrainBatch[i][o] = love.graphics.newSpriteBatch(terrainImage, chunkWidth * chunkHeight)
            end
        end
    end
end

local function loadFernhaven()
    require("terrain.Maps.Fernhaven")
    for i = 0, _G.chunksWide - 1 do
        for o = 0, _G.chunksHigh - 1 do
            _G.genObjects(i, o)
        end
    end
    _G.state.map.name = "Fernhaven"
end

local tableOfFunctions = {
    update = update,
    mousepressed = function()
    end,
    batch = terrainBatch,
    genTerrain = genTerrain,
    genMap = genMap,
    loadFernhaven = loadFernhaven, -- temporarily hardcorded this way
    allocateSpriteBatches = allocateSpriteBatches
}
return tableOfFunctions
