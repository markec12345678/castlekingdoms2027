local activeEntities, _, tileQuads, _ = ...

local Structure = require("objects.Structure")
local Object = require("objects.Object")
local anim = require("libraries.anim8")

local tiles, quadArray = _G.indexBuildingQuads("windmill_whole", nil, 2)

local frWindmillFan = _G.indexQuads("anim_windmill_fan", 15)
local frAnimWindmillOutside = _G.indexQuads("anim_windmill_outside", 15)
local frAnimWindmillInside = _G.indexQuads("anim_windmill_inside", 15)
local frAnimWindmillFilling = _G.indexQuads("anim_windmill_filling", 30)

local ANIM_WINDMILL_FAN = "anim_windmill_fan"
local ANIM_WINDMILL_OUTSIDE = "anim_windmill_outside"
local ANIM_WINDMILL_INSIDE = "anim_windmill_inside"
local ANIM_WINDMILL_FILLING = "anim_windmill_filling"

local tempAnim = {_G.unpack(frWindmillFan)}
for _ = 1, 2 do
    for _, v in ipairs(tempAnim) do
        table.insert(frWindmillFan, v)
    end
end
tempAnim = {_G.unpack(frAnimWindmillOutside)}
for _ = 1, 2 do
    for _, v in ipairs(tempAnim) do
        table.insert(frAnimWindmillOutside, v)
    end
end
tempAnim = {_G.unpack(frAnimWindmillInside)}
for _ = 1, 2 do
    for _, v in ipairs(tempAnim) do
        table.insert(frAnimWindmillInside, v)
    end
end

local an = {
    [ANIM_WINDMILL_FAN] = frWindmillFan,
    [ANIM_WINDMILL_OUTSIDE] = frAnimWindmillOutside,
    [ANIM_WINDMILL_INSIDE] = frAnimWindmillInside,
    [ANIM_WINDMILL_FILLING] = frAnimWindmillFilling
}

local WindmillBlade = _G.class("WindmillBlade", Structure)
function WindmillBlade:initialize(gx, gy, parent)
    self.parent = parent
    Structure.initialize(self, gx, gy, "Windmill blade")
    self.tile = tileQuads["empty"]
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_WINDMILL_FAN], 0.11, nil, ANIM_WINDMILL_FAN)
    self.offsetX = -60
    self.offsetY = -274

    table.insert(activeEntities, self)
end

function WindmillBlade:serialize()
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
    return data
end

function WindmillBlade.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    local anData = data.animation
    obj.animation = _G.anim.newAnimation(an[anData.animationIdentifier], 1, nil, anData.animationIdentifier)
    obj.animation:deserialize(anData)
    table.insert(activeEntities, obj)
    return obj
end

function WindmillBlade:animate(dt)
    Structure.animate(self, dt, true)
end

function WindmillBlade:activate()
    self.animation:resume()
end

function WindmillBlade:deactivate()
    self.animation:pause()
end

local WindmillFilling = _G.class("WindmillFilling", Structure)
function WindmillFilling:initialize(gx, gy, parent)
    self.parent = parent
    Structure.initialize(self, gx, gy, "Windmill filling animation")
    self.tile = tileQuads["empty"]
    self.animated = false
    self.animation = anim.newAnimation(
        an[ANIM_WINDMILL_FILLING], 0.11, function()
            self:fillingCallback()
        end, ANIM_WINDMILL_FILLING)
    self.animation:pause()
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.offsetX = -62
    self.offsetY = -201

    table.insert(activeEntities, self)
end

function WindmillFilling:fillingCallback()
    self.parent.bladeShadow:showOutside()
    self.parent:sendToStockpile()
    self:deactivate()
end

function WindmillFilling:animate(dt)
    Structure.animate(self, dt, true)
end

function WindmillFilling:activate()
    self.animated = true
    self.parent.bladeShadow:showInside()
    self.animation:gotoFrame(1)
    self.animation:resume()
    self:animate(_G.dt)
end

function WindmillFilling:deactivate()
    self.animation:pause()
    self.tile = tileQuads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
        self.instancemesh = nil
    end
    self.animated = false
end

function WindmillFilling:serialize()
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
    return data
end

function WindmillFilling.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    local anData = data.animation
    local callback
    if anData.animationIdentifier == ANIM_WINDMILL_FILLING then
        callback = function()
            obj:fillingCallback()
        end
    end
    obj.animation = _G.anim.newAnimation(an[anData.animationIdentifier], 1, callback, anData.animationIdentifier)
    obj.animation:deserialize(anData)
    table.insert(activeEntities, obj)
    return obj
end

local WindmillShadow = _G.class("WindmillShadow", Structure)
function WindmillShadow:initialize(gx, gy, parent)
    self.parent = parent
    Structure.initialize(self, gx, gy, "Windmill shadow")
    self.tile = tileQuads["empty"]
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_WINDMILL_OUTSIDE], 0.11, nil, ANIM_WINDMILL_OUTSIDE)
    self.offsetX = -46
    self.offsetY = -243

    table.insert(activeEntities, self)
end

function WindmillShadow:serialize()
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
    return data
end

function WindmillShadow.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    local anData = data.animation
    obj.animation = _G.anim.newAnimation(an[anData.animationIdentifier], 1, nil, anData.animationIdentifier)
    obj.animation:deserialize(anData)
    table.insert(activeEntities, obj)
    return obj
end

function WindmillShadow:animate(dt)
    Structure.animate(self, dt, true)
end

function WindmillShadow:activate()
    self.animation:resume()
end

function WindmillShadow:showInside()
    local frame = self.animation.position
    self.animation = anim.newAnimation(an[ANIM_WINDMILL_INSIDE], 0.11, nil, ANIM_WINDMILL_INSIDE)
    self.animation:gotoFrame(frame)
end

function WindmillShadow:showOutside()
    local frame = self.animation.position
    self.animation = anim.newAnimation(an[ANIM_WINDMILL_OUTSIDE], 0.11, nil, ANIM_WINDMILL_OUTSIDE)
    self.animation:gotoFrame(frame)
    self:animate()
end

function WindmillShadow:deactivate()
    self.animation:pause()
end

local WindmillAlias = _G.class("WindmillAlias", Structure)
function WindmillAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
    self.parent = parent
    Structure.initialize(self, gx, gy, "Windmill alias")
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.tile = tile
    self.baseOffsetY = offsetY or 0
    self.additionalOffsetY = 0
    self.offsetX = offsetX or 0
    self.offsetY = self.additionalOffsetY - self.baseOffsetY
    Structure.render(self)
end

function WindmillAlias:serialize()
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
    return data
end

function WindmillAlias.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    if data.tileKey then
        obj.tile = quadArray[data.tileKey]
        obj.tileKey = data.tileKey
        obj:render()
    end
    return obj
end

local Windmill = _G.class("Windmill", Structure)

Windmill.static.WIDTH = 3
Windmill.static.LENGTH = 3
Windmill.static.HEIGHT = 20
Windmill.static.ALIAS_NAME = "WindmillAlias"
Windmill.static.DESTRUCTIBLE = true

function Windmill:initialize(gx, gy, type)
    _G.JobController:add("Miller", self)
    type = type or "Windmill"
    Structure.initialize(self, gx, gy, type)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 400
    self.tile = quadArray[tiles + 1]
    self.working = false
    self.unloading = false
    self.offsetX = 0
    local _, _, _, lh = self.tile:getViewport()
    self.offsetY = 48 - lh

    self.wheat = 0
    self.freeSpots = 3
    self.worker = nil
    self.worker2 = nil
    self.worker3 = nil
    self.workerDelivered = false
    self.worker2Delivered = false
    self.worker3Delivered = false

    self.blade = WindmillBlade:new(self.gx, self.gy + 2, self)
    self.bladeShadow = WindmillShadow:new(self.gx, self.gy + 2, self)
    self.fillingFlour = WindmillFilling:new(self.gx + 1, self.gy + 2, self)

    self:applyBuildingHeightMap()

    for xx = -2, 4 do
        for yy = -2, 4 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrainBiome.dirt, _G.terrainBiome.abundantGrass)
        end
    end
    for xx = -1, 3 do
        for yy = -1, 3 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrainBiome.scarceGrass)
        end
    end
    for xx = 0, 2 do
        for yy = 0, 2 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrainBiome.none)
        end
    end
    for tile = 1, tiles do
        local wnd = WindmillAlias:new(
            quadArray[tile], self.gx, self.gy + (tiles - tile + 1), self, -self.offsetY + 8 * (tiles - tile + 1))
        wnd.tileKey = tile
    end
    for tile = 1, tiles do
        local wnd = WindmillAlias:new(
            quadArray[tiles + 1 + tile], self.gx + tile, self.gy, self, -self.offsetY + 8 * tile, 16)
        wnd.tileKey = tiles + 1 + tile
    end

    WindmillAlias:new(tileQuads["empty"], self.gx + 1, self.gy + 1, self, self.offsetX, self.offsetY)
    WindmillAlias:new(tileQuads["empty"], self.gx + 2, self.gy + 1, self, self.offsetX, self.offsetY)
    WindmillAlias:new(tileQuads["empty"], self.gx + 2, self.gy + 2, self, self.offsetX, self.offsetY)

    _G.state.map:setWalkable(self.gx + 2, self.gy + 2, false)
    Structure.render(self)
end

function Windmill:destroy()
    Structure.destroy(self.blade)
    self.blade.toBeDeleted = true
    Structure.destroy(self.bladeShadow)
    self.bladeShadow.toBeDeleted = true
    Structure.destroy(self.fillingFlour)
    self.fillingFlour.toBeDeleted = true

    if self.worker then
        self.worker:die()
    end
    if self.worker2 then
        self.worker2:die()
    end
    if self.worker3 then
        self.worker3:die()
    end

    _G.stockpile:store("wood")
    _G.stockpile:store("wood")
    _G.stockpile:store("wood")
    _G.stockpile:store("wood")
end

function Windmill:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    self.health = data.health
    self.working = data.working
    self.unloading = data.unloading
    self.offsetX = data.offsetX
    self.offsetY = data.offsetY
    self.wheat = data.wheat
    self.freeSpots = data.freeSpots
    if data.worker then
        self.worker = _G.state:dereferenceObject(data.worker)
        self.worker.workplace = self
    end
    if data.worker2 then
        self.worker2 = _G.state:dereferenceObject(data.worker2)
        self.worker2.workplace = self
    end
    if data.worker3 then
        self.worker3 = _G.state:dereferenceObject(data.worker3)
        self.worker3.workplace = self
    end
    self.workerDelivered = data.workerDelivered
    self.worker2Delivered = data.worker2Delivered
    self.worker3Delivered = data.worker3Delivered
    self.blade = _G.state:dereferenceObject(data.blade)
    self.blade.parent = self
    self.bladeShadow = _G.state:dereferenceObject(data.bladeShadow)
    self.bladeShadow.parent = self
    self.fillingFlour = _G.state:dereferenceObject(data.fillingFlour)
    self.fillingFlour.parent = self
    self.tile = quadArray[tiles + 1]
    Structure.render(self)
end

function Windmill:serialize()
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
    data.wheat = self.wheat
    data.freeSpots = self.freeSpots
    if self.worker then
        data.worker = _G.state:serializeObject(self.worker)
    end
    if self.worker2 then
        data.worker2 = _G.state:serializeObject(self.worker2)
    end
    if self.worker3 then
        data.worker3 = _G.state:serializeObject(self.worker3)
    end
    data.workerDelivered = self.workerDelivered
    data.worker2Delivered = self.worker2Delivered
    data.worker3Delivered = self.worker3Delivered
    data.blade = _G.state:serializeObject(self.blade)
    data.bladeShadow = _G.state:serializeObject(self.bladeShadow)
    data.fillingFlour = _G.state:serializeObject(self.fillingFlour)
    return data
end

function Windmill.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

function Windmill:join(worker)
    if self.health == -1 then
        _G.JobController:remove("Miller", self)
        worker:die()
        return
    end
    if self.freeSpots == 3 then
        self.worker = worker
        self.worker.workplace = self
        self.freeSpots = self.freeSpots - 1
    elseif self.freeSpots == 2 then
        self.worker2 = worker
        self.worker2.workplace = self
        self.freeSpots = self.freeSpots - 1
    elseif self.freeSpots == 1 then
        self.worker3 = worker
        self.worker3.workplace = self
        self.freeSpots = self.freeSpots - 1
    end
end

function Windmill:work(worker)
    if worker.state == "Going to workplace with wheat" then
        if not self.working then
            self.wheat = self.wheat + 1
            if worker == self.worker3 or worker == self.worker2 then
                worker.state = "Waiting for work"
                return
            else
                if self.wheat >= 3 then
                    if not self.working then
                        worker.state = "Working"
                        self.working = true
                        worker.tile = tileQuads["empty"]
                        worker.animated = false
                        worker.gx = self.gx + 1
                        worker.gy = self.gy + 2
                        worker:clearPath()
                        worker:jobUpdate()
                        self.fillingFlour:activate()
                        self.wheat = self.wheat - 3
                        self.bladeShadow:showInside()
                        self.worker2Delivered, self.worker3Delivered = false, false
                        -- else
                        --     self.worker.state = "Waiting for work"
                    end
                else
                    worker.state = "Waiting for work"
                end
            end
        end
    else
        -- self.worker.state = "Waiting for work"
        -- worker.state = "Waiting for work"
        if worker == self.worker and self.wheat == 3 then
            worker.state = "Working"
            self.working = true
            worker.tile = tileQuads["empty"]
            worker.animated = false
            worker.gx = self.gx + 1
            worker.gy = self.gy + 2
            worker:clearPath()
            worker:jobUpdate()
            self.wheat = self.wheat - 3
            self.worker2Delivered, self.worker3Delivered = false, false
            self.fillingFlour:activate()
            self.bladeShadow:showInside()
        else
            if worker == self.worker3 and self.wheat < 4 then
                worker.state = "Go to stockpile for wheat"
                worker:clearPath()
            end
            if worker == self.worker2 and self.wheat < 4 then
                worker.state = "Go to stockpile for wheat"
                worker:clearPath()
            end
            if worker == self.worker and not self.workerDelivered then
                if self.wheat >= 3 then
                    worker.state = "Working"
                    self.working = true
                    worker.tile = tileQuads["empty"]
                    worker.animated = false
                    worker.gx = self.gx + 1
                    worker.gy = self.gy + 2
                    worker:clearPath()
                    worker:jobUpdate()
                    self.wheat = self.wheat - 3
                    self.worker2Delivered, self.worker3Delivered = false, false
                    self.fillingFlour:activate()
                    self.bladeShadow:showInside()
                elseif not self.workerDelivered then
                    worker.state = "Go to stockpile for wheat"
                    worker:clearPath()
                end
            end
        end
    end
end

function Windmill:sendToStockpile()
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
    _G.addObjectAt(cx, cy, i, o, self.worker)
    self.working = false
    self.workerDelivered = false
end

return Windmill
