local activeEntities, _, tileQuads, _ = ...

local Structure = require("objects.Structure")
local Object = require("objects.Object")
local anim = require("libraries.anim8")
local NotEnoughWorkersFloat = require("objects.Structures.NotEnoughWorkersFloat")
local Cow = require("objects.Units.Cow")

local tiles, quadArray = _G.indexBuildingQuads("farm (4)")

local ANIM_BABYCOW = "Baby_cow"
local ANIM_FERMENT = "Ferment"
local ANIM_COWHEAD = "Cow_head"
local ANIM_MIL = "Mil"
local ANIM_MIL_END = "Mil_end"

local an = {
    [ANIM_BABYCOW] = _G.addReverse(_G.indexQuads("dairy_farm_anim_babycow", 24)),
    [ANIM_FERMENT] = _G.indexQuads("dairy_farm_anim_cheese_ferment", 8),
    [ANIM_COWHEAD] = _G.addReverse(_G.indexQuads("dairy_farm_anim_cowhead", 16)),
    [ANIM_MIL] = (_G.indexQuads("dairy_farm_anim_mil", 12)),
    [ANIM_MIL_END] = (_G.indexQuads("dairy_farm_anim_mil", 31)),
}

local CheeseCrafting = _G.class("CheeseCrafting", Structure)
function CheeseCrafting:initialize(gx, gy, parent)
    self.parent = parent
    Structure.initialize(self, gx, gy, "Cheese crafting")
    self.tile = tileQuads["empty"]
    self.animated = false
    self.craftingCycle = 0
    self.animation = anim.newAnimation(an[ANIM_FERMENT], 0.11, self:craftCallback_1(), ANIM_FERMENT)
    self.animation:pause()
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.offsetX = -51
    self.offsetY = -87

    table.insert(activeEntities, self)
end

function CheeseCrafting:serialize()
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

function CheeseCrafting.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.cookingObj = obj
    local callback
    local anData = data.animation
    if anData.animationIdentifier == ANIM_FERMENT then
        callback = obj:craftCallback_1()
    end
    obj.animation = _G.anim.newAnimation(an[anData.animationIdentifier], 1, callback, anData.animationIdentifier)
    obj.animation:deserialize(anData)
    table.insert(activeEntities, obj)
    return obj
end

function CheeseCrafting:animate()
    Structure.animate(self, _G.dt, true)
end

function CheeseCrafting:activate()
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_FERMENT], 0.11, self:craftCallback_1(), ANIM_FERMENT)
    self:animate(_G.dt)
end

function CheeseCrafting:deactivate()
    self.animation:pause()
    self.tile = tileQuads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
        self.instancemesh = nil
    end
    self.animated = false
    self.craftingCycle = 0
end

local CowMilking = _G.class("CowMilking", Structure)
function CowMilking:initialize(gx, gy, parent)
    self.parent = parent
    Structure.initialize(self, gx, gy, "Cow milking")
    self.tile = tileQuads["empty"]
    self.animated = false
    self.craftingCycle = 0
    self.animation = anim.newAnimation(an[ANIM_COWHEAD], 0.11, self:craftCallback_1(), ANIM_COWHEAD)
    self.animation:pause()
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.offsetX = -51
    self.offsetY = -87

    table.insert(activeEntities, self)
end

function CowMilking:serialize()
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

function CowMilking.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.cowMilking = obj
    local callback
    local anData = data.animation
    if anData.animationIdentifier == ANIM_COWHEAD then
        callback = obj:craftCallback_1()
    end
    obj.animation = _G.anim.newAnimation(an[anData.animationIdentifier], 1, callback, anData.animationIdentifier)
    obj.animation:deserialize(anData)
    table.insert(activeEntities, obj)
    return obj
end

function CowMilking:animate()
    Structure.animate(self, _G.dt, true)
end

function CowMilking:activate()
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_COWHEAD], 0.11, self:craftCallback_1(), ANIM_COWHEAD)
    self:animate(_G.dt)
end

function CowMilking:deactivate()
    self.animation:pause()
    self.tile = tileQuads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
        self.instancemesh = nil
    end
    self.animated = false
    self.craftingCycle = 0
end

local CowMilkingFarmer = _G.class("CowMilkingFarmer", Structure)
function CowMilkingFarmer:initialize(gx, gy, parent)
    self.parent = parent
    Structure.initialize(self, gx, gy, "Cow milking farmer")
    self.tile = tileQuads["empty"]
    self.animated = false
    self.craftingCycle = 0
    self.animation = anim.newAnimation(an[ANIM_MIL], 0.11, self:craftCallback_1(), ANIM_MIL)
    self.animation:pause()
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.offsetX = -51
    self.offsetY = -87

    table.insert(activeEntities, self)
end

function CowMilkingFarmer:serialize()
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

function CowMilkingFarmer.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.cowMilkingFarmer = obj
    local callback
    local anData = data.animation
    if anData.animationIdentifier == ANIM_MIL then
        callback = obj:craftCallback_1()
    end
    obj.animation = _G.anim.newAnimation(an[anData.animationIdentifier], 1, callback, anData.animationIdentifier)
    obj.animation:deserialize(anData)
    table.insert(activeEntities, obj)
    return obj
end

function CowMilkingFarmer:animate()
    Structure.animate(self, _G.dt, true)
end

function CowMilkingFarmer:activate()
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_MIL], 0.11, self:craftCallback_1(), ANIM_MIL)
    self:animate(_G.dt)
end

function CowMilkingFarmer:deactivate()
    self.animation:pause()
    self.tile = tileQuads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
        self.instancemesh = nil
    end
    self.animated = false
    self.craftingCycle = 0
end

local CowBreeding = _G.class("CowBreeding", Structure)
function CowBreeding:initialize(gx, gy, parent)
    self.parent = parent
    Structure.initialize(self, gx, gy, "Cow breeding")
    self.tile = tileQuads["empty"]
    self.animated = false
    self.cowOne = nil
    self.cowTwo = nil
    self.cowThree = nil
    self.craftingCycle = 0
    self.animation = anim.newAnimation(an[ANIM_BABYCOW], 0.11, self:craftCallback_1(), ANIM_BABYCOW)
    self.animation:pause()
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.offsetX = -51
    self.offsetY = -87

    table.insert(activeEntities, self)
end

function CowBreeding:serialize()
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
    if self.cowOne then
        data.cowOne = _G.state:serializeObject(self.cowOne)
    end
    if self.cowTwo then
        data.cowTwo = _G.state:serializeObject(self.cowTwo)
    end
    if self.cowThree then
        data.cowThree = _G.state:serializeObject(self.cowThree)
    end

    data.parent = _G.state:serializeObject(self.parent)
    return data
end

function CowBreeding.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    if data.cowOne then
        obj.cowOne = _G.state:dereferenceObject(data.cowOne)
    end
    if data.cowTwo then
        obj.cowTwo = _G.state:dereferenceObject(data.cowTwo)
    end
    if data.cowThree then
        obj.cowThree = _G.state:dereferenceObject(data.cowThree)
    end
    obj.parent.cowBreed = obj
    local callback
    local anData = data.animation
    if anData.animationIdentifier == ANIM_BABYCOW then
        callback = obj:craftCallback_1()
    end
    obj.animation = _G.anim.newAnimation(an[anData.animationIdentifier], 1, callback, anData.animationIdentifier)
    obj.animation:deserialize(anData)
    table.insert(activeEntities, obj)
    return obj
end

function CowBreeding:animate()
    Structure.animate(self, _G.dt, true)
end

function CowBreeding:activate()
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_BABYCOW], 0.11, self:craftCallback_1(), ANIM_BABYCOW)
    self:animate(_G.dt)
end

function CowBreeding:deactivate()
    self.animation:pause()
    self.tile = tileQuads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
        self.instancemesh = nil
    end
    self.animated = false
    self.craftingCycle = 0
end

local DairyFarmAlias = _G.class("DairyFarmAlias", Structure)
function DairyFarmAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
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

function DairyFarmAlias:serialize()
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
    data.freeSpots = self.freeSpots
    if self.dairyWorker then
        data.dairyWorker = _G.state:serializeObject(self.dairyWorker)
    end
    return data
end

function DairyFarmAlias.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    if data.dairyWorker then
        self.dairyWorker = _G.state:dereferenceObject(data.dairyWorker)
        self.dairyWorker.workplace = self
    end
    obj.parent = _G.state:dereferenceObject(data.parent)
    if data.tileKey then
        if type(data.tileKey) == "number" then
            obj.tile = quadArray[data.tileKey]
            obj.tileKey = data.tileKey
        elseif type(data.tileKey) == "string" then
            obj.tile = tileQuads[data.tileKey]
            obj.tileKey = data.tileKey
        end
        obj:render()
    end
    return obj
end

local tileQuads = require("objects.object_quads")
local DairyFarm = _G.class("DairyFarm", Structure)

DairyFarm.static.WIDTH = 3
DairyFarm.static.LENGTH = 3
DairyFarm.static.HEIGHT = 17
DairyFarm.static.DESTRUCTIBLE = true
DairyFarm.static.HOVERTEXT = "Click to recruit units"
function DairyFarm:initialize(gx, gy)
    _G.JobController:add("DairyFarmer", self)
    Structure.initialize(self, gx, gy, "DairyFarm")
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 200
    self.tile = quadArray[tiles + 1]
    self.working = false
    self.unloading = false
    self.cowCounter = 0
    self.offsetX = 0
    self.offsetY = -48 - 6
    self.freeSpots = 1
    self.worker = nil
    self.cookingObj = CheeseCrafting:new(self.gx + 3, self.gy + 2, self)
    self.cowMilking = CowMilking:new(self.gx + 3, self.gy + 2, self)
    self.cowMilkingFarmer = CowMilkingFarmer:new(self.gx + 3, self.gy + 2, self)
    self.cowBreed = CowBreeding:new(self.gx + 3, self.gy + 2, self)
    for tile = 1, tiles do
        local hsl = DairyFarmAlias:new(quadArray[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offsetY + 8 * (tiles - tile + 1))
        hsl.tileKey = tile
    end
    for tile = 1, tiles do
        local hsl = DairyFarmAlias:new(quadArray[tiles + 1 + tile], self.gx + tile, self.gy, self,
            -self.offsetY + 8 * tile
            , 16)
        hsl.tileKey = tiles + 1 + tile
    end
    for xx = 0, DairyFarm.static.WIDTH - 1 do
        for yy = 0, DairyFarm.static.WIDTH - 1 do
            if not _G.objectFromSubclassAtGlobal(self.gx + xx, self.gy + gy, Structure) then
                DairyFarmAlias:new(tileQuads["empty"], self.gx + xx, self.gy + yy, self, 0, 0)
            end
        end
    end

    --top fence
    for xx = 3, 8 do
        for yy = 0, 0 do
            if not _G.objectFromSubclassAtGlobal(self.gx + xx, self.gy + gy, Structure) then
                if xx == 4 or xx == 5 then
                    _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrainBiome.scarceGrass)
                else
                    local alias = DairyFarmAlias:new(tileQuads["tile_farmland_fence (1)"], self.gx + xx, self.gy + yy,
                        self, -self.offsetY - 4 * 8)
                    alias.tileKey = "tile_farmland_fence (1)"
                end
            end
        end
    end
    --bottom fence
    for xx = 1, 8 do
        for yy = 9, 9 do
            if not _G.objectFromSubclassAtGlobal(self.gx + xx, self.gy + gy, Structure) then
                if xx == 4 or xx == 5 then
                    _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrainBiome.scarceGrass)
                else
                    local alias = DairyFarmAlias:new(tileQuads["tile_farmland_fence (1)"], self.gx + xx, self.gy + yy,
                        self, -self.offsetY - 4 * 8)
                    alias.tileKey = "tile_farmland_fence (1)"
                end
            end
        end
    end
    -- left fence
    for xx = 0, 0 do
        for yy = 3, 8 do
            if not _G.objectFromSubclassAtGlobal(self.gx + xx, self.gy + gy, Structure) then
                if yy == 4 or yy == 5 then
                    _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrainBiome.scarceGrass)
                else
                    local alias = DairyFarmAlias:new(tileQuads["tile_farmland_fence (2)"], self.gx + xx, self.gy + yy,
                        self, -self.offsetY - 4 * 8)
                    alias.tileKey = "tile_farmland_fence (2)"
                end
            end
        end
    end
    --right fence
    for xx = 9, 9 do
        for yy = 1, 8 do
            if not _G.objectFromSubclassAtGlobal(self.gx + xx, self.gy + gy, Structure) then
                if yy == 4 or yy == 5 then
                    _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrainBiome.scarceGrass)
                else
                    local alias = DairyFarmAlias:new(tileQuads["tile_farmland_fence (2)"], self.gx + xx, self.gy + yy,
                        self, -self.offsetY - 4 * 8)
                    alias.tileKey = "tile_farmland_fence (2)"
                end
            end
        end
    end
    --right top corner
    local alias = DairyFarmAlias:new(tileQuads["tile_farmland_fence (3)"], self.gx + 9, self.gy + 0,
        self, -self.offsetY - 4 * 8)
    alias.tileKey = "tile_farmland_fence (3)"
    --bottom corner
    alias = DairyFarmAlias:new(tileQuads["tile_farmland_fence (4)"], self.gx + 9, self.gy + 9,
        self, -self.offsetY - 4 * 8)
    alias.tileKey = "tile_farmland_fence (4)"
    --bottom left corner
    alias = DairyFarmAlias:new(tileQuads["tile_farmland_fence (5)"], self.gx + 0, self.gy + 9,
        self, -self.offsetY - 4 * 8)
    alias.tileKey = "tile_farmland_fence (5)"

    for xx = -1, 9 do
        for yy = -1, 9 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrainBiome.scarceGrass)
        end
    end
    self.float = NotEnoughWorkersFloat:new(self.gx + self.class.WIDTH - 1, self.gy + self.class.LENGTH - 1, 7, -112)
    self:applyBuildingHeightMap()
end

function CowMilking:craftCallback_1()
    return function()
        self.craftingCycle = self.craftingCycle + 1
        if self.parent.cowCounter == 3 then
            self.animation = anim.newAnimation(an[ANIM_COWHEAD], 0.11, self:craftCallback_1(), ANIM_COWHEAD)
            if self.craftingCycle == 3 then
                self.craftingCycle = 0
                self:deactivate()
            end
        end
    end
end

function CowMilkingFarmer:craftCallback_1()
    return function()
        self.craftingCycle = self.craftingCycle + 1
        if self.parent.cowCounter == 3 then
            self.animation = anim.newAnimation(an[ANIM_MIL], 0.11, self:craftCallback_1(), ANIM_MIL)
            if self.craftingCycle == 4 then
                self.animation = anim.newAnimation(an[ANIM_MIL_END], 0.11, self:craftCallback_1(), ANIM_MIL_END)
            end
            if self.craftingCycle == 5 then
                self.craftingCycle = 0
                self:deactivate()
                self.parent.cowMilking:deactivate()
                self.parent.cookingObj:activate()
            end
        end
    end
end

function CheeseCrafting:craftCallback_1()
    return function()
        self.parent:sendToStockpile()
        self:deactivate()
    end
end

function CowBreeding:craftCallback_1()
    return function()
        self.craftingCycle = self.craftingCycle + 1
        if self.parent.cowCounter ~= 3 then
            self.animation = anim.newAnimation(an[ANIM_BABYCOW], 0.11, self:craftCallback_1(), ANIM_BABYCOW)
            if self.craftingCycle == 3 then
                if self.parent.cowCounter == 0 then
                    self.cowOne = Cow:new(self.parent.gx + 5, self.parent.gy + 3)
                elseif self.parent.cowCounter == 1 then
                    self.cowTwo = Cow:new(self.parent.gx + 2, self.parent.gy + 5)
                elseif self.parent.cowCounter == 2 then
                    self.cowThree = Cow:new(self.parent.gx + 5, self.parent.gy + 5)
                end
                self.parent.cowCounter = self.parent.cowCounter + 1
                self.craftingCycle = 0
            end
        end
        if self.parent.cowCounter == 3 then
            self.craftingCycle = 0
            self:deactivate()
            self.parent.cowMilking:activate()
            self.parent.cowMilkingFarmer:activate()
        end
    end
end

function DairyFarm:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    if data.worker then
        self.worker = _G.state:dereferenceObject(data.worker)
        self.worker.workplace = self
    end
    self.tile = quadArray[tiles + 1]

    Structure.render(self)
end

function DairyFarm:serialize()
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
    data.cowCounter = self.cowCounter
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    data.freeSpots = self.freeSpots
    if self.worker then
        data.worker = _G.state:serializeObject(self.worker)
    end
    return data
end

function DairyFarm.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

function DairyFarm:join(worker)
    if self.health == -1 then
        _G.JobController:remove("DairyFarmer", self)
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

function DairyFarm:work(worker)
    if worker.state == "Going to workplace" and self.cowCounter ~= 3 then
        worker.state = "Waiting"
        self.cowBreed:activate()
    elseif self.cowCounter == 3 then
        worker.state = "Working"
        self.working = true
        worker:jobUpdate()
        worker.gx = self.gx + 1
        worker.gy = self.gy + 2
        self.cowMilking:activate()
        self.cowMilkingFarmer:activate()
    elseif not self.working and worker.state == "Working" then
        worker.state = "Go to foodpile"
    end
end

function DairyFarm:sendToStockpile()
    local i, o, cx, cy
    self.worker.state = "Go to foodpile"
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
    self.cowBreed:deactivate()
    self.cookingObj:deactivate()
    self.cowMilking:deactivate()
    self.cowMilkingFarmer:deactivate()
end

function DairyFarm:destroy()
    if self.worker then
        self.worker:quitJob()
    end
    self.float:destroy()
    Structure.destroy(self.cookingObj)
    self.cookingObj.toBeDeleted = true
    Structure.destroy(self.cowMilking)
    self.cowMilking.toBeDeleted = true
    Structure.destroy(self.cowMilkingFarmer)
    self.cowMilkingFarmer.toBeDeleted = true
    Structure.destroy(self.cowBreed)
    self.cowBreed.toBeDeleted = true

    if (self.cowBreed.cowOne) then
        self.cowBreed.cowOne:die()
    end
    if (self.cowBreed.cowTwo) then
        self.cowBreed.cowTwo:die()
    end
    if (self.cowBreed.cowThree) then
        self.cowBreed.cowThree:die()
    end

    for xx = -1, 9 do
        for yy = -1, 9 do
            local tile = _G.objectFromClassAtGlobal(self.gx + xx, self.gy + yy, "DairyFarmAlias")
            if tile then
                tile.state = -1
                Structure.destroy(tile)
                tile.toBeDeleted = true
                _G.state.map:setWalkable(self.gx + xx, self.gy + yy, 0)
            end
        end
    end
    Structure.destroy(self)
end

return DairyFarm
