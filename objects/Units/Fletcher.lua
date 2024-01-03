local _, _ = ...
local Worker = require("objects.Units.Worker")
local Object = require("objects.Object")
local anim = require("libraries.anim8")
local WEAPON = require("objects.Enums.Weapon")

local ANIM_WALKING_EAST = "walking_east"
local ANIM_WALKING_NORTH = "walking_north"
local ANIM_WALKING_NORTHEAST = "walking_northeast"
local ANIM_WALKING_NORTHWEST = "walking_northwest"
local ANIM_WALKING_SOUTH = "walking_south"
local ANIM_WALKING_SOUTHEAST = "walking_southeast"
local ANIM_WALKING_SOUTHWEST = "walking_southwest"
local ANIM_WALKING_WEST = "walking_west"
-- wood
local ANIM_WALKING_WOOD_EAST = "walking_WOOD_east"
local ANIM_WALKING_WOOD_NORTH = "walking_WOOD_north"
local ANIM_WALKING_WOOD_NORTHEAST = "walking_WOOD_northeast"
local ANIM_WALKING_WOOD_NORTHWEST = "walking_WOOD_northwest"
local ANIM_WALKING_WOOD_SOUTH = "walking_WOOD_south"
local ANIM_WALKING_WOOD_SOUTHEAST = "walking_WOOD_southeast"
local ANIM_WALKING_WOOD_SOUTHWEST = "walking_WOOD_southwest"
local ANIM_WALKING_WOOD_WEST = "walking_WOOD_west"
-- bow
local ANIM_WALKING_BOW_EAST = "walking_BOW_east"
local ANIM_WALKING_BOW_NORTH = "walking_BOW_north"
local ANIM_WALKING_BOW_NORTHEAST = "walking_BOW_northeast"
local ANIM_WALKING_BOW_NORTHWEST = "walking_BOW_northwest"
local ANIM_WALKING_BOW_SOUTH = "walking_BOW_south"
local ANIM_WALKING_BOW_SOUTHEAST = "walking_BOW_southeast"
local ANIM_WALKING_BOW_SOUTHWEST = "walking_BOW_southwest"
local ANIM_WALKING_BOW_WEST = "walking_BOW_west"
-- crossbow
local ANIM_WALKING_CROSSBOW_EAST = "walking_CROSSBOW_east"
local ANIM_WALKING_CROSSBOW_NORTH = "walking_CROSSBOW_north"
local ANIM_WALKING_CROSSBOW_NORTHEAST = "walking_CROSSBOW_northeast"
local ANIM_WALKING_CROSSBOW_NORTHWEST = "walking_CROSSBOW_northwest"
local ANIM_WALKING_CROSSBOW_SOUTH = "walking_CROSSBOW_south"
local ANIM_WALKING_CROSSBOW_SOUTHEAST = "walking_CROSSBOW_southeast"
local ANIM_WALKING_CROSSBOW_SOUTHWEST = "walking_CROSSBOW_southwest"
local ANIM_WALKING_CROSSBOW_WEST = "walking_CROSSBOW_west"

--idle
local ANIM_IDLE = "idle"
local ANIM_IDLE_STATIC = "idle_static"

local an = {
    [ANIM_WALKING_EAST] = _G.indexQuads("body_fletcher_walk_e", 16),
    [ANIM_WALKING_NORTH] = _G.indexQuads("body_fletcher_walk_n", 16),
    [ANIM_WALKING_NORTHEAST] = _G.indexQuads("body_fletcher_walk_ne", 16),
    [ANIM_WALKING_NORTHWEST] = _G.indexQuads("body_fletcher_walk_nw", 16),
    [ANIM_WALKING_SOUTH] = _G.indexQuads("body_fletcher_walk_s", 16),
    [ANIM_WALKING_SOUTHEAST] = _G.indexQuads("body_fletcher_walk_se", 16),
    [ANIM_WALKING_SOUTHWEST] = _G.indexQuads("body_fletcher_walk_sw", 16),
    [ANIM_WALKING_WEST] = _G.indexQuads("body_fletcher_walk_w", 16),
    [ANIM_WALKING_WOOD_EAST] = _G.indexQuads("body_fletcher_walk_plank_e", 16),
    [ANIM_WALKING_WOOD_NORTH] = _G.indexQuads("body_fletcher_walk_plank_n", 16),
    [ANIM_WALKING_WOOD_NORTHEAST] = _G.indexQuads("body_fletcher_walk_plank_ne", 16),
    [ANIM_WALKING_WOOD_NORTHWEST] = _G.indexQuads("body_fletcher_walk_plank_nw", 16),
    [ANIM_WALKING_WOOD_SOUTH] = _G.indexQuads("body_fletcher_walk_plank_s", 16),
    [ANIM_WALKING_WOOD_SOUTHEAST] = _G.indexQuads("body_fletcher_walk_plank_se", 16),
    [ANIM_WALKING_WOOD_SOUTHWEST] = _G.indexQuads("body_fletcher_walk_plank_sw", 16),
    [ANIM_WALKING_WOOD_WEST] = _G.indexQuads("body_fletcher_walk_plank_w", 16),
    [ANIM_WALKING_BOW_EAST] = _G.indexQuads("body_fletcher_walk_bow_e", 16),
    [ANIM_WALKING_BOW_NORTH] = _G.indexQuads("body_fletcher_walk_bow_n", 16),
    [ANIM_WALKING_BOW_NORTHEAST] = _G.indexQuads("body_fletcher_walk_bow_ne", 16),
    [ANIM_WALKING_BOW_NORTHWEST] = _G.indexQuads("body_fletcher_walk_bow_nw", 16),
    [ANIM_WALKING_BOW_SOUTH] = _G.indexQuads("body_fletcher_walk_bow_s", 16),
    [ANIM_WALKING_BOW_SOUTHEAST] = _G.indexQuads("body_fletcher_walk_bow_se", 16),
    [ANIM_WALKING_BOW_SOUTHWEST] = _G.indexQuads("body_fletcher_walk_bow_sw", 16),
    [ANIM_WALKING_BOW_WEST] = _G.indexQuads("body_fletcher_walk_bow_w", 16),
    [ANIM_WALKING_CROSSBOW_EAST] = _G.indexQuads("body_fletcher_walk_crossbow_e", 16),
    [ANIM_WALKING_CROSSBOW_NORTH] = _G.indexQuads("body_fletcher_walk_crossbow_n", 16),
    [ANIM_WALKING_CROSSBOW_NORTHEAST] = _G.indexQuads("body_fletcher_walk_crossbow_ne", 16),
    [ANIM_WALKING_CROSSBOW_NORTHWEST] = _G.indexQuads("body_fletcher_walk_crossbow_nw", 16),
    [ANIM_WALKING_CROSSBOW_SOUTH] = _G.indexQuads("body_fletcher_walk_crossbow_s", 16),
    [ANIM_WALKING_CROSSBOW_SOUTHEAST] = _G.indexQuads("body_fletcher_walk_crossbow_se", 16),
    [ANIM_WALKING_CROSSBOW_SOUTHWEST] = _G.indexQuads("body_fletcher_walk_crossbow_sw", 16),
    [ANIM_WALKING_CROSSBOW_WEST] = _G.indexQuads("body_fletcher_walk_crossbow_w", 16),
    [ANIM_WALKING_BOW_EAST] = _G.indexQuads("body_fletcher_walk_bow_e", 16),
    [ANIM_WALKING_BOW_NORTH] = _G.indexQuads("body_fletcher_walk_bow_n", 16),
    [ANIM_WALKING_BOW_NORTHEAST] = _G.indexQuads("body_fletcher_walk_bow_ne", 16),
    [ANIM_WALKING_BOW_NORTHWEST] = _G.indexQuads("body_fletcher_walk_bow_nw", 16),
    [ANIM_WALKING_BOW_SOUTH] = _G.indexQuads("body_fletcher_walk_bow_s", 16),
    [ANIM_WALKING_BOW_SOUTHEAST] = _G.indexQuads("body_fletcher_walk_bow_se", 16),
    [ANIM_WALKING_BOW_SOUTHWEST] = _G.indexQuads("body_fletcher_walk_bow_sw", 16),
    [ANIM_WALKING_BOW_WEST] = _G.indexQuads("body_fletcher_walk_bow_w", 16),

    [ANIM_IDLE] = _G.indexQuads("body_fletcher_idle", 16),
    [ANIM_IDLE_STATIC] = _G.indexQuads("body_fletcher_idle", 1)
}

local Fletcher = _G.class('Fletcher', Worker)

function Fletcher:initialize(gx, gy, type)
    Worker.initialize(self, gx, gy, type)
    self.state = 'Find a job'
    self.waitTimer = 0
    self.weaponType = WEAPON.bow
    self.offsetY = -10
    self.offsetX = -5
    self.count = 1
    self.animation = anim.newAnimation(an[ANIM_WALKING_WEST], 10, nil, ANIM_WALKING_WEST)
end

function Fletcher:dirSubUpdate()
    if self.moveDir == "west" then
        if self.state == "Going to armoury" and self.weaponType == WEAPON.bow then
            self.animation = anim.newAnimation(an[ANIM_WALKING_BOW_WEST], 0.05, nil, ANIM_WALKING_BOW_WEST)
        elseif self.state == "Going to armoury" and self.weaponType == WEAPON.crossbow then
            self.animation = anim.newAnimation(an[ANIM_WALKING_CROSSBOW_WEST], 0.05, nil, ANIM_WALKING_CROSSBOW_WEST)
        elseif self.state == "Going to workplace with WOOD" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_WOOD_WEST], 0.05, nil, ANIM_WALKING_WOOD_WEST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_WEST], 0.05, nil, ANIM_WALKING_WEST)
        end
    elseif self.moveDir == "southwest" then
        if self.state == "Going to armoury" and self.weaponType == WEAPON.bow then
            self.animation = anim.newAnimation(an[ANIM_WALKING_BOW_SOUTHWEST], 0.05, nil, ANIM_WALKING_BOW_SOUTHWEST)
        elseif self.state == "Going to armoury" and self.weaponType == WEAPON.crossbow then
            self.animation = anim.newAnimation(an[ANIM_WALKING_CROSSBOW_SOUTHWEST], 0.05, nil,
                ANIM_WALKING_CROSSBOW_SOUTHWEST)
        elseif self.state == "Going to workplace with WOOD" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_WOOD_SOUTHWEST], 0.05, nil, ANIM_WALKING_WOOD_SOUTHWEST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_SOUTHWEST], 0.05, nil, ANIM_WALKING_SOUTHWEST)
        end
    elseif self.moveDir == "northwest" then
        if self.state == "Going to armoury" and self.weaponType == WEAPON.bow then
            self.animation = anim.newAnimation(an[ANIM_WALKING_BOW_NORTHWEST], 0.05, nil, ANIM_WALKING_BOW_NORTHWEST)
        elseif self.state == "Going to armoury" and self.weaponType == WEAPON.crossbow then
            self.animation = anim.newAnimation(an[ANIM_WALKING_CROSSBOW_NORTHWEST], 0.05, nil,
                ANIM_WALKING_CROSSBOW_NORTHWEST)
        elseif self.state == "Going to workplace with WOOD" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_WOOD_NORTHWEST], 0.05, nil, ANIM_WALKING_WOOD_NORTHWEST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_NORTHWEST], 0.05, nil, ANIM_WALKING_NORTHWEST)
        end
    elseif self.moveDir == "north" then
        if self.state == "Going to armoury" and self.weaponType == WEAPON.bow then
            self.animation = anim.newAnimation(an[ANIM_WALKING_BOW_NORTH], 0.05, nil, ANIM_WALKING_BOW_NORTH)
        elseif self.state == "Going to armoury" and self.weaponType == WEAPON.crossbow then
            self.animation = anim.newAnimation(an[ANIM_WALKING_BOW_NORTH], 0.05, nil,
                ANIM_WALKING_BOW_NORTH)
        elseif self.state == "Going to workplace with WOOD" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_WOOD_NORTH], 0.05, nil, ANIM_WALKING_WOOD_NORTH)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_NORTH], 0.05, nil, ANIM_WALKING_NORTH)
        end
    elseif self.moveDir == "south" then
        if self.state == "Going to armoury" and self.weaponType == WEAPON.bow then
            self.animation = anim.newAnimation(an[ANIM_WALKING_BOW_SOUTH], 0.05, nil, ANIM_WALKING_BOW_SOUTH)
        elseif self.state == "Going to armoury" and self.weaponType == WEAPON.crossbow then
            self.animation = anim.newAnimation(an[ANIM_WALKING_BOW_SOUTH], 0.05, nil,
                ANIM_WALKING_BOW_SOUTH)
        elseif self.state == "Going to workplace with WOOD" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_WOOD_SOUTH], 0.05, nil, ANIM_WALKING_WOOD_SOUTH)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_SOUTH], 0.05, nil, ANIM_WALKING_SOUTH)
        end
    elseif self.moveDir == "east" then
        if self.state == "Going to armoury" and self.weaponType == WEAPON.bow then
            self.animation = anim.newAnimation(an[ANIM_WALKING_BOW_EAST], 0.05, nil, ANIM_WALKING_BOW_EAST)
        elseif self.state == "Going to armoury" and self.weaponType == WEAPON.crossbow then
            self.animation = anim.newAnimation(an[ANIM_WALKING_CROSSBOW_EAST], 0.05, nil,
                ANIM_WALKING_CROSSBOW_EAST)
        elseif self.state == "Going to workplace with WOOD" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_WOOD_EAST], 0.05, nil, ANIM_WALKING_WOOD_EAST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_EAST], 0.05, nil, ANIM_WALKING_EAST)
        end
    elseif self.moveDir == "southeast" then
        if self.state == "Going to armoury" and self.weaponType == WEAPON.bow then
            self.animation = anim.newAnimation(an[ANIM_WALKING_BOW_SOUTHEAST], 0.05, nil, ANIM_WALKING_BOW_SOUTHEAST)
        elseif self.state == "Going to armoury" and self.weaponType == WEAPON.crossbow then
            self.animation = anim.newAnimation(an[ANIM_WALKING_CROSSBOW_SOUTHEAST], 0.05, nil,
                ANIM_WALKING_CROSSBOW_SOUTHEAST)
        elseif self.state == "Going to workplace with WOOD" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_WOOD_SOUTHEAST], 0.05, nil, ANIM_WALKING_WOOD_SOUTHEAST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_SOUTHEAST], 0.05, nil, ANIM_WALKING_SOUTHEAST)
        end
    elseif self.moveDir == "northeast" then
        if self.state == "Going to armoury" and self.weaponType == WEAPON.bow then
            self.animation = anim.newAnimation(an[ANIM_WALKING_BOW_NORTHEAST], 0.05, nil, ANIM_WALKING_BOW_NORTHEAST)
        elseif self.state == "Going to armoury" and self.weaponType == WEAPON.crossbow then
            self.animation = anim.newAnimation(an[ANIM_WALKING_CROSSBOW_NORTHEAST], 0.05, nil,
                ANIM_WALKING_CROSSBOW_NORTHEAST)
        elseif self.state == "Going to workplace with WOOD" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_WOOD_NORTHEAST], 0.05, nil, ANIM_WALKING_WOOD_NORTHEAST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_NORTHEAST], 0.05, nil, ANIM_WALKING_NORTHEAST)
        end
    end
end

function Fletcher:update()
    self.waitTimer = self.waitTimer + _G.dt
    if self.waitTimer > 1 then
        if self.state == "Waiting for WOOD" then
            self.waitTimer = 0
            local gotResource = _G.stockpile:take('wood')
            if not gotResource then
                self.state = "Waiting for WOOD"
                return
            else
                self.state = "Go to workplace with WOOD"
                self:clearPath()
                return
            end
        end
    end
    if self.pathState == "Waiting for path" then
        self:pathfind()
    elseif self.state ~= "No path to workplace" and self.state ~= "Working" then
        if self.state == "Find a job" then
            _G.JobController:findJob(self, "Fletcher")
        elseif self.state == "Go to armoury" or self.state == "Wait" then
            if next(_G.weaponpile.nodeList) ~= nil then
                self.state = "Going to armoury"
                local closestNode
                local distance = math.huge
                for _, v in ipairs(_G.weaponpile.nodeList) do
                    local tmp = _G.manhattanDistance(v.gx, v.gy, self.gx, self.gy)
                    if tmp < distance then
                        distance = tmp
                        closestNode = v
                    end
                end
                if not closestNode then
                    print("Closest weaponpile node not found")
                    self.state = "Wait"
                else
                    self:requestPath(closestNode.gx, closestNode.gy)
                end
                self.moveDir = "none"
            end
        elseif self.state == "Go to stockpile for WOOD" then
            if _G.stockpile then
                if self.state == "Go to stockpile" then
                    self.state = "Going to armoury"
                else
                    self.state = "Going to stockpile for WOOD"
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
        elseif self.state == "Go to workplace" or self.state == "Go to workplace with WOOD" then
            self:requestPathToStructure(self.workplace)
            if self.state == "Go to workplace with WOOD" then
                self.state = "Going to workplace with WOOD"
            else
                self.state = "Going to workplace"
            end
            self.moveDir = "none"
        elseif self.moveDir == "none" and
            (self.state == "Going to workplace" or self.state == "Going to armoury" or self.state ==
                "Going to workplace with WOOD" or self.state == "Going to stockpile for WOOD") then
            self:updateDirection()
            self:dirSubUpdate()
        end
        if (self.state == "Going to workplace" or self.state == "Going to armoury" or self.state ==
                "Going to workplace with WOOD" or self.state == "Going to stockpile for WOOD") then
            self:move()
        end
        if self:reachedWaypoint() then
            if self.state == "Going to workplace" or self.state == "Going to workplace with WOOD" then
                if self:reachedPathEnd() then
                    self.workplace:work(self)
                    self:clearPath()
                    return
                else
                    self:setNextWaypoint()
                end
                self.count = self.count + 1
            elseif self.state == "Going to stockpile for WOOD" then
                if self:reachedPathEnd() then
                    local gotResource = _G.stockpile:take('wood')
                    if not gotResource then
                        self.state = "Waiting for WOOD"
                        self.animation = anim.newAnimation(an[ANIM_IDLE], 0.15, nil, ANIM_IDLE)
                        return
                    else
                        self.state = "Go to workplace with WOOD"
                        self:clearPath()
                        return
                    end
                else
                    self:setNextWaypoint()
                end
                self.count = self.count + 1
            elseif self.state == "Going to armoury" then
                if self:reachedPathEnd() then
                    if self.weaponType == WEAPON.bow then
                        _G.weaponpile:store(WEAPON.bow)
                    else
                        _G.weaponpile:store(WEAPON.crossbow)
                    end
                    self.state = "Go to stockpile for WOOD"
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

function Fletcher:animate()
    self:update()
    Worker.animate(self)
end

function Fletcher:load(data)
    Object.deserialize(self, data)
    Worker.load(self, data)
    local anData = data.animation
    if anData then
        self.animation = anim.newAnimation(an[anData.animationIdentifier], 1, nil, anData.animationIdentifier)
        self.animation:deserialize(anData)
    end
end

function Fletcher:serialize()
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
    data.weaponType = self.weaponType
    data.offsetY = self.offsetY
    data.offsetX = self.offsetX
    data.count = self.count
    return data
end

return Fletcher
