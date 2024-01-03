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
-- ingot
local ANIM_WALKING_INGOT_EAST = "walking_INGOT_east"
local ANIM_WALKING_INGOT_NORTH = "walking_INGOT_north"
local ANIM_WALKING_INGOT_NORTHEAST = "walking_INGOT_northeast"
local ANIM_WALKING_INGOT_NORTHWEST = "walking_INGOT_northwest"
local ANIM_WALKING_INGOT_SOUTH = "walking_INGOT_south"
local ANIM_WALKING_INGOT_SOUTHEAST = "walking_INGOT_southeast"
local ANIM_WALKING_INGOT_SOUTHWEST = "walking_INGOT_southwest"
local ANIM_WALKING_INGOT_WEST = "walking_INGOT_west"
-- sword
local ANIM_WALKING_SWORD_EAST = "walking_SWORD_east"
local ANIM_WALKING_SWORD_NORTH = "walking_SWORD_north"
local ANIM_WALKING_SWORD_NORTHEAST = "walking_SWORD_northeast"
local ANIM_WALKING_SWORD_NORTHWEST = "walking_SWORD_northwest"
local ANIM_WALKING_SWORD_SOUTH = "walking_SWORD_south"
local ANIM_WALKING_SWORD_SOUTHEAST = "walking_SWORD_southeast"
local ANIM_WALKING_SWORD_SOUTHWEST = "walking_SWORD_southwest"
local ANIM_WALKING_SWORD_WEST = "walking_SWORD_west"
-- mace
local ANIM_WALKING_MACE_EAST = "walking_MACE_east"
local ANIM_WALKING_MACE_NORTH = "walking_MACE_north"
local ANIM_WALKING_MACE_NORTHEAST = "walking_MACE_northeast"
local ANIM_WALKING_MACE_NORTHWEST = "walking_MACE_northwest"
local ANIM_WALKING_MACE_SOUTH = "walking_MACE_south"
local ANIM_WALKING_MACE_SOUTHEAST = "walking_MACE_southeast"
local ANIM_WALKING_MACE_SOUTHWEST = "walking_MACE_southwest"
local ANIM_WALKING_MACE_WEST = "walking_MACE_west"

--idle
local ANIM_IDLE = "idle"
local ANIM_IDLE_STATIC = "idle_static"

local an = {
    [ANIM_WALKING_EAST] = _G.indexQuads("body_blacksmith_walk_e", 16),
    [ANIM_WALKING_NORTH] = _G.indexQuads("body_blacksmith_walk_n", 16),
    [ANIM_WALKING_NORTHEAST] = _G.indexQuads("body_blacksmith_walk_ne", 16),
    [ANIM_WALKING_NORTHWEST] = _G.indexQuads("body_blacksmith_walk_nw", 16),
    [ANIM_WALKING_SOUTH] = _G.indexQuads("body_blacksmith_walk_s", 16),
    [ANIM_WALKING_SOUTHEAST] = _G.indexQuads("body_blacksmith_walk_se", 16),
    [ANIM_WALKING_SOUTHWEST] = _G.indexQuads("body_blacksmith_walk_sw", 16),
    [ANIM_WALKING_WEST] = _G.indexQuads("body_blacksmith_walk_w", 16),
    [ANIM_WALKING_INGOT_EAST] = _G.indexQuads("body_blacksmith_walk_ingot_e", 16),
    [ANIM_WALKING_INGOT_NORTH] = _G.indexQuads("body_blacksmith_walk_ingot_n", 16),
    [ANIM_WALKING_INGOT_NORTHEAST] = _G.indexQuads("body_blacksmith_walk_ingot_ne", 16),
    [ANIM_WALKING_INGOT_NORTHWEST] = _G.indexQuads("body_blacksmith_walk_ingot_nw", 16),
    [ANIM_WALKING_INGOT_SOUTH] = _G.indexQuads("body_blacksmith_walk_ingot_s", 16),
    [ANIM_WALKING_INGOT_SOUTHEAST] = _G.indexQuads("body_blacksmith_walk_ingot_se", 16),
    [ANIM_WALKING_INGOT_SOUTHWEST] = _G.indexQuads("body_blacksmith_walk_ingot_sw", 16),
    [ANIM_WALKING_INGOT_WEST] = _G.indexQuads("body_blacksmith_walk_ingot_w", 16),
    [ANIM_WALKING_SWORD_EAST] = _G.indexQuads("body_blacksmith_walk_sword_e", 16),
    [ANIM_WALKING_SWORD_NORTH] = _G.indexQuads("body_blacksmith_walk_sword_n", 16),
    [ANIM_WALKING_SWORD_NORTHEAST] = _G.indexQuads("body_blacksmith_walk_sword_ne", 16),
    [ANIM_WALKING_SWORD_NORTHWEST] = _G.indexQuads("body_blacksmith_walk_sword_nw", 16),
    [ANIM_WALKING_SWORD_SOUTH] = _G.indexQuads("body_blacksmith_walk_sword_s", 16),
    [ANIM_WALKING_SWORD_SOUTHEAST] = _G.indexQuads("body_blacksmith_walk_sword_se", 16),
    [ANIM_WALKING_SWORD_SOUTHWEST] = _G.indexQuads("body_blacksmith_walk_sword_sw", 16),
    [ANIM_WALKING_SWORD_WEST] = _G.indexQuads("body_blacksmith_walk_sword_w", 16),
    [ANIM_WALKING_MACE_EAST] = _G.indexQuads("body_blacksmith_walk_mace_e", 16),
    [ANIM_WALKING_MACE_NORTH] = _G.indexQuads("body_blacksmith_walk_mace_n", 16),
    [ANIM_WALKING_MACE_NORTHEAST] = _G.indexQuads("body_blacksmith_walk_mace_ne", 16),
    [ANIM_WALKING_MACE_NORTHWEST] = _G.indexQuads("body_blacksmith_walk_mace_nw", 16),
    [ANIM_WALKING_MACE_SOUTH] = _G.indexQuads("body_blacksmith_walk_mace_s", 16),
    [ANIM_WALKING_MACE_SOUTHEAST] = _G.indexQuads("body_blacksmith_walk_mace_se", 16),
    [ANIM_WALKING_MACE_SOUTHWEST] = _G.indexQuads("body_blacksmith_walk_mace_sw", 16),
    [ANIM_WALKING_MACE_WEST] = _G.indexQuads("body_blacksmith_walk_mace_w", 16),

    [ANIM_IDLE] = _G.indexQuads("body_blacksmith_idle", 16),
    [ANIM_IDLE_STATIC] = _G.indexQuads("body_blacksmith_idle", 1)
}

local Blacksmith = _G.class('Blacksmith', Worker)

function Blacksmith:initialize(gx, gy, type)
    Worker.initialize(self, gx, gy, type)
    self.state = 'Find a job'
    self.waitTimer = 0
    self.weaponType = WEAPON.sword
    self.offsetY = -10
    self.offsetX = -5
    self.count = 1
    self.animation = anim.newAnimation(an[ANIM_WALKING_WEST], 10, nil, ANIM_WALKING_WEST)
end

function Blacksmith:dirSubUpdate()
    if self.moveDir == "west" then
        if self.state == "Going to armoury" and self.weaponType == WEAPON.sword then
            self.animation = anim.newAnimation(an[ANIM_WALKING_SWORD_WEST], 0.05, nil, ANIM_WALKING_SWORD_WEST)
        elseif self.state == "Going to armoury" and self.weaponType == WEAPON.mace then
            self.animation = anim.newAnimation(an[ANIM_WALKING_MACE_WEST], 0.05, nil, ANIM_WALKING_MACE_WEST)
        elseif self.state == "Going to workplace with INGOT" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_INGOT_WEST], 0.05, nil, ANIM_WALKING_INGOT_WEST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_WEST], 0.05, nil, ANIM_WALKING_WEST)
        end
    elseif self.moveDir == "southwest" then
        if self.state == "Going to armoury" and self.weaponType == WEAPON.sword then
            self.animation = anim.newAnimation(an[ANIM_WALKING_SWORD_SOUTHWEST], 0.05, nil, ANIM_WALKING_SWORD_SOUTHWEST)
        elseif self.state == "Going to armoury" and self.weaponType == WEAPON.mace then
            self.animation = anim.newAnimation(an[ANIM_WALKING_MACE_SOUTHWEST], 0.05, nil, ANIM_WALKING_MACE_SOUTHWEST)
        elseif self.state == "Going to workplace with INGOT" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_INGOT_SOUTHWEST], 0.05, nil, ANIM_WALKING_INGOT_SOUTHWEST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_SOUTHWEST], 0.05, nil, ANIM_WALKING_SOUTHWEST)
        end
    elseif self.moveDir == "northwest" then
        if self.state == "Going to armoury" and self.weaponType == WEAPON.sword then
            self.animation = anim.newAnimation(an[ANIM_WALKING_SWORD_NORTHWEST], 0.05, nil, ANIM_WALKING_SWORD_NORTHWEST)
        elseif self.state == "Going to armoury" and self.weaponType == WEAPON.mace then
            self.animation = anim.newAnimation(an[ANIM_WALKING_MACE_NORTHWEST], 0.05, nil, ANIM_WALKING_MACE_NORTHWEST)
        elseif self.state == "Going to workplace with INGOT" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_INGOT_NORTHWEST], 0.05, nil, ANIM_WALKING_INGOT_NORTHWEST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_NORTHWEST], 0.05, nil, ANIM_WALKING_NORTHWEST)
        end
    elseif self.moveDir == "north" then
        if self.state == "Going to armoury" and self.weaponType == WEAPON.sword then
            self.animation = anim.newAnimation(an[ANIM_WALKING_SWORD_NORTH], 0.05, nil, ANIM_WALKING_SWORD_NORTH)
        elseif self.state == "Going to armoury" and self.weaponType == WEAPON.mace then
            self.animation = anim.newAnimation(an[ANIM_WALKING_MACE_NORTH], 0.05, nil, ANIM_WALKING_MACE_NORTH)
        elseif self.state == "Going to workplace with INGOT" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_INGOT_NORTH], 0.05, nil, ANIM_WALKING_INGOT_NORTH)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_NORTH], 0.05, nil, ANIM_WALKING_NORTH)
        end
    elseif self.moveDir == "south" then
        if self.state == "Going to armoury" and self.weaponType == WEAPON.sword then
            self.animation = anim.newAnimation(an[ANIM_WALKING_SWORD_SOUTH], 0.05, nil, ANIM_WALKING_SWORD_SOUTH)
        elseif self.state == "Going to armoury" and self.weaponType == WEAPON.mace then
            self.animation = anim.newAnimation(an[ANIM_WALKING_MACE_SOUTH], 0.05, nil, ANIM_WALKING_MACE_SOUTH)
        elseif self.state == "Going to workplace with INGOT" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_INGOT_SOUTH], 0.05, nil, ANIM_WALKING_INGOT_SOUTH)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_SOUTH], 0.05, nil, ANIM_WALKING_SOUTH)
        end
    elseif self.moveDir == "east" then
        if self.state == "Going to armoury" and self.weaponType == WEAPON.sword then
            self.animation = anim.newAnimation(an[ANIM_WALKING_SWORD_EAST], 0.05, nil, ANIM_WALKING_SWORD_EAST)
        elseif self.state == "Going to armoury" and self.weaponType == WEAPON.mace then
            self.animation = anim.newAnimation(an[ANIM_WALKING_MACE_EAST], 0.05, nil, ANIM_WALKING_MACE_EAST)
        elseif self.state == "Going to workplace with INGOT" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_INGOT_EAST], 0.05, nil, ANIM_WALKING_INGOT_EAST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_EAST], 0.05, nil, ANIM_WALKING_EAST)
        end
    elseif self.moveDir == "southeast" then
        if self.state == "Going to armoury" and self.weaponType == WEAPON.sword then
            self.animation = anim.newAnimation(an[ANIM_WALKING_SWORD_SOUTHEAST], 0.05, nil, ANIM_WALKING_SWORD_SOUTHEAST)
        elseif self.state == "Going to armoury" and self.weaponType == WEAPON.mace then
            self.animation = anim.newAnimation(an[ANIM_WALKING_MACE_SOUTHEAST], 0.05, nil, ANIM_WALKING_MACE_SOUTHEAST)
        elseif self.state == "Going to workplace with INGOT" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_INGOT_SOUTHEAST], 0.05, nil, ANIM_WALKING_INGOT_SOUTHEAST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_SOUTHEAST], 0.05, nil, ANIM_WALKING_SOUTHEAST)
        end
    elseif self.moveDir == "northeast" then
        if self.state == "Going to armoury" and self.weaponType == WEAPON.sword then
            self.animation = anim.newAnimation(an[ANIM_WALKING_SWORD_NORTHEAST], 0.05, nil, ANIM_WALKING_SWORD_NORTHEAST)
        elseif self.state == "Going to armoury" and self.weaponType == WEAPON.mace then
            self.animation = anim.newAnimation(an[ANIM_WALKING_MACE_NORTHEAST], 0.05, nil, ANIM_WALKING_MACE_NORTHEAST)
        elseif self.state == "Going to workplace with INGOT" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_INGOT_NORTHEAST], 0.05, nil, ANIM_WALKING_INGOT_NORTHEAST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_NORTHEAST], 0.05, nil, ANIM_WALKING_NORTHEAST)
        end
    end
end

function Blacksmith:update()
    self.waitTimer = self.waitTimer + _G.dt
    if self.waitTimer > 1 then
        if self.state == "Waiting for INGOT" then
            self.waitTimer = 0
            local gotResource = _G.stockpile:take('iron')
            if not gotResource then
                self.state = "Waiting for INGOT"
                return
            else
                self.state = "Go to workplace with INGOT"
                self:clearPath()
                return
            end
        end
    end
    if self.pathState == "Waiting for path" then
        self:pathfind()
    elseif self.state ~= "No path to workplace" and self.state ~= "Working" then
        if self.state == "Find a job" then
            _G.JobController:findJob(self, "Blacksmith")
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
        elseif self.state == "Go to stockpile for INGOT" then
            if _G.stockpile then
                if self.state == "Go to stockpile" then
                    self.state = "Going to armoury"
                else
                    self.state = "Going to stockpile for INGOT"
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
        elseif self.state == "Go to workplace" or self.state == "Go to workplace with INGOT" then
            self:requestPathToStructure(self.workplace)
            if self.state == "Go to workplace with INGOT" then
                self.state = "Going to workplace with INGOT"
            else
                self.state = "Going to workplace"
            end
            self.moveDir = "none"
        elseif self.moveDir == "none" and
            (self.state == "Going to workplace" or self.state == "Going to armoury" or self.state ==
                "Going to workplace with INGOT" or self.state == "Going to stockpile for INGOT") then
            self:updateDirection()
            self:dirSubUpdate()
        end
        if (self.state == "Going to workplace" or self.state == "Going to armoury" or self.state ==
                "Going to workplace with INGOT" or self.state == "Going to stockpile for INGOT") then
            self:move()
        end
        if self:reachedWaypoint() then
            if self.state == "Going to workplace" or self.state == "Going to workplace with INGOT" then
                if self:reachedPathEnd() then
                    self.workplace:work(self)
                    self:clearPath()
                    return
                else
                    self:setNextWaypoint()
                end
                self.count = self.count + 1
            elseif self.state == "Going to stockpile for INGOT" then
                if self:reachedPathEnd() then
                    local gotResource = _G.stockpile:take('iron')
                    if not gotResource then
                        self.state = "Waiting for INGOT"
                        self.animation = anim.newAnimation(an[ANIM_IDLE], 0.15, nil, ANIM_IDLE)
                        return
                    else
                        self.state = "Go to workplace with INGOT"
                        self:clearPath()
                        return
                    end
                else
                    self:setNextWaypoint()
                end
                self.count = self.count + 1
            elseif self.state == "Going to armoury" then
                if self:reachedPathEnd() then
                    if self.weaponType == WEAPON.sword then
                        _G.weaponpile:store(WEAPON.sword)
                    else
                        _G.weaponpile:store(WEAPON.mace)
                    end
                    self.state = "Go to stockpile for INGOT"
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

function Blacksmith:animate()
    self:update()
    Worker.animate(self)
end

function Blacksmith:load(data)
    Object.deserialize(self, data)
    Worker.load(self, data)
    local anData = data.animation
    if anData then
        self.animation = anim.newAnimation(an[anData.animationIdentifier], 1, nil, anData.animationIdentifier)
        self.animation:deserialize(anData)
    end
end

function Blacksmith:serialize()
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

return Blacksmith
