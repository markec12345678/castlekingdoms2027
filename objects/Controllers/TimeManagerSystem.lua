-- objects/Controllers/TimeManagerSystem.lua
-- Castle Kingdoms 2027 v2.8.8 - Time Manager System
--
-- Advanced time management with game speed control, time-of-day effects,
-- and scheduled events. Goes beyond basic pause/speed to offer:
--
-- Features:
-- - 8 speed levels (0.25x to 10x)
-- - Auto-pause conditions (focus loss, combat start, hero death)
-- - Time-of-day schedule (events at dawn, noon, dusk, midnight)
-- - Time-lapse mode (skip to next event)
-- - Per-system time scaling (AI thinks slower, combat stays realtime)
-- - Time budget tracking (how much real time spent)

local TimeManager = {}

local SPEED_LEVELS = {
    { label = "Pavza",    speed = 0.0,  key = "space" },
    { label = "0.25x",    speed = 0.25, key = "1" },
    { label = "0.5x",     speed = 0.5,  key = "2" },
    { label = "Normal",   speed = 1.0,  key = "3" },
    { label = "2x",       speed = 2.0,  key = "4" },
    { label = "3x",       speed = 3.0,  key = "5" },
    { label = "5x",       speed = 5.0,  key = "6" },
    { label = "10x",      speed = 10.0, key = "7" },
}

TimeManager.SPEED_LEVELS = SPEED_LEVELS

local initialized = false
local currentSpeedIndex = 4  -- default Normal (1.0x)
local currentSpeed = 1.0
local isPaused = false
local gameTime = 0  -- total game time (affected by speed)
local realTime = 0  -- total real time (unaffected)
local timeScale = {
    ai = 1.0,        -- AI update rate
    economy = 1.0,   -- economy update rate
    combat = 1.0,    -- combat update rate (usually stays 1.0)
    weather = 1.0,   -- weather change rate
    animation = 1.0, -- animation speed
}

-- Auto-pause settings
local autoPause = {
    onFocusLoss = true,
    onHeroDeath = false,
    onCombatStart = false,
    onMissionComplete = true,
}

-- Scheduled events (time-of-day)
local SCHEDULE = {
    { time = 0.00, name = "Polnoč", event = "midnight" },
    { time = 0.25, name = "Zora", event = "dawn" },
    { time = 0.50, name = "Poldne", event = "noon" },
    { time = 0.75, name = "Mrak", event = "dusk" },
}

TimeManager.SCHEDULE = SCHEDULE

local lastScheduleEvent = nil
local timeBudget = {}  -- [category] = seconds spent

function TimeManager.init()
    if initialized then return end
    initialized = true
    print("[TimeManager] Initialized — speed: " .. currentSpeed .. "x")
end

-- Set speed by index
function TimeManager.setSpeedIndex(index)
    if index < 1 or index > #SPEED_LEVELS then return false end
    currentSpeedIndex = index
    currentSpeed = SPEED_LEVELS[index].speed
    isPaused = currentSpeed == 0
    if _G.state then
        _G.speedModifier = currentSpeed
    end
    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Hitrost: " .. SPEED_LEVELS[index].label)
    end
    return true
end

-- Set speed by value
function TimeManager.setSpeed(speed)
    for i, level in ipairs(SPEED_LEVELS) do
        if level.speed == speed then
            return TimeManager.setSpeedIndex(i)
        end
    end
    return false
end

-- Toggle pause
function TimeManager.togglePause()
    if isPaused then
        return TimeManager.setSpeedIndex(4)  -- back to Normal
    else
        return TimeManager.setSpeedIndex(1)  -- pause
    end
end

-- Increase speed
function TimeManager.increaseSpeed()
    local next = math.min(#SPEED_LEVELS, currentSpeedIndex + 1)
    return TimeManager.setSpeedIndex(next)
end

-- Decrease speed
function TimeManager.decreaseSpeed()
    local prev = math.max(1, currentSpeedIndex - 1)
    return TimeManager.setSpeedIndex(prev)
end

-- Get current speed
function TimeManager.getSpeed()
    return currentSpeed
end

function TimeManager.getSpeedLabel()
    return SPEED_LEVELS[currentSpeedIndex].label
end

function TimeManager.isPaused()
    return isPaused
end

-- Set per-system time scale
function TimeManager.setSystemScale(system, scale)
    if not timeScale[system] then return false end
    timeScale[system] = math.max(0.1, math.min(10.0, scale))
    return true
end

function TimeManager.getSystemScale(system)
    return timeScale[system] or 1.0
end

-- Get effective dt for a system (game dt * system scale)
function TimeManager.getSystemDt(system, dt)
    if isPaused then return 0 end
    return dt * currentSpeed * (timeScale[system] or 1.0)
end

-- Auto-pause handlers
function TimeManager.onFocusLoss()
    if not autoPause.onFocusLoss then return end
    if not isPaused then
        TimeManager.setSpeedIndex(1)
        if _G.ModernUI then
            _G.ModernUI.notifyInfo("Samodejna pavza (izguba fokusa)")
        end
    end
end

function TimeManager.onHeroDeath()
    if not autoPause.onHeroDeath then return end
    if not isPaused then
        TimeManager.setSpeedIndex(1)
        if _G.ModernUI then
            _G.ModernUI.notifyError("Samodejna pavza (hero padel)")
        end
    end
end

function TimeManager.onCombatStart()
    if not autoPause.onCombatStart then return end
    if not isPaused then
        TimeManager.setSpeedIndex(1)
    end
end

function TimeManager.onMissionComplete()
    if not autoPause.onMissionComplete then return end
    TimeManager.setSpeedIndex(1)
end

-- Set auto-pause option
function TimeManager.setAutoPause(option, enabled)
    if autoPause[option] ~= nil then
        autoPause[option] = enabled
        return true
    end
    return false
end

function TimeManager.getAutoPause(option)
    return autoPause[option]
end

-- Update
function TimeManager.update(dt)
    if not initialized then return end
    realTime = realTime + dt
    if not isPaused then
        gameTime = gameTime + dt * currentSpeed
    end

    -- Check time-of-day schedule
    if _G.LightingSystem and _G.LightingSystem.getTimePeriod then
        local timePeriod = _G.LightingSystem.getTimePeriod():lower()
        local dayProgress = _G.LightingSystem.getDayProgress and _G.LightingSystem.getDayProgress() or 0

        for _, sched in ipairs(SCHEDULE) do
            if dayProgress >= sched.time and lastScheduleEvent ~= sched.event then
                lastScheduleEvent = sched.event
                if _G.ModernUI then
                    _G.ModernUI.notifyInfo("Čas dneva: " .. sched.name)
                end
                if _G.GameEventBus then
                    pcall(function() _G.GameEventBus.emit("time_of_day", { event = sched.event, name = sched.name }) end)
                end
                if _G.VoiceOver then
                    pcall(function() _G.VoiceOver.notify("season_changed", sched.name) end)
                end
            end
        end
    end
end

-- Time-lapse: skip to next scheduled event
function TimeManager.skipToNextEvent()
    if not _G.LightingSystem then return false end
    -- Speed up until next schedule event
    TimeManager.setSpeedIndex(7)  -- 5x
    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Preskok na naslednji dogodek (5x)")
    end
    return true
end

-- Track time budget
function TimeManager.addBudget(category, seconds)
    timeBudget[category] = (timeBudget[category] or 0) + (seconds or 0)
end

function TimeManager.getBudget(category)
    return timeBudget[category] or 0
end

-- Get formatted time
function TimeManager.formatTime(seconds)
    seconds = math.floor(seconds or 0)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    return string.format("%02d:%02d:%02d", h, m, s)
end

-- Get stats
function TimeManager.getStats()
    return {
        speed = currentSpeed,
        speedLabel = SPEED_LEVELS[currentSpeedIndex].label,
        speedIndex = currentSpeedIndex,
        paused = isPaused,
        gameTime = gameTime,
        gameTimeFormatted = TimeManager.formatTime(gameTime),
        realTime = realTime,
        realTimeFormatted = TimeManager.formatTime(realTime),
        timeRatio = realTime > 0 and (gameTime / realTime) or 1.0,
        systemScales = timeScale,
        autoPause = autoPause,
    }
end

-- Get all speed levels for UI
function TimeManager.getSpeedLevels()
    local result = {}
    for i, level in ipairs(SPEED_LEVELS) do
        table.insert(result, {
            index = i,
            label = level.label,
            speed = level.speed,
            key = level.key,
            active = i == currentSpeedIndex,
        })
    end
    return result
end

return TimeManager
