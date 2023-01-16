local bresenham = require('libraries.bresenham')
local WoodenWall = require("objects.Structures.WoodenWall")
local WalkableWoodenWall = require("objects.Structures.WalkableWoodenWall")
local tileQuads = require("objects.object_quads")

local woodIcon = love.graphics.newImage("assets/ui/goods/woodIcon.png")

local WallController = _G.class("WallController")
function WallController:initialize()
    self.clicked = false
    self.walkable = false
    self.lastFinalGX = nil
    self.lastFinalGY = nil
    self.buildingCount = 0
    self.offsetY = 112
    self.quad = "tile_buildings_wood_wall (1)"
end

function WallController:setWalkableWall()
    self.walkable = true
    self.quad = "wood_wall_walkable"
    self.offsetY = 112 - 44
end

function WallController:setWoodenWall()
    self.walkable = false
    self.quad = "tile_buildings_wood_wall (1)"
    self.offsetY = 112
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
            local sameWallAtPosition = _G.objectFromClassAtGlobal(gx, gy, WoodenWall) or _G.objectFromClassAtGlobal(gx, gy, WalkableWoodenWall)
            if sameWallAtPosition then return true end
            if _G.importantObjectAtGlobal(gx, gy) then
                return false
            end
            if _G.state.map:isWaterAt(gx, gy) then
                return false
            end
            if self.walkable then
                if _G.BuildController:isBuildingAffordable("WalkableWoodenWall") then
                    _G.BuildController:purchaseBuilding("WalkableWoodenWall")
                    local builtBuilding = WalkableWoodenWall:new(gx, gy)
                    _G.BuildingManager:add(builtBuilding)
                    for k, v in ipairs(_G.stockpile.nodeList) do
                        if v.gx == gx and v.gy == gy then
                            table.remove(_G.stockpile.nodeList, k)
                            break
                        end
                    end
                    for k, v in ipairs(_G.foodpile.nodeList) do
                        if v.gx == gx and v.gy == gy then
                            table.remove(_G.foodpile.nodeList, k)
                            break
                        end
                    end
                    return true
                else
                    return false
                end
            else
                if _G.BuildController:isBuildingAffordable("WoodenWall") then
                    _G.BuildController:purchaseBuilding("WoodenWall")
                    local builtBuilding = WoodenWall:new(gx, gy)
                    _G.BuildingManager:add(builtBuilding)
                    for k, v in ipairs(_G.stockpile.nodeList) do
                        if v.gx == gx and v.gy == gy then
                            table.remove(_G.stockpile.nodeList, k)
                            break
                        end
                    end
                    for k, v in ipairs(_G.foodpile.nodeList) do
                        if v.gx == gx and v.gy == gy then
                            table.remove(_G.foodpile.nodeList, k)
                            break
                        end
                    end
                    return true
                else
                    return false
                end
            end
        end)
    end
end

function WallController:drawMouse()
    if not self.clicked then return end
    local totalCost = _G.BuildController:getWoodCost("WoodenWall", self.buildingCount)
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
        local sameWallAtPosition = _G.objectFromClassAtGlobal(gx, gy, WoodenWall) or _G.objectFromClassAtGlobal(gx, gy, WalkableWoodenWall)
        if sameWallAtPosition then
            self.buildingCount = self.buildingCount - 1
            return true
        end
        if self.walkable then
            if not _G.BuildController:isBuildingAffordable("WalkableWoodenWall", self.buildingCount) then
                canAfford = false
            end
        else
            if not _G.BuildController:isBuildingAffordable("WoodenWall", self.buildingCount) then
                canAfford = false
            end
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
                fy + (-elevationOffsetY - self.offsetY) * _G.state.scaleX,
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
