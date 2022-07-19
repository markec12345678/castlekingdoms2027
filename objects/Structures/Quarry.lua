local activeEntities, _, tileQuads, _ = ...

local Structure = require("objects.Structure")
local Object = require("objects.Object")
local anim = require("libraries.anim8")
local tiles, quadArray = _G.indexBuildingQuads("stone_quarry")

local frLifterPart1 = _G.indexQuads("anim_quarry_lower", 17)
local frLifterPart2 = _G.indexQuads("anim_quarry_lower", 20 + 18, 18)
local frLifterPart3 = _G.indexQuads("anim_quarry_lower", 31 + 18 + 20, 18 + 20)
local frHookPart1 = _G.indexQuads("anim_quarry_hook", 47)
table.insert(frHookPart1, 1, tileQuads["anim_quarry_hook_empty (1)"])
local frHookPart2 = _G.indexQuads("anim_quarry_hook", 17 + 45, 48)
local frShaper = _G.indexQuads("anim_quarry_cut", 131)

table.remove(frShaper, 2)
table.remove(frShaper, 2)
table.remove(frShaper, 2)
table.remove(frShaper, 2)
table.remove(frShaper, 2)

local frPullerPart2 = _G.indexQuads("anim_quarry_pull", 42 + 20, 20)
local frPullerPart1 = _G.indexQuads("anim_quarry_pull", 19)
local frStack = _G.indexQuads("small_stone_stack", 2)

local ANIM_LIFTER_PART1 = "lifter_part1"
local ANIM_LIFTER_PART2 = "lifter_part2"
local ANIM_LIFTER_PART3 = "lifter_part3"
local ANIM_LIFTER_PART4 = "lifter_part4"
local ANIM_HOOK_PART1 = "hook_part1"
local ANIM_HOOK_PART2 = "hook_part2"
local ANIM_SHAPER = "shaper"
local ANIM_PULLER_PART1 = "puller_part1"
local ANIM_PULLER_PART2 = "puller_part1"
local ANIM_STACK = "stack"

local an = {
    [ANIM_LIFTER_PART1] = frLifterPart1,
    [ANIM_LIFTER_PART2] = frLifterPart2,
    [ANIM_LIFTER_PART3] = frLifterPart3,
    [ANIM_LIFTER_PART4] = frLifterPart1,
    [ANIM_HOOK_PART1] = frHookPart1,
    [ANIM_HOOK_PART2] = frHookPart2,
    [ANIM_SHAPER] = frShaper,
    [ANIM_PULLER_PART1] = frPullerPart1,
    [ANIM_PULLER_PART2] = frPullerPart2,
    [ANIM_STACK] = frStack
}

local QuarryLifter = _G.class("QuarryLifter", Structure)
function QuarryLifter:initialize(gx, gy, parent)
    local mytype = "Lifter"
    self.parent = parent
    Structure.initialize(self, gx, gy, mytype)
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_LIFTER_PART1], 0.10, self:lifterCallback_1(), ANIM_LIFTER_PART1)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.offsetX = -2
    self.offsetY = -93
    table.insert(activeEntities, self)
end
function QuarryLifter:serialize()
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
function QuarryLifter.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.lifter = obj
    local callback
    local anData = data.animation
    if anData.animationIdentifier == ANIM_LIFTER_PART1 then
        callback = obj:lifterCallback_1()
    elseif anData.animationIdentifier == ANIM_LIFTER_PART2 then
        callback = obj:lifterCallback_2()
    elseif anData.animationIdentifier == ANIM_LIFTER_PART3 then
        callback = obj:lifterCallback_3()
    elseif anData.animationIdentifier == ANIM_LIFTER_PART4 then
        callback = obj:lifterCallback_4()
    end
    obj.animation = _G.anim.newAnimation(an[anData.animationIdentifier], 1, callback, anData.animationIdentifier)
    obj.animation:deserialize(anData)
    table.insert(activeEntities, obj)
    return obj
end
function QuarryLifter:lifterCallback_1()
    return function()
        self.parent.puller:activate()
        self.parent.hook:activate()
        self.animation = anim.newAnimation(an[ANIM_LIFTER_PART2], 0.10, self:lifterCallback_2(), ANIM_LIFTER_PART2)
    end
end
function QuarryLifter:lifterCallback_2()
    return function()
        self.animation = anim.newAnimation(an[ANIM_LIFTER_PART3], 0.10, self:lifterCallback_3(), ANIM_LIFTER_PART3)
    end
end
function QuarryLifter:lifterCallback_3()
    return function()
        self.animation = anim.newAnimation(an[ANIM_LIFTER_PART4], 0.10, self:lifterCallback_4(), ANIM_LIFTER_PART4)
        self.animation:pause()
    end
end
function QuarryLifter:lifterCallback_4()
    return function()
        self.animation:gotoFrame(1)
    end
end
function QuarryLifter:animate(dt)
    Structure.animate(self, dt, true)
end
function QuarryLifter:start()
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_LIFTER_PART1], 0.11, self:lifterCallback_1(), ANIM_LIFTER_PART1)
    self.animation:pause()
    self:animate()
end
function QuarryLifter:stop()
    self.animation:pause()
    self.quantity = 0
    self.animated = false
end
function QuarryLifter:activate()
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_LIFTER_PART1], 0.11, self:lifterCallback_1(), ANIM_LIFTER_PART1)
    self:animate()
end
function QuarryLifter:deactivate()
    self.animation:pause()
    self.tile = tileQuads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
        self.instancemesh = nil
    end
    self.animated = false
end

local QuarryHook = _G.class("QuarryHook", Structure)
function QuarryHook:initialize(gx, gy, parent)
    local mytype = "Hook"
    self.parent = parent
    Structure.initialize(self, gx, gy, mytype)
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_HOOK_PART1], 0.11, self:hookCallback_1(), ANIM_HOOK_PART1)
    self.animation:pause()
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.offsetX = -2
    self.offsetY = -116
    table.insert(activeEntities, self)
end
function QuarryHook:hookCallback_1()
    return function()
        self.parent.shaper:activate()
        self.animation = anim.newAnimation(an[ANIM_HOOK_PART2], 0.12, self:hookCallback_2(), ANIM_HOOK_PART2)
    end
end
function QuarryHook:hookCallback_2()
    return function()
        self.animation = anim.newAnimation(an[ANIM_HOOK_PART1], 0.11, self:hookCallback_1(), ANIM_HOOK_PART1)
        self.animation:pause()
    end
end
function QuarryHook:animate(dt)
    Structure.animate(self, dt, true)
end
function QuarryHook:activate()
    self.animated = true
    self.animation:gotoFrame(2)
    self.animation:resume()
    self:animate()
end
function QuarryHook:serialize()
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
function QuarryHook.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.hook = obj
    local callback
    local anData = data.animation
    if anData.animationIdentifier == ANIM_HOOK_PART1 then
        callback = obj:hookCallback_1()
    elseif anData.animationIdentifier == ANIM_HOOK_PART2 then
        callback = obj:hookCallback_2()
    end
    obj.animation = _G.anim.newAnimation(an[anData.animationIdentifier], 1, callback, anData.animationIdentifier)
    obj.animation:deserialize(anData)
    table.insert(activeEntities, obj)
    return obj
end

local QuarryShaper = _G.class("QuarryShaper", Structure)
function QuarryShaper:initialize(gx, gy, parent)
    local mytype = "Shaper"
    self.parent = parent
    Structure.initialize(self, gx, gy, mytype)
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_SHAPER], 0.05, self:shaperCallback(), ANIM_SHAPER)
    self.animation:pause()
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.offsetX = -31
    self.offsetY = -79
    table.insert(activeEntities, self)
end
function QuarryShaper:shaperCallback()
    return function()
        self.parent.lifter:activate()
        self.animation:gotoFrame(1)
        self.animation:pause()
        self.parent.stack:add()
        if self.parent.stack.quantity == self.parent.stack.class.MAX_QUANTITY then
            if self.parent.isStandalone then
                self.parent:sendToStockpile()
            else
                self.parent:stop()
            end
        end
    end
end
function QuarryShaper:animate(dt)
    Structure.animate(self, dt, true)
end
function QuarryShaper:start()
    self.animated = true
    self.animation:pause()
    self:animate()
end
function QuarryShaper:stop()
    self.animation:pause()
    self.quantity = 0
    self.animated = false
end
function QuarryShaper:activate()
    self.animated = true
    self.animation:resume()
    self:animate()
end
function QuarryShaper:deactivate()
    self.animation:pause()
    self.tile = tileQuads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
        self.instancemesh = nil
    end
    self.animated = false
end
function QuarryShaper:serialize()
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
function QuarryShaper.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.shaper = obj
    local callback
    local anData = data.animation
    if anData.animationIdentifier == ANIM_SHAPER then
        callback = obj:shaperCallback()
    end
    obj.animation = _G.anim.newAnimation(an[anData.animationIdentifier], 1, callback, anData.animationIdentifier)
    obj.animation:deserialize(anData)
    table.insert(activeEntities, obj)
    return obj
end

local QuarryPuller = _G.class("QuarryPuller", Structure)
function QuarryPuller:initialize(gx, gy, parent, offsetX, offsetY)
    local mytype = "Puller"
    self.parent = parent
    Structure.initialize(self, gx, gy, mytype)
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_PULLER_PART1], 0.11, self:pullerCallback_1(), ANIM_PULLER_PART1)
    self.animation:pause()
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.offsetX = 92 + offsetX - 16 - 16
    self.offsetY = 58 + offsetY - 32 - 16
    table.insert(activeEntities, self)
end
function QuarryPuller:pullerCallback_1()
    return function()
        self.animation = anim.newAnimation(an[ANIM_PULLER_PART2], 0.11, self:pullerCallback_2(), ANIM_PULLER_PART2)
    end
end
function QuarryPuller:pullerCallback_2()
    return function()
        self.animation = anim.newAnimation(an[ANIM_PULLER_PART1], 0.11, self:pullerCallback_1(), ANIM_PULLER_PART1)
        self.animation:gotoFrame(1)
        self.animation:pause()
    end
end
function QuarryPuller:animate(dt)
    Structure.animate(self, dt, true)
end
function QuarryPuller:start()
    self.animated = true
    self.animation:pause()
    self:animate()
end
function QuarryPuller:stop()
    self.animation:pause()
    self.quantity = 0
    self.animated = false
end
function QuarryPuller:activate()
    self.animated = true
    self.animation:resume()
    self:animate()
end
function QuarryPuller:deactivate()
    self.animation:pause()
    self.quantity = 0
    self.tile = tileQuads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
        self.instancemesh = nil
    end
    self.animated = false
end
function QuarryPuller:serialize()
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
function QuarryPuller.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.puller = obj
    local callback
    local anData = data.animation
    if anData.animationIdentifier == ANIM_PULLER_PART1 then
        callback = obj:pullerCallback_1()
    elseif anData.animationIdentifier == ANIM_PULLER_PART2 then
        callback = obj:pullerCallback_2()
    end
    obj.animation = _G.anim.newAnimation(an[anData.animationIdentifier], 1, callback, anData.animationIdentifier)
    obj.animation:deserialize(anData)
    table.insert(activeEntities, obj)
    return obj
end

local QuarryStack = _G.class("QuarryStack", Structure)
QuarryStack.static.MAX_QUANTITY = 3
function QuarryStack:initialize(gx, gy, parent)
    local mytype = "Stack"
    self.parent = parent
    self.quantity = 0
    Structure.initialize(self, gx, gy, mytype)
    self.offsetX = 11
    self.offsetY = -105
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_STACK], 0.11, nil, ANIM_STACK)
    self.animation:pause()
    table.insert(activeEntities, self)
end

function QuarryStack:animate(dt)
    Structure.animate(self, dt, true)
end

function QuarryStack:add()
    local newQuantity = self.quantity + 1
    if newQuantity <= self.class.MAX_QUANTITY then
        self.quantity = newQuantity
        if self.quantity == 1 then
            self:activate()
            return
        end
        self.animation:gotoFrame(self.quantity)
    else
        print("Quarry Stack is full!")
    end
end

function QuarryStack:take()
    self.quantity = self.quantity - 1
    self.parent:start()
    if self.quantity == 0 then
        self:deactivate()
        self.parent.unloading = false
        return
    end
    if self.quantity < self.parent.stack.class.MAX_QUANTITY then
        self.parent:start()
    end
    self.animation:gotoFrame(self.quantity)
end

function QuarryStack:activate()
    self.animated = true
    self.animation:gotoFrame(1)
    self.animation:pause()
    self:animate()
end

function QuarryStack:deactivate()
    self.animation:pause()
    self.tile = tileQuads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
        self.instancemesh = nil
    end
    self.animated = false
end

function QuarryStack:serialize()
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
    data.parent = _G.state:serializeObject(self.parent)
    return data
end

function QuarryStack.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.stack = obj
    local anData = data.animation
    obj.animation = _G.anim.newAnimation(an[anData.animationIdentifier], 1, nil, anData.animationIdentifier)
    obj.animation:deserialize(anData)
    obj.quantity = data.quantity
    obj.offsetX = 11
    obj.offsetY = -105
    table.insert(activeEntities, obj)
    return obj
end

local QuarryAlias = _G.class("QuarryAlias", Structure)
function QuarryAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
    self.parent = parent
    Structure.initialize(self, gx, gy, "Quarry alias")
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
function QuarryAlias:serialize()
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
function QuarryAlias.static:deserialize(data)
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

local Quarry = _G.class("Quarry", Structure)
Quarry.static.WIDTH = 6
Quarry.static.LENGTH = 6
Quarry.static.HEIGHT = 16
function Quarry:initialize(gx, gy)
    _G.JobController:add("Stonemason", self)
    Structure.initialize(self, gx, gy, "Quarry")
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 400
    self.tile = quadArray[tiles + 1]
    self.working = false
    self.offsetX = 0
    self.offsetY = -7 * 16 - 6
    self.freeSpots = 3
    self.assignedOxHandler = nil
    self.liftWorker = nil
    self.pullWorker = nil
    self.shapeWorker = nil
    self.isStandalone = true
    self.lifter = QuarryLifter:new(self.gx + 3, self.gy + 5, self, self.offsetX - 64 - 16)
    self.lifter:deactivate()
    self.shaper = QuarryShaper:new(self.gx + 1, self.gy + 5, self, self.offsetX - 64 - 16, self.offsetY)
    self.shaper:deactivate()
    self.puller = QuarryPuller:new(self.gx + 4, self.gy + 2, self, self.offsetX - 64 - 16, self.offsetY)
    self.puller:deactivate()
    self.hook = QuarryHook:new(self.gx + 2, self.gy + 5, self, self.offsetX - 64 - 16)
    self.stack = QuarryStack:new(self.gx + 9, self.gy + 10, self)
    self.stack:deactivate()

    for xx = 0, 5 do
        for yy = 0, 5 do
            _G.removeObjectFromClassAtGlobal(self.gx + xx, self.gy + yy, "Stone")
        end
    end
    for xx = 0, 5 do
        for yy = 0, 5 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrainBiome.none)
        end
    end

    for tile = 1, tiles do
        local qur = QuarryAlias:new(quadArray[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offsetY + 8 * (tiles - tile + 1))
        qur.tileKey = tile
    end

    for tile = 1, tiles do
        local qur = QuarryAlias:new(quadArray[tiles + 1 + tile], self.gx + tile, self.gy, self,
            -self.offsetY + 8 * tile, 14)
        qur.tileKey = tiles + 1 + tile
    end

    QuarryAlias:new(tileQuads["empty"], self.gx + 5, self.gy + 1, self, 12 + 8 * 4, 16)
    QuarryAlias:new(tileQuads["empty"], self.gx + 5, self.gy + 2, self, 12 + 8 * 4, 16)
    QuarryAlias:new(tileQuads["empty"], self.gx + 5, self.gy + 3, self, 12 + 8 * 4, 16)
    QuarryAlias:new(tileQuads["empty"], self.gx + 5, self.gy + 4, self, 12 + 8 * 4, 16)
    QuarryAlias:new(tileQuads["empty"], self.gx + 5, self.gy + 5, self, 12 + 8 * 4, 16)
    QuarryAlias:new(tileQuads["empty"], self.gx + 1, self.gy + 5, self, 12 + 8 * 4, 16)
    QuarryAlias:new(tileQuads["empty"], self.gx + 2, self.gy + 5, self, 12 + 8 * 4, 16)
    QuarryAlias:new(tileQuads["empty"], self.gx + 3, self.gy + 5, self, 12 + 8 * 4, 16)
    QuarryAlias:new(tileQuads["empty"], self.gx + 4, self.gy + 5, self, 12 + 8 * 4, 16)

    Structure:applyBuildingHeightMap(gx, gy, self.class.WIDTH, self.class.LENGTH, self.class.HEIGHT)
    Structure.render(self)
end
function Quarry:join(worker)
    if self.freeSpots == 3 then
        self.liftWorker = worker
        worker.workplace = self
        self.freeSpots = self.freeSpots - 1
    elseif self.freeSpots == 2 then
        self.pullWorker = worker
        worker.workplace = self
        self.freeSpots = self.freeSpots - 1
    elseif self.freeSpots == 1 then
        self.shapeWorker = worker
        worker.workplace = self
        self.freeSpots = self.freeSpots - 1
    end
end
function Quarry:work(worker)
    if self.liftWorker == worker then
        worker.state = "Working"
        worker.tile = tileQuads["empty"]
        worker.animated = false
        worker.gx = self.gx + 3
        worker.gy = self.gy + 2
        worker:jobUpdate()
        self.lifter:start()
    elseif self.pullWorker == worker then
        worker.state = "Working"
        worker.tile = tileQuads["empty"]
        worker.animated = false
        worker.gx = self.gx + 4
        worker.gy = self.gy + 3
        worker:jobUpdate()
        self.puller:start()
        self.puller.tile = tileQuads["anim_quarry_pull (1)"]
    elseif self.shapeWorker == worker then
        worker.state = "Working"
        worker.tile = tileQuads["empty"]
        worker.animated = false
        worker.gx = self.gx + 3
        worker.gy = self.gy + 4
        self.shaper:start()
        worker:jobUpdate()
        self.shaper.tile = tileQuads["anim_quarry_cut (1)"]
    end
    if self.shapeWorker and self.shapeWorker.state == "Working" and not self.working and self.liftWorker.state ==
        "Working" and self.pullWorker.state == "Working" then
        self.working = true
        self.lifter:activate()
    end
end
function Quarry:sendToStockpile()
    if self.isStandalone then
        self.stack:take()
        self.stack:take()
        self.stack:take()
        local i, o, cx, cy
        self.liftWorker.state = "Go to stockpile"
        self.liftWorker.animated = true
        self.liftWorker.gx = self.gx + 6
        self.liftWorker.gy = self.gy + 2
        self.liftWorker.fx = (self.gx + 6) * 1000 + 500
        self.liftWorker.fy = (self.gy + 2) * 1000 + 500
        i = (self.liftWorker.gx) % (_G.chunkWidth)
        o = (self.liftWorker.gy) % (_G.chunkWidth)
        cx = math.floor(self.liftWorker.gx / _G.chunkWidth)
        cy = math.floor(self.liftWorker.gy / _G.chunkWidth)
        _G.addObjectAt(cx, cy, i, o, self.liftWorker)

        self.pullWorker.state = "Go to stockpile"
        self.pullWorker.animated = true
        self.pullWorker.gx = self.gx + 5
        self.pullWorker.gy = self.gy - 1
        self.pullWorker.fx = (self.gx + 5) * 1000 + 500
        self.pullWorker.fy = (self.gy - 1) * 1000 + 500
        i = (self.pullWorker.gx) % (_G.chunkWidth)
        o = (self.pullWorker.gy) % (_G.chunkWidth)
        cx = math.floor(self.pullWorker.gx / _G.chunkWidth)
        cy = math.floor(self.pullWorker.gy / _G.chunkWidth)
        _G.addObjectAt(cx, cy, i, o, self.pullWorker)

        self.shapeWorker.state = "Go to stockpile"
        self.shapeWorker.animated = true
        self.shapeWorker.gx = self.gx + 1
        self.shapeWorker.gy = self.gy + 6
        self.shapeWorker.fx = (self.gx + 1) * 1000 + 500
        self.shapeWorker.fy = (self.gy + 6) * 1000 + 500
        i = (self.shapeWorker.gx) % (_G.chunkWidth)
        o = (self.shapeWorker.gy) % (_G.chunkWidth)
        cx = math.floor(self.shapeWorker.gx / _G.chunkWidth)
        cy = math.floor(self.shapeWorker.gy / _G.chunkWidth)
        _G.addObjectAt(cx, cy, i, o, self.shapeWorker)

        self.lifter:deactivate()
        self.puller:deactivate()
        self.shaper:deactivate()
        self.stack:deactivate()
        self.working = false
    end
end
function Quarry:start()
    if not self.working then
        self.lifter:start()
        self.puller:start()
        self.shaper:start()
        if self.shapeWorker and self.shapeWorker.state == "Working" and not self.working and self.liftWorker.state ==
            "Working" and self.pullWorker.state == "Working" then
            self.working = true
            self.lifter:activate()
        end
    end
end
function Quarry:stop()
    self.lifter:stop()
    self.puller:stop()
    self.shaper:stop()
    self.working = false
end
function Quarry:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    self.health = data.health
    self.working = data.working
    self.offsetX = data.offsetX
    self.offsetY = data.offsetY
    self.freeSpots = data.freeSpots
    if data.liftWorker then
        self.liftWorker = _G.state:dereferenceObject(data.liftWorker)
        self.liftWorker.workplace = self
    end
    if data.pullWorker then
        self.pullWorker = _G.state:dereferenceObject(data.pullWorker)
        self.pullWorker.workplace = self
    end
    if data.shapeWorker then
        self.shapeWorker = _G.state:dereferenceObject(data.shapeWorker)
        self.shapeWorker.workplace = self
    end
    self.tile = quadArray[tiles + 1]
    Structure.render(self)
end
function Quarry:serialize()
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
    if self.liftWorker then
        data.liftWorker = _G.state:serializeObject(self.liftWorker)
    end
    if self.pullWorker then
        data.pullWorker = _G.state:serializeObject(self.pullWorker)
    end
    if self.shapeWorker then
        data.shapeWorker = _G.state:serializeObject(self.shapeWorker)
    end
    return data
end
function Quarry.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

return Quarry
