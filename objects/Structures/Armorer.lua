local tileQuads = require("objects.object_quads")
local Structure = require("objects.Structure")
local Object = require("objects.Object")
local anim = require("libraries.anim8")
local NotEnoughWorkersFloat = require("objects.Structures.NotEnoughWorkersFloat")

local tiles, quadArray = _G.indexBuildingQuads("armourer_workshop (18)")
local tilesExt, quadArrayExt = _G.indexBuildingQuads("armourer_workshop (9)")

local ANIM_CRAFTING_SHIELD = "Crafting_Shield"

local an = {
    [ANIM_CRAFTING_SHIELD] = _G.addReverse(_G.indexQuads("armourer_anim", 15)),
}

local armourerFx = {
    ["bonk"] = {_G.fx["armourhit_01"],
        _G.fx["armourhit_02"],
        _G.fx["armourhit_03"],
        _G.fx["armourhit_04"],
        _G.fx["armourhit_05"]}
}

local ShieldCrafting = _G.class("ShieldCrafting", Structure)
function ShieldCrafting:initialize(gx, gy, parent)
    self.parent = parent
    Structure.initialize(self, gx, gy, "Shield crafting")
    self.tile = tileQuads["empty"]
    self.animated = false
    self.craftingCycle = 0
    self.animation = anim.newAnimation(an[ANIM_CRAFTING_SHIELD], 0.11, self:craftCallback_1(), ANIM_CRAFTING_SHIELD)
    self.animation:pause()
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.offsetX = -51
    self.offsetY = -77

    self:registerAsActiveEntity()
end

function ShieldCrafting:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.animation = self.animation:serialize()
    data.animated = self.animated
    data.craftingCycle = self.craftingCycle
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    data.parent = _G.state:serializeObject(self.parent)
    return data
end

function ShieldCrafting.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.cookingObj = obj
    local callback
    local anData = data.animation
    if anData.animationIdentifier == ANIM_CRAFTING_SHIELD then
        callback = obj:craftCallback_1()
    end
    obj.animation = _G.anim.newAnimation(an[anData.animationIdentifier], 1, callback, anData.animationIdentifier)
    obj.animation:deserialize(anData)

    return obj
end

function ShieldCrafting:craftCallback_1()
    return function()
        self.animation = anim.newAnimation(an[ANIM_CRAFTING_SHIELD], 0.11, self:craftCallback_1(), ANIM_CRAFTING_SHIELD)

        if self.craftingCycle == 6 then
            self.parent:sendToStockpile()
            self.craftingCycle = 0
            self:deactivate()
        else
            self.craftingCycle = self.craftingCycle + 1
        end
    end
end

function ShieldCrafting:animate()
    local prevPosition = self.animation.position
    Structure.animate(self, _G.dt, true)
    local newPosition = self.animation.position
    if self.animation.status == "playing" and self.animation.animationIdentifier == ANIM_CRAFTING_SHIELD and prevPosition ~= newPosition then
        if (self.animation.position == 6 or (prevPosition < 6 and newPosition > 6)) then
            _G.playSfx(self, armourerFx["bonk"])
        elseif (self.animation.position == 23 or (prevPosition < 23 and newPosition > 23)) then
            _G.playSfx(self, armourerFx["bonk"])
        end
    end
end

function ShieldCrafting:activate()
    self.animated = true
    self.animation:gotoFrame(1)
    self.animation:resume()
    self:animate()
end

function ShieldCrafting:deactivate()
    self.animation:pause()
    self.tile = tileQuads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
        self.instancemesh = nil
    end
    self.animated = false
end

local ArmorerAlias = _G.class("ArmorerAlias", Structure)
function ArmorerAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
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

function ArmorerAlias:serialize()
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

function ArmorerAlias.static:deserialize(data)
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

local Armorer = _G.class("Armorer", Structure)

Armorer.static.WIDTH = 4
Armorer.static.LENGTH = 4
Armorer.static.HEIGHT = 17
Armorer.static.DESTRUCTIBLE = true

function Armorer:initialize(gx, gy)
    _G.JobController:add("Armourer", self)
    Structure.initialize(self, gx, gy, "Armorer")
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 200
    self.tile = quadArray[tiles + 1]
    self.working = false
    self.unloading = false
    self.offsetX = 0
    self.offsetY = -52
    self.freeSpots = 1
    self.worker = nil
    self.cookingObj = ShieldCrafting:new(self.gx + 3, self.gy + 2, self)
    for tile = 1, tiles do
        local hsl = ArmorerAlias:new(quadArray[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offsetY + 8 * (tiles - tile + 1))
        hsl.tileKey = tile
    end
    for tile = 1, tiles do
        local hsl = ArmorerAlias:new(quadArray[tiles + 1 + tile], self.gx + tile, self.gy, self, -self.offsetY + 8 * tile
            , 16)
        hsl.tileKey = tiles + 1 + tile
    end
    local tileQuads = require("objects.object_quads")
    for xx = 0, Armorer.static.WIDTH - 1 do
        for yy = 0, Armorer.static.LENGTH - 1 do
            if not _G.objectFromSubclassAtGlobal(self.gx + xx, self.gy + yy, Structure) then
                ArmorerAlias:new(tileQuads["empty"], self.gx + xx, self.gy + yy, self, 0, 0)
            end
        end
    end
    self.float = NotEnoughWorkersFloat:new(self.gx + self.class.WIDTH - 1, self.gy + self.class.LENGTH - 1, 7, -112)
    self:applyBuildingHeightMap()
end

function Armorer:destroy()
    self.float:destroy()
    Structure.destroy(self.cookingObj)
    self.cookingObj.toBeDeleted = true

    _G.JobController:remove("Armourer", self)
    Structure.destroy(self)
    if self.worker then
        self.worker:quitJob()
    end
end

function Armorer:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    if data.worker then
        self.worker = _G.state:dereferenceObject(data.worker)
        self.worker.workplace = self
    end
    self.tile = quadArray[tiles + 1]
    Structure.render(self)
end

function Armorer:serialize()
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

function Armorer.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

function Armorer:onClick()
    -- empty, just needed to trigger the inside view
end

function Armorer:enterHover()
    self.hover = true
    for tile = 1, tiles do
        local alias = _G.objectFromClassAtGlobal(self.gx, self.gy + (tiles - tile + 1), ArmorerAlias)
        if not alias then return end
        alias.tile = quadArray[tile]
        alias.tileKey = tile
        alias:render()
    end

    for tile = 1, tiles do
        local alias = _G.objectFromClassAtGlobal(self.gx + tile, self.gy, ArmorerAlias)
        if not alias then return end
        alias.tile = quadArray[tiles + 1 + tile]
        alias.tileKey = tiles + 1 + tile
        alias:render()
    end
    self.tile = quadArray[tiles + 1]
    self:render()
end

function Armorer:exitHover(induced)
    if induced or not self.cookingObj.animated then
        self.hover = false
    else return end
    for tile = 1, tilesExt do
        local alias = _G.objectFromClassAtGlobal(self.gx, self.gy + (tilesExt - tile + 1), ArmorerAlias)
        if alias then
            alias.tile = quadArrayExt[tile]
            alias.tileKey = tile
            alias:render()
        end
    end

    for tile = 1, tilesExt do
        local alias = _G.objectFromClassAtGlobal(self.gx + tile, self.gy, ArmorerAlias)
        if alias then
            alias.tile = quadArrayExt[tilesExt + 1 + tile]
            alias.tileKey = tilesExt + 1 + tile
            alias:render()
        end
    end
    self.tile = quadArrayExt[tilesExt + 1]
    self:render()
end

function Armorer:join(worker)
    if self.health == -1 then
        _G.JobController:remove("Armourer", self)
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

function Armorer:work(worker)
    if self.worker.state == "Going to workplace with IRON" then
        self.worker.state = "Working"
        self.working = true
        worker.tile = tileQuads["empty"]
        worker.animated = false
        worker.gx = self.gx + 1
        worker.gy = self.gy + 2
        worker:jobUpdate()
        self.cookingObj:activate()
    else
        self.worker.state = "Working"
        if not self.working and self.worker.state == "Working" then
            self.worker.state = "Go to stockpile for IRON"
        end
    end
    if self.worker.state == "Working" then
        self:enterHover()
    end
end

function Armorer:sendToStockpile()
    local i, o, cx, cy
    self.worker.state = "Go to armoury"
    self.worker.animated = true
    self.worker.gx = self.gx + 1
    self.worker.gy = self.gy + 4
    self.worker.fx = self.worker.gx * 1000 + 500
    self.worker.fy = self.worker.gy * 1000 + 500
    i = (self.worker.gx) % (_G.chunkWidth)
    o = (self.worker.gy) % (_G.chunkWidth)
    cx = math.floor(self.worker.gx / _G.chunkWidth)
    cy = math.floor(self.worker.gy / _G.chunkWidth)
    _G.addObjectAt(cx, cy, i, o, self.worker)
    self.working = false
    self.worker.needNewVertAsap = true
    self.cookingObj:deactivate()
    self:exitHover(true)
end

return Armorer
