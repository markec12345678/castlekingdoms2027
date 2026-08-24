-- objects/Animation/UnitAnimationSystem.lua
-- Castle Kingdoms 2027 v3.13.6 - Unit Animation Framework
--
-- Provides frame-by-frame animation support for units.
-- Loads animation frames from assets/units/animations/<UnitName>/<state>_<frame>.png
--
-- Animation states (matching COMBAT states):
--   idle, walk, attack, death, hit, retreat
--
-- Each state has N frames: idle_01.png, idle_02.png, ...
-- If no animation files exist, falls back to static HD unit sprite.
--
-- Public API:
--   UnitAnimation.init()                    - preload all animations
--   UnitAnimation.get(unit, state, frame)    - get love.Image for a frame
--   UnitAnimation.hasAnimation(unit, state) - check if animation exists
--   UnitAnimation.getFrameCount(unit, state) - get number of frames
--   UnitAnimation.update(dt)                - update all active animations
--   UnitAnimation.getStats()                - debug info

local UnitAnimation = {}

local COMBAT = require("objects.Enums.Combat")

-- Cache: "unitName_state" → { frames = {Image, ...}, count = N }
local animationCache = {}

-- Cache: "unitName_state" → true (checked, not found)
local checkedCache = {}

-- Animation directory
local ANIM_DIR = "assets/units/animations"

-- Default frame rate (FPS)
local DEFAULT_FPS = 10

-- Active animations: unit → { state, frame, timer, fps }
local activeAnimations = {}

-- Load frames for a unit + state
-- @param unitName string (e.g. "Archer")
-- @param state string (e.g. "idle", "walk", "attack", "death")
-- @return table { frames = {Image,...}, count = N } or nil
local function loadAnimation(unitName, state)
    local key = unitName .. "_" .. state
    if checkedCache[key] then
        return animationCache[key]
    end
    checkedCache[key] = true

    local frames = {}
    local frameNum = 1

    -- Try to load frames: state_01.png, state_02.png, ...
    while frameNum <= 20 do  -- max 20 frames per animation
        local padded = string.format("%02d", frameNum)
        local path = ANIM_DIR .. "/" .. unitName .. "/" .. state .. "_" .. padded .. ".png"
        local ok, imageData = pcall(love.image.newImageData, path)
        if ok and imageData then
            local ok2, image = pcall(love.graphics.newImage, imageData)
            if ok2 and image then
                image:setFilter("linear", "linear")
                table.insert(frames, image)
                frameNum = frameNum + 1
            else
                break
            end
        else
            break
        end
    end

    if #frames > 0 then
        animationCache[key] = { frames = frames, count = #frames }
        return animationCache[key]
    end

    return nil
end

-- Get a specific frame of an animation
-- @param unitName string
-- @param state string
-- @param frame number (1-indexed)
-- @return love.Image or nil
function UnitAnimation.get(unitName, state, frame)
    if not unitName or not state then return nil end
    local key = unitName .. "_" .. state
    local anim = animationCache[key]
    if not anim then
        anim = loadAnimation(unitName, state)
    end
    if anim and anim.frames and anim.frames[frame] then
        return anim.frames[frame]
    end
    return nil
end

-- Check if animation exists
function UnitAnimation.hasAnimation(unitName, state)
    if not unitName or not state then return false end
    local key = unitName .. "_" .. state
    if checkedCache[key] then
        return animationCache[key] ~= nil
    end
    return loadAnimation(unitName, state) ~= nil
end

-- Get frame count
function UnitAnimation.getFrameCount(unitName, state)
    local key = unitName .. "_" .. state
    local anim = animationCache[key]
    if not anim then
        anim = loadAnimation(unitName, state)
    end
    return anim and anim.count or 0
end

-- Get current animation state for a unit
-- Converts combatState to animation state
local function getAnimState(combatState)
    if not combatState then return "idle" end
    if combatState == COMBAT.STATE_IDLE then return "idle"
    elseif combatState == COMBAT.STATE_AGGRO then return "walk"
    elseif combatState == COMBAT.STATE_SEEKING then return "walk"
    elseif combatState == COMBAT.STATE_ATTACKING then return "attack"
    elseif combatState == COMBAT.STATE_RETREATING then return "retreat"
    elseif combatState == COMBAT.STATE_DEAD then return "death"
    end
    return "idle"
end

-- Register a unit for animation updates
-- @param unit The unit object (must have className and combatState)
function UnitAnimation.register(unit)
    if not unit or not unit.className then return end
    activeAnimations[unit] = {
        state = getAnimState(unit.combatState),
        frame = 1,
        timer = 0,
        fps = DEFAULT_FPS,
    }
end

-- Unregister a unit
function UnitAnimation.unregister(unit)
    activeAnimations[unit] = nil
end

-- Update all active animations
function UnitAnimation.update(dt)
    for unit, anim in pairs(activeAnimations) do
        if unit and not unit.toBeDeleted and unit.health and unit.health > 0 then
            -- Check if state changed
            local newState = getAnimState(unit.combatState)
            if newState ~= anim.state then
                anim.state = newState
                anim.frame = 1
                anim.timer = 0
            end

            -- Advance frame
            anim.timer = anim.timer + dt
            if anim.timer >= 1 / anim.fps then
                anim.timer = 0
                local count = UnitAnimation.getFrameCount(unit.className, anim.state)
                if count > 0 then
                    anim.frame = anim.frame + 1
                    if anim.frame > count then
                        -- Loop (except for death which stays on last frame)
                        if anim.state == "death" then
                            anim.frame = count
                        else
                            anim.frame = 1
                        end
                    end
                end
            end
        else
            -- Clean up dead/deleted units
            activeAnimations[unit] = nil
        end
    end
end

-- Get current frame image for a unit
-- @param unit The unit object
-- @return love.Image or nil (fall back to static sprite)
function UnitAnimation.getCurrentFrame(unit)
    if not unit or not unit.className then return nil end
    local anim = activeAnimations[unit]
    if not anim then return nil end

    -- Check if animation exists for this state
    if not UnitAnimation.hasAnimation(unit.className, anim.state) then
        -- Try idle as fallback
        if anim.state ~= "idle" and UnitAnimation.hasAnimation(unit.className, "idle") then
            return UnitAnimation.get(unit.className, "idle", 1)
        end
        return nil  -- No animation, use static sprite
    end

    return UnitAnimation.get(unit.className, anim.state, anim.frame)
end

-- Preload all animations for a list of units
function UnitAnimation.init(unitNames)
    if not unitNames then return 0 end
    local states = {"idle", "walk", "attack", "death", "hit", "retreat"}
    local count = 0
    for _, unitName in ipairs(unitNames) do
        for _, state in ipairs(states) do
            if loadAnimation(unitName, state) then
                count = count + 1
            end
        end
    end
    print(string.format("[UnitAnimation] Initialized (%d animations loaded)", count))
    return count
end

-- Get stats
function UnitAnimation.getStats()
    local animCount = 0
    local frameCount = 0
    for key, anim in pairs(animationCache) do
        animCount = animCount + 1
        frameCount = frameCount + anim.count
    end
    return {
        animationsLoaded = animCount,
        totalFrames = frameCount,
        activeAnimations = 0,  -- computed below
        animDir = ANIM_DIR,
        defaultFPS = DEFAULT_FPS,
    }
end

-- Reset
function UnitAnimation.reset()
    animationCache = {}
    checkedCache = {}
    activeAnimations = {}
end

return UnitAnimation
