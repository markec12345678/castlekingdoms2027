local _, _ = ...
local Worker = require("objects.Units.Worker")
local Object = require("objects.Object")
local anim = require("libraries.anim8")
local FOOD = require("objects.Enums.Food")

local fr_walking_cheese_east = _G.indexQuads("body_farmer_walk_cheese_e", 16)
local fr_walking_cheese_north = _G.indexQuads("body_farmer_walk_cheese_n", 16)
local fr_walking_cheese_west = _G.indexQuads("body_farmer_walk_cheese_w", 16)
local fr_walking_cheese_south = _G.indexQuads("body_farmer_walk_cheese_s", 16)
local fr_walking_cheese_northeast = _G.indexQuads("body_farmer_walk_cheese_ne", 16)
local fr_walking_cheese_northwest = _G.indexQuads("body_farmer_walk_cheese_nw", 16)
local fr_walking_cheese_southeast = _G.indexQuads("body_farmer_walk_cheese_se", 16)
local fr_walking_cheese_southwest = _G.indexQuads("body_farmer_walk_cheese_sw", 16)
local fr_walking_east = _G.indexQuads("body_farmer_walk_e", 16)
local fr_walking_north = _G.indexQuads("body_farmer_walk_n", 16)
local fr_walking_northeast = _G.indexQuads("body_farmer_walk_ne", 16)
local fr_walking_northwest = _G.indexQuads("body_farmer_walk_nw", 16)
local fr_walking_south = _G.indexQuads("body_farmer_walk_s", 16)
local fr_walking_southeast = _G.indexQuads("body_farmer_walk_se", 16)
local fr_walking_southwest = _G.indexQuads("body_farmer_walk_sw", 16)
local fr_walking_west = _G.indexQuads("body_farmer_walk_w", 16)
local fr_gather_cheese_east = _G.indexQuads("body_farmer_actual_cheese_e", 10)

local idle = indexQuads("body_farmer_idle", 16)
local idle_loop = indexQuads("body_farmer_idle", 16, 12, true)

local WALKING_cheese_EAST = "walking_cheese_east"
local WALKING_cheese_NORTH = "walking_cheese_north"
local WALKING_cheese_WEST = "walking_cheese_west"
local WALKING_cheese_SOUTH = "walking_cheese_south"
local WALKING_cheese_NORTHEAST = "walking_cheese_northeast"
local WALKING_cheese_NORTHWEST = "walking_cheese_northwest"
local WALKING_cheese_SOUTHEAST = "walking_cheese_southeast"
local WALKING_cheese_SOUTHWEST = "walking_cheese_southwest"
local WALKING_EAST = "walking_east"
local WALKING_NORTH = "walking_north"
local WALKING_NORTHEAST = "walking_northeast"
local WALKING_NORTHWEST = "walking_northwest"
local WALKING_SOUTH = "walking_south"
local WALKING_SOUTHEAST = "walking_southeast"
local WALKING_SOUTHWEST = "walking_southwest"
local WALKING_WEST = "walking_west"
local GATHER_cheese_EAST = "gather_cheese_east"
local IDLE = "idle"
local IDLE_LOOP = "idle_loop"

local an = {
    [WALKING_cheese_EAST] = fr_walking_cheese_east,
    [WALKING_cheese_NORTH] = fr_walking_cheese_north,
    [WALKING_cheese_WEST] = fr_walking_cheese_west,
    [WALKING_cheese_SOUTH] = fr_walking_cheese_south,
    [WALKING_cheese_NORTHEAST] = fr_walking_cheese_northeast,
    [WALKING_cheese_NORTHWEST] = fr_walking_cheese_northwest,
    [WALKING_cheese_SOUTHEAST] = fr_walking_cheese_southeast,
    [WALKING_cheese_SOUTHWEST] = fr_walking_cheese_southwest,
    [WALKING_EAST] = fr_walking_east,
    [WALKING_NORTH] = fr_walking_north,
    [WALKING_NORTHEAST] = fr_walking_northeast,
    [WALKING_NORTHWEST] = fr_walking_northwest,
    [WALKING_SOUTH] = fr_walking_south,
    [WALKING_SOUTHEAST] = fr_walking_southeast,
    [WALKING_SOUTHWEST] = fr_walking_southwest,
    [WALKING_WEST] = fr_walking_west,
    [GATHER_cheese_EAST] = fr_gather_cheese_east,
    [IDLE] = idle,
    [IDLE_LOOP] = idle_loop
}

local DairyFarmer = _G.class('DairyFarmer', Worker)

function DairyFarmer:initialize(gx, gy, type)
    Worker.initialize(self, gx, gy, type)
    self.state = 'Find a job'
    self.waitTimer = 0
    self.offsetY = -10
    self.offsetX = -5
    self.count = 1
    self.animation = anim.newAnimation(an[WALKING_WEST], 10, nil, WALKING_WEST)
end

function DairyFarmer:dirSubUpdate()
    if self.moveDir == "west" then
        if self.state == "Going to foodpile" then
            self.animation = anim.newAnimation(an[WALKING_cheese_WEST], 0.05, nil, WALKING_cheese_WEST)
        else
            self.animation = anim.newAnimation(an[WALKING_WEST], 0.05, nil, WALKING_WEST)
        end
    elseif self.moveDir == "southwest" then
        if self.state == "Going to foodpile" then
            self.animation = anim.newAnimation(an[WALKING_cheese_SOUTHWEST], 0.05, nil, WALKING_cheese_SOUTHWEST)
        else
            self.animation = anim.newAnimation(an[WALKING_SOUTHWEST], 0.05, nil, WALKING_SOUTHWEST)
        end
    elseif self.moveDir == "northwest" then
        if self.state == "Going to foodpile" then
            self.animation = anim.newAnimation(an[WALKING_cheese_NORTHWEST], 0.05, nil, WALKING_cheese_NORTHWEST)
        else
            self.animation = anim.newAnimation(an[WALKING_NORTHWEST], 0.05, nil, WALKING_NORTHWEST)
        end
    elseif self.moveDir == "north" then
        if self.state == "Going to foodpile" then
            self.animation = anim.newAnimation(an[WALKING_cheese_NORTH], 0.05, nil, WALKING_cheese_NORTH)
        else
            self.animation = anim.newAnimation(an[WALKING_NORTH], 0.05, nil, WALKING_NORTH)
        end
    elseif self.moveDir == "south" then
        if self.state == "Going to foodpile" then
            self.animation = anim.newAnimation(an[WALKING_cheese_SOUTH], 0.05, nil, WALKING_cheese_SOUTH)
        else
            self.animation = anim.newAnimation(an[WALKING_SOUTH], 0.05, nil, WALKING_SOUTH)
        end
    elseif self.moveDir == "east" then
        if self.state == "Going to foodpile" then
            self.animation = anim.newAnimation(an[WALKING_cheese_EAST], 0.05, nil, WALKING_cheese_EAST)
        else
            self.animation = anim.newAnimation(an[WALKING_EAST], 0.05, nil, WALKING_EAST)
        end
    elseif self.moveDir == "southeast" then
        if self.state == "Going to foodpile" then
            self.animation = anim.newAnimation(an[WALKING_cheese_SOUTHEAST], 0.05, nil, WALKING_cheese_SOUTHEAST)
        else
            self.animation = anim.newAnimation(an[WALKING_SOUTHEAST], 0.05, nil, WALKING_SOUTHEAST)
        end
    elseif self.moveDir == "northeast" then
        if self.state == "Going to foodpile" then
            self.animation = anim.newAnimation(an[WALKING_cheese_NORTHEAST], 0.05, nil, WALKING_cheese_NORTHEAST)
        else
            self.animation = anim.newAnimation(an[WALKING_NORTHEAST], 0.05, nil, WALKING_NORTHEAST)
        end
    end
end

function DairyFarmer:update()
    self.waitTimer = self.waitTimer + _G.dt
    if self.pathState == "Waiting for path" then
        self:pathfind()
    elseif self.state ~= "No path to workplace" and self.state ~= "Working" then
        if self.state == "Find a job" then
            _G.JobController:findJob(self, "DairyFarmer")
        elseif self.state == "Waiting" then
            self.workplace:work(self)
        elseif self.state == "Go to foodpile" or self.state == "Wait" then
            if next(_G.foodpile.nodeList) ~= nil then
                self.state = "Going to foodpile"
                local closestNode
                local distance = math.huge
                for _, v in ipairs(_G.foodpile.nodeList) do
                    local tmp = _G.manhattanDistance(v.gx, v.gy, self.gx, self.gy)
                    if tmp < distance then
                        distance = tmp
                        closestNode = v
                    end
                end
                if not closestNode then
                    print("Closest foodpile node not found")
                    self.state = "Wait"
                else
                    self:requestPath(closestNode.gx, closestNode.gy)
                end
                self.moveDir = "none"
            end
        elseif self.state == "Go to workplace" then
            self:requestPath(self.workplace.gx + 1, self.workplace.gy + 4)
            self.state = "Going to workplace"
            self.moveDir = "none"
        elseif self.moveDir == "none" and
            (self.state == "Going to workplace" or self.state == "Going to foodpile") then
            self:updateDirection()
            self:dirSubUpdate()
        end
        if (self.state == "Going to workplace" or self.state == "Going to foodpile") then
            self:move()
        end
        if self.fx * 0.001 == self.waypointX and self.fy * 0.001 == self.waypointY and self.moveDir ~= "none" then
            if self.state == "Going to workplace" then
                if self:reachedPathEnd() then
                    self.workplace:work(self)
                    if self.state == "Waiting" then
                        self.animation = anim.newAnimation(an[IDLE], 0.05, "pauseAtEnd", IDLE)
                    end
                    self:clearPath()
                    return
                else
                    self:setNextWaypoint()
                end
                self.count = self.count + 1
            elseif self.state == "Going to foodpile" then
                if self:reachedPathEnd() then
                    _G.foodpile:store(FOOD.cheese)
                    self.state = "Go to workplace"
                    self:clearPath()
                    return
                else
                    self:setNextWaypoint()
                end
                self.count = self.count + 1
            end
        end
    end
end

function DairyFarmer:animate()
    self:update()
    Worker.animate(self)
end

function DairyFarmer:load(data)
    Object.deserialize(self, data)
    Worker.load(self, data)
    local anData = data.animation
    if anData then
        self.animation = anim.newAnimation(an[anData.animationIdentifier], 1, nil, anData.animationIdentifier)
        self.animation:deserialize(anData)
    end
end

function DairyFarmer:serialize()
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

return DairyFarmer
