local activeEntities, tileQuads, _ = ...
local anim = require("libraries.anim8")
local Structure = require("objects.Structure")
local Peasant = require("objects.Units.Peasant")
local Object = require("objects.Object")

local ANIM_CAMPFIRE_BURNING = "Campfire burning"
local ANIM_FLOAT_CIRCLE_GREEN = "Peasants coming float"
local ANIM_FLOAT_CIRCLE_RED = "Peasants leaving float"

local an = {
    [ANIM_CAMPFIRE_BURNING] = _G.indexQuads("campfire", 19, 2),
    [ANIM_FLOAT_CIRCLE_GREEN] = _G.indexQuads("float_circle_green", 51),
    [ANIM_FLOAT_CIRCLE_RED] = _G.indexQuads("float_circle_red", 51)
}

local campfireFx = {
    ["fire"] = {_G.fx["fireloop1"],
        _G.fx["fireloop2"]}
}

local CampfireFloatPop = _G.class("CampfireFloatPop", Structure)
function CampfireFloatPop:initialize(gx, gy)
    Structure.initialize(self, gx, gy, "Campfire float circle")
    self.animatedAlias = true
    self.animated = true
    local PopularityController = require("objects.Controllers.PopularityController")
    self.greenAnimation = anim.newAnimation(an[ANIM_FLOAT_CIRCLE_GREEN], PopularityController.speedPopModifier, self:immigrantCallback(),
        ANIM_FLOAT_CIRCLE_GREEN)
    self.redAnimation = anim.newAnimation(an[ANIM_FLOAT_CIRCLE_RED], PopularityController.speedPopModifier, self:emigrantCallback(),
        ANIM_FLOAT_CIRCLE_RED)
    self.offsetX = 7
    self.offsetY = -81
    self.animation = self.greenAnimation
    self.tile = tileQuads["empty"]
    _G.campfireFloatPop = self
    table.insert(activeEntities, self)
end

function CampfireFloatPop:updateSpeed(modifier)
    if _G.state.popularity >= 50 then
        local frame = 1
        if self.animation.animationIdentifier == ANIM_FLOAT_CIRCLE_GREEN then
            frame = self.animation.position
        end
        self.greenAnimation = anim.newAnimation(an[ANIM_FLOAT_CIRCLE_GREEN], modifier, self:immigrantCallback(),
            ANIM_FLOAT_CIRCLE_GREEN)
        self.animation = self.greenAnimation
        self.animation:gotoFrame(frame)
        self.animation:pause()
    else
        local frame = 1
        if self.animation.animationIdentifier == ANIM_FLOAT_CIRCLE_RED then
            frame = self.animation.position
        end
        self.redAnimation = anim.newAnimation(an[ANIM_FLOAT_CIRCLE_RED], modifier, self:emigrantCallback(),
            ANIM_FLOAT_CIRCLE_RED)
        self.animation = self.redAnimation
        self.animation:gotoFrame(frame)
        self.animation:pause()
    end
end

function CampfireFloatPop:animate(dt)
    if not _G.campfire then return end
    if _G.state.popularity >= 50 then
        local shouldAddPeasants = true
        if _G.state.population >= _G.state.maxPopulation then
            shouldAddPeasants = false
            if self.animation.animationIdentifier == ANIM_FLOAT_CIRCLE_GREEN then
                self.animation:pauseAtStart()
            end
        end
        if _G.campfire.peasants >= _G.campfire.maxPeasants then
            shouldAddPeasants = false
            if self.animation.animationIdentifier == ANIM_FLOAT_CIRCLE_GREEN then
                self.animation:pauseAtStart()
            end
        end
        if shouldAddPeasants then
            self.animation = self.greenAnimation
            self.animation:resume()
        end
    else
        local shouldRemovePeasants = true
        if _G.campfire.peasants <= 0 then
            shouldRemovePeasants = false
            if self.animation.animationIdentifier == ANIM_FLOAT_CIRCLE_RED then
                self.animation:pauseAtStart()
            else
                self.animation:pause()
            end
        end
        if shouldRemovePeasants then
            self.animation = self.redAnimation
            self.animation:resume()
        end
    end
    Structure.animate(self, dt, true)
    _G.playSfx(self, campfireFx["fire"], 0.8)
end

function CampfireFloatPop:immigrantCallback()
    local actionBar = require("states.ui.ActionBar")
    return function()
        _G.state.population = _G.state.population + 1
        actionBar:updatePopulationCount()
        Peasant:new(_G.spawnPointX, _G.spawnPointY)
    end
end

function CampfireFloatPop:emigrantCallback()
    local actionBar = require("states.ui.ActionBar")
    return function()
        _G.state.population = _G.state.population - 1
        actionBar:updatePopulationCount()
        _G.campfire:makePeasantLeave()
    end
end

function CampfireFloatPop:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.baseOffsetY = self.baseOffsetY
    data.animated = self.animated
    data.additionalOffsetY = self.additionalOffsetY
    data.animatedAlias = self.animatedAlias
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    if self.animation then
        data.animation = self.animation:serialize()
    end
    data.greenAnimation = self.greenAnimation:serialize()
    data.redAnimation = self.redAnimation:serialize()
    return data
end

function CampfireFloatPop.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    if data.animation then
        local anData = data.animation
        local callback
        if anData.animationIdentifier == ANIM_FLOAT_CIRCLE_GREEN then
            callback = obj:immigrantCallback()
        else
            obj.redAnimation = _G.anim.newAnimation(an[data.redAnimation.animationIdentifier], 1,
                obj:emigrantCallback(), data.redAnimation.animationIdentifier)
            obj.redAnimation:deserialize(data.redAnimation)
        end
        if anData.animationIdentifier == ANIM_FLOAT_CIRCLE_RED then
            callback = obj:emigrantCallback()
        else
            obj.greenAnimation = _G.anim.newAnimation(an[data.greenAnimation.animationIdentifier], 1,
                obj:immigrantCallback(), data.greenAnimation.animationIdentifier)
            obj.greenAnimation:deserialize(data.greenAnimation)
        end
        obj.animation = _G.anim.newAnimation(an[anData.animationIdentifier], 1, callback, anData.animationIdentifier)
        obj.animation:deserialize(anData)
        if obj.greenAnimation then
            obj.redAnimation = obj.animation
        else
            obj.greenAnimation = obj.animation
        end
    end
    _G.campfireFloatPop = obj
    table.insert(activeEntities, obj)
    return obj
end

local CampfireAlias = _G.class("CampfireAlias", Structure)
function CampfireAlias:initialize(gx, gy, parent, animatedAlias)
    self.parent = parent
    Structure.initialize(self, gx, gy, "Campfire alias")
    self.animatedAlias = animatedAlias
    self.offsetX = 0
    self.offsetY = -16
    self.tile = tileQuads["empty"]
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    parent:takeSpot(gx, gy)
end

function CampfireAlias:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.tileKey = self.tileKey
    data.baseOffsetY = self.baseOffsetY
    data.animated = self.animated
    data.additionalOffsetY = self.additionalOffsetY
    data.animatedAlias = self.animatedAlias
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    if self.animation then
        data.animation = self.animation:serialize()
    end
    if not self.animatedAlias then
        data.parent = _G.state:serializeObject(self.parent)
    end
    return data
end

function CampfireAlias.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    if not data.animatedAlias then
        obj.parent = _G.state:dereferenceObject(data.parent)
    end
    if data.tileKey then
        obj.tile = tileQuads[data.tileKey]
        obj.tileKey = data.tileKey
        obj:render()
    end
    if data.animation then
        local anData = data.animation
        obj.animation = _G.anim.newAnimation(an[anData.animationIdentifier], 1, nil, anData.animationIdentifier)
        obj.animation:deserialize(anData)
    end
    return obj
end

local Campfire = _G.class("Campfire", Structure)
Campfire.static.DESTRUCTIBLE = false
function Campfire:initialize(gx, gy, type)
    Structure.initialize(self, gx, gy, type or "Campfire")
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 1000
    self.tile = tileQuads["empty"]
    self.offsetX = 0
    self.offsetY = 0
    self.animated = false
    self.peasants = 0
    self.maxPeasants = 20
    self.freeSpots = _G.newAutotable(2)

    for xx = -3, 5 do
        for yy = -1, 5 do
            self.freeSpots[xx][yy] = true
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrainBiome.dirt)
        end
    end
    for xx = -2, 4 do
        for yy = -2, 4 do
            self.freeSpots[xx][yy] = true
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrainBiome.scarceGrass)
        end
    end
    _G.terrainSetTileAt(self.gx + 4, self.gy + 4, _G.terrainBiome.dirt)
    _G.terrainSetTileAt(self.gx + -2, self.gy + 4, _G.terrainBiome.dirt)
    self:takeSpot(_G.spawnPointX, _G.spawnPointY)
    CampfireFloatPop:new(self.gx + 3, self.gy + 3)
    CampfireAlias:new(self.gx, self.gy - 1, self)
    CampfireAlias:new(self.gx, self.gy + 1, self)
    CampfireAlias:new(self.gx + 1, self.gy, self)
    CampfireAlias:new(self.gx + 1, self.gy - 1, self)
    self.animatedAlias = CampfireAlias:new(self.gx + 1, self.gy + 1, self, true)
    self.animatedAlias.tileKey = "campfire (1)"
    self.animatedAlias.tile = tileQuads[self.animatedAlias.tileKey]
    CampfireAlias:new(self.gx + 2, self.gy, self)
    CampfireAlias:new(self.gx + 2, self.gy + 1, self)
    CampfireAlias:new(self.gx + 2, self.gy - 1, self)
    self:takeSpot(self.gx, self.gy)
    _G.campfire = self
    if _G.state.chunkObjects[self.animatedAlias.cx][self.animatedAlias.cy] == nil then
        _G.state.chunkObjects[self.animatedAlias.cx][self.animatedAlias.cy] = {}
    end
    _G.state.chunkObjects[self.animatedAlias.cx][self.animatedAlias.cy][self.animatedAlias] = self.animatedAlias

    Structure.render(self.animatedAlias)
end

function Campfire:update()
    return
end

function Campfire:makePeasantLeave()
    for xx = -1, 3 do
        for yy = -2, 3 do
            if self.freeSpots[xx][yy] ~= true and type(self.freeSpots[xx][yy]) == "table" then
                local peasant = self.freeSpots[xx][yy]
                peasant:remove()
                self.freeSpots[xx][yy] = true
                self.peasants = self.peasants - 1
                return true
            end
        end
    end
    return false
end

function Campfire:getNextFreeSpot(peasant)
    if not self.animated then
        self.animatedAlias.animated = true
        self.animatedAlias.offsetY = -22 - 16
        self.animatedAlias.animation = _G.anim.newAnimation(an[ANIM_CAMPFIRE_BURNING], 0.1, nil, ANIM_CAMPFIRE_BURNING)
    end
    for xx = -1, 3 do
        for yy = -2, 3 do
            if self.freeSpots[xx][yy] == true then
                self.freeSpots[xx][yy] = peasant
                self.peasants = self.peasants + 1
                return self.gx + xx, self.gy + yy, self:getPointingDirection(self.gx + xx, self.gy + yy)
            end
        end
    end
    return false
end

function Campfire:getFreePeasant()
    for xx = -1, 3 do
        for yy = -2, 3 do
            if type(self.freeSpots[xx][yy]) == "table" then
                local peasant = self.freeSpots[xx][yy]
                if peasant.state ~= "Waiting" then
                    goto skipThisPeasant
                end
                self.freeSpots[xx][yy] = true
                self.peasants = self.peasants - 1
                if self.peasants == 0 then
                    self.animatedAlias.animated = false
                    self.animatedAlias.offsetY = -16
                    Structure.render(self.animatedAlias)
                end
                peasant.state = "Waiting"
                peasant.tryTogetAJob = true
                return peasant
            end
            ::skipThisPeasant::
        end
    end
    return false
end

function Campfire:getPointingDirection(wx, wy)
    local fx, fy = self.gx, self.gy
    local angle = math.atan2(fy - wy, fx - wx)
    if angle < 0 then
        angle = angle + 2 * math.pi
    end
    angle = angle * (180 / math.pi)
    angle = math.round(angle)

    if angle < 0 then
        angle = 360 + angle
    end
    if (angle >= 135 + 22 and angle <= 225 - 22) then -- direction is west
        return "west"
    elseif (angle > 135 - 22 and angle < 135 + 22) then -- direction is southwest
        return "southwest"
    elseif (angle > 225 - 22 and angle < 225 + 22) then -- direction is northwest
        return "northwest"
    elseif (angle >= 225 + 22 and angle <= 315 - 22) then -- direction is north
        return "north"
    elseif (angle >= 45 + 22 and angle <= 135 - 22) then -- direction is south
        return "south"
    elseif ((angle >= 315 + 22 and angle <= 359) or (angle >= 0 and angle <= 45 - 22)) then -- direction is east
        return "east"
    elseif (angle > 45 - 22 and angle < 45 + 22) then -- direction is southeast
        return "southeast"
    elseif (angle > 315 - 22 and angle < 315 + 22) then -- direction is northeast
        return "northeast"
    end
end

function Campfire:freeSpot(gx, gy)
    local x, y = -(self.gx - gx), -(self.gy - gy)
    self.freeSpots[x][y] = true
end

function Campfire:takeSpot(gx, gy)
    local x, y = -(self.gx - gx), -(self.gy - gy)
    self.freeSpots[x][y] = false
end

function Campfire:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    data.animated = self.animated
    data.peasants = self.peasants
    data.maxPeasants = self.maxPeasants
    data.health = self.health
    local freeSpots = {}
    for xx = -3, 5 do
        freeSpots[xx] = {}
        for yy = -1, 5 do
            freeSpots[xx][yy] = self.freeSpots[xx][yy]
            if freeSpots[xx][yy] and type(freeSpots[xx][yy]) ~= "boolean" then
                freeSpots[xx][yy] = _G.state:serializeObject(freeSpots[xx][yy])
            end
        end
    end
    for xx = -2, 4 do
        freeSpots[xx] = {}
        for yy = -2, 4 do
            freeSpots[xx][yy] = self.freeSpots[xx][yy]
            if freeSpots[xx][yy] and type(freeSpots[xx][yy]) ~= "boolean" then
                freeSpots[xx][yy] = _G.state:serializeObject(freeSpots[xx][yy])
            end
        end
    end
    data.animatedAlias = _G.state:serializeObject(self.animatedAlias)
    data.freeSpots = freeSpots
    return data
end

function Campfire.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

function Campfire:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    self.freeSpots = _G.newAutotable(2)
    for xx = -3, 5 do
        for yy = -1, 5 do
            self.freeSpots[xx][yy] = data.freeSpots[xx][yy]
            if type(self.freeSpots[xx][yy]) == "table" then
                self.freeSpots[xx][yy] = _G.state:dereferenceObject(self.freeSpots[xx][yy])
            end
        end
    end
    for xx = -2, 4 do
        for yy = -2, 4 do
            self.freeSpots[xx][yy] = data.freeSpots[xx][yy]
            if type(self.freeSpots[xx][yy]) == "table" then
                self.freeSpots[xx][yy] = _G.state:dereferenceObject(self.freeSpots[xx][yy])
            end
        end
    end
    self.animatedAlias = _G.state:dereferenceObject(data.animatedAlias)
    self.animatedAlias.parent = self
    _G.campfire = self
    if _G.state.chunkObjects[self.animatedAlias.cx][self.animatedAlias.cy] == nil then
        _G.state.chunkObjects[self.animatedAlias.cx][self.animatedAlias.cy] = {}
    end
    _G.state.chunkObjects[self.animatedAlias.cx][self.animatedAlias.cy][self.animatedAlias] = self.animatedAlias
    Structure.render(self.animatedAlias)
end

return Campfire
