local IsoToScreenX, IsoToScreenY = _G.IsoToScreenX, _G.IsoToScreenY

local HighlightView = _G.class("HighlightView")
function HighlightView:initialize()
    self.points = {}
end

function HighlightView:handleViewScroll()
    if self.points and next(self.points) then
        local newpoints = {}
        for i, v in ipairs(self.points) do
            if (i % 2 == 0) then
                newpoints[i] = v - _G.state.viewYview * _G.state.scaleX
            else
                newpoints[i] = v - _G.state.viewXview * _G.state.scaleX
            end
        end
        return newpoints
    end
end

function HighlightView:update()
    local MX, MY = love.mouse.getPosition()
    local OX, OY = _G.getTerrainTileOnMouse(MX, MY)
    local Structure = require("objects.Structure")
    local structure = _G.objectFromSubclassAtGlobal(OX, OY, Structure)
    self.leftCornerX = nil
    if not structure or string.find(structure.class.name, "Rock") then
        self.lastStructure = nil
        self.points = nil
        return
    end
    structure = structure.parent or structure
    if not structure.onClick and not _G.DestructionController.active then return end
    if not structure.class.WIDTH then
        self.lastStructure = nil
        self.points = nil
        return
    end
    local LCX = structure.gx
    local LCY = structure.gy + structure.class.LENGTH - 1
    local CCX = structure.gx + structure.class.WIDTH - 1
    local CCY = structure.gy + structure.class.LENGTH - 1
    local OCX, OCY = CCX, CCY
    local RCX = structure.gx + structure.class.WIDTH - 1
    local RCY = structure.gy
    if self.lastStructure == structure and self.lastScale == _G.state.scaleX then return end
    self.lastScale = _G.state.scaleX
    self.lastStructure = structure
    self.points = {}
    local cx, cy, x, y = _G.getLocalCoordinatesFromGlobal(structure.gx, structure.gy)
    local elevationOffsetY = (_G.state.map.heightmap[cx][cy][x][y] or 0) * 2
    if structure.class.name == "SaxonHall" then
        CCX = CCX - 5
        CCY = CCY + 1
        self.points[#self.points + 1] = IsoToScreenX(CCX, CCY) - ((IsoToScreenX(CCX, CCY))) *
            (1 - _G.state.scaleX) + (_G.tileWidth / 2) * _G.state.scaleX
        self.points[#self.points + 1] = IsoToScreenY(CCX, CCY) - ((IsoToScreenY(CCX, CCY))) *
            (1 - _G.state.scaleX) + _G.tileHeight * _G.state.scaleX - elevationOffsetY * _G.state.scaleX
        CCX = CCX + 3
        self.points[#self.points + 1] = IsoToScreenX(CCX, CCY) - ((IsoToScreenX(CCX, CCY))) *
            (1 - _G.state.scaleX) + (_G.tileWidth / 2) * _G.state.scaleX
        self.points[#self.points + 1] = IsoToScreenY(CCX, CCY) - ((IsoToScreenY(CCX, CCY))) *
            (1 - _G.state.scaleX) + _G.tileHeight * _G.state.scaleX - elevationOffsetY * _G.state.scaleX
        CCY = CCY - 1
        self.points[#self.points + 1] = IsoToScreenX(CCX, CCY) - ((IsoToScreenX(CCX, CCY))) *
            (1 - _G.state.scaleX) + (_G.tileWidth / 2) * _G.state.scaleX
        self.points[#self.points + 1] = IsoToScreenY(CCX, CCY) - ((IsoToScreenY(CCX, CCY))) *
            (1 - _G.state.scaleX) + _G.tileHeight * _G.state.scaleX - elevationOffsetY * _G.state.scaleX
        CCX = OCX
        CCY = OCY
        self.points[#self.points + 1] = IsoToScreenX(CCX, CCY) - ((IsoToScreenX(CCX, CCY))) *
            (1 - _G.state.scaleX) + (_G.tileWidth / 2) * _G.state.scaleX
        self.points[#self.points + 1] = IsoToScreenY(CCX, CCY) - ((IsoToScreenY(CCX, CCY))) *
            (1 - _G.state.scaleX) + _G.tileHeight * _G.state.scaleX - elevationOffsetY * _G.state.scaleX
        self.points[#self.points + 1] = IsoToScreenX(RCX, RCY) - ((IsoToScreenX(RCX, RCY))) *
            (1 - _G.state.scaleX) + _G.tileWidth * _G.state.scaleX
        self.points[#self.points + 1] = IsoToScreenY(RCX, RCY) - ((IsoToScreenY(RCX, RCY))) *
            (1 - _G.state.scaleX) + (_G.tileHeight / 2) * _G.state.scaleX - elevationOffsetY * _G.state.scaleX
    else
        self.points[#self.points + 1] = IsoToScreenX(LCX, LCY) - ((IsoToScreenX(LCX, LCY))) *
            (1 - _G.state.scaleX)
        self.points[#self.points + 1] = IsoToScreenY(LCX, LCY) - ((IsoToScreenY(LCX, LCY))) *
            (1 - _G.state.scaleX) + (_G.tileHeight / 2) * _G.state.scaleX - elevationOffsetY * _G.state.scaleX
        self.points[#self.points + 1] = IsoToScreenX(CCX, CCY) - ((IsoToScreenX(CCX, CCY))) *
            (1 - _G.state.scaleX) + (_G.tileWidth / 2) * _G.state.scaleX
        self.points[#self.points + 1] = IsoToScreenY(CCX, CCY) - ((IsoToScreenY(CCX, CCY))) *
            (1 - _G.state.scaleX) + _G.tileHeight * _G.state.scaleX - elevationOffsetY * _G.state.scaleX
        self.points[#self.points + 1] = IsoToScreenX(RCX, RCY) - ((IsoToScreenX(RCX, RCY))) *
            (1 - _G.state.scaleX) + _G.tileWidth * _G.state.scaleX
        self.points[#self.points + 1] = IsoToScreenY(RCX, RCY) - ((IsoToScreenY(RCX, RCY))) *
            (1 - _G.state.scaleX) + (_G.tileHeight / 2) * _G.state.scaleX - elevationOffsetY * _G.state.scaleX
    end

end

function HighlightView:draw()
    if self.points and next(self.points) then
        local points = self:handleViewScroll()
        if _G.DestructionController.active then
            love.graphics.setLineWidth(3)
            love.graphics.setColor(0.9, 0, 0, 1)
        else
            love.graphics.setLineWidth(1)
            love.graphics.setColor(0.9, 0.9, 0.9, 1)
        end
        love.graphics.setLineStyle("smooth")
        love.graphics.line(points)
        if _G.DestructionController.active then
            love.graphics.setLineWidth(3)
            love.graphics.setColor(0.4, 0, 0, 0.75)
        else
            love.graphics.setLineWidth(1)
            love.graphics.setColor(0.4, 0.4, 0.4, 0.75)
        end
        love.graphics.setLineStyle("smooth")
        love.graphics.line(points[#points - 1], points[#points], points[#points - 3], points[#points - 2])
        love.graphics.setColor(1, 1, 1, 1)
    end
end

return HighlightView:new()
