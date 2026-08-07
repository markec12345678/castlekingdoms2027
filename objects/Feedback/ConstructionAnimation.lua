-- objects/Feedback/ConstructionAnimation.lua
-- Castle Kingdoms 2027 - Building Construction Animation
-- Visual progress indicator during building construction

local ConstructionAnim = {}

local initialized = false
local activeAnimations = {}  -- {buildingId = {progress, x, y, ...}}

function ConstructionAnim.init()
    if initialized then return end
    initialized = true
    print("[ConstructionAnim] Initialized")
end

-- Start construction animation for a building
function ConstructionAnim.start(buildingId, gx, gy, buildTime)
    if not initialized then return end

    activeAnimations[buildingId] = {
        gx = gx,
        gy = gy,
        progress = 0,
        buildTime = buildTime or 15,
        timer = 0,
        complete = false,
    }

    -- Spawn dust particles
    if _G.VisualPolish then
        local sx = _G.IsoToScreenX(gx, gy) - (_G.state.viewXview or 0)
        local sy = _G.IsoToScreenY(gx, gy) - (_G.state.viewYview or 0)
        _G.VisualPolish.spawnBuildEffect(sx, sy)
    end
end

-- Update construction animations
function ConstructionAnim.update(dt)
    if not initialized then return end

    for id, anim in pairs(activeAnimations) do
        if not anim.complete then
            anim.timer = anim.timer + dt
            anim.progress = math.min(1, anim.timer / anim.buildTime)

            -- Periodic dust particles
            if math.random() < dt * 2 then  -- ~2 particles per second
                if _G.VisualPolish and _G.state and _G.state.viewXview then
                    local sx = _G.IsoToScreenX(anim.gx, anim.gy) - (_G.state.viewXview or 0)
                    local sy = _G.IsoToScreenY(anim.gx, anim.gy) - (_G.state.viewYview or 0)
                    _G.VisualPolish.spawnEffect(sx + math.random(-15, 15), sy + math.random(-10, 10), "dust", 1)
                end
            end

            -- Check completion
            if anim.progress >= 1 then
                anim.complete = true
                ConstructionAnim._onComplete(anim)
            end
        end
    end

    -- Clean up completed animations after delay
    for id, anim in pairs(activeAnimations) do
        if anim.complete and anim.timer > anim.buildTime + 2 then
            activeAnimations[id] = nil
        end
    end
end

function ConstructionAnim._onComplete(anim)
    -- Spawn celebration particles
    if _G.VisualPolish and _G.state then
        local sx = _G.IsoToScreenX(anim.gx, anim.gy) - _G.state.viewXview
        local sy = _G.IsoToScreenY(anim.gx, anim.gy) - _G.state.viewYview
        _G.VisualPolish.spawnEffect(sx, sy, "spark", 10)
    end

    -- Voice notification
    if _G.VoiceOver then
        _G.VoiceOver.notify("building_complete", "Zgradba")
    end

    -- Emit event
    if _G.GameEventBus then
        _G.GameEventBus.emit("building_built", { gx = anim.gx, gy = anim.gy })
    end
end

-- Draw construction progress
function ConstructionAnim.draw()
    if not initialized then return end

    for id, anim in pairs(activeAnimations) do
        if not anim.complete and _G.state and _G.state.viewXview then
            local sx = _G.IsoToScreenX(anim.gx, anim.gy) - _G.state.viewXview
            local sy = _G.IsoToScreenY(anim.gx, anim.gy) - _G.state.viewYview

            -- Draw scaffolding effect (semi-transparent overlay)
            love.graphics.setColor(0.5, 0.4, 0.2, 0.3 * (1 - anim.progress))
            love.graphics.rectangle("fill", sx - 30, sy - 30, 60, 60)

            -- Draw progress bar
            local barW = 50
            local barH = 6
            local barX = sx - barW / 2
            local barY = sy - 40

            -- Background
            love.graphics.setColor(0, 0, 0, 0.7)
            love.graphics.rectangle("fill", barX - 1, barY - 1, barW + 2, barH + 2)

            -- Progress
            local progressColor = {1, 0.5, 0.2}  -- Orange
            if anim.progress > 0.7 then
                progressColor = {0.2, 1, 0.3}  -- Green when almost done
            end
            love.graphics.setColor(progressColor[1], progressColor[2], progressColor[3], 1)
            love.graphics.rectangle("fill", barX, barY, barW * anim.progress, barH)

            -- Percentage text
            love.graphics.setColor(1, 1, 1, 1)
            local pct = math.floor(anim.progress * 100)
            love.graphics.print(pct .. "%", barX, barY - 18)

            love.graphics.setColor(1, 1, 1, 1)
        end
    end
end

-- Remove a building's animation (when building is destroyed)
function ConstructionAnim.remove(buildingId)
    activeAnimations[buildingId] = nil
end

-- Get progress for a building
function ConstructionAnim.getProgress(buildingId)
    local anim = activeAnimations[buildingId]
    return anim and anim.progress or 1.0
end

-- Get active construction count
function ConstructionAnim.getActiveCount()
    local count = 0
    for _, anim in pairs(activeAnimations) do
        if not anim.complete then count = count + 1 end
    end
    return count
end

-- Get stats
function ConstructionAnim.getStats()
    return {
        active = ConstructionAnim.getActiveCount(),
        total = #activeAnimations,
    }
end

return ConstructionAnim
