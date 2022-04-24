local Object = require("objects.Object")
local Structure = _G.class('Structure', Object)
function Structure:initialize(gx, gy, type)
    Object.initialize(self, gx, gy, type)
    _G.addObjectAt(self.cx, self.cy, self.i, self.o, self)
end
function Structure:animate(dt, force_update)
    dt = dt or _G.dt
    if not self.animation or not self.animated then
        return
    end
    local updated = self.animation:update(dt) or force_update
    -- animation might have called a callback and deleted itself
    if not self.animation or not self.animated then
        return
    end
    if not self.instancemesh and _G.state.object_mesh then
        local offset_x, offset_y = 0, 0
        if _G.quad_offset[self.animation:getQuad()] then
            offset_x, offset_y = _G.quad_offset[self.animation:getQuad()][1] or 0,
                _G.quad_offset[self.animation:getQuad()][2] or 0
        end
        local instancemesh = _G.state.object_mesh[self.cx][self.cy]
        local quad, x, y, _, _, _, _, _, _, _ = self.animation:getFrameInfo(self.x + (self.offset_x or 0) + offset_x,
            self.y + (self.offset_y or 0) + offset_y - _G.state.map.walking_heightmap[self.gx][self.gy])
        local elevation_offset_y = 0
        if _G.state.map.heightmap[self.cx][self.cy][self.i][self.o] then
            elevation_offset_y = _G.state.map.heightmap[self.cx][self.cy][self.i][self.o] * 2
        end
        y = y - elevation_offset_y
        local qx, qy, qw, qh = quad:getViewport()
        self.vert_id = _G.getFreeVertexFromTile(self.cx, self.cy, self.i, self.o)
        if self.vert_id then
            self.instancemesh = instancemesh
            self.instancemesh:setVertex(self.vert_id, x, y, qx, qy, qw, qh, 1)
        end
        return
    end
    if self.instancemesh and updated then
        local offset_x, offset_y = 0, 0
        if _G.quad_offset[self.animation:getQuad()] then
            offset_x, offset_y = _G.quad_offset[self.animation:getQuad()][1] or 0,
                _G.quad_offset[self.animation:getQuad()][2] or 0
        end
        local quad, x, y, _, _, _, _, _, _, _ = self.animation:getFrameInfo(self.x + (self.offset_x or 0) + offset_x,
            self.y + (self.offset_y or 0) + offset_y - _G.state.map.walking_heightmap[self.gx][self.gy])
        local elevation_offset_y = 0
        if _G.state.map.heightmap[self.cx][self.cy][self.i][self.o] then
            elevation_offset_y = _G.state.map.heightmap[self.cx][self.cy][self.i][self.o] * 2
        end
        y = y - elevation_offset_y
        if quad then
            local qx, qy, qw, qh = quad:getViewport()
            self.instancemesh:setVertex(self.vert_id, x, y, qx, qy, qw, qh, 1)
        end
        return
    end
end
function Structure:serialize()
    local data = {}
    local object_data = Object.serialize(self)
    for k, v in pairs(object_data) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    return data
end

function Structure.static:applyBuildingHeightMap(gx, gy, buildingWidth, buildingLength, buildingHeight)
    for xx = 0, buildingWidth do
        for yy = 0, buildingLength do
            local building_tile_coordinate_x = gx + xx
            local building_tile_coordinate_y = gy + yy
            _G.terrainSetTileAt(building_tile_coordinate_x, building_tile_coordinate_y, _G.terrain_biome.none)
            local ccx, ccy, xxx, yyy = _G.getLocalCoordinatesFromGlobal(building_tile_coordinate_x,
                building_tile_coordinate_y)
            _G.buildingheightmap[ccx][ccy][xxx][yyy] = buildingHeight
        end
    end
end

function Structure:load(data)
    Object.initialize(self, data.gx, data.gy, data.type)
    _G.addObjectAt(self.cx, self.cy, self.i, self.o, self)
end

return Structure
