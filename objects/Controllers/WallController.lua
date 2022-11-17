local bresenham = require('libraries.bresenham')
local WoodenWall = require("objects.Structures.WoodenWall")
local tileQuads = require("objects.object_quads")

local woodIcon = love.graphics.newImage("assets/ui/goods/woodIcon.png")

local WallController = _G.class("WallController")
function WallController:initialize()
    self.clicked = false
    self.lastFinalGX = nil
    self.lastFinalGY = nil
    self.buildingCount = 0
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

function WallController:drawMouse()
    if not self.clicked then return end
    local totalCost = _G.BuildController:getWoodCost("wooden_wall", self.buildingCount)
    local mx, my = love.mouse.getPosition()
    love.graphics.draw(woodIcon, mx + 30, my + 20, nil, 0.5)
    if totalCost > _G.state.resources["wood"] then
        love.graphics.setColor(1, 0.6, 0.6, 1)
        love.graphics.print(totalCost .. " / " .. _G.state.resources["wood"], mx + 30 + 30, my + 20)
    else
        love.graphics.print(totalCost, mx + 30 + 30, my + 20)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function WallController:draw()
    if not self.clicked then
        return
    end
    local mx, my = love.mouse.getPosition()
    local igx, igy = _G.getTerrainTileOnMouse(mx, my)
    self.buildingCount = 0
    self.canAfford = false
    bresenham.los(self.initialGX, self.initialGY, igx, igy, function(gx, gy)
        self.buildingCount = self.buildingCount + 1
        local cx, cy, x, y = _G.getLocalCoordinatesFromGlobal(gx, gy)
        local elevationOffsetY = (_G.state.map.heightmap[cx][cy][x][y] or 0) * 2
        local fx = IsoToScreenX(gx, gy) - _G.state.viewXview - ((IsoToScreenX(gx, gy)) - _G.state.viewXview) * (1 - _G.state.scaleX)
        local fy = IsoToScreenY(gx, gy) - _G.state.viewYview - ((IsoToScreenY(gx, gy)) - _G.state.viewYview) * (1 - _G.state.scaleX)
        local canAfford = true
        local sameWallAtPosition = _G.objectFromClassAtGlobal(gx, gy, WoodenWall)
        if sameWallAtPosition then
            self.buildingCount = self.buildingCount - 1
            return true
        end
        if not _G.BuildController:isBuildingAffordable("wooden_wall", self.buildingCount) then
            canAfford = false
        end
        if _G.importantObjectAtGlobal(gx, gy) and not sameWallAtPosition then
            return false
        end
        if _G.state.map:isWaterAt(gx, gy) then
            return false
        end
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
        self.canAfford = canAfford
        return true
    end)
end

return WallController:new()
