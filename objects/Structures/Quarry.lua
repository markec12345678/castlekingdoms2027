local active_entities, object, tile_quads, object_batch = ...
local Structure = require("objects.Structure")
local tiles, quad_array = indexBuildingQuads("stone_quarry")

local fr_lifter_part1 = indexQuads("anim_quarry_lower", 17)
local fr_lifter_part2 = indexQuads("anim_quarry_lower", 20 + 18, 18)
local fr_lifter_part3 = indexQuads("anim_quarry_lower", 31 + 18 + 20, 18 + 20)
local fr_hook_part1 = indexQuads("anim_quarry_hook", 44)
table.insert(fr_hook_part1, 1, tile_quads["anim_quarry_hook_empty (1)"])
local fr_hook_part2 = indexQuads("anim_quarry_hook", 17 + 45, 45)
local fr_shaper = indexQuads("anim_quarry_cut", 131)

local fr_puller_part2 = {}
fr_puller_part2 = indexQuads("anim_quarry_pull", 42 + 20, 20)
local fr_puller_part1 = {}
fr_puller_part1 = indexQuads("anim_quarry_pull", 19)
local Quarry_lifter = class('Quarry_lifter', Structure)
function Quarry_lifter:initialize(gx, gy, parent, offset_x, offset_y)
    local mytype = "Lifter"
    local i = (gx) % (chunk_width)
    local o = (gy) % (chunk_width)
    local cx = math.floor(gx / chunk_width)
    local cy = math.floor(gy / chunk_width)
    local x = IsoX + (i - o) * tile_width * 0.5
    local y = IsoY + (i + o) * tile_height * 0.5
    Structure.initialize(self, gx, gy, mytype)
    self.animated = true
    self.part3_end = function()
        self.animation = anim.newAnimation(fr_lifter_part1, 0.10, function()
            self.animation:gotoFrame(1)
        end)
        self.animation:pause()
    end
    self.part2_end = function()
        self.animation = anim.newAnimation(fr_lifter_part3, 0.10, self.part3_end)
    end
    self.part1_end = function()
        self.parent.puller:activate()
        self.parent.hook:activate()
        self.animation = anim.newAnimation(fr_lifter_part2, 0.10, self.part2_end)
    end
    self.animation = anim.newAnimation(fr_lifter_part1, 0.10, self.part1_end) -- , 'pauseAtEnd')
    self.gx = gx
    self.gy = gy
    setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.qid = 0
    self.offset_x = 48 + offset_x
    self.offset_y = 74 + offset_y - 64 + 32
    addObjectAt(cx, cy, i, o, self)
    table.insert(active_entities, self)
end
function Quarry_lifter:animate()
    self.animation:update(dt)
end
function Quarry_lifter:activate()
    self.animated = true
    self.animation = anim.newAnimation(fr_lifter_part1, 0.11, self.part1_end)
end
function Quarry_lifter:deactivate()
    self.animation:pause()
    self.tile = tile_quads["empty"]
    self.animated = false
end

local Quarry_hook = class('Quarry_hook', Structure)
function Quarry_hook:initialize(gx, gy, parent, offset_x, offset_y)
    local mytype = "Hook"
    local i = (gx) % (chunk_width)
    local o = (gy) % (chunk_width)
    local cx = math.floor(gx / chunk_width)
    local cy = math.floor(gy / chunk_width)
    local x = IsoX + (i - o) * tile_width * 0.5
    local y = IsoY + (i + o) * tile_height * 0.5
    Structure.initialize(self, gx, gy, mytype)
    self.animated = true
    self.part2_end = function()
        self.animation = anim.newAnimation(fr_hook_part1, 0.11, self.part1_end)
        self.animation:pause()
        -- self.parent.shaper.animation = anim.newAnimation(fr_shaper_part2,0.11,self.parent.shaper.anim_end)
    end
    self.part1_end = function()
        self.parent.shaper:activate()
        self.animation = anim.newAnimation(fr_hook_part2, 0.12, self.part2_end)
    end
    self.animation = anim.newAnimation(fr_hook_part1, 0.11, self.part1_end)
    self.animation:pause()
    self.gx = gx
    self.gy = gy
    setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.qid = 0
    self.offset_x = 32 + offset_x
    self.offset_y = 57 + offset_y - 15
    addObjectAt(cx, cy, i, o, self)
    table.insert(active_entities, self)
end
function Quarry_hook:animate()
    self.animation:update(dt)
end
function Quarry_hook:activate()
    self.animation:gotoFrame(2)
    self.animation:resume()
end

local Quarry_shaper = class('Quarry_shaper', Structure)
function Quarry_shaper:initialize(gx, gy, parent, offset_x, offset_y)
    local mytype = "Shaper"
    local i = (gx) % (chunk_width)
    local o = (gy) % (chunk_width)
    local cx = math.floor(gx / chunk_width)
    local cy = math.floor(gy / chunk_width)
    local x = IsoX + (i - o) * tile_width * 0.5
    local y = IsoY + (i + o) * tile_height * 0.5
    Structure.initialize(self, gx, gy, mytype)
    self.animated = true
    self.anim_end = function()
        self.parent.lifter:activate()
        self.animation:gotoFrame(1)
        self.animation:pause()
        self.parent.stone_quantity = self.parent.stone_quantity + 1
        if self.parent.stone_quantity == 3 then
            self.parent:send_to_stockpile()
        end
    end
    self.animation = anim.newAnimation(fr_shaper, 0.05, self.anim_end)
    self.animation:pause()
    self.gx = gx
    self.gy = gy
    setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.qid = 0
    self.offset_x = -15 + offset_x
    self.offset_y = 57 + offset_y - 2
    addObjectAt(cx, cy, i, o, self)
    table.insert(active_entities, self)
end
function Quarry_shaper:animate()
    self.animation:update(dt)
end
function Quarry_shaper:activate()
    self.animated = true
    self.animation:resume()
end
function Quarry_shaper:deactivate()
    self.animation:pause()
    self.tile = tile_quads["empty"]
    self.animated = false
end

local Quarry_puller = class('Quarry_puller', Structure)
function Quarry_puller:initialize(gx, gy, parent, offset_x, offset_y)
    local mytype = "Puller"
    local i = (gx) % (chunk_width)
    local o = (gy) % (chunk_width)
    local cx = math.floor(gx / chunk_width)
    local cy = math.floor(gy / chunk_width)
    local x = IsoX + (i - o) * tile_width * 0.5
    local y = IsoY + (i + o) * tile_height * 0.5
    Structure.initialize(self, gx, gy, mytype)
    self.animated = true
    self.anim_end = function()
        self.animation = anim.newAnimation(fr_puller_part1, 0.11, self.part1_end)
        self.animation:gotoFrame(1)
        self.animation:pause()
    end
    self.part1_end = function()
        self.animation = anim.newAnimation(fr_puller_part2, 0.11, self.anim_end)
    end
    self.animation = anim.newAnimation(fr_puller_part1, 0.11, self.part1_end)
    self.animation:pause()
    self.gx = gx
    self.gy = gy
    setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.qid = 0
    self.offset_x = 92 + offset_x - 16 - 16
    self.offset_y = 58 + offset_y - 32 - 16
    addObjectAt(cx, cy, i, o, self)
    table.insert(active_entities, self)
end
function Quarry_puller:animate()
    self.animation:update(dt)
end
function Quarry_puller:activate()
    self.animated = true
    self.animation:resume()
end
function Quarry_puller:deactivate()
    self.tile = tile_quads["empty"]
    self.animated = false
end
local Quarry_alias = class('Quarry_alias', Structure)
function Quarry_alias:initialize(tile, gx, gy, parent, offset_y, offset_x)
    local mytype = "Static structure"
    local i = (gx) % (chunk_width)
    local o = (gy) % (chunk_width)
    local cx = math.floor(gx / chunk_width)
    local cy = math.floor(gy / chunk_width)
    local x = IsoX + (i - o) * tile_width * 0.5
    local y = IsoY + (i + o) * tile_height * 0.5
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
    addObjectAt(cx, cy, i, o, self)
end

local Quarry = class('Quarry', Structure)
function Quarry:initialize(gx, gy, type)
    _G.JobController:add("Stonemason", self)
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
    self.offset_x = 0
    self.offset_y = -7 * 16 - 6
    self.level = 1
    self.rotation = 1
    self.lifter = Quarry_lifter:new(self.gx + 3, self.gy + 3, self, self.offset_x - 64 - 16, self.offset_y)
    self.lifter:deactivate()
    self.shaper = Quarry_shaper:new(self.gx + 2, self.gy + 2, self, self.offset_x - 64 - 16, self.offset_y)
    self.shaper:deactivate()
    self.puller = Quarry_puller:new(self.gx + 4, self.gy + 2, self, self.offset_x - 64 - 16, self.offset_y)
    self.puller:deactivate()
    self.hook = Quarry_hook:new(self.gx + 1, self.gy + 1, self, self.offset_x - 64 - 16, self.offset_y)
    for xx = -1, 6 do
        for yy = -1, 6 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.dirt)
        end
    end

    for tile = 1, tiles do
        Quarry_alias:new(quad_array[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offset_y + 8 * (tiles - tile + 1))
    end

    for tile = 1, tiles do
        Quarry_alias:new(quad_array[tiles + 1 + tile], self.gx + tile, self.gy, self, -self.offset_y + 8 * tile, 14)
    end
    -- Quarry_alias:new(tile_quads[2302],self.gx,self.gy+5,self,118+8*5)				
    -- Quarry_alias:new(tile_quads[2303],self.gx,self.gy+4,self,118+8*4)
    -- Quarry_alias:new(tile_quads[2304],self.gx,self.gy+3,self,118+8*3)
    -- Quarry_alias:new(tile_quads[2305],self.gx,self.gy+2,self,118+8*2)
    -- Quarry_alias:new(tile_quads[2306],self.gx,self.gy+1,self,118+8*1)

    -- Quarry_alias:new(tile_quads[2308],self.gx+1,self.gy,self,118+8*1,14)
    -- Quarry_alias:new(tile_quads[2309],self.gx+2,self.gy,self,118+8*2,14)
    -- Quarry_alias:new(tile_quads[2310],self.gx+3,self.gy,self,118+8*3,14)
    -- Quarry_alias:new(tile_quads[2311],self.gx+4,self.gy,self,118+8*4,14)
    -- Quarry_alias:new(tile_quads[2312],self.gx+5,self.gy,self,118+8*5,14)

    Quarry_alias:new(tile_quads["empty"], self.gx + 5, self.gy + 1, self, 12 + 8 * 4, 16)
    Quarry_alias:new(tile_quads["empty"], self.gx + 5, self.gy + 2, self, 12 + 8 * 4, 16)
    Quarry_alias:new(tile_quads["empty"], self.gx + 5, self.gy + 3, self, 12 + 8 * 4, 16)
    Quarry_alias:new(tile_quads["empty"], self.gx + 5, self.gy + 4, self, 12 + 8 * 4, 16)
    Quarry_alias:new(tile_quads["empty"], self.gx + 5, self.gy + 5, self, 12 + 8 * 4, 16)
    Quarry_alias:new(tile_quads["empty"], self.gx + 1, self.gy + 5, self, 12 + 8 * 4, 16)
    Quarry_alias:new(tile_quads["empty"], self.gx + 2, self.gy + 5, self, 12 + 8 * 4, 16)
    Quarry_alias:new(tile_quads["empty"], self.gx + 3, self.gy + 5, self, 12 + 8 * 4, 16)
    Quarry_alias:new(tile_quads["empty"], self.gx + 4, self.gy + 5, self, 12 + 8 * 4, 16)

    self.free_spots = 3
    self.lift_worker = nil
    self.pull_worker = nil
    self.shape_worker = nil
end
function Quarry:join(worker)
    if self.free_spots == 3 then
        self.lift_worker = worker
        worker.workplace = self
        self.free_spots = self.free_spots - 1
    elseif self.free_spots == 2 then
        self.pull_worker = worker
        worker.workplace = self
        self.free_spots = self.free_spots - 1
    elseif self.free_spots == 1 then
        self.shape_worker = worker
        worker.workplace = self
        self.free_spots = self.free_spots - 1
    end
end
function Quarry:work(worker)
    if self.lift_worker == worker then
        worker.state = "Working"
        worker.tile = tile_quads["empty"]
        worker.animated = false
        worker.gx = self.gx + 3
        worker.gy = self.gy + 2
        worker:job_update()
        self.lifter.tile = tile_quads["anim_quarry_lower (1)"]
    elseif self.pull_worker == worker then
        worker.state = "Working"
        worker.tile = tile_quads["empty"]
        worker.animated = false
        worker.gx = self.gx + 4
        worker.gy = self.gy + 3
        worker:job_update()
        self.puller.tile = tile_quads["anim_quarry_pull (1)"]
    elseif self.shape_worker == worker then
        worker.state = "Working"
        worker.tile = tile_quads["empty"]
        worker.animated = false
        worker.gx = self.gx + 3
        worker.gy = self.gy + 4
        worker:job_update()
        self.shaper.tile = tile_quads["anim_quarry_cut (1)"]
    end
    if self.shape_worker and self.shape_worker.state == "Working" and not self.working and self.lift_worker.state ==
        "Working" and self.pull_worker.state == "Working" then
        self.working = true
        self.lifter:activate()
    end
end
function Quarry:send_to_stockpile()
    self.stone_quantity = 0
    local i, o, cx, cy
    self.lift_worker.state = "Go to stockpile"
    self.lift_worker.animated = true
    self.lift_worker.gx = self.gx + 6
    self.lift_worker.gy = self.gy + 2
    self.lift_worker.fx = (self.gx + 6) * 1000
    self.lift_worker.fy = (self.gy + 2) * 1000
    i = (self.lift_worker.gx) % (chunk_width)
    o = (self.lift_worker.gy) % (chunk_width)
    cx = math.floor(self.lift_worker.gx / chunk_width)
    cy = math.floor(self.lift_worker.gy / chunk_width)
    addObjectAt(cx, cy, i, o, self.lift_worker)

    self.pull_worker.state = "Go to stockpile"
    self.pull_worker.animated = true
    self.pull_worker.gx = self.gx + 5
    self.pull_worker.gy = self.gy - 1
    self.pull_worker.fx = (self.gx + 5) * 1000
    self.pull_worker.fy = (self.gy - 1) * 1000
    i = (self.pull_worker.gx) % (chunk_width)
    o = (self.pull_worker.gy) % (chunk_width)
    cx = math.floor(self.pull_worker.gx / chunk_width)
    cy = math.floor(self.pull_worker.gy / chunk_width)
    addObjectAt(cx, cy, i, o, self.pull_worker)

    self.shape_worker.state = "Go to stockpile"
    self.shape_worker.animated = true
    self.shape_worker.gx = self.gx + 1
    self.shape_worker.gy = self.gy + 6
    self.shape_worker.fx = (self.gx + 1) * 1000
    self.shape_worker.fy = (self.gy + 6) * 1000
    i = (self.shape_worker.gx) % (chunk_width)
    o = (self.shape_worker.gy) % (chunk_width)
    cx = math.floor(self.shape_worker.gx / chunk_width)
    cy = math.floor(self.shape_worker.gy / chunk_width)
    addObjectAt(cx, cy, i, o, self.shape_worker)

    self.lifter:deactivate()
    self.puller:deactivate()
    self.shaper:deactivate()
    self.working = false
end

return Quarry
