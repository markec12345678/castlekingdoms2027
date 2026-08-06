-- states/ui/hud/economic_event_log.lua
-- Stronghold 2027 - Economic Event Log HUD Widget
--
-- Discreet toast/banner notifications for economic events:
-- - Shows active events with icons and time remaining
-- - Appears when events trigger, fades when they end
-- - Positioned on right side of screen (stacked vertically)
-- - Color-coded: green = positive, red = negative
--
-- Always visible during gameplay (no toggle needed)
--
-- Usage:
--   local EventLog = require("states.ui.hud.economic_event_log")
--   EventLog.update(dt)
--   EventLog.draw()

local EconomicEvents = require("objects.Economy.EconomicEventsSystem")

local EventLog = {}

local enabled = true
local fadeTime = 0  -- for fade-in animation

-- Event display info
local EVENT_INFO = {
    blight = { icon = "!", color = {1, 0.3, 0.3}, short = "Nesreca za pridelke" },
    bumper_harvest = { icon = "+", color = {0.3, 1, 0.3}, short = "Bogata letina" },
    gold_rush = { icon = "$", color = {1, 0.85, 0.3}, short = "Zlata mrzlica" },
    plague = { icon = "X", color = {0.8, 0.2, 0.2}, short = "Kuga" },
    trade_boom = { icon = "^", color = {0.3, 1, 0.5}, short = "Trgovski razcvet" },
    trade_bust = { icon = "v", color = {1, 0.5, 0.3}, short = "Trgovski zaton" },
    mild_winter = { icon = "~", color = {0.5, 0.8, 1}, short = "Blaga zima" },
    harsh_winter = { icon = "*", color = {0.7, 0.85, 1}, short = "Ostra zima" },
    merchant_caravan = { icon = "C", color = {1, 0.85, 0.3}, short = "Trgovska karavana" },
    festival = { icon = "F", color = {1, 0.5, 0.8}, short = "Praznik" },
}

-- Position configuration
local config = {
    startX = 0,  -- will be calculated based on screen width
    startY = 80,
    width = 220,
    height = 45,
    spacing = 5,
    fadeSpeed = 5.0,
}

-- Track active events with their own fade state
local trackedEvents = {}  -- map of event key -> { info, alpha, age }

function EventLog.setEnabled(state)
    enabled = state
end

function EventLog.isEnabled()
    return enabled
end

-- Update tracked events
function EventLog.update(dt)
    if not enabled then return end

    fadeTime = fadeTime + dt

    -- Get currently active events from EconomicEventsSystem
    local activeEvents = EconomicEvents.getActiveEvents()

    -- Update tracked events
    local seenKeys = {}
    for _, active in ipairs(activeEvents) do
        seenKeys[active.key] = true

        if not trackedEvents[active.key] then
            -- New event - start with fade-in
            trackedEvents[active.key] = {
                info = active,
                alpha = 0,
                age = 0,
            }
        else
            -- Update existing
            trackedEvents[active.key].info = active
            trackedEvents[active.key].alpha = math.min(1, trackedEvents[active.key].alpha + dt * config.fadeSpeed)
        end
    end

    -- Remove events that are no longer active (fade out)
    for key, tracked in pairs(trackedEvents) do
        if not seenKeys[key] then
            tracked.alpha = tracked.alpha - dt * config.fadeSpeed
            if tracked.alpha <= 0 then
                trackedEvents[key] = nil
            end
        end
    end
end

-- Draw event log
function EventLog.draw()
    if not enabled then return end
    if not _G.state or not _G.state.initialized then return end

    local screenW = love.graphics.getDimensions()
    config.startX = screenW - config.width - 10

    local y = config.startY

    -- Sort events by time remaining (longest first)
    local sortedEvents = {}
    for key, tracked in pairs(trackedEvents) do
        table.insert(sortedEvents, { key = key, tracked = tracked })
    end
    table.sort(sortedEvents, function(a, b)
        return a.tracked.info.remaining > b.tracked.info.remaining
    end)

    -- Draw each event
    for _, item in ipairs(sortedEvents) do
        local tracked = item.tracked
        local info = tracked.info
        local eventInfo = EVENT_INFO[info.key] or { icon = "?", color = {0.7, 0.7, 0.7}, short = info.nameSlv or info.name }

        local alpha = tracked.alpha
        local x = config.startX

        -- Background panel
        love.graphics.setColor(0.1, 0.1, 0.15, alpha * 0.9)
        love.graphics.rectangle("fill", x, y, config.width, config.height, 4, 4, 4, 4)

        -- Colored border (event type)
        local c = eventInfo.color
        love.graphics.setColor(c[1], c[2], c[3], alpha)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", x, y, config.width, config.height, 4, 4, 4, 4)

        -- Icon (large, left side)
        love.graphics.setColor(c[1], c[2], c[3], alpha)
        love.graphics.print(eventInfo.icon, x + 8, y + 8)

        -- Event name (Slovenian)
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.print(eventInfo.short, x + 30, y + 6)

        -- Time remaining
        love.graphics.setColor(0.7, 0.7, 0.7, alpha)
        love.graphics.print(string.format("%.0fs preostalo", info.remaining), x + 30, y + 24)

        -- Progress bar (time elapsed)
        local barX = x + 8
        local barY = y + config.height - 8
        local barW = config.width - 16
        local barH = 3

        love.graphics.setColor(0.2, 0.2, 0.2, alpha)
        love.graphics.rectangle("fill", barX, barY, barW, barH)

        local progress = 1.0 - (info.remaining / info.duration)
        progress = math.max(0, math.min(1, progress))

        love.graphics.setColor(c[1], c[2], c[3], alpha)
        love.graphics.rectangle("fill", barX, barY, barW * progress, barH)

        y = y + config.height + config.spacing
    end

    love.graphics.setColor(1, 1, 1, 1)
end

-- Get info for debug
function EventLog.getInfo()
    local count = 0
    for _ in pairs(trackedEvents) do count = count + 1 end
    return {
        enabled = enabled,
        activeCount = count,
    }
end

-- Clear all tracked events
function EventLog.clear()
    trackedEvents = {}
end

return EventLog
