local _, _ = ...
local Unit = require("objects.Units.Unit")
local Object = require("objects.Object")
local anim = require("libraries.anim8")

-- walk
local ANIM_WALKING_EAST = "walking_east"
local ANIM_WALKING_NORTH = "walking_north"
local ANIM_WALKING_NORTHEAST = "walking_northeast"
local ANIM_WALKING_NORTHWEST = "walking_northwest"
local ANIM_WALKING_SOUTH = "walking_south"
local ANIM_WALKING_SOUTHEAST = "walking_southeast"
local ANIM_WALKING_SOUTHWEST = "walking_southwest"
local ANIM_WALKING_WEST = "walking_west"
-- eat
local ANIM_EATING_EAST = "eating_east"
local ANIM_EATING_NORTH = "eating_north"
local ANIM_EATING_NORTHEAST = "eating_northeast"
local ANIM_EATING_NORTHWEST = "eating_northwest"
local ANIM_EATING_SOUTH = "eating_south"
local ANIM_EATING_SOUTHEAST = "eating_southeast"
local ANIM_EATING_SOUTHWEST = "eating_southwest"
local ANIM_EATING_WEST = "eating_west"
-- fly
local ANIM_FLY = "fly"
-- die
local ANIM_DIE = "die"
local ANIM_DIE_ARROW = "die_arrow"
-- idle
local ANIM_IDLE = "idle"

local an = {
    [ANIM_WALKING_EAST] = _G.indexQuads("body_chicken_brown_walk_e", 16),
    [ANIM_WALKING_NORTH] = _G.indexQuads("body_chicken_brown_walk_n", 16),
    [ANIM_WALKING_NORTHEAST] = _G.indexQuads("body_chicken_brown_walk_ne", 16),
    [ANIM_WALKING_NORTHWEST] = _G.indexQuads("body_chicken_brown_walk_nw", 16),
    [ANIM_WALKING_SOUTH] = _G.indexQuads("body_chicken_brown_walk_s", 16),
    [ANIM_WALKING_SOUTHEAST] = _G.indexQuads("body_chicken_brown_walk_se", 16),
    [ANIM_WALKING_SOUTHWEST] = _G.indexQuads("body_chicken_brown_walk_sw", 16),
    [ANIM_WALKING_WEST] = _G.indexQuads("body_chicken_brown_walk_w", 16),

    [ANIM_EATING_EAST] = _G.addReverse(_G.addReverse(_G.indexQuads("body_chicken_brown_eat_e", 16, nil, true))),
    [ANIM_EATING_NORTH] = _G.addReverse(_G.addReverse(_G.indexQuads("body_chicken_brown_eat_n", 16, nil, true))),
    [ANIM_EATING_NORTHEAST] = _G.addReverse(_G.addReverse(_G.indexQuads("body_chicken_brown_eat_ne", 16, nil, true))),
    [ANIM_EATING_NORTHWEST] = _G.addReverse(_G.addReverse(_G.indexQuads("body_chicken_brown_eat_nw", 16, nil, true))),
    [ANIM_EATING_SOUTH] = _G.addReverse(_G.addReverse(_G.indexQuads("body_chicken_brown_eat_s", 16, nil, true))),
    [ANIM_EATING_SOUTHEAST] = _G.addReverse(_G.addReverse(_G.indexQuads("body_chicken_brown_eat_se", 16, nil, true))),
    [ANIM_EATING_SOUTHWEST] = _G.addReverse(_G.addReverse(_G.indexQuads("body_chicken_brown_eat_sw", 16, nil, true))),
    [ANIM_EATING_WEST] = _G.addReverse(_G.addReverse(_G.indexQuads("body_chicken_brown_eat_w", 16, nil, true))),

    [ANIM_IDLE] = _G.addReverse(_G.addReverse(_G.indexQuads("body_chicken_brown_eat_e", 16, nil, true))),
    [ANIM_FLY] = _G.indexQuads("body_chicken_brown_fly", 32),
    [ANIM_DIE] = _G.indexQuads("body_chicken_brown_die", 22),
    [ANIM_DIE_ARROW] = _G.indexQuads("body_chicken_brown_die_arrow", 24),
}

local Chicken = _G.class('Chicken', Unit)

function Chicken:initialize(gx, gy, type, anchor)
    Unit.initialize(self, gx, gy, type)
    self.state = "Idle"
    self.waitTimer = 0
    self.offsetY = -10
    self.offsetX = -5
    self.count = 1
    self.sitDownTimer = 0
    self.animation = anim.newAnimation(an[ANIM_IDLE], 0.05, nil, ANIM_IDLE)
    self.anchor = anchor
end

local eatingDurations = {["1-118"] = 0.09}
local flyinggDurations = {["1-32"] = 0.09}

function Chicken:startEating(facingDir)
    self.state = "Eating"
    local callback = function()
        self.state = "Idle"
    end
    if facingDir == "west" then
        self.animation = anim.newAnimation(an[ANIM_EATING_WEST], eatingDurations, callback, ANIM_EATING_WEST)
    elseif facingDir == "southwest" then
        self.animation = anim.newAnimation(an[ANIM_EATING_SOUTHWEST], eatingDurations, callback, ANIM_EATING_SOUTHWEST)
    elseif facingDir == "northwest" then
        self.animation = anim.newAnimation(an[ANIM_EATING_NORTHWEST], eatingDurations, callback, ANIM_EATING_NORTHWEST)
    elseif facingDir == "north" then
        self.animation = anim.newAnimation(an[ANIM_EATING_NORTH], eatingDurations, callback, ANIM_EATING_NORTH)
    elseif facingDir == "south" then
        self.animation = anim.newAnimation(an[ANIM_EATING_SOUTH], eatingDurations, callback, ANIM_EATING_SOUTH)
    elseif facingDir == "east" then
        self.animation = anim.newAnimation(an[ANIM_EATING_EAST], eatingDurations, callback, ANIM_EATING_EAST)
    elseif facingDir == "southeast" then
        self.animation = anim.newAnimation(an[ANIM_EATING_SOUTHEAST], eatingDurations, callback, ANIM_EATING_SOUTHEAST)
    elseif facingDir == "northeast" then
        self.animation = anim.newAnimation(an[ANIM_EATING_NORTHEAST], eatingDurations, callback, ANIM_EATING_NORTHEAST)
    end
end

function Chicken:startFlying(facingDir)
    self.state = "Flying"
    local callback = function()
        self.state = "Idle"
    end

    self.animation = anim.newAnimation(an[ANIM_FLY], flyinggDurations, callback, ANIM_FLY)
end

function Chicken:dirSubUpdate()
    if self.moveDir == "west" then
        if self.state == "eat" then
            self.animation = anim.newAnimation(an[ANIM_EATING_WEST], 0.05, nil, ANIM_EATING_WEST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_WEST], 0.05, nil, ANIM_WALKING_WEST)
        end
    elseif self.moveDir == "southwest" then
        if self.state == "eat" then
            self.animation = anim.newAnimation(an[ANIM_EATING_SOUTHWEST], 0.05, nil, ANIM_EATING_SOUTHWEST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_SOUTHWEST], 0.05, nil, ANIM_WALKING_SOUTHWEST)
        end
    elseif self.moveDir == "northwest" then
        if self.state == "eat" then
            self.animation = anim.newAnimation(an[ANIM_EATING_NORTHWEST], 0.05, nil, ANIM_EATING_NORTHWEST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_NORTHWEST], 0.05, nil, ANIM_WALKING_NORTHWEST)
        end
    elseif self.moveDir == "north" then
        if self.state == "eat" then
            self.animation = anim.newAnimation(an[ANIM_EATING_NORTH], 0.05, nil, ANIM_EATING_NORTH)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_NORTH], 0.05, nil, ANIM_WALKING_NORTH)
        end
    elseif self.moveDir == "south" then
        if self.state == "eat" then
            self.animation = anim.newAnimation(an[ANIM_EATING_SOUTH], 0.05, nil, ANIM_EATING_SOUTH)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_SOUTH], 0.05, nil, ANIM_WALKING_SOUTH)
        end
    elseif self.moveDir == "east" then
        if self.state == "eat" then
            self.animation = anim.newAnimation(an[ANIM_EATING_EAST], 0.05, nil, ANIM_EATING_EAST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_EAST], 0.05, nil, ANIM_WALKING_EAST)
        end
    elseif self.moveDir == "southeast" then
        if self.state == "eat" then
            self.animation = anim.newAnimation(an[ANIM_EATING_SOUTHEAST], 0.05, nil, ANIM_EATING_SOUTHEAST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_SOUTHEAST], 0.05, nil, ANIM_WALKING_SOUTHEAST)
        end
    elseif self.moveDir == "northeast" then
        if self.state == "eat" then
            self.animation = anim.newAnimation(an[ANIM_EATING_NORTHEAST], 0.05, nil, ANIM_EATING_NORTHEAST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_NORTHEAST], 0.05, nil, ANIM_WALKING_NORTHEAST)
        end
    end
end

function Chicken:getRandomWaypoint()
    local targetX, targetY

    targetX = self.anchor.gx or self.gx
    targetX = targetX + math.random(-3, 3)
    targetY = self.anchor.gy or self.gy
    targetY = targetY + math.random(-3, 3)

    return targetX, targetY
end

function Chicken:update()
    if self.pathState == "Waiting for path" then
        self:pathfind()
    elseif self.pathState == "No path" then
        local targetX, targetY = self:getRandomWaypoint()
        self:requestPath(targetX, targetY)
    elseif self.state == "Idle" then
        local targetX, targetY = self:getRandomWaypoint()
        self:clearPath()
        self:requestPath(targetX, targetY)
        self.state = "Going to random waypoint"
    elseif self.state == "Going to random waypoint" then
        if self.moveDir == "none" then
            self:updateDirection()
        end
        self:move()
    end
    if self.moveDir == "none" then
        self.moveDir = "east"
    end
    if self.fx * 0.001 == self.waypointX and self.fy * 0.001 == self.waypointY and self.moveDir ~= "none" then
        if self.state == "Going to random waypoint" then
            if self:reachedPathEnd() then
                -- Randomly decide whether to eat or sit
                if math.random(1, 2) == 1 then
                    -- decided to sit
                    self:startFlying(self.moveDir)
                    self:clearPath()
                else
                    -- decided to eat
                    self:startEating(self.moveDir)
                    self:clearPath()
                end
                return
            else
                self:setNextWaypoint()
            end
            self.count = self.count + 1
        end
    end
end

function Chicken:animate()
    self:update()
    Unit.animate(self)
end

function Chicken:load(data)
    Object.deserialize(self, data)
    Unit.load(self, data)
    local anData = data.animation
    if anData then
        self.animation = anim.newAnimation(an[anData.animationIdentifier], 1, nil, anData.animationIdentifier)
        self.animation:deserialize(anData)
    end
end

function Chicken:serialize()
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

return Chicken
