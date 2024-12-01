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
-- iron
local ANIM_WALKING_INGOT_EAST = "walking_INGOT_east"
local ANIM_WALKING_INGOT_NORTH = "walking_INGOT_north"
local ANIM_WALKING_INGOT_NORTHEAST = "walking_INGOT_northeast"
local ANIM_WALKING_INGOT_NORTHWEST = "walking_INGOT_northwest"
local ANIM_WALKING_INGOT_SOUTH = "walking_INGOT_south"
local ANIM_WALKING_INGOT_SOUTHEAST = "walking_INGOT_southeast"
local ANIM_WALKING_INGOT_SOUTHWEST = "walking_INGOT_southwest"
local ANIM_WALKING_INGOT_WEST = "walking_INGOT_west"
-- armor
local ANIM_WALKING_SHIELD_EAST = "walking_SHIELD_east"
local ANIM_WALKING_SHIELD_NORTH = "walking_SHIELD_north"
local ANIM_WALKING_SHIELD_NORTHEAST = "walking_SHIELD_northeast"
local ANIM_WALKING_SHIELD_NORTHWEST = "walking_SHIELD_northwest"
local ANIM_WALKING_SHIELD_SOUTH = "walking_SHILED_south"
local ANIM_WALKING_SHIELD_SOUTHEAST = "walking_SHIELD_southeast"
local ANIM_WALKING_SHIELD_SOUTHWEST = "walking_SHIELD_southwest"
local ANIM_WALKING_SHIELD_WEST = "walking_SHIELD_west"

--idle
local ANIM_IDLE = "idle"
local ANIM_IDLE_STATIC = "idle_static"

local an = {
    [ANIM_WALKING_EAST] = _G.indexQuads("body_armourer_walk_e", 16),
    [ANIM_WALKING_NORTH] = _G.indexQuads("body_armourer_walk_n", 16),
    [ANIM_WALKING_NORTHEAST] = _G.indexQuads("body_armourer_walk_ne", 16),
    [ANIM_WALKING_NORTHWEST] = _G.indexQuads("body_armourer_walk_nw", 16),
    [ANIM_WALKING_SOUTH] = _G.indexQuads("body_armourer_walk_s", 16),
    [ANIM_WALKING_SOUTHEAST] = _G.indexQuads("body_armourer_walk_se", 16),
    [ANIM_WALKING_SOUTHWEST] = _G.indexQuads("body_armourer_walk_sw", 16),
    [ANIM_WALKING_WEST] = _G.indexQuads("body_armourer_walk_w", 16),
    [ANIM_WALKING_INGOT_EAST] = _G.indexQuads("body_armourer_walk_ingot_e", 16),
    [ANIM_WALKING_INGOT_NORTH] = _G.indexQuads("body_armourer_walk_ingot_n", 16),
    [ANIM_WALKING_INGOT_NORTHEAST] = _G.indexQuads("body_armourer_walk_ingot_ne", 16),
    [ANIM_WALKING_INGOT_NORTHWEST] = _G.indexQuads("body_armourer_walk_ingot_nw", 16),
    [ANIM_WALKING_INGOT_SOUTH] = _G.indexQuads("body_armourer_walk_ingot_s", 16),
    [ANIM_WALKING_INGOT_SOUTHEAST] = _G.indexQuads("body_armourer_walk_ingot_se", 16),
    [ANIM_WALKING_INGOT_SOUTHWEST] = _G.indexQuads("body_armourer_walk_ingot_sw", 16),
    [ANIM_WALKING_INGOT_WEST] = _G.indexQuads("body_armourer_walk_ingot_w", 16),
    [ANIM_WALKING_SHIELD_EAST] = _G.indexQuads("body_armourer_walk_shield_e", 16),
    [ANIM_WALKING_SHIELD_NORTH] = _G.indexQuads("body_armourer_walk_shield_n", 16),
    [ANIM_WALKING_SHIELD_NORTHEAST] = _G.indexQuads("body_armourer_walk_shield_ne", 16),
    [ANIM_WALKING_SHIELD_NORTHWEST] = _G.indexQuads("body_armourer_walk_shield_nw", 16),
    [ANIM_WALKING_SHIELD_SOUTH] = _G.indexQuads("body_armourer_walk_shield_s", 16),
    [ANIM_WALKING_SHIELD_SOUTHEAST] = _G.indexQuads("body_armourer_walk_shield_se", 16),
    [ANIM_WALKING_SHIELD_SOUTHWEST] = _G.indexQuads("body_armourer_walk_shield_sw", 16),
    [ANIM_WALKING_SHIELD_WEST] = _G.indexQuads("body_armourer_walk_shield_w", 16),

    [ANIM_IDLE] = _G.indexQuads("body_armourer_idle", 16),
}

local Armourer = _G.class('Armourer', Worker)

function Armourer:initialize(gx, gy, type)
    Worker.initialize(self, gx, gy, type)
    self:usePallete(2)
    self.state = 'Find a job'
    self.waitTimer = 0
    self.offsetY = -10
    self.offsetX = -5
    self.count = 1
    self.animation = anim.newAnimation(an[ANIM_WALKING_WEST], 10, nil, ANIM_WALKING_WEST)
end

function Armourer:dirSubUpdate()
    if self.moveDir == "west" then
        if self.state == "Going to armoury" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_SHIELD_WEST], 0.05, nil, ANIM_WALKING_SHIELD_WEST)
        elseif self.state == "Going to workplace with IRON" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_INGOT_WEST], 0.05, nil, ANIM_WALKING_INGOT_WEST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_WEST], 0.05, nil, ANIM_WALKING_WEST)
        end
    elseif self.moveDir == "southwest" then
        if self.state == "Going to armoury" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_SHIELD_SOUTHWEST], 0.05, nil, ANIM_WALKING_SHIELD_SOUTHWEST)
        elseif self.state == "Going to workplace with IRON" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_INGOT_SOUTHWEST], 0.05, nil, ANIM_WALKING_INGOT_SOUTHWEST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_SOUTHWEST], 0.05, nil, ANIM_WALKING_SOUTHWEST)
        end
    elseif self.moveDir == "northwest" then
        if self.state == "Going to armoury" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_SHIELD_NORTHWEST], 0.05, nil, ANIM_WALKING_SHIELD_NORTHWEST)
        elseif self.state == "Going to workplace with IRON" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_INGOT_NORTHWEST], 0.05, nil, ANIM_WALKING_INGOT_NORTHWEST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_NORTHWEST], 0.05, nil, ANIM_WALKING_NORTHWEST)
        end
    elseif self.moveDir == "north" then
        if self.state == "Going to armoury" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_SHIELD_NORTH], 0.05, nil, ANIM_WALKING_SHIELD_NORTH)
        elseif self.state == "Going to workplace with IRON" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_INGOT_NORTH], 0.05, nil, ANIM_WALKING_INGOT_NORTH)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_NORTH], 0.05, nil, ANIM_WALKING_NORTH)
        end
    elseif self.moveDir == "south" then
        if self.state == "Going to armoury" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_SHIELD_SOUTH], 0.05, nil, ANIM_WALKING_SHIELD_SOUTH)
        elseif self.state == "Going to workplace with IRON" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_INGOT_SOUTH], 0.05, nil, ANIM_WALKING_INGOT_SOUTH)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_SOUTH], 0.05, nil, ANIM_WALKING_SOUTH)
        end
    elseif self.moveDir == "east" then
        if self.state == "Going to armoury" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_SHIELD_EAST], 0.05, nil, ANIM_WALKING_SHIELD_EAST)
        elseif self.state == "Going to workplace with IRON" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_INGOT_EAST], 0.05, nil, ANIM_WALKING_INGOT_EAST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_EAST], 0.05, nil, ANIM_WALKING_EAST)
        end
    elseif self.moveDir == "southeast" then
        if self.state == "Going to armoury" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_SHIELD_SOUTHEAST], 0.05, nil, ANIM_WALKING_SHIELD_SOUTHEAST)
        elseif self.state == "Going to workplace with IRON" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_INGOT_SOUTHEAST], 0.05, nil, ANIM_WALKING_INGOT_SOUTHEAST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_SOUTHEAST], 0.05, nil, ANIM_WALKING_SOUTHEAST)
        end
    elseif self.moveDir == "northeast" then
        if self.state == "Going to armoury" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_SHIELD_NORTHEAST], 0.05, nil, ANIM_WALKING_SHIELD_NORTHEAST)
        elseif self.state == "Going to workplace with IRON" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_INGOT_NORTHEAST], 0.05, nil, ANIM_WALKING_INGOT_NORTHEAST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_NORTHEAST], 0.05, nil, ANIM_WALKING_NORTHEAST)
        end
    end
end

function Armourer:update()
    self.waitTimer = self.waitTimer + _G.dt
    if self.waitTimer > 1 then
        if self.state == "Waiting for IRON" then
            self.waitTimer = 0
            local gotResource = _G.stockpile:take('iron')
            if not gotResource then
                self.state = "Waiting for IRON"
                return
            else
                self.state = "Go to workplace with IRON"
                self:clearPath()
                return
            end
        end
    end
    if self.pathState == "Waiting for path" then
        self:pathfind()
    elseif self.state ~= "No path to workplace" and self.state ~= "Working" then
        if self.state == "Find a job" then
            _G.JobController:findJob(self, "Armourer")
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
        elseif self.state == "Go to stockpile for IRON" then
            if _G.stockpile then
                if self.state == "Go to stockpile" then
                    self.state = "Going to armoury"
                else
                    self.state = "Going to stockpile for IRON"
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
        elseif self.state == "Go to workplace" or self.state == "Go to workplace with IRON" then
            self:requestPathToStructure(self.workplace)
            if self.state == "Go to workplace with IRON" then
                self.state = "Going to workplace with IRON"
            else
                self.state = "Going to workplace"
            end
            self.moveDir = "none"
        elseif self.moveDir == "none" and
            (self.state == "Going to workplace" or self.state == "Going to armoury" or self.state ==
                "Going to workplace with IRON" or self.state == "Going to stockpile for IRON") then
            self:updateDirection()
            self:dirSubUpdate()
        end
        if (self.state == "Going to workplace" or self.state == "Going to armoury" or self.state ==
                "Going to workplace with IRON" or self.state == "Going to stockpile for IRON") then
            self:move()
        end
        if self:reachedWaypoint() then
            if self.state == "Going to workplace" or self.state == "Going to workplace with IRON" then
                if self:reachedPathEnd() then
                    self.workplace:work(self)
                    self:clearPath()
                    return
                else
                    self:setNextWaypoint()
                end
                self.count = self.count + 1
            elseif self.state == "Going to stockpile for IRON" then
                if self:reachedPathEnd() then
                    local gotResource = _G.stockpile:take('iron')
                    if not gotResource then
                        self.state = "Waiting for IRON"
                        self.animation = anim.newAnimation(an[ANIM_IDLE], 0.15, nil, ANIM_IDLE)
                        return
                    else
                        self.state = "Go to workplace with IRON"
                        self:clearPath()
                        return
                    end
                else
                    self:setNextWaypoint()
                end
                self.count = self.count + 1
            elseif self.state == "Going to armoury" then
                if self:reachedPathEnd() then
                    _G.weaponpile:store(WEAPON.shield)
                    self.state = "Go to stockpile for IRON"
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

function Armourer:animate()
    self:update()
    Worker.animate(self)
end

function Armourer:load(data)
    Object.deserialize(self, data)
    Worker.load(self, data)
    local anData = data.animation
    if anData then
        self.animation = anim.newAnimation(an[anData.animationIdentifier], 1, nil, anData.animationIdentifier)
        self.animation:deserialize(anData)
    end
end

function Armourer:serialize()
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

return Armourer
