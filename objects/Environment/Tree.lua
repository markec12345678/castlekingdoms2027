local object_batch, active_objects, tile_quads, object = ...
local Object = require("objects.Object")

local Tree = class('Tree', Object)
function Tree:initialize(gx, gy, type)
    Object.initialize(self, gx, gy, type)
    self.gx = chunk_width * self.cx + self.i -- warning fucking genius
    self.gy = chunk_width * self.cy + self.o
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
    self.update_timer = 0
    self.chunk_key = false
    self.trunk_tile = tile_quads["empty"]
    self.cut_down = function()
        self.falling = false
        self.chop = true
        self.animation = self.chop_animation
        self.animation:pause()
    end
    self.finish = function() -- TODO: turn into stump object
        self.animation = anim.newAnimation({self.trunk_tile}, 0.1)
        self.animation:pause()
        self.stump = true
        self.animation:update(dt)
        self.animated = false -- mark for removal from list
        self:animate() -- animate, because the list will remove us before we show the stump
        self.type = "Stump"
        self.tile = self.trunk_tile
        for xx = -1, 1 do
            for yy = -1, 1 do
                _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.dirt, _G.terrain_biome.scarce_grass)
            end
        end
        -- self:destroy()
    end
    if self.gx < 2048 and self.gx >= 0 and self.gy < 2048 and self.gy >= 0 then
        _G.collision_map[self.gx][self.gy] = 1
        setWalkable(self.gx, self.gy, 1)
    end
    if _G.chunk_objects[self.cx][self.cy] == nil then
        _G.chunk_objects[self.cx][self.cy] = {}
    end
    _G.chunk_objects[self.cx][self.cy][self] = self
    addObjectAt(self.cx, self.cy, self.i, self.o, self)
end
function Tree:animate()
    if _G.scale_x > 0.6 then
        self.animation:update(dt)
        self.offset_timer = self.offset_timer + 1
        if self.offset_timer > 4 then
            self.offset_x = self.base_offset_x
        end
    elseif _G.scale_x > 0.3 then
        self.update_timer = self.update_timer + 1
        if self.update_timer == 10 then
            self.animation:update(dt)
            self.animation:update(dt)
            self.update_timer = 0
        end
    end
end
function Tree:destroy()
    removeObjectAt(self.cx, self.cy, self.i, self.o, self)
    _G.chunk_objects[self.cx][self.cy][self] = nil
    self = nil
end
function Tree:cut()
    if self.health > 0 then
        status[self.cx][self.cy] = 1
        self.offset_x = self.base_offset_x + 4
        self.offset_timer = 0
        self.health = self.health - 1
    elseif self.health <= 0 and self.falling == false and self.chop == false and self.stump == false then
        status[self.cx][self.cy] = 1
        self.offset_x = self.base_offset_x - 8
        self.offset_timer = 0
        if self.dead then
            self.finish()
            return 2
        else
            self.animation = self.falling_animation
            self.falling = true
            if (self.cx > current_chunk_x + 1) or (self.cx < current_chunk_x - 1) or (self.cy > current_chunk_y + 1) or
                (self.cy < current_chunk_y - 1) then
                self.chop = true
                self.falling = false
            end
        end
    end
    if self.chop then
        status[self.cx][self.cy] = 1
        if self.animation:getTotalFrames() ~= self.animation:getCurrentFrame() then
            self.animation:gotoFrame(self.animation:getCurrentFrame() + 1)
        else
            self.finish()
            self.chop = false
            return 2
        end
    end
end

return Tree
