local tileQuads = require("objects.object_quads")
local Structure = require("objects.Structure")
local Object = require("objects.Object")
local anim = require("libraries.anim8")
local NotEnoughWorkersFloat = require("objects.Structures.NotEnoughWorkersFloat")
local SmokeLoop = require("objects.Structures.SmokeLoop")

local tilesExt, quadArrayExt = _G.indexBuildingQuads("bakery_workshop (9)")
local tiles, quadArray = _G.indexBuildingQuads("bakery_workshop (18)")

local ANIM_BAKING_BREAD = "Baking_Bread"
local ANIM_BAKING_BREAD_PART2 = "Baking_Bread_Part2"
local ANIM_BREAD_STACK = "Bread_Stack"

local an = {
    [ANIM_BAKING_BREAD] = _G.indexQuads("anim_baker", 53),
    [ANIM_BAKING_BREAD_PART2] = _G.indexQuads("anim_baker", 64, 54),
    [ANIM_BREAD_STACK] = _G.indexQuads("anim_baker_bread", 4)
}

local bakeryFx = {
    ["ShoveBig"] = { _G.fx["bakebig1"],
        _G.fx["bakebig4"],
        _G.fx["bakebig5"] },
    ["ShoveSmall"] = { _G.fx["bakesmall2"],
        _G.fx["bakesmall3"],
        _G.fx["bakesmall4"],
        _G.fx["bakesmall5"] }
}

local BakeryBreadStack = _G.class("BakeryBreadStack", Structure)
function BakeryBreadStack:initialize(gx, gy, parent)
    self.parent = parent
    Structure.initialize(self, gx, gy, "Bakery bread stack")
    self.tile = tileQuads["empty"]
    self.animated = false
    self.animation = anim.newAnimation(an[ANIM_BREAD_STACK], 0.11, nil, ANIM_BREAD_STACK)
    self.animation:pause()
    self.quantity = 0
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.offsetX = -24
    self.offsetY = -94

    self:registerAsActiveEntity()
end

function BakeryBreadStack:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.animation = self.animation:serialize()
    data.animated = self.animated
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    data.quantity = self.quantity
    data.parent = _G.state:serializeObject(self.parent)
    return data
end

function BakeryBreadStack.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.stack = obj
    local anData = data.animation
    obj.animation = _G.anim.newAnimation(an[anData.animationIdentifier], 1, nil, anData.animationIdentifier)
    obj.animation:deserialize(anData)

    return obj
end

function BakeryBreadStack:stack()
    self.quantity = self.quantity + 1
    self.animation:gotoFrame(self.quantity)
    self:animate(_G.dt)
end

function BakeryBreadStack:animate(dt)
    Structure.animate(self, dt, true)
end

function BakeryBreadStack:activate()
    self.animated = true
    self.quantity = 1
    self.animation:gotoFrame(1)
    self.animation:pause()
    self:animate()
end

function BakeryBreadStack:deactivate()
    self.animation:pause()
    self.quantity = 0
    self.tile = tileQuads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
        self.instancemesh = nil
    end
    self.animated = false
end

function BakeryBreadStack:take()
    self.quantity = self.quantity - 4
    if self.quantity == 0 then
        self:deactivate()
        self.parent.unloading = false
        return
    end
    self.animation:gotoFrame(self.quantity)
end

local BakeryCooking = _G.class("BakeryCooking", Structure)
function BakeryCooking:initialize(gx, gy, parent)
    self.parent = parent
    Structure.initialize(self, gx, gy, "Bakery cooking")
    self.tile = tileQuads["empty"]
    self.animated = false
    self.animation = anim.newAnimation(an[ANIM_BAKING_BREAD], 0.11, self:bakeCallback_1(), ANIM_BAKING_BREAD)
    self.animation:pause()
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.offsetX = -36
    self.offsetY = -88

    self:registerAsActiveEntity()
end

function BakeryCooking:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.animation = self.animation:serialize()
    data.animated = self.animated
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    data.parent = _G.state:serializeObject(self.parent)
    return data
end

function BakeryCooking.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.cookingObj = obj
    local callback
    local anData = data.animation
    if anData.animationIdentifier == ANIM_BAKING_BREAD then
        callback = obj:bakeCallback_1()
    elseif anData.animationIdentifier == ANIM_BAKING_BREAD_PART2 then
        callback = obj:bakeCallback_2()
    end
    obj.animation = _G.anim.newAnimation(an[anData.animationIdentifier], 1, callback, anData.animationIdentifier)
    obj.animation:deserialize(anData)

    return obj
end

function BakeryCooking:bakeCallback_1()
    return function()
        if not self.parent.stack.animated then
            self.parent.stack:activate()
        else
            self.parent.stack:stack()
        end
        self.animation = anim.newAnimation(
            an[ANIM_BAKING_BREAD_PART2], 0.11, self:bakeCallback_2(), ANIM_BAKING_BREAD_PART2)
    end
end

function BakeryCooking:bakeCallback_2()
    return function()
        self.animation = anim.newAnimation(an[ANIM_BAKING_BREAD], 0.11, self:bakeCallback_1(), ANIM_BAKING_BREAD)
        if self.parent.stack.quantity == 4 then
            self.parent:findExitPointTo("Granary", function(found, path)
                if found then
                    self.parent:sendToStockpile()
                else
                    print("No path found to granary!")
                end
            end)
            self:deactivate()
        end
    end
end

function BakeryCooking:animate()
    local prevPosition = self.animation.position
    Structure.animate(self, _G.dt, true)
    local newPosition = self.animation.position
    if self.animation.status == "playing" and self.animation.animationIdentifier == ANIM_BAKING_BREAD then
        if (self.animation.position == 8 or (prevPosition < 8 and newPosition > 8)) then
            _G.playSfx(self, bakeryFx["ShoveSmall"])
        elseif (self.animation.position == 22 or (prevPosition < 22 and newPosition > 22)) then
            _G.playSfx(self, bakeryFx["ShoveBig"])
        elseif (self.animation.position == 53 or (prevPosition < 53 and newPosition > 53)) then
            _G.playSfx(self, bakeryFx["ShoveSmall"])
        end
    end
end

function BakeryCooking:activate()
    self.animated = true
    self.animation:gotoFrame(1)
    self.animation:resume()
    self:animate()
end

function BakeryCooking:deactivate()
    self.animation:pause()
    self.tile = tileQuads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
        self.instancemesh = nil
    end
    self.animated = false
end

local BakeryAlias = _G.class("BakeryAlias", Structure)
function BakeryAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
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

function BakeryAlias:serialize()
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

function BakeryAlias.static:deserialize(data)
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

local Bakery = _G.class("Bakery", Structure)

Bakery.static.WIDTH = 4
Bakery.static.LENGTH = 4
Bakery.static.HEIGHT = 17
Bakery.static.ALIAS_NAME = "BakeryAlias"
Bakery.static.DESTRUCTIBLE = true

function Bakery:initialize(gx, gy)
    _G.JobController:add("Baker", self)
    Structure.initialize(self, gx, gy, "Bakery")
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 400
    self.tile = quadArray[tiles + 1]
    self.working = false
    self.unloading = false
    self.offsetX = 0
    self.offsetY = 64 - 131
    self.freeSpots = 1
    self.worker = nil
    self.cookingObj = BakeryCooking:new(self.gx + 3, self.gy + 2, self)
    self.stack = BakeryBreadStack:new(self.gx + 3, self.gy + 3, self)

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
    self:applyBuildingHeightMap()
    for tile = 1, tiles do
        local bkr = BakeryAlias:new(
            quadArray[tile], self.gx, self.gy + (tiles - tile + 1), self, -self.offsetY + 8 * (tiles - tile + 1))
        bkr.tileKey = tile
    end
    for tile = 1, tiles do
        local bkr = BakeryAlias:new(
            quadArray[tiles + 1 + tile], self.gx + tile, self.gy, self, -self.offsetY + 8 * tile, 16)
        bkr.tileKey = tiles + 1 + tile
    end

    BakeryAlias:new(tileQuads["empty"], self.gx + 1, self.gy + 3, self, self.offsetX, self.offsetY)
    BakeryAlias:new(tileQuads["empty"], self.gx + 2, self.gy + 3, self, self.offsetX, self.offsetY)
    BakeryAlias:new(tileQuads["empty"], self.gx + 1, self.gy + 2, self, self.offsetX, self.offsetY)
    BakeryAlias:new(tileQuads["empty"], self.gx + 2, self.gy + 2, self, self.offsetX, self.offsetY)
    BakeryAlias:new(tileQuads["empty"], self.gx + 1, self.gy + 1, self, self.offsetX, self.offsetY)
    BakeryAlias:new(tileQuads["empty"], self.gx + 2, self.gy + 1, self, self.offsetX, self.offsetY)
    BakeryAlias:new(tileQuads["empty"], self.gx + 3, self.gy + 1, self, self.offsetX, self.offsetY)

    self.float = NotEnoughWorkersFloat:new(self.gx + self.class.WIDTH - 1, self.gy + self.class.LENGTH - 1, 7, -112)
    self.smoke = SmokeLoop:new(self.gx, self.gy, -4, -93)
    self.smoke:deactivate()
    self:setSpawnPoint(self.gx + 1, self.gy + 4)
    Structure.render(self)
end

function Bakery:destroy()
    self.float:destroy()
    self.smoke:destroy()
    Structure.destroy(self.cookingObj)
    self.cookingObj.toBeDeleted = true
    Structure.destroy(self.stack)
    self.stack.toBeDeleted = true

    _G.JobController:remove("Baker", self)
    Structure.destroy(self)
    if self.worker then
        self.worker:quitJob()
    end
end

function Bakery:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    if data.worker then
        self.worker = _G.state:dereferenceObject(data.worker)
        self.worker.workplace = self
    end
    if data.smoke then
        self.smoke = _G.state:dereferenceObject(data.smoke)
    end
    self.tile = quadArray[tiles + 1]
    Structure.render(self)
end

function Bakery:serialize()
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
    if self.smoke then
        data.smoke = _G.state:serializeObject(self.smoke)
    end
    return data
end

function Bakery.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

function Bakery:enterHover(induced)
    self.hover = true
    for tile = 1, tiles do
        local alias = _G.objectFromClassAtGlobal(self.gx, self.gy + (tiles - tile + 1), BakeryAlias)
        if not alias then return end
        alias.tile = quadArray[tile]
        alias.tileKey = tile
        alias:render()
    end

    for tile = 1, tiles do
        local alias = _G.objectFromClassAtGlobal(self.gx + tile, self.gy, BakeryAlias)
        if not alias then return end
        alias.tile = quadArray[tiles + 1 + tile]
        alias.tileKey = tiles + 1 + tile
        alias:render()
    end
    self.tile = quadArray[tiles + 1]
    self:render()
end

function Bakery:exitHover(induced)
    if induced or not self.cookingObj.animated then
        self.hover = false
    else
        return
    end
    for tile = 1, tilesExt do
        local alias = _G.objectFromClassAtGlobal(self.gx, self.gy + (tilesExt - tile + 1), BakeryAlias)
        if alias then
            alias.tile = quadArrayExt[tile]
            alias.tileKey = tile
            alias:render()
        end
    end

    for tile = 1, tilesExt do
        local alias = _G.objectFromClassAtGlobal(self.gx + tile, self.gy, BakeryAlias)
        if alias then
            alias.tile = quadArrayExt[tilesExt + 1 + tile]
            alias.tileKey = tilesExt + 1 + tile
            alias:render()
        end
    end
    self.tile = quadArrayExt[tilesExt + 1]
    self:render()
end

function Bakery:leave(sleepInsteadOfLeaving)
    if self.worker then
        _G.JobController:add("Baker", self)
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

function Bakery:join(worker)
    if self.health == -1 then
        _G.JobController:remove("Baker", self)
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
        self.smoke:activate()
    end
end

function Bakery:onClick()

end

function Bakery:work(worker)
    if self.worker.state == "Going to workplace with flour" then
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
            self.worker.state = "Go to stockpile for flour"
        end
    end
    if self.worker.state == "Working" then
        self:enterHover(true)
        self:exitHover(false)
    end
end

function Bakery:sendToStockpile()
    local i, o, cx, cy
    self.worker.state = "Go to granary"
    self.worker.animated = true
    self.worker.gx = self.spawnpointGX
    self.worker.gy = self.spawnpointGY
    self.worker.fx = self.worker.gx * 1000 + 500
    self.worker.fy = self.worker.gy * 1000 + 500
    i = (self.worker.gx) % (_G.chunkWidth)
    o = (self.worker.gy) % (_G.chunkWidth)
    cx = math.floor(self.worker.gx / _G.chunkWidth)
    cy = math.floor(self.worker.gy / _G.chunkWidth)
    table.insert(self.worker.locationsCx, cx)
    table.insert(self.worker.locationsCy, cy)
    table.insert(self.worker.locationsI, i)
    table.insert(self.worker.locationsO, o)
    _G.addObjectAt(cx, cy, i, o, self.worker)
    self.working = false
    self.worker.needNewVertAsap = true
    self.cookingObj:deactivate()
    self.stack:take()
    self:enterHover(false)
    self:exitHover(true)
end

return Bakery
