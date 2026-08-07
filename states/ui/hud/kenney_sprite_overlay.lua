-- states/ui/hud/kenney_sprite_overlay.lua
-- Castle Kingdoms 2027 - Kenney CC0 Sprite Overlay
--
-- When Kenney CC0 assets are enabled, this overlay renders:
-- - CC0 status indicator (top-left corner)
-- - Building/unit sprites in the game world
-- - Action bar icon replacements
--
-- This is a non-intrusive overlay that draws ON TOP of the existing
-- rendering. When disabled, the original Original RTS assets show through.

local KenneySpriteRenderer = require("objects.Config.KenneySpriteRenderer")

local KenneySpriteOverlay = {}

-- Draw the overlay
function KenneySpriteOverlay.draw()
    -- Draw CC0 status badge (top-left, below season widget)
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
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

    -- Castle Kingdoms 2027: Only render visible objects (frustum culling)
    -- Use activeEntities instead of gameObjectList for better performance
    if _G.state and _G.state.activeEntities then
        local viewX = _G.state.viewXview or 0
        local viewY = _G.state.viewYview or 0
        local scale = _G.state.scaleX or 1

        -- Calculate visible bounds (with margin)
        local visLeft = viewX - 100
        local visRight = viewX + screenW / scale + 100
        local visTop = viewY - 100
        local visBottom = viewY + screenH / scale + 100

        for _, obj in ipairs(_G.state.activeEntities) do
            if obj and not obj.toBeDeleted and obj.gx and obj.gy then
                -- Convert world to screen
                local screenX = obj.gx * 32 - obj.gy * 32
                local screenY = (obj.gx + obj.gy) * 16

                -- Frustum culling: skip off-screen objects
                if screenX >= visLeft and screenX <= visRight and
                   screenY >= visTop and screenY <= visBottom then

                    screenX = (screenX - viewX) * scale
                    screenY = (screenY - viewY) * scale

                    -- Draw unit or building
                    if obj._combatAttached and obj.className and obj.className ~= "Peasant" then
                        KenneySpriteRenderer.drawUnit(obj.className, screenX, screenY, obj.moveDir)
                    elseif obj.class and obj.class.name then
                        KenneySpriteRenderer.drawBuilding(obj.class.name, screenX, screenY, scale, scale)
                    end
                end
            end
        end
    end

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
