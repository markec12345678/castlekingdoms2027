local active_entities, object, tile_quads, object_batch = ...
local Structure = require("objects.Structure")

local tiles, quad_array = indexBuildingQuads("iron_mine")
local fr_pouring = indexQuads("anim_iron_miner_pour", 20)
local fr_bucket = indexQuads("anim_iron_miner_pull", 8)
local fr_casting_iron = indexQuads("anim_iron_miner_cast", 24)
local fr_miner_going_down = indexQuads("anim_iron_miner_hole", 38)
local fr_miner_going_up = reverse(indexQuads("anim_iron_miner_hole", 38))
local fr_miner_pulling = indexQuads("anim_iron_miner_rope", 12)
local fr_stack = indexQuads("anim_iron_miner_stack", 8)
-- extra 2 loops on this animation
local fr_tunnel_glow = indexQuads("anim_iron_miner_glow", 8, nil, true)
local temp_anim = {unpack(fr_tunnel_glow)}
for i = 1, 2 do
    for _, v in ipairs(temp_anim) do
        table.insert(fr_tunnel_glow, v)
    end
end

local function reverse_table(t)
    local reversed = {}
    local count = #t
    for idx, v in ipairs(t) do
        reversed[count + 1 - idx] = v
    end
    return reversed
end

local fr_chimney_glow = indexQuads("anim_iron_miner_chimney_glow", 8, nil)
local fr_reverse_chimney_glow = reverse_table(fr_chimney_glow)
local fr_chimney_smoke = indexQuads("anim_iron_miner_smoke", 28)
local Mine_going_down = class('Mine_going_down', Structure)
function Mine_going_down:initialize(gx, gy, parent, offset_x, offset_y)
    local mytype = "Iron mine up/down"
    local going_anim_offset_x, going_anim_offset_y = 13 + offset_x - 48, 6 + offset_y - 32 - 16
    local tunnel_anim_offset_x, tunnel_anim_offset_y = 13 + offset_x - 48, -72
    Structure.initialize(self, gx, gy, mytype)
    self.animated = true
    self.anim_end = function()
        self.animation:pause()
        self:deactivate()
        self.parent.puller:activate()
        self.parent.bucket:activate()
    end
    self.part2_end = function()
        self.offset_x, self.offset_y = going_anim_offset_x, going_anim_offset_y
        self.animation = anim.newAnimation(fr_miner_going_up, 0.11, self.anim_end)
    end
    self.part1_end = function()
        self.offset_x, self.offset_y = tunnel_anim_offset_x, tunnel_anim_offset_y
        self.animation = anim.newAnimation(fr_tunnel_glow, 0.11, self.part2_end)
    end
    self.animation = anim.newAnimation(fr_miner_going_down, 0.11, self.part1_end)
    self.gx = gx
    self.gy = gy
    setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.qid = 0
    self.offset_x = 13 + offset_x - 48
    self.offset_y = 6 + offset_y - 32 - 16

    table.insert(active_entities, self)
end
function Mine_going_down:animate(dt)
    Structure.animate(self, dt, true)
end
function Mine_going_down:activate()
    self.animated = true
    self.animation = anim.newAnimation(fr_miner_going_down, 0.11, self.part1_end)
    self:animate()
end
function Mine_going_down:deactivate()
    self.animation:pause()
    self.tile = tile_quads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vert_id)
        self.instancemesh = nil
    end
    self.animated = false
end

local Mine_puller = class('Mine_puller', Structure)
function Mine_puller:initialize(gx, gy, parent, offset_x, offset_y)
    local mytype = "Puller"
    Structure.initialize(self, gx, gy, mytype)
    self.animated = true
    self.part1_end = function()
        self.animation:pause()
        self.parent.pourer:activate()
        self:deactivate()
        self.parent.bucket:deactivate()
    end
    self.animation = anim.newAnimation(fr_miner_pulling, 0.11, self.part1_end)
    self.animation:pause()
    self.gx = gx
    self.gy = gy
    setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.qid = 0
    self.offset_x = 13 + offset_x + 32 + 32 - 48
    self.offset_y = -2 + offset_y - 32 + 8

    table.insert(active_entities, self)
end
function Mine_puller:animate(dt)
    Structure.animate(self, dt, true)
end
function Mine_puller:activate()
    self.animated = true
    self.animation:resume()
    self:animate()
end
function Mine_puller:deactivate()
    self.animation:pause()
    self.tile = tile_quads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vert_id)
        self.instancemesh = nil
    end
    self.animated = false
end
local Mine_bucket = class('Mine_bucket', Structure)
function Mine_bucket:initialize(gx, gy, parent, offset_x, offset_y)
    local mytype = "Hook"
    Structure.initialize(self, gx, gy, mytype)
    self.animated = true
    self.part1_end = function()
        self.parent.shaper:activate()
    end
    self.animation = anim.newAnimation(fr_bucket, 0.19)
    self.animation:pause()
    self.gx = gx
    self.gy = gy
    setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.qid = 0
    self.offset_x = -3 + offset_x + 48 + 32 - 48
    self.offset_y = -8 + offset_y - 32

    table.insert(active_entities, self)
end
function Mine_bucket:animate(dt)
    Structure.animate(self, dt, true)
end
function Mine_bucket:activate()
    self.animated = true
    self.animation:gotoFrame(1)
    self.animation:resume()
    self:animate()
end
function Mine_bucket:deactivate()
    self.animation:pause()
    self.tile = tile_quads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vert_id)
        self.instancemesh = nil
    end
    self.animated = false
end

local Mine_pourer = class('Mine_pourer', Structure)
function Mine_pourer:initialize(gx, gy, parent, offset_x, offset_y)
    local mytype = "Animation"
    Structure.initialize(self, gx, gy, mytype)
    self.animated = true
    self.part1_end = function()
        self.animation = anim.newAnimation({tile_quads["anim_iron_miner_pour (20)"]}, 0.1, self.part2_end)
        self.parent.casting:activate()
        if self.parent.stack.quantity < 7 then
            self.parent.going_down:activate()
        else
            self.parent.unloading = true
            self.parent:send_to_stockpile()
        end
    end
    self.animation = anim.newAnimation(fr_pouring, 0.11, self.part1_end)
    self.animation:pause()
    self.gx = gx
    self.gy = gy
    setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.qid = 0
    self.offset_x = 13 + offset_x + 48 + 32 - 48
    self.offset_y = -13 + offset_y - 16

    table.insert(active_entities, self)
end
function Mine_pourer:animate(dt)
    Structure.animate(self, dt, true)
end
function Mine_pourer:activate()
    self.animation = anim.newAnimation(fr_pouring, 0.11, self.part1_end)
    self.animated = true
    self.animation:gotoFrame(1)
    self.animation:resume()
    self:animate()
end
function Mine_pourer:deactivate()
    self.animation:pause()
    self.tile = tile_quads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vert_id)
        self.instancemesh = nil
    end
    self.animated = false
end
local Mine_casting = class('Mine_casting', Structure)
function Mine_casting:initialize(gx, gy, parent, offset_x, offset_y)
    local mytype = "Animation"
    Structure.initialize(self, gx, gy, mytype)
    local cast_x, cast_y = 49 + offset_x - 16 - 48, 11 + offset_y - 64
    local chimney_x, chimney_y = -15, -96
    local smoke_x, smoke_y = -10, -165
    self.animated = true
    self.part4_end = function()
        if not self.parent.stack.animated then
            self.parent.stack:activate()
        end
        self.parent.stack:stack()
        self.animation = anim.newAnimation(fr_chimney_glow, 0.11, self.part1_end)
        self.animation:pause()
        self:deactivate()
    end
    self.part3_end = function()
        self.offset_x, self.offset_y = cast_x, cast_y
        self.animation = anim.newAnimation(fr_casting_iron, 0.11, self.part4_end)
    end
    self.part2_end = function()
        self.offset_x, self.offset_y = chimney_x, chimney_y
        self.animation = anim.newAnimation(fr_reverse_chimney_glow, 0.11, self.part3_end)
    end
    self.part1_end = function()
        self.offset_x, self.offset_y = smoke_x, smoke_y
        self.animation = anim.newAnimation(fr_chimney_smoke, 0.11, self.part2_end)
    end
    self.animation = anim.newAnimation(fr_chimney_glow, 0.11, self.part1_end)
    self.animation:pause()
    self.gx = gx
    self.gy = gy
    setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.qid = 0
    self.offset_x, self.offset_y = chimney_x, chimney_y

    table.insert(active_entities, self)
end
function Mine_casting:animate(dt)
    Structure.animate(self, dt, true)
end
function Mine_casting:activate()
    self.animated = true
    self.animation:gotoFrame(1)
    self.animation:resume()
    self:animate()
end
function Mine_casting:deactivate()
    self.animation:pause()
    self.tile = tile_quads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vert_id)
        self.instancemesh = nil
    end
    self.animated = false
end
local Mine_stack = class('Mine_stack', Structure)
function Mine_stack:initialize(gx, gy, parent, offset_x, offset_y)
    local mytype = "Animation"
    Structure.initialize(self, gx, gy, mytype)
    self.animated = true
    self.part1_end = function()
        -- self.parent.stack:activate()			
    end
    self.animation = anim.newAnimation(fr_stack, 0.11, self.part1_end)
    self.animation:pause()
    self.quantity = 0
    self.gx = gx
    self.gy = gy
    setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.qid = 0
    self.offset_x = 49 + offset_x - 16 - 48
    self.offset_y = 11 + offset_y - 32 - 8 + 3

    table.insert(active_entities, self)
end
function Mine_stack:stack()
    self.quantity = self.quantity + 1
    self.animation:gotoFrame(self.quantity)
end
function Mine_stack:animate(dt)
    Structure.animate(self, dt, true)
end
function Mine_stack:activate()
    self.animated = true
    self.animation:gotoFrame(1)
    self.animation:pause()
    self:animate()
end
function Mine_stack:deactivate()
    self.animation:pause()
    self.tile = tile_quads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vert_id)
        self.instancemesh = nil
    end
    self.animated = false
end
function Mine_stack:take()
    self.quantity = self.quantity - 1
    if self.quantity == 0 then
        self:deactivate()
        self.parent.unloading = false
        return
    end
    self.animation:gotoFrame(self.quantity)
end
local Mine_alias = class('Mine_alias', Structure)
function Mine_alias:initialize(tile, gx, gy, parent, offset_y, offset_x)
    local mytype = "Static structure"
    Structure.initialize(self, gx, gy, mytype)
    self.gx = gx
    self.gy = gy
    setWalkable(self.gx, self.gy, 1)
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
    self:render()
end

local Mine = class('Mine', Structure)
function Mine:initialize(gx, gy, type)
    _G.JobController:add("Miner", self)
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
    self.offset_y = -64 + 16 + 4

    self.pourer = Mine_pourer:new(self.gx + 1, self.gy + 1, self, self.offset_x - 64 - 16, self.offset_y)
    self.pourer:deactivate()
    self.going_down = Mine_going_down:new(self.gx + 3, self.gy + 3, self, self.offset_x, self.offset_y)
    self.going_down:deactivate()
    self.puller = Mine_puller:new(self.gx + 2, self.gy + 1, self, self.offset_x - 64 - 16, self.offset_y)
    self.puller:deactivate()
    self.bucket = Mine_bucket:new(self.gx + 2, self.gy + 2, self, self.offset_x - 64 - 16, self.offset_y)
    self.bucket:deactivate()
    self.casting = Mine_casting:new(self.gx + 2, self.gy + 3, self, self.offset_x, self.offset_y)
    self.casting:deactivate()
    self.stack = Mine_stack:new(self.gx + 3, self.gy + 2, self, self.offset_x, self.offset_y)
    self.stack:deactivate()

    for tile = 1, tiles do
        Mine_alias:new(quad_array[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offset_y + 8 * (tiles - tile + 1))
    end

    for tile = 1, tiles do
        Mine_alias:new(quad_array[tiles + 1 + tile], self.gx + tile, self.gy, self, -self.offset_y + 8 * tile, 16)
    end

    for xx = 0, 3 do
        for yy = 0, 3 do
            removeObjectFromClassAtGlobal(self.gx + xx, self.gy + yy, "Iron")
        end
    end

    Mine_alias:new(tile_quads["empty"], self.gx + 1, self.gy + 3, self, 12 + 8 * 4, 16)
    Mine_alias:new(tile_quads["empty"], self.gx + 3, self.gy + 1, self, 12 + 8 * 4, 16)

    self.free_spots = 1
    self.worker = nil
    self:render()
end
function Mine:join(worker)
    if self.free_spots == 1 then
        self.worker = worker
        worker.workplace = self
        self.free_spots = self.free_spots - 1
    end
end
function Mine:work(worker)
    if self.unloading then
        self.worker.state = "Go to stockpile"
        self.stack:take()
        return
    end
    worker.state = "Working"
    worker.tile = tile_quads["empty"]
    worker.animated = false
    worker.gx = self.gx + 1
    worker.gy = self.gy + 2
    worker:job_update()

    if not self.working and self.worker.state == "Working" then
        self.working = true
        self.going_down:activate()
    end
end
function Mine:send_to_stockpile()
    local i, o, cx, cy
    self.worker.state = "Go to stockpile"
    self.worker.animated = true
    self.worker.gx = self.gx - 1
    self.worker.gy = self.gy + 1
    self.worker.fx = (self.gx - 1) * 1000 + 500
    self.worker.fy = (self.gy + 1) * 1000 + 500
    i = (self.worker.gx) % (chunk_width)
    o = (self.worker.gy) % (chunk_width)
    cx = math.floor(self.worker.gx / chunk_width)
    cy = math.floor(self.worker.gy / chunk_width)
    addObjectAt(cx, cy, i, o, self.worker)
    self.stack:take()
    self.going_down:deactivate()
    self.working = false
end

return Mine
