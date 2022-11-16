local _, _, _ = ...
local bresenham = require('libraries.bresenham')
local WoodenWall = require("objects.Structures.WoodenWall")
local tileQuads = require("objects.object_quads")

local WallController = _G.class("WallController")
function WallController:initialize()
    self.clicked = false
    self.lastFinalGX = nil
    self.lastFinalGY = nil
    self.quad = "tile_buildings_wood_wall (1)"
end

function WallController:build()
    if not self.clicked then
        self.clicked = true
        local mx, my = love.mouse.getPosition()
        self.initialGX, self.initialGY = _G.getTerrainTileOnMouse(mx, my)
    else
        self.clicked = false
        local finalMX, finalMY = love.mouse.getPosition()
        local finalGX, finalGY = _G.getTerrainTileOnMouse(finalMX, finalMY)
        bresenham.los(self.initialGX, self.initialGY, finalGX, finalGY, function(gx, gy)
            local sameWallAtPosition = _G.objectFromClassAtGlobal(gx, gy, WoodenWall)
            if sameWallAtPosition then return true end
            if _G.importantObjectAtGlobal(gx, gy) then
                return false
            end
            if _G.state.map:isWaterAt(gx, gy) then
                return false
            end
            if _G.BuildController:isBuildingAffordable("wooden_wall") then
                _G.BuildController:purchaseBuilding("wooden_wall")
                WoodenWall:new(gx, gy)
                return true
            else
                return false
            end
        end)
    end
end

function WallController:draw()
    if not self.clicked then
        return
    end
    local mx, my = love.mouse.getPosition()
    local igx, igy = _G.getTerrainTileOnMouse(mx, my)
    local buildableCount = 1
    bresenham.los(self.initialGX, self.initialGY, igx, igy, function(gx, gy)
        local ccx, ccy, xxx, yyy = _G.getLocalCoordinatesFromGlobal(gx, gy)
        local elevationOffsetY = (_G.state.map.heightmap[ccx][ccy][xxx][yyy] or 0) * 2
        local fx = IsoToScreenX(gx, gy) - _G.state.viewXview - ((IsoToScreenX(gx, gy)) - _G.state.viewXview) * (1 - _G.state.scaleX)
        local fy = IsoToScreenY(gx, gy) - _G.state.viewYview - ((IsoToScreenY(gx, gy)) - _G.state.viewYview) * (1 - _G.state.scaleX)
        local canAfford = true
        if not _G.BuildController:isBuildingAffordable("wooden_wall", buildableCount) then
            canAfford = false
        end
        buildableCount = buildableCount + 1
        local sameWallAtPosition = _G.objectFromClassAtGlobal(gx, gy, WoodenWall)
        if _G.importantObjectAtGlobal(gx, gy) and not sameWallAtPosition then
            return false
        end
        if _G.state.map:isWaterAt(gx, gy) then
            return false
        end
        if sameWallAtPosition then return true end
        if canAfford then
            love.graphics.draw(
                _G.objectAtlas,
                tileQuads[self.quad],
                fx,
                fy + (-elevationOffsetY - 112) * _G.state.scaleX,
                0, _G.state.scaleX
            )
        else
            love.graphics.draw(
                _G.objectAtlas,
                tileQuads["tile_buildings_stone_wall_red"],
                fx,
                fy + (-elevationOffsetY - 112 + 31) * _G.state.scaleX,
                0, _G.state.scaleX
            )
        end
        return true
    end)
end

return WallController:new()
