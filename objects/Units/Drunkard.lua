local Worker = require("objects.Units.Worker")
local anim = require("libraries.anim8")
local Object = require("objects.Object")

local fr_idle_drunkard_east = _G.indexQuads("body_drunkard_idle_e", 3)
local fr_idle_drunkard_north = _G.indexQuads("body_drunkard_idle_n", 3)
local fr_idle_drunkard_northeast = _G.indexQuads("body_drunkard_idle_ne", 3)
local fr_idle_drunkard_northwest = _G.indexQuads("body_drunkard_idle_nw", 3)
local fr_idle_drunkard_south = _G.indexQuads("body_drunkard_idle_s", 3)
local fr_idle_drunkard_southeast = _G.indexQuads("body_drunkard_idle_se", 3)
local fr_idle_drunkard_southwest = _G.indexQuads("body_drunkard_idle_sw", 3)
local fr_idle_drunkard_west = _G.indexQuads("body_drunkard_idle_w", 3)

local fr_idle_loop_drunkard_east = _G.indexQuads("body_drunkard_idle_e", 14, 4)
local fr_idle_loop_drunkard_north = _G.indexQuads("body_drunkard_idle_n", 14, 4)
local fr_idle_loop_drunkard_northeast = _G.indexQuads("body_drunkard_idle_ne", 14, 4)
local fr_idle_loop_drunkard_northwest = _G.indexQuads("body_drunkard_idle_nw", 14, 4)
local fr_idle_loop_drunkard_south = _G.indexQuads("body_drunkard_idle_s", 14, 4)
local fr_idle_loop_drunkard_southeast = _G.indexQuads("body_drunkard_idle_se", 14, 4)
local fr_idle_loop_drunkard_southwest = _G.indexQuads("body_drunkard_idle_sw", 14, 4)
local fr_idle_loop_drunkard_west = _G.indexQuads("body_drunkard_idle_w", 14, 4)

local fr_falling_drunkard = _G.indexQuads("body_drunkard_sit", 11)
local fr_standup_drunkard = _G.reverse(_G.indexQuads("body_drunkard_sit", 11))
local fr_drink1_drunkard = _G.indexQuads("body_drunkard_sit", 16, 12)
local fr_drink2_drunkard = _G.reverse(_G.indexQuads("body_drunkard_sit", 15, 13))

local fr_walking_drunkard_east = _G.indexQuads("body_drunkard_walk_e", 16)
local fr_walking_drunkard_north = _G.indexQuads("body_drunkard_walk_n", 16)
local fr_walking_drunkard_northeast = _G.indexQuads("body_drunkard_walk_ne", 16)
local fr_walking_drunkard_northwest = _G.indexQuads("body_drunkard_walk_nw", 16)
local fr_walking_drunkard_south = _G.indexQuads("body_drunkard_walk_s", 16)
local fr_walking_drunkard_southeast = _G.indexQuads("body_drunkard_walk_se", 16)
local fr_walking_drunkard_southwest = _G.indexQuads("body_drunkard_walk_sw", 16)
local fr_walking_drunkard_west = _G.indexQuads("body_drunkard_walk_w", 16)

local WALKING_DRUNKARD_EAST = "walking_drunkard_east"
local WALKING_DRUNKARD_NORTH = "walking_drunkard_north"
local WALKING_DRUNKARD_WEST = "walking_drunkard_west"
local WALKING_DRUNKARD_SOUTH = "walking_drunkard_south"
local WALKING_DRUNKARD_NORTHEAST = "walking_drunkard_northeast"
local WALKING_DRUNKARD_NORTHWEST = "walking_drunkard_northwest"
local WALKING_DRUNKARD_SOUTHEAST = "walking_drunkard_southeast"
local WALKING_DRUNKARD_SOUTHWEST = "walking_drunkard_southwest"
local IDLE_DRUNKARD_EAST = "idle_drunkard_east"
local IDLE_DRUNKARD_NORTH = "idle_drunkard_north"
local IDLE_DRUNKARD_WEST = "idle_drunkard_west"
local IDLE_DRUNKARD_SOUTH = "idle_drunkard_south"
local IDLE_DRUNKARD_NORTHEAST = "idle_drunkard_northeast"
local IDLE_DRUNKARD_NORTHWEST = "idle_drunkard_northwest"
local IDLE_DRUNKARD_SOUTHEAST = "idle_drunkard_southeast"
local IDLE_DRUNKARD_SOUTHWEST = "idle_drunkard_southwest"
local IDLE_LOOP_DRUNKARD_EAST = "idle_loop_drunkard_east"
local IDLE_LOOP_DRUNKARD_NORTH = "idle_loop_drunkard_north"
local IDLE_LOOP_DRUNKARD_WEST = "idle_loop_drunkard_west"
local IDLE_LOOP_DRUNKARD_SOUTH = "idle_loop_drunkard_south"
local IDLE_LOOP_DRUNKARD_NORTHEAST = "idle_loop_drunkard_northeast"
local IDLE_LOOP_DRUNKARD_NORTHWEST = "idle_loop_drunkard_northwest"
local IDLE_LOOP_DRUNKARD_SOUTHEAST = "idle_loop_drunkard_southeast"
local IDLE_LOOP_DRUNKARD_SOUTHWEST = "idle_loop_drunkard_southwest"
local FALLING_DRUNKARD = "falling_drunkard"
local DRINK1_DRUNKARD = "drink1_drunkard"
local DRINK2_DRUNKARD = "drink2_drunkard"
local STANDUP_DRUNKARD = "standup_drunkard"

local an = {
    [WALKING_DRUNKARD_EAST] = fr_walking_drunkard_east,
    [WALKING_DRUNKARD_NORTH] = fr_walking_drunkard_north,
    [WALKING_DRUNKARD_WEST] = fr_walking_drunkard_west,
    [WALKING_DRUNKARD_SOUTH] = fr_walking_drunkard_south,
    [WALKING_DRUNKARD_NORTHEAST] = fr_walking_drunkard_northeast,
    [WALKING_DRUNKARD_NORTHWEST] = fr_walking_drunkard_northwest,
    [WALKING_DRUNKARD_SOUTHEAST] = fr_walking_drunkard_southeast,
    [WALKING_DRUNKARD_SOUTHWEST] = fr_walking_drunkard_southwest,
    [IDLE_DRUNKARD_EAST] = fr_idle_drunkard_east,
    [IDLE_DRUNKARD_NORTH] = fr_idle_drunkard_north,
    [IDLE_DRUNKARD_WEST] = fr_idle_drunkard_west,
    [IDLE_DRUNKARD_SOUTH] = fr_idle_drunkard_south,
    [IDLE_DRUNKARD_NORTHEAST] = fr_idle_drunkard_northeast,
    [IDLE_DRUNKARD_NORTHWEST] = fr_idle_drunkard_northwest,
    [IDLE_DRUNKARD_SOUTHEAST] = fr_idle_drunkard_southeast,
    [IDLE_DRUNKARD_SOUTHWEST] = fr_idle_drunkard_southwest,
    [FALLING_DRUNKARD] = fr_falling_drunkard,
    [DRINK1_DRUNKARD] = fr_drink1_drunkard,
    [DRINK2_DRUNKARD] = fr_drink2_drunkard,
    [STANDUP_DRUNKARD] = fr_standup_drunkard,
    [IDLE_LOOP_DRUNKARD_EAST] = fr_idle_loop_drunkard_east,
    [IDLE_LOOP_DRUNKARD_NORTH] = fr_idle_loop_drunkard_north,
    [IDLE_LOOP_DRUNKARD_WEST] = fr_idle_loop_drunkard_west,
    [IDLE_LOOP_DRUNKARD_SOUTH] = fr_idle_loop_drunkard_south,
    [IDLE_LOOP_DRUNKARD_NORTHEAST] = fr_idle_loop_drunkard_northeast,
    [IDLE_LOOP_DRUNKARD_NORTHWEST] = fr_idle_loop_drunkard_northwest,
    [IDLE_LOOP_DRUNKARD_SOUTHEAST] = fr_idle_loop_drunkard_southeast,
    [IDLE_LOOP_DRUNKARD_SOUTHWEST] = fr_idle_loop_drunkard_southwest,
}

local STANDING_TIME = 4
local SITTING_TIME = 4
local IDLE_ANIMATION_FRAME_TIME = 0.20
local LIFE_TIME = 90
local RESPAWN_TIME = 10

local Drunkard = _G.class('Drunkard', Worker)

function Drunkard:initialize(gx, gy, inn)
    Worker.initialize(self, gx, gy, nil)
    self.state = 'Wander'
    self.offsetX = -5
    self.offsetY = -10
    self.count = 1
    self.waitingTimer = 0
    self.lifeTimer = 0
    self.inn = inn
    self.straightWalkSpeed = math.floor(self.straightWalkSpeed * 0.4)
    self.diagonalWalkSpeed = math.floor(self.diagonalWalkSpeed * 0.4)
    self.animation = anim.newAnimation(an[IDLE_DRUNKARD_SOUTH], 0.11, nil, IDLE_DRUNKARD_SOUTH)
end

function Drunkard:update()
    if self.state ~= "Waiting for respawn" then
        self.lifeTimer = self.lifeTimer + _G.dt
    end
    if self.lifeTimer > LIFE_TIME then
        self.state = "Waiting for respawn"
        self.waitingTimer = 0
        self.lifeTimer = 0
        --Disappear
        _G.removeObjectAt(self.lrcx, self.lrcy, self.lrx, self.lry, self)
        _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
        self.instancemesh = nil
        self.animation = nil
        self:clearPath()
    end
    if self.pathState == "Waiting for path" then
        self:pathfind()
        if self.animation and self.animation.animationIdentifier ~= IDLE_DRUNKARD_SOUTH then
            self.animation = _G.anim.newAnimation(an[IDLE_DRUNKARD_SOUTH], 0.11, nil, IDLE_DRUNKARD_SOUTH)
        end
    elseif self.pathState == "No path" then
        self:startWandering()
    else
        if self.state == "Wander" then
            self:startWandering()
        elseif self.state == "Wandering" then
            if self.moveDir == "none" then
                self:updateDirection()
                self:dirSubUpdate()
            end
            self:move()
        elseif self.state == "Standing" then
            self.waitingTimer = self.waitingTimer + _G.dt
            if self.waitingTimer > STANDING_TIME then
                self.state = "Wander"
                self.waitingTimer = 0
            end
        elseif self.state == "Sitting" then
            self.waitingTimer = self.waitingTimer + _G.dt
            if self.waitingTimer > SITTING_TIME then
                self.state = "Standing up"
                self.animation = anim.newAnimation(an[STANDUP_DRUNKARD], 0.20, function() self:standupFinished() end, STANDUP_DRUNKARD)
                self.waitingTimer = 0
            end
        elseif self.state == "Waiting for respawn" then
            self.waitingTimer = self.waitingTimer + _G.dt
            if self.waitingTimer > RESPAWN_TIME then
                if self.inn then
                    self.state = "Wander"
                    self.animation = anim.newAnimation(an[IDLE_DRUNKARD_SOUTH], 0.11, nil, IDLE_DRUNKARD_SOUTH)
                    self.fx = (self.inn.gx + 3) * 1000 + 500 -- teleport in front of the inn
                    self.fy = (self.inn.gy + 5) * 1000 + 500
                    self.waitingTimer = 0
                else
                    self:die()
                end
            end
        end
        if self:reachedWaypoint() then
            if self.state == "Wandering" then
                if self:reachedPathEnd() then
                    self:chooseNextTask()
                    return
                else
                    self:setNextWaypoint()
                end
                self.count = self.count + 1
            end
        end
    end
end

function Drunkard:chooseNextTask()
    local number = math.random(1, 10)
    if number == 10 then
        self.state = "Sitting"
        self.animation = anim.newAnimation(an[FALLING_DRUNKARD], 0.11, function() self:drinkLoop() end, FALLING_DRUNKARD)
    elseif number == 9 or number == 8 then
        self.state = "Standing"
        self:dirSubUpdate()
    else
        self.state = "Wander"
    end
    self:clearPath()
end

function Drunkard:getRandomWaypoint()
    for i = 1, 20 do
        local targetX = self.gx + math.random(-3, 3)
        local targetY = self.gy + math.random(-3, 3)
        if _G.state.map:getWalkable(targetX, targetY) == 0 then
            return targetX, targetY
        end
    end

    return -1, -1
end

local function getRandomDirection(notDirection)
    local directions = { "north", "south", "east", "west", "northwest", "northeast", "southwest", "southeast" }
    local find = function(direction) for k, d in ipairs(directions) do if d == direction then return k end end end
    if notDirection ~= nil and notDirection ~= "none" then
        local removeIndex = find(notDirection)
        if removeIndex ~= nil then
            table.remove(directions, removeIndex)
        end
    end
    local index = math.random(#directions)
    return directions[index]
end

function Drunkard:startWandering()
    local targetX, targetY = self:getRandomWaypoint()
    if (targetX == -1) then
        self.state = "Standing"
        self.waitingTimer = 0
        self.moveDir = getRandomDirection()
        self:dirSubUpdate()
        return
    end

    self:clearPath()
    self:requestPath(targetX, targetY)
    self.state = "Wandering"
end

function Drunkard:dirSubUpdate()
    if self.moveDir == "west" then
        if self.state == "Standing" then
            self.animation = anim.newAnimation(an[IDLE_DRUNKARD_WEST], IDLE_ANIMATION_FRAME_TIME, function() self:idleLoop() end, IDLE_DRUNKARD_WEST)
        else
            self.animation = anim.newAnimation(an[WALKING_DRUNKARD_WEST], 0.16, nil, WALKING_DRUNKARD_WEST)
        end
    elseif self.moveDir == "southwest" then
        if self.state == "Standing" then
            self.animation = anim.newAnimation(an[IDLE_DRUNKARD_SOUTHWEST], IDLE_ANIMATION_FRAME_TIME, function() self:idleLoop() end, IDLE_DRUNKARD_SOUTHWEST)
        else
            self.animation = anim.newAnimation(an[WALKING_DRUNKARD_SOUTHWEST], 0.16, nil, WALKING_DRUNKARD_SOUTHWEST)
        end
    elseif self.moveDir == "northwest" then
        if self.state == "Standing" then
            self.animation = anim.newAnimation(an[IDLE_DRUNKARD_NORTHWEST], IDLE_ANIMATION_FRAME_TIME, function() self:idleLoop() end, IDLE_DRUNKARD_NORTHWEST)
        else
            self.animation = anim.newAnimation(an[WALKING_DRUNKARD_NORTHWEST], 0.16, nil, WALKING_DRUNKARD_NORTHWEST)
        end
    elseif self.moveDir == "north" then
        if self.state == "Standing" then
            self.animation = anim.newAnimation(an[IDLE_DRUNKARD_NORTH], IDLE_ANIMATION_FRAME_TIME, function() self:idleLoop() end, IDLE_DRUNKARD_NORTH)
        else
            self.animation = anim.newAnimation(an[WALKING_DRUNKARD_NORTH], 0.16, nil, WALKING_DRUNKARD_NORTH)
        end
    elseif self.moveDir == "south" then
        if self.state == "Standing" then
            self.animation = anim.newAnimation(an[IDLE_DRUNKARD_SOUTH], IDLE_ANIMATION_FRAME_TIME, function() self:idleLoop() end, IDLE_DRUNKARD_SOUTH)
        else
            self.animation = anim.newAnimation(an[WALKING_DRUNKARD_SOUTH], 0.16, nil, WALKING_DRUNKARD_SOUTH)
        end
    elseif self.moveDir == "east" then
        if self.state == "Standing" then
            self.animation = anim.newAnimation(an[IDLE_DRUNKARD_EAST], IDLE_ANIMATION_FRAME_TIME, function() self:idleLoop() end, IDLE_DRUNKARD_EAST)
        else
            self.animation = anim.newAnimation(an[WALKING_DRUNKARD_EAST], 0.16, nil, WALKING_DRUNKARD_EAST)
        end
    elseif self.moveDir == "southeast" then
        if self.state == "Standing" then
            self.animation = anim.newAnimation(an[IDLE_DRUNKARD_SOUTHEAST], IDLE_ANIMATION_FRAME_TIME, function() self:idleLoop() end, IDLE_DRUNKARD_SOUTHEAST)
        else
            self.animation = anim.newAnimation(an[WALKING_DRUNKARD_SOUTHEAST], 0.16, nil, WALKING_DRUNKARD_SOUTHEAST)
        end
    elseif self.moveDir == "northeast" then
        if self.state == "Standing" then
            self.animation = anim.newAnimation(an[IDLE_DRUNKARD_NORTHEAST], IDLE_ANIMATION_FRAME_TIME, function() self:idleLoop() end, IDLE_DRUNKARD_NORTHEAST)
        else
            self.animation = anim.newAnimation(an[WALKING_DRUNKARD_NORTHEAST], 0.16, nil, WALKING_DRUNKARD_NORTHEAST)
        end
    end
end

function Drunkard:idleLoop()
    if self.state == "Standing" then
        if self.animation.animationIdentifier == IDLE_DRUNKARD_WEST then
            self.animation = anim.newAnimation(an[IDLE_LOOP_DRUNKARD_WEST], IDLE_ANIMATION_FRAME_TIME, nil, IDLE_LOOP_DRUNKARD_WEST)
        elseif self.animation.animationIdentifier == IDLE_DRUNKARD_SOUTHWEST then
            self.animation = anim.newAnimation(an[IDLE_LOOP_DRUNKARD_SOUTHWEST], IDLE_ANIMATION_FRAME_TIME, nil, IDLE_LOOP_DRUNKARD_SOUTHWEST)
        elseif self.animation.animationIdentifier == IDLE_DRUNKARD_NORTHWEST then
            self.animation = anim.newAnimation(an[IDLE_LOOP_DRUNKARD_NORTHWEST], IDLE_ANIMATION_FRAME_TIME, nil, IDLE_LOOP_DRUNKARD_NORTHWEST)
        elseif self.animation.animationIdentifier == IDLE_DRUNKARD_NORTH then
            self.animation = anim.newAnimation(an[IDLE_LOOP_DRUNKARD_NORTH], IDLE_ANIMATION_FRAME_TIME, nil, IDLE_LOOP_DRUNKARD_NORTH)
        elseif self.animation.animationIdentifier == IDLE_DRUNKARD_SOUTH then
            self.animation = anim.newAnimation(an[IDLE_LOOP_DRUNKARD_SOUTH], IDLE_ANIMATION_FRAME_TIME, nil, IDLE_LOOP_DRUNKARD_SOUTH)
        elseif self.animation.animationIdentifier == IDLE_DRUNKARD_EAST then
            self.animation = anim.newAnimation(an[IDLE_LOOP_DRUNKARD_EAST], IDLE_ANIMATION_FRAME_TIME, nil, IDLE_LOOP_DRUNKARD_EAST)
        elseif self.animation.animationIdentifier == IDLE_DRUNKARD_SOUTHEAST then
            self.animation = anim.newAnimation(an[IDLE_LOOP_DRUNKARD_SOUTHEAST], IDLE_ANIMATION_FRAME_TIME, nil, IDLE_LOOP_DRUNKARD_SOUTHEAST)
        elseif self.animation.animationIdentifier == IDLE_DRUNKARD_NORTHEAST then
            self.animation = anim.newAnimation(an[IDLE_LOOP_DRUNKARD_NORTHEAST], IDLE_ANIMATION_FRAME_TIME, nil, IDLE_LOOP_DRUNKARD_NORTHEAST)
        end
    end
end

function Drunkard:drinkLoop()
    if self.state == "Sitting" then
        if self.animation.animationIdentifier == DRINK1_DRUNKARD then
            self.animation = anim.newAnimation(an[DRINK2_DRUNKARD], 0.11, function() self:drinkLoop() end, DRINK2_DRUNKARD)
        elseif self.animation.animationIdentifier == FALLING_DRUNKARD or self.animation.animationIdentifier == DRINK2_DRUNKARD then
            self.animation = anim.newAnimation(an[DRINK1_DRUNKARD], 0.11, function() self:drinkLoop() end, DRINK1_DRUNKARD)
        end
    end
end

function Drunkard:standupFinished()
    self.state = "Wander"
    self.animation:pauseAtEnd()
end

function Drunkard:animate()
    self:update()
    Worker.animate(self)
end

function Drunkard:die()
    self.toBeDeleted = true
    _G.freeVertexFromTile(self.cx, self.cy, self.previousVertId)
    self.animation = nil
    _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
    _G.removeObjectAt(self.cx, self.cy, self.i, self.o, self)
end

function Drunkard:load(data)
    Object.deserialize(self, data)
    Worker.load(self, data)
    local anData = data.animation
    if anData then
        local callback
        local frameTime = 0.11
        if string.find(anData.animationIdentifier, "standup") then
            callback = function() self:standupFinished() end
            frameTime = 0.20
        elseif string.find(anData.animationIdentifier, "idle") then
            callback = function() self:idleLoop() end
            frameTime = IDLE_ANIMATION_FRAME_TIME
        elseif string.find(anData.animationIdentifier, "falling") or string.find(anData.animationIdentifier, "drink") then
            callback = function() self:drinkLoop() end
        end
        self.animation = anim.newAnimation(an[anData.animationIdentifier], frameTime, callback, anData.animationIdentifier)
        self.animation:deserialize(anData)
    end
end

function Drunkard:serialize()
    local data = {}
    local unitData = Worker.serialize(self)
    for k, v in pairs(unitData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    if self.animation then
        data.animation = self.animation:serialize()
    end
    data.state = self.state
    data.waitingTimer = self.waitingTimer
    data.offsetY = self.offsetY
    data.offsetX = self.offsetX
    data.count = self.count
    data.lifeTimer = self.lifeTimer
    return data
end

return Drunkard
