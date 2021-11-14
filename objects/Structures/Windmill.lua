local active_entities, object, tile_quads, object_batch = ...
local Structure = require("objects.Structure")

local tiles, quad_array = _G.indexBuildingQuads("windmill_whole", nil, 2)

local fr_windmill_fan = _G.indexQuads("anim_windmill_fan", 15)
local fr_anim_windmill_outside = _G.indexQuads("anim_windmill_outside", 15)
local fr_anim_windmill_inside = _G.indexQuads("anim_windmill_inside", 15)

local temp_anim = {unpack(fr_windmill_fan)}
for i = 1, 2 do
    for _, v in ipairs(temp_anim) do
        table.insert(fr_windmill_fan, v)
    end
end
temp_anim = {unpack(fr_anim_windmill_outside)}
for i = 1, 2 do
    for _, v in ipairs(temp_anim) do
        table.insert(fr_anim_windmill_outside, v)
    end
end
temp_anim = {unpack(fr_anim_windmill_inside)}
for i = 1, 2 do
    for _, v in ipairs(temp_anim) do
        table.insert(fr_anim_windmill_inside, v)
    end
end

local Windmill_blade = class('Windmill_blade', Structure)
function Windmill_blade:initialize(gx, gy, parent, offset_x, offset_y)
    local mytype = "Animation"
    Structure.initialize(self, gx, gy, mytype)
    self.tile = tile_quads["empty"]
    self.animated = true
    self.part1_end = function()
        self.parent:send_to_stockpile()
        self.animation:pause()
    end
    self.animation = anim.newAnimation(fr_windmill_fan, 0.11, self.part1_end)
    self.animation:pause()
    self.gx = gx
    self.gy = gy
    self.parent = parent
    self.qid = 0
    self.offset_x = -60
    self.offset_y = -274

    table.insert(active_entities, self)
end
function Windmill_blade:animate(dt)
    Structure.animate(self, dt, true)
end
function Windmill_blade:activate()
    self.animation:resume()
end
function Windmill_blade:deactivate()
    self.animation:pause()
end

local Windmill_shadow = class('Windmill_shadow', Structure)
function Windmill_shadow:initialize(gx, gy, parent, offset_x, offset_y)
    local mytype = "Animation"
    Structure.initialize(self, gx, gy, mytype)
    self.tile = tile_quads["empty"]
    self.animated = true
    self.part1_end = function()
        -- TODO
    end
    self.animation = anim.newAnimation(fr_anim_windmill_outside, 0.11, self.part1_end)
    self.animation:pause()
    self.gx = gx
    self.gy = gy
    self.parent = parent
    self.qid = 0
    self.offset_x = -46
    self.offset_y = -243

    table.insert(active_entities, self)
end
function Windmill_shadow:animate(dt)
    Structure.animate(self, dt, true)
end
function Windmill_shadow:activate()
    self.animation:resume()
end
function Windmill_shadow:show_inside()
    local frame = self.animation.position
    self.animation = anim.newAnimation(fr_anim_windmill_inside, 0.11)
    self.animation:gotoFrame(frame)
end
function Windmill_shadow:show_outside()
    local frame = self.animation.position
    self.animation = anim.newAnimation(fr_anim_windmill_outside, 0.11)
    self.animation:gotoFrame(frame)
    self:animate()
end
function Windmill_shadow:deactivate()
    self.animation:pause()
end

local Windmill_alias = _G.class('Windmill_alias', Structure)
function Windmill_alias:initialize(tile, gx, gy, parent, offset_y, offset_x)
    local mytype = "Static structure"
    Structure.initialize(self, gx, gy, mytype)
    self.gx = gx
    self.gy = gy
    _G.setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.qid = 0
    self.tile = tile
    self.base_offset_y = offset_y or 0
    self.additional_offset_y = 0
    self.offset_x = offset_x or 0
    self.offset_y = self.additional_offset_y - self.base_offset_y
    for k, v in ipairs(_G.stockpile.node_list) do
        if v.gx == self.gx and v.gy == self.gy then
            table.remove(_G.stockpile.node_list, k)
            break
        end
    end
    Structure.render(self)
end

local Windmill = class('Windmill', Structure)
function Windmill:initialize(gx, gy, type)
    _G.JobController:add("Miller", self)
    local mytype = "Static structure"
    Structure.initialize(self, gx, gy, mytype)
    self.gx = chunk_width * self.cx + self.i
    self.gy = chunk_width * self.cy + self.o
    setWalkable(self.gx, self.gy, 1)
    self.health = 400
    self.qid = nil
    self.tile = quad_array[tiles + 1]
    self.stone_quantity = 0
    self.working = false
    self.unloading = false
    self.offset_x = 0
    local _, _, _, lh = self.tile:getViewport()
    self.offset_y = 48 - lh
    self.level = 1
    self.rotation = 1

    -- self.stack = Windmill_plank_stack:new(self.gx, self.gy + 2, self, self.offset_x, self.offset_y)
    self.blade = Windmill_blade:new(self.gx, self.gy + 2, self, self.offset_x, self.offset_y)
    self.blade_shadow = Windmill_shadow:new(self.gx, self.gy + 2, self, self.offset_x, self.offset_y)
    -- self.log_stack = Windmill_log_stack:new(self.gx + 2, self.gy + 1, self, self.offset_x, self.offset_y)
    -- self.stack:deactivate()
    for xx = -2, 4 do
        for yy = -2, 4 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.dirt, _G.terrain_biome.abundant_grass)
        end
    end
    for xx = -1, 3 do
        for yy = -1, 3 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.scarce_grass)
        end
    end
    for tile = 1, tiles do
        Windmill_alias:new(quad_array[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offset_y + 8 * (tiles - tile + 1))
    end
    for tile = 1, tiles do
        Windmill_alias:new(quad_array[tiles + 1 + tile], self.gx + tile, self.gy, self, -self.offset_y + 8 * tile, 16)
    end

    self.free_spots = 1
    self.worker = nil
    Structure.render(self)
end
function Windmill:join(worker)
    if self.free_spots == 1 then
        self.worker = worker
        self.worker.workplace = self
        self.free_spots = self.free_spots - 1
    end
end
function Windmill:work(worker)
    if self.worker.state == "Going to workplace with wheat" then
        self.worker.state = "Working"
        self.working = true
        worker.tile = tile_quads["empty"]
        worker.animated = false
        worker.gx = self.gx + 1
        worker.gy = self.gy + 2
        worker:job_update()
        self.blade:activate()
        self.blade_shadow:activate()
        self.blade_shadow:show_inside()
    else
        self.worker.state = "Working"
        if not self.working and self.worker.state == "Working" then
            self.worker.state = "Go to stockpile for wheat"
        end
    end
end
function Windmill:send_to_stockpile()
    local i, o, cx, cy
    self.worker.state = "Go to stockpile"
    self.worker.animated = true
    self.worker.gx = self.gx + 1
    self.worker.gy = self.gy + 3
    self.worker.fx = (self.gx + 1) * 1000
    self.worker.fy = (self.gy + 3) * 1000
    i = (self.worker.gx) % (chunk_width)
    o = (self.worker.gy) % (chunk_width)
    cx = math.floor(self.worker.gx / chunk_width)
    cy = math.floor(self.worker.gy / chunk_width)
    addObjectAt(cx, cy, i, o, self.worker)
    self.working = false
    self.blade_shadow:show_outside()
    self.blade_shadow:deactivate()
end

return Windmill
