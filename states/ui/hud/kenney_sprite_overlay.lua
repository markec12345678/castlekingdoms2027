-- states/ui/hud/kenney_sprite_overlay.lua
-- Stronghold 2027 - Kenney CC0 Sprite Overlay
--
-- When Kenney CC0 assets are enabled, this overlay renders:
-- - CC0 status indicator (top-left corner)
-- - Building/unit sprites in the game world
-- - Action bar icon replacements
--
-- This is a non-intrusive overlay that draws ON TOP of the existing
-- rendering. When disabled, the original Firefly assets show through.

local KenneySpriteRenderer = require("objects.Config.KenneySpriteRenderer")

local KenneySpriteOverlay = {}

-- Draw the overlay
function KenneySpriteOverlay.draw()
    -- Draw CC0 status badge (top-left, below season widget)
    local screenW = love.graphics.getWidth()
    local badgeX = 10
    local badgeY = 80

    -- Badge background
    love.graphics.setColor(0.1, 0.2, 0.1, 0.85)
    love.graphics.rectangle("fill", badgeX, badgeY, 180, 25, 4, 4, 4, 4)

    -- Badge border
    love.graphics.setColor(0.3, 0.8, 0.3, 0.8)
    love.graphics.setLineWidth(1.5)
    love.graphics.rectangle("line", badgeX, badgeY, 180, 25, 4, 4, 4, 4)

    -- Badge text
    love.graphics.setColor(0.3, 1, 0.3, 1)
    love.graphics.print("CC0 Asseti (Kenney)", badgeX + 10, badgeY + 5)

    -- Draw building sprites in the game world
    -- This replaces the original sprite batch rendering
    if _G.state and _G.state.gameObjectList then
        for _, obj in ipairs(_G.state.gameObjectList) do
            if obj and not obj.toBeDeleted and obj.class and obj.class.name then
                local name = obj.class.name

                -- Check if it's a building (has gx, gy but no health)
                if obj.gx and obj.gy and (not obj._combatAttached or obj.className == "Peasant") then
                    -- Convert world to screen
                    local screenX = obj.gx * 32 - obj.gy * 32
                    local screenY = (obj.gx + obj.gy) * 16

                    if _G.state.viewXview then
                        screenX = screenX - _G.state.viewXview
                    end
                    if _G.state.viewYview then
                        screenY = screenY - _G.state.viewYview
                    end

                    local scale = _G.state.scaleX or 1
                    screenX = screenX * scale
                    screenY = screenY * scale

                    -- Only render if on-screen
                    if screenX > -100 and screenX < screenW + 100 then
                        KenneySpriteRenderer.drawBuilding(name, screenX, screenY, scale, scale)
                    end
                end

                -- Check if it's a unit (has _combatAttached)
                if obj._combatAttached and obj.className and obj.className ~= "Peasant" then
                    if obj.gx and obj.gy then
                        local screenX = obj.gx * 32 - obj.gy * 32
                        local screenY = (obj.gx + obj.gy) * 16

                        if _G.state.viewXview then
                            screenX = screenX - _G.state.viewXview
                        end
                        if _G.state.viewYview then
                            screenY = screenY - _G.state.viewYview
                        end

                        local scale = _G.state.scaleX or 1
                        screenX = screenX * scale
                        screenY = screenY * scale

                        if screenX > -100 and screenX < screenW + 100 then
                            KenneySpriteRenderer.drawUnit(obj.className, screenX, screenY, obj.moveDir)
                        end
                    end
                end
            end
        end
    end

    -- Draw Kenney resource icons in the action bar area
    -- (overlay on top of existing UI)
    KenneySpriteOverlay.drawResourceBar()

    love.graphics.setColor(1, 1, 1, 1)
end

-- Draw resource bar with Kenney icons
function KenneySpriteOverlay.drawResourceBar()
    -- Resource bar is typically at the top of the screen
    -- Draw small Kenney icons next to resource counts
    -- This is a visual enhancement when CC0 is enabled

    local resources = {
        { name = "wood",  label = "Les",   x = 200 },
        { name = "stone", label = "Kamen", x = 300 },
        { name = "gold",  label = "Zlato", x = 400 },
        { name = "iron",  label = "Železo", x = 500 },
    }

    -- Only draw if state has resources
    if not _G.state then return end

    for _, res in ipairs(resources) do
        KenneySpriteRenderer.drawResourceIcon(res.name, res.x, 15, 20)
    end
end

return KenneySpriteOverlay
