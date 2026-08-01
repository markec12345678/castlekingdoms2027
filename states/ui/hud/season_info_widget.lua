-- states/ui/hud/season_info_widget.lua
-- Stronghold 2027 - Season Info HUD Widget
--
-- Small, elegant widget in screen corner showing:
-- - Current season with icon
-- - Year count
-- - Time to next season (progress bar)
--
-- Always visible during gameplay (no toggle needed)
--
-- Usage:
--   local SeasonWidget = require("states.ui.hud.season_info_widget")
--   SeasonWidget.update(dt)
--   SeasonWidget.draw()

local SeasonalSystem = require("objects.Economy.SeasonalSystem")

local SeasonWidget = {}

local enabled = true
local alpha = 0.9
local pulseTime = 0

local SEASON_ICONS = {
    spring = "*",
    summer = "#",
    autumn = "~",
    winter = "+",
}

local SEASON_COLORS = {
    spring = {0.5, 0.9, 0.4},
    summer = {1.0, 0.85, 0.3},
    autumn = {0.9, 0.6, 0.2},
    winter = {0.7, 0.85, 1.0},
}

local config = {
    x = 10,
    y = 10,
    width = 180,
    height = 65,
    padding = 8,
}

function SeasonWidget.setEnabled(state)
    enabled = state
end

function SeasonWidget.isEnabled()
    return enabled
end

function SeasonWidget.update(dt)
    pulseTime = pulseTime + dt
end

function SeasonWidget.draw()
    if not enabled then return end
    if not _G.state or not _G.state.initialized then return end

    local info = SeasonalSystem.getSeasonInfo()
    if not info then return end

    local x = config.x
    local y = config.y
    local w = config.width
    local h = config.height

    -- Background panel
    love.graphics.setColor(0.1, 0.1, 0.15, alpha * 0.85)
    love.graphics.rectangle("fill", x, y, w, h, 4, 4, 4, 4)

    -- Border (season-colored)
    local seasonColor = SEASON_COLORS[info.current] or {1, 1, 1}
    love.graphics.setColor(seasonColor[1], seasonColor[2], seasonColor[3], alpha * 0.8)
    love.graphics.setLineWidth(1.5)
    love.graphics.rectangle("line", x, y, w, h, 4, 4, 4, 4)

    -- Season icon
    local icon = SEASON_ICONS[info.current] or "*"
    love.graphics.setColor(seasonColor[1], seasonColor[2], seasonColor[3], alpha)
    love.graphics.print(icon, x + config.padding, y + 5)

    -- Season name (Slovenian)
    love.graphics.setColor(1, 1, 1, alpha)
    love.graphics.print(info.nameSlv or info.name, x + 40, y + 5)

    -- Year
    love.graphics.setColor(0.8, 0.8, 0.8, alpha)
    love.graphics.print("Leto " .. info.year, x + 40, y + 22)

    -- Progress bar
    local barX = x + config.padding
    local barY = y + 42
    local barW = w - config.padding * 2
    local barH = 6

    love.graphics.setColor(0.2, 0.2, 0.2, alpha)
    love.graphics.rectangle("fill", barX, barY, barW, barH)

    local progress = 1.0 - (info.timeRemaining / info.duration)
    progress = math.max(0, math.min(1, progress))

    love.graphics.setColor(seasonColor[1], seasonColor[2], seasonColor[3], alpha)
    love.graphics.rectangle("fill", barX, barY, barW * progress, barH)

    -- Time remaining
    love.graphics.setColor(0.7, 0.7, 0.7, alpha)
    local timeText = string.format("-> %s (%.0fs)", SeasonalSystem.getNextSeason(), info.timeRemaining)
    love.graphics.print(timeText, x + config.padding, y + 52)

    love.graphics.setColor(1, 1, 1, 1)
end

function SeasonWidget.getInfo()
    return { enabled = enabled, alpha = alpha }
end

return SeasonWidget
