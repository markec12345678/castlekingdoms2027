local tileQuads = require("objects.object_quads")
local ScreenToIsoX, ScreenToIsoY = _G.ScreenToIsoX, _G.ScreenToIsoY
local tileWidth, tileHeight = _G.tileWidth, _G.tileHeight
local chunkWidth, chunkHeight = _G.chunkWidth, _G.chunkHeight

---@enum biome
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
---@class Terrain
local Terrain = _G.class("Terrain")
function Terrain:initialize(state)
    self.tilesToUpdateInChunk = _G.newAutotable(4)
    self.secondaryTilesToUpdateInChunk = _G.newAutotable(4)
    self.tertiaryTilesToUpdateInChunk = _G.newAutotable(4)
    self.chunksSet = newAutotable(2)
    if type(state) ~= "table" then error("expected a State class, got " .. type(state)) end
    self.state = state
    self.heightmap = self.state.map.heightmap
    self.tileheight = self.state.map.buildingheightmap
    self.terrainTile = self.state.map.terrainTile
    self.terrain = self.state.map.terrain
    self.keysToSkip = _G.newAutotable(4)
end

--- Gets the maximum size of a macro tile that can fit for that biome.
---@param biome biome
---@param cx integer Chunk X
---@param cy integer Chunk Y
---@param i integer Local X (0-63)
---@param o integer Local Y (0-63)
---@param overrideKeysToSkip? table overrides keysToSkip variable
---@return integer 1-4
function Terrain:checkMaxSizeBiome(biome, cx, cy, i, o, overrideKeysToSkip)
    local currentHeight = 0
    local keysToSkip = overrideKeysToSkip or self.keysToSkip
    if self.state.map.shadowmap[cx][cy][i][o] ~= 0 and self.state.map.shadowmap[cx][cy][i][o] ~= nil then
        return 1
    end
    if self.heightmap[cx][cy][i + 0][o + 0] ~= nil and self.heightmap[cx][cy][i + 0][o + 0] ~= currentHeight then
        return 1
    end
    if i + 1 >= chunkWidth - 1 or o + 1 >= chunkHeight - 1 then
        return 1
    end
    if self.state.map.terrain[cx][cy][i + 0][o + 1] ~= biome or keysToSkip[cx][cy][i + 0][o + 1] then
        return 1
    end
    if self.heightmap[cx][cy][i + 0][o + 1] ~= nil and self.heightmap[cx][cy][i + 0][o + 1] ~= currentHeight then
        return 1
    end
    if self.state.map.shadowmap[cx][cy][i + 0][o + 1] ~= 0 and self.state.map.shadowmap[cx][cy][i + 0][o + 1] ~= nil then
        return 1
    end
    if self.state.map.terrain[cx][cy][i + 1][o + 1] ~= biome or keysToSkip[cx][cy][i + 1][o + 1] then
        return 1
    end
    if self.heightmap[cx][cy][i + 1][o + 1] ~= nil and self.heightmap[cx][cy][i + 1][o + 1] ~= currentHeight then
        return 1
    end
    if self.state.map.shadowmap[cx][cy][i + 1][o + 1] ~= 0 and self.state.map.shadowmap[cx][cy][i + 1][o + 1] ~= nil then
        return 1
    end
    if self.state.map.terrain[cx][cy][i + 1][o + 0] ~= biome or keysToSkip[cx][cy][i + 1][o + 0] then
        return 1
    end
    if self.heightmap[cx][cy][i + 1][o + 0] ~= nil and self.heightmap[cx][cy][i + 1][o + 0] ~= currentHeight then
        return 1
    end
    if self.state.map.shadowmap[cx][cy][i + 1][o + 0] ~= 0 and self.state.map.shadowmap[cx][cy][i + 1][o + 0] ~= nil then
        return 1
    end
    if i + 2 >= chunkWidth - 1 or o + 2 >= chunkHeight - 1 then
        return 2
    end
    if self.state.map.shadowmap[cx][cy][i + 2][o + 2] ~= 0 and self.state.map.shadowmap[cx][cy][i + 2][o + 2] ~= nil then
        return 2
    end
    if self.state.map.terrain[cx][cy][i + 2][o + 0] ~= biome or keysToSkip[cx][cy][i + 2][o + 0] then
        return 2
    end
    if self.heightmap[cx][cy][i + 2][o + 0] ~= nil and self.heightmap[cx][cy][i + 2][o + 0] ~= currentHeight then
        return 2
    end
    if self.state.map.shadowmap[cx][cy][i + 2][o + 0] ~= 0 and self.state.map.shadowmap[cx][cy][i + 2][o + 0] ~= nil then
        return 2
    end
    if self.state.map.terrain[cx][cy][i + 2][o + 1] ~= biome or keysToSkip[cx][cy][i + 2][o + 1] then
        return 2
    end
    if self.heightmap[cx][cy][i + 2][o + 1] ~= nil and self.heightmap[cx][cy][i + 2][o + 1] ~= currentHeight then
        return 2
    end
    if self.state.map.shadowmap[cx][cy][i + 2][o + 1] ~= 0 and self.state.map.shadowmap[cx][cy][i + 2][o + 1] ~= nil then
        return 2
    end
    if self.state.map.terrain[cx][cy][i + 2][o + 2] ~= biome or keysToSkip[cx][cy][i + 2][o + 2] then
        return 2
    end
    if self.heightmap[cx][cy][i + 2][o + 2] ~= nil and self.heightmap[cx][cy][i + 2][o + 2] ~= currentHeight then
        return 2
    end
    if self.state.map.shadowmap[cx][cy][i + 2][o + 2] ~= 0 and self.state.map.shadowmap[cx][cy][i + 2][o + 2] ~= nil then
        return 2
    end
    if self.state.map.terrain[cx][cy][i + 0][o + 2] ~= biome or keysToSkip[cx][cy][i + 0][o + 2] then
        return 2
    end
    if self.heightmap[cx][cy][i + 0][o + 2] ~= nil and self.heightmap[cx][cy][i + 0][o + 2] ~= currentHeight then
        return 2
    end
    if self.state.map.shadowmap[cx][cy][i + 0][o + 2] ~= 0 and self.state.map.shadowmap[cx][cy][i + 0][o + 2] ~= nil then
        return 2
    end
    if self.state.map.terrain[cx][cy][i + 1][o + 2] ~= biome or keysToSkip[cx][cy][i + 1][o + 2] then
        return 2
    end
    if self.heightmap[cx][cy][i + 1][o + 2] ~= nil and self.heightmap[cx][cy][i + 1][o + 2] ~= currentHeight then
        return 2
    end
    if self.state.map.shadowmap[cx][cy][i + 1][o + 2] ~= 0 and self.state.map.shadowmap[cx][cy][i + 1][o + 2] ~= nil then
        return 2
    end
    if i + 3 >= chunkWidth - 1 or o + 3 >= chunkHeight - 1 then
        return 3
    end
    if self.state.map.shadowmap[cx][cy][i + 3][o + 3] ~= 0 and self.state.map.shadowmap[cx][cy][i + 3][o + 3] ~= nil then
        return 1
    end
    if self.state.map.terrain[cx][cy][i + 3][o + 0] ~= biome or keysToSkip[cx][cy][i + 3][o + 0] then
        return 3
    end
    if self.heightmap[cx][cy][i + 3][o + 0] ~= nil and self.heightmap[cx][cy][i + 3][o + 0] ~= currentHeight then
        return 3
    end
    if self.state.map.shadowmap[cx][cy][i + 3][o + 0] ~= 0 and self.state.map.shadowmap[cx][cy][i + 3][o + 0] ~= nil then
        return 3
    end
    if self.state.map.terrain[cx][cy][i + 3][o + 1] ~= biome or keysToSkip[cx][cy][i + 3][o + 1] then
        return 3
    end
    if self.heightmap[cx][cy][i + 3][o + 1] ~= nil and self.heightmap[cx][cy][i + 3][o + 1] ~= currentHeight then
        return 3
    end
    if self.state.map.shadowmap[cx][cy][i + 3][o + 1] ~= 0 and self.state.map.shadowmap[cx][cy][i + 3][o + 1] ~= nil then
        return 3
    end
    if self.state.map.terrain[cx][cy][i + 3][o + 2] ~= biome or keysToSkip[cx][cy][i + 3][o + 2] then
        return 3
    end
    if self.heightmap[cx][cy][i + 3][o + 2] ~= nil and self.heightmap[cx][cy][i + 3][o + 2] ~= currentHeight then
        return 3
    end
    if self.state.map.shadowmap[cx][cy][i + 3][o + 2] ~= 0 and self.state.map.shadowmap[cx][cy][i + 3][o + 2] ~= nil then
        return 3
    end
    if self.state.map.terrain[cx][cy][i + 3][o + 3] ~= biome or keysToSkip[cx][cy][i + 3][o + 3] then
        return 3
    end
    if self.heightmap[cx][cy][i + 3][o + 3] ~= nil and self.heightmap[cx][cy][i + 3][o + 3] ~= currentHeight then
        return 3
    end
    if self.state.map.shadowmap[cx][cy][i + 3][o + 3] ~= 0 and self.state.map.shadowmap[cx][cy][i + 3][o + 3] ~= nil then
        return 3
    end
    if self.state.map.terrain[cx][cy][i + 0][o + 3] ~= biome or keysToSkip[cx][cy][i + 0][o + 3] then
        return 3
    end
    if self.heightmap[cx][cy][i + 0][o + 3] ~= nil and self.heightmap[cx][cy][i + 0][o + 3] ~= currentHeight then
        return 3
    end
    if self.state.map.shadowmap[cx][cy][i + 0][o + 3] ~= 0 and self.state.map.shadowmap[cx][cy][i + 0][o + 3] ~= nil then
        return 3
    end
    if self.state.map.terrain[cx][cy][i + 1][o + 3] ~= biome or keysToSkip[cx][cy][i + 1][o + 3] then
        return 3
    end
    if self.heightmap[cx][cy][i + 1][o + 3] ~= nil and self.heightmap[cx][cy][i + 1][o + 3] ~= currentHeight then
        return 3
    end
    if self.state.map.shadowmap[cx][cy][i + 1][o + 3] ~= 0 and self.state.map.shadowmap[cx][cy][i + 1][o + 3] ~= nil then
        return 3
    end
    if self.state.map.terrain[cx][cy][i + 2][o + 3] ~= biome or keysToSkip[cx][cy][i + 2][o + 3] then
        return 3
    end
    if self.heightmap[cx][cy][i + 2][o + 3] ~= nil and self.heightmap[cx][cy][i + 2][o + 3] ~= currentHeight then
        return 3
    end
    if self.state.map.shadowmap[cx][cy][i + 2][o + 3] ~= 0 and self.state.map.shadowmap[cx][cy][i + 2][o + 3] ~= nil then
        return 3
    end
    return 4
end

--- Gets rid of a macro tile (up to 4x4) at the specified position
--- Used to clear space in order to place a smaller tile, or a bigger one
---@param size integer 1-4 size of the tile
---@param cx integer Chunk X
---@param cy integer Chunk Y
---@param i integer Local X (0-63)
---@param o integer Local Y (0-63)
function Terrain:freeMultiTileTerrain(size, cx, cy, i, o)
    self.keysToSkip[cx][cy][i][o] = false
    self.terrainTile[cx][cy][i][o] = nil
    self.secondaryTilesToUpdateInChunk[cx][cy][i][o] = true
    self.tertiaryTilesToUpdateInChunk[cx][cy][i][o] = true
    self.keysToSkip[cx][cy][i + 1][o] = false
    self.terrainTile[cx][cy][i + 1][o] = nil
    self.secondaryTilesToUpdateInChunk[cx][cy][i + 1][o] = true
    self.tertiaryTilesToUpdateInChunk[cx][cy][i + 1][o] = true
    self.keysToSkip[cx][cy][i + 1][o + 1] = false
    self.terrainTile[cx][cy][i + 1][o + 1] = nil
    self.secondaryTilesToUpdateInChunk[cx][cy][i + 1][o + 1] = true
    self.tertiaryTilesToUpdateInChunk[cx][cy][i + 1][o + 1] = true
    self.keysToSkip[cx][cy][i][o + 1] = false
    self.terrainTile[cx][cy][i][o + 1] = nil
    self.secondaryTilesToUpdateInChunk[cx][cy][i][o + 1] = true
    self.tertiaryTilesToUpdateInChunk[cx][cy][i][o + 1] = true
    if size >= 3 then
        self.keysToSkip[cx][cy][i + 2][o] = false
        self.terrainTile[cx][cy][i + 2][o] = nil
        self.secondaryTilesToUpdateInChunk[cx][cy][i + 2][o] = true
        self.tertiaryTilesToUpdateInChunk[cx][cy][i + 2][o] = true
        self.keysToSkip[cx][cy][i + 2][o + 1] = false
        self.terrainTile[cx][cy][i + 2][o + 1] = nil
        self.secondaryTilesToUpdateInChunk[cx][cy][i + 2][o + 1] = true
        self.tertiaryTilesToUpdateInChunk[cx][cy][i + 2][o + 1] = true
        self.keysToSkip[cx][cy][i + 2][o + 2] = false
        self.terrainTile[cx][cy][i + 2][o + 2] = nil
        self.secondaryTilesToUpdateInChunk[cx][cy][i + 2][o + 2] = true
        self.tertiaryTilesToUpdateInChunk[cx][cy][i + 2][o + 2] = true
        self.keysToSkip[cx][cy][i][o + 2] = false
        self.terrainTile[cx][cy][i][o + 2] = nil
        self.secondaryTilesToUpdateInChunk[cx][cy][i][o + 2] = true
        self.tertiaryTilesToUpdateInChunk[cx][cy][i][o + 2] = true
        self.keysToSkip[cx][cy][i + 1][o + 2] = false
        self.terrainTile[cx][cy][i + 1][o + 2] = nil
        self.secondaryTilesToUpdateInChunk[cx][cy][i + 1][o + 2] = true
        self.tertiaryTilesToUpdateInChunk[cx][cy][i + 1][o + 2] = true
    end
    if size >= 4 then
        self.keysToSkip[cx][cy][i + 3][o] = false
        self.terrainTile[cx][cy][i + 3][o] = nil
        self.secondaryTilesToUpdateInChunk[cx][cy][i + 3][o] = true
        self.tertiaryTilesToUpdateInChunk[cx][cy][i + 3][o] = true
        self.keysToSkip[cx][cy][i + 3][o + 1] = false
        self.terrainTile[cx][cy][i + 3][o + 1] = nil
        self.secondaryTilesToUpdateInChunk[cx][cy][i + 3][o + 1] = true
        self.tertiaryTilesToUpdateInChunk[cx][cy][i + 3][o + 1] = true
        self.keysToSkip[cx][cy][i + 3][o + 2] = false
        self.terrainTile[cx][cy][i + 3][o + 2] = nil
        self.secondaryTilesToUpdateInChunk[cx][cy][i + 3][o + 2] = true
        self.tertiaryTilesToUpdateInChunk[cx][cy][i + 3][o + 2] = true
        self.keysToSkip[cx][cy][i + 3][o + 3] = false
        self.terrainTile[cx][cy][i + 3][o + 3] = nil
        self.secondaryTilesToUpdateInChunk[cx][cy][i + 3][o + 3] = true
        self.tertiaryTilesToUpdateInChunk[cx][cy][i + 3][o + 3] = true
        self.keysToSkip[cx][cy][i][o + 3] = false
        self.terrainTile[cx][cy][i][o + 3] = nil
        self.secondaryTilesToUpdateInChunk[cx][cy][i][o + 3] = true
        self.tertiaryTilesToUpdateInChunk[cx][cy][i][o + 3] = true
        self.keysToSkip[cx][cy][i + 1][o + 3] = false
        self.terrainTile[cx][cy][i + 1][o + 3] = nil
        self.secondaryTilesToUpdateInChunk[cx][cy][i + 1][o + 3] = true
        self.tertiaryTilesToUpdateInChunk[cx][cy][i + 1][o + 3] = true
        self.keysToSkip[cx][cy][i + 2][o + 3] = false
        self.terrainTile[cx][cy][i + 2][o + 3] = nil
        self.secondaryTilesToUpdateInChunk[cx][cy][i + 2][o + 3] = true
        self.tertiaryTilesToUpdateInChunk[cx][cy][i + 2][o + 3] = true
    end
end

--- Prepares the self.terrain for a macro tile
---@param size integer 1-4 size of the tile
---@param cx integer Chunk X
---@param cy integer Chunk Y
---@param i integer Local X (0-63)
---@param o integer Local Y (0-63)
function Terrain:multiTileTerrain(size, cx, cy, i, o, biome)
    self.terrainTile[cx][cy][i][o] = nil
    self.keysToSkip[cx][cy][i][o] = {
        i,
        o,
        ["size"] = 2,
        ["biome"] = biome,
        ["cx"] = cx,
        ["cy"] = cy
    }
    self.keysToSkip[cx][cy][i + 1][o] = { i, o }
    self.terrainTile[cx][cy][i + 1][o] = nil
    self.keysToSkip[cx][cy][i + 1][o + 1] = { i, o }
    self.terrainTile[cx][cy][i + 1][o + 1] = nil
    self.keysToSkip[cx][cy][i][o + 1] = { i, o }
    self.terrainTile[cx][cy][i][o + 1] = nil
    if size >= 3 then
        self.terrainTile[cx][cy][i][o] = nil
        self.keysToSkip[cx][cy][i][o] = {
            i,
            o,
            ["size"] = 3,
            ["biome"] = biome,
            ["cx"] = cx,
            ["cy"] = cy
        }
        self.keysToSkip[cx][cy][i + 2][o] = { i, o }
        self.terrainTile[cx][cy][i + 2][o] = nil
        self.keysToSkip[cx][cy][i + 2][o + 1] = { i, o }
        self.terrainTile[cx][cy][i + 2][o + 1] = nil
        self.keysToSkip[cx][cy][i + 2][o + 2] = { i, o }
        self.terrainTile[cx][cy][i + 2][o + 2] = nil
        self.keysToSkip[cx][cy][i][o + 2] = { i, o }
        self.terrainTile[cx][cy][i][o + 2] = nil
        self.keysToSkip[cx][cy][i + 1][o + 2] = { i, o }
        self.terrainTile[cx][cy][i + 1][o + 2] = nil
    end
    if size >= 4 then
        self.terrainTile[cx][cy][i][o] = nil
        self.keysToSkip[cx][cy][i][o] = {
            i,
            o,
            ["size"] = 4,
            ["biome"] = biome,
            ["cx"] = cx,
            ["cy"] = cy
        }
        self.keysToSkip[cx][cy][i + 3][o] = { i, o }
        self.terrainTile[cx][cy][i + 3][o] = nil
        self.keysToSkip[cx][cy][i + 3][o + 1] = { i, o }
        self.terrainTile[cx][cy][i + 3][o + 1] = nil
        self.keysToSkip[cx][cy][i + 3][o + 2] = { i, o }
        self.terrainTile[cx][cy][i + 3][o + 2] = nil
        self.keysToSkip[cx][cy][i + 3][o + 3] = { i, o }
        self.terrainTile[cx][cy][i + 3][o + 3] = nil
        self.keysToSkip[cx][cy][i][o + 3] = { i, o }
        self.terrainTile[cx][cy][i][o + 3] = nil
        self.keysToSkip[cx][cy][i + 1][o + 3] = { i, o }
        self.terrainTile[cx][cy][i + 1][o + 3] = nil
        self.keysToSkip[cx][cy][i + 2][o + 3] = { i, o }
        self.terrainTile[cx][cy][i + 2][o + 3] = nil
    end
end

local chunksToUpdate = {}
--- Schedules a self.terrain update for the specified coordinates.
--- Also updates tiles in a 8x8 radius in order to account for macro tiles
---@param cx integer Chunk X
---@param cy integer Chunk Y
---@param i integer Local X (0-63)
---@param o integer Local Y (0-63)
function Terrain:scheduleTerrainUpdate(cx, cy, i, o)
    if (not _G.isChunkCoordinateInsideMap(cx, cy)) then
        return
    end

    self.tilesToUpdateInChunk[cx][cy][i][o] = true
    self.tertiaryTilesToUpdateInChunk[cx][cy][i][o] = true
    for x = -4, 4 do
        for y = -4, 4 do
            self.secondaryTilesToUpdateInChunk[cx][cy][i + x][o + y] = true
            self.tertiaryTilesToUpdateInChunk[cx][cy][i + x][o + y] = true
        end
    end
    if not self.chunksSet[cx][cy] then
        chunksToUpdate[#chunksToUpdate + 1] = { cx, cy }
        self.chunksSet[cx][cy] = true
    end
end

--- Schedules a tight self.terrain update for the specified coordinates.
--- Only updates a single tile unlike `scheduleTerrainUpdate()`.
--- Do not use unless you know what you're doing.
---@param cx integer Chunk X
---@param cy integer Chunk Y
---@param i integer Local X (0-63)
---@param o integer Local Y (0-63)
function Terrain:scheduleTightTerrainUpdate(cx, cy, i, o)
    self.tertiaryTilesToUpdateInChunk[cx][cy][i][o] = true
    if not self.chunksSet[cx][cy] then
        chunksToUpdate[#chunksToUpdate + 1] = { cx, cy }
        self.chunksSet[cx][cy] = true
    end
end

--- Elevates tile at position. Triggers a self.terrain update at position.
---@param gx integer Global X tile position
---@param gy integer Global Y tile position
function Terrain:terrainElevateTileAt(gx, gy)
    local cx, cy, i, o = _G.getLocalCoordinatesFromGlobal(gx, gy)
    if self.state.map.terrain[cx] and self.state.map.terrain[cx][cy] then
        if self.heightmap[cx][cy][i][o] then
            self.heightmap[cx][cy][i][o] = self.heightmap[cx][cy][i][o] + 1
        else
            self.heightmap[cx][cy][i][o] = 1
        end
        self.heightmap[cx][cy][i][o] = math.min(self.heightmap[cx][cy][i][o], 80)
        self:scheduleTerrainUpdate(cx, cy, i, o)
    end
end

--- Elevates tile at position. Triggers a self.terrain update at position.
---@param gx integer Global X tile position
---@param gy integer Global Y tile position
function Terrain:terrainDescendTileAt(gx, gy)
    local cx, cy, i, o = _G.getLocalCoordinatesFromGlobal(gx, gy)
    if self.state.map.terrain[cx] and self.state.map.terrain[cx][cy] then
        if self.heightmap[cx][cy][i][o] then
            self.heightmap[cx][cy][i][o] = self.heightmap[cx][cy][i][o] - 1
        else
            self.heightmap[cx][cy][i][o] = -1
        end
        self.heightmap[cx][cy][i][o] = math.max(self.heightmap[cx][cy][i][o], -20)
        self:scheduleTerrainUpdate(cx, cy, i, o)
    end
end

--- Sets the tile height to a specific value.
---@param gx integer Global X tile position
---@param gy integer Global Y tile position
---@param value number the elevation height
function Terrain:terrainSetHeight(gx, gy, value)
    local cx, cy, i, o = _G.getLocalCoordinatesFromGlobal(gx, gy)
    self.heightmap[cx][cy][i][o] = value
    self:scheduleTerrainUpdate(cx, cy, i, o)
end

--- Calculates the sprite range depending on the biome and max size of tile in that position.
---@param currentBiome biome
---@param cx integer Chunk X
---@param cy integer Chunk Y
---@param i integer Local X (0-63)
---@param o integer Local Y (0-63)
function Terrain:multiTileCalculate(currentBiome, cx, cy, i, o)
    local gx = chunkWidth * cx + i
    local gy = chunkWidth * cy + o
    local lScale = 1.0666
    local maxSize = self:checkMaxSizeBiome(currentBiome, cx, cy, i, o, self.keysToSkip)
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
    if currentBiome ~= _G.terrainBiome.abundantGrassStonesWhite and currentBiome ~= _G.terrainBiome.sea and
        currentBiome ~= _G.terrainBiome.seaWalkable then
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
        local north = self:getTerrainBiomeAt(gx, gy - 1) == _G.terrainBiome.sea or
            self:getTerrainBiomeAt(gx, gy - 1) == _G.terrainBiome.seaWalkable
        local south = self:getTerrainBiomeAt(gx, gy + 1) == _G.terrainBiome.sea or
            self:getTerrainBiomeAt(gx, gy + 1) == _G.terrainBiome.seaWalkable
        local east = self:getTerrainBiomeAt(gx + 1, gy) == _G.terrainBiome.sea or
            self:getTerrainBiomeAt(gx + 1, gy) == _G.terrainBiome.seaWalkable
        local west = self:getTerrainBiomeAt(gx - 1, gy) == _G.terrainBiome.sea or
            self:getTerrainBiomeAt(gx - 1, gy) == _G.terrainBiome.seaWalkable
        local ne = self:getTerrainBiomeAt(gx + 1, gy - 1) == _G.terrainBiome.sea or
            self:getTerrainBiomeAt(gx + 1, gy - 1) == _G.terrainBiome.seaWalkable
        local nw = self:getTerrainBiomeAt(gx - 1, gy - 1) == _G.terrainBiome.sea or
            self:getTerrainBiomeAt(gx - 1, gy - 1) == _G.terrainBiome.seaWalkable
        local se = self:getTerrainBiomeAt(gx + 1, gy + 1) == _G.terrainBiome.sea or
            self:getTerrainBiomeAt(gx + 1, gy + 1) == _G.terrainBiome.seaWalkable
        local sw = self:getTerrainBiomeAt(gx - 1, gy + 1) == _G.terrainBiome.sea or
            self:getTerrainBiomeAt(gx - 1, gy + 1) == _G.terrainBiome.seaWalkable
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
            tileKey = self.terrain[cx][cy][i][o] .. "_1x1 (" .. tostring(rand) .. ")"
            local _, _, _, lh = tileQuads[tileKey]:getViewport()
            lOffsetY = lOffsetY + 16 - lh
        elseif rand > 16 and rand <= 20 then
            lOffsetX = -16 - 4
            self:multiTileTerrain(2, cx, cy, i, o, currentBiome)
            tileKey = self.terrain[cx][cy][i][o] .. "_2x2 (" .. tostring(21 - rand) .. ")"
            local _, _, lw, lh = tileQuads[tileKey]:getViewport()
            lOffsetY = lOffsetY + 32 - lh
            lOffsetX = lOffsetX + 62 - lw
        elseif rand > 20 and rand <= 24 then
            lOffsetX = -32
            self:multiTileTerrain(3, cx, cy, i, o, currentBiome)
            tileKey = self.terrain[cx][cy][i][o] .. "_3x3 (" .. tostring(25 - rand) .. ")"
            local _, _, lw, lh = tileQuads[tileKey]:getViewport()
            lOffsetY = lOffsetY + 48 - lh
            lOffsetX = lOffsetX + 94 - lw
        else
            lOffsetX = -32 - 16
            self:multiTileTerrain(4, cx, cy, i, o, currentBiome)
            tileKey = self.terrain[cx][cy][i][o] .. "_4x4 (" .. tostring(29 - rand) .. ")"
            local _, _, lw, lh = tileQuads[tileKey]:getViewport()
            lOffsetY = lOffsetY + 64 - lh
            lOffsetX = lOffsetX + 124 - lw
        end
    end
    if currentBiome == _G.terrainBiome.abundantGrass then
        lOffsetY = lOffsetY + 1
    end
    if rand == 0 then
        self.terrainTile[cx][cy][i][o] = nil
    else
        self.terrainTile[cx][cy][i][o] = { tileQuads[tileKey], _G.IsoX + (i - o) * tileWidth * 0.5 + lOffsetX,
            _G.IsoY + (i + o) * tileHeight * 0.5 + lOffsetY, 0, lScale, lScale }
    end
end

--- Second pass of terrain updates.
---@private
---@param chunkX integer Chunk X
---@param chunkY integer Chunk Y
function Terrain:updateTerrain2ndPass(chunkX, chunkY)
    local cx = chunkX or _G.currentChunkX
    local cy = chunkY or _G.currentChunkY
    for i = 0, chunkWidth - 1, 1 do
        for o = 0, chunkWidth - 1, 1 do
            if self.secondaryTilesToUpdateInChunk[cx][cy][i] and self.secondaryTilesToUpdateInChunk[cx][cy][i][o] then
                local currentBiome = self.terrain[cx][cy][i][o]
                local multiTileOrigin
                if self.keysToSkip[cx][cy][i][o] then
                    local curIdx = self.keysToSkip[cx][cy][i][o]
                    if curIdx["size"] then
                        multiTileOrigin = curIdx
                    else
                        if curIdx[1] and curIdx[2] then
                            multiTileOrigin = self.keysToSkip[cx][cy][curIdx[1]][curIdx[2]]
                        else
                            goto continue
                        end
                    end
                    local mt = multiTileOrigin
                    if mt.biome ~= currentBiome then
                        self.terrainTile[cx][cy][mt[1]][mt[2]] = {}
                        self:freeMultiTileTerrain(multiTileOrigin.size, cx, cy, mt[1], mt[2])
                    end
                end
                if self.keysToSkip[cx][cy][i][o] then
                    goto endMultiTile
                end
                self:multiTileCalculate(currentBiome, cx, cy, i, o)
            end
            ::endMultiTile::
        end
    end
    self.secondaryTilesToUpdateInChunk[cx][cy] = nil
end

local emptyTable = newAutotable(4)

--- First pass of terrain updates.
---@private
---@param chunkX integer Chunk X
---@param chunkY integer Chunk Y
function Terrain:updateTerrain(chunkX, chunkY)
    local cx = chunkX or _G.currentChunkX
    local cy = chunkY or _G.currentChunkY
    if (not _G.isGlobalCoordInsideMap(cx, cy)) then
        print((debug.traceback("Error: trying to updateTerrain outside map", 1):gsub("\n[^\n]+$", "")))
        return
    end

    for i = 0, chunkWidth - 1, 1 do
        for o = 0, chunkWidth - 1, 1 do
            if not self.tilesToUpdateInChunk[cx][cy][i][o] and not self.tertiaryTilesToUpdateInChunk[cx][cy][i][o] then
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
                        if self.heightmap[curCx] and self.heightmap[curCx][curCy] then
                            totalHeight = totalHeight + (self.heightmap[curCx][curCy][curI][curO] or 0)
                        end
                    end
                end
            end
            local prevCx, prevCy, prevI, prevO = _G.getLocalCoordinatesFromGlobal(gx - 1, gy + 1)

            local prevHeight, prevShadow, prevTileheight = 0, 0, 0
            if self.state.map.terrain[prevCx] and self.state.map.terrain[prevCx][prevCy] then
                prevHeight = self.heightmap[prevCx][prevCy][prevI][prevO] or 0
                prevHeight = 75 * prevHeight / (40 + prevHeight)
                prevShadow = self.state.map.shadowmap[prevCx][prevCy][prevI][prevO] or 0
                prevTileheight = self.tileheight[prevCx][prevCy][prevI][prevO] or 0
            end
            local lastShadow = self.state.map.shadowmap[cx][cy][i][o]
            self.state.map.shadowmap[cx][cy][i][o] = math.max(math.max(prevHeight + prevTileheight, prevShadow) - 3.5, 0)
            if not _G.BuildController.start and lastShadow ~= self.state.map.shadowmap[cx][cy][i][o] then
                local cx, cy, i, o = _G.getLocalCoordinatesFromGlobal(gx + 1, gy - 1)
                if cx < chunksWide and cy < chunksHigh and cx >= 0 and cy >= 0 then
                    if not _G.BuildController.start then
                        self:scheduleTightTerrainUpdate(cx, cy, i, o)
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
            local prev1Height = self.heightmap[prev1Cx][prev1Cy][prev1I][prev1O] or 0
            prev1Height = 75 * prev1Height / (40 + prev1Height)
            local prev1Shadow = self.state.map.shadowmap[prev1Cx][prev1Cy][prev1I][prev1O] or 0
            local prev1Tileheight = self.tileheight[prev1Cx][prev1Cy][prev1I][prev1O] or 0
            local prev2Height = self.heightmap[prev2Cx][prev2Cy][prev2I][prev2O] or 0
            prev2Height = 75 * prev2Height / (40 + prev2Height)
            local prev2Shadow = self.state.map.shadowmap[prev2Cx][prev2Cy][prev2I][prev2O] or 0
            local prev2Tileheight = self.tileheight[prev2Cx][prev2Cy][prev2I][prev2O] or 0
            local prev1ShadowValue = math.max(math.max(prev1Height + prev1Tileheight, prev1Shadow) - 3.5, 0)
            local prev2ShadowValue = math.max(math.max(prev2Height + prev2Tileheight, prev2Shadow) - 3.5, 0)

            local prev3I = (gx + 1) % (chunkWidth)
            local prev3O = (gy) % (chunkWidth)
            local prev3Cx = math.floor((gx + 1) / chunkWidth)
            local prev3Cy = math.floor((gy) / chunkWidth)
            local prev3Height = self.heightmap[prev3Cx][prev3Cy][prev3I][prev3O] or 0
            prev3Height = 75 * prev3Height / (40 + prev3Height)
            local prev3Tileheight = self.tileheight[prev3Cx][prev3Cy][prev3I][prev3O] or 0
            local prev3Shadow = self.state.map.shadowmap[prev3Cx][prev3Cy][prev3I][prev3O] or 0
            local prev3ShadowValue = math.max(math.max(prev3Height + prev3Tileheight, prev3Shadow) - 3.5, 0)

            local prev4I = (gx) % (chunkWidth)
            local prev4O = (gy - 1) % (chunkWidth)
            local prev4Cx = math.floor((gx) / chunkWidth)
            local prev4Cy = math.floor((gy - 1) / chunkWidth)
            local prev4Height = self.heightmap[prev4Cx][prev4Cy][prev4I][prev4O] or 0
            prev4Height = 75 * prev4Height / (40 + prev4Height)
            local prev4Tileheight = self.tileheight[prev4Cx][prev4Cy][prev4I][prev4O] or 0
            local prev4Shadow = self.state.map.shadowmap[prev4Cx][prev4Cy][prev4I][prev4O] or 0
            local prev4ShadowValue = math.max(math.max(prev4Height + prev4Tileheight, prev4Shadow) - 3.5, 0)
            -- self.state.map.shadowmap[cx][cy][i][o] = math.max(shadowmap[cx][cy][i][o], prev1ShadowValue / 2, prev2ShadowValue / 2)
            if (prev1ShadowValue == prev2ShadowValue) and prev1ShadowValue > self.state.map.shadowmap[cx][cy][i][o] then
                self.state.map.shadowmap[cx][cy][i][o] = prev1ShadowValue
            end
            local currentShadow = self.state.map.shadowmap[cx][cy][i][o] or 0
            local elevationOffsetY = self.heightmap[cx][cy][i][o] or 0
            local elevationValue = 75 * elevationOffsetY / (40 + elevationOffsetY)
            local isInShadow = currentShadow > elevationOffsetY or currentShadow > elevationValue
            if not isInShadow then
                local interpolatedShadowVal = (prev1ShadowValue * 2 + prev2ShadowValue * 2 + prev3ShadowValue +
                    prev4ShadowValue) / 6
                self.state.map.shadowmap[cx][cy][i][o] = interpolatedShadowVal
            end

            if self.tilesToUpdateInChunk[cx][cy][i] and self.tilesToUpdateInChunk[cx][cy][i][o] then
                local currentBiome = self.terrain[cx][cy][i][o]
                local multiTileOrigin
                if self.keysToSkip[cx][cy][i][o] then
                    local curIdx = self.keysToSkip[cx][cy][i][o]
                    if curIdx["size"] then
                        multiTileOrigin = curIdx
                    else
                        if curIdx[1] and curIdx[2] then
                            multiTileOrigin = self.keysToSkip[cx][cy][curIdx[1]][curIdx[2]]
                        else
                            goto continue
                        end
                    end
                    local mt = multiTileOrigin
                    local maxSize = self:checkMaxSizeBiome(currentBiome, mt.cx, mt.cy, mt[1], mt[2])
                    if maxSize ~= mt.size or multiTileOrigin.biome ~= currentBiome then
                        self.terrainTile[cx][cy][mt[1]][mt[2]] = {}
                        self:freeMultiTileTerrain(multiTileOrigin.size, cx, cy, mt[1], mt[2])
                    end
                end
                if self.keysToSkip[cx][cy][i][o] then
                    goto continue
                end
                self:multiTileCalculate(currentBiome, cx, cy, i, o)
            end
            ::continue::
            self.tilesToUpdateInChunk[cx][cy][i][o] = nil
            if self.state.map.shadowmap[cx][cy][i][o] and self.state.map.shadowmap[cx][cy][i][o] > 0 and
                self.terrain[cx][cy] then
                local currentBiome = self.terrain[cx][cy][i][o]
                local multiTileOrigin
                if self.keysToSkip[cx][cy][i][o] then
                    local curIdx = self.keysToSkip[cx][cy][i][o]
                    if curIdx["size"] then
                        multiTileOrigin = curIdx
                    else
                        if curIdx[1] and curIdx[2] then
                            multiTileOrigin = self.keysToSkip[cx][cy][curIdx[1]][curIdx[2]]
                        else
                            goto continue
                        end
                    end
                    local mt = multiTileOrigin
                    local maxSize = self:checkMaxSizeBiome(currentBiome, mt.cx, mt.cy, mt[1], mt[2], emptyTable)
                    if maxSize ~= mt.size then
                        self.terrainTile[cx][cy][mt[1]][mt[2]] = {}
                        self:freeMultiTileTerrain(multiTileOrigin.size, cx, cy, mt[1], mt[2])
                    end
                end
            end
            ::endFirstPass::
        end
    end
    self:updateTerrain2ndPass(cx, cy)
end

--- Whether the tile at position should be a cliff.
---@param myGx integer Global X
---@param myGy integer Global Y
---@param allDirections boolean whether to check in all directions or just the ones that face the camera
---@return boolean isCliff the tile should be a cliff
function Terrain:tileShouldBeCliff(myGx, myGy, allDirections)
    local cx, cy, i, o = _G.getLocalCoordinatesFromGlobal(myGx, myGy)
    local myHeight = self.heightmap[cx][cy][i][o] or 0
    cx, cy, i, o = _G.getLocalCoordinatesFromGlobal(myGx + 1, myGy)
    local tileLeftHeight = self.heightmap[cx][cy][i][o] or 0
    local heightCuttoff = 8
    if (myHeight - tileLeftHeight) > heightCuttoff then
        self.state.map:setWalkable(myGx, myGy, 1)
        return true
    end
    cx, cy, i, o = _G.getLocalCoordinatesFromGlobal(myGx, myGy + 1)
    local tileRightHeight = self.heightmap[cx][cy][i][o] or 0
    if (myHeight - tileRightHeight) > heightCuttoff then
        self.state.map:setWalkable(myGx, myGy, 1)
        return true
    end
    cx, cy, i, o = _G.getLocalCoordinatesFromGlobal(myGx + 1, myGy + 1)
    if self.terrain[cx][cy] and self.terrain[cx][cy][i] and self.terrain[cx][cy][i][o] == _G.terrainBiome.none then
        return true
    end
    cx, cy, i, o = _G.getLocalCoordinatesFromGlobal(myGx, myGy - 1)
    if myHeight - (self.heightmap[cx][cy][i][o] or 0) > heightCuttoff then
        self.state.map:setWalkable(myGx, myGy, 1)
        if allDirections then
            return true
        end
    end
    cx, cy, i, o = _G.getLocalCoordinatesFromGlobal(myGx - 1, myGy - 1)
    if myHeight - (self.heightmap[cx][cy][i][o] or 0) > heightCuttoff then
        self.state.map:setWalkable(myGx, myGy, 1)
        if allDirections then
            return true
        end
    end
    cx, cy, i, o = _G.getLocalCoordinatesFromGlobal(myGx - 1, myGy)
    if myHeight - (self.heightmap[cx][cy][i][o] or 0) > heightCuttoff then
        self.state.map:setWalkable(myGx, myGy, 1)
        if allDirections then
            return true
        end
    end
    local gx, gy = myGx + 1, myGy
    i = (gx) % (chunkWidth)
    o = (gy) % (chunkWidth)
    cx = math.floor(gx / chunkWidth)
    cy = math.floor(gy / chunkWidth)
    if self.terrain[cx][cy] and self.terrain[cx][cy][i] and self.terrain[cx][cy][i][o] == _G.terrainBiome.none then
        return true
    end
    return false
end

local function inferZ(cx, cy, i, o, elevation)
    local gx = chunkWidth * cx + i
    local gy = chunkWidth * cy + o
    return (gx * 0.5 + gy + (elevation / 90)) / 3081
end


--- Final render of the tile with shadows and elevation.
---@private
---@param cx integer Chunk X
---@param cy integer Chunk Y
---@param i integer Local X (0-63)
---@param o integer Local Y (0-63)
---@param force boolean render regardless of requirements
function Terrain:refreshTile(cx, cy, i, o, force)
    -- TODO: cleanup
    -- local chevronRightId = _G.getChevronVertexRight(cx, cy, i, o)
    local instancemesh = self.state.objectMesh[cx][cy]

    if (self.terrain[cx][cy][i][o] ~= _G.terrainBiome.none and self.tertiaryTilesToUpdateInChunk[cx][cy][i][o] == true) or force then
        local vertId = _G.getTerrainVertex(cx, cy, i, o)
        instancemesh:setVertex(vertId)
        -- _G.freeTerrainVertex(vertId, cx, cy)
        local elevationOffsetY = self.heightmap[cx][cy][i][o] or 0
        local elevationValue = 75 * elevationOffsetY / (40 + elevationOffsetY)
        local shadowValue = self.state.map.shadowmap[cx][cy][i][o] or 0
        local thisTileheight = self.tileheight[cx][cy][i][o] or 0
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
        prevHeight = self.heightmap[prevCx][prevCy][prevI][prevO] or 0
        prevShadow = self.state.map.shadowmap[prevCx][prevCy][prevI][prevO] or 0
        prevTileheight = self.tileheight[prevCx][prevCy][prevI][prevO] or 0
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
                if self.heightmap[pcx][pcy][pi][po] and self.heightmap[pcx][pcy][pi][po] ~= elevationOffsetY then
                    tilesWithSlope = tilesWithSlope + 1
                end
            end
        end
        if tilesWithSlope > 5 then
            tileHasSlope = true
        end
        local hillTileBase, hillTileSunnySide, hillTileNormal
        local skipMultiTile = false
        local t = self.terrainTile[cx][cy][i][o]
        if not t or #t <= 0 then
            skipMultiTile = true
            t = { nil, _G.IsoX + (i - o) * tileWidth * 0.5, _G.IsoY + (i + o) * tileHeight * 0.5, 0, 1.06, 1.06 }
        end
        local isCliff = self:tileShouldBeCliff(gx, gy)
        if not self:tileShouldBeCliff(gx, gy, true) then
            if _G.shouldTileBeWalkable(gx, gy) and self.state.map:getWalkable(gx, gy) == 1 then
                self.state.map:setWalkable(gx, gy, 0)
            end
            local chevronLeftId = _G.getChevronVertexLeft(cx, cy, i, o)
            _G.freeChevronVertexLeft(chevronLeftId, cx, cy)
            -- instancemesh:setVertex(chevronLeftId)
            -- instancemesh:setVertex(chevronRightId)
        end
        local isIron = _G.objectFromClassAtGlobal(gx, gy, "Iron")
        local isStone = _G.objectFromClassAtGlobal(gx, gy, "Stone")
        local isTree = _G.objectFromClassAtGlobal(gx, gy, "PineTree")
        local isWater = _G.getWaterAt(gx, gy)
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
            if self.terrain[cx][cy][i][o] == _G.terrainBiome.scarceGrass then
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
            if isWater then
                hillTileNormal = "sea_deep_1x1 (" .. love.math.random(1, 8) .. ")"
            end

            hillTileNormal = tileQuads[hillTileNormal]
            hillTileSunnySide = tileQuads[hillTileSunnySide]

            hillChevronNormal = tileQuads[hillChevronNormal]
            hillChevronSunnySide = tileQuads[hillChevronSunnySide]

            cliffChevron = tileQuads["rock_cliff (" .. tostring(horizontalX % 31 + 1) .. ")"]
            if isIron then
                local hillChevronIron = "hill_chevron_14 (" .. normalRand + 4 .. ")"
                hillChevronIron = tileQuads[hillChevronIron]
                local x, y, w, h = hillChevronIron:getViewport()
                hillChevronIronLeft = love.graphics.newQuad(x, y, w, h, _G.objectAtlas)
                -- hillChevronIronRight = love.graphics.newQuad(x + w / 2, y, w / 2, h, _G.objectAtlas)
            else
                local x, y, w, h = hillChevronNormal:getViewport()
                hillChevronNormalLeft = love.graphics.newQuad(x, y, w, h, _G.objectAtlas)
                -- hillChevronNormalRight = love.graphics.newQuad(x + w / 2, y, w / 2, h, _G.objectAtlas)
                x, y, w, h = hillChevronSunnySide:getViewport()
                hillChevronSunnySideLeft = love.graphics.newQuad(x, y, w, h, _G.objectAtlas)
                -- hillChevronSunnySideRight = love.graphics.newQuad(x + w / 2, y, w / 2, h, _G.objectAtlas)
            end
        end
        local lightValue = 1
        if isInShadow then
            local maxShadow = math.min(0.9, 1 - shadowValue)
            if elevationOffsetY ~= 0 then
                local chevronLeftId = _G.getChevronVertexLeft(cx, cy, i, o)
                if isCliff then
                    local qx, qy, qw, qh = cliffChevron:getViewport()
                    instancemesh:setVertex(chevronLeftId, t[2], t[3] - elevationOffsetY * 2 + 8, inferZ(cx, cy, i, o, -1), qx, qy, qw, qh,
                        1 - shadowValue, lScale)
                    -- instancemesh:setVertex(chevronRightId)
                elseif isIron then
                    local qx, qy, qw, qh = hillChevronIronLeft:getViewport()
                    instancemesh:setVertex(chevronLeftId, t[2], t[3] - elevationOffsetY * 2 + 8, inferZ(cx, cy, i, o, -1), qx, qy, qw, qh,
                        1 - shadowValue - 0.01, lScale)
                    -- qx, qy, qw, qh = hillChevronIronRight:getViewport()
                    -- instancemesh:setVertex(chevronRightId, t[2] + qw, t[3] - elevationOffsetY * 2 + 8, inferZ(cx, cy, i, o, elevationOffsetY - 1), qx, qy, qw, qh,
                    --     1 - shadowValue - 0.12, lScale)
                else
                    local qx, qy, qw, qh = hillChevronNormalLeft:getViewport()
                    instancemesh:setVertex(chevronLeftId, t[2], t[3] - elevationOffsetY * 2, inferZ(cx, cy, i, o, -1), qx, qy, qw, qh,
                        1 - shadowValue - 0.01, lScale)
                    -- qx, qy, qw, qh = hillChevronNormalRight:getViewport()
                    -- instancemesh:setVertex(chevronRightId, t[2] + qw, t[3] - elevationOffsetY * 2 + 8, inferZ(cx, cy, i, o, elevationOffsetY - 1), qx, qy, qw, qh,
                    --     1 - shadowValue - 0.12, lScale)
                end
                local qx, qy, qw, qh = hillTileNormal:getViewport()
                local vertId = _G.getTerrainVertex(cx, cy, i, o)
                instancemesh:setVertex(vertId, t[2], t[3] - elevationOffsetY * 2, inferZ(cx, cy, i, o, 0), qx, qy, qw, qh, 1 - shadowValue,
                    lScale)
                tileOverriden = true
            end
            lightValue = maxShadow
        else
            local lightModifier = elevationOffsetY / 50
            if lightModifier > 0 and tileHasSlope and elevationOffsetY ~= 0 then
                lightValue = 0.9 + math.min(lightModifier, 0.1)
                local chevronLeftId = _G.getChevronVertexLeft(cx, cy, i, o)
                if isCliff then
                    local qx, qy, qw, qh = cliffChevron:getViewport()
                    instancemesh:setVertex(chevronLeftId, t[2], t[3] - elevationOffsetY * 2 + 8, inferZ(cx, cy, i, o, -1), qx, qy, qw, qh,
                        0.9 + math.min(lightModifier, 0.1), lScale)
                    -- instancemesh:setVertex(chevronRightId)
                elseif isIron then
                    local qx, qy, qw, qh = hillChevronIronLeft:getViewport()
                    instancemesh:setVertex(chevronLeftId, t[2], t[3] - elevationOffsetY * 2 + 8, inferZ(cx, cy, i, o, -1), qx, qy, qw, qh,
                        0.9 + math.min(lightModifier, 0.1) - 0.01, lScale)
                    -- qx, qy, qw, qh = hillChevronIronRight:getViewport()
                    -- instancemesh:setVertex(chevronRightId, t[2] + qw, t[3] - elevationOffsetY * 2 + 8, inferZ(cx, cy, i, o, elevationOffsetY - 1), qx, qy, qw, qh,
                    --     0.9 + math.min(lightModifier, 0.1) - 0.08, lScale)
                else
                    local qx, qy, qw, qh = hillChevronSunnySideLeft:getViewport()
                    instancemesh:setVertex(chevronLeftId, t[2], t[3] - elevationOffsetY * 2, inferZ(cx, cy, i, o, -1), qx, qy, qw, qh,
                        0.9 + math.min(lightModifier, 0.1) - 0.01, lScale)
                    -- qx, qy, qw, qh = hillChevronSunnySideRight:getViewport()
                    -- instancemesh:setVertex(chevronRightId, t[2] + qw, t[3] - elevationOffsetY * 2 + 8, inferZ(cx, cy, i, o, elevationOffsetY - 1), qx, qy, qw, qh,
                    --     0.9 + math.min(lightModifier, 0.1) - 0.08, lScale)
                end
                local qx, qy, qw, qh = hillTileSunnySide:getViewport()
                local vertId = _G.getTerrainVertex(cx, cy, i, o)
                instancemesh:setVertex(vertId, t[2], t[3] - elevationOffsetY * 2, inferZ(cx, cy, i, o, 0), qx, qy, qw, qh,
                    0.9 + math.min(lightModifier, 0.1), lScale)
                tileOverriden = true
            elseif elevationOffsetY ~= 0 then
                local chevronLeftId = _G.getChevronVertexLeft(cx, cy, i, o)
                lightValue = 1
                if isCliff then
                    local qx, qy, qw, qh = cliffChevron:getViewport()
                    instancemesh:setVertex(chevronLeftId, t[2], t[3] - elevationOffsetY * 2 + 8, inferZ(cx, cy, i, o, -1), qx, qy, qw, qh, 1,
                        lScale)
                    -- instancemesh:setVertex(chevronRightId)
                elseif isIron then
                    local qx, qy, qw, qh = hillChevronIronLeft:getViewport()
                    instancemesh:setVertex(chevronLeftId, t[2], t[3] - elevationOffsetY * 2 + 8, inferZ(cx, cy, i, o, -1), qx, qy, qw, qh, 1 - 0.03
                    , lScale)
                    -- qx, qy, qw, qh = hillChevronIronRight:getViewport()
                    -- instancemesh:setVertex(chevronRightId, t[2] + qw, t[3] - elevationOffsetY * 2 + 8, inferZ(cx, cy, i, o, elevationOffsetY - 1), qx, qy, qw, qh,
                    --     1 - 0.1, lScale)
                else
                    local qx, qy, qw, qh = hillChevronNormalLeft:getViewport()
                    instancemesh:setVertex(chevronLeftId, t[2], t[3] - elevationOffsetY * 2, inferZ(cx, cy, i, o, -1), qx, qy, qw, qh, 1 - 0.03
                    , lScale)
                    -- qx, qy, qw, qh = hillChevronNormalRight:getViewport()
                    -- instancemesh:setVertex(chevronRightId, t[2] + qw, t[3] - elevationOffsetY * 2 + 8, inferZ(cx, cy, i, o, elevationOffsetY - 1), qx, qy, qw, qh,
                    --     1 - 0.1, lScale)
                end
                local qx, qy, qw, qh = hillTileNormal:getViewport()
                local vertId = _G.getTerrainVertex(cx, cy, i, o)
                instancemesh:setVertex(vertId, t[2], t[3] - elevationOffsetY * 2, inferZ(cx, cy, i, o, 0), qx, qy, qw, qh, 1, lScale)
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
            local vertId = _G.getTerrainVertex(cx, cy, i, o)
            instancemesh:setVertex(vertId, t[2], t[3] - elevationOffsetY * 2, inferZ(cx, cy, i, o, elevationOffsetY), qx, qy, qw, qh, lightValue, lScale)
        end
    elseif self.terrain[cx][cy][i][o] == _G.terrainBiome.none then
        local vertId = _G.getTerrainVertex(cx, cy, i, o)
        _G.freeTerrainVertex(vertId, cx, cy)
        local chevronLeftId = _G.getChevronVertexLeft(cx, cy, i, o)
        _G.freeChevronVertexLeft(chevronLeftId, cx, cy)
        -- instancemesh:setVertex(chevronRightId)
    end
end

--- Refreshes the terrain in order to achieve the perfect render.
--- Also referred as to the third pass of terrain updates.
---@param chunkX integer Chunk X
---@param chunkY integer Chunk Y
function Terrain:refreshTerrain(chunkX, chunkY)
    local cx = chunkX or _G.currentChunkX
    local cy = chunkY or _G.currentChunkY
    if (not _G.isGlobalCoordInsideMap(cx, cy)) then
        print((debug.traceback("Error: trying to refreshTerrain outside map", 1):gsub("\n[^\n]+$", "")))
        return
    end

    self.tilesToUpdateInChunk[cx][cy] = nil
    for i = 0, chunkWidth - 1, 1 do
        for o = 0, chunkWidth - 1, 1 do
            self:refreshTile(cx, cy, o, i)
        end
    end
    self.tertiaryTilesToUpdateInChunk[cx][cy] = nil
end

--- Returns the structure's Y offset.
---@return number offsetY of the structure
local function getStructureOffset(gx, gy)
    local structureOffset = 0
    if not _G.BuildController.active or _G.DestructionController.active then
        local structure = _G.objectFromSubclassAtGlobal(gx, gy, "Structure")
        if structure then
            structure = structure.parent or structure
            structureOffset = structure.offsetY or 0
        end
    end
    return structureOffset
end

--- Returns the tile from mouse position.
--- Handles elevation calculation.
---@param mx integer Mouse X
---@param my integer Mouse Y
---@param ignoreElevation? boolean Whether to get the tile a 0 ground level
---@return integer gx, integer gy
function Terrain:getTerrainTileOnMouse(mx, my, ignoreElevation, ignoreStructureOffset)
    local MX, MY, rMX, rMY
    rMX = (mx - _G.ScreenWidth / 2) / self.state.scaleX + self.state.viewXview - 16
    rMY = (my - _G.ScreenHeight / 2) / self.state.scaleX + self.state.viewYview
    local maxTiles = 30
    local offsetY
    local LocalX = math.round(ScreenToIsoX(rMX, rMY))
    local LocalY = math.round(ScreenToIsoY(rMX, rMY))
    if ignoreElevation then return LocalX, LocalY end
    local lastValidGx, lastValidGy = LocalX, LocalY
    for tilesIterated = 0, maxTiles do
        offsetY = tilesIterated * 8
        MX = (mx - _G.ScreenWidth / 2) / self.state.scaleX + self.state.viewXview - 16
        MY = (my + offsetY * self.state.scaleX - _G.ScreenHeight / 2) / self.state.scaleX + self.state.viewYview - 8
        LocalX = math.round(ScreenToIsoX(MX, MY))
        LocalY = math.round(ScreenToIsoY(MX, MY))
        local gx = LocalX
        local gy = LocalY
        local cx, cy, i, o = _G.getLocalCoordinatesFromGlobal(LocalX, LocalY)
        local elevationOffsetY = (self.heightmap[cx][cy][i][o] or 0) * 2
        local t = self.terrainTile[cx][cy][i][o]
        local cyOffset = (cx + cy) * chunkHeight * tileHeight * 0.5
        local tileIsoY = t and #t >= 3 and t[3] or _G.IsoY + (i + o) * tileHeight * 0.5
        local structureOffset = getStructureOffset(gx, gy)
        if ignoreStructureOffset then ignoreStructureOffset = 0 end
        local recty = tileIsoY - elevationOffsetY + cyOffset + structureOffset
        if rMY >= recty then
            lastValidGx, lastValidGy = gx, gy
        end
    end
    return lastValidGx, lastValidGy
end

function Terrain:update()
    for _, chunk in ipairs(chunksToUpdate) do
        self:updateTerrain(chunk[1], chunk[2])
        self:refreshTerrain(chunk[1], chunk[2])
        self.chunksSet[chunk[1]][chunk[2]] = nil
    end
    chunksToUpdate = {}
end

function Terrain:genTerrain(cx, cy)
    -- _G.allocateMesh(cx, cy)
    self.terrain[cx][cy] = newAutotable(2)
    for i = 0, chunkWidth - 1, 1 do
        for o = 0, chunkHeight - 1, 1 do
            self.terrain[cx][cy][i][o] = _G.terrainBiome.abundantGrass
            self:scheduleTerrainUpdate(cx, cy, i, o)
        end
    end
end

function Terrain:terrainSetTileAt(gx, gy, biome, from, force)
    local cx, cy, i, o = _G.getLocalCoordinatesFromGlobal(gx, gy)
    if self.state.map.terrain[cx] and self.state.map.terrain[cx][cy] then
        if from then
            if self.state.map.terrain[cx][cy][i][o] == from then
                self.state.map.terrain[cx][cy][i][o] = biome
                self:scheduleTerrainUpdate(cx, cy, i, o)
            end
        else
            if force or self.state.map.terrain[cx][cy][i][o] ~= _G.terrainBiome.none then
                self.state.map.terrain[cx][cy][i][o] = biome
                self:scheduleTerrainUpdate(cx, cy, i, o)
                local vertId = _G.getTerrainVertex(cx, cy, i, o)
                _G.state.objectMesh[cx][cy]:setVertex(vertId)
            end
        end
    end
end

function Terrain:getTerrainBiomeAt(gx, gy)
    local cx, cy, i, o = _G.getLocalCoordinatesFromGlobal(gx, gy)
    if self.state.map.terrain[cx] and self.state.map.terrain[cx][cy] then
        return self.state.map.terrain[cx][cy][i][o]
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

function Terrain:genMap()
    genForest()
    _G.stoneGen = {}
    local _ = genStone()
    _G.ironGen = {}
    local _ = genIron()
    for i = 0, _G.chunksWide - 1 do
        for o = 0, _G.chunksHigh - 1 do -- usually both are 32 (jumper is set like that with magic numbers)
            self:genTerrain(i, o)
        end
    end
end

return Terrain
