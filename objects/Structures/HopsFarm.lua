local tileQuads = require("objects.object_quads")
local Structure = require("objects.Structure")
local Object = require("objects.Object")
local NotEnoughWorkersFloat = require("objects.Structures.NotEnoughWorkersFloat")

local tiles, quadArray = _G.indexBuildingQuads("farm (2)")
local farmlandTilesStage0 = { tileQuads["tile_farmland_hops_1 (1)"], tileQuads["tile_farmland_hops_2 (1)"] }
local farmlandTilesStage1 = { tileQuads["tile_farmland_hops_1 (2)"], tileQuads["tile_farmland_hops_2 (2)"] }
local farmlandTilesStage2 = { tileQuads["tile_farmland_hops_1 (3)"], tileQuads["tile_farmland_hops_2 (3)"] }
local farmlandTilesStage3 = { tileQuads["tile_farmland_hops_1 (4)"], tileQuads["tile_farmland_hops_2 (4)"] }
local farmlandTilesStage4 = { tileQuads["tile_farmland_hops_1 (5)"], tileQuads["tile_farmland_hops_2 (5)"] }
local farmlandTilesStage5 = { tileQuads["tile_farmland_hops_1 (6)"], tileQuads["tile_farmland_hops_2 (6)"] }
local farmlandTilesStage6 = { tileQuads["tile_farmland_hops_1 (7)"], tileQuads["tile_farmland_hops_2 (7)"] }
local farmlandTilesStage7 = { tileQuads["tile_farmland_hops_1 (8)"], tileQuads["tile_farmland_hops_2 (8)"] }

local HopsFarmAlias = _G.class("HopsFarmAlias", Structure)
function HopsFarmAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
    local mytype = "Static structure"
    self.parent = parent
    Structure.initialize(self, gx, gy, mytype)
    self.tile = tile
    self.baseOffsetY = offsetY or 0
    self.additionalOffsetY = 0
    self.offsetX = offsetX or 0
    self.offsetY = self.additionalOffsetY - self.baseOffsetY
    Structure.render(self)
end

function HopsFarmAlias:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.parent = _G.state:serializeObject(self.parent)
    data.tileKey = self.tileKey
    data.baseOffsetY = self.baseOffsetY
    data.additionalOffsetY = self.additionalOffsetY
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    return data
end

function HopsFarmAlias.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    if data.tileKey then
        obj.tile = quadArray[data.tileKey]
        obj.tileKey = data.tileKey
        obj:render()
    end
    obj.parent = _G.state:dereferenceObject(data.parent)
    return obj
end

local HopsFarmPlant = _G.class("HopsFarmPlant", Structure)
function HopsFarmPlant:initialize(gx, gy, parent, isPlant)
    local mytype = "Hops Plant"
    self.parent = parent
    Structure.initialize(self, gx, gy, mytype)
    self.animated = false
    self.state = -1
    self.hasHopsResource = false
    self.isPlant = false
    if isPlant then
        self.isPlant = true
        parent.availablePlantTiles = parent.availablePlantTiles + 1
    end
    self.offsetX = 0
    self.offsetY = 0
    self.tile = tileQuads["empty"]
    self.tileKey = "empty"
    self.hopsMatureCounter = 0
    self.startedGrowing = false
    self:registerAsActiveEntity()
end

function HopsFarmPlant:reset()
    self.state = -1
    self.hasHopsResource = false
    self.tile = tileQuads["empty"]
    self.tileKey = "empty"
    self:render()
end

function HopsFarmPlant:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.animated = self.animated
    data.isPlant = self.isPlant
    data.state = self.state
    data.tileKey = self.tileKey
    data.hasHopsResource = self.hasHopsResource
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    data.hopsMatureCounter = self.hopsMatureCounter
    data.startedGrowing = self.startedGrowing
    return data
end

function HopsFarmPlant.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    if data.tileKey then
        obj.tile = tileQuads[data.tileKey]
        obj.tileKey = data.tileKey
        obj:render()
    end

    return obj
end

function HopsFarmPlant:render()
    local elevationOffsetY = _G.state.map.heightmap[self.cx][self.cy][self.i][self.o] or 0
    local shadowValue = _G.state.map.shadowmap[self.cx][self.cy][self.i][self.o] or 0
    local isInShadow = shadowValue > elevationOffsetY
    if isInShadow then
        shadowValue = math.min((shadowValue - elevationOffsetY) / 40, 0.6) / 1.25
    else
        shadowValue = 0
    end
    self.shadowValue = 1 - shadowValue / 1.5
    Structure.render(self)
end

function HopsFarmPlant:animate(dt)
    self:update(dt)
end

function HopsFarmPlant:update(dt)
    dt = dt or _G.dt
    if self.state > 0 and self.state < 7 and ((self.parent.tilesSowed >= self.parent.availablePlantTiles) or self.parent.state == 2) and
        (_G.state.hopsGrowingSeason or self.startedGrowing) then
        self.startedGrowing = true
        self.hopsMatureCounter = self.hopsMatureCounter + dt
        if self.hopsMatureCounter > 9 then
            self.state = self.state + 1
            self:setState()
            if self.state == 7 then
                self.parent.tilesFullyGrown = self.parent.tilesFullyGrown + 1
            end
            self.hopsMatureCounter = 0
        end
    end
end

function HopsFarmPlant:takeResource()
    if self.hasHopsResource then
        self:setState(0)
        self.hasHopsResource = false
        return true
    end
    return false
end

function HopsFarmPlant:setState(state)
    state = state or self.state
    local randomTile = love.math.random(1, 2)
    self.state = state
    if not self.isPlant then
        return
    elseif state == 0 then
        self.tile = farmlandTilesStage0[randomTile]
        self.tileKey = string.format("tile_farmland_hops_%d (1)", randomTile)
    elseif state == 1 then
        self.tile = farmlandTilesStage1[randomTile]
        self.tileKey = string.format("tile_farmland_hops_%d (2)", randomTile)
    elseif state == 2 then
        self.tile = farmlandTilesStage2[randomTile]
        self.tileKey = string.format("tile_farmland_hops_%d (3)", randomTile)
    elseif state == 3 then
        self.tile = farmlandTilesStage3[randomTile]
        self.tileKey = string.format("tile_farmland_hops_%d (4)", randomTile)
    elseif state == 4 then
        self.tile = farmlandTilesStage4[randomTile]
        self.tileKey = string.format("tile_farmland_hops_%d (5)", randomTile)
    elseif state == 5 then
        self.tile = farmlandTilesStage5[randomTile]
        self.tileKey = string.format("tile_farmland_hops_%d (6)", randomTile)
    elseif state == 6 then
        self.tile = farmlandTilesStage6[randomTile]
        self.tileKey = string.format("tile_farmland_hops_%d (7)", randomTile)
    elseif state == 7 then
        if self.isPlant then
            self.tile = farmlandTilesStage7[randomTile]
            self.tileKey = string.format("tile_farmland_hops_%d (8)", randomTile)
        else
            self.tile = tileQuads["empty"]
            self.tileKey = "empty"
        end
    end
    local _, _, _, wh = self.tile:getViewport()
    self.offsetY = -(wh - 16)
    self:render()
end

local HopsFarm = _G.class("HopsFarm", Structure)

HopsFarm.static.WIDTH = 3
HopsFarm.static.LENGTH = 3
HopsFarm.static.HEIGHT = 14
HopsFarm.static.ALIAS_NAME = "HopsFarmAlias"
HopsFarm.static.DESTRUCTIBLE = true

function HopsFarm:initialize(gx, gy, type)
    _G.JobController:add("HopsFarmer", self)
    type = type or "Static structure"
    Structure.initialize(self, gx, gy, type)
    self.health = 400
    self.tile = quadArray[tiles + 1]
    self.offsetX = 0
    self.offsetY = -64 - 6 - 8

    self.state = 0

    for xx = -1, 12 do
        for yy = -1, 12 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrainBiome.scarceGrass)
        end
    end

    for xx = 0, 2 do
        for yy = 0, 2 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrainBiome.none)
        end
    end

    for tile = 1, tiles do
        local whf = HopsFarmAlias:new(quadArray[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offsetY + 8 * (tiles - tile + 1))
        whf.tileKey = tile
    end

    for tile = 1, tiles do
        local whf = HopsFarmAlias:new(quadArray[tiles + 1 + tile], self.gx + tile, self.gy, self,
            -self.offsetY + 8 * tile, 14)
        whf.tileKey = tiles + 1 + tile
    end
    self.availablePlantTiles = 0
    self.landTiles = {}
    local t1, t2
    local everySecond = true
    for y = 4, 11 do
        everySecond = not everySecond
        if everySecond then
            t1 = HopsFarmPlant:new(self.gx + 0, self.gy + y, self, true)
            t2 = HopsFarmPlant:new(self.gx + 1, self.gy + y, self, false)
        else
            t1 = HopsFarmPlant:new(self.gx + 0, self.gy + y, self, false)
            t2 = HopsFarmPlant:new(self.gx + 1, self.gy + y, self, false)
        end
        table.insert(self.landTiles, { t1, t2 })
    end

    everySecond = false
    for y = 11, 0, -1 do
        t1 = false
        everySecond = not everySecond
        if everySecond then
            if y > 3 then
                t1 = HopsFarmPlant:new(self.gx + 2, self.gy + y, self, true)
            end
            t2 = HopsFarmPlant:new(self.gx + 3, self.gy + y, self, false)
        else
            if y > 3 then
                t1 = HopsFarmPlant:new(self.gx + 2, self.gy + y, self, false)
            end
            t2 = HopsFarmPlant:new(self.gx + 3, self.gy + y, self, false)
        end
        table.insert(self.landTiles, { t1, t2 })
    end

    everySecond = true
    for y = 0, 11 do
        everySecond = not everySecond
        if everySecond then
            t1 = HopsFarmPlant:new(self.gx + 4, self.gy + y, self, true)
            t2 = HopsFarmPlant:new(self.gx + 5, self.gy + y, self, false)
        else
            t1 = HopsFarmPlant:new(self.gx + 4, self.gy + y, self, false)
            t2 = HopsFarmPlant:new(self.gx + 5, self.gy + y, self, false)
        end
        table.insert(self.landTiles, { t1, t2 })
    end

    everySecond = false
    for y = 11, 0, -1 do
        everySecond = not everySecond
        if everySecond then
            t1 = HopsFarmPlant:new(self.gx + 6, self.gy + y, self, true)
            t2 = HopsFarmPlant:new(self.gx + 7, self.gy + y, self, false)
        else
            t1 = HopsFarmPlant:new(self.gx + 6, self.gy + y, self, false)
            t2 = HopsFarmPlant:new(self.gx + 7, self.gy + y, self, false)
        end
        table.insert(self.landTiles, { t1, t2 })
    end

    everySecond = true
    for y = 0, 11 do
        everySecond = not everySecond
        if everySecond then
            t1 = HopsFarmPlant:new(self.gx + 8, self.gy + y, self, true)
            t2 = HopsFarmPlant:new(self.gx + 9, self.gy + y, self, false)
        else
            t1 = HopsFarmPlant:new(self.gx + 8, self.gy + y, self, false)
            t2 = HopsFarmPlant:new(self.gx + 9, self.gy + y, self, false)
        end
        table.insert(self.landTiles, { t1, t2 })
    end

    everySecond = false
    for y = 11, 0, -1 do
        everySecond = not everySecond
        if everySecond then
            t1 = HopsFarmPlant:new(self.gx + 10, self.gy + y, self, true)
            t2 = HopsFarmPlant:new(self.gx + 11, self.gy + y, self, false)
        else
            t1 = HopsFarmPlant:new(self.gx + 10, self.gy + y, self, false)
            t2 = HopsFarmPlant:new(self.gx + 11, self.gy + y, self, false)
        end
        table.insert(self.landTiles, { t1, t2 })
    end

    self:applyBuildingHeightMap()

    self.tilesSowed = 0
    self.tilesFullyGrown = 0
    self.maxLandTiles = #self.landTiles
    self.processedTiles = 0

    for xx = 1, 2 do
        for yy = 1, 2 do
            HopsFarmAlias:new(tileQuads["empty"], self.gx + xx, self.gy + yy, self, self.offsetX, self.offsetY)
        end
    end

    self.freeSpots = 1
    Structure.render(self)

    self.float = NotEnoughWorkersFloat:new(self.gx + self.class.WIDTH - 1, self.gy + self.class.LENGTH - 1, 4, -120)
end

function HopsFarm:destroy()
    self.float:destroy()

    for xx = -1, 13 do
        for yy = -1, 13 do
            local tile = _G.objectFromClassAtGlobal(self.gx + xx, self.gy + yy, "HopsFarmPlant")
            if type(tile) ~= "boolean" then
                tile.state = -1
                Structure.destroy(tile)
                tile.toBeDeleted = true
            end
        end
    end

    _G.JobController:remove("HopsFarmer", self)

    Structure.destroy(self)
    if self.hopsWorker then
        self.hopsWorker:quitJob()
    end
end

function HopsFarm:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    self.tile = quadArray[tiles + 1]
    self.landTiles = {}
    for idx, ltiles in ipairs(data.landTilesRaw) do
        self.landTiles[idx] = {}
        for _, stile in ipairs(ltiles) do
            if stile == false then
                self.landTiles[idx][#self.landTiles[idx] + 1] = false
            else
                local farmTile = _G.state:dereferenceObject(stile)
                self.landTiles[idx][#self.landTiles[idx] + 1] = farmTile
                farmTile.parent = self
            end
        end
    end
    if data.hopsWorker then
        self.hopsWorker = _G.state:dereferenceObject(data.hopsWorker)
        self.hopsWorker.workplace = self
    end
    Structure.render(self)
end

function HopsFarm:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.availablePlantTiles = self.availablePlantTiles
    data.health = self.health
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    data.maxLandTiles = self.maxLandTiles
    data.processedTiles = self.processedTiles
    data.tilesSowed = self.tilesSowed
    data.tilesFullyGrown = self.tilesFullyGrown
    data.freeSpots = self.freeSpots
    data.state = self.state
    if self.hopsWorker then
        data.hopsWorker = _G.state:serializeObject(self.hopsWorker)
    end
    local landTiles = {}
    for idx, ltiles in ipairs(self.landTiles) do
        landTiles[idx] = {}
        for _, stile in ipairs(ltiles) do
            if stile then
                local farmTile = _G.state:serializeObject(stile)
                landTiles[idx][#landTiles[idx] + 1] = farmTile
            else
                landTiles[idx][#landTiles[idx] + 1] = false
            end
        end
    end
    data.landTilesRaw = landTiles
    return data
end

function HopsFarm.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

function HopsFarm:leave()
    if self.hopsWorker then
        _G.JobController:add("HopsFarmer", self)
        self:reset()
        self.hopsWorker:leaveVillage()
        self.hopsWorker = nil
        self.freeSpots = 1
        self.float:activate()
        return true
    end
end

function HopsFarm:join(worker)
    if self.health == -1 then
        _G.JobController:remove("HopsFarmer", self)
        worker:die()
        return
    end
    if self.freeSpots == 1 then
        self.hopsWorker = worker
        worker.workplace = self
        self.freeSpots = self.freeSpots - 1
    end
    if self.freeSpots == 0 then
        self.float:deactivate()
    end
end

function HopsFarm:updateTiles(farmlandTiles)
    for _, tile in ipairs(farmlandTiles) do
        if tile then
            if tile.state == -1 then
                tile:setState(0)
            elseif tile.state == 0 then
                tile:setState(1)
                if tile.isPlant then
                    self.tilesSowed = self.tilesSowed + 1
                end
            elseif tile.state == 7 then
                if tile.isPlant then
                    tile:setState(7)
                else
                    tile:setState(0)
                end
            end
        end
    end
end

function HopsFarm:reset()
    self.tilesSowed = 0
    self.tilesFullyGrown = 0
    self.processedTiles = 0
    self.state = 0
    for _, tilePair in ipairs(self.landTiles) do
        for _, tile in ipairs(tilePair) do
            if tile and tile.isPlant then
                tile:reset()
            end
        end
    end
end

function HopsFarm:fillResourceTiles()
    for _, tilePair in ipairs(self.landTiles) do
        for _, tile in ipairs(tilePair) do
            if tile and tile.isPlant then
                tile.hasHopsResource = true
            end
        end
    end
end

function HopsFarm:getNextResourceTile()
    for _, tilePair in ipairs(self.landTiles) do
        for _, tile in ipairs(tilePair) do
            if tile and tile.hasHopsResource then
                return tile
            end
        end
    end
    return false
end

function HopsFarm:work(worker)
    if self.hopsWorker == worker then
        if self.hopsWorker.state ~= "Resting" then
            self.hopsWorker.state = "Working"
        end
        if self.state == 0 then
            self.processedTiles = self.processedTiles + 1
            local currentTile = self.landTiles[self.processedTiles][2]
            if not currentTile then
                currentTile = self.landTiles[self.processedTiles][1]
            end
            if self.hopsWorker:isPositionAt(currentTile.gx, currentTile.gy - 2) then
                self.hopsWorker.state = "Hoe walking to southern tile"
            elseif self.hopsWorker:isPositionAt(currentTile.gx, currentTile.gy + 2) then
                self.hopsWorker.state = "Hoe walking to northern tile"
            elseif self.hopsWorker:isPositionAt(currentTile.gx - 1, currentTile.gy + 2) then
                self.hopsWorker.state = "Hoe walking to northeastern tile"
                self.hopsWorker.currentTile = currentTile
            elseif self.hopsWorker:isPositionAt(currentTile.gx - 1, currentTile.gy + 1) then
                self.hopsWorker.state = "Hoe walking to northeastern tile"
                self.hopsWorker.currentTile = currentTile
            elseif self.hopsWorker:isPositionAt(currentTile.gx - 2, currentTile.gy + 1) then
                self.hopsWorker.state = "Hoe walking to northeastern tile"
                self.hopsWorker.currentTile = currentTile
            elseif self.hopsWorker:isPositionAt(currentTile.gx - 2, currentTile.gy - 1) then
                self.hopsWorker.state = "Hoe walking to southeastern tile"
            else
                self.hopsWorker:requestPath(currentTile.gx, currentTile.gy - 1)
                self.hopsWorker.state = "Going to hoe the land from north"
                self.hopsWorker.moveDir = "none"
            end
            self.hopsWorker.farmlandTiles = self.landTiles[self.processedTiles]
            if self.processedTiles == self.maxLandTiles then
                self.state = 1
                self.processedTiles = 0
            end
        elseif self.state == 1 then
            if self.processedTiles == self.maxLandTiles then
                self.state = 2
                self.processedTiles = 0
                self:fillResourceTiles()
                self.hopsWorker.state = "Go to rest"
                return
            end
            self.processedTiles = self.processedTiles + 1
            local currentTile = self.landTiles[self.processedTiles][2]
            if self.hopsWorker:isPositionAt(currentTile.gx, currentTile.gy - 2) then
                self.hopsWorker.state = "Seed walking to southern tile"
            elseif self.hopsWorker:isPositionAt(currentTile.gx, currentTile.gy + 2) then
                self.hopsWorker.state = "Seed walking to northern tile"
            elseif self.hopsWorker:isPositionAt(currentTile.gx - 1, currentTile.gy + 2) then
                self.hopsWorker.state = "Seed walking to northeastern tile"
                self.hopsWorker.currentTile = currentTile
            elseif self.hopsWorker:isPositionAt(currentTile.gx - 1, currentTile.gy + 1) then
                self.hopsWorker.state = "Seed walking to northeastern tile"
                self.hopsWorker.currentTile = currentTile
            elseif self.hopsWorker:isPositionAt(currentTile.gx - 2, currentTile.gy + 1) then
                self.hopsWorker.state = "Seed walking to northeastern tile"
                self.hopsWorker.currentTile = currentTile
            elseif self.hopsWorker:isPositionAt(currentTile.gx - 2, currentTile.gy - 1) then
                self.hopsWorker.state = "Seed walking to southeastern tile"
            else
                self.hopsWorker:requestPath(currentTile.gx, currentTile.gy - 1)
                self.hopsWorker.state = "Going to seed the land from north"
                self.hopsWorker.moveDir = "none"
            end
            self.hopsWorker.farmlandTiles = self.landTiles[self.processedTiles]
        elseif self.state == 2 then
            -- on each rest cycle, check if plants are ready
            if self.tilesFullyGrown >= self.availablePlantTiles then
                self.state = 3
                self.processedTiles = 0
            end
        elseif self.state == 3 then
            local resourceTile = self:getNextResourceTile()
            if resourceTile then
                self.hopsWorker.resourceTile = resourceTile
                self.hopsWorker.state = "Going to pick up hops"
                self.hopsWorker:clearPath()
                self.hopsWorker:requestPath(resourceTile.gx, resourceTile.gy)
            else
                if self.hopsWorker.hops > 0 then
                    self.hopsWorker.state = "Go to stockpile"
                    self.hopsWorker:clearPath()
                else
                    self.tilesFullyGrown = 0
                    self.tilesSowed = 0
                    self.state = 1
                    self.processedTiles = 0
                    self:work(self.hopsWorker)
                end
            end
        end
    end
end

function HopsFarm:sendToStockpile()
    self.hopsWorker.state = "Go to foodpile"
    self.hopsWorker.moveDir = "none"
end

return HopsFarm
