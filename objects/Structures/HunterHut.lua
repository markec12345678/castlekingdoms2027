local tileQuads = require("objects.object_quads")
local Structure = require("objects.Structure")
local Object = require("objects.Object")
local anim = require("libraries.anim8")
local NotEnoughWorkersFloat = require("objects.Floats.NotEnoughWorkersFloat")

local tiles, quadArray = _G.indexBuildingQuads("hunter_hut", true)

local ANIM_HUNTER_STAB = "Hunter_Stab"
local ANIM_HUNTER_CUT = "Hunter_Cut"
local ANIM_STACK_MEAT = "Crafting_Meat"

local an = {
    [ANIM_HUNTER_STAB] = _G.indexQuads("anim_hunter", 5, 1),
    [ANIM_HUNTER_CUT] = _G.indexQuads("anim_hunter", 19, 6),
    [ANIM_STACK_MEAT] = _G.addOther({tileQuads["empty"]}, _G.indexQuads("anim_hunter_meat", 6)), --empty quad added as a delay
}

local CUT_FRAMETIME = 0.17
local STAB_FRAMETIME = 0.05
local MEAT_STACK_FRAMETIME = 2.63 -- The length of cut and stab animations added together

local hunterHutFx = {
    ["cut"] = { _G.fx["huntercut_01"], _G.fx["huntercut_02"], _G.fx["huntercut_03"]}
}

local HunterHutCrafting = _G.class("HunterHutCrafting", Structure)
function HunterHutCrafting:initialize(gx, gy, parent)
    local mytype = "Animation"
    self.parent = parent
    Structure.initialize(self, gx, gy, mytype)
    self.tile = tileQuads["empty"]
    self.animated = false
    self.animation = anim.newAnimation(an[ANIM_HUNTER_CUT], CUT_FRAMETIME, function() self:cutCallback() end, ANIM_HUNTER_CUT)
    self.animation:pause()
    self.offsetX = -35
    self.offsetY = -44
    self.numberOfCuts = 0

    self:registerAsActiveEntity()
end

function HunterHutCrafting:animate()
    Structure.animate(self, _G.dt, true)
end

function HunterHutCrafting:activate()
    self.animation = anim.newAnimation(an[ANIM_HUNTER_STAB], STAB_FRAMETIME, function() self:stabCallback() end, ANIM_HUNTER_STAB)
    self.animated = true
    self.animation:gotoFrame(1)
    self.animation:resume()
    self:animate(_G.dt)
end

function HunterHutCrafting:deactivate()
    self.animation:pause()
    self.tile = tileQuads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
        self.instancemesh = nil
    end
    self.animated = false
end

function HunterHutCrafting:serialize()
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
    data.numberOfCuts = self.numberOfCuts
    return data
end

function HunterHutCrafting:stabCallback()
    _G.playSfx(self, hunterHutFx["cut"])
    self.animation = anim.newAnimation(an[ANIM_HUNTER_CUT], CUT_FRAMETIME, function() self:cutCallback() end, ANIM_HUNTER_CUT)
end

function HunterHutCrafting:cutCallback()
    self.numberOfCuts = self.numberOfCuts + 1
    if self.numberOfCuts >= 6 then
        self.numberOfCuts = 0
        self:findWorkerExitPointAndSendToFoodpile()
        self:deactivate()
    else
        self.animation = anim.newAnimation(an[ANIM_HUNTER_STAB], STAB_FRAMETIME, function() self:stabCallback() end, ANIM_HUNTER_STAB)
    end
end

function HunterHutCrafting:findWorkerExitPointAndSendToFoodpile()
    self.parent:findExitPointTo("Granary", function(found, path)
        if found then
            self.parent:sendToFoodpile()
        else
            print("No path found to foodpile!")
        end
    end)
end

function HunterHutCrafting.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.numberOfCuts = data.numberOfCuts
    local anData = data.animation
    local frameTime = 1
    local callback = nil
    if string.find(anData.animationIdentifier, "Cut") then
        local frameTime = CUT_FRAMETIME 
        callback = function() obj:cutCallback() end
    elseif string.find(anData.animationIdentifier, "Stab") then
        local frameTime = STAB_FRAMETIME
        callback = function() obj:stabCallback() end
    end
    obj.animation = anim.newAnimation(an[anData.animationIdentifier], frameTime, callback, anData.animationIdentifier)
    obj.animation:deserialize(anData)
    return obj
end

local HunterHutMeatStack = _G.class("HunterHutMeatStack", Structure)
function HunterHutMeatStack:initialize(gx, gy, parent)
    local mytype = "Animation"
    self.parent = parent
    Structure.initialize(self, gx, gy, mytype)
    self.tile = tileQuads["empty"]
    self.animated = false
    self.animation = anim.newAnimation(an[ANIM_STACK_MEAT], MEAT_STACK_FRAMETIME, nil, ANIM_STACK_MEAT)
    self.animation:pause()
    self.offsetX = -35
    self.offsetY = -60

    self:registerAsActiveEntity()
end

function HunterHutMeatStack:animate()
    Structure.animate(self, _G.dt, true)
end

function HunterHutMeatStack:activate()
    self.animation = anim.newAnimation(an[ANIM_STACK_MEAT], MEAT_STACK_FRAMETIME, nil, ANIM_STACK_MEAT)
    self.animated = true
    self.animation:gotoFrame(1)
    self.animation:resume()
    self:animate(_G.dt)
end

function HunterHutMeatStack:deactivate()
    self.animation:pause()
    self.tile = tileQuads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
        self.instancemesh = nil
    end
    self.animated = false
end

function HunterHutMeatStack:serialize()
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

function HunterHutMeatStack.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    local anData = data.animation
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.meatStackObj = obj
    obj.animation = anim.newAnimation(an[anData.animationIdentifier], MEAT_STACK_FRAMETIME, nil, anData.animationIdentifier)
    obj.animation:deserialize(anData)
    return obj
end


local HunterHutAlias = _G.class("HunterHutAlias", Structure)
function HunterHutAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
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

function HunterHutAlias:serialize()
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

function HunterHutAlias.static:deserialize(data)
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

local HunterHut = _G.class("HunterHut", Structure)

HunterHut.static.WIDTH = 3
HunterHut.static.LENGTH = 3
HunterHut.static.HEIGHT = 14
HunterHut.static.ALIAS_NAME = "HunterHutAlias"
HunterHut.static.DESTRUCTIBLE = true

function HunterHut:initialize(gx, gy)
    _G.JobController:add("Hunter", self)
    Structure.initialize(self, gx, gy, "Hunter hut")
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    _G.state.firstHunterHut = false
    self.health = 400
    self.tile = quadArray[tiles + 1]
    self.working = false
    self.unloading = false
    self.offsetX = 0
    self.offsetY = -37
    self.freeSpots = 1
    self.worker = nil

    self.craftingObj = HunterHutCrafting:new(self.gx, self.gy, self)
    self.meatStackObj = HunterHutMeatStack:new(self.gx + 1, self.gy + 1, self)

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
        local wht = HunterHutAlias:new(
            quadArray[tile], self.gx, self.gy + (tiles - tile + 1), self, -self.offsetY + 8 * (tiles - tile + 1))
        wht.tileKey = tile
    end
    for tile = 1, tiles do
        local wht = HunterHutAlias:new(
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

    for xx = 1, self.class.WIDTH - 1 do
        for yy = 1, self.class.LENGTH - 1 do
            HunterHutAlias:new(tileQuads["empty"], self.gx + xx, self.gy + yy, self, self.offsetX, self.offsetY)
        end
    end

    self.float = NotEnoughWorkersFloat:new(self.gx, self.gy, 8, -64)
    Structure.render(self)
end

function HunterHut:destroy()
    self.float:destroy()
    Structure.destroy(self.craftingObj)
    Structure.destroy(self.meatStackObj)
    self.craftingObj.toBeDeleted = true
    self.meatStackObj.toBeDeleted = true

    _G.JobController:remove("Hunter", self)
    Structure.destroy(self)

    if self.worker then
        self.worker:quitJob()
    end
end

function HunterHut:leave(sleepInsteadOfLeaving)
    if self.worker then
        _G.JobController:add("Hunter", self)
        if sleepInsteadOfLeaving then
            self.worker:quitJob()
        else
            self.worker:leaveVillage()
        end
        self.worker = nil
        self.freeSpots = 1
        self.float:activate(sleepInsteadOfLeaving)
        self.craftingObj:deactivate()
        self.meatStackObj:deactivate()
        return true
    end
end

function HunterHut:join(worker)
    if self.health == -1 then
        _G.JobController:remove("Hunter", self)
        worker:die()
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

function HunterHut:work(worker)
    worker.state = "Working"
    worker.tile = tileQuads["empty"]
    worker.animated = false
    worker.gx = self.gx + 1
    worker.gy = self.gy + 2
    worker:jobUpdate()

    if not self.working and self.worker.state == "Working" then
        self.working = true
        self.craftingObj:activate()
        self.meatStackObj:activate()
    end
end

function HunterHut:sendToFoodpile()
    self:respawnWorker(self.worker, "Go to foodpile")
    self.meatStackObj:deactivate()
    self.working = false
end

function HunterHut:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    if data.worker then
        self.worker = _G.state:dereferenceObject(data.worker)
        self.worker.workplace = self
    end
    self.craftingObj = _G.state:dereferenceObject(data.craftingObj)
    self.craftingObj.parent = self
    --Meatstack loads later, so it derefrences parent
    if self.restoreExitPoint then
        craftingObj:findWorkerExitPointAndSendToFoodpile()
    end
    self.health = data.health
    self.offsetX = data.offsetX
    self.offsetY = data.offsetY
    self.tile = quadArray[tiles + 1]
    Structure.render(self)
end

function HunterHut:serialize()
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
    data.craftingObj = _G.state:serializeObject(self.craftingObj)
    --Meatstack loads later, so it serializes parent
    return data
end

function HunterHut.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

return HunterHut
