local _, tile_quads, _ = ...
local Structure = require("objects.Structure")
local Object = require("objects.Object")

local ANIM_CAMPFIRE_BURNING = "Campfire burning"

local an = {
    [ANIM_CAMPFIRE_BURNING] = _G.indexQuads("campfire", 19, 2)
}

local Campfire_alias = _G.class('Campfire_alias', Structure)
function Campfire_alias:initialize(gx, gy, parent, animated_alias)
    Structure.initialize(self, gx, gy, "Campfire alias")
    self.animated_alias = animated_alias
    self.offset_x = 0
    self.offset_y = -16
    self.tile = tile_quads["empty"]
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    parent:take_spot(gx, gy)
end
function Campfire_alias:serialize()
    local data = {}
    local struct_data = Structure.serialize(self)
    for k, v in pairs(struct_data) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.tile_key = self.tile_key
    data.base_offset_y = self.base_offset_y
    data.animated = self.animated
    data.additional_offset_y = self.additional_offset_y
    data.animated_alias = self.animated_alias
    data.offset_x = self.offset_x
    data.offset_y = self.offset_y
    if self.animation then
        data.animation = self.animation:serialize()
    end
    if not self.animated_alias then
        data.parent = _G.state:serializeObject(self.parent)
    end
    return data
end
function Campfire_alias.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    if not data.animated_alias then
        obj.parent = _G.state:dereferenceObject(data.parent)
    end
    if data.tile_key then
        obj.tile = tile_quads[data.tile_key]
        obj.tile_key = data.tile_key
        obj:render()
    end
    if data.animation then
        local an_data = data.animation
        obj.animation = _G.anim.newAnimation(an[an_data.animation_identifier], 1, nil, an_data.animation_identifier)
        obj.animation:deserialize(an_data)
    end
    return obj
end

local Campfire = _G.class('Campfire', Structure)
function Campfire:initialize(gx, gy, type)
    Structure.initialize(self, gx, gy, type or "Campfire")
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 1000
    self.tile = tile_quads["empty"]
    self.offset_x = 0
    self.offset_y = 0
    self.animated = false
    self.peasants = 0
    self.hover_action = true
    self.free_spots = _G.newAutotable(2)

    for xx = -3, 5 do
        for yy = -1, 5 do
            self.free_spots[xx][yy] = true
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.dirt)
        end
    end
    for xx = -2, 4 do
        for yy = -2, 4 do
            self.free_spots[xx][yy] = true
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.scarce_grass)
        end
    end
    _G.terrainSetTileAt(self.gx + 4, self.gy + 4, _G.terrain_biome.dirt)
    _G.terrainSetTileAt(self.gx + -2, self.gy + 4, _G.terrain_biome.dirt)
    self:take_spot(_G.spawn_point_x, _G.spawn_point_y)
    Campfire_alias:new(self.gx, self.gy - 1, self)
    Campfire_alias:new(self.gx, self.gy + 1, self)
    Campfire_alias:new(self.gx + 1, self.gy, self)
    Campfire_alias:new(self.gx + 1, self.gy - 1, self)
    self.animated_alias = Campfire_alias:new(self.gx + 1, self.gy + 1, self, true)
    self.animated_alias.tile_key = "campfire (1)"
    self.animated_alias.tile = tile_quads[self.animated_alias.tile_key]
    Campfire_alias:new(self.gx + 2, self.gy, self)
    Campfire_alias:new(self.gx + 2, self.gy + 1, self)
    self:take_spot(self.gx, self.gy)
    _G.campfire = self
    if _G.state.chunk_objects[self.animated_alias.cx][self.animated_alias.cy] == nil then
        _G.state.chunk_objects[self.animated_alias.cx][self.animated_alias.cy] = {}
    end
    _G.state.chunk_objects[self.animated_alias.cx][self.animated_alias.cy][self.animated_alias] = self.animated_alias

    Structure.render(self.animated_alias)
end
function Campfire:update()
    return
end
function Campfire:get_next_free_spot(peasant)
    if not self.animated then
        self.animated_alias.animated = true
        self.animated_alias.offset_y = -22 - 16
        self.animated_alias.animation = _G.anim.newAnimation(an[ANIM_CAMPFIRE_BURNING], 0.1, nil, ANIM_CAMPFIRE_BURNING)
    end
    for xx = -1, 3 do
        for yy = -2, 3 do
            if self.free_spots[xx][yy] == true then
                self.free_spots[xx][yy] = peasant
                self.peasants = self.peasants + 1
                return self.gx + xx, self.gy + yy, self:get_pointing_direction(self.gx + xx, self.gy + yy)
            end
        end
    end
    return false
end
function Campfire:get_free_peasant()
    for xx = -1, 3 do
        for yy = -2, 3 do
            if type(self.free_spots[xx][yy]) == "table" then
                local peasant = self.free_spots[xx][yy]
                self.free_spots[xx][yy] = true
                self.peasants = self.peasants - 1
                if self.peasants == 0 then
                    self.animated_alias.animated = false
                    self.animated_alias.offset_y = -16
                    Structure.render(self.animated_alias)
                end
                peasant.state = "Waiting"
                peasant.try_to_get_a_job = true
                return peasant
            end
        end
    end
    return false
end
function Campfire:get_pointing_direction(wx, wy)
    local fx, fy = self.gx, self.gy
    local angle = math.atan2(fy - wy, fx - wx)
    if angle < 0 then
        angle = angle + 2 * math.pi
    end
    angle = angle * (180 / math.pi)
    angle = math.round(angle)

    if angle < 0 then
        angle = 360 + angle
    end
    if (angle >= 135 + 22 and angle <= 225 - 22) then -- direction is west
        return "west"
    elseif (angle > 135 - 22 and angle < 135 + 22) then -- direction is southwest
        return "southwest"
    elseif (angle > 225 - 22 and angle < 225 + 22) then -- direction is northwest
        return "northwest"
    elseif (angle >= 225 + 22 and angle <= 315 - 22) then -- direction is north
        return "north"
    elseif (angle >= 45 + 22 and angle <= 135 - 22) then -- direction is south
        return "south"
    elseif ((angle >= 315 + 22 and angle <= 359) or (angle >= 0 and angle <= 45 - 22)) then -- direction is east
        return "east"
    elseif (angle > 45 - 22 and angle < 45 + 22) then -- direction is southeast
        return "southeast"
    elseif (angle > 315 - 22 and angle < 315 + 22) then -- direction is northeast
        return "northeast"
    end
end
function Campfire:free_spot(gx, gy)
    local x, y = -(self.gx - gx), -(self.gy - gy)
    self.free_spots[x][y] = true
end
function Campfire:take_spot(gx, gy)
    local x, y = -(self.gx - gx), -(self.gy - gy)
    self.free_spots[x][y] = false
end
function Campfire:serialize()
    local data = {}
    local struct_data = Structure.serialize(self)
    for k, v in pairs(struct_data) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.offset_x = self.offset_x
    data.offset_y = self.offset_y
    data.animated = self.animated
    data.peasants = self.peasants
    data.hover_action = self.hover_action
    data.health = self.health
    local free_spots = {}
    for xx = -3, 5 do
        free_spots[xx] = {}
        for yy = -1, 5 do
            free_spots[xx][yy] = self.free_spots[xx][yy]
            if free_spots[xx][yy] and type(free_spots[xx][yy]) ~= "boolean" then
                free_spots[xx][yy] = _G.state:serializeObject(free_spots[xx][yy])
            end
        end
    end
    for xx = -2, 4 do
        free_spots[xx] = {}
        for yy = -2, 4 do
            free_spots[xx][yy] = self.free_spots[xx][yy]
            if free_spots[xx][yy] and type(free_spots[xx][yy]) ~= "boolean" then
                free_spots[xx][yy] = _G.state:serializeObject(free_spots[xx][yy])
            end
        end
    end
    data.animated_alias = _G.state:serializeObject(self.animated_alias)
    data.free_spots = free_spots
    return data
end
function Campfire.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end
function Campfire:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    self.free_spots = _G.newAutotable(2)
    for xx = -3, 5 do
        for yy = -1, 5 do
            self.free_spots[xx][yy] = data.free_spots[xx][yy]
            if type(self.free_spots[xx][yy]) == "table" then
                self.free_spots[xx][yy] = _G.state:dereferenceObject(self.free_spots[xx][yy])
            end
        end
    end
    for xx = -2, 4 do
        for yy = -2, 4 do
            self.free_spots[xx][yy] = data.free_spots[xx][yy]
            if type(self.free_spots[xx][yy]) == "table" then
                self.free_spots[xx][yy] = _G.state:dereferenceObject(self.free_spots[xx][yy])
            end
        end
    end
    self.animated_alias = _G.state:dereferenceObject(data.animated_alias)
    self.animated_alias.parent = self
    _G.campfire = self
    if _G.state.chunk_objects[self.animated_alias.cx][self.animated_alias.cy] == nil then
        _G.state.chunk_objects[self.animated_alias.cx][self.animated_alias.cy] = {}
    end
    _G.state.chunk_objects[self.animated_alias.cx][self.animated_alias.cy][self.animated_alias] = self.animated_alias
    Structure.render(self.animated_alias)
end

return Campfire
