local _, _ = ...
local Worker = require("objects.Units.Worker")
local Object = require("objects.Object")
local anim = require("libraries.anim8")
local Structure = require("objects.Structure")

local fr_walking_priest_walk_east = _G.indexQuads("body_priest_walk_e", 16)
local fr_walking_priest_walk_north = _G.indexQuads("body_priest_walk_n", 16)
local fr_walking_priest_walk_west = _G.indexQuads("body_priest_walk_w", 16)
local fr_walking_priest_walk_south = _G.indexQuads("body_priest_walk_s", 16)
local fr_walking_priest_walk_northeast = _G.indexQuads("body_priest_walk_ne", 16)
local fr_walking_priest_walk_northwest = _G.indexQuads("body_priest_walk_nw", 16)
local fr_walking_priest_walk_southeast = _G.indexQuads("body_priest_walk_se", 16)
local fr_walking_priest_walk_southwest = _G.indexQuads("body_priest_walk_sw", 16)
local fr_blessing_priest_bless_east = _G.indexQuads("body_priest_bless_e", 16)
local fr_blessing_priest_bless_north = _G.indexQuads("body_priest_bless_n", 16)
local fr_blessing_priest_bless_west = _G.indexQuads("body_priest_bless_w", 16)
local fr_blessing_priest_bless_south = _G.indexQuads("body_priest_bless_s", 16)
local fr_blessing_priest_bless_northeast = _G.indexQuads("body_priest_bless_ne", 16)
local fr_blessing_priest_bless_northwest = _G.indexQuads("body_priest_bless_nw", 16)
local fr_blessing_priest_bless_southeast = _G.indexQuads("body_priest_bless_se", 16)
local fr_blessing_priest_bless_southwest = _G.indexQuads("body_priest_bless_sw", 16)

local idle = indexQuads("body_priest_idle", 16)
local idle_loop = indexQuads("body_priest_idle", 16, 12, true)

local WALKING_PRIEST_EAST = "walking_priest_east"
local WALKING_PRIEST_NORTH = "walking_priest_north"
local WALKING_PRIEST_WEST = "walking_priest_west"
local WALKING_PRIEST_SOUTH = "walking_priest_south"
local WALKING_PRIEST_NORTHEAST = "walking_priest_northeast"
local WALKING_PRIEST_NORTHWEST = "walking_priest_northwest"
local WALKING_PRIEST_SOUTHEAST = "walking_priest_southeast"
local WALKING_PRIEST_SOUTHWEST = "walking_priest_southwest"
local BLESSING_PRIEST_EAST = "bleesing_priest_east"
local BLESSING_PRIEST_NORTH = "blessing_priest_north"
local BLESSING_PRIEST_WEST = "blessing_priest_west"
local BLESSING_PRIEST_SOUTH = "blessing_priest_south"
local BLESSING_PRIEST_NORTHEAST = "blessing_priest_northeast"
local BLESSING_PRIEST_NORTHWEST = "blessing_priest_northwest"
local BLESSING_PRIEST_SOUTHEAST = "blessing_priest_southeast"
local BLESSING_PRIEST_SOUTHWEST = "blessing_priest_southwest"
local IDLE = "idle"
local IDLE_LOOP = "idle_loop"

local an = {
    [WALKING_PRIEST_EAST] = fr_walking_priest_walk_east,
    [WALKING_PRIEST_NORTH] = fr_walking_priest_walk_north,
    [WALKING_PRIEST_WEST] = fr_walking_priest_walk_west,
    [WALKING_PRIEST_SOUTH] = fr_walking_priest_walk_south,
    [WALKING_PRIEST_NORTHEAST] = fr_walking_priest_walk_northeast,
    [WALKING_PRIEST_NORTHWEST] = fr_walking_priest_walk_northwest,
    [WALKING_PRIEST_SOUTHEAST] = fr_walking_priest_walk_southeast,
    [WALKING_PRIEST_SOUTHWEST] = fr_walking_priest_walk_southwest,
    [BLESSING_PRIEST_EAST] = fr_blessing_priest_bless_east,
    [BLESSING_PRIEST_NORTH] = fr_blessing_priest_bless_north,
    [BLESSING_PRIEST_WEST] = fr_blessing_priest_bless_west,
    [BLESSING_PRIEST_SOUTH] = fr_blessing_priest_bless_south,
    [BLESSING_PRIEST_NORTHEAST] = fr_blessing_priest_bless_northeast,
    [BLESSING_PRIEST_NORTHWEST] = fr_blessing_priest_bless_northwest,
    [BLESSING_PRIEST_SOUTHEAST] = fr_blessing_priest_bless_southeast,
    [BLESSING_PRIEST_SOUTHWEST] = fr_blessing_priest_bless_southwest,
    [IDLE] = idle,
    [IDLE_LOOP] = idle_loop
}

local SEARCH_RADIUS = 30
local WORK_DURATION = 6
local NO_EXIT_WAIT_DURATION = 5

local Priest = _G.class('Priest', Worker)

function Priest:initialize(gx, gy, type)
    Worker.initialize(self, gx, gy, type)
    self:usePallete(2)
    self.workplace = nil
    self.state = 'Find a job'
    self.waitTimer = 0
    self.offsetX = -5
    self.offsetY = -10
    self.count = 1
    self.blessedStructures = 0
    self.blessTarget = nil
    self.animation = anim.newAnimation(an[WALKING_PRIEST_WEST], 10, nil, WALKING_PRIEST_WEST)
end

function Priest:blessCallback()
    if self.state == "Blessing" then
        if self.blessedStructures < 4 then
            self.state = "Looking to bless"
            self.moveDir = "none"
            self.blessedStructures = self.blessedStructures + 1
        else
            self.animation:pause()
            self.moveDir = "none"
            self.count = 1
            self.state = "Going to workplace"
            self:requestPathToStructure(self.workplace, function() self:onNoPathToWorkplace() end)
            self.blessedStructures = 0
        end
    end
end

function Priest:dirSubUpdate()
    if self.moveDir == "west" then
        if self.state == "Going to bless" or self.state == "Going to workplace" then
            self.animation = anim.newAnimation(an[WALKING_PRIEST_WEST], 0.05, nil, WALKING_PRIEST_WEST)
        end
    elseif self.moveDir == "southwest" then
        if self.state == "Going to bless" or self.state == "Going to workplace" then
            self.animation = anim.newAnimation(an[WALKING_PRIEST_SOUTHWEST], 0.05, nil, WALKING_PRIEST_SOUTHWEST)
        end
    elseif self.moveDir == "northwest" then
        if self.state == "Going to bless" or self.state == "Going to workplace" then
            self.animation = anim.newAnimation(an[WALKING_PRIEST_NORTHWEST], 0.05, nil, WALKING_PRIEST_NORTHWEST)
        end
    elseif self.moveDir == "north" then
        if self.state == "Going to bless" or self.state == "Going to workplace" then
            self.animation = anim.newAnimation(an[WALKING_PRIEST_NORTH], 0.05, nil, WALKING_PRIEST_NORTH)
        end
    elseif self.moveDir == "south" then
        if self.state == "Going to bless" or self.state == "Going to workplace" then
            self.animation = anim.newAnimation(an[WALKING_PRIEST_SOUTH], 0.05, nil, WALKING_PRIEST_SOUTH)
        end
    elseif self.moveDir == "east" then
        if self.state == "Going to bless" or self.state == "Going to workplace" then
            self.animation = anim.newAnimation(an[WALKING_PRIEST_EAST], 0.05, nil, WALKING_PRIEST_EAST)
        end
    elseif self.moveDir == "southeast" then
        if self.state == "Going to bless" or self.state == "Going to workplace" then
            self.animation = anim.newAnimation(an[WALKING_PRIEST_SOUTHEAST], 0.05, nil, WALKING_PRIEST_SOUTHEAST)
        end
    elseif self.moveDir == "northeast" then
        if self.state == "Going to bless" or self.state == "Going to workplace" then
            self.animation = anim.newAnimation(an[WALKING_PRIEST_NORTHEAST], 0.05, nil, WALKING_PRIEST_NORTHEAST)
        end
    end
end

function Priest:selectBlessingAnimation()
    if self.moveDir == "west" then
        self.animation = anim.newAnimation(an[BLESSING_PRIEST_WEST], 0.08, function() self:blessCallback() end, BLESSING_PRIEST_WEST)
    elseif self.moveDir == "southwest" then
        self.animation = anim.newAnimation(an[BLESSING_PRIEST_SOUTHWEST], 0.08, function() self:blessCallback() end, BLESSING_PRIEST_SOUTHWEST)
    elseif self.moveDir == "northwest" then
        self.animation = anim.newAnimation(an[BLESSING_PRIEST_NORTHWEST], 0.08, function() self:blessCallback() end, BLESSING_PRIEST_NORTHWEST)
    elseif self.moveDir == "north" then
        self.animation = anim.newAnimation(an[BLESSING_PRIEST_NORTH], 0.08, function() self:blessCallback() end, BLESSING_PRIEST_NORTH)
    elseif self.moveDir == "south" then
        self.animation = anim.newAnimation(an[BLESSING_PRIEST_SOUTH], 0.08, function() self:blessCallback() end, BLESSING_PRIEST_SOUTH)
    elseif self.moveDir == "east" then
        self.animation = anim.newAnimation(an[BLESSING_PRIEST_EAST], 0.08, function() self:blessCallback() end, BLESSING_PRIEST_EAST)
    elseif self.moveDir == "southeast" then
        self.animation = anim.newAnimation(an[BLESSING_PRIEST_SOUTHEAST], 0.08, function() self:blessCallback() end, BLESSING_PRIEST_SOUTHEAST)
    elseif self.moveDir == "northeast" then
        self.animation = anim.newAnimation(an[BLESSING_PRIEST_NORTHEAST], 0.08, function() self:blessCallback() end, BLESSING_PRIEST_NORTHEAST)
    end
end

function Priest:findStrucutures()
    local objt = _G.ReligionController:getBuildingToBless(self.gx, self.gy, SEARCH_RADIUS)
    if not objt then
        self.animation = _G.anim.newAnimation(an[IDLE], 0.11, nil, IDLE)
        self.state = "No structures"
        self:onNoPathToWorkplace()
        return
    end
    self.blessTarget = { ["gx"] = objt.gx, ["gy"] = objt.gy }
    self.state = "Going to bless"
    self.moveDir = "none"
    self:requestPathToStructure(objt, function() self:onNoPathToBless() end)
end

function Priest:update()
    if self.state == "Working in workplace" then
        self.waitTimer = self.waitTimer + _G.dt
        if self.waitTimer > WORK_DURATION then
            self.state = "Waiting for exitpoint"
            self.waitTimer = 0
            self.workplace:exitTowardsStockpile()
            return
        end
    end
    if self.pathState == "Waiting for path" then
        self:pathfind()
        if self.animation and self.animation.animationIdentifier ~= IDLE then
            self.animation = _G.anim.newAnimation(an[IDLE], 0.11, nil, IDLE)
        end
    elseif self.state == "Waiting for exitpoint" then
        self.waitTimer = self.waitTimer + _G.dt
        if self.waitTimer > NO_EXIT_WAIT_DURATION then
            self.workplace:exitTowardsStockpile()
            self.waitTimer = 0
        end
    elseif self.pathState == "No path" then --Can happen if path for blessig target fails two times
        self.state = "Working in workplace"
        self.workplace:work(self)
        self.pathState = "none"
    elseif self.state == "Find a job" then
        _G.JobController:findJob(self, "Priest")
    elseif self.state ~= "No structures" then
        if self.state == "Looking to bless" then
            self:findStrucutures()
        elseif self.state == "Go to workplace" then
            self:requestPathToStructure(self.workplace, function() self:onNoPathToWorkplace() end)
            self.state = "Going to workplace"
            self.moveDir = "none"
        elseif self.state == "Going to bless" or self.state == "Going to workplace" or self.state == "Going to waypoint" then
            if self.moveDir == "none" then
                self:updateDirection()
                self:dirSubUpdate()
            end
            self:move()
        end
        if self:reachedWaypoint() then
            if self.state == "Going to bless" then
                if self:reachedPathEnd() then
                    self.state = "Blessing"
                    self:selectBlessingAnimation()
                    if self.blessTarget then
                        local building = _G.objectFromSubclassAtGlobal(self.blessTarget.gx, self.blessTarget.gy, Structure)
                        if building then
                            building.lastBlessed = _G.state.gameTime
                        end
                        self.blessTarget = nil
                    end
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

function Priest:jobUpdate()
    _G.removeObjectAt(self.lrcx, self.lrcy, self.lrx, self.lry, self)
    _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
    self.instancemesh = nil
    self.animation = nil
end

function Priest:onNoPathToWorkplace()
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

function Priest:onExitPointFound()
    self.waitTimer = 0
end

function Priest:animate()
    self:update()
    Worker.animate(self)
end

function Priest:load(data)
    Object.deserialize(self, data)
    Worker.load(self, data)
    local anData = data.animation
    if anData then
        local callback
        if string.find(anData.animationIdentifier, "blessing") then
            callback = function() self:blessCallback() end
        end
        self.animation = anim.newAnimation(an[anData.animationIdentifier], 1, callback, anData.animationIdentifier)
        self.animation:deserialize(anData)
    end
end

function Priest:serialize()
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
    data.blessedStructures = self.blessedStructures
    data.blessTarget = self.blessTarget
    return data
end

function Priest:onNoPathToBless()
    self.state = "Looking to bless"
    self:clearPath()
    self:findStrucutures()
end

return Priest
