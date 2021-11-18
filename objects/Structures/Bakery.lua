local active_entities, object, tile_quads, object_batch = ...
local Structure = require("objects.Structure")

local tiles, quad_array = _G.indexBuildingQuads("bakery_workshop (18)", true)

local fr_baking_bread = _G.indexQuads("anim_baker", 53)
local fr_baking_bread_part2 = _G.indexQuads("anim_baker", 64, 54)
local fr_bread_stack = _G.indexQuads("anim_baker_bread", 4)

local Bakery_log_stack = class('Bakery_log_stack', Structure)

local Bakery_bread_stack = class('Bakery_bread_stack', Structure)
function Bakery_bread_stack:initialize(gx, gy, parent, offset_x, offset_y)
    local mytype = "Animation"
    Structure.initialize(self, gx, gy, mytype)
    self.tile = tile_quads["empty"]
    self.animated = false
    self.animation = anim.newAnimation(fr_bread_stack, 0.11)
    self.animation:pause()
    self.quantity = 0
    self.gx = gx
    self.gy = gy
    setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.qid = 0
    self.offset_x = -24
    self.offset_y = -94

    table.insert(active_entities, self)
end
function Bakery_bread_stack:stack()
    self.quantity = self.quantity + 1
    self.animation:gotoFrame(self.quantity)
    self:animate(_G.dt, true)
end
function Bakery_bread_stack:animate(dt)
    Structure.animate(self, dt, true)
end
function Bakery_bread_stack:activate()
    self.animated = true
    self.quantity = 1
    self.animation:gotoFrame(1)
    self.animation:pause()
    self:animate()
end
function Bakery_bread_stack:deactivate()
    self.animation:pause()
    self.quantity = 0
    self.tile = tile_quads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vert_id)
        self.instancemesh = nil
    end
    self.animated = false
end
function Bakery_bread_stack:take()
    self.quantity = self.quantity - 4
    if self.quantity == 0 then
        self:deactivate()
        self.parent.unloading = false
        return
    end
    self.animation:gotoFrame(self.quantity)
end

local Bakery_cooking = class('Bakery_cooking', Structure)
function Bakery_cooking:initialize(gx, gy, parent, offset_x, offset_y)
    local mytype = "Animation"
    Structure.initialize(self, gx, gy, mytype)
    self.tile = tile_quads["empty"]
    self.animated = false
    self.part2_end = function()
        self.animation = anim.newAnimation(fr_baking_bread, 0.11, self.part1_end)
        if self.parent.stack.quantity == 4 then
            self.parent:send_to_stockpile()
            self:deactivate()
        end
    end
    self.part1_end = function()
        if not self.parent.stack.animated then
            self.parent.stack:activate()
        else
            self.parent.stack:stack()
        end
        self.animation = anim.newAnimation(fr_baking_bread_part2, 0.11, self.part2_end)
    end
    self.animation = anim.newAnimation(fr_baking_bread, 0.11, self.part1_end)
    self.animation:pause()
    self.gx = gx
    self.gy = gy
    setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.qid = 0
    self.offset_x = -36
    self.offset_y = -88

    table.insert(active_entities, self)
end
function Bakery_cooking:animate(dt)
    Structure.animate(self, _G.dt, true)
end
function Bakery_cooking:activate()
    self.animated = true
    self.animation:gotoFrame(1)
    self.animation:resume()
    self:animate(_G.dt)
end
function Bakery_cooking:deactivate()
    self.animation:pause()
    self.tile = tile_quads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vert_id)
        self.instancemesh = nil
    end
    self.animated = false
end

local Bakery_alias = _G.class('Bakery_alias', Structure)
function Bakery_alias:initialize(tile, gx, gy, parent, offset_y, offset_x)
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

local Bakery = class('Bakery', Structure)
function Bakery:initialize(gx, gy, type)
    _G.JobController:add("Baker", self)
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
    self.offset_y = 64 - 131
    self.level = 1
    self.rotation = 1

    self.cooking_obj = Bakery_cooking:new(self.gx + 3, self.gy + 2, self, self.offset_x, self.offset_y)
    self.stack = Bakery_bread_stack:new(self.gx + 3, self.gy + 3, self, self.offset_x, self.offset_y)

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
        Bakery_alias:new(quad_array[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offset_y + 8 * (tiles - tile + 1))
    end
    for tile = 1, tiles do
        Bakery_alias:new(quad_array[tiles + 1 + tile], self.gx + tile, self.gy, self, -self.offset_y + 8 * tile, 16)
    end

    self.free_spots = 1
    self.worker = nil
    Structure.render(self)
end
function Bakery:join(worker)
    if self.free_spots == 1 then
        self.worker = worker
        self.worker.workplace = self
        self.free_spots = self.free_spots - 1
    end
end
function Bakery:work(worker)
    if self.worker.state == "Going to workplace with flour" then
        self.worker.state = "Working"
        self.working = true
        worker.tile = tile_quads["empty"]
        worker.animated = false
        worker.gx = self.gx + 1
        worker.gy = self.gy + 2
        worker:job_update()
        self.cooking_obj:activate()
    else
        self.worker.state = "Working"
        if not self.working and self.worker.state == "Working" then
            self.worker.state = "Go to stockpile for flour"
        end
    end
end
function Bakery:send_to_stockpile()
    local i, o, cx, cy
    self.worker.state = "Go to granary"
    self.worker.animated = true
    self.worker.gx = self.gx + 1
    self.worker.gy = self.gy + 4
    self.worker.fx = self.worker.gx * 1000
    self.worker.fy = self.worker.gy * 1000
    i = (self.worker.gx) % (chunk_width)
    o = (self.worker.gy) % (chunk_width)
    cx = math.floor(self.worker.gx / chunk_width)
    cy = math.floor(self.worker.gy / chunk_width)
    addObjectAt(cx, cy, i, o, self.worker)
    self.working = false
    self.worker.need_new_vert_asap = true
    self.cooking_obj:deactivate()
    self.stack:take()
end

return Bakery
