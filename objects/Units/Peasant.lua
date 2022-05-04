local _, _ = ...
local Unit = require("objects.Units.Unit")
local Object = require("objects.Object")
local anim = require("libraries.anim8")
local indexQuads = _G.indexQuads

local fr_walking_east = indexQuads("body_peasant_walk_e", 16)
local fr_walking_north = indexQuads("body_peasant_walk_n", 16)
local fr_walking_northeast = indexQuads("body_peasant_walk_ne", 16)
local fr_walking_northwest = indexQuads("body_peasant_walk_nw", 16)
local fr_walking_south = indexQuads("body_peasant_walk_s", 16)
local fr_walking_southeast = indexQuads("body_peasant_walk_se", 16)
local fr_walking_southwest = indexQuads("body_peasant_walk_sw", 16)
local fr_walking_west = indexQuads("body_peasant_walk_w", 16)
local fr_bowing_north = indexQuads("body_peasant_bow_n", 6, nil, true)

local fr_idle_east_2 = indexQuads("body_peasant_walk_e", 11, 10)
local fr_idle_north_2 = indexQuads("body_peasant_walk_n", 11, 10)
local fr_idle_northeast_2 = indexQuads("body_peasant_walk_ne", 11, 10)
local fr_idle_northwest_2 = indexQuads("body_peasant_walk_nw", 11, 10)
local fr_idle_south_2 = indexQuads("body_peasant_walk_s", 11, 10)
local fr_idle_southeast_2 = indexQuads("body_peasant_walk_se", 11, 10)
local fr_idle_southwest_2 = indexQuads("body_peasant_walk_sw", 11, 10)
local fr_idle_west_2 = indexQuads("body_peasant_walk_w", 11, 10)

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

local an = {
    [AN_BOWING] = fr_bowing_north,
    [AN_BOWING_FOR_A_JOB] = fr_bowing_north,
    [AN_WALKING_WEST] = fr_walking_west,
    [AN_WALKING_SOUTHWEST] = fr_walking_southwest,
    [AN_WALKING_NORTHWEST] = fr_walking_northwest,
    [AN_WALKING_NORTH] = fr_walking_north,
    [AN_WALKING_SOUTH] = fr_walking_south,
    [AN_WALKING_EAST] = fr_walking_east,
    [AN_WALKING_SOUTHEAST] = fr_walking_southeast,
    [AN_WALKING_NORTHEAST] = fr_walking_northeast,
    [AN_IDLE_WEST] = fr_idle_west_2,
    [AN_IDLE_SOUTHWEST] = fr_idle_southwest_2,
    [AN_IDLE_NORTHWEST] = fr_idle_northwest_2,
    [AN_IDLE_NORTH] = fr_idle_north_2,
    [AN_IDLE_SOUTH] = fr_idle_south_2,
    [AN_IDLE_EAST] = fr_idle_east_2,
    [AN_IDLE_SOUTHEAST] = fr_idle_southeast_2,
    [AN_IDLE_NORTHEAST] = fr_idle_northeast_2
}

local Peasant = _G.class('Peasant', Unit)
function Peasant:initialize(gx, gy, type)
    Unit.initialize(self, gx, gy, type)
    self.workplace = nil
    self.state = 'Bowing'
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
                    if self.orientation == "west" then
                        self.animation = anim.newAnimation(an[AN_IDLE_WEST], 0.11, 'pauseAtEnd', AN_IDLE_WEST)
                    elseif self.orientation == "southwest" then
                        self.animation = anim.newAnimation(an[AN_IDLE_SOUTHWEST], 0.11, 'pauseAtEnd', AN_IDLE_SOUTHWEST)
                    elseif self.orientation == "northwest" then
                        self.animation = anim.newAnimation(an[AN_IDLE_NORTHWEST], 0.11, 'pauseAtEnd', AN_IDLE_NORTHWEST)
                    elseif self.orientation == "north" then
                        self.animation = anim.newAnimation(an[AN_IDLE_NORTH], 0.11, 'pauseAtEnd', AN_IDLE_NORTH)
                    elseif self.orientation == "south" then
                        self.animation = anim.newAnimation(an[AN_IDLE_SOUTH], 0.11, 'pauseAtEnd', AN_IDLE_SOUTH)
                    elseif self.orientation == "east" then
                        self.animation = anim.newAnimation(an[AN_IDLE_EAST], 0.11, 'pauseAtEnd', AN_IDLE_EAST)
                    elseif self.orientation == "southeast" then
                        self.animation = anim.newAnimation(an[AN_IDLE_SOUTHEAST], 0.11, 'pauseAtEnd', AN_IDLE_SOUTHEAST)
                    elseif self.orientation == "northeast" then
                        self.animation = anim.newAnimation(an[AN_IDLE_NORTHEAST], 0.11, 'pauseAtEnd', AN_IDLE_NORTHEAST)
                    end
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
