local Worker = require("objects.Units.Worker")
local Object = require("objects.Object")
local anim = require("libraries.anim8")
local RESOURCES = require("objects.Enums.Resources")

local ANIM_WALKING_EAST = "walking_east"
local ANIM_WALKING_NORTH = "walking_north"
local ANIM_WALKING_NORTHEAST = "walking_northeast"
local ANIM_WALKING_NORTHWEST = "walking_northwest"
local ANIM_WALKING_SOUTH = "walking_south"
local ANIM_WALKING_SOUTHEAST = "walking_southeast"
local ANIM_WALKING_SOUTHWEST = "walking_southwest"
local ANIM_WALKING_WEST = "walking_west"
-- pitch
local ANIM_WALKING_PITCH_EAST = "walking_pitch_east"
local ANIM_WALKING_PITCH_NORTH = "walking_pitch_north"
local ANIM_WALKING_PITCH_NORTHEAST = "walking_pitch_northeast"
local ANIM_WALKING_PITCH_NORTHWEST = "walking_pitch_northwest"
local ANIM_WALKING_PITCH_SOUTH = "walking_pitch_south"
local ANIM_WALKING_PITCH_SOUTHEAST = "walking_pitch_southeast"
local ANIM_WALKING_PITCH_SOUTHWEST = "walking_pitch_southwest"
local ANIM_WALKING_PITCH_WEST = "walking_pitch_west"
--idle
local ANIM_IDLE = "idle"
local ANIM_IDLE_STATIC = "idle_static"

local an = {
    [ANIM_WALKING_EAST] = _G.indexQuads("body_pitch_worker_walk_e", 16),
    [ANIM_WALKING_NORTH] = _G.indexQuads("body_pitch_worker_walk_n", 16),
    [ANIM_WALKING_NORTHEAST] = _G.indexQuads("body_pitch_worker_walk_ne", 16),
    [ANIM_WALKING_NORTHWEST] = _G.indexQuads("body_pitch_worker_walk_nw", 16),
    [ANIM_WALKING_SOUTH] = _G.indexQuads("body_pitch_worker_walk_s", 16),
    [ANIM_WALKING_SOUTHEAST] = _G.indexQuads("body_pitch_worker_walk_se", 16),
    [ANIM_WALKING_SOUTHWEST] = _G.indexQuads("body_pitch_worker_walk_sw", 16),
    [ANIM_WALKING_WEST] = _G.indexQuads("body_pitch_worker_walk_w", 16),
    [ANIM_WALKING_PITCH_EAST] = _G.indexQuads("body_pitch_worker_walk_pitch_e", 16),
    [ANIM_WALKING_PITCH_NORTH] = _G.indexQuads("body_pitch_worker_walk_pitch_n", 16),
    [ANIM_WALKING_PITCH_NORTHEAST] = _G.indexQuads("body_pitch_worker_walk_pitch_ne", 16),
    [ANIM_WALKING_PITCH_NORTHWEST] = _G.indexQuads("body_pitch_worker_walk_pitch_nw", 16),
    [ANIM_WALKING_PITCH_SOUTH] = _G.indexQuads("body_pitch_worker_walk_pitch_s", 16),
    [ANIM_WALKING_PITCH_SOUTHEAST] = _G.indexQuads("body_pitch_worker_walk_pitch_se", 16),
    [ANIM_WALKING_PITCH_SOUTHWEST] = _G.indexQuads("body_pitch_worker_walk_pitch_sw", 16),
    [ANIM_WALKING_PITCH_WEST] = _G.indexQuads("body_pitch_worker_walk_pitch_w", 16),
    [ANIM_IDLE] = _G.addReverse(_G.indexQuads("body_pitch_worker_idle", 21)),
    [ANIM_IDLE_STATIC] = _G.indexQuads("body_pitch_worker_idle", 1)
}
local Pitcher = _G.class('Pitcher', Worker)

function Pitcher:initialize(gx, gy, type)
    Worker.initialize(self, gx, gy, type)
    self.state = 'Find a job'
    self.waitTimer = 0
    self.offsetY = -10
    self.offsetX = -5
    self.count = 1
    self.animation = anim.newAnimation(an[ANIM_WALKING_WEST], 10, nil, ANIM_WALKING_WEST)
end

function Pitcher:load(data)
    Object.deserialize(self, data)
    Worker.load(self, data)
    local anData = data.animation
    if anData then
        self.animation = anim.newAnimation(an[anData.animationIdentifier], 1, nil, anData.animationIdentifier)
        self.animation:deserialize(anData)
    end
end

function Pitcher:serialize()
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
    data.waitTimer = self.waitTimer
    data.offsetY = self.offsetY
    data.offsetX = self.offsetX
    data.count = self.count
    return data
end

function Pitcher:dirSubUpdate()
    if self.moveDir == "west" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_PITCH_WEST], 0.05, nil, ANIM_WALKING_PITCH_WEST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_WEST], 0.05, nil, ANIM_WALKING_WEST)
        end
    elseif self.moveDir == "southwest" then
        if self.state == "Going to stockpile" then
            self.animation =
                anim.newAnimation(an[ANIM_WALKING_PITCH_SOUTHWEST], 0.05, nil, ANIM_WALKING_PITCH_SOUTHWEST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_SOUTHWEST], 0.05, nil, ANIM_WALKING_SOUTHWEST)
        end
    elseif self.moveDir == "northwest" then
        if self.state == "Going to stockpile" then
            self.animation =
                anim.newAnimation(an[ANIM_WALKING_PITCH_NORTHWEST], 0.05, nil, ANIM_WALKING_PITCH_NORTHWEST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_NORTHWEST], 0.05, nil, ANIM_WALKING_NORTHWEST)
        end
    elseif self.moveDir == "north" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_PITCH_NORTH], 0.05, nil, ANIM_WALKING_PITCH_NORTH)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_NORTH], 0.05, nil, ANIM_WALKING_NORTH)
        end
    elseif self.moveDir == "south" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_PITCH_SOUTH], 0.05, nil, ANIM_WALKING_PITCH_SOUTH)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_SOUTH], 0.05, nil, ANIM_WALKING_SOUTH)
        end
    elseif self.moveDir == "east" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_PITCH_EAST], 0.05, nil, ANIM_WALKING_PITCH_EAST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_EAST], 0.05, nil, ANIM_WALKING_EAST)
        end
    elseif self.moveDir == "southeast" then
        if self.state == "Going to stockpile" then
            self.animation =
                anim.newAnimation(an[ANIM_WALKING_PITCH_SOUTHEAST], 0.05, nil, ANIM_WALKING_PITCH_SOUTHEAST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_SOUTHEAST], 0.05, nil, ANIM_WALKING_SOUTHEAST)
        end
    elseif self.moveDir == "northeast" then
        if self.state == "Going to stockpile" then
            self.animation =
                anim.newAnimation(an[ANIM_WALKING_PITCH_NORTHEAST], 0.05, nil, ANIM_WALKING_PITCH_NORTHEAST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_NORTHEAST], 0.05, nil, ANIM_WALKING_NORTHEAST)
        end
    end
end

function Pitcher:update()
    self.waitTimer = self.waitTimer + _G.dt
    if self.state == "Waiting for pitch" then
        if self.waitTimer > 1 then
            self.waitTimer = 0
            self.state = "Go to stockpile"
            self:clearPath()
            return
        end
    end
    if self.pathState == "Waiting for path" then
        self:pathfind()
    elseif self.state == "Waiting for work" then
        self.workplace:work(self)
    elseif self.state ~= "No path to workplace" and self.state ~= "Working" then
        if self.state == "Find a job" then
            _G.JobController:findJob(self, "Pitcher")
        elseif self.state == "Go to stockpile" then
            if _G.stockpile then
                if self.state == "Go to stockpile" then
                    self.state = "Going to stockpile"
                end
                local closestNode
                local distance = math.huge
                for _, v in ipairs(_G.stockpile.nodeList) do
                    local tmp = _G.manhattanDistance(v.gx, v.gy, self.gx, self.gy)
                    if tmp < distance then
                        distance = tmp
                        closestNode = v
                    end
                end
                if not closestNode then
                    print("Closest node not found")
                else
                    self:requestPath(closestNode.gx, closestNode.gy)
                end
                self.moveDir = "none"
            end
        elseif self.state == "Go to workplace" then
            self:requestPathToStructure(self.workplace)
            self.state = "Going to workplace"
            self.moveDir = "none"
            return
        elseif self.moveDir == "none" and
            (self.state == "Going to workplace" or self.state == "Going to stockpile") then
            self:updateDirection()
            self:dirSubUpdate()
        end
        if (self.state == "Going to workplace" or self.state == "Going to stockpile") then
            self:move()
        end
        if self:reachedWaypoint() then
            if self.state == "Going to workplace" then
                if self:reachedPathEnd() then
                    self.workplace:work(self)
                    return
                else
                    self:setNextWaypoint()
                end
                self.count = self.count + 1
            elseif self.state == "Going to stockpile" then
                if self:reachedPathEnd() then
                    if self.state == "Going to stockpile" then
                        _G.stockpile:store('tar')
                        self.state = "Go to workplace"
                        self:clearPath()
                        return
                    end
                end
                self:setNextWaypoint()
                self.count = self.count + 1
            end
        end
    end
end

function Pitcher:animate()
    self:update()
    Worker.animate(self)
end

return Pitcher
