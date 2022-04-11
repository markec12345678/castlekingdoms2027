local _, active_entities, tile_quads, _ = ...
local Object = require("objects.Object")
local anim = require("libraries.anim8")

local fall_fx = {_G.fx["liltreefall"], _G.fx["bigtreefall1"], _G.fx["bigtreefall2"]}

local quad_offset = require('objects.quad_offset')
local STATIC_TRUNK = "Static Trunk"
local Tree = _G.class('Tree', Object)
function Tree:initialize(gx, gy, type)
    Object.initialize(self, gx, gy, type)
    self.offset_y = self.offset_y or -166
    self.base_offset_x = self.base_offset_x or -3 - 38
    self.offset_x = self.base_offset_x
    self.falling = false
    self.chop = false
    self.stump = false
    self.animated = true
    self.marked = false
    self.tile = nil
    self.cuttable = true
    self.tree = true
    self.active = false
    self.offset_timer = 0
    self.instancemesh = nil
    self.update_timer = 0
    self.chunk_key = false
    self.trunk_tile = tile_quads["empty"]
    for xx = -1, 1 do
        for yy = -1, 1 do
            if not ((xx == -1 and yy == -1) or (xx == 1 and yy == 1) or (xx == -1 and yy == 1) or (xx == 1 and yy == -1)) then
                local ccx, ccy, xxx, yyy = _G.getLocalCoordinatesFromGlobal(self.gx + xx, self.gy + yy)
                if xx == 0 and yy == 0 then
                    _G.buildingheightmap[ccx][ccy][xxx][yyy] = 19
                else
                    _G.buildingheightmap[ccx][ccy][xxx][yyy] = 14
                end
            end
        end
    end
    if self.gx < 2048 and self.gx >= 0 and self.gy < 2048 and self.gy >= 0 then
        _G.state.map:setWalkable(self.gx, self.gy, 1)
    end
    if _G.state.chunk_objects[self.cx][self.cy] == nil then
        _G.state.chunk_objects[self.cx][self.cy] = {}
    end
    _G.state.chunk_objects[self.cx][self.cy][self] = self
    _G.addObjectAt(self.cx, self.cy, self.i, self.o, self)
end
function Tree:finish()
    -- Object was deleted by arrayRemove, so we need to readd it
    _G.addObjectAt(self.cx, self.cy, self.i, self.o, self)
    self.animation = anim.newAnimation({self.trunk_tile}, 0.1, nil, STATIC_TRUNK)
    self.animation:pause()
    self.stump = true
    self.animated = false -- mark for removal from list
    self.type = "Stump"
    self.tile = self.trunk_tile
    self:render()
    for xx = -1, 1 do
        for yy = -1, 1 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.dirt, _G.terrain_biome.scarce_grass)
        end
    end
    for xx = -1, 1 do
        for yy = -1, 1 do
            if not ((xx == -1 and yy == -1) or (xx == 1 and yy == 1) or (xx == -1 and yy == 1) or (xx == 1 and yy == -1)) then
                local ccx, ccy, xxx, yyy = _G.getLocalCoordinatesFromGlobal(self.gx + xx, self.gy + yy)
                _G.buildingheightmap[ccx][ccy][xxx][yyy] = 0
                -- TODO: Force a shadow refresh here
            end
        end
    end
end
function Tree:cut_down()
    return function()
        self.to_be_deleted = true
        self.falling = false
        self.chop = true
        self.animation = self.chop_animation
        self.animation:pause()
    end
end
function Tree:render()
    if not self.instancemesh then
        self:animate()
    end
    if _G.state.object_mesh then
        local offset_x, offset_y = 0, 0
        if quad_offset[self.tile] then
            offset_x, offset_y = quad_offset[self.tile][1] or 0, quad_offset[self.tile][2] or 0
        end
        local x, y = self.x + (self.offset_x or 0) + offset_x, self.y + (self.offset_y or 0) + offset_y
        local qx, qy, qw, qh = self.tile:getViewport()
        self.instancemesh:setVertex(self.vert_id, x, y, qx, qy, qw, qh, 1)
    end
end
function Tree:update(dt)
    if self.falling then
        self:animate(dt)
    end
end
function Tree:animate(dt, force_update)
    local updated, ticked = false, false
    if _G.state.scale_x > 0.6 then
        updated = self.animation:update(dt)
        ticked = true
        self.offset_timer = self.offset_timer + 1
        if self.offset_timer > 4 then
            self.offset_x = self.base_offset_x
        end
    elseif _G.state.scale_x > 0.3 then
        self.update_timer = self.update_timer + 1
        if self.update_timer == 10 then
            updated = self.animation:update(dt)
            ticked = true
            self.update_timer = 0
        end
    end
    if self.falling and not ticked then
        updated = self.animation:update(dt)
        if not Object.is_visible_on_screen(self) then
            return -- no need to update vertex if we can't see it
        end
    end
    updated = updated or self.offset_x ~= self.previous_offset_x
    self.previous_offset_x = self.offset_x
    if self.instancemesh and (updated or force_update) then
        self.last_updated = 0
        local offset_x, offset_y = 0, 0
        if quad_offset[self.animation:getQuad()] then
            offset_x, offset_y = quad_offset[self.animation:getQuad()][1] or 0,
                quad_offset[self.animation:getQuad()][2] or 0
        end
        local quad, x, y, _, _, _, _, _, _, _ = self.animation:getFrameInfo(self.x + (self.offset_x or 0) + offset_x,
            self.y + (self.offset_y or 0) + offset_y - _G.state.map.walking_heightmap[self.gx][self.gy])

        local elevation_offset_y = 0
        if _G.state.map.heightmap[self.cx][self.cy][self.i][self.o] then
            elevation_offset_y = _G.state.map.heightmap[self.cx][self.cy][self.i][self.o] * 2
        end
        y = y - elevation_offset_y
        local qx, qy, qw, qh = quad:getViewport()
        self.instancemesh:setVertex(self.vert_id, x, y, qx, qy, qw, qh, 1)
        return
    end
    if not self.instancemesh and _G.state.object_mesh then
        local offset_x, offset_y = 0, 0
        if quad_offset[self.animation:getQuad()] then
            offset_x, offset_y = quad_offset[self.animation:getQuad()][1] or 0,
                quad_offset[self.animation:getQuad()][2] or 0
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
    end
end
function Tree:cut()
    if self.health > 0 then
        self.offset_x = self.base_offset_x + 4
        self.offset_timer = 0
        self.health = self.health - 1
    elseif self.health <= 0 and self.falling == false and self.chop == false and self.stump == false then
        self.offset_x = self.base_offset_x - 8
        self.offset_timer = 0
        if self.dead then
            self:finish()
            return 2
        else
            self.animation = self.falling_animation
            _G.play_sfx(self, fall_fx)
            self.falling = true
            -- We need to animate the falling even if the chunk isn't in the view
            table.insert(active_entities, self)
            if (self.cx > _G.current_chunk_x + 1) or (self.cx < _G.current_chunk_x - 1) or
                (self.cy > _G.current_chunk_y + 1) or (self.cy < _G.current_chunk_y - 1) then
                self.chop = true
                self.falling = false
            end
        end
    end
    if self.chop then
        if self.animation:getTotalFrames() ~= self.animation:getCurrentFrame() then
            self.animation:gotoFrame(self.animation:getCurrentFrame() + 1)
            self:animate(_G.dt, true)
        else
            self:finish()
            self.chop = false
            return 2
        end
    end
end
function Tree:serialize()
    local data = {}
    local object_data = Object.serialize(self)
    for k, v in pairs(object_data) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.offset_y = self.offset_y
    data.base_offset_x = self.base_offset_x
    data.offset_x = self.offset_x
    data.falling = self.falling
    data.chop = self.chop
    data.stump = self.stump
    data.type = self.type
    data.animated = self.animated
    data.marked = self.marked
    data.cuttable = self.cuttable
    data.tree = self.tree
    data.active = self.active
    data.offset_timer = self.offset_timer
    data.update_timer = self.update_timer
    data.chunk_key = self.chunk_key
    return data
end
function Tree:load(data)
    Object.initialize(self, data.gx, data.gy, data.type)
    if _G.state.chunk_objects[self.cx][self.cy] == nil then
        _G.state.chunk_objects[self.cx][self.cy] = {}
    end
    _G.state.chunk_objects[self.cx][self.cy][self] = self
    _G.addObjectAt(self.cx, self.cy, self.i, self.o, self)
end
function Tree.static:deserialize(data)
    local obj = self:new(data.gx, data.gy, data.type)
    Object.deserialize(obj, data)
    return obj
end

return Tree
