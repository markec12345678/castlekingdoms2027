local Object = require("objects.Object")
local Structure = _G.class("Structure", Object)
function Structure:initialize(gx, gy, type)
    Object.initialize(self, gx, gy, type)
    _G.addObjectAt(self.cx, self.cy, self.i, self.o, self)
    self:calculateShadowValue()
end
function Structure:getAverageShadowValue()
    local parent = self.parent
    local gx, gy
    local width = self.class.static.WIDTH
    local length = self.class.static.LENGTH
    if parent then
        if parent["_ref"] then
            parent = _G.state:dereferenceObject(parent)
        end
        gx, gy = parent.gx, parent.gy
        width, length = parent.class.static.WIDTH, parent.class.static.LENGTH
    else
        gx, gy = self.gx, self.gy
    end
    if width and length then
        local totalShadow = 0
        local count = 0
        for x = 0, width do
            for y = 0, length do
                local cx, cy, i, o = _G.getLocalCoordinatesFromGlobal(gx + x, gy + y)
                count = count + 1
                totalShadow = totalShadow + (_G.state.map.shadowmap[cx][cy][i][o] or 0)
                cx, cy, i, o = _G.getLocalCoordinatesFromGlobal(gx + x + 2, gy + y + 2)
                _G.scheduleTerrainUpdate(cx, cy, i, o)
            end
        end
        return totalShadow / count
    end
    return 0
end
function Structure:calculateShadowValue()
    local cx, cy, i, o
    local parent = self.parent
    if parent and parent["_ref"] then
        parent = _G.state:dereferenceObject(parent)
    end
    local thisTileheight = self.class.static.HEIGHT or (parent and parent.class.static.HEIGHT) or 0
    if self.parent then
        cx, cy, i, o = parent.cx, parent.cy, parent.i, parent.o
    else
        cx, cy, i, o = self.cx, self.cy, self.i, self.o
    end
    local elevationOffsetY = _G.state.map.heightmap[cx][cy][i][o] or 0
    local elevationValue = 75 * elevationOffsetY / (40 + elevationOffsetY)
    local shadowValue = self:getAverageShadowValue()

    if shadowValue < thisTileheight * 0.8 + elevationValue then
        self.shadowValue = 1
    else
        shadowValue = math.min((shadowValue - elevationValue - thisTileheight) / 40, 0.6)
        self.shadowValue = math.min(0.825, 1 - shadowValue)
    end
end
function Structure:shadeFromTerrain()
    self:calculateShadowValue()
    if self.tile then
        self:render()
    elseif self.animation then
        self.animate(_G.dt, true)
    end
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
            self.instancemesh:setVertex(self.vertId, x, y, qx, qy, qw, qh, self.shadowValue)
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
            self.instancemesh:setVertex(self.vertId, x, y, qx, qy, qw, qh, self.shadowValue)
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

function Structure.static:applyBuildingHeightMap(gx, gy, buildingWidth, buildingLength, buildingHeight, skipNoneBiome)
    for xx = 0, buildingWidth - 1 do
        for yy = 0, buildingLength - 1 do
            local buildingX = gx + xx
            local buildingY = gy + yy
            if not skipNoneBiome then
                _G.terrainSetTileAt(buildingX, buildingY, _G.terrainBiome.none)
            end
            local ccx, ccy, xxx, yyy = _G.getLocalCoordinatesFromGlobal(buildingX, buildingY)
            _G.buildingheightmap[ccx][ccy][xxx][yyy] = buildingHeight
            _G.state.map:setWalkable(buildingX, buildingY, 1)
        end
    end
end

function Structure:load(data)
    Object.initialize(self, data.gx, data.gy, data.type)
    _G.addObjectAt(self.cx, self.cy, self.i, self.o, self)
end

return Structure
