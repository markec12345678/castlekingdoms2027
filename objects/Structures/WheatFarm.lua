local _, tileQuads, _, activeEntities = ...
local Structure = require("objects.Structure")
local Object = require("objects.Object")
local NotEnoughWorkersFloat = require("objects.Structures.NotEnoughWorkersFloat")

local tiles, quadArray = _G.indexBuildingQuads("farm (2)")
local farmlandTilesStage0 = {tileQuads["tile_farmland_stage_0 (1)"], tileQuads["tile_farmland_stage_0 (2)"],
    tileQuads["tile_farmland_stage_0 (3)"], tileQuads["tile_farmland_stage_0 (4)"]}
local farmlandTilesStage1 = {tileQuads["tile_farmland_stage_1 (1)"], tileQuads["tile_farmland_stage_1 (2)"],
    tileQuads["tile_farmland_stage_1 (3)"], tileQuads["tile_farmland_stage_1 (4)"]}
local farmlandTilesStage2 = {tileQuads["tile_farmland_stage_2 (1)"], tileQuads["tile_farmland_stage_2 (2)"],
    tileQuads["tile_farmland_stage_2 (3)"], tileQuads["tile_farmland_stage_2 (4)"]}
local farmlandTilesStage3 = {tileQuads["tile_farmland_stage_3 (1)"], tileQuads["tile_farmland_stage_3 (2)"],
    tileQuads["tile_farmland_stage_3 (3)"], tileQuads["tile_farmland_stage_3 (4)"]}
local farmlandTilesStage4 = {tileQuads["tile_farmland_stage_4 (1)"], tileQuads["tile_farmland_stage_4 (2)"],
    tileQuads["tile_farmland_stage_4 (3)"], tileQuads["tile_farmland_stage_4 (4)"]}
local farmlandHayTile = tileQuads["tile_farmland_hay (1)"]
local WheatFarmAlias = _G.class("WheatFarmAlias", Structure)
function WheatFarmAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
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

function WheatFarmAlias:serialize()
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

function WheatFarmAlias.static:deserialize(data)
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

local WheatFarmPlant = _G.class("WheatFarmPlant", Structure)
function WheatFarmPlant:initialize(gx, gy, parent)
    local mytype = "Wheat Plant"
    self.parent = parent
    Structure.initialize(self, gx, gy, mytype)
    self.animated = false
    self.isPlant = false
    self.state = -1
    self.hasWheatResource = false
    parent.availablePlantTiles = parent.availablePlantTiles + 1
    if parent.availablePlantTiles % 8 == 0 then
        self.isPlant = true
    end
    self.offsetX = 0
    self.offsetY = 0
    self.tile = tileQuads["empty"]
    self.tileKey = "empty"
    self.wheatMatureCounter = 0
    self.startedGrowing = false
    table.insert(activeEntities, self)
end

function WheatFarmPlant:serialize()
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
    data.hasWheatResource = self.hasWheatResource
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    data.wheatMatureCounter = self.wheatMatureCounter
    data.startedGrowing = self.startedGrowing
    return data
end

function WheatFarmPlant.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    if data.tileKey then
        obj.tile = tileQuads[data.tileKey]
        obj.tileKey = data.tileKey
        obj:render()
    end
    table.insert(activeEntities, obj)
    return obj
end

function WheatFarmPlant:render()
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

function WheatFarmPlant:animate(dt)
    self:update(dt)
end

function WheatFarmPlant:update(dt)
    dt = dt or _G.dt
    if self.state > 0 and self.state < 4 and self.parent.tilesSowed == self.parent.availablePlantTiles and
        (_G.state.wheatGrowingSeason or self.startedGrowing) then
        self.startedGrowing = true
        self.wheatMatureCounter = self.wheatMatureCounter + dt
        if self.wheatMatureCounter > 3 then
            self.state = self.state + 1
            self:setState()
            if self.state == 4 then
                self.parent.tilesFullyGrown = self.parent.tilesFullyGrown + 1
            end
            self.wheatMatureCounter = 0
        end
    end
end

function WheatFarmPlant:takeResource()
    if self.hasWheatResource then
        self:setState(0)
        self.hasWheatResource = false
        return true
    end
    return false
end

function WheatFarmPlant:setState(state)
    state = state or self.state
    local randomTile = love.math.random(1, 4)
    self.state = state
    if state == 0 then
        self.tile = farmlandTilesStage0[randomTile]
        self.tileKey = "tile_farmland_stage_0 (" .. tostring(randomTile) .. ")"
    elseif state == 1 then
        self.tile = farmlandTilesStage1[randomTile]
        self.tileKey = "tile_farmland_stage_1 (" .. tostring(randomTile) .. ")"
    elseif state == 2 then
        self.tile = farmlandTilesStage2[randomTile]
        self.tileKey = "tile_farmland_stage_2 (" .. tostring(randomTile) .. ")"
    elseif state == 3 then
        self.tile = farmlandTilesStage3[randomTile]
        self.tileKey = "tile_farmland_stage_3 (" .. tostring(randomTile) .. ")"
    elseif state == 4 then
        self.tile = farmlandTilesStage4[randomTile]
        self.tileKey = "tile_farmland_stage_4 (" .. tostring(randomTile) .. ")"
    elseif state == 5 then
        if self.isPlant then
            self.tile = farmlandHayTile
            self.tileKey = "tile_farmland_hay (1)"
        else
            self.tile = farmlandTilesStage0[randomTile]
            self.tileKey = "tile_farmland_stage_0 (" .. tostring(randomTile) .. ")"
        end
    end
    local _, _, _, wh = self.tile:getViewport()
    self.offsetY = -(wh - 16)
    self:render()
end

local WheatFarm = _G.class("WheatFarm", Structure)

WheatFarm.static.WIDTH = 3
WheatFarm.static.LENGTH = 3
WheatFarm.static.HEIGHT = 14
WheatFarm.static.ALIAS_NAME = "WheatFarmAlias"
WheatFarm.static.DESTRUCTIBLE = true

function WheatFarm:initialize(gx, gy, type)
    _G.JobController:add("WheatFarmer", self)
    type = type or "Static structure"
    Structure.initialize(self, gx, gy, type)
    self.health = 400
    self.tile = quadArray[tiles + 1]
    self.stoneQuantity = 0
    self.working = false
    self.offsetX = 0
    self.offsetY = -64 - 6 - 8

    self.state = 0

    for xx = -1, 13 do
        for yy = -1, 13 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrainBiome.scarceGrass)
        end
    end

    for xx = 0, 2 do
        for yy = 0, 2 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrainBiome.none)
        end
    end

    for tile = 1, tiles do
        local whf = WheatFarmAlias:new(quadArray[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offsetY + 8 * (tiles - tile + 1))
        whf.tileKey = tile
    end

    for tile = 1, tiles do
        local whf = WheatFarmAlias:new(quadArray[tiles + 1 + tile], self.gx + tile, self.gy, self,
            -self.offsetY + 8 * tile, 14)
        whf.tileKey = tiles + 1 + tile
    end
    self.availablePlantTiles = 0
    self.landTiles = {}
    local t1, t2
    for y = 4, 11 do
        t1 = WheatFarmPlant:new(self.gx + 0, self.gy + y, self, true)
        t2 = WheatFarmPlant:new(self.gx + 1, self.gy + y, self, true)
        table.insert(self.landTiles, {t1, t2})
    end

    for y = 11, 0, -1 do
        t1 = false
        if y > 3 then
            t1 = WheatFarmPlant:new(self.gx + 2, self.gy + y, self, true)
        end
        t2 = WheatFarmPlant:new(self.gx + 3, self.gy + y, self, true)
        table.insert(self.landTiles, {t1, t2})
    end
    for y = 0, 11 do
        t1 = WheatFarmPlant:new(self.gx + 4, self.gy + y, self, true)
        t2 = WheatFarmPlant:new(self.gx + 5, self.gy + y, self, true)
        table.insert(self.landTiles, {t1, t2})
    end
    for y = 11, 0, -1 do
        t1 = WheatFarmPlant:new(self.gx + 6, self.gy + y, self, true)
        t2 = WheatFarmPlant:new(self.gx + 7, self.gy + y, self, true)
        table.insert(self.landTiles, {t1, t2})
    end
    for y = 0, 11 do
        t1 = WheatFarmPlant:new(self.gx + 8, self.gy + y, self, true)
        t2 = WheatFarmPlant:new(self.gx + 9, self.gy + y, self, true)
        table.insert(self.landTiles, {t1, t2})
    end
    for y = 11, 0, -1 do
        t1 = WheatFarmPlant:new(self.gx + 10, self.gy + y, self, true)
        t2 = WheatFarmPlant:new(self.gx + 11, self.gy + y, self, true)
        table.insert(self.landTiles, {t1, t2})
    end

    self:applyBuildingHeightMap()

    table.insert(self.landTiles[1], WheatFarmPlant:new(self.gx + 0, self.gy + 3, self, true))
    table.insert(self.landTiles[1], WheatFarmPlant:new(self.gx + 2, self.gy + 3, self, true))
    table.insert(self.landTiles[1], WheatFarmPlant:new(self.gx + 1, self.gy + 3, self, true))
    self.tilesSowed = 0
    self.tilesFullyGrown = 0
    -- WheatFarmPlant:new(self.gx + 0, self.gy + 3, self)
    -- WheatFarmPlant:new(self.gx + 2, self.gy + 3, self)
    -- WheatFarmPlant:new(self.gx + 1, self.gy + 3, self)
    -- WheatFarmPlant:new(self.gx + 3, self.gy + 3, self)
    self.maxLandTiles = #self.landTiles
    self.processedTiles = 0

    for xx = 1, 2 do
        for yy = 1, 2 do
            WheatFarmAlias:new(tileQuads["empty"], self.gx + xx, self.gy + yy, self, self.offsetX, self.offsetY)
        end
    end

    self.freeSpots = 1
    Structure.render(self)

    self.float = NotEnoughWorkersFloat:new(self.gx + self.class.WIDTH - 1, self.gy + self.class.LENGTH - 1, 4, -120)
end

function WheatFarm:destroy()
    if self.wheatWorker then
        self.wheatWorker:die()
    end
    self.float:destroy()

    for xx = -1, 13 do
        for yy = -1, 13 do
            local tile = _G.objectFromClassAtGlobal(self.gx + xx, self.gy + yy, "WheatFarmPlant")
            if tile then
                tile.state = -1
                Structure.destroy(tile)
                tile.toBeDeleted = true
            end
        end
    end

    _G.stockpile:store("wood")
    _G.stockpile:store("wood")
end

function WheatFarm:load(data)
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
    if data.wheatWorker then
        self.wheatWorker = _G.state:dereferenceObject(data.wheatWorker)
        self.wheatWorker.workplace = self
    end
    Structure.render(self)
end

function WheatFarm:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.availablePlantTiles = self.availablePlantTiles
    data.health = self.health
    data.stoneQuantity = self.stoneQuantity
    data.working = self.working
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    data.maxLandTiles = self.maxLandTiles
    data.processedTiles = self.processedTiles
    data.tilesSowed = self.tilesSowed
    data.tilesFullyGrown = self.tilesFullyGrown
    data.freeSpots = self.freeSpots
    data.state = self.state
    if self.wheatWorker then
        data.wheatWorker = _G.state:serializeObject(self.wheatWorker)
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

function WheatFarm.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

function WheatFarm:join(worker)
    if self.health == -1 then
        _G.JobController:remove("WheatFarmer", self)
        worker:die()
        return
    end
    if self.freeSpots == 1 then
        self.wheatWorker = worker
        worker.workplace = self
        self.freeSpots = self.freeSpots - 1
    end
    if self.freeSpots == 0 then
        self.float:deactivate()
    end
end

function WheatFarm:updateTiles(farmlandTiles)
    for _, tile in ipairs(farmlandTiles) do
        if tile then
            if tile.state == -1 then
                tile:setState(0)
            elseif tile.state == 0 then
                tile:setState(1)
                self.tilesSowed = self.tilesSowed + 1
            elseif tile.state == 4 then
                if tile.isPlant then
                    tile:setState(5)
                else
                    tile:setState(0)
                end
            end
        end
    end
end

function WheatFarm:fillResourceTiles()
    for _, tilePair in ipairs(self.landTiles) do
        for _, tile in ipairs(tilePair) do
            if tile and tile.isPlant then
                tile.hasWheatResource = true
            end
        end
    end
end

function WheatFarm:getNextResourceTile()
    for _, tilePair in ipairs(self.landTiles) do
        for _, tile in ipairs(tilePair) do
            if tile and tile.hasWheatResource then
                return tile
            end
        end
    end
    return false
end

function WheatFarm:work(worker)
    if self.wheatWorker == worker then
        if self.wheatWorker.state ~= "Resting" then
            self.wheatWorker.state = "Working"
        end
        if self.state == 0 then
            self.processedTiles = self.processedTiles + 1
            local currentTile = self.landTiles[self.processedTiles][2]
            if not currentTile then
                currentTile = self.landTiles[self.processedTiles][1]
            end
            if self.wheatWorker:isPositionAt(currentTile.gx, currentTile.gy - 2) then
                self.wheatWorker.state = "Hoe walking to southern tile"
            elseif self.wheatWorker:isPositionAt(currentTile.gx, currentTile.gy + 2) then
                self.wheatWorker.state = "Hoe walking to northern tile"
            elseif self.wheatWorker:isPositionAt(currentTile.gx - 1, currentTile.gy + 2) then
                self.wheatWorker.state = "Hoe walking to northeastern tile"
                self.wheatWorker.currentTile = currentTile
            elseif self.wheatWorker:isPositionAt(currentTile.gx - 1, currentTile.gy + 1) then
                self.wheatWorker.state = "Hoe walking to northeastern tile"
                self.wheatWorker.currentTile = currentTile
            elseif self.wheatWorker:isPositionAt(currentTile.gx - 2, currentTile.gy + 1) then
                self.wheatWorker.state = "Hoe walking to northeastern tile"
                self.wheatWorker.currentTile = currentTile
            elseif self.wheatWorker:isPositionAt(currentTile.gx - 2, currentTile.gy - 1) then
                self.wheatWorker.state = "Hoe walking to southeastern tile"
            else
                self.wheatWorker:requestPath(currentTile.gx, currentTile.gy - 1)
                self.wheatWorker.state = "Going to hoe the land from north"
                self.wheatWorker.moveDir = "none"
            end
            self.wheatWorker.farmlandTiles = self.landTiles[self.processedTiles]
            if self.processedTiles == self.maxLandTiles then
                self.state = 1
                self.processedTiles = 0
            end
        elseif self.state == 1 then
            if self.processedTiles == self.maxLandTiles then
                self.state = 2
                self.processedTiles = 0
                self:fillResourceTiles()
                self.wheatWorker.state = "Go to rest"
                return
            end
            self.processedTiles = self.processedTiles + 1
            local currentTile = self.landTiles[self.processedTiles][2]
            if self.wheatWorker:isPositionAt(currentTile.gx, currentTile.gy - 2) then
                self.wheatWorker.state = "Seed walking to southern tile"
            elseif self.wheatWorker:isPositionAt(currentTile.gx, currentTile.gy + 2) then
                self.wheatWorker.state = "Seed walking to northern tile"
            elseif self.wheatWorker:isPositionAt(currentTile.gx - 1, currentTile.gy + 2) then
                self.wheatWorker.state = "Seed walking to northeastern tile"
                self.wheatWorker.currentTile = currentTile
            elseif self.wheatWorker:isPositionAt(currentTile.gx - 1, currentTile.gy + 1) then
                self.wheatWorker.state = "Seed walking to northeastern tile"
                self.wheatWorker.currentTile = currentTile
            elseif self.wheatWorker:isPositionAt(currentTile.gx - 2, currentTile.gy + 1) then
                self.wheatWorker.state = "Seed walking to northeastern tile"
                self.wheatWorker.currentTile = currentTile
            elseif self.wheatWorker:isPositionAt(currentTile.gx - 2, currentTile.gy - 1) then
                self.wheatWorker.state = "Seed walking to southeastern tile"
            else
                self.wheatWorker:requestPath(currentTile.gx, currentTile.gy - 1)
                self.wheatWorker.state = "Going to seed the land from north"
                self.wheatWorker.moveDir = "none"
            end
            self.wheatWorker.farmlandTiles = self.landTiles[self.processedTiles]
        elseif self.state == 2 then
            -- on each rest cycle, check if plants are ready
            if self.tilesFullyGrown == self.availablePlantTiles then
                self.state = 3
                self.processedTiles = 0
            end
        elseif self.state == 3 then
            self.processedTiles = self.processedTiles + 1
            local currentTile = self.landTiles[self.processedTiles][2]
            if self.wheatWorker:isPositionAt(currentTile.gx, currentTile.gy - 2) then
                self.wheatWorker.state = "Scythe walking to southern tile"
            elseif self.wheatWorker:isPositionAt(currentTile.gx, currentTile.gy + 2) then
                self.wheatWorker.state = "Scythe walking to northern tile"
            elseif self.wheatWorker:isPositionAt(currentTile.gx - 1, currentTile.gy + 2) then
                self.wheatWorker.state = "Scythe walking to northeastern tile"
                self.wheatWorker.currentTile = currentTile
            elseif self.wheatWorker:isPositionAt(currentTile.gx - 1, currentTile.gy + 1) then
                self.wheatWorker.state = "Scythe walking to northeastern tile"
                self.wheatWorker.currentTile = currentTile
            elseif self.wheatWorker:isPositionAt(currentTile.gx - 2, currentTile.gy + 1) then
                self.wheatWorker.state = "Scythe walking to northeastern tile"
                self.wheatWorker.currentTile = currentTile
            elseif self.wheatWorker:isPositionAt(currentTile.gx - 2, currentTile.gy - 1) then
                self.wheatWorker.state = "Scythe walking to southeastern tile"
            else
                self.wheatWorker:requestPath(currentTile.gx, currentTile.gy - 1)
                self.wheatWorker.state = "Going to scythe the land from north"
                self.wheatWorker.moveDir = "none"
            end
            self.wheatWorker.farmlandTiles = self.landTiles[self.processedTiles]
            if self.processedTiles == self.maxLandTiles then
                self.state = 4
                self.processedTiles = 0
            end
        elseif self.state == 4 then
            local resourceTile = self:getNextResourceTile()
            if resourceTile then
                self.wheatWorker.resourceTile = resourceTile
                self.wheatWorker.state = "Going to pick up wheat"
                self.wheatWorker:clearPath()
                self.wheatWorker:requestPath(resourceTile.gx, resourceTile.gy)
            else
                if self.wheatWorker.wheat > 0 then
                    self.wheatWorker.state = "Go to stockpile"
                    self.wheatWorker:clearPath()
                else
                    self.tilesFullyGrown = 0
                    self.tilesSowed = 0
                    self.state = 1
                    self.processedTiles = 0
                    self:work(self.wheatWorker)
                end
            end
        end
    end
end

function WheatFarm:sendToStockpile()
    self.wheatWorker.state = "Go to foodpile"
    self.wheatWorker.moveDir = "none"
    self.working = false
end

return WheatFarm
