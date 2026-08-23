-- objects/Animation/AnimationSystem.lua
-- Castle Kingdoms 2027 - Animation State Machine
--
-- Manages animations for all units with state machine:
-- idle, walk, run, attack, death, hit, build, repair
--
-- Features:
-- - Per-unit animation state machine
-- - Smooth transitions between states
-- - Directional animations (8 directions)
-- - Frame events (e.g., damage applied on attack frame 3)
-- - Animation blending (cross-fade between states)
--
-- Usage:
--   local AnimationSystem = require("objects.Animation.AnimationSystem")
--   AnimationSystem.attachToUnit(unit, "Archer")
--   AnimationSystem.play(unit, "attack", "north")

local AnimationSystem = {}

-- State machine definition
local STATES = {
    idle = {
        loop = true,
        defaultSpeed = 0.15,  -- seconds per frame
        canTransitionTo = {"walk", "run", "attack", "hit", "death", "build", "repair"},
    },
    walk = {
        loop = true,
        defaultSpeed = 0.10,
        canTransitionTo = {"idle", "run", "attack", "hit", "death"},
    },
    run = {
        loop = true,
        defaultSpeed = 0.06,
        canTransitionTo = {"idle", "walk", "attack", "hit", "death"},
    },
    attack = {
        loop = false,
        defaultSpeed = 0.08,
        canTransitionTo = {"idle", "walk", "hit", "death"},
        onComplete = "idle",  -- auto-transition to idle
        eventFrames = {3, 5},  -- damage applied on these frames
    },
    death = {
        loop = false,
        defaultSpeed = 0.12,
        canTransitionTo = {},  -- terminal state
        onComplete = "dead",  -- stay in final frame
    },
    hit = {
        loop = false,
        defaultSpeed = 0.10,
        canTransitionTo = {"idle", "walk", "attack", "death"},
        onComplete = "previous",  -- return to previous state
    },
    build = {
        loop = true,
        defaultSpeed = 0.12,
        canTransitionTo = {"idle", "walk", "hit", "death"},
    },
    repair = {
        loop = true,
        defaultSpeed = 0.12,
        canTransitionTo = {"idle", "walk", "hit", "death"},
    },
}

-- 8 directions for isometric game
local DIRECTIONS = {
    "north", "northeast", "east", "southeast",
    "south", "southwest", "west", "northwest"
}

-- Attach animation system to a unit
function AnimationSystem.attachToUnit(unit, unitClass)
    if unit._animationAttached then return end
    unit._animationAttached = true

    unit.animationState = "idle"
    unit.animationDirection = "south"
    unit.animationFrame = 1
    unit.animationTimer = 0
    unit.animationSpeed = STATES.idle.defaultSpeed
    unit.previousAnimationState = "idle"
    unit.animationEventTriggered = false
    unit.unitClass = unitClass or unit.class and unit.class.name or "Peasant"

    -- Add methods
    unit.playAnimation = AnimationSystem.play
    unit.setAnimationDirection = AnimationSystem.setDirection
    unit.getAnimationState = AnimationSystem.getState
    unit.isAnimationComplete = AnimationSystem.isComplete
    unit.setAnimationSpeed = AnimationSystem.setSpeed
    unit.resetAnimation = AnimationSystem.reset
end

-- Play a specific animation state
-- @param state string One of: idle, walk, run, attack, death, hit, build, repair
-- @param direction string One of 8 directions (optional)
-- @param speed number Frame duration in seconds (optional)
function AnimationSystem.play(self, state, direction, speed)
    if not STATES[state] then
        print("[AnimationSystem] Unknown state: " .. tostring(state))
        return false
    end

    -- Check if transition is allowed
    local currentState = self.animationState
    if currentState == state then return true end  -- already playing

    local allowed = STATES[currentState].canTransitionTo
    local canTransition = false
    for _, s in ipairs(allowed) do
        if s == state then
            canTransition = true
            break
        end
    end

    -- Allow forced transition to death (always allowed)
    if state == "death" then
        canTransition = true
    end

    if not canTransition then
        -- Queue the transition for when current animation completes
        self.queuedAnimation = state
        return false
    end

    -- Save previous state for hit recovery
    if state ~= "hit" and state ~= "death" then
        self.previousAnimationState = state
    end

    -- Set new state
    self.animationState = state
    if direction then
        self.animationDirection = direction
    end
    self.animationSpeed = speed or STATES[state].defaultSpeed
    self.animationFrame = 1
    self.animationTimer = 0
    self.animationEventTriggered = false

    return true
end

-- Set animation direction (8-directional)
function AnimationSystem.setDirection(self, direction)
    -- Validate direction
    for _, dir in ipairs(DIRECTIONS) do
        if dir == direction then
            self.animationDirection = direction
            return true
        end
    end
    -- Invalid direction, keep current
    return false
end

-- Update animation (called every frame)
function AnimationSystem.update(self, dt)
    if not self._animationAttached then return end

    local state = STATES[self.animationState]
    if not state then return end

    self.animationTimer = self.animationTimer + dt

    -- Check for frame event triggers (e.g., damage on attack frame)
    if state.eventFrames and not self.animationEventTriggered then
        for _, eventFrame in ipairs(state.eventFrames) do
            if self.animationFrame == eventFrame then
                self.animationEventTriggered = true
                -- Fire callback if set
                if self.onAnimationEvent then
                    self:onAnimationEvent(self.animationState, self.animationFrame)
                end
                break
            end
        end
    end

    -- Advance frame
    if self.animationTimer >= self.animationSpeed then
        self.animationTimer = 0
        self.animationFrame = self.animationFrame + 1

        -- Check if animation is complete
        local maxFrames = self:getMaxFrames(self.animationState, self.animationDirection)
        if self.animationFrame > maxFrames then
            if state.loop then
                self.animationFrame = 1
            else
                -- Animation complete
                if state.onComplete == "dead" then
                    -- Stay on last frame
                    self.animationFrame = maxFrames
                elseif state.onComplete == "previous" then
                    -- Return to previous state
                    self:playAnimation(self.previousAnimationState or "idle")
                elseif state.onComplete == "idle" then
                    self:playAnimation("idle")
                end

                -- Check queued animation
                if self.queuedAnimation then
                    local queued = self.queuedAnimation
                    self.queuedAnimation = nil
                    self:playAnimation(queued)
                end
            end
        end
    end
end

-- Get current animation state
function AnimationSystem.getState(self)
    return self.animationState, self.animationDirection, self.animationFrame
end

-- Check if current animation is complete (non-looping)
function AnimationSystem.isComplete(self)
    local state = STATES[self.animationState]
    if not state then return true end
    if state.loop then return false end

    local maxFrames = self.getMaxFrames and self:getMaxFrames(self.animationState, self.animationDirection) or 8
    return self.animationFrame >= maxFrames
end

-- Set animation speed (multiplier)
function AnimationSystem.setSpeed(self, speed)
    self.animationSpeed = speed or 0.1
end

-- Reset to idle
function AnimationSystem.reset(self)
    self:playAnimation("idle")
end

-- Determine direction from movement vector
-- @param dx number X movement (-1 to 1)
-- @param dy number Y movement (-1 to 1)
function AnimationSystem.getDirectionFromMovement(dx, dy)
    if dx == 0 and dy == 0 then return nil end

    local angle = math.atan2(dy, dx)
    local degree = math.deg(angle)
    if degree < 0 then degree = degree + 360 end

    -- 8 directions, 45 degrees each
    -- North = -90deg (or 270), East = 0, South = 90, West = 180
    if degree >= 247.5 and degree < 292.5 then return "north"
    elseif degree >= 292.5 and degree < 337.5 then return "northeast"
    elseif degree >= 337.5 or degree < 22.5 then return "east"
    elseif degree >= 22.5 and degree < 67.5 then return "southeast"
    elseif degree >= 67.5 and degree < 112.5 then return "south"
    elseif degree >= 112.5 and degree < 157.5 then return "southwest"
    elseif degree >= 157.5 and degree < 202.5 then return "west"
    else return "northwest" end
end

-- Get all available states
function AnimationSystem.getStates()
    local list = {}
    for state, _ in pairs(STATES) do
        table.insert(list, state)
    end
    return list
end

-- Get directions
function AnimationSystem.getDirections()
    return DIRECTIONS
end

-- Get state info
function AnimationSystem.getStateInfo(state)
    return STATES[state]
end

-- Batch update all units with animation system (called from game loop)
function AnimationSystem.updateAll(dt)
    if not _G.state or not _G.state.gameObjectList then return end

    for _, unit in ipairs(_G.state.gameObjectList) do
        if unit._animationAttached and not unit.toBeDeleted then
            -- v3.12.165: LOD check - skip animation update for low-LOD/off-LOD units
            if _G.LODSystem and not _G.LODSystem.shouldAnimate(unit) then
                -- Skip animation update for this frame (LOD optimization)
            else
                AnimationSystem.update(unit, dt)
            end

            -- Auto-determine animation state based on combat state
            -- (still runs every frame, but cheap)
            if unit.combatState then
                local COMBAT = require("objects.Enums.Combat")
                if unit.combatState == COMBAT.STATE_ATTACKING and unit.animationState ~= "attack" then
                    unit:playAnimation("attack")
                elseif unit.combatState == COMBAT.STATE_DEAD and unit.animationState ~= "death" then
                    unit:playAnimation("death")
                elseif unit.combatState == COMBAT.STATE_RETREATING and unit.animationState ~= "run" then
                    unit:playAnimation("run")
                end
            end

            -- Auto-determine direction based on movement
            if unit.moveDir and unit.moveDir ~= "none" then
                local dx, dy = 0, 0
                if unit.moveDir == "north" then dy = -1
                elseif unit.moveDir == "south" then dy = 1
                elseif unit.moveDir == "east" then dx = 1
                elseif unit.moveDir == "west" then dx = -1
                elseif unit.moveDir == "northeast" then dx = 1; dy = -1
                elseif unit.moveDir == "northwest" then dx = -1; dy = -1
                elseif unit.moveDir == "southeast" then dx = 1; dy = 1
                elseif unit.moveDir == "southwest" then dx = -1; dy = 1
                end

                if dx ~= 0 or dy ~= 0 then
                    local dir = AnimationSystem.getDirectionFromMovement(dx, dy)
                    if dir then
                        unit:setAnimationDirection(dir)
                    end
                    -- Switch to walk/run based on speed
                    if unit.animationState == "idle" then
                        unit:playAnimation("walk")
                    end
                end
            elseif unit.animationState == "walk" or unit.animationState == "run" then
                -- Not moving, return to idle
                unit:playAnimation("idle")
            end
        end
    end
end

return AnimationSystem
