local _, _ = ...

local Unit = require("objects.Units.Unit")
local Object = require("objects.Object")
local anim = require("libraries.anim8")

local fr_walking_stone_east = _G.indexQuads("body_stonemason_walk_stone_e", 16)
local fr_walking_stone_north = _G.indexQuads("body_stonemason_walk_stone_n", 16)
local fr_walking_stone_west = _G.indexQuads("body_stonemason_walk_stone_w", 16)
local fr_walking_stone_south = _G.indexQuads("body_stonemason_walk_stone_s", 16)
local fr_walking_stone_northeast = _G.indexQuads("body_stonemason_walk_stone_ne", 16)
local fr_walking_stone_northwest = _G.indexQuads("body_stonemason_walk_stone_nw", 16)
local fr_walking_stone_southeast = _G.indexQuads("body_stonemason_walk_stone_se", 16)
local fr_walking_stone_southwest = _G.indexQuads("body_stonemason_walk_stone_sw", 16)
local fr_walking_east = _G.indexQuads("body_stonemason_walk_e", 16)
local fr_walking_north = _G.indexQuads("body_stonemason_walk_n", 16)
local fr_walking_northeast = _G.indexQuads("body_stonemason_walk_ne", 16)
local fr_walking_northwest = _G.indexQuads("body_stonemason_walk_nw", 16)
local fr_walking_south = _G.indexQuads("body_stonemason_walk_s", 16)
local fr_walking_southeast = _G.indexQuads("body_stonemason_walk_se", 16)
local fr_walking_southwest = _G.indexQuads("body_stonemason_walk_sw", 16)
local fr_walking_west = _G.indexQuads("body_stonemason_walk_w", 16)

local ANIM_WALKING_STONE_EAST = "walking_stone_east"
local ANIM_WALKING_STONE_NORTH = "walking_stone_north"
local ANIM_WALKING_STONE_WEST = "walking_stone_west"
local ANIM_WALKING_STONE_SOUTH = "walking_stone_south"
local ANIM_WALKING_STONE_NORTHEAST = "walking_stone_northeast"
local ANIM_WALKING_STONE_NORTHWEST = "walking_stone_northwest"
local ANIM_WALKING_STONE_SOUTHEAST = "walking_stone_southeast"
local ANIM_WALKING_STONE_SOUTHWEST = "walking_stone_southwest"
local ANIM_WALKING_EAST = "walking_east"
local ANIM_WALKING_NORTH = "walking_north"
local ANIM_WALKING_NORTHEAST = "walking_northeast"
local ANIM_WALKING_NORTHWEST = "walking_northwest"
local ANIM_WALKING_SOUTH = "walking_south"
local ANIM_WALKING_SOUTHEAST = "walking_southeast"
local ANIM_WALKING_SOUTHWEST = "walking_southwest"
local ANIM_WALKING_WEST = "walking_west"

local an = {
    [ANIM_WALKING_STONE_EAST] = fr_walking_stone_east,
    [ANIM_WALKING_STONE_NORTH] = fr_walking_stone_north,
    [ANIM_WALKING_STONE_WEST] = fr_walking_stone_west,
    [ANIM_WALKING_STONE_SOUTH] = fr_walking_stone_south,
    [ANIM_WALKING_STONE_NORTHEAST] = fr_walking_stone_northeast,
    [ANIM_WALKING_STONE_NORTHWEST] = fr_walking_stone_northwest,
    [ANIM_WALKING_STONE_SOUTHEAST] = fr_walking_stone_southeast,
    [ANIM_WALKING_STONE_SOUTHWEST] = fr_walking_stone_southwest,
    [ANIM_WALKING_EAST] = fr_walking_east,
    [ANIM_WALKING_NORTH] = fr_walking_north,
    [ANIM_WALKING_NORTHEAST] = fr_walking_northeast,
    [ANIM_WALKING_NORTHWEST] = fr_walking_northwest,
    [ANIM_WALKING_SOUTH] = fr_walking_south,
    [ANIM_WALKING_SOUTHEAST] = fr_walking_southeast,
    [ANIM_WALKING_SOUTHWEST] = fr_walking_southwest,
    [ANIM_WALKING_WEST] = fr_walking_west
}
local Stonemason = _G.class("Stonemason", Unit)
Stonemason.static.animations = an
function Stonemason:initialize(gx, gy, type)
    Unit.initialize(self, gx, gy, type)
    self.workplace = nil
    self.state = "Find a job"
    self.count = 1
    self.offsetY = -10
    self.offsetX = -5
    self.eatTimer = 0
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_WALKING_WEST], 10, nil, ANIM_WALKING_WEST)
end
function Stonemason:dirSubUpdate()
    if self.moveDir == "west" then
        if self.state == "Going to stockpile" or self.state == "Going to workplace with stone" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_STONE_WEST], 0.05, nil, ANIM_WALKING_STONE_WEST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_WEST], 0.05, nil, ANIM_WALKING_WEST)
        end
    elseif self.moveDir == "southwest" then
        if self.state == "Going to stockpile" or self.state == "Going to workplace with stone" then
            self.animation =
                anim.newAnimation(an[ANIM_WALKING_STONE_SOUTHWEST], 0.05, nil, ANIM_WALKING_STONE_SOUTHWEST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_SOUTHWEST], 0.05, nil, ANIM_WALKING_SOUTHWEST)
        end
    elseif self.moveDir == "northwest" then
        if self.state == "Going to stockpile" or self.state == "Going to workplace with stone" then
            self.animation =
                anim.newAnimation(an[ANIM_WALKING_STONE_NORTHWEST], 0.05, nil, ANIM_WALKING_STONE_NORTHWEST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_NORTHWEST], 0.05, nil, ANIM_WALKING_NORTHWEST)
        end
    elseif self.moveDir == "north" then
        if self.state == "Going to stockpile" or self.state == "Going to workplace with stone" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_STONE_NORTH], 0.05, nil, ANIM_WALKING_STONE_NORTH)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_NORTH], 0.05, nil, ANIM_WALKING_NORTH)
        end
    elseif self.moveDir == "south" then
        if self.state == "Going to stockpile" or self.state == "Going to workplace with stone" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_STONE_SOUTH], 0.05, nil, ANIM_WALKING_STONE_SOUTH)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_SOUTH], 0.05, nil, ANIM_WALKING_SOUTH)
        end
    elseif self.moveDir == "east" then
        if self.state == "Going to stockpile" or self.state == "Going to workplace with stone" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_STONE_EAST], 0.05, nil, ANIM_WALKING_STONE_EAST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_EAST], 0.05, nil, ANIM_WALKING_EAST)
        end
    elseif self.moveDir == "southeast" then
        if self.state == "Going to stockpile" or self.state == "Going to workplace with stone" then
            self.animation =
                anim.newAnimation(an[ANIM_WALKING_STONE_SOUTHEAST], 0.05, nil, ANIM_WALKING_STONE_SOUTHEAST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_SOUTHEAST], 0.05, nil, ANIM_WALKING_SOUTHEAST)
        end
    elseif self.moveDir == "northeast" then
        if self.state == "Going to stockpile" or self.state == "Going to workplace with stone" then
            self.animation =
                anim.newAnimation(an[ANIM_WALKING_STONE_NORTHEAST], 0.05, nil, ANIM_WALKING_STONE_NORTHEAST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_NORTHEAST], 0.05, nil, ANIM_WALKING_NORTHEAST)
        end
    end
end
function Stonemason:update()
    self.eatTimer = self.eatTimer + 1
    if self.eatTimer > 3000 then
        _G.foodpile:take()
        self.eatTimer = 0
    end
    if self.pathState == "Waiting for path" then
        self:pathfind()
    elseif self.state ~= "No path to quarry" and self.state ~= "Working" then
        if self.state == "Find a job" then
            _G.JobController:findJob(self, "Stonemason")
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
                    print("Closest stockpile node not found")
                else
                    self:requestPath(closestNode.gx, closestNode.gy)
                end
                self.moveDir = "none"
            end
        elseif self.state == "Go to workplace" then
            if self.workplace.liftWorker == self then
                self:requestPath(self.workplace.gx + 6, self.workplace.gy + 3)
                self.state = "Going to workplace"
                self.moveDir = "none"

            elseif self.workplace.pullWorker == self then
                self:requestPath(self.workplace.gx + 5, self.workplace.gy - 1)
                self.state = "Going to workplace"
                self.moveDir = "none"

            elseif self.workplace.shapeWorker == self then
                self:requestPath(self.workplace.gx + 1, self.workplace.gy + 6)
                self.state = "Going to workplace"
                self.moveDir = "none"
            end
        elseif self.moveDir == "none" and self.state == "Going to workplace" then
            self:updateDirection()
        elseif self.moveDir == "none" and self.state == "Going to stockpile" then
            self:updateDirection()
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
                    _G.stockpile:store("stone")
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
function Stonemason:animate()
    self:update()
    Unit.animate(self)
end
function Stonemason:load(data)
    Object.deserialize(self, data)
    Unit.load(self, data)
    local anData = data.animation
    if anData then
        self.animation = anim.newAnimation(an[anData.animationIdentifier], 1, nil, anData.animationIdentifier)
        self.animation:deserialize(anData)
    end
end
function Stonemason:serialize()
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
    data.animated = self.animated
    data.count = self.count
    return data
end
return Stonemason
