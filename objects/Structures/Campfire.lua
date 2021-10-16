local _, tile_quads, _ = ...
local Structure = require("objects.Structure")

local fr_campfire_burning = _G.indexQuads("campfire", 19, 2)

local Campfire_alias = _G.class('Campfire_alias', Structure)
function Campfire_alias:initialize(gx, gy, parent)
    Structure.initialize(self, gx, gy, "Static structure")
    self.gx = gx
    self.gy = gy
    self.tile = tile_quads["empty"]
    _G.setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    parent:take_spot(gx, gy)
end

local Campfire = _G.class('Campfire', Structure)
function Campfire:initialize(gx, gy, type)
    Structure.initialize(self, gx, gy, type or "Campfire")
    _G.setWalkable(self.gx, self.gy, 1)
    self.health = 1000
    self.qid = nil
    self.tile = tile_quads["campfire (1)"]
    self.offset_x = 0
    self.offset_y = 0
    self.animated = false
    self.peasants = 0
    self.level = 1
    self.rotation = 1
    self.hover_action = true
    self.free_spots = _G.newAutotable(2)
    self.spawn_point_x = self.gx
    self.spawn_point_y = self.gy - 3

    local ccx, ccy
    for xx = -2, 4 do
        for yy = -2, 4 do
            self.free_spots[xx][yy] = true
            ccx, ccy = _G.terrainSetTileAt(self.gx + xx, self.gy + yy, math.random(6, 8))
        end
    end
    self:take_spot(_G.spawn_point_x, _G.spawn_point_y)
    Campfire_alias:new(self.gx, self.gy - 1, self)
    Campfire_alias:new(self.gx, self.gy + 1, self)
    Campfire_alias:new(self.gx + 1, self.gy, self)
    Campfire_alias:new(self.gx + 1, self.gy - 1, self)
    Campfire_alias:new(self.gx + 1, self.gy + 1, self)
    Campfire_alias:new(self.gx + 2, self.gy, self)
    Campfire_alias:new(self.gx + 2, self.gy + 1, self)
    self:take_spot(self.gx, self.gy)
    _G.update_terrain(ccx, ccy)
    _G.campfire = self
    if _G.chunk_objects[self.cx][self.cy] == nil then
        _G.chunk_objects[self.cx][self.cy] = {}
    end
    _G.chunk_objects[self.cx][self.cy][self] = self
end
function Campfire:get_next_free_spot(peasant)
    if not self.animated then
        self.animated = true
        self.offset_y = -22
        self.animation = _G.anim.newAnimation(fr_campfire_burning, 0.1)
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
                    self.animated = false
                    self.offset_y = 0
                end
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
function Campfire:animate()
    self.animation:update(_G.dt)
end
return Campfire
