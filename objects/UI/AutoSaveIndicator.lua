-- objects/UI/AutoSaveIndicator.lua
-- Castle Kingdoms 2027 - Auto-Save Indicator
-- Visual feedback when auto-saving

local AutoSaveIndicator = {}

local initialized = false
local isVisible = false
local displayTimer = 0
local maxDisplayTime = 3.0  -- Show for 3 seconds
local iconRotation = 0

function AutoSaveIndicator.init()
    if initialized then return end
    initialized = true
    print("[AutoSaveIndicator] Initialized")
end

-- Show the save indicator
function AutoSaveIndicator.show()
    if not initialized then AutoSaveIndicator.init() end
    isVisible = true
    displayTimer = maxDisplayTime

    if _G.VoiceOver then
        _G.VoiceOver.gameSaved()
    end
end

function AutoSaveIndicator.update(dt)
    if not initialized or not isVisible then return end

    displayTimer = displayTimer - dt
    iconRotation = iconRotation + dt * 3  -- Rotate icon

    if displayTimer <= 0 then
        isVisible = false
    end
end

function AutoSaveIndicator.draw()
    if not initialized or not isVisible then return end

    local w, h = love.graphics.getDimensions()
    local alpha = math.min(1, displayTimer / 0.5)  -- Fade in/out

    -- Position: top-center
    local x = w / 2
    local y = 50

    -- Background
    love.graphics.setColor(0, 0, 0, 0.7 * alpha)
    love.graphics.rectangle("fill", x - 80, y - 15, 160, 30)

    -- Border
    love.graphics.setColor(0.3, 0.6, 0.3, alpha)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x - 80, y - 15, 160, 30)

    -- Spinning icon (floppy disk / save)
    love.graphics.setColor(0.3, 0.9, 0.3, alpha)
    love.graphics.push()
    love.graphics.translate(x - 50, y)
    love.graphics.rotate(iconRotation)
    love.graphics.rectangle("fill", -8, -8, 16, 16)
    love.graphics.rectangle("fill", -5, -8, 10, 4)  -- Top notch
    love.graphics.pop()

    -- Text
    love.graphics.setColor(1, 1, 1, alpha)
    love.graphics.print("Shranjevanje...", x - 30, y - 8)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(1)
end

function AutoSaveIndicator.isVisible()
    return isVisible
end

return AutoSaveIndicator
