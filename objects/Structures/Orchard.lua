local _, _, _ = ...

local Structure = require("objects.Structure")
local Object = require("objects.Object")
local anim = require("libraries.anim8")
local tileQuads = require("objects.object_quads")
local NotEnoughWorkersFloat = require("objects.Structures.NotEnoughWorkersFloat")

local class = _G.class

local tiles, quadArray = _G.indexBuildingQuads("farm (3)")
local treeRaw = _G.indexQuads("tree_apple", 25, nil, true)
local treeApple = _G.indexQuads("tree_apple_apple", 25, nil, true)

local TREE_EMPTY = "Tree empty"
local TREE_APPLES = "Tree with apples"

local an = {
    [TREE_EMPTY] = treeRaw,
    [TREE_APPLES] = treeApple
}

local OrchardAlias = class("OrchardAlias", Structure)
function OrchardAlias:initialize(tile, gx, gy, parent, offsetY, offsetX, unwalkable)
    local mytype = "Static structure"
    self.parent = parent
    Structure.initialize(self, gx, gy, mytype)
    if unwalkable then
        _G.state.map:setWalkable(self.gx, self.gy, 1)
    end
    self.tile = tile
    self.baseOffsetY = offsetY or 0
    self.additionalOffsetY = 0
    self.offsetX = offsetX or 0
    self.offsetY = self.additionalOffsetY - self.baseOffsetY
    Structure.render(self)
end

function OrchardAlias:serialize()
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

function OrchardAlias.static:deserialize(data)
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

local OrchardTree = class("OrchardTree", Structure)
function OrchardTree:initialize(gx, gy, parent, offsetY, offsetX)
    local mytype = "Static structure"
    self.parent = parent
    Structure.initialize(self, gx, gy, mytype)
    self.animated = true
    self.animRaw = anim.newAnimation(an[TREE_EMPTY], 0.10, nil, TREE_EMPTY)
    self.animFull = anim.newAnimation(an[TREE_APPLES], 0.10, nil, TREE_APPLES)
    self.animation = self.animFull
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.baseOffsetY = offsetY or 0
    self.additionalOffsetY = 0
    self.offsetX = offsetX or 0
    self.offsetY = self.additionalOffsetY - self.baseOffsetY
    for xx = -1, 1 do
        for yy = -1, 1 do
            if not ((xx == -1 and yy == -1) or (xx == 1 and yy == 1) or (xx == -1 and yy == 1) or (xx == 1 and yy == -1)) then
                local ccx, ccy, xxx, yyy = _G.getLocalCoordinatesFromGlobal(self.gx + xx, self.gy + yy)
                if xx == 0 and yy == 0 then
                    _G.buildingheightmap[ccx][ccy][xxx][yyy] = 17
                else
                    _G.buildingheightmap[ccx][ccy][xxx][yyy] = 14
                end
            end
        end
    end
    if _G.state.chunkObjects[self.cx][self.cy] == nil then
        _G.state.chunkObjects[self.cx][self.cy] = {}
    end
    _G.state.chunkObjects[self.cx][self.cy][self] = self
    self:shadeFromTerrainSingleTile()
end

function OrchardTree:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.animation = self.animation:serialize()
    data.animRaw = self.animRaw:serialize()
    data.animFull = self.animFull:serialize()
    data.baseOffsetY = self.baseOffsetY
    data.additionalOffsetY = self.additionalOffsetY
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    data.animated = self.animated
    return data
end

function OrchardTree.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    local an1 = data.animRaw
    local an2 = data.animFull
    local an3 = data.animation
    obj.animRaw = _G.anim.newAnimation(an[an1.animationIdentifier], 1, nil, an1.animationIdentifier)
    obj.animRaw:deserialize(an1)
    obj.animFull = _G.anim.newAnimation(an[an2.animationIdentifier], 1, nil, an2.animationIdentifier)
    obj.animFull:deserialize(an2)
    if an3.animationIdentifier == an2.animationIdentifier then
        obj.animation = obj.animFull
    elseif an3.animationIdentifier == an1.animationIdentifier then
        obj.animation = obj.animRaw
    else
        error("Unknown animation for orchard tree: " .. tostring(an3.animationIdentifier))
    end
    if _G.state.chunkObjects[obj.cx][obj.cy] == nil then
        _G.state.chunkObjects[obj.cx][obj.cy] = {}
    end
    _G.state.chunkObjects[obj.cx][obj.cy][obj] = obj
    return obj
end

local Orchard               = class("Orchard", Structure)
Orchard.static.WIDTH        = 12
Orchard.static.LENGTH       = 12
Orchard.static.HEIGHT       = 19
Orchard.static.ALIAS_NAME   = "OrchardAlias"
Orchard.static.DESTRUCTIBLE = true
function Orchard:initialize(gx, gy, type)
    _G.JobController:add("OrchardFarmer", self)
    type = type or "Orchard"
    Structure.initialize(self, gx, gy, type)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 400
    self.tile = quadArray[tiles + 1]
    self.working = false
    self.offsetX = 0
    self.offsetY = -48 - 6

    self.state = 0
    for xx = -1, 13 do
        for yy = -1, 13 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrainBiome.dirt)
        end
    end

    for xx = 0, 2 do
        for yy = 0, 2 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrainBiome.none)
            _G.state.map:setWalkable(self.gx + xx, self.gy + yy, 1)
        end
    end

    for tile = 1, tiles do
        local ora = OrchardAlias:new(quadArray[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offsetY + 8 * (tiles - tile + 1), nil, true)
        ora.tileKey = tile
    end

    for tile = 1, tiles do
        local ora = OrchardAlias:new(quadArray[tiles + 1 + tile], self.gx + tile, self.gy, self,
            -self.offsetY + 8 * tile, 14, true)
        ora.tileKey = tiles + 1 + tile
    end

    for tile = 1, tiles do
        if not _G.objectFromClassAtGlobal(self.gx + tile - 1, self.gy + 2, OrchardAlias) then
            local ora = OrchardAlias:new(quadArray[tile], self.gx + tile - 1, self.gy + 2, self,
                self.offsetY - 8 - 8 * tile)
            ora.tileKey = tile
        end
    end

    for tile = 1, tiles do
        if not _G.objectFromClassAtGlobal(self.gx + 2, self.gy - tile + 2, OrchardAlias) then
            local ora = OrchardAlias:new(quadArray[tiles + 1 + tile], self.gx + 2, self.gy - tile + 2, self,
                self.offsetY - 8 - 8 * (tiles - tile + 1), 16)
            ora.tileKey = tiles + 1 + tile
        end
    end
    local offsetX, offsetY = -64 - 8, 116
    self.tree1 = OrchardTree:new(self.gx + 1, self.gy + 6, self, offsetY, offsetX)
    self.tree2 = OrchardTree:new(self.gx + 1, self.gy + 11, self, offsetY, offsetX)

    self.tree3 = OrchardTree:new(self.gx + 6, self.gy + 1, self, offsetY, offsetX)
    self.tree4 = OrchardTree:new(self.gx + 6, self.gy + 6, self, offsetY, offsetX)
    self.tree5 = OrchardTree:new(self.gx + 6, self.gy + 11, self, offsetY, offsetX)

    self.tree6 = OrchardTree:new(self.gx + 11, self.gy + 1, self, offsetY, offsetX)
    self.tree7 = OrchardTree:new(self.gx + 11, self.gy + 6, self, offsetY, offsetX)
    self.tree8 = OrchardTree:new(self.gx + 11, self.gy + 11, self, offsetY, offsetX)

    for xx = 0, 2 do
        for yy = 0, 2 do
            local ccx, ccy, xxx, yyy = _G.getLocalCoordinatesFromGlobal(self.gx + xx, self.gy + yy)
            _G.buildingheightmap[ccx][ccy][xxx][yyy] = 15
        end
    end

    for xx = 0, 11 do
        for yy = 0, 11 do
            if not _G.objectFromSubclassAtGlobal(self.gx + xx, self.gy + gy, Structure) then
                OrchardAlias:new(tileQuads["empty"], self.gx + xx, self.gy + yy, self)
            end
        end
    end

    self.freeSpots = 1
    Structure.render(self)

    self.float = NotEnoughWorkersFloat:new(self.gx + self.class.WIDTH - 1, self.gy + self.class.LENGTH - 1, 2, -260)
end

function Orchard:destroy()
    if self.appleWorker then
        self.appleWorker:die()
    end
    self.float:destroy()
    Structure.destroy(self.tree1)
    self.tree1.toBeDeleted = true
    Structure.destroy(self.tree2)
    self.tree2.toBeDeleted = true
    Structure.destroy(self.tree3)
    self.tree3.toBeDeleted = true
    Structure.destroy(self.tree4)
    self.tree4.toBeDeleted = true
    Structure.destroy(self.tree5)
    self.tree5.toBeDeleted = true
    Structure.destroy(self.tree6)
    self.tree6.toBeDeleted = true
    Structure.destroy(self.tree7)
    self.tree7.toBeDeleted = true
    Structure.destroy(self.tree8)
    self.tree8.toBeDeleted = true

    for xx = 0, 11 do
        for yy = 0, 11 do
            _G.removeObjectFromClassAtGlobal(self.gx + xx, self.gy + yy, "OrchardAlias")
        end
    end

    _G.stockpile:store("wood")
    _G.stockpile:store("wood")
end

function Orchard:serialize()
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
    data.state = self.state
    data.working = self.working
    data.freeSpots = self.freeSpots
    if self.appleWorker then
        data.appleWorker = _G.state:serializeObject(self.appleWorker)
    end
    data.tree1 = _G.state:serializeObject(self.tree1)
    data.tree2 = _G.state:serializeObject(self.tree2)

    data.tree3 = _G.state:serializeObject(self.tree3)
    data.tree4 = _G.state:serializeObject(self.tree4)
    data.tree5 = _G.state:serializeObject(self.tree5)

    data.tree6 = _G.state:serializeObject(self.tree6)
    data.tree7 = _G.state:serializeObject(self.tree7)
    data.tree8 = _G.state:serializeObject(self.tree8)
    return data
end

function Orchard.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.tile = quadArray[tiles + 1]
    if data.appleWorker then
        obj.appleWorker = _G.state:dereferenceObject(data.appleWorker)
        obj.appleWorker.workplace = obj
    end
    obj.tree1 = _G.state:dereferenceObject(data.tree1)
    obj.tree1.parent = self
    obj.tree2 = _G.state:dereferenceObject(data.tree2)
    obj.tree2.parent = self
    obj.tree3 = _G.state:dereferenceObject(data.tree3)
    obj.tree3.parent = self
    obj.tree4 = _G.state:dereferenceObject(data.tree4)
    obj.tree4.parent = self
    obj.tree5 = _G.state:dereferenceObject(data.tree5)
    obj.tree5.parent = self
    obj.tree6 = _G.state:dereferenceObject(data.tree6)
    obj.tree6.parent = self
    obj.tree7 = _G.state:dereferenceObject(data.tree7)
    obj.tree7.parent = self
    obj.tree8 = _G.state:dereferenceObject(data.tree8)
    obj.tree8.parent = self
    Structure.render(obj)
    return obj
end

function Orchard:join(worker)
    if self.health == -1 then
        _G.JobController:remove("OrchardFarmer", self)
        worker:die()
        return
    end
    if self.freeSpots == 1 then
        self.appleWorker = worker
        worker.workplace = self
        self.freeSpots = self.freeSpots - 1
    end
    if self.freeSpots == 0 then
        self.float:deactivate()
    end
end

function Orchard:work(worker)
    if self.appleWorker == worker then
        self.appleWorker.state = "Working"
        if self.state == 0 then
            self.tree1.animation = self.tree1.animFull
            self.tree2.animation = self.tree2.animFull
            self.tree3.animation = self.tree3.animFull
            self.tree4.animation = self.tree4.animFull
            self.tree5.animation = self.tree5.animFull
            self.tree6.animation = self.tree6.animFull
            self.tree7.animation = self.tree7.animFull
            self.tree8.animation = self.tree8.animFull
            self.appleWorker:clearPath()
            self.appleWorker:requestPath(self.gx + 1, self.gy + 7)
            self.appleWorker.state = "Going to apple tree"
            self.state = 1
        elseif self.state == 1 then
            self.tree1.animation = self.tree1.animRaw
            self.appleWorker:clearPath()
            self.appleWorker:requestPath(self.gx + 1, self.gy + 12)
            self.appleWorker.state = "Going to apple tree"
            self.state = 2
        elseif self.state == 2 then
            self.tree2.animation = self.tree2.animRaw
            self.appleWorker:clearPath()
            self.appleWorker:requestPath(self.gx + 6, self.gy + 12)
            self.appleWorker.state = "Going to apple tree"
            self.state = 3
        elseif self.state == 3 then
            self.tree5.animation = self.tree5.animRaw
            self.appleWorker:clearPath()
            self.appleWorker:requestPath(self.gx + 6, self.gy + 7)
            self.appleWorker.state = "Going to apple tree"
            self.state = 4
        elseif self.state == 4 then
            self.tree4.animation = self.tree4.animRaw
            self.appleWorker:clearPath()
            self.appleWorker:requestPath(self.gx + 6, self.gy + 2)
            self.appleWorker.state = "Going to apple tree"
            self.state = 5
        elseif self.state == 5 then
            self.tree3.animation = self.tree3.animRaw
            self.appleWorker:clearPath()
            self.appleWorker:requestPath(self.gx + 11, self.gy + 2)
            self.appleWorker.state = "Going to apple tree"
            self.state = 6
        elseif self.state == 6 then
            self.tree6.animation = self.tree6.animRaw
            self.appleWorker:clearPath()
            self.appleWorker:requestPath(self.gx + 11, self.gy + 7)
            self.appleWorker.state = "Going to apple tree"
            self.state = 7
        elseif self.state == 7 then
            self.tree7.animation = self.tree7.animRaw
            self.appleWorker:clearPath()
            self.appleWorker:requestPath(self.gx + 11, self.gy + 12)
            self.appleWorker.state = "Going to apple tree"
            self.state = 8
        elseif self.state == 8 then
            self.tree8.animation = self.tree8.animRaw
            self:sendToStockpile()
            self.state = 0
        end

    end
end

function Orchard:sendToStockpile()
    self.appleWorker.state = "Go to foodpile"
    self.appleWorker:clearPath()
    self.working = false
end

return Orchard
