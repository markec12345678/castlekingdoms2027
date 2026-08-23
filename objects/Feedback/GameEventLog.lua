-- objects/Feedback/GameEventLog.lua
-- Castle Kingdoms 2027 v3.12.146 - Game Event Log System
--
-- Centralized event logging that captures important game events:
--   * Building placed/upgraded/destroyed
--   * Unit recruited/killed
--   * Market events (crash, surge, trade)
--   * Royal system activated
--   * Achievement unlocked
--   * Difficulty changed
--   * Game saved/loaded
--
-- Events are stored in memory (max 500) and can be filtered by category.

local GameEventLog = {}

local MAX_EVENTS = 500
local events = {}
local nextId = 1

-- Event categories with colors
local CATEGORIES = {
    build      = { label = "GRADNJA",   color = {0.85, 0.7, 0.3} },
    military   = { label = "VOJSKA",     color = {0.9, 0.4, 0.4} },
    economy    = { label = "EKONOMIJA",  color = {0.4, 0.85, 0.4} },
    royal      = { label = "ROYAL",      color = {0.85, 0.6, 0.95} },
    achievement= { label = "DOSEŽKI",    color = {0.95, 0.85, 0.3} },
    system     = { label = "SISTEM",     color = {0.5, 0.65, 0.85} },
    market     = { label = "TRG",         color = {0.4, 0.7, 0.95} },
    combat     = { label = "BOJ",         color = {0.9, 0.5, 0.3} },
}
GameEventLog.CATEGORIES = CATEGORIES

-- Log an event
-- @param category string (build/military/economy/royal/achievement/system/market/combat)
-- @param message string (human-readable description)
-- @param data table (optional, extra context data)
function GameEventLog.log(category, message, data)
    if not CATEGORIES[category] then
        category = "system"
    end
    local event = {
        id = nextId,
        category = category,
        message = message or "",
        data = data or {},
        timestamp = os.time(),
        gameTime = _G.state and _G.state.gameTime or 0,
    }
    nextId = nextId + 1
    table.insert(events, event)
    -- Trim if exceeding max
    while #events > MAX_EVENTS do
        table.remove(events, 1)
    end
    return event.id
end

-- Get all events (optionally filtered by category)
-- @param category string or nil (nil = all)
-- @param limit number or nil (nil = all)
-- @return table (most recent first)
function GameEventLog.getEvents(category, limit)
    local result = {}
    local count = 0
    for i = #events, 1, -1 do
        local event = events[i]
        if not category or event.category == category then
            table.insert(result, event)
            count = count + 1
            if limit and count >= limit then break end
        end
    end
    return result
end

-- Get event by ID
function GameEventLog.getById(id)
    for _, event in ipairs(events) do
        if event.id == id then return event end
    end
    return nil
end

-- Clear all events
function GameEventLog.clear()
    events = {}
    nextId = 1
end

-- Get stats
function GameEventLog.getStats()
    local byCategory = {}
    for _, event in ipairs(events) do
        byCategory[event.category] = (byCategory[event.category] or 0) + 1
    end
    return {
        total = #events,
        maxEvents = MAX_EVENTS,
        byCategory = byCategory,
    }
end

-- Convenience methods
function GameEventLog.logBuild(message, data)
    return GameEventLog.log("build", message, data)
end

function GameEventLog.logMilitary(message, data)
    return GameEventLog.log("military", message, data)
end

function GameEventLog.logEconomy(message, data)
    return GameEventLog.log("economy", message, data)
end

function GameEventLog.logRoyal(message, data)
    return GameEventLog.log("royal", message, data)
end

function GameEventLog.logAchievement(message, data)
    return GameEventLog.log("achievement", message, data)
end

function GameEventLog.logSystem(message, data)
    return GameEventLog.log("system", message, data)
end

function GameEventLog.logMarket(message, data)
    return GameEventLog.log("market", message, data)
end

function GameEventLog.logCombat(message, data)
    return GameEventLog.log("combat", message, data)
end

return GameEventLog
