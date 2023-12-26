local tileQuads = require("objects.object_quads")
local Structure = require("objects.Structure")
local Object = require("objects.Object")
local anim = require("libraries.anim8")
local NotEnoughWorkersFloat = require("objects.Structures.NotEnoughWorkersFloat")

local tilesExt, quadArrayExt = _G.indexBuildingQuads("beer_workshop (9)")
local tiles, quadArray = _G.indexBuildingQuads("beer_workshop (18)")

local ANIM_BREWING_BEER = "Brewing_Beer"
local ANIM_BREWING_BEER_PART2 = "Brewing_Beer_Part2"
local ANIM_BEER_STACK = "Beer_Stack"

local an = {
    [ANIM_BREWING_BEER] = _G.indexQuads("anim_brewer", 1),
    [ANIM_BREWING_BEER_PART2] = _G.indexQuads("anim_brewer", 48, 1),
    [ANIM_BEER_STACK] = _G.indexQuads("anim_brewer", 1)
}

local breweryFx = {
    ["Stir"] = { _G.fx["stir1"],
        _G.fx["stir2"],
        _G.fx["stir3"],
        _G.fx["stir4"],
        _G.fx["stir5"],
        _G.fx["stir6"] }
}

local BreweryCooking = _G.class("BreweryCooking", Structure)
function BreweryCooking:initialize(gx, gy, parent)
    self.parent = parent
    Structure.initialize(self, gx, gy, "Brewery cooking")
    self.tile = tileQuads["empty"]
    self.animated = false
    self.brewingCycle = 0
    self.animation = anim.newAnimation(an[ANIM_BREWING_BEER], 0.11, self:brewCallback_1(), ANIM_BREWING_BEER)
    self.animation:pause()
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.offsetX = -51
    self.offsetY = -77

    self:registerAsActiveEntity()
end

function BreweryCooking:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.animation = self.animation:serialize()
    data.animated = self.animated
    data.brewingCycle = self.brewingCycle
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    data.parent = _G.state:serializeObject(self.parent)
    return data
end

function BreweryCooking.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.cookingObj = obj
    local callback
    local anData = data.animation
    if anData.animationIdentifier == ANIM_BREWING_BEER then
        callback = obj:brewCallback_1()
    elseif anData.animationIdentifier == ANIM_BREWING_BEER_PART2 then
        callback = obj:brewCallback_2()
    end
    obj.animation = _G.anim.newAnimation(an[anData.animationIdentifier], 1, callback, anData.animationIdentifier)
    obj.animation:deserialize(anData)

    return obj
end

function BreweryCooking:brewCallback_1()
    return function()
        self.brewingCycle = self.brewingCycle + 1
        self.animation = anim.newAnimation(
            an[ANIM_BREWING_BEER_PART2], 0.11, self:brewCallback_2(), ANIM_BREWING_BEER_PART2)
    end
end

function BreweryCooking:brewCallback_2()
    return function()
        self.animation = anim.newAnimation(an[ANIM_BREWING_BEER], 0.11, self:brewCallback_1(), ANIM_BREWING_BEER)

        if self.brewingCycle == 6 then
            self.parent:sendToStockpile()
            self.brewingCycle = 0
            self:deactivate()
        end
    end
end

function BreweryCooking:animate()
    Structure.animate(self, _G.dt, true)
    if self.animation.status == "playing" and (self.animation.animationIdentifier == ANIM_BREWING_BEER
            or self.animation.animationIdentifier == ANIM_BREWING_BEER_PART2) and self.animation.position == 1 then
        _G.playSfx(self, breweryFx["Stir"])
    end
end

function BreweryCooking:activate()
    self.animated = true
    self.animation:gotoFrame(1)
    self.animation:resume()
    self:animate()
end

function BreweryCooking:deactivate()
    self.animation:pause()
    self.tile = tileQuads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
        self.instancemesh = nil
    end
    self.animated = false
end

local BreweryAlias = _G.class("BreweryAlias", Structure)
function BreweryAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
    local mytype = "Static structure"
    self.parent = parent
    Structure.initialize(self, gx, gy, mytype)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.tile = tile
    self.baseOffsetY = offsetY or 0
    self.additionalOffsetY = 0
    self.offsetX = offsetX or 0
    self.offsetY = self.additionalOffsetY - self.baseOffsetY
    Structure.render(self)
end

function BreweryAlias:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.tileKey = self.tileKey
    data.baseOffsetY = self.baseOffsetY
    data.additionalOffsetY = self.additionalOffsetY
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    data.parent = _G.state:serializeObject(self.parent)
    return data
end

function BreweryAlias.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    if data.tileKey then
        obj.tile = quadArray[data.tileKey]
        obj.tileKey = data.tileKey
        obj:render()
    end
    return obj
end

local Brewery = _G.class("Brewery", Structure)

Brewery.static.WIDTH = 4
Brewery.static.LENGTH = 4
Brewery.static.HEIGHT = 17
Brewery.static.ALIAS_NAME = "BreweryAlias"
Brewery.static.DESTRUCTIBLE = true

function Brewery:initialize(gx, gy)
    _G.JobController:add("Brewer", self)
    Structure.initialize(self, gx, gy, "Brewery")
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 400
    self.tile = quadArray[tiles + 1]
    self.working = false
    self.unloading = false
    self.offsetX = 0
    self.offsetY = 64 - 131
    self.freeSpots = 1
    self.worker = nil
    self.cookingObj = BreweryCooking:new(self.gx + 3, self.gy + 2, self)

    for xx = -2, 5 do
        for yy = -2, 5 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrainBiome.dirt, _G.terrainBiome.abundantGrass)
        end
    end
    for xx = -1, 4 do
        for yy = -1, 4 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrainBiome.scarceGrass)
        end
    end

    for tile = 1, tiles do
        local bkr = BreweryAlias:new(
            quadArray[tile], self.gx, self.gy + (tiles - tile + 1), self, -self.offsetY + 8 * (tiles - tile + 1))
        bkr.tileKey = tile
    end
    for tile = 1, tiles do
        local bkr = BreweryAlias:new(
            quadArray[tiles + 1 + tile], self.gx + tile, self.gy, self, -self.offsetY + 8 * tile, 16)
        bkr.tileKey = tiles + 1 + tile
    end

    BreweryAlias:new(tileQuads["empty"], self.gx + 1, self.gy + 3, self, self.offsetX, self.offsetY)
    BreweryAlias:new(tileQuads["empty"], self.gx + 2, self.gy + 3, self, self.offsetX, self.offsetY)
    BreweryAlias:new(tileQuads["empty"], self.gx + 1, self.gy + 2, self, self.offsetX, self.offsetY)
    BreweryAlias:new(tileQuads["empty"], self.gx + 2, self.gy + 2, self, self.offsetX, self.offsetY)
    BreweryAlias:new(tileQuads["empty"], self.gx + 1, self.gy + 1, self, self.offsetX, self.offsetY)
    BreweryAlias:new(tileQuads["empty"], self.gx + 2, self.gy + 1, self, self.offsetX, self.offsetY)
    BreweryAlias:new(tileQuads["empty"], self.gx + 3, self.gy + 1, self, self.offsetX, self.offsetY)

    self.float = NotEnoughWorkersFloat:new(self.gx + self.class.WIDTH - 1, self.gy + self.class.LENGTH - 1, 7, -112)
    self:exitHover(true)
    self:applyBuildingHeightMap()
end

function Brewery:destroy()
    self.float:destroy()
    Structure.destroy(self.cookingObj)
    self.cookingObj.toBeDeleted = true

    Structure.destroy(self)
    _G.JobController:remove("Brewer", self)
    if self.worker then
        self.worker:quitJob()
    end
end

function Brewery:onClick()

end

function Brewery:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    if data.worker then
        self.worker = _G.state:dereferenceObject(data.worker)
        self.worker.workplace = self
    end
    self.tile = quadArray[tiles + 1]
    Structure.render(self)
end

function Brewery:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.health = self.health
    data.working = self.working
    data.unloading = self.unloading
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    data.freeSpots = self.freeSpots
    if self.worker then
        data.worker = _G.state:serializeObject(self.worker)
    end
    return data
end

function Brewery.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

function Brewery:leave(sleepInsteadOfLeaving)
    if self.worker then
        _G.JobController:add("Brewer", self)
        if sleepInsteadOfLeaving then
            self.worker:quitJob()
        else
            self.worker:leaveVillage()
        end
        self.worker = nil
        self.freeSpots = 1
        self.float:activate()
        self.cookingObj:deactivate()
        return true
    end
end

function Brewery:join(worker)
    if self.health == -1 then
        _G.JobController:remove("Brewer", self)
        worker:quitJob()
        return
    end
    if self.freeSpots == 1 then
        self.worker = worker
        self.worker.workplace = self
        self.freeSpots = self.freeSpots - 1
    end
    if self.freeSpots == 0 then
        self.float:deactivate()
    end
end

function Brewery:enterHover(induced)
    self.hover = true

    for tile = 1, tiles do
        local alias = _G.objectFromClassAtGlobal(self.gx, self.gy + (tiles - tile + 1), BreweryAlias)
        if not alias then return end
        alias.tile = quadArray[tile]
        alias.tileKey = tile
        alias:render()
    end

    for tile = 1, tiles do
        local alias = _G.objectFromClassAtGlobal(self.gx + tile, self.gy, BreweryAlias)
        if not alias then return end
        alias.tile = quadArray[tiles + 1 + tile]
        alias.tileKey = tiles + 1 + tile
        alias:render()
    end

    self.tile = quadArray[tiles + 1]
    self:render()
end

function Brewery:exitHover(induced)
    if induced or not self.cookingObj.animated then
        self.hover = false
    else
        return
    end

    for tile = 1, tilesExt do
        local alias = _G.objectFromClassAtGlobal(self.gx, self.gy + (tilesExt - tile + 1), BreweryAlias)
        if alias then
            alias.tile = quadArrayExt[tile]
            alias.tileKey = tile
            alias:render()
        end
    end

    for tile = 1, tilesExt do
        local alias = _G.objectFromClassAtGlobal(self.gx + tile, self.gy, BreweryAlias)
        if alias then
            alias.tile = quadArrayExt[tilesExt + 1 + tile]
            alias.tileKey = tilesExt + 1 + tile
            alias:render()
        end
    end

    self.tile = quadArrayExt[tilesExt + 1]
    self:render()
end

function Brewery:work(worker)
    if self.worker.state == "Going to workplace with hops" then
        self.worker.state = "Working"
        self.working = true
        worker.tile = tileQuads["empty"]
        worker.animated = false
        worker.gx = self.gx + 1
        worker.gy = self.gy + 2
        worker:jobUpdate()
        self.cookingObj:activate()
        self:enterHover(true)
    else
        self.worker.state = "Working"

        if not self.working and self.worker.state == "Working" then
            self.worker.state = "Go to stockpile for hops"
        end
    end
end

function Brewery:sendToStockpile()
    local i, o, cx, cy
    self.worker.state = "Go to stockpile"
    self.worker.animated = true
    self.worker.gx = self.gx + 1
    self.worker.gy = self.gy + 4
    self.worker.fx = (self.gx + 1) * 1000 + 500
    self.worker.fy = (self.gy + 4) * 1000 + 500
    i = (self.worker.gx) % (_G.chunkWidth)
    o = (self.worker.gy) % (_G.chunkWidth)
    cx = math.floor(self.worker.gx / _G.chunkWidth)
    cy = math.floor(self.worker.gy / _G.chunkWidth)
    self.working = false
    self.worker.needNewVertAsap = true
    self.workerDelivered = false
    self.cookingObj:deactivate()
    self:exitHover(true)
end

return Brewery
