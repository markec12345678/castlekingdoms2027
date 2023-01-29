local activeEntities, _, tileQuads, _ = ...

local WEAPON = require("objects.Enums.Weapon")

local Structure = require("objects.Structure")
local Object = require("objects.Object")
local anim = require("libraries.anim8")
local NotEnoughWorkersFloat = require("objects.Structures.NotEnoughWorkersFloat")

local _, _, _, _, swordIconButton, maceIconButton = unpack(require("states.ui.workshops.workshops_ui"))

local tiles, quadArray = _G.indexBuildingQuads("blacksmith_workshop (18)")
local tilesExt, quadArrayExt = _G.indexBuildingQuads("blacksmith_workshop (9)")

local ANIM_CRAFTING_SWORD = "Crafting_SWORD"
local ANIM_CRAFTING_ANVIL = "Crafting_ANVIL"
local ANIM_CRAFTING_MACE = "Crafting_MACE"

local an = {
    [ANIM_CRAFTING_SWORD] = _G.indexQuads("blacksmith_workshop_anim_anvil", 86),
    [ANIM_CRAFTING_ANVIL] = _G.indexQuads("blacksmith_workshop_anim_forge", 24),
    [ANIM_CRAFTING_MACE] = _G.indexQuads("blacksmith_workshop_anim_mace", 89)
}

local AnvilCrafting = _G.class("AnvilCrafting", Structure)
function AnvilCrafting:initialize(gx, gy, parent)
    self.parent = parent
    Structure.initialize(self, gx, gy, "Anvil crafting")
    self.tile = tileQuads["empty"]
    self.animated = false
    self.craftingCycle = 0
    self.animation = anim.newAnimation(an[ANIM_CRAFTING_ANVIL], 0.05, self:craftCallback_1(), ANIM_CRAFTING_ANVIL)
    self.animation:pause()
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.offsetX = -51
    self.offsetY = -77

    table.insert(activeEntities, self)
end

function AnvilCrafting:serialize()
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

function AnvilCrafting.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.swordCrafting = obj
    local anData = data.animation
    if anData.animationIdentifier == ANIM_CRAFTING_ANVIL then
        callback = obj:craftCallback_1()
    elseif anData.animationIdentifier == ANIM_CRAFTING_ANVIL then
        callback = obj:craftCallback_2()
    end
    obj.animation = _G.anim.newAnimation(an[anData.animationIdentifier], 1, callback, anData.animationIdentifier)
    obj.animation:deserialize(anData)
    table.insert(activeEntities, obj)
    return obj
end

function AnvilCrafting:craftCallback_1()
    return function()
        self.craftingCycle = self.craftingCycle + 1
        self.animation = anim.newAnimation(
            an[ANIM_CRAFTING_ANVIL], 0.11, self:craftCallback_2(), ANIM_CRAFTING_ANVIL)
    end
end

function AnvilCrafting:craftCallback_2()
    return function()
        self.animation = anim.newAnimation(an[ANIM_CRAFTING_ANVIL], 0.11, self:craftCallback_1(), ANIM_CRAFTING_ANVIL)
    end
end

function AnvilCrafting:animate()
    Structure.animate(self, _G.dt, true)
end

function AnvilCrafting:activate()
    self.animated = true
    self.animation:gotoFrame(1)
    self.animation:resume()
    self:animate(_G.dt)
end

function AnvilCrafting:deactivate()
    self.animation:pause()
    self.tile = tileQuads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
        self.instancemesh = nil
    end
    self.animated = false
end

local targetBlacksmith
local SwordCrafting = _G.class("SwordCrafting", Structure)
function SwordCrafting:initialize(gx, gy, parent)
    self.parent = parent
    Structure.initialize(self, gx, gy, "Sword crafting")
    self.tile = tileQuads["empty"]
    self.animated = false
    self.craftingCycle = 0
    self.animation = anim.newAnimation(an[ANIM_CRAFTING_SWORD], 0.11, self:craftCallback_1(), ANIM_CRAFTING_SWORD)
    self.animation:pause()
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.offsetX = -51
    self.offsetY = -77 - 18

    table.insert(activeEntities, self)
end

function SwordCrafting:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.animation = self.animation:serialize()
    data.animated = self.animated
    data.weaponType = self.weaponType
    data.craftingCycle = self.craftingCycle
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    data.parent = _G.state:serializeObject(self.parent)
    return data
end

function SwordCrafting.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.swordCrafting = obj
    local callback
    local anData = data.animation
    if anData.animationIdentifier == ANIM_CRAFTING_SWORD then
        callback = obj:craftCallback_1()
    elseif anData.animationIdentifier == ANIM_CRAFTING_MACE then
        callback = obj:craftCallback_2()
    end
    obj.animation = _G.anim.newAnimation(an[anData.animationIdentifier], 1, callback, anData.animationIdentifier)
    obj.animation:deserialize(anData)
    table.insert(activeEntities, obj)
    return obj
end

function SwordCrafting:animate()
    Structure.animate(self, _G.dt, true)
end

function SwordCrafting:activate()
    self.animated = true
    if self.parent.weaponType == WEAPON.sword then
        self.animation = anim.newAnimation(an[ANIM_CRAFTING_SWORD], 0.11, self:craftCallback_1(), ANIM_CRAFTING_SWORD)
    end
    if self.parent.weaponType == WEAPON.mace then
        self.animation = anim.newAnimation(an[ANIM_CRAFTING_MACE], 0.11, self:craftCallback_1(),
            ANIM_CRAFTING_MACE)
    end
    self:animate(_G.dt)
end

function SwordCrafting:deactivate()
    self.animation:pause()
    self.tile = tileQuads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
        self.instancemesh = nil
    end
    self.animated = false
end

local BlacksmithAlias = _G.class("BlacksmithAlias", Structure)
function BlacksmithAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
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

function BlacksmithAlias:serialize()
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

function BlacksmithAlias.static:deserialize(data)
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

local BlacksmithWorkshop = _G.class("BlacksmithWorkshop", Structure)

BlacksmithWorkshop.static.WIDTH = 4
BlacksmithWorkshop.static.LENGTH = 4
BlacksmithWorkshop.static.HEIGHT = 17
BlacksmithWorkshop.static.DESTRUCTIBLE = true

function BlacksmithWorkshop:initialize(gx, gy)
    _G.JobController:add("Blacksmith", self)
    Structure.initialize(self, gx, gy, "BlacksmithWorkshop")
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 200
    self.tile = quadArray[tiles + 1]
    self.working = false
    self.unloading = false
    self.offsetX = 0
    self.offsetY = -64
    self.weaponType = WEAPON.sword
    self.freeSpots = 1
    self.worker = nil
    self.anvilCrafting = AnvilCrafting:new(self.gx + 3, self.gy + 2, self)
    self.swordCrafting = SwordCrafting:new(self.gx + 4, self.gy + 3, self)
    for tile = 1, tiles do
        local hsl = BlacksmithAlias:new(quadArray[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offsetY + 8 * (tiles - tile + 1))
        hsl.tileKey = tile
    end
    for tile = 1, tiles do
        local hsl = BlacksmithAlias:new(quadArray[tiles + 1 + tile], self.gx + tile, self.gy, self,
            -self.offsetY + 8 * tile
            , 16)
        hsl.tileKey = tiles + 1 + tile
    end
    local tileQuads = require("objects.object_quads")
    for xx = 0, BlacksmithWorkshop.static.WIDTH - 1 do
        for yy = 0, BlacksmithWorkshop.static.LENGTH - 1 do
            if not _G.objectFromSubclassAtGlobal(self.gx + xx, self.gy + gy, Structure) then
                BlacksmithAlias:new(tileQuads["empty"], self.gx + xx, self.gy + yy, self, 0, 0)
            end
        end
    end
    self.float = NotEnoughWorkersFloat:new(self.gx + self.class.WIDTH - 1, self.gy + self.class.LENGTH - 1, 7, -112)
    self:applyBuildingHeightMap()
end

function BlacksmithWorkshop:onClick()
    targetBlacksmith = self
    swordIconButton.visible = true
    local x, y = love.mouse.getPosition()
    swordIconButton:SetPos(x - 50, y + 50)
    maceIconButton.visible = true
    maceIconButton:SetPos(x, y + 50)
    maceIconButton.visible = true
end

function SwordCrafting:craftCallback_1()
    return function()
        self.craftingCycle = self.craftingCycle + 1
        if self.parent.weaponType == WEAPON.sword then
            self.animation = anim.newAnimation(an[ANIM_CRAFTING_SWORD], 0.11, self:craftCallback_1(), ANIM_CRAFTING_SWORD)
            if self.craftingCycle == 6 then
                self.parent:sendToStockpile()
                self.craftingCycle = 0
                self:deactivate()
            end
        end
        if self.parent.weaponType == WEAPON.mace then
            self.animation = anim.newAnimation(an[ANIM_CRAFTING_MACE], 0.11, self:craftCallback_1(),
                ANIM_CRAFTING_MACE)
            if self.craftingCycle == 6 then
                self.parent:sendToStockpile()
                self.craftingCycle = 0
                self:deactivate()
            end
        end
    end
end

function BlacksmithWorkshop:destroy()
    if self.worker then
        self.worker:quitJob()
    end
    self.float:destroy()
    Structure.destroy(self.swordCrafting)
    Structure.destroy(self.anvilCrafting)
    self.swordCrafting.toBeDeleted = true
    self.anvilCrafting.toBeDeleted = true

    Structure.destroy(self)
end

function BlacksmithWorkshop:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    if data.worker then
        self.worker = _G.state:dereferenceObject(data.worker)
        self.worker.workplace = self
    end
    self.tile = quadArray[tiles + 1]
    Structure.render(self)
end

function BlacksmithWorkshop:serialize()
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

function BlacksmithWorkshop.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

function BlacksmithWorkshop:setWeapon(weapon)
    self.weaponType = weapon
end

function BlacksmithWorkshop:getWeapon()
    return self.weaponType
end

swordIconButton.OnClick = function(self)
    if targetBlacksmith then
        targetBlacksmith:setWeapon(WEAPON.sword)
    end
    swordIconButton.visible = false
    maceIconButton.visible = false
end

maceIconButton.OnClick = function(self)
    if targetBlacksmith then
        targetBlacksmith:setWeapon(WEAPON.mace)
    end
    swordIconButton.visible = false
    maceIconButton.visible = false
end

function BlacksmithWorkshop:join(worker)
    if self.health == -1 then
        _G.JobController:remove("Blacksmith", self)
        worker:quitJob()
        return
    end
    if self.freeSpots == 1 then
        self.worker = worker
        self.worker.workplace = self
        self.freeSpots = self.freeSpots - 1
    end
    swordIconButton.visible = false
    maceIconButton.visible = false
end

function BlacksmithWorkshop:enterHover(induced)
    self.hover = true
    for tile = 1, tiles do
        local alias = _G.objectFromClassAtGlobal(self.gx, self.gy + (tiles - tile + 1), BlacksmithAlias)
        if not alias then return end
        alias.tile = quadArray[tile]
        alias.tileKey = tile
        alias:render()
    end

    for tile = 1, tiles do
        local alias = _G.objectFromClassAtGlobal(self.gx + tile, self.gy, BlacksmithAlias)
        if not alias then return end
        alias.tile = quadArray[tiles + 1 + tile]
        alias.tileKey = tiles + 1 + tile
        alias:render()
    end
    self.tile = quadArray[tiles + 1]
    self:render()
end

function BlacksmithWorkshop:exitHover(induced)
    if induced or not self.swordCrafting.animated then
        self.hover = false
    else return end
    for tile = 1, tilesExt do
        local alias = _G.objectFromClassAtGlobal(self.gx, self.gy + (tilesExt - tile + 1), BlacksmithAlias)
        if alias then
            alias.tile = quadArrayExt[tile]
            alias.tileKey = tile
            alias:render()
        end
    end

    for tile = 1, tilesExt do
        local alias = _G.objectFromClassAtGlobal(self.gx + tile, self.gy, BlacksmithAlias)
        if alias then
            alias.tile = quadArrayExt[tilesExt + 1 + tile]
            alias.tileKey = tilesExt + 1 + tile
            alias:render()
        end
    end
    self.tile = quadArrayExt[tilesExt + 1]
    self:render()
end

function BlacksmithWorkshop:join(worker)
    if self.health == -1 then
        _G.JobController:remove("Blacksmith", self)
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

function BlacksmithWorkshop:work(worker)
    if self.worker.state == "Going to workplace with INGOT" then
        self.worker.state = "Working"
        self.working = true
        worker.tile = tileQuads["empty"]
        worker.animated = false
        worker.gx = self.gx + 1
        worker.gy = self.gy + 2
        worker:jobUpdate()
        self.anvilCrafting:activate()
        self.swordCrafting:activate()
    else
        self.worker.state = "Working"
        if not self.working and self.worker.state == "Working" then
            self.worker.state = "Go to stockpile for INGOT"
        end
    end
    if self.worker.state == "Working" then
        self:enterHover(true)
    end
end

function BlacksmithWorkshop:sendToStockpile()
    local i, o, cx, cy
    self.worker.state = "Go to armoury"
    self.worker.weaponType = self.weaponType
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
    self.swordCrafting:deactivate()
    self.anvilCrafting:deactivate()
    self:exitHover(true)
end

return BlacksmithWorkshop
