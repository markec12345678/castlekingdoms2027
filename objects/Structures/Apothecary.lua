local tileQuads = require("objects.object_quads")
local Structure = require("objects.Structure")
local Object = require("objects.Object")
local anim = require("libraries.anim8")
local NotEnoughWorkersFloat = require("objects.Structures.NotEnoughWorkersFloat")

local tiles, quadArray = _G.indexBuildingQuads("apothecary_inside")
local tilesExt, quadArrayExt = _G.indexBuildingQuads("apothecary")

local ApothecaryAlias = _G.class("ApothecaryAlias", Structure)
local Apothecary = _G.class("Apothecary", Structure)

local ANIM_PREPERING_MEDICINE = "Preparing_medicine"

local an = {
    [ANIM_PREPERING_MEDICINE] = _G.indexQuads("anim_healer", 42),
}

local apothecaryFx = {
--TBD
}

local ApothecaryCooking = _G.class("ApothecaryCooking", Structure)
function ApothecaryCooking:initialize(gx, gy, parent)
    self.parent = parent
    Structure.initialize(self, gx, gy, "Apothecary cooking")
    self.tile = tileQuads["empty"]
    self.animated = false
    self.working = false
    self.brewingCycle = 0
    self.animation = anim.newAnimation(an[ANIM_PREPERING_MEDICINE], 0.11, self:brewCallback_1(), ANIM_PREPERING_MEDICINE)
    self.animation:pause()
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.offsetX = -28
    self.offsetY = -72

    self:registerAsActiveEntity()
end

function ApothecaryCooking:serialize()
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

function ApothecaryCooking.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.cookingObj = obj
    local callback
    local anData = data.animation
    if anData.animationIdentifier == ANIM_PREPERING_MEDICINE then
        callback = obj:brewCallback_1()
    end
    obj.animation = _G.anim.newAnimation(an[anData.animationIdentifier], 1, callback, anData.animationIdentifier)
    obj.animation:deserialize(anData)

    return obj
end

function ApothecaryCooking:brewCallback_1()
    return function()
        self.brewingCycle = self.brewingCycle + 1
        self.animation = anim.newAnimation(
            an[ANIM_PREPERING_MEDICINE], 0.11, self:brewCallback_1(), ANIM_PREPERING_MEDICINE)
        if self.brewingCycle == 3 then
                self.brewingCycle = 0
                self.parent:sendToHeal()
                self:deactivate()
        end
    end
end

function ApothecaryCooking:animate()
    Structure.animate(self, _G.dt, true)
end

function ApothecaryCooking:activate()
    self.animated = true
    self.animation:gotoFrame(1)
    self.animation:resume()
    self:animate()
end

function ApothecaryCooking:deactivate()
    self.animation:pause()
    self.tile = tileQuads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
        self.instancemesh = nil
    end
    self.animated = false
end

function ApothecaryAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
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

function ApothecaryAlias:serialize()
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

function ApothecaryAlias.static:deserialize(data)
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

Apothecary.static.WIDTH = 6
Apothecary.static.LENGTH = 6
Apothecary.static.HEIGHT = 17
Apothecary.static.DESTRUCTIBLE = true

function Apothecary:initialize(gx, gy)
    _G.JobController:add("Healer", self)
    Structure.initialize(self, gx, gy, "Apothecary")
    self.animated = false
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 50
    self.tile = quadArray[tiles + 1]
    self.offsetX = 0
    self.offsetY = -85
    self.freeSpots = 1
    self.worker = nil
    self.cookingObj = ApothecaryCooking:new(self.gx + 3, self.gy + 2, self)

    for tile = 1, tiles do
        local hsl = ApothecaryAlias:new(quadArray[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offsetY + 8 * (tiles - tile + 1))
        hsl.tileKey = tile
    end
    for tile = 1, tiles do
        local hsl = ApothecaryAlias:new(quadArray[tiles + 1 + tile], self.gx + tile, self.gy, self, -self.offsetY + 8 * tile, 16)
        hsl.tileKey = tiles + 1 + tile
    end
    for xx = 0, Apothecary.static.WIDTH - 1 do
        for yy = 0, Apothecary.static.LENGTH - 1 do
            if not _G.objectFromSubclassAtGlobal(self.gx + xx, self.gy + yy, Structure) then
                ApothecaryAlias:new(tileQuads["empty"], self.gx + xx, self.gy + yy, self, 0, 0)
            end
        end
    end
    self:applyBuildingHeightMap()

    self.float = NotEnoughWorkersFloat:new(self.gx, self.gy, 0, -64)
end

function Apothecary:destroy()
    self.float:destroy()
    Structure.destroy(self.cookingObj)
    self.cookingObj.toBeDeleted = true
    if self.worker then
        self.worker:die()
    end
    Structure.destroy(self)
end

function Apothecary:work(worker)
    if self.worker.state == "Working in workplace" then
        self.working = true
        worker.gx = self.gx + 3
        worker.gy = self.gy + 6
        worker.tile = tileQuads["empty"]
        worker.animated = false
        worker:jobUpdate()
        self.cookingObj:activate()
        self:enterHover(true)
    end
end

function Apothecary:sendToHeal()
    self.worker.animated = true
    self.working = false
    self.worker.needNewVertAsap = true
    self.cookingObj:deactivate()
    self.worker.state = "Going to heal"
    self:exitHover(true)
end

function Apothecary:join(worker)
    if self.health == -1 then
        _G.JobController:remove("Healer", self)
        worker:quitJob()
        return
    end
    if self.freeSpots == 1 then
        self.worker = worker
        worker.workplace = self
        self.freeSpots = self.freeSpots - 1
    end
    if self.freeSpots == 0 then
        self.float:deactivate()
    end
end


function Apothecary:enterHover(induced)
    self.hover = true

    for tile = 1, tiles do
        local alias = _G.objectFromClassAtGlobal(self.gx, self.gy + (tiles - tile + 1), ApothecaryAlias)
        if not alias then return end
        alias.tile = quadArray[tile]
        alias.tileKey = tile
        alias:render()
    end

    for tile = 1, tiles do
        local alias = _G.objectFromClassAtGlobal(self.gx + tile, self.gy, ApothecaryAlias)
        if not alias then return end
        alias.tile = quadArray[tiles + 1 + tile]
        alias.tileKey = tiles + 1 + tile
        alias:render()
    end

    self.tile = quadArray[tiles + 1]
    self:render()
end

function Apothecary:exitHover(induced)
    if induced or not self.cookingObj.animated then
        self.hover = false
    else return end

    for tile = 1, tilesExt do
        local alias = _G.objectFromClassAtGlobal(self.gx, self.gy + (tilesExt - tile + 1), ApothecaryAlias)
        if alias then
            alias.tile = quadArrayExt[tile]
            alias.tileKey = tile
            alias:render()
        end
    end

    for tile = 1, tilesExt do
        local alias = _G.objectFromClassAtGlobal(self.gx + tile, self.gy, ApothecaryAlias)
        if alias then
            alias.tile = quadArrayExt[tilesExt + 1 + tile]
            alias.tileKey = tilesExt + 1 + tile
            alias:render()
        end
    end

    self.tile = quadArrayExt[tilesExt + 1]
    self:render()
end

function Apothecary:onClick()
    --local ActionBar = require("states.ui.ActionBar")
end

function Apothecary:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    if data.worker then
        self.worker = _G.state:dereferenceObject(data.worker)
        self.worker.workplace = self
    end
    self.tile = quadArray[tiles + 1]
    Structure.render(self)
end

function Apothecary:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.health = self.health
    data.working = self.working
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    data.freeSpots = self.freeSpots
    if self.worker then
        data.worker = _G.state:serializeObject(self.worker)
    end
    return data
end

function Apothecary.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

return Apothecary
