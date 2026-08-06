local Unit = require("objects.Units.Unit")
local Object = require("objects.Object")
local anim = require("libraries.anim8")

-- JUMP
local ANIM_JUMPING_EAST = "jumping_east"
local ANIM_JUMPING_NORTH = "jumping_north"
local ANIM_JUMPING_NORTHEAST = "jumping_northeast"
local ANIM_JUMPING_NORTHWEST = "jumping_northwest"
local ANIM_JUMPING_SOUTH = "jumping_south"
local ANIM_JUMPING_SOUTHEAST = "jumping_southeast"
local ANIM_JUMPING_SOUTHWEST = "jumping_southwest"
local ANIM_JUMPING_WEST = "jumping_west"
-- EAT
local ANIM_EATING_EAST = "eating_east"
local ANIM_EATING_NORTH = "eating_north"
local ANIM_EATING_NORTHEAST = "eating_northeast"
local ANIM_EATING_NORTHWEST = "eating_northwest"
local ANIM_EATING_SOUTH = "eating_south"
local ANIM_EATING_SOUTHEAST = "eating_southeast"
local ANIM_EATING_SOUTHWEST = "eating_southwest"
local ANIM_EATING_WEST = "eating_west"
-- STANDING
local ANIM_STANDING_EAST = "standing_east"
local ANIM_STANDING_NORTH = "standing_north"
local ANIM_STANDING_NORTHEAST = "standing_northeast"
local ANIM_STANDING_NORTHWEST = "standing_northwest"
local ANIM_STANDING_SOUTH = "standing_south"
local ANIM_STANDING_SOUTHEAST = "standing_southeast"
local ANIM_STANDING_SOUTHWEST = "standing_southwest"
local ANIM_STANDING_WEST = "standing_west"
-- die from arrow
local ANIM_DIE_ARROW = "die_arrow"
-- die from sword
local ANIM_DIE_SWORD = "die_sword"

local an = {
    --JUMP
    [ANIM_JUMPING_EAST] = _G.indexQuads("body_rabbit_jump_e", 12),
    [ANIM_JUMPING_NORTH] = _G.indexQuads("body_rabbit_jump_n", 12),
    [ANIM_JUMPING_NORTHEAST] = _G.indexQuads("body_rabbit_jump_ne", 12),
    [ANIM_JUMPING_NORTHWEST] = _G.indexQuads("body_rabbit_jump_nw", 12),
    [ANIM_JUMPING_SOUTH] = _G.indexQuads("body_rabbit_jump_s", 12),
    [ANIM_JUMPING_SOUTHEAST] = _G.indexQuads("body_rabbit_jump_se", 12),
    [ANIM_JUMPING_SOUTHWEST] = _G.indexQuads("body_rabbit_jump_sw", 12),
    [ANIM_JUMPING_WEST] = _G.indexQuads("body_rabbit_jump_w", 12),
    --EAT
    [ANIM_EATING_EAST] = _G.indexQuads("body_rabbit_long_idle_e", 21),
    [ANIM_EATING_NORTH] = _G.indexQuads("body_rabbit_long_idle_n", 21),
    [ANIM_EATING_NORTHEAST] = _G.indexQuads("body_rabbit_long_idle_ne", 21),
    [ANIM_EATING_NORTHWEST] = _G.indexQuads("body_rabbit_long_idle_nw", 21),
    [ANIM_EATING_SOUTH] = _G.indexQuads("body_rabbit_long_idle_s", 21),
    [ANIM_EATING_SOUTHEAST] = _G.indexQuads("body_rabbit_long_idle_se", 21),
    [ANIM_EATING_SOUTHWEST] = _G.indexQuads("body_rabbit_long_idle_sw", 21),
    [ANIM_EATING_WEST] = _G.indexQuads("body_rabbit_long_idle_w", 21),
    --STAND
    [ANIM_STANDING_EAST] = _G.indexQuads("body_rabbit_long_idle_e", 36, 22),
    [ANIM_STANDING_NORTH] = _G.indexQuads("body_rabbit_long_idle_n", 36, 22),
    [ANIM_STANDING_NORTHEAST] = _G.indexQuads("body_rabbit_long_idle_ne", 36, 22),
    [ANIM_STANDING_NORTHWEST] = _G.indexQuads("body_rabbit_long_idle_nw", 36, 22),
    [ANIM_STANDING_SOUTH] = _G.indexQuads("body_rabbit_long_idle_s", 36, 22),
    [ANIM_STANDING_SOUTHEAST] = _G.indexQuads("body_rabbit_long_idle_se", 36, 22),
    [ANIM_STANDING_SOUTHWEST] = _G.indexQuads("body_rabbit_long_idle_sw", 36, 22),
    [ANIM_STANDING_WEST] = _G.indexQuads("body_rabbit_long_idle_w", 36, 22),
    --DIE ARROW
    [ANIM_DIE_ARROW] = _G.indexQuads("body_rabbit_die_arrow", 24),
    --DIE SWORD
    [ANIM_DIE_SWORD] = _G.indexQuads("body_rabbit_die_sword", 24),
}

local EATING_FRAMERATE = 0.11
local STANDING_FRAMERATE = 0.11
local JUMP_FRAMETIME = 0.06

local Rabbit = _G.class('Rabbit', Unit)

function Rabbit:initialize(gx, gy, herdIndex)
    Unit.initialize(self, gx, gy, type)
    self.state = "Follow the herd"
    self.offsetY = -10
    self.offsetX = -5
    self.count = 1
    self.herdIndex = herdIndex
    self.migrating = false
    self.straightWalkSpeed = math.floor(self.straightWalkSpeed * 0.8)
    self.diagonalWalkSpeed = math.floor(self.diagonalWalkSpeed * 0.8)
    self.idleDirection = nil
    self.previousHerdLocation = { ["gx"] = nil, ["gy"] = nil }
    self.animation = anim.newAnimation(an[ANIM_EATING_WEST], EATING_FRAMERATE, nil, ANIM_EATING_WEST)
    _G.HerdController.rabbitHerds:registerRabbit(self)
end

function Rabbit:die()
    _G.HerdController.rabbitHerds:removeRabbit(self)
    self.toBeDeleted = true
    _G.freeVertexFromTile(self.cx, self.cy, self.previousVertId)
    self.animation = nil
    _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
    _G.removeObjectAt(self.cx, self.cy, self.i, self.o, self)
end

function Rabbit:animate()
    self:update()
    Unit.animate(self)
end

function Rabbit:update()
    if self.pathState == "Waiting for path" then
        self:pathfind()
    elseif self.pathState == "No path" then
        local targetX, targetY = self:followTheHerd()
        self:requestPath(targetX, targetY)
    elseif self.state == "Follow the herd" then
        local targetX, targetY = self:followTheHerd()
        self:clearPath()
        self:requestPath(targetX, targetY)
        self.state = "Following the herd"
    elseif self.state == "Following the herd" then
        if self.moveDir == "none" then
            self:updateDirection()
        end
        self:move()
    end
    if self:reachedWaypoint() then
        if self.state == "Following the herd" then
            if self:reachedPathEnd() then
                if self.migrating then
                    _G.HerdController.rabbitHerds:herdReachedLocation(self.herdIndex)
                    self.migrating = false
                end
                self.idleDirection = self.moveDir
                self:chooseIdleTask()
                self:clearPath()
                return
            else
                self:setNextWaypoint()
            end
            self.count = self.count + 1
        end
    end
end

function Rabbit:startEating()
    self.state = "Eating"
    local callback = function() self:onIdleTaskFinished() end
    if self.idleDirection == "west" then
        self.animation = anim.newAnimation(an[ANIM_EATING_WEST], EATING_FRAMERATE, callback, ANIM_EATING_WEST)
    elseif self.idleDirection == "southwest" then
        self.animation = anim.newAnimation(an[ANIM_EATING_SOUTHWEST], EATING_FRAMERATE, callback, ANIM_EATING_SOUTHWEST)
    elseif self.idleDirection == "northwest" then
        self.animation = anim.newAnimation(an[ANIM_EATING_NORTHWEST], EATING_FRAMERATE, callback, ANIM_EATING_NORTHWEST)
    elseif self.idleDirection == "north" then
        self.animation = anim.newAnimation(an[ANIM_EATING_NORTH], EATING_FRAMERATE, callback, ANIM_EATING_NORTH)
    elseif self.idleDirection == "south" then
        self.animation = anim.newAnimation(an[ANIM_EATING_SOUTH], EATING_FRAMERATE, callback, ANIM_EATING_SOUTH)
    elseif self.idleDirection == "east" then
        self.animation = anim.newAnimation(an[ANIM_EATING_EAST], EATING_FRAMERATE, callback, ANIM_EATING_EAST)
    elseif self.idleDirection == "southeast" then
        self.animation = anim.newAnimation(an[ANIM_EATING_SOUTHEAST], EATING_FRAMERATE, callback, ANIM_EATING_SOUTHEAST)
    elseif self.idleDirection == "northeast" then
        self.animation = anim.newAnimation(an[ANIM_EATING_NORTHEAST], EATING_FRAMERATE, callback, ANIM_EATING_NORTHEAST)
    end
end

function Rabbit:startLookout()
    self.state = "Lookout"
    local callback = function() self:onIdleTaskFinished() end
    if self.idleDirection == "west" then
        self.animation = anim.newAnimation(an[ANIM_STANDING_WEST], STANDING_FRAMERATE, callback, ANIM_STANDING_WEST)
    elseif self.idleDirection == "southwest" then
        self.animation = anim.newAnimation(an[ANIM_STANDING_SOUTHWEST], STANDING_FRAMERATE, callback, ANIM_STANDING_SOUTHWEST)
    elseif self.idleDirection == "northwest" then
        self.animation = anim.newAnimation(an[ANIM_STANDING_NORTHWEST], STANDING_FRAMERATE, callback, ANIM_STANDING_NORTHWEST)
    elseif self.idleDirection == "north" then
        self.animation = anim.newAnimation(an[ANIM_STANDING_NORTH], STANDING_FRAMERATE, callback, ANIM_STANDING_NORTH)
    elseif self.idleDirection == "south" then
        self.animation = anim.newAnimation(an[ANIM_STANDING_SOUTH], STANDING_FRAMERATE, callback, ANIM_STANDING_SOUTH)
    elseif self.idleDirection == "east" then
        self.animation = anim.newAnimation(an[ANIM_STANDING_EAST], STANDING_FRAMERATE, callback, ANIM_STANDING_EAST)
    elseif self.idleDirection == "southeast" then
        self.animation = anim.newAnimation(an[ANIM_STANDING_SOUTHEAST], STANDING_FRAMERATE, callback, ANIM_STANDING_SOUTHEAST)
    elseif self.idleDirection == "northeast" then
        self.animation = anim.newAnimation(an[ANIM_STANDING_NORTHEAST], STANDING_FRAMERATE, callback, ANIM_STANDING_NORTHEAST)
    end
end

function Rabbit:onIdleTaskFinished()
    if self:migrationStarted() then
        self.state = "Follow the herd"
    else
        self:chooseIdleTask()
    end
end

function Rabbit:chooseIdleTask()
    if math.random(1, 4) == 1 then
        self:startLookout()
    else
        self:startEating()
    end
end

function Rabbit:migrationStarted()
    return _G.HerdController.rabbitHerds:getHerd(self.herdIndex).migrating
end

function Rabbit:followTheHerd()
    local gx, gy = _G.HerdController.rabbitHerds:getHerdPosition(self.herdIndex)
    if self.previousHerdLocation.gx ~= gx or self.previousHerdLocation.gy ~= gy then
        self.migrating = true
        self.previousHerdLocation.gx = gx
        self.previousHerdLocation.gy = gy
        local targetX, targetY
        repeat
            targetX = gx + math.random(-5, 5)
            targetY = gy + math.random(-5, 5)
        until _G.state.map:getWalkable(targetX, targetY) == 0
        return targetX, targetY
    else
        return self.gx, self.gy
    end
end

function Rabbit:dirSubUpdate()
    if self.state == "Following the herd" then
        if self.moveDir == "west" then
            self.animation = anim.newAnimation(an[ANIM_JUMPING_WEST], JUMP_FRAMETIME, nil, ANIM_JUMPING_WEST)
        elseif self.moveDir == "southwest" then
            self.animation = anim.newAnimation(an[ANIM_JUMPING_SOUTHWEST], JUMP_FRAMETIME, nil, ANIM_JUMPING_SOUTHWEST)
        elseif self.moveDir == "northwest" then
            self.animation = anim.newAnimation(an[ANIM_JUMPING_NORTHWEST], JUMP_FRAMETIME, nil, ANIM_JUMPING_NORTHWEST)
        elseif self.moveDir == "north" then
            self.animation = anim.newAnimation(an[ANIM_JUMPING_NORTH], JUMP_FRAMETIME, nil, ANIM_JUMPING_NORTH)
        elseif self.moveDir == "south" then
            self.animation = anim.newAnimation(an[ANIM_JUMPING_SOUTH], JUMP_FRAMETIME, nil, ANIM_JUMPING_SOUTH)
        elseif self.moveDir == "east" then
            self.animation = anim.newAnimation(an[ANIM_JUMPING_EAST], JUMP_FRAMETIME, nil, ANIM_JUMPING_EAST)
        elseif self.moveDir == "southeast" then
            self.animation = anim.newAnimation(an[ANIM_JUMPING_SOUTHEAST], JUMP_FRAMETIME, nil, ANIM_JUMPING_SOUTHEAST)
        elseif self.moveDir == "northeast" then
            self.animation = anim.newAnimation(an[ANIM_JUMPING_NORTHEAST], JUMP_FRAMETIME, nil, ANIM_JUMPING_NORTHEAST)
        end
    end
end

function Rabbit:load(data)
    Object.deserialize(self, data)
    Unit.load(self, data)
    local anData = data.animation
    if anData then
        local anCallback = nil
        local frameTime = 0.11
        if string.find(anData.animationIdentifier, "eating") then
            anCallback = function() self:onIdleTaskFinished() end
            frameTime = EATING_FRAMERATE
        elseif string.find(anData.animationIdentifier, "standing") then
            anCallback = function() self:onIdleTaskFinished() end
            frameTime = STANDING_FRAMERATE
        end
        self.animation = anim.newAnimation(an[anData.animationIdentifier], frameTime, anCallback, anData.animationIdentifier)
        self.animation:deserialize(anData)
    end
    if not self.toBeDeleted then
        _G.HerdController.rabbitHerds:registerRabbit(self)
    end
end

function Rabbit:serialize()
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
    data.offsetY = self.offsetY
    data.offsetX = self.offsetX
    data.count = self.count
    data.herdIndex = self.herdIndex
    data.migrating = self.migrating
    data.straightWalkSpeed = self.straightWalkSpeed
    data.diagonalWalkSpeed = self.diagonalWalkSpeed
    data.idleDirection = self.idleDirection
    data.previousHerdLocation = self.previousHerdLocation
    return data
end

return Rabbit
