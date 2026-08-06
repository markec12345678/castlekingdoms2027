local Worker = require("objects.Units.Worker")
local Object = require("objects.Object")
local anim = _G.anim
local indexQuads = _G.indexQuads

--WALK WITH DEER
local fr_walking_deer_east = indexQuads("body_hunter_walk_deer_e", 16)
local fr_walking_deer_north = indexQuads("body_hunter_walk_deer_n", 16)
local fr_walking_deer_west = indexQuads("body_hunter_walk_deer_w", 16)
local fr_walking_deer_south = indexQuads("body_hunter_walk_deer_s", 16)
local fr_walking_deer_northeast = indexQuads("body_hunter_walk_deer_ne", 16)
local fr_walking_deer_northwest = indexQuads("body_hunter_walk_deer_nw", 16)
local fr_walking_deer_southeast = indexQuads("body_hunter_walk_deer_se", 16)
local fr_walking_deer_southwest = indexQuads("body_hunter_walk_deer_sw", 16)
--WALK WITH MEAT
local fr_walking_meat_east = indexQuads("body_hunter_walk_meat_e", 16)
local fr_walking_meat_north = indexQuads("body_hunter_walk_meat_n", 16)
local fr_walking_meat_west = indexQuads("body_hunter_walk_meat_w", 16)
local fr_walking_meat_south = indexQuads("body_hunter_walk_meat_s", 16)
local fr_walking_meat_northeast = indexQuads("body_hunter_walk_meat_ne", 16)
local fr_walking_meat_northwest = indexQuads("body_hunter_walk_meat_nw", 16)
local fr_walking_meat_southeast = indexQuads("body_hunter_walk_meat_se", 16)
local fr_walking_meat_southwest = indexQuads("body_hunter_walk_meat_sw", 16)
--WALK
local fr_walking_east = indexQuads("body_hunter_walk_e", 16)
local fr_walking_north = indexQuads("body_hunter_walk_n", 16)
local fr_walking_northeast = indexQuads("body_hunter_walk_ne", 16)
local fr_walking_northwest = indexQuads("body_hunter_walk_nw", 16)
local fr_walking_south = indexQuads("body_hunter_walk_s", 16)
local fr_walking_southeast = indexQuads("body_hunter_walk_se", 16)
local fr_walking_southwest = indexQuads("body_hunter_walk_sw", 16)
local fr_walking_west = indexQuads("body_hunter_walk_w", 16)
--RUN
local fr_running_east = indexQuads("body_hunter_run_e", 16)
local fr_running_north = indexQuads("body_hunter_run_n", 16)
local fr_running_northeast = indexQuads("body_hunter_run_ne", 16)
local fr_running_northwest = indexQuads("body_hunter_run_nw", 16)
local fr_running_south = indexQuads("body_hunter_run_s", 16)
local fr_running_southeast = indexQuads("body_hunter_run_se", 16)
local fr_running_southwest = indexQuads("body_hunter_run_sw", 16)
local fr_running_west = indexQuads("body_hunter_run_w", 16)
--SNEAK
local fr_sneaking_east = indexQuads("body_hunter_sneak_e", 16)
local fr_sneaking_north = indexQuads("body_hunter_sneak_n", 16)
local fr_sneaking_northeast = indexQuads("body_hunter_sneak_ne", 16)
local fr_sneaking_northwest = indexQuads("body_hunter_sneak_nw", 16)
local fr_sneaking_south = indexQuads("body_hunter_sneak_s", 16)
local fr_sneaking_southeast = indexQuads("body_hunter_sneak_se", 16)
local fr_sneaking_southwest = indexQuads("body_hunter_sneak_sw", 16)
local fr_sneaking_west = indexQuads("body_hunter_sneak_w", 16)
--ATTACK
local fr_shooting_east = indexQuads("body_hunter_attack_e", 24)
local fr_shooting_north = indexQuads("body_hunter_attack_n", 24)
local fr_shooting_northeast = indexQuads("body_hunter_attack_ne", 24)
local fr_shooting_northwest = indexQuads("body_hunter_attack_nw", 24)
local fr_shooting_south = indexQuads("body_hunter_attack_s", 24)
local fr_shooting_southeast = indexQuads("body_hunter_attack_se", 24)
local fr_shooting_southwest = indexQuads("body_hunter_attack_sw", 24)
local fr_shooting_west = indexQuads("body_hunter_attack_w", 24)

local fr_idle = _G.addReverse(_G.indexQuads("body_hunter_idle_long", 24))
local fr_stand = _G.indexQuads("body_hunter_idle_long", 1, 1)

local AN_WALKING_WEST = "Walking west"
local AN_WALKING_SOUTHWEST = "Walking southwest"
local AN_WALKING_NORTHWEST = "Walking northwest"
local AN_WALKING_NORTH = "Walking north"
local AN_WALKING_SOUTH = "Walking south"
local AN_WALKING_EAST = "Walking east"
local AN_WALKING_SOUTHEAST = "Walking southeast"
local AN_WALKING_NORTHEAST = "Walking northeast"
local AN_RUNNING_WEST = "Running west"
local AN_RUNNING_SOUTHWEST = "Running southwest"
local AN_RUNNING_NORTHWEST = "Running northwest"
local AN_RUNNING_NORTH = "Running north"
local AN_RUNNING_SOUTH = "Running south"
local AN_RUNNING_EAST = "Running east"
local AN_RUNNING_SOUTHEAST = "Running southeast"
local AN_RUNNING_NORTHEAST = "Running northeast"
local AN_SNEAKING_WEST = "Sneaking west"
local AN_SNEAKING_SOUTHWEST = "Sneaking southwest"
local AN_SNEAKING_NORTHWEST = "Sneaking northwest"
local AN_SNEAKING_NORTH = "Sneaking north"
local AN_SNEAKING_SOUTH = "Sneaking south"
local AN_SNEAKING_EAST = "Sneaking east"
local AN_SNEAKING_SOUTHEAST = "Sneaking southeast"
local AN_SNEAKING_NORTHEAST = "Sneaking northeast"
local AN_WALKING_deer_WEST = "Walking with deer west"
local AN_WALKING_deer_SOUTHWEST = "Walking with deer southwest"
local AN_WALKING_deer_NORTHWEST = "Walking with deer northwest"
local AN_WALKING_deer_NORTH = "Walking with deer north"
local AN_WALKING_deer_SOUTH = "Walking with deer south"
local AN_WALKING_deer_EAST = "Walking with deer east"
local AN_WALKING_deer_SOUTHEAST = "Walking with deer southeast"
local AN_WALKING_deer_NORTHEAST = "Walking with deer northeast"
local AN_WALKING_meat_WEST = "Walking with meat west"
local AN_WALKING_meat_SOUTHWEST = "Walking with meat southwest"
local AN_WALKING_meat_NORTHWEST = "Walking with meat northwest"
local AN_WALKING_meat_NORTH = "Walking with meat north"
local AN_WALKING_meat_SOUTH = "Walking with meat south"
local AN_WALKING_meat_EAST = "Walking with meat east"
local AN_WALKING_meat_SOUTHEAST = "Walking with meat southeast"
local AN_WALKING_meat_NORTHEAST = "Walking with meat northeast"
local AN_SHOOTING_WEST = "Shooting west"
local AN_SHOOTING_SOUTHWEST = "Shooting southwest"
local AN_SHOOTING_NORTHWEST = "Shooting northwest"
local AN_SHOOTING_NORTH = "Shooting north"
local AN_SHOOTING_SOUTH = "Shooting south"
local AN_SHOOTING_EAST = "Shooting east"
local AN_SHOOTING_SOUTHEAST = "Shooting southeast"
local AN_SHOOTING_NORTHEAST = "Shooting northeast"
local AN_IDLE = "Idle"
local AN_STAND = "Stand"

local an = {
    [AN_WALKING_WEST] = fr_walking_west,
    [AN_WALKING_SOUTHWEST] = fr_walking_southwest,
    [AN_WALKING_NORTHWEST] = fr_walking_northwest,
    [AN_WALKING_NORTH] = fr_walking_north,
    [AN_WALKING_SOUTH] = fr_walking_south,
    [AN_WALKING_EAST] = fr_walking_east,
    [AN_WALKING_SOUTHEAST] = fr_walking_southeast,
    [AN_WALKING_NORTHEAST] = fr_walking_northeast,
    [AN_RUNNING_WEST] = fr_running_west,
    [AN_RUNNING_SOUTHWEST] = fr_running_southwest,
    [AN_RUNNING_NORTHWEST] = fr_running_northwest,
    [AN_RUNNING_NORTH] = fr_running_north,
    [AN_RUNNING_SOUTH] = fr_running_south,
    [AN_RUNNING_EAST] = fr_running_east,
    [AN_RUNNING_SOUTHEAST] = fr_running_southeast,
    [AN_RUNNING_NORTHEAST] = fr_running_northeast,
    [AN_SNEAKING_WEST] = fr_sneaking_west,
    [AN_SNEAKING_SOUTHWEST] = fr_sneaking_southwest,
    [AN_SNEAKING_NORTHWEST] = fr_sneaking_northwest,
    [AN_SNEAKING_NORTH] = fr_sneaking_north,
    [AN_SNEAKING_SOUTH] = fr_sneaking_south,
    [AN_SNEAKING_EAST] = fr_sneaking_east,
    [AN_SNEAKING_SOUTHEAST] = fr_sneaking_southeast,
    [AN_SNEAKING_NORTHEAST] = fr_sneaking_northeast,
    [AN_WALKING_deer_WEST] = fr_walking_deer_west,
    [AN_WALKING_deer_SOUTHWEST] = fr_walking_deer_southwest,
    [AN_WALKING_deer_NORTHWEST] = fr_walking_deer_northwest,
    [AN_WALKING_deer_NORTH] = fr_walking_deer_north,
    [AN_WALKING_deer_SOUTH] = fr_walking_deer_south,
    [AN_WALKING_deer_EAST] = fr_walking_deer_east,
    [AN_WALKING_deer_SOUTHEAST] = fr_walking_deer_southeast,
    [AN_WALKING_deer_NORTHEAST] = fr_walking_deer_northeast,
    [AN_WALKING_meat_WEST] = fr_walking_meat_west,
    [AN_WALKING_meat_SOUTHWEST] = fr_walking_meat_southwest,
    [AN_WALKING_meat_NORTHWEST] = fr_walking_meat_northwest,
    [AN_WALKING_meat_NORTH] = fr_walking_meat_north,
    [AN_WALKING_meat_SOUTH] = fr_walking_meat_south,
    [AN_WALKING_meat_EAST] = fr_walking_meat_east,
    [AN_WALKING_meat_SOUTHEAST] = fr_walking_meat_southeast,
    [AN_WALKING_meat_NORTHEAST] = fr_walking_meat_northeast,
    [AN_SHOOTING_WEST] = fr_shooting_west,
    [AN_SHOOTING_SOUTHWEST] = fr_shooting_southwest,
    [AN_SHOOTING_NORTHWEST] = fr_shooting_northwest,
    [AN_SHOOTING_NORTH] = fr_shooting_north,
    [AN_SHOOTING_SOUTH] = fr_shooting_south,
    [AN_SHOOTING_EAST] = fr_shooting_east,
    [AN_SHOOTING_SOUTHEAST] = fr_shooting_southeast,
    [AN_SHOOTING_NORTHEAST] = fr_shooting_northeast,
    [AN_IDLE] = fr_idle,
    [AN_STAND] = fr_stand
}

local hunterFx = {
    ["shoot"] = { _G.fx["arrowshoot1 22k"] },
    ["hit"] = { _G.fx["arrowbasic_01"], _G.fx["arrowbasic_02"] }
}

local ANIMATION_FRAMETIME = 0.05
local SHOOT_FRAMETIME = 0.07
local SNEAK_FRAMETIME = 0.20
local IDLE_FRAMETIME = 0.10
local STAND_FRAMETIME = 3

local STRAIGHT_CARRY_SPEED = 2400 * 1
local DIAGONAL_CARRY_SPEED = 1500 * 1
local STRAIGHT_WALK_SPEED = math.floor(STRAIGHT_CARRY_SPEED * 1.5)
local DIAGONAL_WALK_SPEED = math.floor(DIAGONAL_CARRY_SPEED * 1.5)
local STRAIGHT_SNEAK_SPEED = math.floor(STRAIGHT_CARRY_SPEED * 0.3)
local DIAGONAL_SNEAK_SPEED = math.floor(DIAGONAL_CARRY_SPEED * 0.3)
local STRAIGHT_RUN_SPEED = math.floor(STRAIGHT_CARRY_SPEED * 2.5)
local DIAGONAL_RUN_SPEED = math.floor(DIAGONAL_CARRY_SPEED * 2.5)

local Hunter = _G.class('Hunter', Worker)
function Hunter:initialize(gx, gy, type)
    Worker.initialize(self, gx, gy, type)
    self:usePallete(2)
    self.workplace = nil
    self.state = 'Find a job'
    self.count = 1
    self.offsetX = -5
    self.offsetY = -10
    self.straightWalkSpeed = STRAIGHT_WALK_SPEED
    self.diagonalWalkSpeed = DIAGONAL_WALK_SPEED
    self.storeTimer = 0
    self.targetDeer = nil
    self.animation = anim.newAnimation(an[AN_WALKING_WEST], ANIMATION_FRAMETIME, nil, AN_WALKING_WEST)
end

function Hunter:load(data)
    Object.deserialize(self, data)
    Worker.load(self, data)
    local anData = data.animation
    if anData then
        local callback = nil
        local frameTime = ANIMATION_FRAMETIME
        if string.find(anData.animationIdentifier, "Sneaking") then
            frameTime = SNEAK_FRAMETIME
        elseif string.find(anData.animationIdentifier, "Shooting") then
            frameTime = SHOOT_FRAMETIME
            callback = function() self:shootCallback() end
        elseif string.find(anData.animationIdentifier, "Idle") then
            frameTime = IDLE_FRAMETIME
            callback = function() self:idleCallback() end
        elseif string.find(anData.animationIdentifier, "Stand") then
            frameTime = STAND_FRAMETIME
            if self.state == "No deers" then
                callback = function() self:findDeer() end
            end
        end
        self.animation = anim.newAnimation(an[anData.animationIdentifier], frameTime, callback, anData.animationIdentifier)
        self.animation:deserialize(anData)
    end
    if data.targetDeer then
        self.targetDeer = _G.state:dereferenceObject(data.targetDeer)
    end
end

function Hunter:serialize()
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
    data.count = self.count
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    data.storeTimer = self.storeTimer
    if self.targetDeer then
        data.targetDeer = _G.state:serializeObject(self.targetDeer)
    end
    return data
end

function Hunter:collectDeer()
    if self.state == "Collecting deer" then
        if self.targetDeer and not self.targetDeer.toBeDeleted then
            self.targetDeer:die()
            self.animation:pause()
            self.moveDir = "none"
            self.count = 1
            self.state = "Going to workplace with deer"
            self:setMovementSpeed("carry")
            self:requestPath(self.workplace.gx + 1, self.workplace.gy + 2, function() self:onNoPathToWorkplace() end)
        else
            self.state = "Looking to hunt deer"
            self.moveDir = "none"
        end
        self.targetDeer = nil
    end
end

function Hunter:shootCallback()
    _G.playSfx(self, hunterFx["shoot"])
    self.animation:pause()
    local tx, ty = math.round(self.targetDeer.gx), math.round(self.targetDeer.gy)
    _G.ArrowController:shootArrow(self, tx, ty, function()
        self.targetDeer:kill()
        self.state = "Running to deer"
        _G.playSfx(self.targetDeer, hunterFx["hit"])
        self:setMovementSpeed("run")
        self:requestPath(self.endx, self.endy, function() self:onNoAvailableDeer() end)
    end)
end

function Hunter:inRangeForSneak()
    return _G.manhattanDistance(self.gx, self.gy, self.targetDeer.gx, self.targetDeer.gy) < 27
end

function Hunter:inRangeForShoot()
    -- TODO: calculate arrow distance instead of magic number
    return _G.manhattanDistance(self.gx, self.gy, self.targetDeer.gx, self.targetDeer.gy) < 25
end

function Hunter:jobUpdate()
    _G.removeObjectAt(self.lrcx, self.lrcy, self.lrx, self.lry, self)
    _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
    self.instancemesh = nil
    self.animation = nil
end

function Hunter:getAvailableDeersForHerd(herd)
    local availableDeers = {}
    for _, deer in pairs(herd.deers) do
        if not deer.marked then
            table.insert(availableDeers, deer)
        end
    end

    return availableDeers
end

function Hunter:getClosestAvailableDeers()
    local closestAvailableDeers, closestDistance = {}, math.huge
    local herds = _G.HerdController.deerHerds:getDeerHerds()
    for _, herd in pairs(herds) do
        local availableDeersInHerd = self:getAvailableDeersForHerd(herd)
        if #availableDeersInHerd > 0 then
            local dist = _G.manhattanDistance(self.gx, self.gy, herd.gx, herd.gy)
            if dist < closestDistance then
                closestAvailableDeers = availableDeersInHerd
                closestDistance = dist
            end
        end
    end

    return closestAvailableDeers
end

function Hunter:selectDeer()
    local selectedDeer, closestDistance = nil, math.huge
    local availableDeers = self:getClosestAvailableDeers()
    if #availableDeers == 0 then
        return nil
    end
    for _, deer in pairs(availableDeers) do
        local dist = _G.manhattanDistance(self.gx, self.gy, deer.gx, deer.gy)
        if dist < closestDistance then
            selectedDeer = deer
            closestDistance = dist
        end
    end

    return selectedDeer
end

function Hunter:findDeer()
    local selectedDeer = self:selectDeer()
    if not selectedDeer then
        self:onNoAvailableDeer()
        return
    end
    self.targetDeer = selectedDeer
    self.targetDeer:waitForHunter()
    self.endx = selectedDeer.gx
    self.endy = selectedDeer.gy + 1
    if self.endx == self.gx and self.endy == self.gy then
        self.state = "Collecting deer"
        self:clearPath()
        self:collectDeer()
        return
    else
        self.state = "Walking to deer"
        self:setMovementSpeed("walk")
        self:requestPath(self.endx, self.endy, function() self:onNoAvailableDeer() end)
        return
    end
end

function Hunter:dirSubUpdate()
    if self.moveDir == "west" then
        if self.state == "Going to foodpile" then
            self.animation = anim.newAnimation(an[AN_WALKING_meat_WEST], ANIMATION_FRAMETIME, nil, AN_WALKING_meat_WEST)
        elseif self.state == "Going to workplace with deer" then
            self.animation = anim.newAnimation(an[AN_WALKING_deer_WEST], ANIMATION_FRAMETIME, nil, AN_WALKING_deer_WEST)
        elseif self.state == "Shooting" then
            self.animation = anim.newAnimation(an[AN_SHOOTING_WEST], SHOOT_FRAMETIME, function() self:shootCallback() end, AN_SHOOTING_WEST)
        elseif self.state == "Sneaking" then
            self.animation = anim.newAnimation(an[AN_SNEAKING_WEST], SNEAK_FRAMETIME, nil, AN_SNEAKING_WEST)
        elseif self.state == "Running to deer" then
            self.animation = anim.newAnimation(an[AN_RUNNING_WEST], ANIMATION_FRAMETIME, nil, AN_RUNNING_WEST)
        else
            self.animation = anim.newAnimation(an[AN_WALKING_WEST], ANIMATION_FRAMETIME, nil, AN_WALKING_WEST)
        end
    elseif self.moveDir == "southwest" then
        if self.state == "Going to foodpile" then
            self.animation = anim.newAnimation(an[AN_WALKING_meat_SOUTHWEST], ANIMATION_FRAMETIME, nil, AN_WALKING_meat_SOUTHWEST)
        elseif self.state == "Going to workplace with deer" then
            self.animation = anim.newAnimation(an[AN_WALKING_deer_SOUTHWEST], ANIMATION_FRAMETIME, nil, AN_WALKING_deer_SOUTHWEST)
        elseif self.state == "Shooting" then
            self.animation = anim.newAnimation(an[AN_SHOOTING_SOUTHWEST], SHOOT_FRAMETIME, function() self:shootCallback() end, AN_SHOOTING_SOUTHWEST)
        elseif self.state == "Sneaking" then
            self.animation = anim.newAnimation(an[AN_SNEAKING_SOUTHWEST], SNEAK_FRAMETIME, nil, AN_SNEAKING_SOUTHWEST)
        elseif self.state == "Running to deer" then
            self.animation = anim.newAnimation(an[AN_RUNNING_SOUTHWEST], ANIMATION_FRAMETIME, nil, AN_RUNNING_SOUTHWEST)
        else
            self.animation = anim.newAnimation(an[AN_WALKING_SOUTHWEST], ANIMATION_FRAMETIME, nil, AN_WALKING_SOUTHWEST)
        end
    elseif self.moveDir == "northwest" then
        if self.state == "Going to foodpile" then
            self.animation = anim.newAnimation(an[AN_WALKING_meat_NORTHWEST], ANIMATION_FRAMETIME, nil, AN_WALKING_meat_NORTHWEST)
        elseif self.state == "Going to workplace with deer" then
            self.animation = anim.newAnimation(an[AN_WALKING_deer_NORTHWEST], ANIMATION_FRAMETIME, nil, AN_WALKING_deer_NORTHWEST)
        elseif self.state == "Shooting" then
            self.animation = anim.newAnimation(an[AN_SHOOTING_NORTHWEST], SHOOT_FRAMETIME, function() self:shootCallback() end, AN_SHOOTING_NORTHWEST)
        elseif self.state == "Sneaking" then
            self.animation = anim.newAnimation(an[AN_SNEAKING_NORTHWEST], SNEAK_FRAMETIME, nil, AN_SNEAKING_NORTHWEST)
        elseif self.state == "Running to deer" then
            self.animation = anim.newAnimation(an[AN_RUNNING_NORTHWEST], ANIMATION_FRAMETIME, nil, AN_RUNNING_NORTHWEST)
        else
            self.animation = anim.newAnimation(an[AN_WALKING_NORTHWEST], ANIMATION_FRAMETIME, nil, AN_WALKING_NORTHWEST)
        end
    elseif self.moveDir == "north" then
        if self.state == "Going to foodpile" then
            self.animation = anim.newAnimation(an[AN_WALKING_meat_NORTH], ANIMATION_FRAMETIME, nil, AN_WALKING_meat_NORTH)
        elseif self.state == "Going to workplace with deer" then
            self.animation = anim.newAnimation(an[AN_WALKING_deer_NORTH], ANIMATION_FRAMETIME, nil, AN_WALKING_deer_NORTH)
        elseif self.state == "Shooting" then
            self.animation = anim.newAnimation(an[AN_SHOOTING_NORTH], SHOOT_FRAMETIME, function() self:shootCallback() end, AN_SHOOTING_NORTH)
        elseif self.state == "Sneaking" then
            self.animation = anim.newAnimation(an[AN_SNEAKING_NORTH], SNEAK_FRAMETIME, nil, AN_SNEAKING_NORTH)
        elseif self.state == "Running to deer" then
            self.animation = anim.newAnimation(an[AN_RUNNING_NORTH], ANIMATION_FRAMETIME, nil, AN_RUNNING_NORTH)
        else
            self.animation = anim.newAnimation(an[AN_WALKING_NORTH], ANIMATION_FRAMETIME, nil, AN_WALKING_NORTH)
        end
    elseif self.moveDir == "south" then
        if self.state == "Going to foodpile" then
            self.animation = anim.newAnimation(an[AN_WALKING_meat_SOUTH], ANIMATION_FRAMETIME, nil, AN_WALKING_meat_SOUTH)
        elseif self.state == "Going to workplace with deer" then
            self.animation = anim.newAnimation(an[AN_WALKING_deer_SOUTH], ANIMATION_FRAMETIME, nil, AN_WALKING_deer_SOUTH)
        elseif self.state == "Shooting" then
            self.animation = anim.newAnimation(an[AN_SHOOTING_SOUTH], SHOOT_FRAMETIME, function() self:shootCallback() end, AN_SHOOTING_SOUTH)
        elseif self.state == "Sneaking" then
            self.animation = anim.newAnimation(an[AN_SNEAKING_SOUTH], SNEAK_FRAMETIME, nil, AN_SNEAKING_SOUTH)
        elseif self.state == "Running to deer" then
            self.animation = anim.newAnimation(an[AN_RUNNING_SOUTH], ANIMATION_FRAMETIME, nil, AN_RUNNING_SOUTH)
        else
            self.animation = anim.newAnimation(an[AN_WALKING_SOUTH], ANIMATION_FRAMETIME, nil, AN_WALKING_SOUTH)
        end
    elseif self.moveDir == "east" then
        if self.state == "Going to foodpile" then
            self.animation = anim.newAnimation(an[AN_WALKING_meat_EAST], ANIMATION_FRAMETIME, nil, AN_WALKING_meat_EAST)
        elseif self.state == "Going to workplace with deer" then
            self.animation = anim.newAnimation(an[AN_WALKING_deer_EAST], ANIMATION_FRAMETIME, nil, AN_WALKING_deer_EAST)
        elseif self.state == "Shooting" then
            self.animation = anim.newAnimation(an[AN_SHOOTING_EAST], SHOOT_FRAMETIME, function() self:shootCallback() end, AN_SHOOTING_EAST)
        elseif self.state == "Sneaking" then
            self.animation = anim.newAnimation(an[AN_SNEAKING_EAST], SNEAK_FRAMETIME, nil, AN_SNEAKING_EAST)
        elseif self.state == "Running to deer" then
            self.animation = anim.newAnimation(an[AN_RUNNING_EAST], ANIMATION_FRAMETIME, nil, AN_RUNNING_EAST)
        else
            self.animation = anim.newAnimation(an[AN_WALKING_EAST], ANIMATION_FRAMETIME, nil, AN_WALKING_EAST)
        end
    elseif self.moveDir == "southeast" then
        if self.state == "Going to foodpile" then
            self.animation = anim.newAnimation(an[AN_WALKING_meat_SOUTHEAST], ANIMATION_FRAMETIME, nil, AN_WALKING_meat_SOUTHEAST)
        elseif self.state == "Going to workplace with deer" then
            self.animation = anim.newAnimation(an[AN_WALKING_deer_SOUTHEAST], ANIMATION_FRAMETIME, nil, AN_WALKING_deer_SOUTHEAST)
        elseif self.state == "Shooting" then
            self.animation = anim.newAnimation(an[AN_SHOOTING_SOUTHEAST], SHOOT_FRAMETIME, function() self:shootCallback() end, AN_SHOOTING_SOUTHEAST)
        elseif self.state == "Sneaking" then
            self.animation = anim.newAnimation(an[AN_SNEAKING_SOUTHEAST], SNEAK_FRAMETIME, nil, AN_SNEAKING_SOUTHEAST)
        elseif self.state == "Running to deer" then
            self.animation = anim.newAnimation(an[AN_RUNNING_SOUTHEAST], ANIMATION_FRAMETIME, nil, AN_RUNNING_SOUTHEAST)
        else
            self.animation = anim.newAnimation(an[AN_WALKING_SOUTHEAST], ANIMATION_FRAMETIME, nil, AN_WALKING_SOUTHEAST)
        end
    elseif self.moveDir == "northeast" then
        if self.state == "Going to foodpile" then
            self.animation = anim.newAnimation(an[AN_WALKING_meat_NORTHEAST], ANIMATION_FRAMETIME, nil, AN_WALKING_meat_NORTHEAST)
        elseif self.state == "Going to workplace with deer" then
            self.animation = anim.newAnimation(an[AN_WALKING_deer_NORTHEAST], ANIMATION_FRAMETIME, nil, AN_WALKING_deer_NORTHEAST)
        elseif self.state == "Shooting" then
            self.animation = anim.newAnimation(an[AN_SHOOTING_NORTHEAST], SHOOT_FRAMETIME, function() self:shootCallback() end, AN_SHOOTING_NORTHEAST)
        elseif self.state == "Sneaking" then
            self.animation = anim.newAnimation(an[AN_SNEAKING_NORTHEAST], SNEAK_FRAMETIME, nil, AN_SNEAKING_NORTHEAST)
        elseif self.state == "Running to deer" then
            self.animation = anim.newAnimation(an[AN_RUNNING_NORTHEAST], ANIMATION_FRAMETIME, nil, AN_RUNNING_NORTHEAST)
        else
            self.animation = anim.newAnimation(an[AN_WALKING_NORTHEAST], ANIMATION_FRAMETIME, nil, AN_WALKING_NORTHEAST)
        end
    end
end

function Hunter:onNoPathToWorkplace()
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

function Hunter:onNoAvailableDeer()
    self.state = "No deers"
    self.animation = anim.newAnimation(an[AN_IDLE], IDLE_FRAMETIME, function() self:idleCallback() end, AN_IDLE)
    self:clearPath()
end

function Hunter:idleCallback()
    self.animation = anim.newAnimation(an[AN_STAND], STAND_FRAMETIME, function() self:findDeer() end, AN_STAND)
    self:clearPath()
end

function Hunter:setMovementSpeed(speed)
    if speed == "run" then
        self.straightWalkSpeed = STRAIGHT_RUN_SPEED
        self.diagonalWalkSpeed = DIAGONAL_RUN_SPEED
    elseif speed == "sneak" then
        self.straightWalkSpeed = STRAIGHT_SNEAK_SPEED
        self.diagonalWalkSpeed = DIAGONAL_SNEAK_SPEED
    elseif speed == "walk" then
        self.straightWalkSpeed = STRAIGHT_WALK_SPEED
        self.diagonalWalkSpeed = DIAGONAL_WALK_SPEED
    elseif speed == "carry" then
        self.straightWalkSpeed = STRAIGHT_CARRY_SPEED
        self.diagonalWalkSpeed = DIAGONAL_CARRY_SPEED
    else
        print("Error: Movement speed for hunter does not exist: " .. speed)
    end
end

function Hunter:update()
    self.storeTimer = self.storeTimer + _G.dt
    if self.state == "Walking to deer" or self.state == "Sneaking" or self.state == "Shooting" then
        self.targetDeer:waitForHunter()
    end
    if self.pathState == "Waiting for path" then
        self:pathfind()
        if self.animation and self.animation.animationIdentifier ~= AN_STAND then
            self.animation = _G.anim.newAnimation(an[AN_STAND], STAND_FRAMETIME, nil, AN_STAND)
        end
    elseif self.pathState == "No path" then
        self.pathState = "none"
        if self.targetDeer and not self.targetDeer.toBeDeleted then
            self.targetDeer:die() --Removing deer to protect other Hunters from being stuck
            self.targetDeer = nil
        end
        self:onNoAvailableDeer()
    elseif self.state == "Find a job" then
        _G.JobController:findJob(self, "Hunter")
    elseif self.state == "Storing second deer" and self.storeTimer > 0.3 then
        self.storeTimer = 0
        self.state = "Storing third deer"
        _G.foodpile:store('meat')
    elseif self.state == "Storing third deer" and self.storeTimer > 0.3 then
        self.storeTimer = 0
        _G.foodpile:store('meat')
        self.state = "Storing fourth deer"
    elseif self.state == "Storing fourth deer" and self.storeTimer > 0.3 then
        self.storeTimer = 0
        _G.foodpile:store('meat')
        self.animation:resume()
        self.state = "Go to workplace"
    elseif self.state == "Go to foodpile" then
        if _G.foodpile then
            self.state = "Going to foodpile"
            self:setMovementSpeed("walk")
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
                self:onNoPathToWorkplace()
            else
                self:requestPath(closestNode.gx, closestNode.gy, function() self:onNoPathToWorkplace() end)
            end
            self.moveDir = "none"
        end
    elseif self.state ~= "No deers" then
        if self.state == "Looking to hunt deer" then
            self:findDeer()
        elseif self.state == "Go to workplace" then
            self.gx, self.gy = math.round(self.gx), math.round(self.gy)
            self.fx, self.fy = self.gx * 1000 + 500, self.gy * 1000 + 500
            self:requestPath(self.workplace.gx + 1, self.workplace.gy + 2, function() self:onNoPathToWorkplace() end)
            self.state = "Going to workplace"
            self:setMovementSpeed("walk")
            self.moveDir = "none"
        elseif self.state == "Running to deer" or self.state == "Going to foodpile" or self.state == "Going to workplace"
            or
            self.state == "Going to workplace with deer" then
            if self.moveDir == "none" then
                self:updateDirection()
                self:dirSubUpdate()
            end
            self:move()
        elseif self.state == "Walking to deer" then
            if self.moveDir == "none" then
                self:updateDirection()
                self:dirSubUpdate()
            end
            self:move()

            if self:inRangeForSneak() then
                self.state = "Sneaking"
                self:setMovementSpeed("sneak")
                self:dirSubUpdate()
            end
        elseif self.state == "Sneaking" then
            if self:inRangeForShoot() then
                self.state = "Shooting"
                self:dirSubUpdate()
                self:clearPath()
            else
                if self.moveDir == "none" then
                    self:updateDirection()
                    self:dirSubUpdate()
                end
                self:move()
            end
        end
        if self:reachedWaypoint() then
            if self.state == "Running to deer" then
                if self:reachedPathEnd() then
                    self.state = "Collecting deer"
                    self:clearPath()
                    self:collectDeer()
                    return
                else
                    self:setNextWaypoint()
                end
                self.count = self.count + 1
            elseif self.state == "Walking to deer" then
                if self:reachedPathEnd() then
                    self.state = "Collecting deer"
                    self:clearPath()
                    self:collectDeer()
                    return
                else
                    self:setNextWaypoint()
                end
                self.count = self.count + 1
            elseif self.state == "Sneaking" then
                if self:reachedPathEnd() then
                    self.state = "Collecting deer"
                    self:clearPath()
                    self:collectDeer()
                    return
                else
                    self:setNextWaypoint()
                end
                self.count = self.count + 1
            elseif self.state == "Going to workplace with deer" then
                if self:reachedPathEnd() then
                    self.workplace:work(self)
                    self:clearPath()
                    return
                else
                    self:setNextWaypoint()
                end
                self.count = self.count + 1
            elseif self.state == "Going to foodpile" then
                if self:reachedPathEnd() then
                    _G.foodpile:store('meat')
                    self.state = "Storing second deer"
                    self.animation:pause()
                    self.storeTimer = 0
                    self:clearPath()
                    return
                else
                    self:setNextWaypoint()
                end
                self.count = self.count + 1
            elseif self.state == "Going to workplace" then
                if self:reachedPathEnd() then
                    self.state = "Looking to hunt deer"
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

function Hunter:animate()
    self:update()
    Worker.animate(self)
end

return Hunter
