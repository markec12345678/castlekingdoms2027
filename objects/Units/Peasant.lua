local _, _ = ...
local Unit = require("objects.Units.Unit")
local Object = require("objects.Object")
local anim = require("libraries.anim8")

local fr = require("objects.Animations.Peasant")

local durations_idling_1 = {
    ["1-10"] = 0.15,
    ["11-14"] = 5,
    ["15-23"] = 0.15
}

local AN_BOWING = "Bowing"
local AN_BOWING_FOR_A_JOB = "Bowing for a job"
local AN_WALKING_WEST = "Walking west"
local AN_WALKING_SOUTHWEST = "Walking southwest"
local AN_WALKING_NORTHWEST = "Walking northwest"
local AN_WALKING_NORTH = "Walking north"
local AN_WALKING_SOUTH = "Walking south"
local AN_WALKING_EAST = "Walking east"
local AN_WALKING_SOUTHEAST = "Walking southeast"
local AN_WALKING_NORTHEAST = "Walking northeast"
local AN_IDLE_WEST = "Idling west"
local AN_IDLE_SOUTHWEST = "Idling southwest"
local AN_IDLE_NORTHWEST = "Idling northwest"
local AN_IDLE_NORTH = "Idling north"
local AN_IDLE_SOUTH = "Idling south"
local AN_IDLE_EAST = "Idling east"
local AN_IDLE_SOUTHEAST = "Idling southeast"
local AN_IDLE_NORTHEAST = "Idling northeast"

local AN_IDLE_WEST_1 = "Idling west 1"
local AN_IDLE_SOUTHWEST_1 = "Idling southwest 1"
local AN_IDLE_NORTHWEST_1 = "Idling northwest 1"
local AN_IDLE_NORTH_1 = "Idling north 1"
local AN_IDLE_SOUTH_1 = "Idling south 1"
local AN_IDLE_EAST_1 = "Idling east 1"
local AN_IDLE_SOUTHEAST_1 = "Idling southeast 1"
local AN_IDLE_NORTHEAST_1 = "Idling northeast 1"

local AN_IDLE_WEST_2 = "Idling west 2"
local AN_IDLE_SOUTHWEST_2 = "Idling southwest 2"
local AN_IDLE_NORTHWEST_2 = "Idling northwest 2"
local AN_IDLE_NORTH_2 = "Idling north 2"
local AN_IDLE_SOUTH_2 = "Idling south 2"
local AN_IDLE_EAST_2 = "Idling east 2"
local AN_IDLE_SOUTHEAST_2 = "Idling southeast 2"
local AN_IDLE_NORTHEAST_2 = "Idling northeast 2"

local AN_IDLE_WEST_3 = "Idling west 3"
local AN_IDLE_SOUTHWEST_3 = "Idling southwest 3"
local AN_IDLE_NORTHWEST_3 = "Idling northwest 3"
local AN_IDLE_NORTH_3 = "Idling north 3"
local AN_IDLE_SOUTH_3 = "Idling south 3"
local AN_IDLE_EAST_3 = "Idling east 3"
local AN_IDLE_SOUTHEAST_3 = "Idling southeast 3"
local AN_IDLE_NORTHEAST_3 = "Idling northeast 3"

local an = {
    [AN_BOWING] = fr.fr_bowing_north,
    [AN_BOWING_FOR_A_JOB] = fr.fr_bowing_north,
    [AN_WALKING_WEST] = fr.fr_walking_west,
    [AN_WALKING_SOUTHWEST] = fr.fr_walking_southwest,
    [AN_WALKING_NORTHWEST] = fr.fr_walking_northwest,
    [AN_WALKING_NORTH] = fr.fr_walking_north,
    [AN_WALKING_SOUTH] = fr.fr_walking_south,
    [AN_WALKING_EAST] = fr.fr_walking_east,
    [AN_WALKING_SOUTHEAST] = fr.fr_walking_southeast,
    [AN_WALKING_NORTHEAST] = fr.fr_walking_northeast,
    [AN_IDLE_WEST] = fr.fr_idle_west_2,
    [AN_IDLE_SOUTHWEST] = fr.fr_idle_southwest_2,
    [AN_IDLE_NORTHWEST] = fr.fr_idle_northwest_2,
    [AN_IDLE_NORTH] = fr.fr_idle_north_2,
    [AN_IDLE_SOUTH] = fr.fr_idle_south_2,
    [AN_IDLE_EAST] = fr.fr_idle_east_2,
    [AN_IDLE_SOUTHEAST] = fr.fr_idle_southeast_2,
    [AN_IDLE_NORTHEAST] = fr.fr_idle_northeast_2,

    [AN_IDLE_WEST_1] = fr.fr_idling_west_1,
    [AN_IDLE_SOUTHWEST_1] = fr.fr_idling_southwest_1,
    [AN_IDLE_NORTHWEST_1] = fr.fr_idling_northwest_1,
    [AN_IDLE_NORTH_1] = fr.fr_idling_north_1,
    [AN_IDLE_SOUTH_1] = fr.fr_idling_south_1,
    [AN_IDLE_EAST_1] = fr.fr_idling_east_1,
    [AN_IDLE_SOUTHEAST_1] = fr.fr_idling_southeast_1,
    [AN_IDLE_NORTHEAST_1] = fr.fr_idling_northeast_1,

    [AN_IDLE_WEST_2] = fr.fr_idling_west_2,
    [AN_IDLE_SOUTHWEST_2] = fr.fr_idling_southwest_2,
    [AN_IDLE_NORTHWEST_2] = fr.fr_idling_northwest_2,
    [AN_IDLE_NORTH_2] = fr.fr_idling_north_2,
    [AN_IDLE_SOUTH_2] = fr.fr_idling_south_2,
    [AN_IDLE_EAST_2] = fr.fr_idling_east_2,
    [AN_IDLE_SOUTHEAST_2] = fr.fr_idling_southeast_2,
    [AN_IDLE_NORTHEAST_2] = fr.fr_idling_northeast_2,

    [AN_IDLE_WEST_3] = fr.fr_idling_west_3,
    [AN_IDLE_SOUTHWEST_3] = fr.fr_idling_southwest_3,
    [AN_IDLE_NORTHWEST_3] = fr.fr_idling_northwest_3,
    [AN_IDLE_NORTH_3] = fr.fr_idling_north_3,
    [AN_IDLE_SOUTH_3] = fr.fr_idling_south_3,
    [AN_IDLE_EAST_3] = fr.fr_idling_east_3,
    [AN_IDLE_SOUTHEAST_3] = fr.fr_idling_southeast_3,
    [AN_IDLE_NORTHEAST_3] = fr.fr_idling_northeast_3
}

local Peasant = _G.class("Peasant", Unit)
function Peasant:initialize(gx, gy, type)
    Unit.initialize(self, gx, gy, type)
    self.workplace = nil
    self.state = "Bowing"
    self.marked = 0
    self.count = 1
    self.offsetY = -10
    self.offsetX = -5
    self.eatTimer = 0
    self.animated = true
    self.orientation = ""
    local bowingEnd = function(animation)
        animation:pause()
        self.state = "Going to campfire"
    end
    self.animation = anim.newAnimation(an[AN_BOWING], 0.12, bowingEnd, AN_BOWING)
    local campX, campY, orientation = _G.campfire:getNextFreeSpot(self)
    self.orientation = orientation
    self:requestPath(campX, campY)
    self.tryTogetAJob = false
end
function Peasant:load(data)
    Object.deserialize(self, data)
    Unit.load(self, data)
    local anData = data.animation
    local callback
    if anData then
        if anData.animationIdentifier == AN_BOWING then
            callback = function(animation)
                animation:pause()
                self.state = "Going to campfire"
            end
        elseif anData.animationIdentifier == AN_BOWING_FOR_A_JOB then
            callback = function()
                self:bowingJobCallback()
            end
        elseif string.find(anData.animationIdentifier, "Idling") then
            callback = function()
                self:chooseRandomIdleAnimation()
            end
        end
        self.animation = anim.newAnimation(an[anData.animationIdentifier], 1, callback, anData.animationIdentifier)
        self.animation:deserialize(anData)
    end
end
function Peasant:dirSubUpdate()
    if self.moveDir == "west" then
        self.animation = anim.newAnimation(an[AN_WALKING_WEST], 0.05, nil, AN_WALKING_WEST)
    elseif self.moveDir == "southwest" then
        self.animation = anim.newAnimation(an[AN_WALKING_SOUTHWEST], 0.05, nil, AN_WALKING_SOUTHWEST)
    elseif self.moveDir == "northwest" then
        self.animation = anim.newAnimation(an[AN_WALKING_NORTHWEST], 0.05, nil, AN_WALKING_NORTHWEST)
    elseif self.moveDir == "north" then
        self.animation = anim.newAnimation(an[AN_WALKING_NORTH], 0.05, nil, AN_WALKING_NORTH)
    elseif self.moveDir == "south" then
        self.animation = anim.newAnimation(an[AN_WALKING_SOUTH], 0.05, nil, AN_WALKING_SOUTH)
    elseif self.moveDir == "east" then
        self.animation = anim.newAnimation(an[AN_WALKING_EAST], 0.05, nil, AN_WALKING_EAST)
    elseif self.moveDir == "southeast" then
        self.animation = anim.newAnimation(an[AN_WALKING_SOUTHEAST], 0.05, nil, AN_WALKING_SOUTHEAST)
    elseif self.moveDir == "northeast" then
        self.animation = anim.newAnimation(an[AN_WALKING_NORTHEAST], 0.05, nil, AN_WALKING_NORTHEAST)
    end
end
function Peasant:jobUpdate()
    _G.removeObjectAt(self.lrcx, self.lrcy, self.lrx, self.lry, self)
end
function Peasant:getAJob()
    if self.state == "Waiting" then
        if math.floor(self.gx) == _G.spawnPointX and math.floor(self.gy) == _G.spawnPointY then
            self.state = "Getting a job"
            self.animation = anim.newAnimation(an[AN_BOWING_FOR_A_JOB], 0.12, function()
                self:bowingJobCallback()
            end, AN_BOWING_FOR_A_JOB)
        else
            self:requestPath(_G.spawnPointX, _G.spawnPointY)
            self.state = "Going to door"
        end
    else
        self.tryTogetAJob = true
    end
end
function Peasant:chooseRandomIdleAnimation()
    if self.state ~= "Waiting" then
        return
    end
    local rand = love.math.random(3)
    local callback = function()
        self:chooseRandomIdleAnimation()
    end
    if rand == 1 then
        if self.orientation == "west" then
            self.animation = anim.newAnimation(an[AN_IDLE_WEST_1], durations_idling_1, callback, AN_IDLE_WEST_1)
        elseif self.orientation == "southwest" then
            self.animation = anim.newAnimation(an[AN_IDLE_SOUTHWEST_1], durations_idling_1, callback,
                AN_IDLE_SOUTHWEST_1)
        elseif self.orientation == "northwest" then
            self.animation = anim.newAnimation(an[AN_IDLE_NORTHWEST_1], durations_idling_1, callback,
                AN_IDLE_NORTHWEST_1)
        elseif self.orientation == "north" then
            self.animation = anim.newAnimation(an[AN_IDLE_NORTH_1], durations_idling_1, callback, AN_IDLE_NORTH_1)
        elseif self.orientation == "south" then
            self.animation = anim.newAnimation(an[AN_IDLE_SOUTH_1], durations_idling_1, callback, AN_IDLE_SOUTH_1)
        elseif self.orientation == "east" then
            self.animation = anim.newAnimation(an[AN_IDLE_EAST_1], durations_idling_1, callback, AN_IDLE_EAST_1)
        elseif self.orientation == "southeast" then
            self.animation = anim.newAnimation(an[AN_IDLE_SOUTHEAST_1], durations_idling_1, callback,
                AN_IDLE_SOUTHEAST_1)
        elseif self.orientation == "northeast" then
            self.animation = anim.newAnimation(an[AN_IDLE_NORTHEAST_1], durations_idling_1, callback,
                AN_IDLE_NORTHEAST_1)
        end
    elseif rand == 2 then
        if self.orientation == "west" then
            self.animation = anim.newAnimation(an[AN_IDLE_WEST_2], 0.15, callback, AN_IDLE_WEST_2)
        elseif self.orientation == "southwest" then
            self.animation = anim.newAnimation(an[AN_IDLE_SOUTHWEST_2], 0.15, callback, AN_IDLE_SOUTHWEST_2)
        elseif self.orientation == "northwest" then
            self.animation = anim.newAnimation(an[AN_IDLE_NORTHWEST_2], 0.15, callback, AN_IDLE_NORTHWEST_2)
        elseif self.orientation == "north" then
            self.animation = anim.newAnimation(an[AN_IDLE_NORTH_2], 0.15, callback, AN_IDLE_NORTH_2)
        elseif self.orientation == "south" then
            self.animation = anim.newAnimation(an[AN_IDLE_SOUTH_2], 0.15, callback, AN_IDLE_SOUTH_2)
        elseif self.orientation == "east" then
            self.animation = anim.newAnimation(an[AN_IDLE_EAST_2], 0.15, callback, AN_IDLE_EAST_2)
        elseif self.orientation == "southeast" then
            self.animation = anim.newAnimation(an[AN_IDLE_SOUTHEAST_2], 0.15, callback, AN_IDLE_SOUTHEAST_2)
        elseif self.orientation == "northeast" then
            self.animation = anim.newAnimation(an[AN_IDLE_NORTHEAST_2], 0.15, callback, AN_IDLE_NORTHEAST_2)
        end
    elseif rand == 3 then
        if self.orientation == "west" then
            self.animation = anim.newAnimation(an[AN_IDLE_WEST_3], 0.15, callback, AN_IDLE_WEST_3)
        elseif self.orientation == "southwest" then
            self.animation = anim.newAnimation(an[AN_IDLE_SOUTHWEST_3], 0.15, callback, AN_IDLE_SOUTHWEST_3)
        elseif self.orientation == "northwest" then
            self.animation = anim.newAnimation(an[AN_IDLE_NORTHWEST_3], 0.15, callback, AN_IDLE_NORTHWEST_3)
        elseif self.orientation == "north" then
            self.animation = anim.newAnimation(an[AN_IDLE_NORTH_3], 0.15, callback, AN_IDLE_NORTH_3)
        elseif self.orientation == "south" then
            self.animation = anim.newAnimation(an[AN_IDLE_SOUTH_3], 0.15, callback, AN_IDLE_SOUTH_3)
        elseif self.orientation == "east" then
            self.animation = anim.newAnimation(an[AN_IDLE_EAST_3], 0.15, callback, AN_IDLE_EAST_3)
        elseif self.orientation == "southeast" then
            self.animation = anim.newAnimation(an[AN_IDLE_SOUTHEAST_3], 0.15, callback, AN_IDLE_SOUTHEAST_3)
        elseif self.orientation == "northeast" then
            self.animation = anim.newAnimation(an[AN_IDLE_NORTHEAST_3], 0.15, callback, AN_IDLE_NORTHEAST_3)
        end
    end
end
function Peasant:update()
    if self.tryToGetAJob and self.state == "Waiting" then
        self:getAJob()
    end
    self.eatTimer = self.eatTimer + 1
    if self.eatTimer > 3000 then
        _G.foodpile:take()
        self.eatTimer = 0
    end
    if self.pathState == "Waiting for path" then
        self:pathfind()
    elseif self.state == "Going to campfire" then
        self:updateDirection()
        self:move()
    elseif self.state == "Going to door" then
        self:updateDirection()
        self:move()
    end
    if self.fx * 0.001 == self.waypointX and self.fy * 0.001 == self.waypointY and self.moveDir ~= "none" then
        if self.state == "Going to campfire" or self.state == "Going to door" then
            if self:reachedPathEnd() then
                self:clearPath()
                if self.state == "Going to campfire" then
                    self.state = "Waiting"
                    self:chooseRandomIdleAnimation()
                elseif self.state == "Going to door" then
                    self.state = "Getting a job"
                    self.animation = anim.newAnimation(an[AN_BOWING_FOR_A_JOB], 0.12, function()
                        self:bowingJobCallback()
                    end, AN_BOWING_FOR_A_JOB)
                end
                return
            else
                self:setNextWaypoint()
            end
            self.count = self.count + 1
        end
    end
end
function Peasant:bowingJobCallback()
    self.toBeDeleted = true
    _G.freeVertexFromTile(self.cx, self.cy, self.previousVertId)
    self.animation = nil
    _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
    _G.removeObjectAt(self.cx, self.cy, self.i, self.o, self)
    _G.JobController:addAvailableWorker()
end
function Peasant:animate()
    self:update()
    Unit.animate(self)
end
function Peasant:serialize()
    local data = {}
    local unitData = Unit.serialize(self)
    for k, v in pairs(unitData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.workplace = self.workplace
    data.state = self.state
    data.marked = self.marked
    data.count = self.count
    data.offsetY = self.offsetY
    data.offsetX = self.offsetX
    data.eatTimer = self.eatTimer
    data.orientation = self.orientation
    data.animated = self.animated
    if self.animation then
        data.animation = self.animation:serialize()
    end
    data.tryToGetAJob = self.tryToGetAJob
    return data
end

return Peasant
