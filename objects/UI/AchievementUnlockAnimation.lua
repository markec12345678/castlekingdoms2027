-- objects/UI/AchievementUnlockAnimation.lua
-- Castle Kingdoms 2027 v2.9.6 - Achievement Unlock Animation
--
-- Animated visual notification when achievements are unlocked.
-- Features sliding panel, rarity-based colors, sound, and particle effects.
--
-- Animation stages:
-- 1. Slide in from right (0.3s)
-- 2. Hold display (3s)
-- 3. Slide out to right (0.3s)
-- 4. Queue next achievement if multiple

local AchievementAnim = {}

local initialized = false
local activeAnimation = nil  -- current animation
local animationQueue = {}    -- pending achievements
local stage = "idle"         -- idle, slideIn, hold, slideOut
local stageTimer = 0
local slideDuration = 0.3
local holdDuration = 3.0

-- Rarity styling
local RARITY_STYLES = {
    common = { color = {0.7, 0.7, 0.7}, glowColor = {0.5, 0.5, 0.5}, label = "Common" },
    rare = { color = {0.3, 0.6, 0.9}, glowColor = {0.2, 0.4, 0.7}, label = "Rare" },
    epic = { color = {0.8, 0.3, 0.8}, glowColor = {0.6, 0.2, 0.6}, label = "Epic" },
    legendary = { color = {1.0, 0.8, 0.2}, glowColor = {0.8, 0.6, 0.1}, label = "Legendary" },
}

AchievementAnim.RARITY_STYLES = RARITY_STYLES

-- Particle system
local particles = nil

function AchievementAnim.init()
    if initialized then return end
    initialized = true
    -- Create particle system for sparkles
    -- (will be initialized on first use with love.graphics.newImageData)
    print("[AchievementAnim] Initialized")
end

-- Queue an achievement unlock animation
function AchievementAnim.show(achievementData)
    if not initialized then AchievementAnim.init() end
    if not achievementData or not achievementData.name then return false end

    table.insert(animationQueue, {
        id = achievementData.id or "unknown",
        name = achievementData.name,
        nameSlv = achievementData.nameSlv or achievementData.name,
        description = achievementData.description or "",
        descSlv = achievementData.descSlv or achievementData.description or "",
        rarity = achievementData.rarity or "common",
        category = achievementData.category or "misc",
        icon = achievementData.icon or "★",
    })

    -- If no active animation, start immediately
    if not activeAnimation and #animationQueue > 0 then
        AchievementAnim._next()
    end

    return true
end

-- Start next animation from queue
function AchievementAnim._next()
    if #animationQueue == 0 then
        activeAnimation = nil
        stage = "idle"
        return
    end

    activeAnimation = table.remove(animationQueue, 1)
    stage = "slideIn"
    stageTimer = 0

    -- Play sound
    if _G.SFXLibrary then
        pcall(function() _G.SFXLibrary.play("ui", "success_chime") end)
    end

    -- Fire event
    if _G.GameEventBus then
        pcall(function() _G.GameEventBus.emit("achievement_animation_started", activeAnimation) end)
    end

    print("[AchievementAnim] Showing: " .. activeAnimation.name .. " (" .. activeAnimation.rarity .. ")")
end

-- Update animation
function AchievementAnim.update(dt)
    if not initialized or not activeAnimation then return end

    stageTimer = stageTimer + dt

    if stage == "slideIn" then
        if stageTimer >= slideDuration then
            stage = "hold"
            stageTimer = 0
        end
    elseif stage == "hold" then
        if stageTimer >= holdDuration then
            stage = "slideOut"
            stageTimer = 0
        end
    elseif stage == "slideOut" then
        if stageTimer >= slideDuration then
            AchievementAnim._next()
        end
    end
end

-- Draw animation
function AchievementAnim.draw()
    if not initialized or not activeAnimation then return end

    local style = RARITY_STYLES[activeAnimation.rarity] or RARITY_STYLES.common
    local screenWidth, screenHeight = love.graphics.getDimensions()

    -- Panel dimensions
    local panelWidth = 340
    local panelHeight = 80
    local panelY = 60  -- from top

    -- Calculate X based on animation stage
    local panelX
    if stage == "slideIn" then
        -- Slide from right (off-screen) to position
        local progress = stageTimer / slideDuration
        progress = AchievementAnim._easeOut(progress)
        panelX = screenWidth - panelWidth * progress
    elseif stage == "hold" then
        panelX = screenWidth - panelWidth
    elseif stage == "slideOut" then
        -- Slide back to right (off-screen)
        local progress = stageTimer / slideDuration
        progress = AchievementAnim._easeIn(progress)
        panelX = screenWidth - panelWidth + panelWidth * progress
    else
        return
    end

    -- Glow effect (pulsing)
    local glowPulse = math.sin(love.timer.getTime() * 3) * 0.2 + 0.8

    -- Draw glow
    love.graphics.setColor(style.glowColor[1], style.glowColor[2], style.glowColor[3], 0.3 * glowPulse)
    love.graphics.rectangle("fill", panelX - 4, panelY - 4, panelWidth + 8, panelHeight + 8, 6, 6)

    -- Draw background
    love.graphics.setColor(0.08, 0.08, 0.12, 0.95)
    love.graphics.rectangle("fill", panelX, panelY, panelWidth, panelHeight, 4, 4)

    -- Draw border (rarity colored)
    love.graphics.setColor(style.color[1], style.color[2], style.color[3], 1.0)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", panelX, panelY, panelWidth, panelHeight, 4, 4)

    -- Draw left accent bar
    love.graphics.setColor(style.color[1], style.color[2], style.color[3], 1.0)
    love.graphics.rectangle("fill", panelX, panelY, 6, panelHeight)

    -- Draw icon area (left side)
    local iconX = panelX + 20
    local iconY = panelY + panelHeight / 2 - 15
    love.graphics.setColor(style.color[1], style.color[2], style.color[3], 1.0)
    love.graphics.circle("fill", iconX + 15, iconY + 15, 20)
    love.graphics.setColor(0.08, 0.08, 0.12, 1.0)
    love.graphics.print(activeAnimation.icon, iconX + 8, iconY + 5)

    -- Draw "ACHIEVEMENT UNLOCKED" label
    love.graphics.setColor(style.color[1], style.color[2], style.color[3], 0.8)
    love.graphics.print("DOSEŽEK ODKLENJEN", panelX + 55, panelY + 8)

    -- Draw rarity label
    love.graphics.setColor(style.color[1], style.color[2], style.color[3], 1.0)
    love.graphics.print("[" .. style.label .. "]", panelX + 55 + 150, panelY + 8)

    -- Draw achievement name
    love.graphics.setColor(1, 1, 1, 1.0)
    local displayName = activeAnimation.nameSlv or activeAnimation.name
    love.graphics.print(displayName, panelX + 55, panelY + 28)

    -- Draw description (truncated)
    love.graphics.setColor(0.7, 0.7, 0.7, 1.0)
    local desc = activeAnimation.descSlv or activeAnimation.description or ""
    if #desc > 45 then desc = desc:sub(1, 42) .. "..." end
    love.graphics.print(desc, panelX + 55, panelY + 48)

    -- Draw sparkle particles (simple)
    if stage == "hold" then
        local sparkleCount = 5
        for i = 1, sparkleCount do
            local sparkleX = panelX + panelWidth - 20 + math.sin(love.timer.getTime() * 2 + i) * 15
            local sparkleY = panelY + 10 + math.cos(love.timer.getTime() * 3 + i) * 25
            local sparkleAlpha = math.sin(love.timer.getTime() * 4 + i * 1.5) * 0.5 + 0.5
            love.graphics.setColor(style.color[1], style.color[2], style.color[3], sparkleAlpha)
            love.graphics.circle("fill", sparkleX, sparkleY, 2)
        end
    end

    -- Draw queue indicator if more pending
    if #animationQueue > 0 then
        love.graphics.setColor(0.7, 0.7, 0.7, 0.8)
        love.graphics.print("+" .. #animationQueue, panelX + panelWidth - 20, panelY + panelHeight - 15)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

-- Easing functions
function AchievementAnim._easeOut(t)
    return 1 - (1 - t) * (1 - t)
end

function AchievementAnim._easeIn(t)
    return t * t
end

-- Get stats
function AchievementAnim.getStats()
    return {
        active = activeAnimation ~= nil,
        stage = stage,
        queueSize = #animationQueue,
        currentName = activeAnimation and activeAnimation.name or nil,
        currentRarity = activeAnimation and activeAnimation.rarity or nil,
    }
end

-- Clear queue
function AchievementAnim.clearQueue()
    animationQueue = {}
    activeAnimation = nil
    stage = "idle"
end

-- Skip current animation
function AchievementAnim.skip()
    if activeAnimation then
        AchievementAnim._next()
    end
end

return AchievementAnim
