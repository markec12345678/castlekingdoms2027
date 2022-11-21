local activeEntities, objectBatch = ...
local Object = require('objects.Object')

local Unit = _G.class('Unit', Object)
function Unit:initialize(gx, gy, type, noPathState)
    Object.initialize(self, gx, gy, type)
    self.endx = 0
    self.endy = 0
    self.lastI, self.lastO = self.i, self.o
    self.fx = self.gx * 1000 + 500
    self.fy = self.gy * 1000 + 500
    self.previousFx, self.previousFy = self.fx, self.fy
    self.previousCx = nil
    self.previousCy = nil
    self.hasMoveDir = false
    self.waypointX = nil
    self.waypointY = nil
    self.straightWalkSpeed = 2400 * 1
    self.diagonalWalkSpeed = 1500 * 1
    self.unitOffsetX = 30
    self.unitOffsetY = 57
    self.originalx = self.gx
    self.originaly = self.gy
    self.nd = {}
    self.path = 0
    self.pathState = "none"
    self.moveDir = "none"
    self.previousDir = "none"
    self.animated = true
    self.noPathState = noPathState or "No path"
    self.needNewVertAsap = false
    self.locationsCx = {}
    self.locationsCy = {}
    self.locationsI = {}
    self.locationsO = {}
    self.lrcx, self.lrcy, self.lrx, self.lry = 0, 0, 0, 0
    _G.addObjectAt(self.cx, self.cy, self.i, self.o, self)
    table.insert(self.locationsCx, self.cx)
    table.insert(self.locationsCy, self.cy)
    table.insert(self.locationsI, self.i)
    table.insert(self.locationsO, self.o)
    table.insert(activeEntities, self)
    self:calculatePosition()
end

function Unit:die()
    _G.state.population = _G.state.population - 1
    self.toBeDeleted = true
    _G.freeVertexFromTile(self.cx, self.cy, self.previousVertId)
    self.animation = nil
    _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
    _G.removeObjectAt(self.cx, self.cy, self.i, self.o, self)
end

function Unit:setNextWaypoint()
    self.waypointX = self.nd[self.count][1] + 0.5
    self.waypointY = self.nd[self.count][2] + 0.5
    self.moveDir = "none"
end

function Unit:isPositionAt(px, py)
    if self.gx - 0.5 == px and self.gy - 0.5 == py then
        return true
    end
    return false
end

function Unit:animate()
    if self == nil or self.animation == nil then
        return -- nothing to animatedAlias
    end
    local updated = self.animation:update(_G.dt)
    if self == nil or self.animation == nil then
        return -- animation may have been deleted on callback
    end
    if not self.vertId then
        self.needNewVertAsap = true
    end
    local changedTiles = self.i ~= self.lastI or self.o ~= self.lastO or self.needNewVertAsap
    updated = updated or changedTiles
    if self.instancemesh then
        if changedTiles then
            _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
            self.vertId = nil
            self.instancemesh = nil
            local newVert = _G.getFreeVertexFromTile(self.cx, self.cy, self.i, self.o)
            if newVert ~= false then
                self.needNewVertAsap = false
                self.vertId = newVert
                self.lastI, self.lastO = self.i, self.o
                updated = true
            else
                self.needNewVertAsap = true
                -- print("didn't receive new vert 1", self, self.vertId)
            end
        end
    end
    self.previousFx, self.previousFy = self.fx, self.fy
    updated = updated or ((self.previousFx ~= self.fx or self.previousFy ~= self.fy) and Object.isVisibleOnScreen(self))
    if self.instancemesh and self.animation and updated and self.vertId then
        self.lastUpdated = 0
        local offsetX, offsetY = 0, 0
        if _G.quadOffset[self.animation:getQuad()] then
            offsetX, offsetY = _G.quadOffset[self.animation:getQuad()][1] or 0,
                _G.quadOffset[self.animation:getQuad()][2] or 0
        end
        local quad, x, y, _, _, _, _, _, _, _ = self.animation:getFrameInfo(self.x + (self.offsetX or 0) + offsetX,
            self.y + (self.offsetY or 0) + offsetY -
            _G.state.map.walkingHeightmap[math.round(self.gx)][math.round(self.gy)])

        local elevationOffsetY = 0
        if _G.state.map.heightmap[self.cx][self.cy][self.i][self.o] then
            elevationOffsetY = _G.state.map.heightmap[self.cx][self.cy][self.i][self.o]
        end
        y = y - elevationOffsetY * 2
        local qx, qy, qw, qh = quad:getViewport()
        local shadowValue = _G.state.map.shadowmap[self.cx][self.cy][self.i][self.o] or 0
        local isInShadow = shadowValue > elevationOffsetY
        if isInShadow then
            shadowValue = math.min((shadowValue - elevationOffsetY) / 40, 0.6) / 1.25
        else
            shadowValue = 0
        end
        self.instancemesh:setVertex(self.vertId, x, y, qx, qy, qw, qh, 1 - shadowValue / 1.5)
        return
    end
    if not self.instancemesh and _G.state.objectMesh then
        self:updatePosition()
        local offsetX, offsetY = 0, 0
        if _G.quadOffset[self.animation:getQuad()] then
            offsetX, offsetY = _G.quadOffset[self.animation:getQuad()][1] or 0,
                _G.quadOffset[self.animation:getQuad()][2] or 0
        end
        local instancemesh = _G.state.objectMesh[self.cx][self.cy]
        local quad, x, y, _, _, _, _, _, _, _ = self.animation:getFrameInfo(self.x + (self.offsetX or 0) + offsetX,
            self.y + (self.offsetY or 0) + offsetY -
            _G.state.map.walkingHeightmap[math.round(self.gx)][math.round(self.gy)])

        local elevationOffsetY = 0
        if _G.state.map.heightmap[self.cx][self.cy][self.i][self.o] then
            elevationOffsetY = _G.state.map.heightmap[self.cx][self.cy][self.i][self.o]
        end
        y = y - elevationOffsetY * 2
        local qx, qy, qw, qh = quad:getViewport()
        if self.vertId then
            _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
            self.vertId = nil
        end
        local newVert = _G.getFreeVertexFromTile(self.cx, self.cy, self.i, self.o)
        if newVert then
            self.needNewVertAsap = false
            self.vertId = newVert
            self.instancemesh = instancemesh
            local shadowValue = _G.state.map.shadowmap[self.cx][self.cy][self.i][self.o] or 0
            local isInShadow = shadowValue > elevationOffsetY
            if isInShadow then
                shadowValue = math.min((shadowValue - elevationOffsetY) / 40, 0.6) / 1.25
            else
                shadowValue = 0
            end
            self.instancemesh:setVertex(self.vertId, x, y, qx, qy, qw, qh, 1 - shadowValue / 1.5)
            self.hasAnimation = true
        else
            self.needNewVertAsap = true
            -- print("didn't receive new vert 2")
        end
    end
end

function Unit:requestPath(xx, yy)
    if type(xx) ~= "number" then
        error("Wrong type for request path xx: " .. tostring(xx))
    end
    if type(yy) ~= "number" then
        error("Wrong type for request path yy: " .. tostring(yy))
    end
    self.startx, self.starty = math.floor(self.gx), math.floor(self.gy)
    _G.finder:requestPath(self.startx, self.starty, xx, yy)
    self.hasMoveDir = false
    self.endx = xx
    self.endy = yy
    self.pathState = "Waiting for path"
end

function Unit:reachedPathEnd()
    if self.nd[1] == nil then
        if self.gx == self.nd[0][1] + 0.5 and self.gy == self.nd[0][2] + 0.5 then
            if self.chosenOne then
                print("reached path end 1", self.state)
            end
            return true
        end
    else
        local lastNode = self.nd[#self.nd]
        if self.gx == lastNode[1] + 0.5 and self.gy == lastNode[2] + 0.5 then
            if self.chosenOne then
                print("reached path end 2", self.state)
            end
            return true
        end
    end
    return false
end

function Unit:pathfind()
    if self.endx >= _G.chunksWide * _G.chunkWidth or self.endy >= _G.chunksHigh * _G.chunkHeight or self.endx < 0 or
        self.endy < 0 then
        self.pathState = "No path"
        self.state = self.noPathState
        print("AVOIDED DISASTER, TODO: RETURN RESULT")
        return
    end
    if not self.startx or not self.starty or not self.endx or not self.endy then
        print(self.startx, self.starty, self.endx, self.endy)
        error("Trying to pathfind with wrong coordinates")
    end
    self.path = _G.finder:getPath(self.startx, self.starty, self.endx, self.endy)
    if self.path then
        if type(self.path) == "table" then
            self.nd = {}
            local first = true -- skip the first node, because it's our position
            local count = 0
            for _, node in ipairs(self.path) do
                if not first then
                    self.nd[count] = node
                    count = count + 1
                else
                    if node[1] == self.gx and node[2] == self.gy then
                        self.nd[-1] = node
                    else
                        self.nd[count] = node
                    end
                    first = false
                end
            end
            self.count = 1
            self.waypointX = self.nd[0][1] + 0.5
            self.waypointY = self.nd[0][2] + 0.5
            self.moveDir = "none"
            self.pathState = "Found"
            return true
        elseif self.path == 2 then
            self.pathState = "No path"
            print("No path found", self.state)
            self.state = self.noPathState
        end
    end
end

function Unit:calculatePosition()
    self.x = IsoX + ((self.fx * 0.001) % _G.chunkWidth - (self.fy * 0.001) % _G.chunkWidth) * tileWidth * 0.5 -
        self.unitOffsetX
    self.y = IsoY + ((self.fx * 0.001) % _G.chunkWidth + (self.fy * 0.001) % _G.chunkWidth) * tileHeight * 0.5 -
        self.unitOffsetY
    self.lastX, self.lastY = self.x, self.y
end

function Unit:updateDirection()
    local wx = self.waypointX
    local wy = self.waypointY
    if not wx or not wy then return end
    local angle = math.atan2(wy - (self.fy * 0.001), wx - (self.fx * 0.001))
    if angle < 0 then
        angle = angle + 2 * math.pi
    end
    angle = angle * (180 / math.pi)
    angle = math.round(angle)

    if angle < 0 then
        angle = 360 + angle
    end
    if (angle >= 135 + 22 and angle <= 225 - 22) then -- direction is west
        self.moveDir = "west"
        if self.previousDir ~= "west" then
            self:updatePosition()
            self:dirSubUpdate()
        end
    elseif (angle > 135 - 22 and angle < 135 + 22) then -- direction is southwest
        self.moveDir = "southwest"
        if self.previousDir ~= "southwest" then
            self:updatePosition()
            self:dirSubUpdate()
        end
    elseif (angle > 225 - 22 and angle < 225 + 22) then -- direction is northwest
        self.moveDir = "northwest"
        if self.previousDir ~= "northwest" then
            self:updatePosition()
            self:dirSubUpdate()
        end
    elseif (angle >= 225 + 22 and angle <= 315 - 22) then -- direction is north
        self.moveDir = "north"
        if self.previousDir ~= "north" then
            self:updatePosition()
            self:dirSubUpdate()
        end
    elseif (angle >= 45 + 22 and angle <= 135 - 22) then -- direction is south
        self.moveDir = "south"
        if self.previousDir ~= "south" then
            self:updatePosition()
            self:dirSubUpdate()
        end
    elseif ((angle >= 315 + 22 and angle <= 359) or (angle >= 0 and angle <= 45 - 22)) then -- direction is east
        self.moveDir = "east"
        if self.previousDir ~= "east" then
            self:updatePosition()
            self:dirSubUpdate()
        end
    elseif (angle > 45 - 22 and angle < 45 + 22) then -- direction is southeast
        self.moveDir = "southeast"
        if self.previousDir ~= "southeast" then
            self:updatePosition()
            self:dirSubUpdate()
        end
    elseif (angle > 315 - 22 and angle < 315 + 22) then -- direction is northeast
        self.moveDir = "northeast"
        if self.previousDir ~= "northeast" then
            self:updatePosition()
            self:dirSubUpdate()
        end
    end
    self.previousDir = self.moveDir
end

function Unit:updatePosition()
    self.previousCx, self.previousCy = self.cx, self.cy
    self.gx, self.gy = self.fx * 0.001, self.fy * 0.001
    self.cx, self.cy = math.floor(math.floor(self.gx) / _G.chunkWidth), math.floor(math.floor(self.gy) / _G.chunkWidth)
    local xx, yy = math.floor((self.gx) % (_G.chunkWidth)), math.floor((self.gy) % (_G.chunkWidth))
    self.lastI, self.lastO = self.i, self.o
    self.i, self.o = xx, yy
    if self.previousCx ~= self.cx or self.previousCy ~= self.cy then
        if not _G.isObjectAt(self.cx, self.cy, xx, yy, self) then
            _G.addObjectAt(self.cx, self.cy, xx, yy, self)
            for idx, _ in ipairs(self.locationsCx) do
                _G.removeObjectAt(self.locationsCx[idx], self.locationsCy[idx], self.locationsI[idx],
                    self.locationsO[idx], self)
            end
            self.locationsCx = {self.cx}
            self.locationsCy = {self.cy}
            self.locationsI = {xx}
            self.locationsO = {yy}
        end
        _G.freeVertexFromTile(self.previousCx, self.previousCy, self.vertId)
        self.vertId = nil
        self.instancemesh = nil
        if self.animation then
            local quad, x, y, _, _, _, _, _, _, _ = self.animation:getFrameInfo(
                self.x + (self.offsetX or 0) + _G.offsetX, self.y + (self.offsetY or 0) + _G.offsetY -
                _G.state.map.walkingHeightmap[math.floor(self.gx)][math.floor(self.gy)])
            local qx, qy, qw, qh = quad:getViewport()
            local newVert = _G.getFreeVertexFromTile(self.cx, self.cy, self.i, self.o)
            if newVert then
                self.vertId = newVert
                self.needNewVertAsap = false
                self.instancemesh = _G.state.objectMesh[self.cx][self.cy]
                self.vertData = {x, y, qx, qy, qw, qh, 1}
                local shadowValue = _G.state.map.shadowmap[self.cx][self.cy][self.i][self.o] or 0
                local elevationOffsetY = _G.state.map.heightmap[self.cx][self.cy][self.i][self.o] or 0
                local isInShadow = shadowValue > elevationOffsetY
                if isInShadow then
                    shadowValue = math.min((shadowValue - elevationOffsetY) / 40, 0.6) / 1.25
                else
                    shadowValue = 0
                end
                self.instancemesh:setVertex(self.vertId, x, y, qx, qy, qw, qh, 1 - shadowValue / 1.5)
                self.hasAnimation = true
            else
                -- print("didn't receive new vert 3")
                self.needNewVertAsap = true
            end
        else
            self.needNewVertAsap = true
        end
    end
    self.lrcx, self.lrcy, self.lrx, self.lry = self.cx, self.cy, xx, yy
    local newGX, newGY = math.floor(self.gx % _G.chunkWidth), math.floor(self.gy % _G.chunkWidth)
    if self.originalx ~= newGX or self.originaly ~= newGY then
        _G.addObjectAt(self.cx, self.cy, xx, yy, self)
        for idx, _ in ipairs(self.locationsCx) do
            _G.removeObjectAt(self.locationsCx[idx], self.locationsCy[idx], self.locationsI[idx], self.locationsO[idx],
                self)
        end
        self.locationsCx = {self.cx}
        self.locationsCy = {self.cy}
        self.locationsI = {xx}
        self.locationsO = {yy}
        self.originalx = newGX
        self.originaly = newGY
        self:updateDirection()

        local cgx, cgy = math.floor(self.gx), math.floor(self.gy)
        if self.moveDir == "west" then
            if _G.state.map:getWalkable(cgx - 1, cgy) == 1 then
                self.pathState = "Need to repath"
            end
        elseif self.moveDir == "south" then
            if _G.state.map:getWalkable(cgx, cgy + 1) == 1 then
                self.pathState = "Need to repath"
            end
        elseif self.moveDir == "north" then
            if _G.state.map:getWalkable(cgx, cgy - 1) == 1 then
                self.pathState = "Need to repath"
            end
        elseif self.moveDir == "east" then
            if _G.state.map:getWalkable(cgx + 1, cgy) == 1 then
                self.pathState = "Need to repath"
            end
        elseif self.moveDir == "northwest" then
            if _G.state.map:getWalkable(cgx - 1, cgy - 1) == 1 then
                self.pathState = "Need to repath"
            end
        elseif self.moveDir == "northeast" then
            if _G.state.map:getWalkable(cgx + 1, cgy - 1) == 1 then
                self.pathState = "Need to repath"
            end
        elseif self.moveDir == "southwest" then
            if _G.state.map:getWalkable(cgx - 1, cgy + 1) == 1 then
                self.pathState = "Need to repath"
            end
        elseif self.moveDir == "southeast" then
            if _G.state.map:getWalkable(cgx + 1, cgy + 1) == 1 then
                self.pathState = "Need to repath"
            end
        end
        if self.pathState == "Need to repath" then
            self:requestPath(self.endx, self.endy)
            self.pathState = "Waiting for path"
            self.moveDir = "none"
        end
        self.needNewVertAsap = true
    end
    self:calculatePosition()
end

function Unit:move()
    if self.pathState ~= "Found" then
        return
    end
    if not self.hasMoveDir then
        self:dirSubUpdate()
        self.hasMoveDir = true
    end
    if self.moveDir == "west" then
        self.fx = self.fx - _G.dt * self.straightWalkSpeed
        if self.fx < self.waypointX * 1000 then
            self.fx = self.waypointX * 1000
        end

    elseif self.moveDir == "south" then
        self.fy = self.fy + _G.dt * self.straightWalkSpeed
        if self.fy > self.waypointY * 1000 then
            self.fy = self.waypointY * 1000
        end

    elseif self.moveDir == "north" then
        self.fy = self.fy - _G.dt * self.straightWalkSpeed
        if self.fy < self.waypointY * 1000 then
            self.fy = self.waypointY * 1000
        end

    elseif self.moveDir == "east" then
        self.fx = self.fx + _G.dt * self.straightWalkSpeed
        if self.fx > self.waypointX * 1000 then
            self.fx = self.waypointX * 1000
        end

    elseif self.moveDir == "northwest" then
        self.fx = self.fx - _G.dt * self.diagonalWalkSpeed
        self.fy = self.fy - _G.dt * self.diagonalWalkSpeed
        if self.fx < self.waypointX * 1000 then
            self.fx = self.waypointX * 1000
        end
        if self.fy < self.waypointY * 1000 then
            self.fy = self.waypointY * 1000
        end

    elseif self.moveDir == "northeast" then
        self.fx = self.fx + _G.dt * self.diagonalWalkSpeed
        self.fy = self.fy - _G.dt * self.diagonalWalkSpeed
        if self.fx > self.waypointX * 1000 then
            self.fx = self.waypointX * 1000
        end
        if self.fy < self.waypointY * 1000 then
            self.fy = self.waypointY * 1000
        end

    elseif self.moveDir == "southwest" then
        self.fx = self.fx - _G.dt * self.diagonalWalkSpeed
        self.fy = self.fy + _G.dt * self.diagonalWalkSpeed
        if self.fx < self.waypointX * 1000 then
            self.fx = self.waypointX * 1000
        end
        if self.fy > self.waypointY * 1000 then
            self.fy = self.waypointY * 1000
        end

    elseif self.moveDir == "southeast" then
        self.fx = self.fx + _G.dt * self.diagonalWalkSpeed
        self.fy = self.fy + _G.dt * self.diagonalWalkSpeed
        if self.fx > self.waypointX * 1000 then
            self.fx = self.waypointX * 1000
        end
        if self.fy > self.waypointY * 1000 then
            self.fy = self.waypointY * 1000
        end

    end
    self:updatePosition()
end

function Unit:jobUpdate()
    _G.removeObjectAt(self.lrcx, self.lrcy, self.lrx, self.lry, self)
    _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
    self.vertId = nil
    self.instancemesh = nil
    self.animation = nil
end

function Unit:serialize()
    local data = {}
    local objectData = Object.serialize(self)
    for k, v in pairs(objectData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.startx = self.startx
    data.starty = self.starty
    data.endx = self.endx
    data.endy = self.endy
    data.lastI, data.lastO = self.lastI, self.lastO
    data.fx = self.fx
    data.fy = self.fy
    data.previousFx, data.previousFy = self.previousFx, self.previousFy
    data.previousCx = self.previousCx
    data.previousCy = self.previousCy
    data.hasMoveDir = self.hasMoveDir
    data.waypointX = self.waypointX
    data.waypointY = self.waypointY
    data.straightWalkSpeed = self.straightWalkSpeed
    data.diagonalWalkSpeed = self.diagonalWalkSpeed
    data.unitOffsetX = self.unitOffsetX
    data.unitOffsetY = self.unitOffsetY
    data.originalx = self.originalx
    data.originaly = self.originaly
    data.nd = self.nd
    data.path = self.path
    data.pathState = self.pathState
    data.moveDir = self.moveDir
    data.previousDir = self.previousDir
    data.animated = self.animated
    data.noPathState = self.noPathState
    data.needNewVertAsap = self.needNewVertAsap
    data.locationsCx = self.locationsCx
    data.locationsCy = self.locationsCy
    data.locationsI = self.locationsI
    data.locationsO = self.locationsO
    data.lrcx, data.lrcy, data.lrx, data.lry = self.lrcx, self.lrcy, self.lrx, self.lry
    return data
end

function Unit.static:deserialize(data)
    local object = _G.getClassByName(data.className)
    data.needNewVertAsap = true
    local obj = object:allocate()
    Object.deserialize(obj, data)
    if not obj.eatTimer then
        obj.eatTimer = 0
    end
    obj:load(data)
    return obj
end

function Unit:clearPath()
    self.nd = {}
    self.waypointX, self.waypointY = nil, nil
    self.previousDir = "none"
    self.moveDir = "none"
    self.count = 1
end

function Unit:load(_)
    _G.addObjectAt(self.cx, self.cy, self.i, self.o, self)
    table.insert(self.locationsCx, self.cx)
    table.insert(self.locationsCy, self.cy)
    table.insert(self.locationsI, self.i)
    table.insert(self.locationsO, self.o)
    table.insert(activeEntities, self)
    self:calculatePosition()
end

return Unit
