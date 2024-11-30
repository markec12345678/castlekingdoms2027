local Unit = require("objects.Units.Unit")
local Object = require("objects.Object")
local anim = require("libraries.anim8")

local fr_laydown_bear = _G.indexQuads("body_bear_idle", 9)
local fr_breathing_bear = _G.addReverse(_G.indexQuads("body_bear_idle", 11, 9))
local fr_laying_bear = _G.addRepeat(_G.indexQuads("body_bear_idle", 9, 9), 3)
local fr_standup_bear = _G.reverse(_G.indexQuads("body_bear_idle", 9))
local fr_scratching_bear = _G.addReverse(_G.indexQuads("body_bear_idle", 16, 11))

local fr_walking_bear_east = _G.indexQuads("body_bear_walk_e", 16)
local fr_walking_bear_north = _G.indexQuads("body_bear_walk_n", 16)
local fr_walking_bear_northeast = _G.indexQuads("body_bear_walk_ne", 16)
local fr_walking_bear_northwest = _G.indexQuads("body_bear_walk_nw", 16)
local fr_walking_bear_south = _G.indexQuads("body_bear_walk_s", 16)
local fr_walking_bear_southeast = _G.indexQuads("body_bear_walk_se", 16)
local fr_walking_bear_southwest = _G.indexQuads("body_bear_walk_sw", 16)
local fr_walking_bear_west = _G.indexQuads("body_bear_walk_w", 16)

local WALKING_BEAR_EAST = "walking_bear_east"
local WALKING_BEAR_NORTH = "walking_bear_north"
local WALKING_BEAR_WEST = "walking_bear_west"
local WALKING_BEAR_SOUTH = "walking_bear_south"
local WALKING_BEAR_NORTHEAST = "walking_bear_northeast"
local WALKING_BEAR_NORTHWEST = "walking_bear_northwest"
local WALKING_BEAR_SOUTHEAST = "walking_bear_southeast"
local WALKING_BEAR_SOUTHWEST = "walking_bear_southwest"
local LAYDOWN_BEAR = "laydown_bear"
local STANDUP_BEAR = "standup_bear"
local BREATHING_BEAR = "breathing_bear"
local LAYING_BEAR = "laying_bear"
local SCRATCHING_BEAR = "scratching_bear"

local an = {
    [WALKING_BEAR_EAST] = fr_walking_bear_east,
    [WALKING_BEAR_NORTH] = fr_walking_bear_north,
    [WALKING_BEAR_WEST] = fr_walking_bear_west,
    [WALKING_BEAR_SOUTH] = fr_walking_bear_south,
    [WALKING_BEAR_NORTHEAST] = fr_walking_bear_northeast,
    [WALKING_BEAR_NORTHWEST] = fr_walking_bear_northwest,
    [WALKING_BEAR_SOUTHEAST] = fr_walking_bear_southeast,
    [WALKING_BEAR_SOUTHWEST] = fr_walking_bear_southwest,
    [LAYDOWN_BEAR] = fr_laydown_bear,
    [STANDUP_BEAR] = fr_standup_bear,
    [BREATHING_BEAR] = fr_breathing_bear,
    [LAYING_BEAR] = fr_laying_bear,
    [SCRATCHING_BEAR] = fr_scratching_bear,
}

local SLEEPING_DURATION = 30
local LAYDOWN_FRAMETIME = 0.2
local BREATHING_FRAMETIME = 0.35
local STANDUP_FRAMETIME = 0.15
local WALKING_FRAMETIME = 0.08
local WALKING_RADIUS = 10
local LAYING_BEAR_FRAMERATE = 0.8
local SCRATCHING_FRAMERATE = 0.2

local Bear = _G.class('Bear', Unit)

function Bear:initialize(gx, gy)
    Unit.initialize(self, gx, gy, nil)
    self.state = 'Wander'
    self.offsetX = 5
    self.offsetY = -20
    self.count = 1
    self.waitingTimer = 0
    self.straightWalkSpeed = math.floor(self.straightWalkSpeed * 0.7)
    self.diagonalWalkSpeed = math.floor(self.diagonalWalkSpeed * 0.7)
    self.animation = anim.newAnimation(an[LAYDOWN_BEAR], LAYDOWN_FRAMETIME, function() self:startLaying() end, LAYDOWN_BEAR)
end

function Bear:update()
    if self.pathState == "Waiting for path" then
        self:pathfind()
        if self.animation and self.animation.animationIdentifier ~= LAYDOWN_BEAR then
            self.animation = _G.anim.newAnimation(an[LAYDOWN_BEAR], LAYDOWN_FRAMETIME, function() self:startLaying() end, LAYDOWN_BEAR)
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
        elseif self.state == "Sleeping" then
            self.waitingTimer = self.waitingTimer + _G.dt
            if self.waitingTimer > SLEEPING_DURATION then
                self.state = "Standing up"
                self.animation = anim.newAnimation(an[STANDUP_BEAR], STANDUP_FRAMETIME, function() self:standupFinished() end, STANDUP_BEAR)
                self.waitingTimer = 0
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

function Bear:chooseNextTask()
    local number = math.random(1, 10)
    if number > 7 then
        self.state = "Sleeping"
        self.animation = anim.newAnimation(an[LAYDOWN_BEAR], LAYDOWN_FRAMETIME, function() self:startLaying() end, LAYDOWN_BEAR)
    else
        self.state = "Wander"
    end
    self:clearPath()
end

function Bear:startLaying()
    self.animation = anim.newAnimation(an[LAYING_BEAR], LAYING_BEAR_FRAMERATE, function() self:startBreathingOrScratching() end, LAYING_BEAR)
end

function Bear:startBreathingOrScratching()
    if math.random(1, 10) > 6 then
        self.animation = anim.newAnimation(an[SCRATCHING_BEAR], SCRATCHING_FRAMERATE, function() self:startLaying() end, SCRATCHING_BEAR)
    else
        self.animation = anim.newAnimation(an[BREATHING_BEAR], BREATHING_FRAMETIME, function() self:startLaying() end, BREATHING_BEAR)
    end
end

function Bear:animate()
    self:update()
    Unit.animate(self)
end

function Bear:startWandering()
    local targetX, targetY = self:getRandomWaypoint()
    if (targetX == -1) then --Nowhere to go: might as well sleep
        self.state = "Sleeping"
        self.animation = anim.newAnimation(an[LAYDOWN_BEAR], LAYDOWN_FRAMETIME, function() self:startSleeping() end, LAYDOWN_BEAR)
        return
    end

    self:clearPath()
    self:requestPath(targetX, targetY)
    self.state = "Wandering"
end

function Bear:getRandomWaypoint()
    for i = 1, 20 do
        local targetX = self.gx + math.random(-WALKING_RADIUS, WALKING_RADIUS)
        local targetY = self.gy + math.random(-WALKING_RADIUS, WALKING_RADIUS)
        if _G.state.map:getWalkable(targetX, targetY) == 0 then
            return targetX, targetY
        end
    end

    return -1, -1
end

function Bear:dirSubUpdate()
    if self.moveDir == "west" then
        self.animation = anim.newAnimation(an[WALKING_BEAR_WEST], WALKING_FRAMETIME, nil, WALKING_BEAR_WEST)
    elseif self.moveDir == "southwest" then
        self.animation = anim.newAnimation(an[WALKING_BEAR_SOUTHWEST], WALKING_FRAMETIME, nil, WALKING_BEAR_SOUTHWEST)
    elseif self.moveDir == "northwest" then
        self.animation = anim.newAnimation(an[WALKING_BEAR_NORTHWEST], WALKING_FRAMETIME, nil, WALKING_BEAR_NORTHWEST)
    elseif self.moveDir == "north" then
        self.animation = anim.newAnimation(an[WALKING_BEAR_NORTH], WALKING_FRAMETIME, nil, WALKING_BEAR_NORTH)
    elseif self.moveDir == "south" then
        self.animation = anim.newAnimation(an[WALKING_BEAR_SOUTH], WALKING_FRAMETIME, nil, WALKING_BEAR_SOUTH)
    elseif self.moveDir == "east" then
        self.animation = anim.newAnimation(an[WALKING_BEAR_EAST], WALKING_FRAMETIME, nil, WALKING_BEAR_EAST)
    elseif self.moveDir == "southeast" then
        self.animation = anim.newAnimation(an[WALKING_BEAR_SOUTHEAST], WALKING_FRAMETIME, nil, WALKING_BEAR_SOUTHEAST)
    elseif self.moveDir == "northeast" then
        self.animation = anim.newAnimation(an[WALKING_BEAR_NORTHEAST], WALKING_FRAMETIME, nil, WALKING_BEAR_NORTHEAST)
    end
end

function Bear:standupFinished()
    self.state = "Wander"
    self.animation:pauseAtEnd()
end

function Bear:serialize()
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
    data.waitingTimer = self.waitingTimer
    return data
end

function Bear:load(data)
    Object.deserialize(self, data)
    Unit.load(self, data)
    local anData = data.animation
    if anData then
        local anCallback = nil
        local frameTime = 0.11
        if string.find(anData.animationIdentifier, "laydown") then
            anCallback = function() self:startLaying() end
            frameTime = LAYDOWN_FRAMETIME
        elseif string.find(anData.animationIdentifier, "standup") then
            anCallback = function() self:standupFinished() end
            frameTime = STANDUP_FRAMETIME
        elseif string.find(anData.animationIdentifier, "laying") then
            anCallback = function() self:startBreathingOrScratching() end
            frameTime = LAYING_BEAR_FRAMERATE
        elseif string.find(anData.animationIdentifier, "scratching") then
            anCallback = function() self:startLaying() end
            frameTime = SCRATCHING_FRAMERATE
        elseif string.find(anData.animationIdentifier, "breathing") then
            anCallback = function() self:startLaying() end
            frameTime = BREATHING_FRAMETIME
        end
        self.animation = anim.newAnimation(an[anData.animationIdentifier], frameTime, anCallback, anData.animationIdentifier)
        self.animation:deserialize(anData)
    end
end

return Bear
