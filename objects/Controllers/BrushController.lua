local brushType = {
    ["Remove"] = 1,
    ["PaintTerrainObjects"] = 2,
    ["Count"] = 3
}
local brushObjects = {
    ["Stone"] = require("objects.Environment.Stone"),
    ["Iron"] = require("objects.Environment.Iron"),
    ["OakTree"] = require("objects.Environment.OakTree"),
    ["PineTree"] = require("objects.Environment.PineTree"),
    ["Shrub"] = require("objects.Environment.Shrub"),
    ["BirchTree"] = require("objects.Environment.BirchTree"),
    ["ChestnutTree"] = require("objects.Environment.ChestnutTree")
}

local brushShapes = {
    ["Square"] = 1,
    ["Circle"] = 2
}

local brushMode = {
    ["Solid"] = 1,
    ["Scattered"] = 2
}

local brushDensity = {
    ["VeryDense"] = 6,
    ["Dense"] = 8,
    ["Medium"] = 10,
    ["Low"] = 12
}

local image = love.graphics.newImage("assets/tiles/info_tiles_strip.png")
local console = require("libraries.console")

local BrushController = _G.class("BrushController")
BrushController.FONT_SIZE = 12
BrushController.FONT = love.graphics.newFont(BrushController.FONT_SIZE)
BrushController.BACKGROUND_COLOR = { 0, 0, 0, 0.4 }
BrushController.TEXT_COLOR = { 1, 1, 1, 1 }
function BrushController:initialize()
    self.maxSize = 10
    self.active = false
    self.pressed = false
    self.size = 5
    self.type = brushType.PaintTerrainObjects
    self.brushObjectType = nil
    self.brushObject = nil
    self.shape = brushShapes.Square
    self.mode = brushMode.Solid
    self.density = brushDensity.Medium
    self.quad = love.graphics.newQuad(88, 0, 40, 16, image:getWidth(), image:getHeight())
    self.batch = love.graphics.newSpriteBatch(image)
end

function BrushController:setType(type)
    self.type = brushType[type]
end

function BrushController:cycleType()
    self.type = self.type + 1
    if (self.type >= brushType.Count) then
        self.type = brushType.Remove
    end
    if self.type == brushType.Remove then
        print("Delete Mode activated")
    elseif self.type == brushType.PaintTerrainObjects then
        print("Paint mode activated")
    end
end

function BrushController:setObject(object)
    self.brushObjectType = object
    self.brushObject = brushObjects[object]
    if (self.brushObject == brushObjects.OakTree)
        or (self.brushObject == brushObjects.PineTree)
        or (self.brushObject == brushObjects.Shrub)
        or (self.brushObject == brushObjects.BirchTree)
        or (self.brushObject == brushObjects.ChestnutTree) then
        self.mode = brushMode.Scattered
    else
        self.mode = brushMode.Solid
    end
end

function BrushController:toggleBuilding()
    if not self.active then
        self.active = true
        self:setObject("Stone")
        print("Brush Mode: Stone")
    else
        self.active = false
        print("Brush Mode: Deactivated")
    end
end

function BrushController:activated()
    return self.active
end

function BrushController:keyReleased(key)
    if not love.keyboard.isDown("lalt") then
        return
    end

    if key == "n" then
        self:cycleShapes()
    elseif (key == "=" or key == "+" or key == "kp+") then
        self:sizeInc()
    elseif (key == "-" or key == "kp-") then
        self:sizeDec()
    elseif (key == "m") then
        self:cycleDensity()
    elseif (key == "v") then
        self:cycleType()
    elseif (key == "s") then
        self:setObject("Stone")
        print("Brush Mode: Stone")
    elseif (key == "i") then
        self:setObject("Iron")
        print("Brush Mode: Iron")
    elseif (key == "o") then
        self:setObject("OakTree")
        print("Brush Mode: OakTree")
    elseif (key == "p") then
        self:setObject("PineTree")
        print("Brush Mode: PineTree")
    elseif (key == "h") then
        self:setObject("Shrub")
        print("Brush Mode: Shrub")
    elseif (key == "j") then
        self:setObject("BirchTree")
        print("Brush Mode: BirchTree")
    elseif (key == "k") then
        self:setObject("ChestnutTree")
        print("Brush Mode: ChestnutTree")
    end
end

function BrushController:setShape(shape)
    self.shape = brushShapes[shape]
end

function BrushController:cycleShapes()
    if self.shape == 1 then
        self.shape = 2
        print("Brush Shape: Circle")
    else
        self.shape = 1
        print("Brush Shape: Square")
    end
end

function BrushController:setSize(size)
    if size >= 0 and size <= self.maxSize then
        self.size = size
    end
end

function BrushController:sizeDec()
    local newSize = self.size - 1
    self:setSize(newSize)
    print("Brush Size set to", self.size)
end

function BrushController:sizeInc()
    local newSize = self.size + 1
    self:setSize(newSize)
    print("Brush Size set to", self.size)
end

function BrushController:setDensity(density)
    self.density = brushDensity[density]
end

function BrushController:cycleDensity()
    if self.density == brushDensity.Low then
        self.density = brushDensity.Medium
        print("Brush Density: Medium")
    elseif self.density == brushDensity.Medium then
        self.density = brushDensity.Dense
        print("Brush Density: Dense")
    elseif self.density == brushDensity.Dense then
        self.density = brushDensity.VeryDense
        print("Brush Density: Very Dense")
    elseif self.density == brushDensity.VeryDense then
        self.density = brushDensity.Low
        print("Brush Density: Low")
    end
end

function BrushController:getMouseTilePosition()
    local MX, MY = love.mouse.getPosition()
    local LX, LY = _G.getTerrainTileOnMouse(MX, MY)
    LX, LY = LX - math.floor(self.size / 2), LY - math.floor(self.size / 2)
    return LX, LY
end

function BrushController:isOutOfBounds(X, Y)
    return not (X >= 0 and X < 512 and Y >= 0 and Y < 512)
end

function BrushController:canPaint(X, Y)
    if not _G.objectFromClassAtGlobal(X, Y, self.brushObjectType) and not _G.importantObjectAtGlobal(X, Y) and
        not self:isOutOfBounds(X, Y) then
        return true
    else
        return false
    end
end

function BrushController:paintSolid()
    local LX, LY = self:getMouseTilePosition()

    if self:isOutOfBounds(LX, LY) then
        return
    end

    if self.shape == brushShapes.Square then
        for XX = 0, self.size do
            for YY = 0, self.size do
                if self.type == brushType.Remove then
                    _G.removeObjectFromClassAtGlobal(LX + XX, LY + YY, "Stone")
                    _G.removeObjectFromClassAtGlobal(LX + XX, LY + YY, "Iron")
                    _G.removeObjectFromClassAtGlobal(LX + XX, LY + YY, "OakTree")
                    _G.removeObjectFromClassAtGlobal(LX + XX, LY + YY, "PineTree")
                    _G.removeObjectFromClassAtGlobal(LX + XX, LY + YY, "BirchTree")
                    _G.removeObjectFromClassAtGlobal(LX + XX, LY + YY, "ChestnutTree")
                    _G.removeObjectFromClassAtGlobal(LX + XX, LY + YY, "Shrub")
                elseif self.type == brushType.PaintTerrainObjects then
                    if self:canPaint(XX + LX, LY + YY) then
                        self.brushObject:new(LX + XX, LY + YY)
                    end
                end
            end
        end
    elseif self.shape == brushShapes.Circle then
        for XX = LX - self.size, LX + self.size do
            for YY = LY - self.size, LY + self.size do
                if (XX - LX) * (XX - LX) + (YY - LY) * (YY - LY) <= self.size * self.size then
                    if self.removeMode then
                        _G.removeObjectFromClassAtGlobal(XX, YY, "Stone")
                        _G.removeObjectFromClassAtGlobal(XX, YY, "Iron")
                        _G.removeObjectFromClassAtGlobal(XX, YY, "OakTree")
                        _G.removeObjectFromClassAtGlobal(XX, YY, "PineTree")
                        _G.removeObjectFromClassAtGlobal(XX, YY, "BirchTree")
                        _G.removeObjectFromClassAtGlobal(XX, YY, "ChestnutTree")
                        _G.removeObjectFromClassAtGlobal(XX, YY, "Shrub")
                    elseif self.type == brushType.PaintTerrainObjects then
                        if self:canPaint(LX + XX, LY + YY) then
                            self.brushObject:new(LX + XX, LY + YY)
                        end
                    end
                end
            end
        end
    end
end

function BrushController:checkForObjectInRadius(X, Y, R, object)
    X, Y = X - math.floor(R / 2), Y - math.floor(R / 2)
    for XX = 0, R do
        for YY = 0, R do
            if _G.objectFromClassAtGlobal(XX + X, YY + Y, object) then
                return true
            end
        end
    end
    return false
end

function BrushController:paintScattered()
    local LX, LY = self:getMouseTilePosition()

    if self:isOutOfBounds(LX, LY) then
        return
    end

    if self.shape == brushShapes.Square then
        for XX = 0, self.size do
            for YY = 0, self.size do
                if (love.math.random(0, 9999) % 3 == 0) then
                    if self:canPaint(LX + XX, LY + YY) and
                        not self:checkForObjectInRadius(LX + XX, LY + YY, self.density, self.brushObjectType) then
                        self.brushObject:new(LX + XX, LY + YY)
                    end
                end
            end
        end
    elseif self.shape == brushShapes.Circle then
        for XX = LX - self.size, LX + self.size do
            for YY = LY - self.size, LY + self.size do
                if (love.math.random(0, 9999) % 3 == 0) then
                    if (XX - LX) * (XX - LX) + (YY - LY) * (YY - LY) <= self.size * self.size then
                        if self:canPaint(XX, YY) and
                            not self:checkForObjectInRadius(XX, YY, self.density, self.brushObjectType) then
                            self.brushObject:new(XX, YY)
                        end
                    end
                end
            end
        end
    end
end

function BrushController:update()
    if self.active then
        if self.pressed then
            if self.mode == brushMode.Solid or self.removeMode then
                self:paintSolid()
            else
                self:paintScattered()
            end
        end
        local LX, LY = self:getMouseTilePosition()
        self.BatchX = _G.IsoToScreenX(LX, LY) - _G.state.viewXview - ((_G.IsoToScreenX(LX, LY)) - _G.state.viewXview) * (1 - _G.state.scaleX)
        self.BatchY = _G.IsoToScreenY(LX, LY) - _G.state.viewYview - ((_G.IsoToScreenY(LX, LY)) - _G.state.viewYview) * (1 - _G.state.scaleX)
        self.batch:clear()
        if self.shape == brushShapes.Square then
            for XX = 0, self.size do
                for YY = 0, self.size do
                    local GX, GY = LX + XX, LY + YY
                    if self:canPaint(GX, GY) then
                        self.batch:setColor(1, 1, 1, 0.5)
                    else
                        self.batch:setColor(0.5, 0, 0, 0.2)
                    end
                    local ccx, ccy, xxx, yyy = _G.getLocalCoordinatesFromGlobal(GX, GY)
                    local elevationOffsetY = (_G.state.map.heightmap[ccx][ccy][xxx][yyy] or 0) * 2
                    self.batch:add(self.quad, (XX - YY) * _G.tileWidth * 0.5, (XX + YY) * _G.tileHeight * 0.5 - elevationOffsetY, 0, 1, 1)
                end
            end
        elseif self.shape == brushShapes.Circle then
            for XX = LX - self.size, LX + self.size do
                for YY = LY - self.size, LY + self.size do
                    if (XX - LX) * (XX - LX) + (YY - LY) * (YY - LY) <= self.size * self.size then
                        local GX, GY = -(LX - XX), -(LY - YY)
                        if self:canPaint(XX, YY) then
                            self.batch:setColor(1, 1, 1, 0.5)
                        else
                            self.batch:setColor(0.5, 0, 0, 0.2)
                        end
                        local ccx, ccy, xxx, yyy = _G.getLocalCoordinatesFromGlobal(XX, YY)
                        local elevationOffsetY = (_G.state.map.heightmap[ccx][ccy][xxx][yyy] or 0) * 2
                        self.batch:add(self.quad, (GX - GY) * _G.tileWidth * 0.5, (GX + GY) * _G.tileHeight * 0.5 - elevationOffsetY, 0, 1, 1)
                    end
                end
            end
        end
    end
end

function BrushController:draw()
    if not self.active then
        return
    end

    local LX, LY = self:getMouseTilePosition()
    if not self:isOutOfBounds(LX, LY) then
        love.graphics.draw(self.batch, self.BatchX, self.BatchY, nil, _G.state.scaleX)
    end

    local x = -love.graphics.getWidth() / 2
    local y = -love.graphics.getHeight() / 2
    love.graphics.setColor(unpack(BrushController.BACKGROUND_COLOR))
    love.graphics.rectangle('fill', x, y, 200, 400)

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setFont(BrushController.FONT)

    love.graphics.printf("Brush Mode: " .. self.brushObjectType, x + 5, y + 5, 200, "left")
    love.graphics.printf("Brush Size: " .. tostring(self.size + 1), x + 5, y + 25, 200, "left")
    if (self.type == brushType.Remove) then
        love.graphics.printf("Paint Mode: Delete", x + 5, y + 45, 200, "left")
    else
        love.graphics.printf("Paint Mode: Paint", x + 5, y + 45, 200, "left")
    end
    love.graphics.printf("Alt + v: Remove/Paint", x + 5, y + 85, 200, "left")
    love.graphics.printf("Alt + s: Stone", x + 5, y + 105, 200, "left")
    love.graphics.printf("Alt + o: OakTree", x + 5, y + 125, 200, "left")
    love.graphics.printf("Alt + p: PineTree", x + 5, y + 145, 200, "left")
    love.graphics.printf("Alt + j: BirchTree", x + 5, y + 165, 200, "left")
    love.graphics.printf("Alt + k: Chestnut", x + 5, y + 185, 200, "left")
    love.graphics.printf("Alt + h: Shrub", x + 5, y + 205, 200, "left")
    love.graphics.printf("Alt + i: Iron", x + 5, y + 225, 200, "left")
    love.graphics.printf("Alt + -/+: Dec/Inc Size", x + 5, y + 250, 200, "left")
end

function BrushController:mousepressed(button)
    if _G.BrushController.active == true and button == 1 then
        _G.BrushController.pressed = true
    end
end

function BrushController:mousereleased(button)
    if _G.BrushController.active == true and button == 1 then
        _G.BrushController.pressed = false
    end
end

function BrushController:debug_info()
    local result = ""
    if self.type == brushType.Remove then
        result = "Delete Mode"
    elseif self.type == brushType.PaintTerrainObjects then
        result = "Paint Mode"
    end

    return result
end

console.addCommand("brush", function(params)
    if (params == "delete") then
        _G.BrushController.type = brushType.Remove
        print("Paint Mode: Delete")
    end

    return true
end, "Works with map")


return BrushController:new()
