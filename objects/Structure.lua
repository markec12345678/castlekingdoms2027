local Object = require("objects.Object")
local Structure = _G.class('Structure', Object)
function Structure:initialize(gx, gy, type)
    Object.initialize(self, gx, gy, type)
    _G.addObjectAt(self.cx, self.cy, self.i, self.o, self)
end
function Structure:animate(dt, forceUpdate)
    dt = dt or _G.dt
    if not self.animation or not self.animated then
        return
    end
    local updated = self.animation:update(dt) or forceUpdate
    -- animation might have called a callback and deleted itself
    if not self.animation or not self.animated then
        return
    end
    if not self.instancemesh and _G.state.objectMesh then
        local offsetX, offsetY = 0, 0
        if _G.quadOffset[self.animation:getQuad()] then
            offsetX, offsetY = _G.quadOffset[self.animation:getQuad()][1] or 0,
                _G.quadOffset[self.animation:getQuad()][2] or 0
        end
        local instancemesh = _G.state.objectMesh[self.cx][self.cy]
        local quad, x, y, _, _, _, _, _, _, _ = self.animation:getFrameInfo(self.x + (self.offsetX or 0) + offsetX,
            self.y + (self.offsetY or 0) + offsetY - _G.state.map.walkingHeightmap[self.gx][self.gy])
        local elevationOffsetY = 0
        if _G.state.map.heightmap[self.cx][self.cy][self.i][self.o] then
            elevationOffsetY = _G.state.map.heightmap[self.cx][self.cy][self.i][self.o] * 2
        end
        y = y - elevationOffsetY
        local qx, qy, qw, qh = quad:getViewport()
        self.vertId = _G.getFreeVertexFromTile(self.cx, self.cy, self.i, self.o)
        if self.vertId then
            self.instancemesh = instancemesh
            self.instancemesh:setVertex(self.vertId, x, y, qx, qy, qw, qh, 1)
        end
        return
    end
    if self.instancemesh and updated then
        local offsetX, offsetY = 0, 0
        if _G.quadOffset[self.animation:getQuad()] then
            offsetX, offsetY = _G.quadOffset[self.animation:getQuad()][1] or 0,
                _G.quadOffset[self.animation:getQuad()][2] or 0
        end
        local quad, x, y, _, _, _, _, _, _, _ = self.animation:getFrameInfo(self.x + (self.offsetX or 0) + offsetX,
            self.y + (self.offsetY or 0) + offsetY - _G.state.map.walkingHeightmap[self.gx][self.gy])
        local elevationOffsetY = 0
        if _G.state.map.heightmap[self.cx][self.cy][self.i][self.o] then
            elevationOffsetY = _G.state.map.heightmap[self.cx][self.cy][self.i][self.o] * 2
        end
        y = y - elevationOffsetY
        if quad then
            local qx, qy, qw, qh = quad:getViewport()
            self.instancemesh:setVertex(self.vertId, x, y, qx, qy, qw, qh, 1)
        end
        return
    end
end
function Structure:serialize()
    local data = {}
    local objectData = Object.serialize(self)
    for k, v in pairs(objectData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    return data
end

function Structure.static:applyBuildingHeightMap(gx, gy, buildingWidth, buildingLength, buildingHeight)
    for xx = 0, buildingWidth - 1 do
        for yy = 0, buildingLength - 1 do
            local buildingTileCoordinateX = gx + xx
            local buildingTileCoordinateY = gy + yy
            _G.terrainSetTileAt(buildingTileCoordinateX, buildingTileCoordinateY, _G.terrainBiome.none)
            local ccx, ccy, xxx, yyy =
                _G.getLocalCoordinatesFromGlobal(buildingTileCoordinateX, buildingTileCoordinateY)
            _G.buildingheightmap[ccx][ccy][xxx][yyy] = buildingHeight
        end
    end
end

function Structure:load(data)
    Object.initialize(self, data.gx, data.gy, data.type)
    _G.addObjectAt(self.cx, self.cy, self.i, self.o, self)
end

return Structure
