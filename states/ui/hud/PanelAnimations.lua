-- states/ui/hud/PanelAnimations.lua
-- Castle Kingdoms 2027 - Shared Panel Animation Utility (v3.12.126)
--
-- Provides smooth fade-in / fade-out + slide-in / slide-out animation
-- transitions for UI panels. Each panel can register an "anim state" and
-- call update(dt) + applyTransform() during its draw() call.
--
-- Usage:
--   local PanelAnim = require("states.ui.hud.PanelAnimations")
--
--   -- In your panel module (top-level local state):
--   local animState = PanelAnim.createState()
--
--   -- In your toggle():
--   function MyPanel.toggle()
--       if not visible then
--           visible = true
--           PanelAnim.open(animState)  -- start opening animation
--       else
--           PanelAnim.close(animState)  -- start closing animation (visible stays true until done)
--       end
--   end
--
--   -- In your update(dt):
--   function MyPanel.update(dt)
--       if not visible and not PanelAnim.isAnimating(animState) then return end
--       PanelAnim.update(animState, dt)
--       -- Auto-clear visibility once close animation finishes
--       if animState.phase == "closed" then
--           visible = false
--       end
--   end
--
--   -- In your draw(), BEFORE drawing panel content:
--   function MyPanel.draw()
--       if not visible and not PanelAnim.isAnimating(animState) then return end
--       local progress = PanelAnim.getProgress(animState)  -- 0..1 for alpha
--       local offsetX, offsetY = PanelAnim.getOffset(animState)  -- slide offset
--       love.graphics.push("all")
--       love.graphics.translate(offsetX, offsetY)
--       -- ... existing draw code, but multiply alpha by `progress` ...
--       love.graphics.pop()
--   end
--
-- Phases:
--   "closed"      — fully hidden, no animation
--   "opening"     — animating from 0 → 1
--   "open"        — fully visible (no animation)
--   "closing"     — animating from 1 → 0 (visible flag still true)
--
-- Configuration:
--   createState(opts) — opts is a table with optional keys:
--     .duration   = number (seconds, default 0.20) — open/close duration
--     .slideDir   = "up" | "down" | "left" | "right" | "none" (default "down")
--     .slideDist  = number (pixels, default 24) — how far to slide
--     .easing     = "linear" | "easeIn" | "easeOut" | "easeInOut" (default "easeOut")

local PanelAnimations = {}

-- Easing functions
local function easeLinear(t)
    return t
end

local function easeIn(t)
    -- Quadratic ease-in: t^2 (slow start, fast end)
    return t * t
end

local function easeOut(t)
    -- Quadratic ease-out: 1 - (1-t)^2
    return 1 - (1 - t) * (1 - t)
end

local function easeInOut(t)
    -- Quadratic ease-in-out
    if t < 0.5 then
        return 2 * t * t
    else
        return 1 - ((-2 * t + 2) ^ 2) / 2
    end
end

-- Default configuration
local DEFAULT_DURATION = 0.20
local DEFAULT_SLIDE_DIR = "down"
local DEFAULT_SLIDE_DIST = 24
local DEFAULT_EASING = "easeOut"

-- Create a new animation state for a panel
function PanelAnimations.createState(opts)
    opts = opts or {}
    local easingFn = easeOut
    if opts.easing == "linear" then easingFn = easeLinear
    elseif opts.easing == "easeIn" then easingFn = easeIn
    elseif opts.easing == "easeInOut" then easingFn = easeInOut
    elseif opts.easing == "easeOut" then easingFn = easeOut
    end
    return {
        phase = "closed",       -- closed | opening | open | closing
        progress = 0,           -- 0..1 (1 = fully open)
        duration = opts.duration or DEFAULT_DURATION,
        slideDir = opts.slideDir or DEFAULT_SLIDE_DIR,
        slideDist = opts.slideDist or DEFAULT_SLIDE_DIST,
        easingFn = easingFn,
    }
end

-- Start opening animation
function PanelAnimations.open(state)
    if not state then return end
    state.phase = "opening"
    state.progress = 0
end

-- Start closing animation
function PanelAnimations.close(state)
    if not state then return end
    -- If already closed or closing, do nothing
    if state.phase == "closed" or state.phase == "closing" then return end
    state.phase = "closing"
    -- progress stays at current value (whatever open progress we had)
end

-- Snap to fully open (no animation) — useful for first-frame scenarios
function PanelAnimations.snapOpen(state)
    if not state then return end
    state.phase = "open"
    state.progress = 1
end

-- Snap to fully closed (no animation)
function PanelAnimations.snapClosed(state)
    if not state then return end
    state.phase = "closed"
    state.progress = 0
end

-- Update animation progress based on dt
function PanelAnimations.update(state, dt)
    if not state then return end
    if state.phase == "opening" then
        state.progress = state.progress + dt / state.duration
        if state.progress >= 1 then
            state.progress = 1
            state.phase = "open"
        end
    elseif state.phase == "closing" then
        state.progress = state.progress - dt / state.duration
        if state.progress <= 0 then
            state.progress = 0
            state.phase = "closed"
        end
    end
end

-- Get current eased progress (0..1) for alpha multiplication
function PanelAnimations.getProgress(state)
    if not state then return 1 end
    if state.phase == "closed" then return 0 end
    if state.phase == "open" then return 1 end
    return state.easingFn(state.progress)
end

-- Get slide offset (dx, dy) for current frame
-- Returns 0,0 when fully open or fully closed
function PanelAnimations.getOffset(state)
    if not state then return 0, 0 end
    if state.phase == "open" or state.phase == "closed" then
        return 0, 0
    end
    -- Slide direction inverts for closing (we want it to slide OUT the same way it slid IN)
    local t = state.easingFn(state.progress)
    -- For opening: offset = (1-t) * slideDist in slideDir
    -- For closing: offset = (1-t) * slideDist in slideDir (same formula since progress goes 1→0)
    local mag = (1 - t) * state.slideDist
    if state.slideDir == "up" then
        return 0, -mag
    elseif state.slideDir == "down" then
        return 0, mag
    elseif state.slideDir == "left" then
        return -mag, 0
    elseif state.slideDir == "right" then
        return mag, 0
    end
    return 0, 0
end

-- Check if any animation is in progress
function PanelAnimations.isAnimating(state)
    if not state then return false end
    return state.phase == "opening" or state.phase == "closing"
end

-- Check if the panel should be considered "visible" for input routing
-- (i.e., it's opening, open, or closing — but not fully closed)
function PanelAnimations.isShown(state)
    if not state then return false end
    return state.phase ~= "closed"
end

return PanelAnimations
