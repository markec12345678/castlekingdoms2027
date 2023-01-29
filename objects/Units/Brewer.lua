local _, _ = ...
local Worker = require("objects.Units.Worker")
local Object = require("objects.Object")
local anim = require("libraries.anim8")

local ANIM_WALKING_EAST = "walking_east"
local ANIM_WALKING_NORTH = "walking_north"
local ANIM_WALKING_NORTHEAST = "walking_northeast"
local ANIM_WALKING_NORTHWEST = "walking_northwest"
local ANIM_WALKING_SOUTH = "walking_south"
local ANIM_WALKING_SOUTHEAST = "walking_southeast"
local ANIM_WALKING_SOUTHWEST = "walking_southwest"
local ANIM_WALKING_WEST = "walking_west"
-- hops
local ANIM_WALKING_HOPS_EAST = "walking_hops_east"
local ANIM_WALKING_HOPS_NORTH = "walking_hops_north"
local ANIM_WALKING_HOPS_NORTHEAST = "walking_hops_northeast"
local ANIM_WALKING_HOPS_NORTHWEST = "walking_hops_northwest"
local ANIM_WALKING_HOPS_SOUTH = "walking_hops_south"
local ANIM_WALKING_HOPS_SOUTHEAST = "walking_hops_southeast"
local ANIM_WALKING_HOPS_SOUTHWEST = "walking_hops_southwest"
local ANIM_WALKING_HOPS_WEST = "walking_hops_west"
-- beer
local ANIM_WALKING_BEER_EAST = "walking_beer_east"
local ANIM_WALKING_BEER_NORTH = "walking_beer_north"
local ANIM_WALKING_BEER_NORTHEAST = "walking_beer_northeast"
local ANIM_WALKING_BEER_NORTHWEST = "walking_beer_northwest"
local ANIM_WALKING_BEER_SOUTH = "walking_beer_south"
local ANIM_WALKING_BEER_SOUTHEAST = "walking_beer_southeast"
local ANIM_WALKING_BEER_SOUTHWEST = "walking_beer_southwest"
local ANIM_WALKING_BEER_WEST = "walking_beer_west"
-- idle/wait
local ANIM_IDLE = "idle"

local an = {
    [ANIM_WALKING_EAST] = _G.indexQuads("body_brewer_walk_e", 16),
    [ANIM_WALKING_NORTH] = _G.indexQuads("body_brewer_walk_n", 16),
    [ANIM_WALKING_NORTHEAST] = _G.indexQuads("body_brewer_walk_ne", 16),
    [ANIM_WALKING_NORTHWEST] = _G.indexQuads("body_brewer_walk_nw", 16),
    [ANIM_WALKING_SOUTH] = _G.indexQuads("body_brewer_walk_s", 16),
    [ANIM_WALKING_SOUTHEAST] = _G.indexQuads("body_brewer_walk_se", 16),
    [ANIM_WALKING_SOUTHWEST] = _G.indexQuads("body_brewer_walk_sw", 16),
    [ANIM_WALKING_WEST] = _G.indexQuads("body_brewer_walk_w", 16),
    [ANIM_WALKING_HOPS_EAST] = _G.indexQuads("body_brewer_walk_herbs_e", 16),
    [ANIM_WALKING_HOPS_NORTH] = _G.indexQuads("body_brewer_walk_herbs_n", 16),
    [ANIM_WALKING_HOPS_NORTHEAST] = _G.indexQuads("body_brewer_walk_herbs_ne", 16),
    [ANIM_WALKING_HOPS_NORTHWEST] = _G.indexQuads("body_brewer_walk_herbs_nw", 16),
    [ANIM_WALKING_HOPS_SOUTH] = _G.indexQuads("body_brewer_walk_herbs_s", 16),
    [ANIM_WALKING_HOPS_SOUTHEAST] = _G.indexQuads("body_brewer_walk_herbs_se", 16),
    [ANIM_WALKING_HOPS_SOUTHWEST] = _G.indexQuads("body_brewer_walk_herbs_sw", 16),
    [ANIM_WALKING_HOPS_WEST] = _G.indexQuads("body_brewer_walk_herbs_w", 16),
    [ANIM_WALKING_BEER_EAST] = _G.indexQuads("body_brewer_walk_beer_e", 16),
    [ANIM_WALKING_BEER_NORTH] = _G.indexQuads("body_brewer_walk_beer_n", 16),
    [ANIM_WALKING_BEER_NORTHEAST] = _G.indexQuads("body_brewer_walk_beer_ne", 16),
    [ANIM_WALKING_BEER_NORTHWEST] = _G.indexQuads("body_brewer_walk_beer_nw", 16),
    [ANIM_WALKING_BEER_SOUTH] = _G.indexQuads("body_brewer_walk_beer_s", 16),
    [ANIM_WALKING_BEER_SOUTHEAST] = _G.indexQuads("body_brewer_walk_beer_se", 16),
    [ANIM_WALKING_BEER_SOUTHWEST] = _G.indexQuads("body_brewer_walk_beer_sw", 16),
    [ANIM_WALKING_BEER_WEST] = _G.indexQuads("body_brewer_walk_beer_w", 16),
    [ANIM_IDLE] = _G.indexQuads("body_brewer_idle", 16)
}

local Brewer = _G.class('Brewer', Worker)

function Brewer:initialize(gx, gy, type)
    Worker.initialize(self, gx, gy, type)
    self.state = 'Find a job'
    self.waitTimer = 0
    self.offsetY = -10
    self.offsetX = -5
    self.count = 1
    self.animation = anim.newAnimation(an[ANIM_WALKING_WEST], 10, nil, ANIM_WALKING_WEST)
end

function Brewer:load(data)
    Object.deserialize(self, data)
    Worker.load(self, data)
    local anData = data.animation
    if anData then
        self.animation = anim.newAnimation(an[anData.animationIdentifier], 1, nil, anData.animationIdentifier)
        self.animation:deserialize(anData)
    end
end

function Brewer:serialize()
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

function Brewer:dirSubUpdate()
    if self.moveDir == "west" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_BEER_WEST], 0.05, nil, ANIM_WALKING_BEER_WEST)
        elseif self.state == "Going to workplace with hops" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_HOPS_WEST], 0.05, nil, ANIM_WALKING_HOPS_WEST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_WEST], 0.05, nil, ANIM_WALKING_WEST)
        end
    elseif self.moveDir == "southwest" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_BEER_SOUTHWEST], 0.05, nil, ANIM_WALKING_BEER_SOUTHWEST)
        elseif self.state == "Going to workplace with hops" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_HOPS_SOUTHWEST], 0.05, nil, ANIM_WALKING_HOPS_SOUTHWEST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_SOUTHWEST], 0.05, nil, ANIM_WALKING_SOUTHWEST)
        end
    elseif self.moveDir == "northwest" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_BEER_NORTHWEST], 0.05, nil, ANIM_WALKING_BEER_NORTHWEST)
        elseif self.state == "Going to workplace with hops" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_HOPS_NORTHWEST], 0.05, nil, ANIM_WALKING_HOPS_NORTHWEST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_NORTHWEST], 0.05, nil, ANIM_WALKING_NORTHWEST)
        end
    elseif self.moveDir == "north" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_BEER_NORTH], 0.05, nil, ANIM_WALKING_BEER_NORTH)
        elseif self.state == "Going to workplace with hops" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_HOPS_NORTH], 0.05, nil, ANIM_WALKING_HOPS_NORTH)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_NORTH], 0.05, nil, ANIM_WALKING_NORTH)
        end
    elseif self.moveDir == "south" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_BEER_SOUTH], 0.05, nil, ANIM_WALKING_BEER_SOUTH)
        elseif self.state == "Going to workplace with hops" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_HOPS_SOUTH], 0.05, nil, ANIM_WALKING_HOPS_SOUTH)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_SOUTH], 0.05, nil, ANIM_WALKING_SOUTH)
        end
    elseif self.moveDir == "east" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_BEER_EAST], 0.05, nil, ANIM_WALKING_BEER_EAST)
        elseif self.state == "Going to workplace with hops" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_HOPS_EAST], 0.05, nil, ANIM_WALKING_HOPS_EAST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_EAST], 0.05, nil, ANIM_WALKING_EAST)
        end
    elseif self.moveDir == "southeast" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_BEER_SOUTHEAST], 0.05, nil, ANIM_WALKING_BEER_SOUTHEAST)
        elseif self.state == "Going to workplace with hops" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_HOPS_SOUTHEAST], 0.05, nil, ANIM_WALKING_HOPS_SOUTHEAST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_SOUTHEAST], 0.05, nil, ANIM_WALKING_SOUTHEAST)
        end
    elseif self.moveDir == "northeast" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_BEER_NORTHEAST], 0.05, nil, ANIM_WALKING_BEER_NORTHEAST)
        elseif self.state == "Going to workplace with hops" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_HOPS_NORTHEAST], 0.05, nil, ANIM_WALKING_HOPS_NORTHEAST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_NORTHEAST], 0.05, nil, ANIM_WALKING_NORTHEAST)
        end
    end
end

function Brewer:update()
    self.waitTimer = self.waitTimer + _G.dt
    if self.waitTimer > 1 then
        self.waitTimer = 0
        if self.state == "Waiting for hops" then
            self.waitTimer = 0
            local gotResource = _G.stockpile:take('hop')
            if not gotResource then
                self.state = "Waiting for hops"
                self.animation = anim.newAnimation(an[ANIM_IDLE], 0.05, nil, ANIM_IDLE)
                return
            else
                self.state = "Go to workplace with hops"
                self:clearPath()
                return
            end
        end
    end
    if self.pathState == "Waiting for path" then
        self:pathfind()
    elseif self.state == "Waiting for work" then
        self.workplace:work(self)
    elseif self.state ~= "No path to workplace" and self.state ~= "Working" then
        if self.state == "Find a job" then
            _G.JobController:findJob(self, "Brewer")
        elseif self.state == "Go to stockpile" or self.state == "Go to stockpile for hops" then
            if _G.stockpile then
                if self.state == "Go to stockpile" then
                    self.state = "Going to stockpile"
                else
                    self.state = "Going to stockpile for hops"
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
        elseif self.state == "Go to workplace" or self.state == "Go to workplace with hops" then
            if self.workplace.worker == self then
                self:requestPath(self.workplace.gx, self.workplace.gy + 4)
            elseif self.workplace.worker2 == self then
                self:requestPath(self.workplace.gx + 1, self.workplace.gy + 4)
            else
                self:requestPath(self.workplace.gx + 2, self.workplace.gy + 4)
            end
            if self.state == "Go to workplace with hops" then
                self.state = "Going to workplace with hops"
            else
                self.state = "Going to workplace"
            end
            self.moveDir = "none"
            return
        elseif self.moveDir == "none" and
            (self.state == "Going to workplace" or self.state == "Going to stockpile" or self.state ==
                "Going to workplace with hops" or self.state == "Going to stockpile for hops") then
            self:updateDirection()
            self:dirSubUpdate()
        end
        if (self.state == "Going to workplace" or self.state == "Going to stockpile" or self.state ==
            "Going to workplace with hops" or self.state == "Going to stockpile for hops") then
            self:move()
        end
        if self.fx * 0.001 == self.waypointX and self.fy * 0.001 == self.waypointY and self.moveDir ~= "none" then
            if self.state == "Going to workplace" or self.state == "Going to workplace with hops" then
                if self:reachedPathEnd() then
                    self.workplace:work(self)
                    return
                else
                    self:setNextWaypoint()

                end
                self.count = self.count + 1
            elseif self.state == "Going to stockpile for hops" or self.state == "Going to stockpile" then
                if self:reachedPathEnd() then
                    if self.state == "Going to stockpile" then
                        _G.stockpile:store('ale')
                    end
                    local gotResource = _G.stockpile:take('hop')
                    if not gotResource then
                        self.state = "Waiting for hops"
                        return
                    else
                        self.state = "Go to workplace with hops"
                        self:clearPath()
                        return
                    end
                else
                    self:setNextWaypoint()

                end
                self.count = self.count + 1
            end
        end
    end
end

function Brewer:animate()
    self:update()
    Worker.animate(self)
end

return Brewer
