local _, _ = ...

local Unit = require("objects.Units.Unit")
local Object = require("objects.Object")
local anim = require("libraries.anim8")

local ANIM_WALKING_EAST = "Walking_East"
local ANIM_WALKING_NORTH = "Walking_North"
local ANIM_WALKING_NORTHEAST = "Walking_Northeast"
local ANIM_WALKING_NORTHWEST = "Walking_Northwest"
local ANIM_WALKING_SOUTH = "Walking_South"
local ANIM_WALKING_SOUTHEAST = "Walking_Southeast"
local ANIM_WALKING_SOUTHWEST = "Walking_Southwest"
local ANIM_WALKING_WEST = "Walking_West"
local ANIM_WALKING_IRON_EAST = "Walking_Iron_East"
local ANIM_WALKING_IRON_NORTH = "Walking_Iron_North"
local ANIM_WALKING_IRON_NORTHEAST = "Walking_Iron_Northeast"
local ANIM_WALKING_IRON_NORTHWEST = "Walking_Iron_Northwest"
local ANIM_WALKING_IRON_SOUTH = "Walking_Iron_South"
local ANIM_WALKING_IRON_SOUTHEAST = "Walking_Iron_Southeast"
local ANIM_WALKING_IRON_SOUTHWEST = "Walking_Iron_Southwest"
local ANIM_WALKING_IRON_WEST = "Walking_Iron_West"

local an = {
    [ANIM_WALKING_EAST] = _G.indexQuads("body_iron_miner_walk_e", 16),
    [ANIM_WALKING_NORTH] = _G.indexQuads("body_iron_miner_walk_n", 16),
    [ANIM_WALKING_NORTHEAST] = _G.indexQuads("body_iron_miner_walk_ne", 16),
    [ANIM_WALKING_NORTHWEST] = _G.indexQuads("body_iron_miner_walk_nw", 16),
    [ANIM_WALKING_SOUTH] = _G.indexQuads("body_iron_miner_walk_s", 16),
    [ANIM_WALKING_SOUTHEAST] = _G.indexQuads("body_iron_miner_walk_se", 16),
    [ANIM_WALKING_SOUTHWEST] = _G.indexQuads("body_iron_miner_walk_sw", 16),
    [ANIM_WALKING_WEST] = _G.indexQuads("body_iron_miner_walk_w", 16),
    [ANIM_WALKING_IRON_EAST] = _G.indexQuads("body_iron_miner_walk_ingot_e", 16),
    [ANIM_WALKING_IRON_NORTH] = _G.indexQuads("body_iron_miner_walk_ingot_n", 16),
    [ANIM_WALKING_IRON_NORTHEAST] = _G.indexQuads("body_iron_miner_walk_ingot_ne", 16),
    [ANIM_WALKING_IRON_NORTHWEST] = _G.indexQuads("body_iron_miner_walk_ingot_nw", 16),
    [ANIM_WALKING_IRON_SOUTH] = _G.indexQuads("body_iron_miner_walk_ingot_s", 16),
    [ANIM_WALKING_IRON_SOUTHEAST] = _G.indexQuads("body_iron_miner_walk_ingot_se", 16),
    [ANIM_WALKING_IRON_SOUTHWEST] = _G.indexQuads("body_iron_miner_walk_ingot_sw", 16),
    [ANIM_WALKING_IRON_WEST] = _G.indexQuads("body_iron_miner_walk_ingot_w", 16)
}

local Miner = _G.class('Miner', Unit)

function Miner:initialize(gx, gy, type)
    Unit.initialize(self, gx, gy, type)
    self.state = 'Find a job'
    self.eatTimer = 0
    self.offsetY = -10
    self.offsetX = -5
    self.count = 1
    self.animation = anim.newAnimation(an[ANIM_WALKING_WEST], 10, nil, ANIM_WALKING_WEST)
end

function Miner:dirSubUpdate()
    if self.moveDir == "west" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_IRON_WEST], 0.05, nil, ANIM_WALKING_IRON_WEST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_WEST], 0.05, nil, ANIM_WALKING_WEST)
        end
    elseif self.moveDir == "southwest" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_IRON_SOUTHWEST], 0.05, nil, ANIM_WALKING_IRON_SOUTHWEST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_SOUTHWEST], 0.05, nil, ANIM_WALKING_SOUTHWEST)
        end
    elseif self.moveDir == "northwest" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_IRON_NORTHWEST], 0.05, nil, ANIM_WALKING_IRON_NORTHWEST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_NORTHWEST], 0.05, nil, ANIM_WALKING_NORTHWEST)
        end
    elseif self.moveDir == "north" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_IRON_NORTH], 0.05, nil, ANIM_WALKING_IRON_NORTH)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_NORTH], 0.05, nil, ANIM_WALKING_NORTH)
        end
    elseif self.moveDir == "south" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_IRON_SOUTH], 0.05, nil, ANIM_WALKING_IRON_SOUTH)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_SOUTH], 0.05, nil, ANIM_WALKING_SOUTH)
        end
    elseif self.moveDir == "east" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_IRON_EAST], 0.05, nil, ANIM_WALKING_IRON_EAST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_EAST], 0.05, nil, ANIM_WALKING_EAST)
        end
    elseif self.moveDir == "southeast" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_IRON_SOUTHEAST], 0.05, nil, ANIM_WALKING_IRON_SOUTHEAST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_SOUTHEAST], 0.05, nil, ANIM_WALKING_SOUTHEAST)
        end
    elseif self.moveDir == "northeast" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_IRON_NORTHEAST], 0.05, nil, ANIM_WALKING_IRON_NORTHEAST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_NORTHEAST], 0.05, nil, ANIM_WALKING_NORTHEAST)
        end
    end
end

function Miner:update()
    self.eatTimer = self.eatTimer + 1
    if self.eatTimer > 3000 then
        _G.foodpile:take()
        self.eatTimer = 0
    end
    if self.pathState == "Waiting for path" then
        self:pathfind()
    elseif self.state ~= "No path to workplace" and self.state ~= "Working" then
        if self.state == "Find a job" then
            _G.JobController:findJob(self, "Miner")
        elseif self.state == "Go to stockpile" then
            if _G.stockpile then
                self.state = "Going to stockpile"
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
            self:requestPath(self.workplace.gx - 1, self.workplace.gy + 1)
            self.state = "Going to workplace"
            self.moveDir = "none"
        elseif self.moveDir == "none" and self.state == "Going to workplace" then
            self:updateDirection()
            self:dirSubUpdate()
        elseif self.moveDir == "none" and self.state == "Going to stockpile" then
            self:updateDirection()
            self:dirSubUpdate()
        end
        if self.state == "Going to workplace" or self.state == "Going to stockpile" then
            self:move()
        end
        if self.fx * 0.001 == self.waypointX and self.fy * 0.001 == self.waypointY and self.moveDir ~= "none" then
            if self.state == "Going to workplace" then
                if self:reachedPathEnd() then
                    self.workplace:work(self)
                    self:clearPath()
                    return
                else
                    self:setNextWaypoint()
                end
                self.count = self.count + 1
            elseif self.state == "Going to stockpile" then
                if self:reachedPathEnd() then
                    _G.stockpile:store('iron')
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
function Miner:animate()
    self:update()
    Unit.animate(self)
end
function Miner:load(data)
    Object.deserialize(self, data)
    Unit.load(self, data)
    local anData = data.animation
    if anData then
        self.animation = anim.newAnimation(an[anData.animationIdentifier], 1, nil, anData.animationIdentifier)
        self.animation:deserialize(anData)
    end
end
function Miner:serialize()
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
    data.eatTimer = self.eatTimer
    data.offsetY = self.offsetY
    data.offsetX = self.offsetX
    data.count = self.count
    return data
end

return Miner
