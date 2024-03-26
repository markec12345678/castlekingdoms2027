local _, _, _, _ = ...

local Structure = require("objects.Structure")
local Object = require("objects.Object")
local Drunkard = require("objects.Units.Drunkard")
local NotEnoughWorkersFloat = require("objects.Floats.NotEnoughWorkersFloat")

local tileQuads = require("objects.object_quads")
local tiles, quadArray = _G.indexBuildingQuads("inn_inside", true)
local tilesExt, quadArrayExt = _G.indexBuildingQuads("inn", true)

local ANIM_INN_PARTY = "Inn_Party"
local ANIM_INN_DOG_SITTING_DOWN = "Inn_Dog_Sitting_Down"
local ANIM_INN_DOG_SITTING = "Inn_Dog_Sitting"
local ANIM_INN_DOG_STANDING_UP = "Inn_Dog_Standing_Up"
local ANIM_INN_DOG_STANDING = "Inn_Dog_Standing"
local ANIM_INN_DOG_LICKING = "Inn_Dog_Licking"
local ANIM_INN_DOG_LYING_DOWN = "Inn_Dog_Lying_Down"
local ANIM_INN_DOG_LYING = "Inn_Dog_Lying"
local ANIM_INN_DOG_SITTING_UP = "Inn_Dog_Sitting_Up"
local ANIM_INN_FIREPLACE = "Inn_Fireplace"
local ANIM_INN_INNKEEPER_CLEANING = "Inn_Innkeeper_Cleaning"
local ANIM_INN_INNKEEPER_STANDING = "Inn_Innkeeper_Standing"

local an = {
    [ANIM_INN_PARTY] = _G.indexQuads("anim_inn", 31, 1, true),
    [ANIM_INN_DOG_SITTING_DOWN] = _G.indexQuads("anim_inn_animal", 7),
    [ANIM_INN_DOG_SITTING] = _G.addRepeat(_G.indexQuads("anim_inn_animal", 7, 7), 15),
    [ANIM_INN_DOG_STANDING_UP] = _G.reverse(_G.indexQuads("anim_inn_animal", 7)),
    [ANIM_INN_DOG_STANDING] = _G.addRepeat(_G.indexQuads("anim_inn_animal", 1, 1), 15),
    [ANIM_INN_DOG_LICKING] = _G.indexQuads("anim_inn_animal", 17, 7),
    [ANIM_INN_DOG_LYING_DOWN] = _G.indexQuads("anim_inn_animal", 24, 17),
    [ANIM_INN_DOG_LYING] = _G.addRepeat(_G.indexQuads("anim_inn_animal", 24, 24), 15),
    [ANIM_INN_DOG_SITTING_UP] = _G.reverse(_G.indexQuads("anim_inn_animal", 24, 17)),
    [ANIM_INN_FIREPLACE] = _G.indexQuads("anim_inn_fire", 16),
    [ANIM_INN_INNKEEPER_CLEANING] = _G.indexQuads("anim_inn_guy", 16, 1, true),
    [ANIM_INN_INNKEEPER_STANDING] = _G.addReverse(_G.indexQuads("anim_inn_guy", 3, 1))
}

local DOG_ANIMATION_FRAMETIME = 0.11

local innFx = {
    ["Inn"] = { _G.fx["inn_01"], _G.fx["inn_02"] }
}

local InnAnimation = _G.class("InnAnimation", Structure)
function InnAnimation:initialize(gx, gy, parent, offsetX, offsetY, nextAnimationCallback)
    self.parent = parent
    Structure.initialize(self, gx, gy, "Inn Animation")
    self.tile = tileQuads["empty"]
    self.animated = false
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.offsetX = offsetX
    self.offsetY = offsetY
    self.nextAnimationCallback = nextAnimationCallback
    if self.nextAnimationCallback then
        local startingAnimation, frameTime = self.nextAnimationCallback(nil)
        self.animation = anim.newAnimation(an[startingAnimation], frameTime, function() self:animationEnd() end, startingAnimation)
        self.animation:pause()
    end

    self:registerAsActiveEntity()
end

function InnAnimation:animationEnd()
    if self.nextAnimationCallback then
        local nextAnimation, frametime = self.nextAnimationCallback(self.animation.animationIdentifier)
        if nextAnimation ~= nil then
            self.animation = anim.newAnimation(an[nextAnimation], frametime, function() self:animationEnd() end, nextAnimation)
        end
    end
end

function InnAnimation:animate()
    Structure.animate(self, _G.dt, true)
end

function InnAnimation:activate()
    self.animated = true
    self.animation:gotoFrame(1)
    self.animation:resume()
    self:animate()
end

function InnAnimation:deactivate()
    self.animation:pause()
    self.tile = tileQuads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
        self.instancemesh = nil
    end
    self.animated = false
end

function InnAnimation:serialize()
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

local function nextPartyAnimation(previousAnimation)
    if previousAnimation == nil then
        return ANIM_INN_PARTY, 0.11
    end

    return nil, nil
end

local function nextFireplaceAnimation(previousAnimation)
    if previousAnimation == nil then
        return ANIM_INN_FIREPLACE, 0.11
    end

    return nil, nil
end

local function nextDogAnimation(previousAnimation)
    if previousAnimation == nil then
        return ANIM_INN_DOG_SITTING, DOG_ANIMATION_FRAMETIME
    elseif previousAnimation == ANIM_INN_DOG_STANDING_UP then
        return ANIM_INN_DOG_STANDING, DOG_ANIMATION_FRAMETIME
    elseif previousAnimation == ANIM_INN_DOG_SITTING_DOWN then
        return ANIM_INN_DOG_SITTING, DOG_ANIMATION_FRAMETIME
    elseif previousAnimation == ANIM_INN_DOG_LYING_DOWN then
        return ANIM_INN_DOG_LYING, DOG_ANIMATION_FRAMETIME
    elseif previousAnimation == ANIM_INN_DOG_SITTING_UP then
        return ANIM_INN_DOG_SITTING, DOG_ANIMATION_FRAMETIME
    elseif previousAnimation == ANIM_INN_DOG_LICKING then
        return ANIM_INN_DOG_SITTING, DOG_ANIMATION_FRAMETIME
    elseif previousAnimation == ANIM_INN_DOG_STANDING then
        if math.random(1, 4) == 4 then
            return ANIM_INN_DOG_SITTING_DOWN, DOG_ANIMATION_FRAMETIME
        end
    elseif previousAnimation == ANIM_INN_DOG_LYING then
        if math.random(1, 4) == 4 then
            return ANIM_INN_DOG_SITTING_UP, DOG_ANIMATION_FRAMETIME
        end
    elseif previousAnimation == ANIM_INN_DOG_SITTING then
        local roll = math.random(1, 8)
        if roll == 1 then
            return ANIM_INN_DOG_STANDING_UP, DOG_ANIMATION_FRAMETIME
        elseif roll == 2 then
            return ANIM_INN_DOG_LYING_DOWN, DOG_ANIMATION_FRAMETIME
        elseif roll >= 3 and roll <= 6 then
            return ANIM_INN_DOG_LICKING, DOG_ANIMATION_FRAMETIME
        end
    end

    return nil, nil
end

local function nextInnkeeperAnimation(previousAnimation)
    if previousAnimation == nil then
        return ANIM_INN_INNKEEPER_STANDING, 0.30
    elseif previousAnimation == ANIM_INN_INNKEEPER_STANDING then
        local roll = math.random(1, 3)
        if (roll == 3) then
            return ANIM_INN_INNKEEPER_CLEANING, 0.11
        end
    elseif previousAnimation == ANIM_INN_INNKEEPER_CLEANING then
        return ANIM_INN_INNKEEPER_STANDING, 0.30
    end

    return nil, nil
end

function InnAnimationFactory(type, gx, gy, parent)
    local animation = nil
    if type == "InnParty" then
        animation = InnAnimation:new(gx, gy, parent, -55, -68, nextPartyAnimation)
    elseif type == "InnDog" then
        animation = InnAnimation:new(gx, gy, parent, -55, -68, nextDogAnimation)
    elseif type == "InnFireplace" then
        animation = InnAnimation:new(gx, gy, parent, -39, -76, nextFireplaceAnimation)
    elseif type == "InnkeeperAnim" then
        animation = InnAnimation:new(gx, gy, parent, -39, -76, nextInnkeeperAnimation)
    end

    if animation == nil then
        print("Error, no such inn animation exist: ")
        print(type)
    end

    return animation
end

function InnAnimation.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    local anData = data.animation
    local frameTime = 0
    if string.find(anData.animationIdentifier, "Party") then
        obj.parent.partyObj = obj
        obj.nextAnimationCallback = nextPartyAnimation
        frameTime = 0.11
    elseif string.find(anData.animationIdentifier, "Dog") then
        obj.parent.dogObj = obj
        obj.nextAnimationCallback = nextDogAnimation
        frameTime = DOG_ANIMATION_FRAMETIME
    elseif string.find(anData.animationIdentifier, "Fireplace") then
        obj.parent.fireplaceObj = obj
        obj.nextAnimationCallback = nextFireplaceAnimation
        frameTime = 0.11
    elseif string.find(anData.animationIdentifier, "Innkeeper") then
        obj.parent.innkeeperAnimObj = obj
        obj.nextAnimationCallback = nextInnkeeperAnimation
        if string.find(anData.animationIdentifier, "Standing") then
            frameTime = 0.30
        else
            frameTime = 0.11
        end
    else
        print("Unknown inn animation: " .. anData.animationIdentifier)
    end
    obj.animation = _G.anim.newAnimation(an[anData.animationIdentifier], frameTime, function() obj:animationEnd() end, anData.animationIdentifier)
    obj.animation:deserialize(anData)

    return obj
end

local InnAlias = _G.class("InnAlias", Structure)
function InnAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
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

function InnAlias:serialize()
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

function InnAlias.static:deserialize(data)
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

local Inn = _G.class("Inn", Structure)

Inn.static.WIDTH = 5
Inn.static.LENGTH = 5
Inn.static.HEIGHT = 17
Inn.static.DESTRUCTIBLE = true

local ALE_CONSUMPTION_DURATION = 0.5
local CONSUMED_ALE_PER_DRUNKARD = 120

function Inn:initialize(gx, gy)
    _G.JobController:add("Innkeeper", self)
    Structure.initialize(self, gx, gy, "Inn")
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 200
    self.tile = quadArray[tiles + 1]
    self.offsetX = 0
    self.offsetY = -90
    self.freeSpots = 1
    self.worker = nil
    self.hover = false
    self.jugsOfAle = 0
    self.consumedAleSinceLastDrunkard = 0
    self.aleConsumptionTimer = 0
    self.partyObj = InnAnimationFactory("InnParty", self.gx + 3, self.gy + 2, self)
    self.dogObj = InnAnimationFactory("InnDog", self.gx + 3, self.gy + 2, self)
    self.fireplaceObj = InnAnimationFactory("InnFireplace", self.gx + 3, self.gy + 3, self)
    self.innkeeperAnimObj = InnAnimationFactory("InnkeeperAnim", self.gx + 3, self.gy + 3, self)
    for tile = 1, tiles do
        local hsl = InnAlias:new(quadArray[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offsetY + 8 * (tiles - tile + 1))
        hsl.tileKey = tile
    end
    for tile = 1, tiles do
        local hsl = InnAlias:new(quadArray[tiles + 1 + tile], self.gx + tile, self.gy, self, -self.offsetY + 8 * tile
        , 16)
        hsl.tileKey = tiles + 1 + tile
    end
    local tileQuads = require("objects.object_quads")
    for xx = 0, Inn.static.WIDTH - 1 do
        for yy = 0, Inn.static.LENGTH - 1 do
            if not _G.objectFromSubclassAtGlobal(self.gx + xx, self.gy + yy, Structure) then
                InnAlias:new(tileQuads["empty"], self.gx + xx, self.gy + yy, self, 0, 0)
            end
        end
    end
    self:applyBuildingHeightMap()

    self.float = NotEnoughWorkersFloat:new(self.gx, self.gy, 0, -64)
    
    _G.AleController:registerInn(self)
end

function Inn:destroy()
    _G.AleController:removeInn(self)
    _G.JobController:remove("Innkeeper", self)
    if self.worker then
        self.worker:quitJob()
    end
    self.float:destroy()
    Structure.destroy(self.partyObj)
    self.partyObj.toBeDeleted = true
    Structure.destroy(self.dogObj)
    self.dogObj.toBeDeleted = true
    Structure.destroy(self.innkeeperAnimObj)
    self.innkeeperAnimObj.toBeDeleted = true
    Structure.destroy(self.fireplaceObj)
    self.fireplaceObj.toBeDeleted = true

    Structure.destroy(self)
end

function Inn:onClick()
    local ActionBar = require("states.ui.ActionBar")
    ActionBar:switchMode("inn")
    ActionBar:setChosenInn(self)
    _G.playSfx(self, innFx["Inn"])
end

function Inn:join(worker)
    if self.health == -1 then
        _G.JobController:remove("Innkeeper", self)
        worker:quitJob()
        return
    end
    if self.freeSpots == 1 then
        self.worker = worker
        worker.workplace = self
        self.freeSpots = self.freeSpots - 1
    end
    if self.freeSpots == 0 then
        self.float:deactivate()
    end
end

function Inn:leave(sleepInsteadOfLeaving)
    if self.worker then
        _G.JobController:add("Innkeeper", self)
        if sleepInsteadOfLeaving then
            self.worker:quitJob()
        else
            self.worker:leaveVillage()
        end
        self.worker = nil
        self.freeSpots = 1
        self.float:activate(sleepInsteadOfLeaving)
        self.partyObj:deactivate()
        self.dogObj:deactivate()
        self.innkeeperAnimObj:deactivate()
        self:exitHover()
        return true
    end
end

function Inn:work(worker)
    worker.gx = self.gx + 3
    worker.gy = self.gy + 6
    worker:jobUpdate()
    self.innkeeperAnimObj:activate()
    self.fireplaceObj:deactivate()
end

function Inn:exitToStockpile()
    self:findExitPointTo("Stockpile", function(found, path)
        if found then
            self:sendToStockpile()
        else
            print("No path found to stockpile!")
        end
    end)
end

function Inn:sendToStockpile()
    self:respawnWorker(self.worker, "Go to stockpile")
    self.innkeeperAnimObj:deactivate()
end

function Inn:consumeAle()
    if self.jugsOfAle > 0 then
        if not self.partyObj.animated then
            self.partyObj:activate()
            self.dogObj:activate()
            self:enterHover()
        end

        self.aleConsumptionTimer = self.aleConsumptionTimer + _G.dt
        if self.aleConsumptionTimer > ALE_CONSUMPTION_DURATION then
            self.jugsOfAle = self.jugsOfAle - 1
            self.consumedAleSinceLastDrunkard = self.consumedAleSinceLastDrunkard + 1
            self.aleConsumptionTimer = 0
        end

        if self.consumedAleSinceLastDrunkard > CONSUMED_ALE_PER_DRUNKARD then
            Drunkard:new(self.gx + 3, self.gy + Inn.static.WIDTH)
            self.consumedAleSinceLastDrunkard = 0
        end
    elseif self.partyObj.animated then
        self.partyObj:deactivate()
        self.dogObj:deactivate()
        self:exitHover()
    end
end

function Inn:enterHover(induced)
    self.hover = true

    for tile = 1, tiles do
        local alias = _G.objectFromClassAtGlobal(self.gx, self.gy + (tiles - tile + 1), InnAlias)
        if not alias then return end
        alias.tile = quadArray[tile]
        alias.tileKey = tile
        alias:render()
    end

    for tile = 1, tiles do
        local alias = _G.objectFromClassAtGlobal(self.gx + tile, self.gy, InnAlias)
        if not alias then return end
        alias.tile = quadArray[tiles + 1 + tile]
        alias.tileKey = tiles + 1 + tile
        alias:render()
    end

    self.tile = quadArray[tiles + 1]
    self:render()

    if (not self.partyObj.animated) then
        self.fireplaceObj:activate()
    end
end

function Inn:exitHover(induced)
    self.fireplaceObj:deactivate()
    if induced or not self.partyObj.animated then
        self.hover = false
    else
        return
    end
    for tile = 1, tilesExt do
        local alias = _G.objectFromClassAtGlobal(self.gx, self.gy + (tilesExt - tile + 1), InnAlias)
        if alias then
            alias.tile = quadArrayExt[tile]
            alias.tileKey = tile
            alias:render()
        end
    end

    for tile = 1, tilesExt do
        local alias = _G.objectFromClassAtGlobal(self.gx + tile, self.gy, InnAlias)
        if alias then
            alias.tile = quadArrayExt[tilesExt + 1 + tile]
            alias.tileKey = tilesExt + 1 + tile
            alias:render()
        end
    end

    self.tile = quadArrayExt[tilesExt + 1]
    self:render()
end

function Inn:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    self.tile = quadArray[tiles + 1]
    Structure.render(self)
    if data.worker then
        self.worker = _G.state:dereferenceObject(data.worker)
        self.worker.workplace = self
    end
    _G.AleController:registerInn(self)
end

function Inn:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.health = self.health
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    data.freeSpots = self.freeSpots
    data.jugsOfAle = self.jugsOfAle
    data.consumedAleSinceLastDrunkard = self.consumedAleSinceLastDrunkard
    data.aleConsumptionTimer = self.aleConsumptionTimer
    if self.worker then
        data.worker = _G.state:serializeObject(self.worker)
    end

    return data
end

function Inn.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

return Inn
