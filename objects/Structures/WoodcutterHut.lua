local activeEntities, _, tileQuads, _ = ...
local Structure = require("objects.Structure")
local Object = require("objects.Object")

local tiles, quadArray = _G.indexBuildingQuads("woodcutter_hut", true)

local sawpullFx = {_G.fx["sawpull1 22k"], _G.fx["sawpull2 22k"], _G.fx["sawpull3 22k"]}

local sawpushFx = {_G.fx["sawpush1 22k"], _G.fx["sawpush2 22k"], _G.fx["sawpush3 22k"]}

local frWoodcutterSawing = _G.indexQuads("anim_woodcutter_saw", 19, nil, true)
local frPlankStack = _G.indexQuads("anim_woodcutter_planks", 3)
local frLogStack = _G.indexQuads("anim_woodcutter_logs", 3)

local AN_HUT_SAWING = "Sawing"
local AN_HUT_PLANKS = "Plank stack"
local AN_HUT_LOGS = "Log stack"

local an = {
    [AN_HUT_SAWING] = frWoodcutterSawing,
    [AN_HUT_PLANKS] = frPlankStack,
    [AN_HUT_LOGS] = frLogStack
}
local WoodcutterHutLogStack = _G.class("WoodcutterHutLogStack", Structure)
function WoodcutterHutLogStack:initialize(gx, gy, parent)
    local mytype = "Animation"
    self.parent = parent
    Structure.initialize(self, gx, gy, mytype)
    self.tile = tileQuads["empty"]
    self.animated = false
    self.animation = _G.anim.newAnimation(an[AN_HUT_LOGS], 0.11, nil, AN_HUT_LOGS)
    self.animation:pause()
    self.quantity = 0
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.offsetX = -51
    self.offsetY = -50

    table.insert(activeEntities, self)
end

function WoodcutterHutLogStack:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.animation = self.animation:serialize()
    data.animated = self.animated
    data.quantity = self.quantity
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    return data
end

function WoodcutterHutLogStack.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    local anData = data.animation
    local callback = function()
        if not obj.parent.stack.animated then
            obj.parent.stack:activate()
        else
            obj.parent.stack:stack()
        end
        local tookLog = obj.parent.logStack:take()
        if not tookLog then
            obj.parent:sendToStockpile()
            obj:deactivate()
        end
    end
    obj.animation = _G.anim.newAnimation(an[anData.animationIdentifier], 1, callback, anData.animationIdentifier)
    obj.animation:deserialize(anData)
    table.insert(activeEntities, obj)
    return obj
end

function WoodcutterHutLogStack:stack()
    self.quantity = self.quantity + 1
    self.animation:gotoFrame(self.quantity)
    self:animate(_G.dt, true)
end

function WoodcutterHutLogStack:animate(dt)
    Structure.animate(self, dt, true)
end

function WoodcutterHutLogStack:activate()
    self.animated = true
    self.quantity = 1
    self.animation:gotoFrame(1)
    self.animation:pause()
    self:animate()
end

function WoodcutterHutLogStack:deactivate()
    self.animation:pause()
    self.quantity = 0
    self.tile = tileQuads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
        self.instancemesh = nil
    end
    self.animated = false
end

function WoodcutterHutLogStack:take()
    if self.quantity == 0 then
        return false
    end
    self.quantity = self.quantity - 1
    if self.quantity == 0 then
        self:deactivate()
        return true
    end
    self.animation:gotoFrame(self.quantity)
    self:animate(_G.dt, true)
    return true
end

local WoodcutterHutPlankStack = _G.class("WoodcutterHutPlankStack", Structure)
function WoodcutterHutPlankStack:initialize(gx, gy, parent)
    local mytype = "Animation"
    self.parent = parent
    Structure.initialize(self, gx, gy, mytype)
    self.tile = tileQuads["empty"]
    self.animated = false
    self.animation = _G.anim.newAnimation(an[AN_HUT_PLANKS], 0.11, nil, AN_HUT_PLANKS)
    self.animation:pause()
    self.quantity = 0
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.offsetX = -23
    self.offsetY = -52

    table.insert(activeEntities, self)
end

function WoodcutterHutPlankStack:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.animation = self.animation:serialize()
    data.animated = self.animated
    data.quantity = self.quantity
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    return data
end

function WoodcutterHutPlankStack.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    local anData = data.animation
    obj.animation = _G.anim.newAnimation(an[anData.animationIdentifier], 1, nil, anData.animationIdentifier)
    obj.animation:deserialize(anData)
    table.insert(activeEntities, obj)
    return obj
end

function WoodcutterHutPlankStack:stack()
    self.quantity = self.quantity + 1
    self.animation:gotoFrame(self.quantity)
    self:animate(_G.dt, true)
end

function WoodcutterHutPlankStack:animate(dt)
    Structure.animate(self, dt, true)
end

function WoodcutterHutPlankStack:activate()
    self.animated = true
    self.quantity = 1
    self.animation:gotoFrame(1)
    self.animation:pause()
    self:animate()
end

function WoodcutterHutPlankStack:deactivate()
    self.animation:pause()
    self.quantity = 0
    self.tile = tileQuads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
        self.instancemesh = nil
    end
    self.animated = false
end

function WoodcutterHutPlankStack:take()
    self.quantity = self.quantity - 3
    if self.quantity == 0 then
        self:deactivate()
        self.parent.unloading = false
        return
    end
    self.animation:gotoFrame(self.quantity)
end

local WoodcutterHutSawing = _G.class("WoodcutterHutSawing", Structure)
function WoodcutterHutSawing:initialize(gx, gy, parent)
    local mytype = "Animation"
    self.parent = parent
    Structure.initialize(self, gx, gy, mytype)
    self.tile = tileQuads["empty"]
    self.animated = false
    self.animation = _G.anim.newAnimation(an[AN_HUT_SAWING], 0.11, nil, AN_HUT_SAWING)
    self.animation:pause()
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.offsetX = -35
    self.offsetY = -44
    self:setCallback()

    table.insert(activeEntities, self)
end

function WoodcutterHutSawing:animate()
    if self.animation.position == 8 or self.animation.position == 21 then
        _G.playSfx(self, sawpullFx)
    elseif self.animation.position == 13 or self.animation.position == 26 then
        _G.playSfx(self, sawpushFx)
    end
    Structure.animate(self, _G.dt, true)
end

function WoodcutterHutSawing:activate()
    self.animated = true
    self.animation:gotoFrame(1)
    self.animation:resume()
    self:animate(_G.dt)
end

function WoodcutterHutSawing:deactivate()
    self.animation:pause()
    self.tile = tileQuads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
        self.instancemesh = nil
    end
    self.animated = false
end

function WoodcutterHutSawing:serialize()
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

function WoodcutterHutSawing:setCallback()
    local parent = self.parent
    self.animation.onLoop = function()
        if not parent.stack.animated then
            parent.stack:activate()
        else
            parent.stack:stack()
        end
        local tookLog = parent.logStack:take()
        if not tookLog then
            parent:sendToStockpile()
            self:deactivate()
        end
    end
end

function WoodcutterHutSawing.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    local anData = data.animation
    obj.animation = _G.anim.newAnimation(an[anData.animationIdentifier], 1, nil, anData.animationIdentifier)
    obj.animation:deserialize(anData)
    table.insert(activeEntities, obj)
    return obj
end

local WoodcutterHutAlias = _G.class("WoodcutterHutAlias", Structure)
function WoodcutterHutAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
    local mytype = "Static structure"
    self.parent = parent
    Structure.initialize(self, gx, gy, mytype)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.tile = tile
    self.baseOffsetY = offsetY or 0
    self.additionalOffsetY = 0
    self.offsetX = offsetX or 0
    self.offsetY = self.additionalOffsetY - self.baseOffsetY
    for k, v in ipairs(_G.stockpile.nodeList) do
        if v.gx == self.gx and v.gy == self.gy then
            table.remove(_G.stockpile.nodeList, k)
            break
        end
    end
    Structure.render(self)
end

function WoodcutterHutAlias:serialize()
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

function WoodcutterHutAlias.static:deserialize(data)
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

local WoodcutterHut = _G.class("WoodcutterHut", Structure)

WoodcutterHut.static.WIDTH = 3
WoodcutterHut.static.LENGTH = 3
WoodcutterHut.static.HEIGHT = 14
WoodcutterHut.static.ALIAS_NAME = "WoodcutterHutAlias"
WoodcutterHut.static.DESTRUCTIBLE = true

function WoodcutterHut:initialize(gx, gy, type)
    _G.JobController:add("Woodcutter", self)
    type = type or "Woodcutter hut"
    Structure.initialize(self, gx, gy, type)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    _G.state.firstWoodCutterHut = false
    self.health = 400
    self.tile = quadArray[tiles + 1]
    self.working = false
    self.unloading = false
    self.offsetX = 0
    self.offsetY = -32
    self.freeSpots = 1
    self.worker = nil

    self.stack = WoodcutterHutPlankStack:new(self.gx, self.gy + 2, self)
    self.sawingObj = WoodcutterHutSawing:new(self.gx, self.gy, self)
    self.logStack = WoodcutterHutLogStack:new(self.gx + 2, self.gy + 1, self)

    for xx = -1, 3 do
        for yy = -1, 3 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrainBiome.scarceGrass)
        end
    end

    _G.terrainSetTileAt(self.gx - 2, self.gy, _G.terrainBiome.scarceGrass)
    _G.terrainSetTileAt(self.gx - 2, self.gy + 1, _G.terrainBiome.scarceGrass)
    _G.terrainSetTileAt(self.gx - 2, self.gy + 2, _G.terrainBiome.scarceGrass)

    _G.terrainSetTileAt(self.gx, self.gy - 2, _G.terrainBiome.scarceGrass)
    _G.terrainSetTileAt(self.gx + 1, self.gy - 2, _G.terrainBiome.scarceGrass)
    _G.terrainSetTileAt(self.gx + 2, self.gy - 2, _G.terrainBiome.scarceGrass)

    _G.terrainSetTileAt(self.gx + 4, self.gy, _G.terrainBiome.scarceGrass)
    _G.terrainSetTileAt(self.gx + 4, self.gy + 1, _G.terrainBiome.scarceGrass)
    _G.terrainSetTileAt(self.gx + 4, self.gy + 2, _G.terrainBiome.scarceGrass)

    _G.terrainSetTileAt(self.gx, self.gy + 4, _G.terrainBiome.scarceGrass)
    _G.terrainSetTileAt(self.gx + 1, self.gy + 4, _G.terrainBiome.scarceGrass)
    _G.terrainSetTileAt(self.gx + 2, self.gy + 4, _G.terrainBiome.scarceGrass)

    self:applyBuildingHeightMap()

    for tile = 1, tiles do
        local wht = WoodcutterHutAlias:new(
            quadArray[tile], self.gx, self.gy + (tiles - tile + 1), self, -self.offsetY + 8 * (tiles - tile + 1))
        wht.tileKey = tile
    end
    for tile = 1, tiles do
        local wht = WoodcutterHutAlias:new(
            quadArray[tiles + 1 + tile], self.gx + tile, self.gy, self, -self.offsetY + 8 * tile, 16)
        wht.tileKey = tiles + 1 + tile
    end

    WoodcutterHutAlias:new(tileQuads["empty"], self.gx + 1, self.gy + 1, self, self.offsetX, self.offsetY)
    WoodcutterHutAlias:new(tileQuads["empty"], self.gx + 1, self.gy + 2, self, self.offsetX, self.offsetY)
    WoodcutterHutAlias:new(tileQuads["empty"], self.gx + 2, self.gy + 2, self, self.offsetX, self.offsetY)

    Structure.render(self)
end

function WoodcutterHut:destroy()
    Structure.destroy(self.sawingObj)
    self.sawingObj.toBeDeleted = true
    Structure.destroy(self.stack)
    self.stack.toBeDeleted = true
    Structure.destroy(self.logStack)
    self.logStack.toBeDeleted = true

    if self.worker then
        self.worker:die()
    end

    _G.stockpile:store("wood")
    _G.stockpile:store("wood")
end

function WoodcutterHut:join(worker)
    if self.health == -1 then
        _G.JobController:remove("Woodcutter", self)
        worker:die()
        return
    end
    if self.freeSpots == 1 then
        self.worker = worker
        self.worker.workplace = self
        self.freeSpots = self.freeSpots - 1
    end
end

function WoodcutterHut:work(worker)
    self.logStack:activate()
    self.logStack:stack()
    self.logStack:stack()
    _G.playSfx(self, _G.fx["droplog"])
    worker.state = "Working"
    worker.tile = tileQuads["empty"]
    worker.animated = false
    worker.gx = self.gx + 1
    worker.gy = self.gy + 2
    worker:jobUpdate()

    if not self.working and self.worker.state == "Working" then
        self.working = true
        self.sawingObj:activate()
    end
end

function WoodcutterHut:sendToStockpile()
    local i, o, cx, cy
    self.worker.state = "Go to stockpile"
    self.worker.animated = true
    self.worker.gx = self.gx + 1
    self.worker.gy = self.gy + 3
    self.worker.fx = (self.gx + 1) * 1000 + 500
    self.worker.fy = (self.gy + 3) * 1000 + 500
    i = (self.worker.gx) % (_G.chunkWidth)
    o = (self.worker.gy) % (_G.chunkWidth)
    cx = math.floor(self.worker.gx / _G.chunkWidth)
    cy = math.floor(self.worker.gy / _G.chunkWidth)
    _G.addObjectAt(cx, cy, i, o, self.worker)
    self.stack:deactivate()
    self.working = false
end

function WoodcutterHut:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    if data.worker then
        self.worker = _G.state:dereferenceObject(data.worker)
        self.worker.workplace = self
    end
    self.stack = _G.state:dereferenceObject(data.stack)
    self.stack.parent = self
    self.sawingObj = _G.state:dereferenceObject(data.sawingObj)
    self.sawingObj.parent = self
    self.sawingObj:setCallback()
    self.logStack = _G.state:dereferenceObject(data.logStack)
    self.logStack.parent = self
    self.health = data.health
    self.offsetX = data.offsetX
    self.offsetY = data.offsetY
    self.tile = quadArray[tiles + 1]
    Structure.render(self)
end

function WoodcutterHut:serialize()
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
    data.stack = _G.state:serializeObject(self.stack)
    data.sawingObj = _G.state:serializeObject(self.sawingObj)
    data.logStack = _G.state:serializeObject(self.logStack)
    return data
end

function WoodcutterHut.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

return WoodcutterHut
