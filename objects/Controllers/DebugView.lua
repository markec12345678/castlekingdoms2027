local image = love.graphics.newImage("assets/tiles/info_tiles_strip.png")
local Object = require("objects.Object")
local tileWidth, tileHeight = _G.tileWidth, _G.tileHeight
local IsoToScreenX, IsoToScreenY = _G.IsoToScreenX, _G.IsoToScreenY

local DebugView = _G.class("DebugView")
function DebugView:initialize()
    self.width = 16
    self.height = 16
    self.gx = 0
    self.gy = 0
    self.FX = 0
    self.FY = 0
    self.active = false
    self.focus = "objects"
    self.batch = love.graphics.newSpriteBatch(image)
    self.quads = {}
    self.info = ""
    self.lastObject = nil
    self.quads[1] = love.graphics.newQuad(0, 0, 30, 16, image:getWidth(), image:getHeight())
    self.quads[2] = love.graphics.newQuad(30, 0, 30, 16, image:getWidth(), image:getHeight())
    self.quads[3] = love.graphics.newQuad(60, 0, 30, 16, image:getWidth(), image:getHeight())
    self.quads[4] = love.graphics.newQuad(90, 0, 30, 16, image:getWidth(), image:getHeight())
end

function DebugView:toggle()
    if not self.active then
        self.focus = "objects"
        self.active = true
        return
    end
    if self.focus == "objects" then
        self.focus = "pathfinding"
        return
    end
    if self.focus == "pathfinding" then
        self.active = false
        return
    end
end

function DebugView:update()
    self.info = ""
    if self.active then
        local MX, MY = love.mouse.getPosition()
        local OX, OY = _G.getTerrainTileOnMouse(MX, MY)
        local objectOnMouse
        if self.focus == "objects" then
            objectOnMouse = _G.objectFromSubclassAtGlobal(OX, OY, Object)
            if objectOnMouse then
                self.lastObject = objectOnMouse
            elseif self.lastObject then
                if _G.manhattanDistance(OX, OY, self.lastObject.gx, self.lastObject.gy) <= 2 then
                    objectOnMouse = self.lastObject
                end
            end

            if objectOnMouse then
                self.info = ("[%s]\n"):format(objectOnMouse.class.name)
                for k, v in pairs(objectOnMouse) do
                    self.info = self.info .. ("\t%s: %s\n"):format(k, v)
                end
            end
        elseif self.focus == "pathfinding" then
            self.info = "(0) Walkable"
            if _G.state.map:getWalkable(OX, OY) == 1 then
                self.info = "(1) Not Walkable"
            end
            local cx, cy, i, o = _G.getLocalCoordinatesFromGlobal(OX, OY)
            self.info = self.info .. "\n Shadow: " .. tostring(_G.state.map.shadowmap[cx][cy][i][o] or 0)
            self.info = self.info .. "\n cx, cy, i, o: " .. cx .. ", " .. cy .. ", " .. i .. ", " .. o
            self.info = self.info .. "\n gx, gy: " .. OX .. ", " .. OY
            local val = -1

            local Structure = require("objects.Structure")
            local structure = _G.objectFromSubclassAtGlobal(OX, OY, Structure)
            if structure then
                val = structure:getAverageShadowValue()
            end
            self.info = self.info .. "\n" .. val
        end

        local LX, LY = OX - math.floor(self.width / 2), OY - math.floor(self.height / 2)
        self.gx, self.gy = LX, LY
        local cx, cy, x, y = _G.getLocalCoordinatesFromGlobal(self.gx, self.gy)
        local type
        self.elevationOffsetY = (_G.state.map.heightmap[cx][cy][x][y] or 0) * 2
        self.FX = IsoToScreenX(LX, LY) - _G.state.viewXview - ((IsoToScreenX(LX, LY)) - _G.state.viewXview) *
            (1 - _G.state.scaleX)
        self.FY = IsoToScreenY(LX, LY) - _G.state.viewYview - ((IsoToScreenY(LX, LY)) - _G.state.viewYview) *
            (1 - _G.state.scaleX)
        -- No point to flush the batch everytime, only do it when the position changes
        if self.previousGx ~= self.gx or self.previousGy ~= self.gy then
            self.batch:clear()
            for xx = 0, self.width - 1 do
                for yy = 0, self.height - 1 do
                    local ccx, ccy, xxx, yyy = _G.getLocalCoordinatesFromGlobal(xx + self.gx, yy + self.gy)
                    if self.focus == "objects" then
                        if _G.importantObjectAtGlobal(xx + self.gx, yy + self.gy) then
                            type = 1
                        else
                            type = 2
                        end
                        if objectOnMouse and objectOnMouse.cx == ccx and objectOnMouse.cy == ccy and objectOnMouse.i ==
                            xxx and objectOnMouse.o == yyy then
                            type = 4
                        end
                    elseif self.focus == "pathfinding" then
                        if _G.state.map:getWalkable(xx + self.gx, yy + self.gy) == 1 then
                            type = 1
                        else
                            type = 2
                        end
                        if xx + self.gx == OX and yy + self.gy == OY then
                            type = 4
                        end
                    end
                    local elevationOffsetY = (_G.state.map.heightmap[ccx][ccy][xxx][yyy] or 0) * 2
                    self.batch:add(self.quads[type], (xx - yy) * tileWidth * 0.5,
                        (xx + yy) * tileHeight * 0.5 - elevationOffsetY, 0, 1, 1)
                end
            end
            self.batch:flush()
            self.previousGx = self.gx
            self.previousGy = self.gy
        end
    end
end

function DebugView:draw()
    if self.active then
        love.graphics.setColor(1, 1, 1, 0.3)
        love.graphics.draw(self.batch, self.FX, self.FY, nil, _G.state.scaleX)
        love.graphics.setColor(1, 1, 1, 1)
        local MX, MY = love.mouse.getPosition()
        if self.info then
            love.graphics.print(self.info, MX + 30 - love.graphics.getWidth() / 2, MY - love.graphics.getHeight() / 2)
        end
    end
end

return DebugView:new()
