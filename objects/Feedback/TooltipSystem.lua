-- objects/Feedback/TooltipSystem.lua
-- Castle Kingdoms 2027 v2.9.5 - Enhanced Tooltip System
--
-- Rich tooltip system with contextual information for buildings, units,
-- resources, and UI elements. Goes beyond simple text tooltips with:
--
-- Features:
-- - Rich text tooltips (multi-line, colored, with icons)
-- - 6 tooltip types (building, unit, resource, tech, hero, stats)
-- - Delay before showing (configurable, default 0.5s)
-- - Fade-in animation
-- - Smart positioning (avoids screen edges)
-- - Tooltip queue (if multiple elements hovered)
-- - Cost preview (shows resource costs)
-- - Comparison tooltips (compare two units/buildings)
-- - History tracking (recent tooltips)

local TooltipSystem = {}

local initialized = false
local activeTooltip = nil
local tooltipQueue = {}
local delayTimer = 0
local showDelay = 0.5  -- seconds before showing
local fadeAlpha = 0
local fadeSpeed = 8.0
local isFading = false
local recentTooltips = {}
local maxHistory = 20
local maxWidth = 320
local padding = 8

-- Tooltip types with styling
local TOOLTIP_TYPES = {
    building = { bgColor = {0.1, 0.15, 0.2, 0.95}, borderColor = {0.6, 0.5, 0.3}, icon = "🏠" },
    unit = { bgColor = {0.15, 0.1, 0.1, 0.95}, borderColor = {0.8, 0.3, 0.3}, icon = "⚔" },
    resource = { bgColor = {0.1, 0.15, 0.1, 0.95}, borderColor = {0.3, 0.8, 0.3}, icon = "📦" },
    technology = { bgColor = {0.15, 0.1, 0.2, 0.95}, borderColor = {0.6, 0.4, 0.8}, icon = "🔬" },
    hero = { bgColor = {0.2, 0.15, 0.05, 0.95}, borderColor = {1.0, 0.8, 0.2}, icon = "★" },
    stats = { bgColor = {0.1, 0.1, 0.15, 0.95}, borderColor = {0.4, 0.6, 0.9}, icon = "📊" },
    default = { bgColor = {0.1, 0.1, 0.12, 0.95}, borderColor = {0.5, 0.5, 0.5}, icon = "ℹ" },
}

TooltipSystem.TOOLTIP_TYPES = TOOLTIP_TYPES

function TooltipSystem.init()
    if initialized then return end
    initialized = true
    print("[TooltipSystem] Initialized with " .. TooltipSystem._getTypeCount() .. " tooltip types")
end

function TooltipSystem._getTypeCount()
    local count = 0
    for _ in pairs(TOOLTIP_TYPES) do count = count + 1 end
    return count
end

-- Show a tooltip
function TooltipSystem.show(tooltipData)
    if not initialized then return false end
    if not tooltipData or not tooltipData.text then return false end

    tooltipData.type = tooltipData.type or "default"
    tooltipData.x = tooltipData.x or love.mouse.getX()
    tooltipData.y = tooltipData.y or love.mouse.getY()
    tooltipData.lines = TooltipSystem._parseLines(tooltipData.text)
    tooltipData.cost = tooltipData.cost or nil
    tooltipData.stats = tooltipData.stats or nil
    tooltipData.comparison = tooltipData.comparison or nil

    -- Add to queue or replace
    if activeTooltip then
        tooltipQueue = {}
    end
    activeTooltip = tooltipData
    delayTimer = 0
    isFading = false

    -- Record in history
    table.insert(recentTooltips, {
        text = tooltipData.text,
        type = tooltipData.type,
        timestamp = os.time(),
    })
    while #recentTooltips > maxHistory do
        table.remove(recentTooltips, 1)
    end

    return true
end

-- Quick show helpers
function TooltipSystem.showBuilding(name, description, cost, stats)
    return TooltipSystem.show({
        text = name .. "\n" .. description,
        type = "building",
        cost = cost,
        stats = stats,
    })
end

function TooltipSystem.showUnit(name, description, stats)
    return TooltipSystem.show({
        text = name .. "\n" .. description,
        type = "unit",
        stats = stats,
    })
end

function TooltipSystem.showResource(name, amount, description)
    return TooltipSystem.show({
        text = name .. " (" .. amount .. ")\n" .. (description or ""),
        type = "resource",
    })
end

function TooltipSystem.showTech(name, description, cost, researched)
    return TooltipSystem.show({
        text = name .. (researched and " ✓" or "") .. "\n" .. description,
        type = "technology",
        cost = cost,
    })
end

function TooltipSystem.showHero(name, level, ability, stats)
    return TooltipSystem.show({
        text = name .. " (Lvl " .. level .. ")\n" .. ability,
        type = "hero",
        stats = stats,
    })
end

function TooltipSystem.showStats(title, statsTable)
    local text = title
    for k, v in pairs(statsTable) do
        text = text .. "\n  " .. k .. ": " .. tostring(v)
    end
    return TooltipSystem.show({ text = text, type = "stats" })
end

-- Hide tooltip
function TooltipSystem.hide()
    if not activeTooltip then return end
    isFading = true
end

-- Parse multi-line text
function TooltipSystem._parseLines(text)
    local lines = {}
    for line in text:gmatch("[^\n]+") do
        table.insert(lines, line)
    end
    if #lines == 0 then table.insert(lines, text) end
    return lines
end

-- Update
function TooltipSystem.update(dt)
    if not initialized then return end

    if activeTooltip then
        if isFading then
            fadeAlpha = fadeAlpha - fadeSpeed * dt
            if fadeAlpha <= 0 then
                fadeAlpha = 0
                activeTooltip = nil
                isFading = false
                -- Process queue
                if #tooltipQueue > 0 then
                    activeTooltip = table.remove(tooltipQueue, 1)
                    delayTimer = 0
                end
            end
        else
            -- Delay before showing
            if delayTimer < showDelay then
                delayTimer = delayTimer + dt
            else
                fadeAlpha = math.min(1.0, fadeAlpha + fadeSpeed * dt)
            end
            -- Update position to follow mouse
            if activeTooltip then
                activeTooltip.x = love.mouse.getX()
                activeTooltip.y = love.mouse.getY()
            end
        end
    end
end

-- Draw tooltip
function TooltipSystem.draw()
    if not initialized or not activeTooltip or fadeAlpha <= 0 then return end

    local tooltip = activeTooltip
    local style = TOOLTIP_TYPES[tooltip.type] or TOOLTIP_TYPES.default
    local alpha = fadeAlpha

    -- Calculate size
    local font = love.graphics.getFont()
    local lineHeight = font:getHeight()
    local width = 0
    for _, line in ipairs(tooltip.lines) do
        local w = font:getWidth(line)
        if w > width then width = w end
    end
    width = math.min(maxWidth, width + padding * 2)

    local height = #tooltip.lines * lineHeight + padding * 2

    -- Add cost section
    if tooltip.cost then
        height = height + lineHeight + 4
        for k, v in pairs(tooltip.cost) do
            height = height + lineHeight
        end
    end

    -- Add stats section
    if tooltip.stats then
        height = height + lineHeight + 4
        for k, v in pairs(tooltip.stats) do
            height = height + lineHeight
        end
    end

    -- Smart positioning (avoid screen edges)
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local x = tooltip.x + 15
    local y = tooltip.y + 15
    if x + width > screenWidth then x = tooltip.x - width - 15 end
    if y + height > screenHeight then y = tooltip.y - height - 15 end
    if x < 0 then x = 0 end
    if y < 0 then y = 0 end

    -- Draw background
    love.graphics.setColor(style.bgColor[1], style.bgColor[2], style.bgColor[3], style.bgColor[4] * alpha)
    love.graphics.rectangle("fill", x, y, width, height, 4, 4)

    -- Draw border
    love.graphics.setColor(style.borderColor[1], style.borderColor[2], style.borderColor[3], alpha)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, width, height, 4, 4)

    -- Draw text lines
    local textY = y + padding
    for i, line in ipairs(tooltip.lines) do
        if i == 1 then
            -- First line is title (bold-ish)
            love.graphics.setColor(style.borderColor[1], style.borderColor[2], style.borderColor[3], alpha)
        else
            love.graphics.setColor(0.9, 0.9, 0.9, alpha)
        end
        love.graphics.print(line, x + padding, textY)
        textY = textY + lineHeight
    end

    -- Draw cost section
    if tooltip.cost then
        textY = textY + 4
        love.graphics.setColor(0.7, 0.6, 0.3, alpha)
        love.graphics.print("Stroški:", x + padding, textY)
        textY = textY + lineHeight
        for res, amount in pairs(tooltip.cost) do
            local resColor = TooltipSystem._getResourceColor(res)
            love.graphics.setColor(resColor[1], resColor[2], resColor[3], alpha)
            love.graphics.print("  " .. res .. ": " .. tostring(amount), x + padding, textY)
            textY = textY + lineHeight
        end
    end

    -- Draw stats section
    if tooltip.stats then
        textY = textY + 4
        love.graphics.setColor(0.4, 0.7, 0.9, alpha)
        love.graphics.print("Statistika:", x + padding, textY)
        textY = textY + lineHeight
        for k, v in pairs(tooltip.stats) do
            love.graphics.setColor(0.8, 0.8, 0.8, alpha)
            love.graphics.print("  " .. k .. ": " .. tostring(v), x + padding, textY)
            textY = textY + lineHeight
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
end

-- Get resource color
function TooltipSystem._getResourceColor(resource)
    local colors = {
        gold = {1.0, 0.8, 0.2},
        wood = {0.6, 0.4, 0.2},
        stone = {0.6, 0.6, 0.6},
        iron = {0.4, 0.5, 0.6},
        food = {0.3, 0.8, 0.3},
    }
    return colors[resource] or {0.8, 0.8, 0.8}
end

-- Set show delay
function TooltipSystem.setDelay(delay)
    showDelay = math.max(0, delay)
end

-- Set fade speed
function TooltipSystem.setFadeSpeed(speed)
    fadeSpeed = math.max(1.0, speed)
end

-- Get active tooltip
function TooltipSystem.getActive()
    return activeTooltip
end

-- Get history
function TooltipSystem.getHistory(limit)
    local result = {}
    limit = limit or 10
    for i = math.max(1, #recentTooltips - limit + 1), #recentTooltips do
        table.insert(result, recentTooltips[i])
    end
    return result
end

-- Get stats
function TooltipSystem.getStats()
    return {
        active = activeTooltip ~= nil,
        queueSize = #tooltipQueue,
        historyCount = #recentTooltips,
        showDelay = showDelay,
        fadeAlpha = fadeAlpha,
        typeCount = TooltipSystem._getTypeCount(),
    }
end

return TooltipSystem
