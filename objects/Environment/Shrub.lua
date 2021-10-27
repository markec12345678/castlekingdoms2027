local object_batch, active_objects, tile_quads, object = ...
local Object = require("objects.Object")

local fr_shrub_1 = indexQuads("tree_shrub1", 25, nil, true)
local fr_shrub_2 = indexQuads("tree_shrub2", 25, nil, true)

local Shrub = class('Shrub', Object)
function Shrub:initialize(gx, gy, type)
    Object.initialize(self, gx, gy, type)
    self.gx = chunk_width * self.cx + self.i -- warning fucking genius
    self.gy = chunk_width * self.cy + self.o
    self.health = 1
    if not type then
        if love.math.random(0, 1) == 0 then
            type = "Tall shrub"
        else
            type = "Short shrub"
        end
    end
    if type == "Tall shrub" then
        self.animation = anim.newAnimation(fr_shrub_1, 0.1)
        self.offset_x = -32
        self.offset_y = -57
    elseif type == "Short shrub" then
        self.animation = anim.newAnimation(fr_shrub_2, 0.1)
        self.offset_x = -11
        self.offset_y = -32
    end
    self.chop = false
    self.animated = true
    self.marked = false
    self.tile = nil
    self.active = false
    self.update_timer = 0
    self.chunk_key = false
    if _G.chunk_objects[self.cx][self.cy] == nil then
        _G.chunk_objects[self.cx][self.cy] = {}
    end
    _G.chunk_objects[self.cx][self.cy][self] = self
end
function Shrub:animate()
    if _G.scale_x > 0.6 then
        self.animation:update(dt)
    elseif _G.scale_x > 0.4 then
        self.update_timer = self.update_timer + 1
        if self.update_timer == 10 then
            self.animation:update(dt)
            self.animation:update(dt)
            self.update_timer = 0
        end
    end
end
function Shrub:destroy()
    removeObjectAt(self.cx, self.cy, self.i, self.o, self)
    _G.chunk_objects[self.cx][self.cy][self] = nil
    self = nil
end
function Shrub:cut()
    if self.health > 0 then
        status[self.cx][self.cy] = 1
        self.offset_x = self.base_offset_x + 4
        self.offset_timer = 0
        self.health = self.health - 1
    elseif self.health <= 0 then
        self:destroy()
    end
end

return Shrub
