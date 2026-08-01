-- objects/Controllers/HealthBarController.lua
-- Stronghold 2027 - Health Bar UI
--
-- Draws health bars above units when they're damaged or in combat
-- Optimized: only draws bars for units with health < max or in combat

local HealthBarController = _G.class("HealthBarController")

function HealthBarController:initialize()
    self.enabled = true
    self.visibleUnits = {}  -- Units currently showing health bars
    self.barWidth = 40
    self.barHeight = 5
    self.barOffsetY = 60  -- Above unit
    self.showThreshold = 0.95  -- Show bar if health < 95% of max

    print("HealthBarController initialized")
end

function HealthBarController:setEnabled(state)
    self.enabled = state
end

function HealthBarController:update(dt)
    if not self.enabled then return end
    if not _G.state or not _G.state.gameObjectList then return end

    self.visibleUnits = {}

    for _, unit in ipairs(_G.state.gameObjectList) do
        if unit.health and unit.maxHealth and not unit.toBeDeleted then
            -- Show health bar if:
            -- 1. Health is below threshold
            -- 2. Unit is in combat state
            -- 3. Unit is selected
            local shouldShow = false

            if unit.health < unit.maxHealth * self.showThreshold then
                shouldShow = true
            end

            if unit.combatState and unit.combatState ~= "idle" then
                shouldShow = true
            end

            if unit.selected then
                shouldShow = true
            end

            if shouldShow then
                table.insert(self.visibleUnits, unit)
            end
        end
    end
end

function HealthBarController:draw()
    if not self.enabled then return end

    for _, unit in ipairs(self.visibleUnits) do
        self:drawHealthBar(unit)
    end
end

function HealthBarController:drawHealthBar(unit)
    if not unit.gx or not unit.gy then return end

    -- Convert world coords to screen (simplified isometric)
    local screenX = unit.gx * 32 - unit.gy * 32
    local screenY = unit.gx * 16 + unit.gy * 16

    -- Apply view offset
    screenX = screenX - (_G.state.viewXview or 0)
    screenY = screenY - (_G.state.viewYview or 0) - self.barOffsetY

    -- Adjust for unit offset
    if unit.unitOffsetY then
        screenY = screenY - unit.unitOffsetY
    end

    -- Apply scale
    local scaleX = _G.state.scaleX or 1
    local barX = screenX - (self.barWidth / 2) * scaleX
    local barY = screenY
    local barW = self.barWidth * scaleX
    local barH = self.barHeight * scaleX

    -- Calculate health percentage
    local healthPercent = 1
    if unit.maxHealth and unit.maxHealth > 0 then
        healthPercent = math.max(0, math.min(1, unit.health / unit.maxHealth))
    end

    -- Background (dark)
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", barX - 1, barY - 1, barW + 2, barH + 2)

    -- Health bar background
    love.graphics.setColor(0.3, 0.3, 0.3, 1)
    love.graphics.rectangle("fill", barX, barY, barW, barH)

    -- Health bar fill (color depends on percentage)
    local r, g, b
    if healthPercent > 0.6 then
        r, g, b = 0.2, 0.8, 0.2  -- Green
    elseif healthPercent > 0.3 then
        r, g, b = 0.9, 0.8, 0.2  -- Yellow
    else
        r, g, b = 0.9, 0.2, 0.2  -- Red
    end

    love.graphics.setColor(r, g, b, 1)
    love.graphics.rectangle("fill", barX, barY, barW * healthPercent, barH)

    -- Border
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", barX, barY, barW, barH)

    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)

    -- Show unit name if selected
    if unit.selected and unit.class and unit.class.name then
        local font = love.graphics.getFont()
        local nameY = barY - font:getHeight() - 2
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(unit.class.name, barX, nameY)
        love.graphics.print(string.format("%d/%d", math.floor(unit.health), unit.maxHealth),
            barX, barY + barH + 2)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function HealthBarController:getVisibleCount()
    return #self.visibleUnits
end

return HealthBarController:new()
