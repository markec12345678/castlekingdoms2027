local queue = require("libraries.queue")
local Events = require("objects.Enums.Events")

local waypointSheet = love.graphics.newImage("assets/ui/unit_control/waypoint_float_strip.png")
local imageW, imageH = 336, 23
local waypointQuads = {
    love.graphics.newQuad(0, 0, 42, 23, imageW, imageH),
    love.graphics.newQuad(1 * 42, 0, 42, 23, imageW, imageH),
    love.graphics.newQuad(2 * 42, 0, 42, 23, imageW, imageH),
    love.graphics.newQuad(3 * 42, 0, 42, 23, imageW, imageH),
    love.graphics.newQuad(4 * 42, 0, 42, 23, imageW, imageH),
    love.graphics.newQuad(5 * 42, 0, 42, 23, imageW, imageH),
    love.graphics.newQuad(6 * 42, 0, 42, 23, imageW, imageH),
    love.graphics.newQuad(7 * 42, 0, 42, 23, imageW, imageH)
}
waypointQuads = _G.addReverse(waypointQuads)

local WaypointFloat = _G.class("WaypointFloat")
function WaypointFloat:initialize(gx, gy)
    self.animation = anim.newAnimation(waypointQuads, 0.05)
    self.gx, self.gy = gx, gy
    self.active = true
end

function WaypointFloat:draw()
    if not self.active then return false end
    self.animation:update(love.timer.getDelta())
    local gx, gy = self.gx, self.gy
    local cx, cy, x, y = _G.getLocalCoordinatesFromGlobal(gx, gy)
    local elevationOffsetY = (_G.state.map.heightmap[cx][cy][x][y] or 0) * 2 - _G.state.map.walkingHeightmap[self.gx][self.gy]
    local fx = IsoToScreenX(gx, gy) - _G.state.viewXview - ((IsoToScreenX(gx, gy)) - _G.state.viewXview) * (1 - _G.state.scaleX) - 10 * _G.state.scaleX
    local fy = IsoToScreenY(gx, gy) - _G.state.viewYview - ((IsoToScreenY(gx, gy)) - _G.state.viewYview) * (1 - _G.state.scaleX) - 5 * _G.state.scaleX
    love.graphics.draw(
        waypointSheet,
        self.animation:getQuad(),
        fx,
        fy + (-elevationOffsetY) * _G.state.scaleX,
        0, _G.state.scaleX
    )
end

function WaypointFloat:remove()
    self.animation = nil
    self.active = false
    self = nil
end

---@class Commander
---@field public selectedUnits table<Unit>
---@field private initialize function
local Commander = _G.class("Commander")
function Commander:initialize()
    self.initialPressGX = nil
    self.initialPressGY = nil
    self.initialMX, self.initialMY = nil, nil
    self.isDown = false
    self.selectedUnits = {}
    self.selectedUnitsByType = {}
    self.centerPosition = nil
    self.waypointFloats = {}
end

---clears waypoints from memory
function Commander:clearWaypoints()
    for _, v in ipairs(self.waypointFloats) do
        v:remove()
    end
    self.waypointFloats = {}
end

---returns true if the position is within map bounds
---@param gx integer The global X tile position
---@param gy integer The global Y tile position
---@return boolean isInBounds
function Commander:isInBounds(gx, gy)
    if (gx < 0 or gy < 0
            or gx > _G.chunkWidth * _G.chunksWide
            or gy > _G.chunkHeight * _G.chunksHigh) then
        return false
    end
    return true
end

---generates a list of positions from the center of X,Y with floodfill
---@param x integer The global X tile position
---@param y integer The global Y tile position
---@param unitCount integer Determines how large the floodfill should be
---@return table<integer, integer>[] positions List of positions
function Commander:floodfill(x, y, unitCount)
    local stack = queue:new()
    local visited = newAutotable(2)
    local positions = {}
    if self:isInBounds(x, y) and _G.state.map:getWalkable(x, y) == 0 then
        stack:push({ x, y })
        visited[x][y] = true
        positions = { { x, y } }
        unitCount = unitCount - 1
    end
    while #stack > 0 or unitCount > 0 do
        local p = stack:pop()
        if not p then return positions end
        x, y = p[1], p[2]
        if self:isInBounds(x + 1, y) and not visited[x + 1][y] and _G.state.map:getWalkable(x + 1, y) == 0 then
            stack:push({ x + 1, y })
            visited[x + 1][y] = true
            positions[#positions + 1] = { x + 1, y }
            unitCount = unitCount - 1
            if unitCount == 0 then return positions end
        end
        if self:isInBounds(x - 1, y) and not visited[x - 1][y] and _G.state.map:getWalkable(x - 1, y) == 0 then
            stack:push({ x - 1, y })
            visited[x - 1][y] = true
            positions[#positions + 1] = { x - 1, y }
            unitCount = unitCount - 1
            if unitCount == 0 then return positions end
        end
        if self:isInBounds(x, y + 1) and not visited[x][y + 1] and _G.state.map:getWalkable(x, y + 1) == 0 then
            stack:push({ x, y + 1 })
            visited[x][y + 1] = true
            positions[#positions + 1] = { x, y + 1 }
            unitCount = unitCount - 1
            if unitCount == 0 then return positions end
        end
        if self:isInBounds(x, y - 1) and not visited[x][y - 1] and _G.state.map:getWalkable(x, y - 1) == 0 then
            stack:push({ x, y - 1 })
            visited[x][y - 1] = true
            positions[#positions + 1] = { x, y - 1 }
            unitCount = unitCount - 1
            if unitCount == 0 then return positions end
        end
    end
    return positions
end

---handles mousepresses
---@return boolean consumed whether the mouse press should be propagated to other controllers
function Commander:mousepressed(x, y, button)
    if button == 1 and not _G.BuildController.active and not _G.DestructionController.active and not _G.BrushController.active then
        self.initialMX, self.initialMY = x, y
        self.initialPressGX, self.initialPressGY = _G.getTerrainTileOnMouse(x, y)
        self.isDown = true
        return true
    end
    return false
end

---handles mousereleases
---@return boolean consumed whether the mouse release should be propagated to other controllers
function Commander:mousereleased(x, y, button)
    if button == 1 then
        if self.isDown then self.isDown = false else return false end
        local finalPressGX, finalPressGY = _G.getTerrainTileOnMouse(x, y)
        self:selectUnitsInArea(self.initialPressGX, self.initialPressGY, finalPressGX, finalPressGY)
        return true
    elseif button == 2 and #self.selectedUnits > 0 then
        self:clearWaypoints()
        local pressGX, pressGY = _G.getTerrainTileOnMouse(x, y)
        local positions = self:floodfill(pressGX, pressGY, #self.selectedUnits)
        local totalUnits = 0
        local newSelectedUnitsOrder = {}
        for idx, unit in ipairs(self.selectedUnits) do
            if not positions[idx] then goto ranOutOfSpace end
            self.waypointFloats[#self.waypointFloats + 1] = WaypointFloat:new(positions[idx][1], positions[idx][2])
            unit:gotoUserWaypoint(positions[idx][1], positions[idx][2], self.waypointFloats[#self.waypointFloats], function()
                totalUnits = totalUnits - 1
                if totalUnits == 0 then
                    for _, v in ipairs(newSelectedUnitsOrder) do
                        v.state = "Going to waypoint"
                    end
                end
            end)
            totalUnits = totalUnits + 1
            newSelectedUnitsOrder[#newSelectedUnitsOrder + 1] = unit
        end
        ::ranOutOfSpace::
        self.selectedUnits = newSelectedUnitsOrder
    end
    return false
end

---selects units in a rectangle area
---@param x1 integer Global position
---@param y1 integer Global position
---@param x2 integer Global position
---@param y2 integer Global position
function Commander:selectUnitsInArea(x1, y1, x2, y2)
    self.selectedUnits = {}
    self.selectedUnitsByType = {}
    local Soldier = require("objects.Units.Soldier")
    local tileStartX, tileStartY, tileEndX, tileEndY = x1, y1, x2, y2

    local firstRow = math.min(tileStartX + tileStartY, tileEndX + tileEndY)
    local lastRow = math.max(tileStartX + tileStartY, tileEndX + tileEndY)

    local firstColumn = math.min(tileStartX - tileStartY, tileEndX - tileEndY)
    local lastColumn = math.max(tileStartX - tileStartY, tileEndX - tileEndY)

    for row = firstRow, lastRow do
        local shift = bit.band(bit.bxor(row, firstColumn), 1)
        for column = firstColumn + shift, lastColumn, 2 do
            local xx, yy = bit.rshift(row + column, 1), bit.rshift(row - column, 1)
            local units = _G.allObjectsFromSubclassAtGlobal(xx, yy, Soldier)
            for _, unit in ipairs(units) do
                self.selectedUnits[#self.selectedUnits + 1] = unit
                if not self.selectedUnitsByType[unit.class.name] then
                    self.selectedUnitsByType[unit.class.name] = { unit }
                else
                    table.insert(self.selectedUnitsByType[unit.class.name], unit)
                end
            end
        end
    end
    if next(self.selectedUnitsByType) == nil then
        _G.bus.emit(Events.OnUnitsDeselected)
    else
        _G.bus.emit(Events.OnUnitsSelected, self.selectedUnitsByType)
    end
end

local HEALTHBARS = {
    REGULAR = {
        love.graphics.newImage("assets/ui/healthbars/regular/healthbar_regular (1).png"),
        love.graphics.newImage("assets/ui/healthbars/regular/healthbar_regular (2).png"),
        love.graphics.newImage("assets/ui/healthbars/regular/healthbar_regular (3).png"),
        love.graphics.newImage("assets/ui/healthbars/regular/healthbar_regular (4).png"),
        love.graphics.newImage("assets/ui/healthbars/regular/healthbar_regular (5).png"),
        love.graphics.newImage("assets/ui/healthbars/regular/healthbar_regular (6).png"),
        love.graphics.newImage("assets/ui/healthbars/regular/healthbar_regular (7).png"),
        love.graphics.newImage("assets/ui/healthbars/regular/healthbar_regular (8).png"),
        love.graphics.newImage("assets/ui/healthbars/regular/healthbar_regular (9).png"),
        love.graphics.newImage("assets/ui/healthbars/regular/healthbar_regular (10).png"),
        love.graphics.newImage("assets/ui/healthbars/regular/healthbar_regular (11).png")
    }
}

---draws selection rectangle in absolute position
function Commander:drawMouse()
    if self.isDown then
        love.graphics.rectangle("line", self.initialMX, self.initialMY, love.mouse.getX() - self.initialMX, love.mouse.getY() - self.initialMY)
        local x, y = love.mouse.getPosition()
        local finalPressGX, finalPressGY = _G.getTerrainTileOnMouse(x, y)
        self:selectUnitsInArea(self.initialPressGX, self.initialPressGY, finalPressGX, finalPressGY)
    end
end

---draws the healthbars in relative position
function Commander:draw()
    if #self.selectedUnits == 0 then
        return
    end
    for _, v in ipairs(self.waypointFloats) do
        v:draw()
    end
    for _, unit in ipairs(self.selectedUnits) do
        local gx, gy = unit.gx, unit.gy
        local cx, cy, x, y = _G.getLocalCoordinatesFromGlobal(gx, gy)
        local elevationOffsetY = (_G.state.map.heightmap[cx][cy][x][y] or 0) * 2
        local fx = IsoToScreenX(gx, gy) - _G.state.viewXview - ((IsoToScreenX(gx, gy)) - _G.state.viewXview) * (1 - _G.state.scaleX)
        local fy = IsoToScreenY(gx, gy) - _G.state.viewYview - ((IsoToScreenY(gx, gy)) - _G.state.viewYview) * (1 - _G.state.scaleX)

        love.graphics.draw(
            HEALTHBARS.REGULAR[math.ceil(unit.health / 10)],
            fx,
            fy + (-elevationOffsetY - 50) * _G.state.scaleX,
            0, _G.state.scaleX
        )
    end
end

---@type Commander
local commander = Commander:new()
return commander
