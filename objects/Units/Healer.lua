local _, _ = ...
local Worker = require("objects.Units.Worker")
local Object = require("objects.Object")
local anim = require("libraries.anim8")

local fr_walking_healer_walk_east = _G.indexQuads("body_healer_walk_e", 16)
local fr_walking_healer_walk_north = _G.indexQuads("body_healer_walk_n", 16)
local fr_walking_healer_walk_west = _G.indexQuads("body_healer_walk_w", 16)
local fr_walking_healer_walk_south = _G.indexQuads("body_healer_walk_s", 16)
local fr_walking_healer_walk_northeast = _G.indexQuads("body_healer_walk_ne", 16)
local fr_walking_healer_walk_northwest = _G.indexQuads("body_healer_walk_nw", 16)
local fr_walking_healer_walk_southeast = _G.indexQuads("body_healer_walk_se", 16)
local fr_walking_healer_walk_southwest = _G.indexQuads("body_healer_walk_sw", 16)
local fr_healing_healer_east = _G.indexQuads("body_healer_heal_e", 16)
local fr_healing_healer_north = _G.indexQuads("body_healer_heal_n", 16)
local fr_healing_healer_west = _G.indexQuads("body_healer_heal_w", 16)
local fr_healing_healer_south = _G.indexQuads("body_healer_heal_s", 16)
local fr_healing_healer_northeast = _G.indexQuads("body_healer_heal_ne", 16)
local fr_healing_healer_northwest = _G.indexQuads("body_healer_heal_nw", 16)
local fr_healing_healer_southeast = _G.indexQuads("body_healer_heal_se", 16)
local fr_healing_healer_southwest = _G.indexQuads("body_healer_heal_sw", 16)

local idle = indexQuads("body_healer_heal_s", 16)
local idle_loop = indexQuads("body_healer_heal_s", 16, 1, true)

local WALKING_healer_EAST = "walking_healer_east"
local WALKING_healer_NORTH = "walking_healer_north"
local WALKING_healer_WEST = "walking_healer_west"
local WALKING_healer_SOUTH = "walking_healer_south"
local WALKING_healer_NORTHEAST = "walking_healer_northeast"
local WALKING_healer_NORTHWEST = "walking_healer_northwest"
local WALKING_healer_SOUTHEAST = "walking_healer_southeast"
local WALKING_healer_SOUTHWEST = "walking_healer_southwest"
local HEALING_healer_EAST = "healing_healer_east"
local HEALING_healer_NORTH = "healing_healer_north"
local HEALING_healer_WEST = "healing_healer_west"
local HEALING_healer_SOUTH = "healing_healer_south"
local HEALING_healer_NORTHEAST = "healing_healer_northeast"
local HEALING_healer_NORTHWEST = "healing_healer_northwest"
local HEALING_healer_SOUTHEAST = "healing_healer_southeast"
local HEALING_healer_SOUTHWEST = "healing_healer_southwest"
local IDLE = "idle"
local IDLE_LOOP = "idle_loop"

local an = {
    [WALKING_healer_EAST] = fr_walking_healer_walk_east,
    [WALKING_healer_NORTH] = fr_walking_healer_walk_north,
    [WALKING_healer_WEST] = fr_walking_healer_walk_west,
    [WALKING_healer_SOUTH] = fr_walking_healer_walk_south,
    [WALKING_healer_NORTHEAST] = fr_walking_healer_walk_northeast,
    [WALKING_healer_NORTHWEST] = fr_walking_healer_walk_northwest,
    [WALKING_healer_SOUTHEAST] = fr_walking_healer_walk_southeast,
    [WALKING_healer_SOUTHWEST] = fr_walking_healer_walk_southwest,
    [HEALING_healer_EAST] = fr_healing_healer_east,
    [HEALING_healer_NORTH] = fr_healing_healer_north,
    [HEALING_healer_WEST] = fr_healing_healer_west,
    [HEALING_healer_SOUTH] = fr_healing_healer_south,
    [HEALING_healer_NORTHEAST] = fr_healing_healer_northeast,
    [HEALING_healer_NORTHWEST] = fr_healing_healer_northwest,
    [HEALING_healer_SOUTHEAST] = fr_healing_healer_southeast,
    [HEALING_healer_SOUTHWEST] = fr_healing_healer_southwest,
    [IDLE] = idle,
    [IDLE_LOOP] = idle_loop
}

local SEARCH_RADIUS = 90
local WORK_DURATION = 12

local Healer = _G.class('Healer', Worker)

function Healer:initialize(gx, gy, type)
    Worker.initialize(self, gx, gy, type)
    self.workplace = nil
    self.state = 'Find a job'
    self.waitTimer = 0
    self.offsetX = -5
    self.offsetY = -10
    self.buildingsInArea = {}
    self.count = 1
    self.healedStructures = 1
    self.animation = anim.newAnimation(an[WALKING_healer_WEST], 10, nil, WALKING_healer_WEST)
end

function Healer:getRandomBuildingInArea()
    local buildings = _G.BuildingManager:getAllNearbyBuildings(self.workplace, SEARCH_RADIUS)
        for _, building in ipairs(buildings) do
        if building.class.name ~= "Stockpile" then
                table.insert(self.buildingsInArea, building)
        end
    end
end

function Healer:healCallback()
    if self.state == "healing" or (self.state == "Going to heal" and self.waypointX == nil) then
        if  #self.buildingsInArea > 1 then
            print("Number of buildings to heal ", #self.buildingsInArea)
            self.state = "Looking to heal"
            self.moveDir = "none"
            table.remove(self.buildingsInArea, 1)
        else
            self.animation:pause()
            self.moveDir = "none"
            self.state = "Going to workplace"
            self:requestPath(self.workplace.gx + 3, self.workplace.gy + 6, function() self:onNoPathToWorkplace() end)
            self.buildingsInArea = {}
        end
    end
end

function Healer:dirSubUpdate()
    if self.moveDir == "west" then
        if self.state == "Going to heal" or self.state == "Going to workplace" then
            self.animation = anim.newAnimation(an[WALKING_healer_WEST], 0.05, nil, WALKING_healer_WEST)
        end
    elseif self.moveDir == "southwest" then
        if self.state == "Going to heal" or self.state == "Going to workplace" then
            self.animation = anim.newAnimation(an[WALKING_healer_SOUTHWEST], 0.05, nil, WALKING_healer_SOUTHWEST)
        end
    elseif self.moveDir == "northwest" then
        if self.state == "Going to heal" or self.state == "Going to workplace" then
            self.animation = anim.newAnimation(an[WALKING_healer_NORTHWEST], 0.05, nil, WALKING_healer_NORTHWEST)
        end
    elseif self.moveDir == "north" then
        if self.state == "Going to heal" or self.state == "Going to workplace" then
            self.animation = anim.newAnimation(an[WALKING_healer_NORTH], 0.05, nil, WALKING_healer_NORTH)
        end
    elseif self.moveDir == "south" then
        if self.state == "Going to heal" or self.state == "Going to workplace" then
            self.animation = anim.newAnimation(an[WALKING_healer_SOUTH], 0.05, nil, WALKING_healer_SOUTH)
        end
    elseif self.moveDir == "east" then
        if self.state == "Going to heal" or self.state == "Going to workplace" then
            self.animation = anim.newAnimation(an[WALKING_healer_EAST], 0.05, nil, WALKING_healer_EAST)
        end
    elseif self.moveDir == "southeast" then
        if self.state == "Going to heal" or self.state == "Going to workplace" then
            self.animation = anim.newAnimation(an[WALKING_healer_SOUTHEAST], 0.05, nil, WALKING_healer_SOUTHEAST)
        end
    elseif self.moveDir == "northeast" then
        if self.state == "Going to heal" or self.state == "Going to workplace" then
            self.animation = anim.newAnimation(an[WALKING_healer_NORTHEAST], 0.05, nil, WALKING_healer_NORTHEAST)
        end
    end
end

function Healer:findStructures()
    if #self.buildingsInArea < 1 then
        self:getRandomBuildingInArea()
    end

    local objt = self.buildingsInArea[1]

    if not objt then
        self.animation = _G.anim.newAnimation(an[IDLE], 0.11, nil, IDLE)
        self.state = "No structures"
        self:onNoPathToWorkplace()
        return
    end

    self.endx = objt.gx + math.floor(objt.class.WIDTH / 2) --healer goes in front of the building
    self.endy = objt.gy + objt.class.LENGTH + 1
    if self.endx == self.gx and self.endy == self.gy then
        self.state = "healing"
        self.animation = anim.newAnimation(an[WALKING_healer_NORTHEAST], 0.08, function() self:healCallback() end, WALKING_healer_NORTHEAST)
        self:clearPath()
        return
    else
        self.state = "Going to heal"
        self.moveDir = "none"
        -- TODO see if thats walkable
        self:requestPath(self.endx, self.endy, function() self:onNoPathToheal() end)
        return
    end
end

function Healer:update()
    if self.state == "Working in workplace" then
        self.waitTimer = self.waitTimer + _G.dt
        if self.waitTimer > WORK_DURATION then
            self.state = "Looking to heal"
            self.waitTimer = 0
            return
        end
    end
    if self.pathState == "Waiting for path" then
        self:pathfind()
        if self.animation and self.animation.animationIdentifier ~= IDLE then
            self.animation = _G.anim.newAnimation(an[IDLE], 0.11, nil, IDLE)
        end
    elseif self.pathState == "No path" then --Can happen if path for healig target fails two times
        self.state = "Working in workplace"
        self.workplace:work(self)
        self.pathState = "none"
    elseif self.state == "Find a job" then
        _G.JobController:findJob(self, "healer")
    elseif self.state ~= "No structures" then
        if self.state == "Looking to heal" then
            self:findStructures()
        elseif self.state == "Go to workplace" then
            self:requestPath(self.workplace.gx + 3, self.workplace.gy + 6, function() self:onNoPathToWorkplace() end)
            self.state = "Going to workplace"
            self.moveDir = "none"
        elseif self.state == "Going to heal" or self.state == "Going to workplace" or self.state == "Going to waypoint" then
            if self.moveDir == "none" then
                self:updateDirection()
                self:dirSubUpdate()
            end
            self:move()
        end
        if self.fx * 0.001 == self.waypointX and self.fy * 0.001 == self.waypointY and self.moveDir ~= "none" then
            if self.state == "Going to heal" then
                if self:reachedPathEnd() then
                    self.state = "healing"
                    self.animation = anim.newAnimation(an[HEALING_healer_NORTHEAST], 0.08, function() self:healCallback() end, HEALING_healer_NORTHEAST)
                    self:clearPath()
                    return
                else
                    self:setNextWaypoint()
                end
                self.count = self.count + 1
            elseif self.state == "Going to workplace" then
                if self:reachedPathEnd() then
                    self.state = "Working in workplace"
                    self.workplace:work(self)
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

function Healer:jobUpdate()
    _G.removeObjectAt(self.lrcx, self.lrcy, self.lrx, self.lry, self)
    _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
    self.instancemesh = nil
    self.animation = nil
end

function Healer:onNoPathToWorkplace()
    self.workplace.float:activate()
    local Peasant = require("objects.Units.Peasant")
    self.toBeDeleted = true
    _G.freeVertexFromTile(self.cx, self.cy, self.previousVertId)
    self.animation = nil
    _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
    _G.removeObjectAt(self.cx, self.cy, self.i, self.o, self)
    if _G.campfire.peasants < _G.campfire.maxPeasants then
        Peasant:new(_G.spawnPointX, _G.spawnPointY)
    end
end

function Healer:animate()
    self:update()
    Worker.animate(self)
end

function Healer:load(data)
    Object.deserialize(self, data)
    Worker.load(self, data)
    self:getRandomBuildingInArea()
    local anData = data.animation
    if anData then
        local callback
        if string.find(anData.animationIdentifier, "healing") then
            callback = function() self:healCallback() end
        end
        self.animation = anim.newAnimation(an[anData.animationIdentifier], 1, callback, anData.animationIdentifier)
        self.animation:deserialize(anData)
    end
end

function Healer:serialize()
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
    data.buildingsInArea = {}
    data.healedStructures = self.healedStructures
    return data
end

function Healer:onNoPathToheal()
    self.state = "Looking to heal"
    self:clearPath()
    self:findStructures()
end

return Healer
