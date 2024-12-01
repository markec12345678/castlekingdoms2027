local Unit = require("objects.Units.Unit")
local Object = require("objects.Object")
local anim = require("libraries.anim8")

local an = require("objects.Animations.Lord")

local Lord = _G.class("Lord", Unit)

function Lord:initialize(gx, gy)
    Unit.initialize(self, gx, gy, type)
    self:usePallete(2)
    self.state = "Going to keep"
    self.count = 1
    self.offsetY = -5 - 8
    self.offsetX = -8
    self.animated = true
    self.pathState = "No path"
    self.swordOut = false
end

local function getRandomDirection(notDirection)
    local directions = { "north", "south", "east", "west", "northwest", "northeast", "southwest", "southeast" }
    local find = function(direction) for k, d in ipairs(directions) do if d == direction then return k end end end
    if notDirection ~= nil and notDirection ~= "none" then
        local removeIndex = find(notDirection)
        if removeIndex ~= nil then
            table.remove(directions, removeIndex)
        end
    end
    local index = math.random(#directions)
    return directions[index]
end

function Lord:load(data)
    Object.deserialize(self, data)
    Unit.load(self, data)
    local anData = data.animation
    local callback
    if anData then
        self.animation = anim.newAnimation(an[anData.animationIdentifier], 0.05, callback, anData.animationIdentifier)
        self.animation:deserialize(anData)
    end
end

function Lord:getDirectionalAnimation(animation, durations, onLoop, direction)
    --TODO: hardcode animations indexes so we don't concatenate strings in game
    if direction == "none" then
        direction = getRandomDirection()
    end
    if direction == "west" then
        return anim.newAnimation(an[animation .. "_w"], durations, onLoop, animation .. "_w")
    elseif direction == "southwest" then
        return anim.newAnimation(an[animation .. "_sw"], durations, onLoop, animation .. "_sw")
    elseif direction == "northwest" then
        return anim.newAnimation(an[animation .. "_nw"], durations, onLoop, animation .. "_nw")
    elseif direction == "north" then
        return anim.newAnimation(an[animation .. "_n"], durations, onLoop, animation .. "_n")
    elseif direction == "south" then
        return anim.newAnimation(an[animation .. "_s"], durations, onLoop, animation .. "_s")
    elseif direction == "east" then
        return anim.newAnimation(an[animation .. "_e"], durations, onLoop, animation .. "_e")
    elseif direction == "southeast" then
        return anim.newAnimation(an[animation .. "_se"], durations, onLoop, animation .. "_se")
    elseif direction == "northeast" then
        return anim.newAnimation(an[animation .. "_ne"], durations, onLoop, animation .. "_ne")
    end
    error("Invalid animation direction!")
end

function Lord:dirSubUpdate()
    local walkAnimationName = self.swordOut and "body_lord_walk_sword" or "body_lord_walk"
    local animation = self:getDirectionalAnimation(walkAnimationName, 0.05, nil, self.moveDir)

    if (animation ~= nil) then
        self.animation = animation
    end
end

function Lord:getRandomWaypoint(radius, anchor)
    local targetX = self.gx
    local targetY = self.gy
    local spreadRadius = radius or 5

    if anchor ~= nil then
        targetX = anchor.gx or targetX
        targetY = anchor.gy or targetY
    end

    -- TODO: this below two lines prevent lord from going behind buildings
    targetX = targetX + math.random(spreadRadius, spreadRadius * 2)
    targetY = targetY + math.random(spreadRadius, spreadRadius * 2)

    if _G.state.map:getWalkable(targetX, targetY) == 1 then return -1, -1 end

    return targetX, targetY
end

local tasks = { "Wander", "Wander", "Wander", "Wander", "Wander", "Wander", "Wander", "Wander", "Going to keep" }
function Lord:chooseNewTask()
    self.pathState = "No path"
    self.swordOut = math.random(4) == 1
    local chosenTask = tasks[math.random(#tasks)]
    if self.previousTask == "Going to keep" then chosenTask = "Wander" end
    self.previousTask = chosenTask

    if chosenTask == "Wander" then
        -- TODO: this should really only choose the keep, and the lord should choose a location withion a large radius, perhaps 10
        -- since there are no soldiers, for now this walks to a random building to produce the 'wandering' effect
        local targetX, targetY
        local circuitBreaker = 0
        repeat
            circuitBreaker = circuitBreaker + 1
            if circuitBreaker > 20 then
                self:clearPath()
                self.state = "Idle"
                local d = getRandomDirection()
                self:doIdle(0, d)
                return
            end
            targetX, targetY = self:getRandomWaypoint(10, _G.BuildingManager:getRandomBuilding())
        until (targetX ~= -1)
        self:clearPath()
        self:requestPath(targetX, targetY)
        self.state = "Wander"
    elseif chosenTask == "Going to keep" then
        -- TODO: go to keep's door and idle there for a few seconds
        -- (if using a keep-tower with a roof, stand on top)
        self:clearPath()
        self:requestPath(_G.spawnPointX, _G.spawnPointY)
        self.state = "Wander"
    elseif chosenTask == "Find recruit" then
        -- TODO: add "Giving orders" task where the lord will go to a newly recruited soldier and idle in front of them for a couple seconds
        -- he does this once for every soldier when they are recruited and then never again
        -- therefore, this task is only relevant so long as there are soldiers remaining on the map that have not yet been 'ordered'
    elseif chosenTask == "Visit fortification" then
        -- TODO: add "Visit fortification" task where the lord goes and stands on top of a random tower/gatehouse for a couple seconds
    end
end

function Lord:update()
    if self.pathState == "Waiting for path" then
        self:pathfind()
    elseif self.pathState == "No path" then
        local targetX, targetY = self:getRandomWaypoint(5, _G.BuildingManager:getRandomBuilding())
        self:requestPath(targetX, targetY)
    elseif self.state == "Go to keep" then
        self:clearPath()
        self:requestPath(_G.spawnPointX, _G.spawnPointY)
        self.state = "Wander"
    elseif self.state == "Going to keep" then
        self:updateDirection()
        self:move()
    elseif self.state == "Find recruit" then
        self:updateDirection()
        self:move()
    elseif self.state == "Wander" then
        self:updateDirection()
        self:move()
    elseif self.state == "Visit fortification" then
        self:updateDirection()
        self:move()
    end

    if self:reachedWaypoint() then
        if self:reachedPathEnd() then
            self:clearPath()
            self.state = "Idle"
            self:doIdle(0, getRandomDirection())
            return
        else
            self:setNextWaypoint()
        end
        self.count = self.count + 1
    end
end

function Lord:doIdle(idle_count, direction)
    local doActionCallback = function()
        -- idle again recursively in a new direction
        local newDirection = getRandomDirection()
        self:doIdle(idle_count + 1, newDirection)
    end

    local r = math.random(5)
    local stopIdling = (r == 1) or idle_count > 4
    if stopIdling then
        -- finish idling
        doActionCallback = function()
            self:chooseNewTask()
        end
    end
    local idle_frame_delay = 0.8
    self.animation = self:getDirectionalAnimation("body_lord_idle_stand", idle_frame_delay, doActionCallback, direction)
end

function Lord:animate()
    self:update()
    Unit.animate(self)
end

function Lord:serialize()
    local data = {}
    local unitData = Unit.serialize(self)
    for k, v in pairs(unitData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.state = self.state
    data.count = self.count
    data.offsetY = self.offsetY
    data.offsetX = self.offsetX
    data.animated = self.animated
    if self.animation then
        data.animation = self.animation:serialize()
    end
    return data
end

return Lord
