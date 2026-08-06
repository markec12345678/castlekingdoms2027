local _, _ = ...
local Unit = require("objects.Units.Unit")
local Object = require("objects.Object")
local anim = require("libraries.anim8")

--die
local ANIM_DIE = "die"
--eat
local ANIM_EATING_EAST = "eating_east"
local ANIM_EATING_NORTH = "eating_north"
local ANIM_EATING_NORTHEAST = "eating_northeast"
local ANIM_EATING_NORTHWEST = "eating_northwest"
local ANIM_EATING_SOUTH = "eating_south"
local ANIM_EATING_SOUTHEAST = "eating_southeast"
local ANIM_EATING_SOUTHWEST = "eating_southwest"
local ANIM_EATING_WEST = "eating_west"
--sit
local ANIM_SITING_EAST = "siting_east"
local ANIM_SITING_NORTH = "siting_north"
local ANIM_SITING_NORTHEAST = "siting_northeast"
local ANIM_SITING_NORTHWEST = "siting_northwest"
local ANIM_SITING_SOUTH = "siting_south"
local ANIM_SITING_SOUTHEAST = "siting_southeast"
local ANIM_SITING_SOUTHWEST = "siting_southwest"
local ANIM_SITING_WEST = "siting_west"
--walk
local ANIM_WALKING_EAST = "walking_east"
local ANIM_WALKING_NORTH = "walking_north"
local ANIM_WALKING_NORTHEAST = "walking_northeast"
local ANIM_WALKING_NORTHWEST = "walking_northwest"
local ANIM_WALKING_SOUTH = "walking_south"
local ANIM_WALKING_SOUTHEAST = "walking_southeast"
local ANIM_WALKING_SOUTHWEST = "walking_southwest"
local ANIM_WALKING_WEST = "walking_west"

local an = {
    [ANIM_WALKING_EAST] = _G.indexQuads("body_cow_walk_e", 16),
    [ANIM_WALKING_NORTH] = _G.indexQuads("body_cow_walk_n", 16),
    [ANIM_WALKING_NORTHEAST] = _G.indexQuads("body_cow_walk_ne", 16),
    [ANIM_WALKING_NORTHWEST] = _G.indexQuads("body_cow_walk_nw", 16),
    [ANIM_WALKING_SOUTH] = _G.indexQuads("body_cow_walk_s", 16),
    [ANIM_WALKING_SOUTHEAST] = _G.indexQuads("body_cow_walk_se", 16),
    [ANIM_WALKING_SOUTHWEST] = _G.indexQuads("body_cow_walk_sw", 16),
    [ANIM_WALKING_WEST] = _G.indexQuads("body_cow_walk_w", 16),
    [ANIM_EATING_EAST] = _G.addReverse(_G.indexQuads("body_cow_eat_e", 16)),
    [ANIM_EATING_NORTH] = _G.addReverse(_G.indexQuads("body_cow_eat_n", 16)),
    [ANIM_EATING_NORTHEAST] = _G.addReverse(_G.indexQuads("body_cow_eat_ne", 16)),
    [ANIM_EATING_NORTHWEST] = _G.addReverse(_G.indexQuads("body_cow_eat_nw", 16)),
    [ANIM_EATING_SOUTH] = _G.addReverse(_G.indexQuads("body_cow_eat_s", 16)),
    [ANIM_EATING_SOUTHEAST] = _G.addReverse(_G.indexQuads("body_cow_eat_se", 16)),
    [ANIM_EATING_SOUTHWEST] = _G.addReverse(_G.indexQuads("body_cow_eat_sw", 16)),
    [ANIM_EATING_WEST] = _G.indexQuads("body_cow_eat_w", 16),
    [ANIM_SITING_EAST] = _G.indexQuads("body_cow_sit_e", 16),
    [ANIM_SITING_NORTH] = _G.indexQuads("body_cow_sit_n", 16),
    [ANIM_SITING_NORTHEAST] = _G.indexQuads("body_cow_sit_ne", 16),
    [ANIM_SITING_NORTHWEST] = _G.indexQuads("body_cow_sit_nw", 16),
    [ANIM_SITING_SOUTH] = _G.indexQuads("body_cow_sit_s", 16),
    [ANIM_SITING_SOUTHEAST] = _G.indexQuads("body_cow_sit_se", 16),
    [ANIM_SITING_SOUTHWEST] = _G.indexQuads("body_cow_sit_sw", 16),
    [ANIM_SITING_WEST] = _G.indexQuads("body_cow_sit_w", 16),
    [ANIM_DIE] = _G.indexQuads("body_cow_die", 12),
}
local Cow = _G.class('Cow', Unit)

function Cow:initialize(gx, gy, type)
    Unit.initialize(self, gx, gy, type)
    self.state = "Going to eat"
    self.waitTimer = 0
    self.offsetY = -10
    self.offsetX = -5
    self.count = 1
    self.animation = anim.newAnimation(an[ANIM_WALKING_WEST], 10, nil, ANIM_WALKING_WEST)
end

function Cow:dirSubUpdate()
    if self.moveDir == "west" then
        if self.state == "Going to roam" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_WEST], 0.05, nil, ANIM_WALKING_WEST)
        elseif self.state == "Going to eat" then
            self.animation = anim.newAnimation(an[ANIM_EATING_WEST], 0.05, nil, ANIM_EATING_WEST)
        elseif self.state == "Going to sit" then
            self.animation = anim.newAnimation(an[ANIM_SITING_WEST], 0.05, nil, ANIM_SITING_WEST)
        end
    elseif self.moveDir == "southwest" then
        if self.state == "Going to roam" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_SOUTHWEST], 0.05, nil, ANIM_WALKING_SOUTHWEST)
        elseif self.state == "Going to eat" then
            self.animation = anim.newAnimation(an[ANIM_EATING_SOUTHWEST], 0.05, nil, ANIM_EATING_SOUTHWEST)
        elseif self.state == "Going to sit" then
            self.animation = anim.newAnimation(an[ANIM_SITING_SOUTHWEST], 0.05, nil, ANIM_SITING_SOUTHWEST)
        end
    elseif self.moveDir == "northwest" then
        if self.state == "Going to roam" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_NORTHWEST], 0.05, nil, ANIM_WALKING_NORTHWEST)
        elseif self.state == "Going to eat" then
            self.animation = anim.newAnimation(an[ANIM_EATING_NORTHWEST], 0.05, nil, ANIM_EATING_NORTHWEST)
        elseif self.state == "Going to sit" then
            self.animation = anim.newAnimation(an[ANIM_SITING_NORTHWEST], 0.05, nil, ANIM_SITING_NORTHWEST)
        end
    elseif self.moveDir == "north" then
        if self.state == "Going to roam" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_NORTH], 0.05, nil, ANIM_WALKING_NORTH)
        elseif self.state == "Going to eat" then
            self.animation = anim.newAnimation(an[ANIM_EATING_NORTH], 0.05, nil, ANIM_EATING_NORTH)
        elseif self.state == "Going to sit" then
            self.animation = anim.newAnimation(an[ANIM_SITING_NORTH], 0.05, nil, ANIM_SITING_NORTH)
        end
    elseif self.moveDir == "south" then
        if self.state == "Going to roam" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_SOUTH], 0.05, nil, ANIM_WALKING_SOUTH)
        elseif self.state == "Going to eat" then
            self.animation = anim.newAnimation(an[ANIM_EATING_SOUTH], 0.05, nil, ANIM_EATING_SOUTH)
        elseif self.state == "Going to sit" then
            self.animation = anim.newAnimation(an[ANIM_SITING_SOUTH], 0.05, nil, ANIM_SITING_SOUTH)
        end
    elseif self.moveDir == "east" then
        if self.state == "Going to roam" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_EAST], 0.05, nil, ANIM_WALKING_EAST)
        elseif self.state == "Going to eat" then
            self.animation = anim.newAnimation(an[ANIM_EATING_EAST], 0.05, nil, ANIM_EATING_EAST)
        elseif self.state == "Going to sit" then
            self.animation = anim.newAnimation(an[ANIM_SITING_EAST], 0.05, nil, ANIM_SITING_EAST)
        end
    elseif self.moveDir == "southeast" then
        if self.state == "Going to roam" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_SOUTHEAST], 0.05, nil, ANIM_WALKING_SOUTHEAST)
        elseif self.state == "Going to eat" then
            self.animation = anim.newAnimation(an[ANIM_EATING_SOUTHEAST], 0.05, nil, ANIM_EATING_SOUTHEAST)
        elseif self.state == "Going to sit" then
            self.animation = anim.newAnimation(an[ANIM_SITING_SOUTHEAST], 0.05, nil, ANIM_SITING_SOUTHEAST)
        end
    elseif self.moveDir == "northeast" then
        if self.state == "Going to roam" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_NORTHEAST], 0.05, nil, ANIM_WALKING_NORTHEAST)
        elseif self.state == "Going to eat" then
            self.animation = anim.newAnimation(an[ANIM_EATING_NORTHEAST], 0.05, nil, ANIM_EATING_NORTHEAST)
        elseif self.state == "Going to sit" then
            self.animation = anim.newAnimation(an[ANIM_SITING_NORTHEAST], 0.05, nil, ANIM_SITING_NORTHEAST)
        end
    end
end

function Cow:update()
    self.waitTimer = self.waitTimer + _G.dt
    if self.state == "Going to eat" and self.waitTimer > 1 then
        self.animation = anim.newAnimation(an[ANIM_EATING_NORTHEAST], 0.11, nil, ANIM_EATING_NORTHEAST)
        self.waitTimer = -2
    end
end

function Cow:animate()
    self:update()
    Unit.animate(self)
end

function Cow:load(data)
    Object.deserialize(self, data)
    Unit.load(self, data)
    local anData = data.animation
    if anData then
        self.animation = anim.newAnimation(an[anData.animationIdentifier], 1, nil, anData.animationIdentifier)
        self.animation:deserialize(anData)
    end
end

function Cow:serialize()
    local data = {}
    local unitData = Unit.serialize(self)
    for k, v in pairs(unitData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    if self.animation then
        data.animation = self.animation:serialize()
    end
    data.state = self.state
    data.waitTimer = self.waitTimer
    data.offsetY = self.offsetY
    data.offsetX = self.offsetX
    data.count = self.count
    return data
end

return Cow
