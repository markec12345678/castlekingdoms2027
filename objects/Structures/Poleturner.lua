local tileQuads = require("objects.object_quads")
local WEAPON = require("objects.Enums.Weapon")
local Structure = require("objects.Structure")
local Object = require("objects.Object")
local anim = require("libraries.anim8")
local NotEnoughWorkersFloat = require("objects.Floats.NotEnoughWorkersFloat")

local _, _, pikeIconButton, spearIconButton = unpack(require("states.ui.workshops.workshops_ui"))

local tiles, quadArray = _G.indexBuildingQuads("poleturner_workshop (18)")
local tilesExt, quadArrayExt = _G.indexBuildingQuads("poleturner_workshop (9)")

local ANIM_CRAFTING_PIKE_PART1 = "Crafting_Pike_part1"
local ANIM_CRAFTING_SPEAR = "Crafting_Spear"
local ANIM_CRAFTING_PIKE = "Crafting_Pike"

local an = {
    [ANIM_CRAFTING_PIKE_PART1] = _G.indexQuads("anim_poleturner", 61),
    [ANIM_CRAFTING_SPEAR] = _G.addReverse(_G.indexQuads("anim_poleturner_3", 33)),
    [ANIM_CRAFTING_PIKE] = _G.addReverse(_G.indexQuads("anim_poleturner_2", 33)),
}

local poleturnerFx = {
    ["spear"] = { _G.fx["pole_turn1"],
        _G.fx["pole_turn2"],
        _G.fx["pole_turn3"] },
    ["halberd"] = { _G.fx["pole_grind2"],
        _G.fx["pole_grind3"],
        _G.fx["pole_grind6"] }
}


local targetPoleturner
local SpearCrafting = _G.class("SpearCrafting", Structure)
function SpearCrafting:initialize(gx, gy, parent)
    self.parent = parent
    Structure.initialize(self, gx, gy, "Spear crafting")
    self.tile = tileQuads["empty"]
    self.animated = false
    self.craftingCycle = 0
    self.animation = anim.newAnimation(an[ANIM_CRAFTING_SPEAR], 0.11, self:craftCallback_1(), ANIM_CRAFTING_SPEAR)
    self.animation:pause()
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.offsetX = -51
    self.offsetY = -77

    self:registerAsActiveEntity()
end

function SpearCrafting:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.animation = self.animation:serialize()
    data.animated = self.animated
    data.nextWeapon = self.nextWeapon
    data.weaponType = self.weaponType
    data.craftingCycle = self.craftingCycle
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    data.parent = _G.state:serializeObject(self.parent)
    return data
end

function SpearCrafting.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.spearCrafting = obj
    local callback
    local anData = data.animation
    if anData.animationIdentifier == ANIM_CRAFTING_SPEAR then
        callback = obj:craftCallback_1()
    elseif anData.animationIdentifier == ANIM_CRAFTING_PIKE_PART1 then
        callback = obj:craftCallback_2()
    end
    obj.animation = _G.anim.newAnimation(an[anData.animationIdentifier], 1, callback, anData.animationIdentifier)
    obj.animation:deserialize(anData)
    if obj.parent.restoreExitPoint then
        obj:findWorkerExitPointAndSendToArmoury()
    end

    return obj
end

function SpearCrafting:animate()
    Structure.animate(self, _G.dt, true)
end

function SpearCrafting:activate()
    self.animated = true
    self.parent:setWeapon(self.parent.nextWeapon)
    if self.parent.weaponType == WEAPON.spear then
        _G.playSfx(self, poleturnerFx["spear"])
        self.animation = anim.newAnimation(an[ANIM_CRAFTING_SPEAR], 0.08, self:craftCallback_1(), ANIM_CRAFTING_SPEAR)
    end
    if self.parent.weaponType == WEAPON.pike then
        self.animation = anim.newAnimation(an[ANIM_CRAFTING_PIKE_PART1], 0.08, self:craftCallback_1(),
            ANIM_CRAFTING_PIKE)
    end
    self:animate()
end

function SpearCrafting:deactivate()
    self.animation:pause()
    self.tile = tileQuads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
        self.instancemesh = nil
    end
    self.animated = false
end

local PoleturnerAlias = _G.class("PoleturnerAlias", Structure)
function PoleturnerAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
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

function PoleturnerAlias:serialize()
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

function PoleturnerAlias.static:deserialize(data)
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

local PoleturnerWorkshop = _G.class("PoleturnerWorkshop", Structure)

PoleturnerWorkshop.static.WIDTH = 4
PoleturnerWorkshop.static.LENGTH = 4
PoleturnerWorkshop.static.HEIGHT = 17
PoleturnerWorkshop.static.DESTRUCTIBLE = true

function PoleturnerWorkshop:initialize(gx, gy)
    _G.JobController:add("Poleturner", self)
    Structure.initialize(self, gx, gy, "PoleturnerWorkshop")
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 200
    self.tile = quadArray[tiles + 1]
    self.working = false
    self.unloading = false
    self.offsetX = 0
    self.offsetY = -44
    self.weaponType = WEAPON.spear
    self.nextWeapon = self.weaponType
    self.freeSpots = 1
    self.worker = nil
    self.spearCrafting = SpearCrafting:new(self.gx + 3, self.gy + 2, self)
    for tile = 1, tiles do
        local hsl = PoleturnerAlias:new(quadArray[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offsetY + 8 * (tiles - tile + 1))
        hsl.tileKey = tile
    end
    for tile = 1, tiles do
        local hsl = PoleturnerAlias:new(quadArray[tiles + 1 + tile], self.gx + tile, self.gy, self,
            -self.offsetY + 8 * tile
            , 16)
        hsl.tileKey = tiles + 1 + tile
    end
    local tileQuads = require("objects.object_quads")
    for xx = 0, PoleturnerWorkshop.static.WIDTH - 1 do
        for yy = 0, PoleturnerWorkshop.static.LENGTH - 1 do
            if not _G.objectFromSubclassAtGlobal(self.gx + xx, self.gy + gy, Structure) then
                PoleturnerAlias:new(tileQuads["empty"], self.gx + xx, self.gy + yy, self, 0, 0)
            end
        end
    end
    self.float = NotEnoughWorkersFloat:new(self.gx + self.class.WIDTH - 1, self.gy + self.class.LENGTH - 1, 7, -112)
    self:applyBuildingHeightMap()
end

function PoleturnerWorkshop:onClick()
    targetPoleturner = self
    pikeIconButton.visible = true
    local x, y = love.mouse.getPosition()
    pikeIconButton:SetPos(x - 50, y + 50)
    spearIconButton.visible = true
    spearIconButton:SetPos(x, y + 50)
end

function SpearCrafting:craftCallback_1()
    return function()
        self.craftingCycle = self.craftingCycle + 1
        if self.parent.weaponType == WEAPON.spear then
            self.animation = anim.newAnimation(an[ANIM_CRAFTING_SPEAR], 0.08, self:craftCallback_1(), ANIM_CRAFTING_SPEAR)
            if self.craftingCycle == 6 then
                self:findWorkerExitPointAndSendToArmoury()
                self.craftingCycle = 0
                self:deactivate()
            else
                _G.playSfx(self, poleturnerFx["spear"])
            end
        end
        if self.parent.weaponType == WEAPON.pike then
            if self.craftingCycle == 1 or self.craftingCycle == 4 then
                _G.playSfx(self, poleturnerFx["halberd"])
            end
            self.animation = anim.newAnimation(an[ANIM_CRAFTING_PIKE], 0.08, self:craftCallback_1(),
                ANIM_CRAFTING_PIKE)
            if self.craftingCycle == 8 then
                self.animation = anim.newAnimation(an[ANIM_CRAFTING_PIKE], 0.08, self:craftCallback_2(),
                    ANIM_CRAFTING_PIKE_PART1)
            end
        end
    end
end

function SpearCrafting:craftCallback_2()
    return function()
        self:findWorkerExitPointAndSendToArmoury()
        self.craftingCycle = 0
        self:deactivate()
    end
end

function SpearCrafting:findWorkerExitPointAndSendToArmoury()
    self.parent:findExitPointTo("Armoury", function(found, path)
        if found then
            self.parent:sendToArmoury()
        else
            print("No path found to armoury!")
        end
    end)
end

function PoleturnerWorkshop:destroy()
    _G.JobController:remove("Poleturner", self)
    self.float:destroy()
    Structure.destroy(self.spearCrafting)
    self.spearCrafting.toBeDeleted = true

    Structure.destroy(self)
    if self.worker then
        self.worker:quitJob()
    end
    spearIconButton.visible = false
    pikeIconButton.visible = false
end

function PoleturnerWorkshop:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    if data.worker then
        self.worker = _G.state:dereferenceObject(data.worker)
        self.worker.workplace = self
    end
    self.tile = quadArray[tiles + 1]
    Structure.render(self)
end

function PoleturnerWorkshop:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.health = self.health
    data.working = self.working
    data.weaponType = self.weaponType
    data.unloading = self.unloading
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    data.freeSpots = self.freeSpots
    if self.worker then
        data.worker = _G.state:serializeObject(self.worker)
    end
    return data
end

function PoleturnerWorkshop.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

function PoleturnerWorkshop:setWeapon(weapon)
    self.weaponType = weapon
end

function PoleturnerWorkshop:getWeapon()
    return self.weaponType
end

spearIconButton.OnClick = function(self)
    if targetPoleturner then
        targetPoleturner.nextWeapon = WEAPON.spear
    end
    spearIconButton.visible = false
    pikeIconButton.visible = false
end

pikeIconButton.OnClick = function(self)
    if targetPoleturner then
        targetPoleturner.nextWeapon = WEAPON.pike
    end
    spearIconButton.visible = false
    pikeIconButton.visible = false
end

function PoleturnerWorkshop:enterHover(induced)
    self.hover = true
    for tile = 1, tiles do
        local alias = _G.objectFromClassAtGlobal(self.gx, self.gy + (tiles - tile + 1), PoleturnerAlias)
        if not alias then return end
        alias.tile = quadArray[tile]
        alias.tileKey = tile
        alias:render()
    end

    for tile = 1, tiles do
        local alias = _G.objectFromClassAtGlobal(self.gx + tile, self.gy, PoleturnerAlias)
        if not alias then return end
        alias.tile = quadArray[tiles + 1 + tile]
        alias.tileKey = tiles + 1 + tile
        alias:render()
    end
    self.tile = quadArray[tiles + 1]
    self:render()
end

function PoleturnerWorkshop:exitHover(induced)
    if induced or not self.spearCrafting.animated then
        self.hover = false
    else
        return
    end
    for tile = 1, tilesExt do
        local alias = _G.objectFromClassAtGlobal(self.gx, self.gy + (tilesExt - tile + 1), PoleturnerAlias)
        if alias then
            alias.tile = quadArrayExt[tile]
            alias.tileKey = tile
            alias:render()
        end
    end

    for tile = 1, tilesExt do
        local alias = _G.objectFromClassAtGlobal(self.gx + tile, self.gy, PoleturnerAlias)
        if alias then
            alias.tile = quadArrayExt[tilesExt + 1 + tile]
            alias.tileKey = tilesExt + 1 + tile
            alias:render()
        end
    end
    self.tile = quadArrayExt[tilesExt + 1]
    self:render()
end

function PoleturnerWorkshop:leave(sleepInsteadOfLeaving)
    if self.worker then
        _G.JobController:add("Poleturner", self)
        if sleepInsteadOfLeaving then
            self.worker:quitJob()
        else
            self.worker:leaveVillage()
        end
        self.worker = nil
        self.freeSpots = 1
        self.float:activate(sleepInsteadOfLeaving)
        self.spearCrafting:deactivate()
        return true
    end
end

function PoleturnerWorkshop:join(worker)
    if self.health == -1 then
        _G.JobController:remove("Poleturner", self)
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

function PoleturnerWorkshop:work(worker)
    if self.worker.state == "Going to workplace with WOOD" then
        self.worker.state = "Working"
        self.working = true
        worker.tile = tileQuads["empty"]
        worker.animated = false
        worker.gx = self.gx + 1
        worker.gy = self.gy + 2
        worker:jobUpdate()
        self.spearCrafting:activate()
    else
        self.worker.state = "Working"
        if not self.working and self.worker.state == "Working" then
            self.worker.state = "Go to stockpile for WOOD"
        end
    end
    if self.worker.state == "Working" then
        self:enterHover(true)
    end
end

function PoleturnerWorkshop:sendToArmoury()
    self:respawnWorker(self.worker, "Go to armoury")
    self.working = false
    self.spearCrafting:deactivate()
    self:exitHover(true)
end

return PoleturnerWorkshop
