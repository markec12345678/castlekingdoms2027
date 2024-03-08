local Worker = require("objects.Units.Worker")
local anim = require("libraries.anim8")
local Object = require("objects.Object")

local fr_idle_normal_innkeeper = _G.indexQuads("body_innkeeper_idle_1", 3)
local fr_idle_reverse_innkeeper = _G.addReverse(fr_idle_normal_innkeeper)
local fr_idle_clean_innkeeper = _G.indexQuads("body_innkeeper_idle_1", 16, 1, true)
local fr_idle_scratch_innkeeper = _G.indexQuads("body_innkeeper_idle_2", 16)

local fr_walk_barrel_innkeeper_east = _G.indexQuads("body_innkeeper_walk_barrel_e", 16)
local fr_walk_barrel_innkeeper_north = _G.indexQuads("body_innkeeper_walk_barrel_n", 16)
local fr_walk_barrel_innkeeper_north_east = _G.indexQuads("body_innkeeper_walk_barrel_ne", 16)
local fr_walk_barrel_innkeeper_north_west = _G.indexQuads("body_innkeeper_walk_barrel_nw", 16)
local fr_walk_barrel_innkeeper_south = _G.indexQuads("body_innkeeper_walk_barrel_s", 16)
local fr_walk_barrel_innkeeper_south_east = _G.indexQuads("body_innkeeper_walk_barrel_se", 16)
local fr_walk_barrel_innkeeper_south_west = _G.indexQuads("body_innkeeper_walk_barrel_sw", 16)
local fr_walk_barrel_innkeeper_west = _G.indexQuads("body_innkeeper_walk_barrel_w", 16)

local fr_walk_innkeeper_east = _G.indexQuads("body_innkeeper_walk_e", 16)
local fr_walk_innkeeper_north = _G.indexQuads("body_innkeeper_walk_n", 16)
local fr_walk_innkeeper_north_east = _G.indexQuads("body_innkeeper_walk_ne", 16)
local fr_walk_innkeeper_north_west = _G.indexQuads("body_innkeeper_walk_nw", 16)
local fr_walk_innkeeper_south = _G.indexQuads("body_innkeeper_walk_s", 16)
local fr_walk_innkeeper_south_east = _G.indexQuads("body_innkeeper_walk_se", 16)
local fr_walk_innkeeper_south_west = _G.indexQuads("body_innkeeper_walk_sw", 16)
local fr_walk_innkeeper_west = _G.indexQuads("body_innkeeper_walk_w", 16)

local IDLE_NORMAL_INNKEEPER = "idle_normal_innkeeper"
local IDLE_REVERSE_INNKEEPER = "idle_reverse_innkeeper"
local IDLE_CLEAN_INNKEEPER = "idle_clean_innkeeper"
local IDLE_SCRATCH_INNKEEPER = "idle_scratch_innkeeper"
local WALKING_INNKEEPER_EAST = "walking_innkeeper_east"
local WALKING_INNKEEPER_NORTH = "walking_innkeeper_north"
local WALKING_INNKEEPER_WEST = "walking_innkeeper_west"
local WALKING_INNKEEPER_SOUTH = "walking_innkeeper_south"
local WALKING_INNKEEPER_NORTHEAST = "walking_innkeeper_northeast"
local WALKING_INNKEEPER_NORTHWEST = "walking_innkeeper_northwest"
local WALKING_INNKEEPER_SOUTHEAST = "walking_innkeeper_southeast"
local WALKING_INNKEEPER_SOUTHWEST = "walking_innkeeper_southwest"
local WALKING_BARREL_INNKEEPER_EAST = "walking_barrel_innkeeper_east"
local WALKING_BARREL_INNKEEPER_NORTH = "walking_barrel_innkeeper_north"
local WALKING_BARREL_INNKEEPER_WEST = "walking_barrel_innkeeper_west"
local WALKING_BARREL_INNKEEPER_SOUTH = "walking_barrel_innkeeper_south"
local WALKING_BARREL_INNKEEPER_NORTHEAST = "walking_barrel_innkeeper_northeast"
local WALKING_BARREL_INNKEEPER_NORTHWEST = "walking_barrel_innkeeper_northwest"
local WALKING_BARREL_INNKEEPER_SOUTHEAST = "walking_barrel_innkeeper_southeast"
local WALKING_BARREL_INNKEEPER_SOUTHWEST = "walking_barrel_innkeeper_southwest"

local an = {
    [IDLE_NORMAL_INNKEEPER] = fr_idle_normal_innkeeper,
    [IDLE_REVERSE_INNKEEPER] = fr_idle_reverse_innkeeper,
    [IDLE_CLEAN_INNKEEPER] = fr_idle_clean_innkeeper,
    [IDLE_SCRATCH_INNKEEPER] = fr_idle_scratch_innkeeper,
    [WALKING_INNKEEPER_EAST] = fr_walk_innkeeper_east,
    [WALKING_INNKEEPER_NORTH] = fr_walk_innkeeper_north,
    [WALKING_INNKEEPER_WEST] = fr_walk_innkeeper_west,
    [WALKING_INNKEEPER_SOUTH] = fr_walk_innkeeper_south,
    [WALKING_INNKEEPER_NORTHEAST] = fr_walk_innkeeper_north_east,
    [WALKING_INNKEEPER_NORTHWEST] = fr_walk_innkeeper_north_west,
    [WALKING_INNKEEPER_SOUTHEAST] = fr_walk_innkeeper_south_east,
    [WALKING_INNKEEPER_SOUTHWEST] = fr_walk_innkeeper_south_west,
    [WALKING_BARREL_INNKEEPER_EAST] = fr_walk_barrel_innkeeper_east,
    [WALKING_BARREL_INNKEEPER_NORTH] = fr_walk_barrel_innkeeper_north,
    [WALKING_BARREL_INNKEEPER_WEST] = fr_walk_barrel_innkeeper_west,
    [WALKING_BARREL_INNKEEPER_SOUTH] = fr_walk_barrel_innkeeper_south,
    [WALKING_BARREL_INNKEEPER_NORTHEAST] = fr_walk_barrel_innkeeper_north_east,
    [WALKING_BARREL_INNKEEPER_NORTHWEST] = fr_walk_barrel_innkeeper_north_west,
    [WALKING_BARREL_INNKEEPER_SOUTHEAST] = fr_walk_barrel_innkeeper_south_east,
    [WALKING_BARREL_INNKEEPER_SOUTHWEST] = fr_walk_barrel_innkeeper_south_west,
}

local NO_ALE_WAIT_DURATION = 5
local NO_EXIT_WAIT_DURATION = 5
local NORMAL_IDLE_FRAMETIME = 0.3
local CLEAN_IDLE_FRAMETIME = 0.07
local SCRATCH_IDLE_FRAMETIME = 0.07
local WALK_FRAMETIME = 0.05

local Innkeeper = _G.class('Innkeeper', Worker)

function Innkeeper:initialize(gx, gy, type)
    Worker.initialize(self, gx, gy, type)
    self.workplace = nil
    self.state = 'Find a job'
    self.offsetX = -5
    self.offsetY = -10
    self.count = 1
    self.animation = anim.newAnimation(an[IDLE_CLEAN_INNKEEPER], CLEAN_IDLE_FRAMETIME, function() self:idleEnd() end, IDLE_CLEAN_INNKEEPER)
    self.waitTimer = 0
end

function Innkeeper:update()
    if self.workplace then
        self.workplace:consumeAle()
    end

    if self.pathState == "Waiting for path" then
        self:pathfind()
        if self.animation and self.animation.animationIdentifier ~= IDLE_SCRATCH_INNKEEPER then
            self.animation = _G.anim.newAnimation(an[IDLE_SCRATCH_INNKEEPER], SCRATCH_IDLE_FRAMETIME, function() self:idleEnd() end, IDLE_SCRATCH_INNKEEPER)
        end
    elseif self.pathState == "No path" and not self.state == "Waiting for ale" then --Teleport to workplace
        self.state = "Working in workplace"
        self.workplace:work(self)
        self.pathState = "none"
    elseif self.state == "Working in workplace" then
        if self.workplace.jugsOfAle == 0 then
            self.state = "Waiting for exitpoint"
            self.workplace:exitToStockpile()
        end
    elseif self.state == "Waiting for exitpoint" then
        self.waitTimer = self.waitTimer + _G.dt
        if self.waitTimer > NO_EXIT_WAIT_DURATION then
            self.workplace:exitToStockpile()
            self.waitTimer = 0
        end
    elseif self.state == "Waiting for ale" then
        self.waitTimer = self.waitTimer + _G.dt
        if self.waitTimer > NO_ALE_WAIT_DURATION then
            self.state = "Go to stockpile"
            self.waitTimer = 0
        end
    elseif self.state == "Find a job" then
        _G.JobController:findJob(self, "Innkeeper")
    elseif self.state == "Go to workplace" then
        self:requestPathToStructure(self.workplace, function() self:onNoPathToWorkplace() end)
        self.state = "Going to workplace"
        self.moveDir = "none"
    elseif self.state == "Go to workplace with ale" then
        self:requestPathToStructure(self.workplace, function() self:onNoPathToWorkplace() end)
        self.state = "Going to workplace with ale"
        self.moveDir = "none"
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
                self:requestPath(closestNode.gx, closestNode.gy, function() self:onAleIsUnavaliable() end)
            end
            self.moveDir = "none"
        end
    elseif self.state == "Going to workplace" or self.state == "Going to stockpile" or self.state == "Going to workplace with ale" then
        if self.moveDir == "none" then
            self:updateDirection()
            self:dirSubUpdate()
        end
        self:move()
    end
    if self:reachedWaypoint() then
        if self.state == "Going to workplace" then
            if self:reachedPathEnd() then
                self.state = "Go to stockpile"
                self:clearPath()
                return
            else
                self:setNextWaypoint()
            end
            self.count = self.count + 1
        elseif self.state == "Going to stockpile" then
            if self:reachedPathEnd() then
                local gotResource = _G.stockpile:take('ale')
                if not gotResource then
                    self:onAleIsUnavaliable()
                    return
                else
                    self.state = "Go to workplace with ale"
                    self:clearPath()
                    return
                end
            else
                self:setNextWaypoint()
            end
            self.count = self.count + 1
        elseif self.state == "Going to workplace with ale" then
            if self:reachedPathEnd() then
                self.workplace.jugsOfAle = self.workplace.jugsOfAle + 160
                self.state = "Working in workplace"
                self.workplace:work(self)
                self:clearPath()
            else
                self:setNextWaypoint()
            end
            self.count = self.count + 1
        end
    end
end

function Innkeeper:dirSubUpdate()
    if self.moveDir == "west" then
        if self.state == "Going to workplace" or self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[WALKING_INNKEEPER_WEST], WALK_FRAMETIME, nil, WALKING_INNKEEPER_WEST)
        elseif self.state == "Going to workplace with ale" then
            self.animation = anim.newAnimation(an[WALKING_BARREL_INNKEEPER_WEST], WALK_FRAMETIME, nil, WALKING_BARREL_INNKEEPER_WEST)
        end
    elseif self.moveDir == "southwest" then
        if self.state == "Going to workplace" or self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[WALKING_INNKEEPER_SOUTHWEST], WALK_FRAMETIME, nil, WALKING_INNKEEPER_SOUTHWEST)
        elseif self.state == "Going to workplace with ale" then
            self.animation = anim.newAnimation(an[WALKING_BARREL_INNKEEPER_SOUTHWEST], WALK_FRAMETIME, nil, WALKING_BARREL_INNKEEPER_SOUTHWEST)
        end
    elseif self.moveDir == "northwest" then
        if self.state == "Going to workplace" or self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[WALKING_INNKEEPER_NORTHWEST], WALK_FRAMETIME, nil, WALKING_INNKEEPER_NORTHWEST)
        elseif self.state == "Going to workplace with ale" then
            self.animation = anim.newAnimation(an[WALKING_BARREL_INNKEEPER_NORTHWEST], WALK_FRAMETIME, nil, WALKING_BARREL_INNKEEPER_NORTHWEST)
        end
    elseif self.moveDir == "north" then
        if self.state == "Going to workplace" or self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[WALKING_INNKEEPER_NORTH], WALK_FRAMETIME, nil, WALKING_INNKEEPER_NORTH)
        elseif self.state == "Going to workplace with ale" then
            self.animation = anim.newAnimation(an[WALKING_BARREL_INNKEEPER_NORTH], WALK_FRAMETIME, nil, WALKING_BARREL_INNKEEPER_NORTH)
        end
    elseif self.moveDir == "south" then
        if self.state == "Going to workplace" or self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[WALKING_INNKEEPER_SOUTH], WALK_FRAMETIME, nil, WALKING_INNKEEPER_SOUTH)
        elseif self.state == "Going to workplace with ale" then
            self.animation = anim.newAnimation(an[WALKING_BARREL_INNKEEPER_SOUTH], WALK_FRAMETIME, nil, WALKING_BARREL_INNKEEPER_SOUTH)
        end
    elseif self.moveDir == "east" then
        if self.state == "Going to workplace" or self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[WALKING_INNKEEPER_EAST], WALK_FRAMETIME, nil, WALKING_INNKEEPER_EAST)
        elseif self.state == "Going to workplace with ale" then
            self.animation = anim.newAnimation(an[WALKING_BARREL_INNKEEPER_EAST], WALK_FRAMETIME, nil, WALKING_BARREL_INNKEEPER_EAST)
        end
    elseif self.moveDir == "southeast" then
        if self.state == "Going to workplace" or self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[WALKING_INNKEEPER_SOUTHEAST], WALK_FRAMETIME, nil, WALKING_INNKEEPER_SOUTHEAST)
        elseif self.state == "Going to workplace with ale" then
            self.animation = anim.newAnimation(an[WALKING_BARREL_INNKEEPER_SOUTHEAST], WALK_FRAMETIME, nil, WALKING_BARREL_INNKEEPER_SOUTHEAST)
        end
    elseif self.moveDir == "northeast" then
        if self.state == "Going to workplace" or self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[WALKING_INNKEEPER_NORTHEAST], WALK_FRAMETIME, nil, WALKING_INNKEEPER_NORTHEAST)
        elseif self.state == "Going to workplace with ale" then
            self.animation = anim.newAnimation(an[WALKING_BARREL_INNKEEPER_NORTHEAST], WALK_FRAMETIME, nil, WALKING_BARREL_INNKEEPER_NORTHEAST)
        end
    end
end

function Innkeeper:jobUpdate()
    _G.removeObjectAt(self.lrcx, self.lrcy, self.lrx, self.lry, self)
    _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
    self.instancemesh = nil
    self.animation = nil
end

function Innkeeper:animate()
    self:update()
    Worker.animate(self)
end

function Innkeeper:idleEnd()
    if self.animation and self.animation.animationIdentifier == IDLE_NORMAL_INNKEEPER then
        self.animation = _G.anim.newAnimation(an[IDLE_REVERSE_INNKEEPER], NORMAL_IDLE_FRAMETIME, function() self:idleEnd() end, IDLE_REVERSE_INNKEEPER)
    elseif self.animation and self.animation.animationIdentifier == IDLE_REVERSE_INNKEEPER then
        local roll = math.random(10)
        if roll < 4 then
            self.animation = _G.anim.newAnimation(an[IDLE_SCRATCH_INNKEEPER], SCRATCH_IDLE_FRAMETIME, function() self:idleEnd() end, IDLE_SCRATCH_INNKEEPER)
        elseif roll < 7 then
            self.animation = _G.anim.newAnimation(an[IDLE_CLEAN_INNKEEPER], CLEAN_IDLE_FRAMETIME, function() self:idleEnd() end, IDLE_CLEAN_INNKEEPER)
        else
            self.animation = _G.anim.newAnimation(an[IDLE_NORMAL_INNKEEPER], NORMAL_IDLE_FRAMETIME, function() self:idleEnd() end, IDLE_NORMAL_INNKEEPER)
        end
    elseif self.animation and self.animation.animationIdentifier == IDLE_SCRATCH_INNKEEPER then
        self.animation = _G.anim.newAnimation(an[IDLE_NORMAL_INNKEEPER], NORMAL_IDLE_FRAMETIME, function() self:idleEnd() end, IDLE_NORMAL_INNKEEPER)
    elseif self.animation and self.animation.animationIdentifier == IDLE_CLEAN_INNKEEPER then
        self.animation = _G.anim.newAnimation(an[IDLE_NORMAL_INNKEEPER], NORMAL_IDLE_FRAMETIME, function() self:idleEnd() end, IDLE_NORMAL_INNKEEPER)
    end
end

function Innkeeper:onAleIsUnavaliable()
    if self.animation and self.animation.animationIdentifier ~= IDLE_NORMAL_INNKEEPER then
        self.animation = _G.anim.newAnimation(an[IDLE_NORMAL_INNKEEPER], NORMAL_IDLE_FRAMETIME, function() self:idleEnd() end, IDLE_NORMAL_INNKEEPER)
    end
    self.state = "Waiting for ale"
end

function Innkeeper:onNoPathToWorkplace()
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

function Innkeeper:load(data)
    Object.deserialize(self, data)
    Worker.load(self, data)
    local anData = data.animation
    local frameTime = WALK_FRAMETIME
    if anData then
        local callback
        if string.find(anData.animationIdentifier, "idle") then
            callback = function() self:idleEnd() end
            frameTime = NORMAL_IDLE_FRAMETIME
            if string.find(anData.animationIdentifier, "clean") then
                frameTime = CLEAN_IDLE_FRAMETIME
            elseif (string.find(anData.animationIdentifier, "scratch")) then
                frameTime = SCRATCH_IDLE_FRAMETIME
            end
        end
        self.animation = anim.newAnimation(an[anData.animationIdentifier], frameTime, callback, anData.animationIdentifier)
        self.animation:deserialize(anData)
    end
end

function Innkeeper:serialize()
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

return Innkeeper
