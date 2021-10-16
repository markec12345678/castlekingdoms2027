local active_entities, object, tile_quads, object_batch = ...
local Structure = require("objects.Structure")

local tiles, quad_array = _G.indexBuildingQuads("woodcutter_hut", true)

local WoodcutterHut_alias = _G.class('WoodcutterHut_alias', Structure)
function WoodcutterHut_alias:initialize(tile, gx, gy, parent, offset_y, offset_x)
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
end

local WoodcutterHut = class('WoodcutterHut', Structure)
function WoodcutterHut:initialize(gx, gy, type)
    _G.JobController:add("Woodcutter", self)
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
    self.offset_y = -32
    self.level = 1
    self.rotation = 1
    local ccx, ccy
    for xx = -1, 3 do
        for yy = -1, 3 do
            ccx, ccy = terrainSetTileAt(self.gx + xx, self.gy + yy, math.random(6, 8))
        end
    end
    update_terrain(ccx, ccy)
    for tile = 1, tiles do
        WoodcutterHut_alias:new(quad_array[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offset_y + 8 * (tiles - tile + 1))
    end
    for tile = 1, tiles do
        WoodcutterHut_alias:new(quad_array[tiles + 1 + tile], self.gx + tile, self.gy, self, -self.offset_y + 8 * tile,
            16)
    end

    self.free_spots = 1
    self.worker = nil
end
function WoodcutterHut:join(worker)
    if self.free_spots == 1 then
        self.worker = worker
        self.worker.workplace = self
        self.free_spots = self.free_spots - 1
    end
end
function WoodcutterHut:work(worker)
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
    -- self.lifter.tile = tile_quads[139]

    if not self.working and self.worker.state == "Working" then
        self.working = true
        self.going_down:activate()
    end
end
function WoodcutterHut:send_to_stockpile()
    local i, o, cx, cy
    self.worker.state = "Go to stockpile"
    self.worker.animated = true
    self.worker.gx = self.gx - 1
    self.worker.gy = self.gy + 1
    self.worker.fx = (self.gx - 1) * 1000
    self.worker.fy = (self.gy + 1) * 1000
    i = (self.worker.gx) % (chunk_width)
    o = (self.worker.gy) % (chunk_width)
    cx = math.floor(self.worker.gx / chunk_width)
    cy = math.floor(self.worker.gy / chunk_width)
    addObjectAt(cx, cy, i, o, self.worker)
    self.stack:take()
    self.going_down:deactivate()
    self.working = false
end

return WoodcutterHut
