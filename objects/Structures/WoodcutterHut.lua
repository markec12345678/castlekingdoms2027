local tileQuads = require("objects.object_quads")
local Structure = require("objects.Structure")
local Object = require("objects.Object")
local NotEnoughWorkersFloat = require("objects.Structures.NotEnoughWorkersFloat")

local tiles, quadArray = _G.indexBuildingQuads("woodcutter_hut", true)

local sawpullFx = { _G.fx["sawpull1 22k"], _G.fx["sawpull2 22k"], _G.fx["sawpull3 22k"] }

local sawpushFx = { _G.fx["sawpush1 22k"], _G.fx["sawpush2 22k"], _G.fx["sawpush3 22k"] }

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
    self.offsetX = -51
    self.offsetY = -50

    self:registerAsActiveEntity()
end

function WoodcutterHutLogStack:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.parent = _G.state:serializeObject(self.parent)
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
            obj:findWorkerExitPointAndSendToStockpile()
            obj:deactivate()
        end
    end
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.logStack = obj
    obj.animation = _G.anim.newAnimation(an[anData.animationIdentifier], 1, callback, anData.animationIdentifier)
    obj.animation:deserialize(anData)
    if obj.parent.restoreExitPoint then
        obj:findWorkerExitPointAndSendToStockpile()
    end

    return obj
end

function WoodcutterHutLogStack:findWorkerExitPointAndSendToStockpile()
    self.parent:findExitPointTo("Stockpile", function(found, path)
        if found then
            self.parent:sendToStockpile()
        else
            print("No path found to stockpile!")
        end
    end)
end

function WoodcutterHutLogStack:stack()
    self.quantity = self.quantity + 1
    self.animation:gotoFrame(self.quantity)
    self:animate(_G.dt)
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
    self:animate(_G.dt)
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
    self.offsetX = -23
    self.offsetY = -52

    self:registerAsActiveEntity()
end

function WoodcutterHutPlankStack:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.parent = _G.state:serializeObject(self.parent)
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
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.stack = obj
    obj.animation = _G.anim.newAnimation(an[anData.animationIdentifier], 1, nil, anData.animationIdentifier)
    obj.animation:deserialize(anData)

    return obj
end

function WoodcutterHutPlankStack:stack()
    self.quantity = self.quantity + 1
    self.animation:gotoFrame(self.quantity)
    self:animate(_G.dt)
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
    self.offsetX = -35
    self.offsetY = -44
    self:setCallback()

    self:registerAsActiveEntity()
end

function WoodcutterHutSawing:animate()
    local prevPosition = self.animation.position
    Structure.animate(self, _G.dt, true)
    local newPosition = self.animation.position
    if prevPosition ~= newPosition then
        if self.animation.position == 8 or self.animation.position == 21 then
            _G.playSfx(self, sawpullFx, true)
        elseif self.animation.position == 13 or self.animation.position == 26 then
            _G.playSfx(self, sawpushFx, true)
        end
    end
end

function WoodcutterHutSawing:activate()
    self.animated = true
    self.animation:gotoFrame(1)
    self.animation:resume()
    self:animate()
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
    data.parent = _G.state:serializeObject(self.parent)
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
            self:findWorkerExitPointAndSendToStockpile()
            self:deactivate()
        end
    end
end

function WoodcutterHutSawing:findWorkerExitPointAndSendToStockpile()
    self.parent:findExitPointTo("Stockpile", function(found, path)
        if found then
            self.parent:sendToStockpile()
        else
            print("No path found to stockpile!")
        end
    end)
end

function WoodcutterHutSawing.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    local anData = data.animation

    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.sawingObj = obj
    obj.animation = _G.anim.newAnimation(an[anData.animationIdentifier], 1, nil, anData.animationIdentifier)
    obj:setCallback()
    obj.animation:deserialize(anData)
    if obj.parent.restoreExitPoint then
        obj:findWorkerExitPointAndSendToStockpile()
    end

    return obj
end

local WoodcutterHutAlias = _G.class("WoodcutterHutAlias", Structure)
function WoodcutterHutAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
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

function WoodcutterHutAlias:serialize()
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

function WoodcutterHutAlias.static:deserialize(data)
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

    self:applyBuildingHeightMap(nil, true)

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

    for x = 0, self.class.WIDTH - 1 do
        for y = 0, self.class.LENGTH - 1 do
            if y ~= 2 then
                _G.state.map:setWalkable(self.gx + x, self.gy + y, 1)
            end
        end
    end

    WoodcutterHutAlias:new(tileQuads["empty"], self.gx + 1, self.gy + 1, self, self.offsetX, self.offsetY)
    WoodcutterHutAlias:new(tileQuads["empty"], self.gx + 1, self.gy + 2, self, self.offsetX, self.offsetY)
    WoodcutterHutAlias:new(tileQuads["empty"], self.gx + 2, self.gy + 2, self, self.offsetX, self.offsetY)

    self.float = NotEnoughWorkersFloat:new(self.gx, self.gy, 8, -64)
    self.getNextTree = coroutine.wrap(function()
        local trees = self:findNearestTreesViaFloodfill()
        for i = 1, #trees do
            local obj = trees[i]
            if obj.cuttable and not self.stump and not obj.marked then
                coroutine.yield(obj)
            end
            trees[i] = nil
        end
        while true do
            coroutine.yield(false)
        end
    end)
end

---returns true if the position is within map bounds
---@param gx integer The global X tile position
---@param gy integer The global Y tile position
---@return boolean isInBounds
---@private
function WoodcutterHut:isInBounds(gx, gy)
    if (gx < 0 or gy < 0
            or gx > _G.chunkWidth * _G.chunksWide
            or gy > _G.chunkHeight * _G.chunksHigh) then
        return false
    end
    return true
end

function WoodcutterHut:findNearestTreesViaFloodfill()
    local x, y = self.gx, self.gy
    local Tree = require("objects.Environment.Tree")
    local queue = require("libraries.queue")
    local stack = queue:new()
    local visited = newAutotable(2)
    local trees = {}
    local maxTiles = 10000
    stack:push({ x, y })
    visited[x][y] = true
    while #stack > 0 or maxTiles > 0 do
        local p = stack:pop()
        if not p then return trees end
        x, y = p[1], p[2]
        _G.terrainSetTileAt(x, y, _G.terrainBiome.beach, nil, true)
        local tree = objectFromSubclassAtGlobal(x + 1, y, Tree)
        if tree then
            trees[#trees + 1] = tree
        end
        tree = objectFromSubclassAtGlobal(x - 1, y, Tree)
        if tree then
            trees[#trees + 1] = tree
        end
        tree = objectFromSubclassAtGlobal(x, y + 1, Tree)
        if tree then
            trees[#trees + 1] = tree
        end
        tree = objectFromSubclassAtGlobal(x, y - 1, Tree)
        if tree then
            trees[#trees + 1] = tree
        end
        -- TODO: fix diagonals
        -- tree = objectFromSubclassAtGlobal(x + 1, y - 1, Tree)
        -- if tree then
        --     trees[#trees + 1] = tree
        -- end
        -- tree = objectFromSubclassAtGlobal(x - 1, y - 1, Tree)
        -- if tree then
        --     trees[#trees + 1] = tree
        -- end
        -- tree = objectFromSubclassAtGlobal(x + 1, y + 1, Tree)
        -- if tree then
        --     trees[#trees + 1] = tree
        -- end
        -- tree = objectFromSubclassAtGlobal(x - 1, y + 1, Tree)
        -- if tree then
        --     trees[#trees + 1] = tree
        -- end
        if self:isInBounds(x + 1, y) and not visited[x + 1][y] and _G.state.map:getWalkable(x + 1, y) == 0 then
            stack:push({ x + 1, y })
            visited[x + 1][y] = true
            maxTiles = maxTiles - 1
            if maxTiles == 0 then return trees end
        end
        if self:isInBounds(x - 1, y) and not visited[x - 1][y] and _G.state.map:getWalkable(x - 1, y) == 0 then
            stack:push({ x - 1, y })
            visited[x - 1][y] = true
            maxTiles = maxTiles - 1
            if maxTiles == 0 then return trees end
        end
        if self:isInBounds(x, y + 1) and not visited[x][y + 1] and _G.state.map:getWalkable(x, y + 1) == 0 then
            stack:push({ x, y + 1 })
            visited[x][y + 1] = true
            maxTiles = maxTiles - 1
            if maxTiles == 0 then return trees end
        end
        if self:isInBounds(x, y - 1) and not visited[x][y - 1] and _G.state.map:getWalkable(x, y - 1) == 0 then
            stack:push({ x, y - 1 })
            visited[x][y - 1] = true
            maxTiles = maxTiles - 1
            if maxTiles == 0 then return trees end
        end
        -- TODO: fix diagonals
        -- if self:isInBounds(x, y - 1) and not visited[x + 1][y - 1] and _G.state.map:getWalkable(x + 1, y - 1) == 0 then
        --     stack:push({ x + 1, y - 1 })
        --     visited[x + 1][y - 1] = true
        --     maxTiles = maxTiles - 1
        --     if maxTiles == 0 then return trees end
        -- end
        -- if self:isInBounds(x, y - 1) and not visited[x - 1][y - 1] and _G.state.map:getWalkable(x - 1, y - 1) == 0 then
        --     stack:push({ x - 1, y - 1 })
        --     visited[x - 1][y - 1] = true
        --     maxTiles = maxTiles - 1
        --     if maxTiles == 0 then return trees end
        -- end
        -- if self:isInBounds(x + 1, y + 1) and not visited[x + 1][y + 1] and _G.state.map:getWalkable(x + 1, y + 1) == 0 then
        --     stack:push({ x + 1, y + 1 })
        --     visited[x + 1][y + 1] = true
        --     maxTiles = maxTiles - 1
        --     if maxTiles == 0 then return trees end
        -- end
        -- if self:isInBounds(x - 1, y + 1) and not visited[x - 1][y + 1] and _G.state.map:getWalkable(x - 1, y + 1) == 0 then
        --     stack:push({ x - 1, y + 1 })
        --     visited[x - 1][y + 1] = true
        --     maxTiles = maxTiles - 1
        --     if maxTiles == 0 then return trees end
        -- end
    end
    return trees
end

function WoodcutterHut:destroy()
    _G.JobController:remove("Woodcutter", self)
    Structure.destroy(self.sawingObj)
    self.sawingObj.toBeDeleted = true
    Structure.destroy(self.stack)
    self.stack.toBeDeleted = true
    Structure.destroy(self.logStack)
    self.logStack.toBeDeleted = true
    self.float:destroy()

    Structure.destroy(self)

    if self.worker then
        self.worker:quitJob()
    end
end

function WoodcutterHut:leave(sleepInsteadOfLeaving)
    if self.worker then
        _G.JobController:add("Woodcutter", self)
        if sleepInsteadOfLeaving then
            self.worker:quitJob()
        else
            self.worker:leaveVillage()
        end
        self.worker = nil
        self.freeSpots = 1
        self.float:activate()
        self.sawingObj:deactivate()
        return true
    end
end

function WoodcutterHut:join(worker)
    self.logStack:deactivate()
    self.stack:deactivate()
    if self.health == -1 then
        _G.JobController:remove("Woodcutter", self)
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
    self:respawnWorker(self.worker, "Go to stockpile")
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
    self.health = data.health
    self.offsetX = data.offsetX
    self.offsetY = data.offsetY
    self.tile = quadArray[tiles + 1]
    self.getNextTree = coroutine.wrap(function()
        local trees = self:findNearestTreesViaFloodfill()
        for i = 1, #trees do
            local obj = trees[i]
            if obj.cuttable and not self.stump and not obj.marked then
                coroutine.yield(obj)
            end
        end
        while true do
            coroutine.yield(false)
        end
    end)
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
    return data
end

function WoodcutterHut.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

return WoodcutterHut
