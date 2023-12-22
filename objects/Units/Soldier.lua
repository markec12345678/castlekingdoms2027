local Unit = require("objects.Units.Unit")

local Soldier = _G.class("Soldier", Unit)

function Soldier:initialize(gx, gy, type)
    Unit.initialize(self, gx, gy, type)
    self.health = 100
    self.waitingForPathMaxTime = 60
    self.pathFoundCallback = nil

    local barracksType = _G.selectedRecruitLocation.class.name
    if barracksType == "Barracks" or barracksType == "StoneBarracks" or barracksType == "Cathedral" then
        self.state = "Going to barracks"
    elseif barracksType == "EngineersGuild" or barracksType == "TunnelersGuild" then
        self.state = "Going to guild"
    else
        error("Unknown barracks type: " .. tostring(barracksType))
    end

    local gx, gy, _ = _G.selectedRecruitLocation:getNextFreeSpot(self)
    if not gx then
        error("No free spots at barracks for soldier?")
    end
    self:requestPath(gx, gy)
end

function Soldier:getDirectionalAnimation(an, animation, durations, onLoop, direction)
    --TODO: hardcode animations indexes so we don't concatenate strings in game
    if direction == "none" then
        direction = "west"
    end
    if direction == "west" then
        local unitAnim = anim.newAnimation(an[animation .. "_w"], durations, onLoop, animation .. "_w")
        unitAnim:gotoFrame(math.random(10))
        return unitAnim
    elseif direction == "southwest" then
        local unitAnim = anim.newAnimation(an[animation .. "_sw"], durations, onLoop, animation .. "_sw")
        unitAnim:gotoFrame(math.random(10))
        return unitAnim
    elseif direction == "northwest" then
        local unitAnim = anim.newAnimation(an[animation .. "_nw"], durations, onLoop, animation .. "_nw")
        unitAnim:gotoFrame(math.random(10))
        return unitAnim
    elseif direction == "north" then
        local unitAnim = anim.newAnimation(an[animation .. "_n"], durations, onLoop, animation .. "_n")
        unitAnim:gotoFrame(math.random(10))
        return unitAnim
    elseif direction == "south" then
        local unitAnim = anim.newAnimation(an[animation .. "_s"], durations, onLoop, animation .. "_s")
        unitAnim:gotoFrame(math.random(10))
        return unitAnim
    elseif direction == "east" then
        local unitAnim = anim.newAnimation(an[animation .. "_e"], durations, onLoop, animation .. "_e")
        unitAnim:gotoFrame(math.random(10))
        return unitAnim
    elseif direction == "southeast" then
        local unitAnim = anim.newAnimation(an[animation .. "_se"], durations, onLoop, animation .. "_se")
        unitAnim:gotoFrame(math.random(10))
        return unitAnim
    elseif direction == "northeast" then
        local unitAnim = anim.newAnimation(an[animation .. "_ne"], durations, onLoop, animation .. "_ne")
        unitAnim:gotoFrame(math.random(10))
        return unitAnim
    end
    error("Invalid animation direction!")
end

function Soldier:gotoUserWaypoint(gx, gy, waypointFloat, callback)
    local pathfindable = self:requestPath(gx, gy)
    if self.animation then
        self.animation:pause()
    end
    if not pathfindable then
        print("Soldier: can't go there my lord")
        if callback then callback() end
        return
    end
    if callback then self.pathFoundCallback = callback end
    self.waypointFloat = waypointFloat
    self.state = "Waiting to go to waypoint"
end

function Soldier:onClick()
    _G.selectedUnit = self
end

function Soldier:update()
    if self.waypointFloat and not self.waypointFloat.active then
        self.waypointFloat = nil
    end
    if self.pathState == "Waiting for path" then
        self:pathfind()
    elseif self.state == "Waiting to go to waypoint" and self.pathState == "Found" then
        if type(self.pathFoundCallback) == "function" then
            self.pathFoundCallback()
            self.pathFoundCallback = true
        elseif self.pathFoundCallback ~= true then
            self.state = "Going to waypoint"
        end
    elseif self.state == "Going to barracks" or self.state == "Going to guild" or self.state == "Going to waypoint" then
        self:updateDirection()
        self:move()
    elseif self.state == "Go to barracks" then
        if not _G.selectedRecruitLocation then error("unit needs to be enlisted via barracks, _G.selectedRecruitLocation = nil") end
        local gx, gy, _ = _G.selectedRecruitLocation:getNextFreeSpot(self)
        if not gx then error("no free spots at barracks for soldier?") end
        self:requestPath(gx, gy)
        self.state = "Going to barracks"
    elseif self.state == "Go to guild" then
        if not _G.selectedRecruitLocation then error("unit needs to be enlisted via guild, _G.selectedRecruitLocation = nil") end
        local gx, gy, _ = _G.selectedRecruitLocation:getNextFreeSpot(self)
        if not gx then error("no free spots at guild for support units?") end
        self:requestPath(gx, gy)
        self.state = "Going to guild"
    end

    local finishedCurrentWaypoint = self.fx * 0.001 == self.waypointX and self.fy * 0.001 == self.waypointY and self.moveDir ~= "none"
    if finishedCurrentWaypoint then
        local finishedEntirePath = self:reachedPathEnd()
        if finishedEntirePath then
            self:clearPath()
            if self.state == "Going to barracks" or self.state == "Going to guild" then
                self.moveDir = "south"
                self:dirSubUpdate()
                Unit.animate(self) -- render one time to orient itself south
            elseif self.state == "Going to waypoint" then
                if self.waypointFloat and self.waypointFloat.active then
                    self.waypointFloat:remove()
                    self.waypointFloat = nil
                end
            end
            self.animation:pause()
            self.state = "Idle"
            return
        else
            self:setNextWaypoint()
        end
        self.count = self.count + 1
    end
end

function Soldier:animate()
    self:update()
    Unit.animate(self)
end

return Soldier
