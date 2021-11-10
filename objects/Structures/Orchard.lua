local object, tile_quads, object_batch = ...
local Structure = require("objects.Structure")
local tiles, quad_array = indexBuildingQuads("farm (3)")
local tree_raw = indexQuads("tree_apple", 25, nil, true)
local tree_apple = indexQuads("tree_apple_apple", 25, nil, true)
local quad_offset = require('objects.quad_offset')

local Orchard_alias = class('Orchard_alias', Structure)
function Orchard_alias:initialize(tile, gx, gy, parent, offset_y, offset_x)
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
    Structure.render(self)
end
local Orchard_tree = class('Orchard_tree', Structure)
function Orchard_tree:initialize(gx, gy, parent, offset_y, offset_x)
    local mytype = "Static structure"
    Structure.initialize(self, gx, gy, mytype)
    self.animated = true
    self.anim_raw = anim.newAnimation(tree_raw, 0.10)
    self.anim_full = anim.newAnimation(tree_apple, 0.10)
    self.animation = self.anim_full
    self.gx = gx
    self.gy = gy
    setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.qid = 0
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
    if _G.chunk_objects[self.cx][self.cy] == nil then
        _G.chunk_objects[self.cx][self.cy] = {}
    end
    _G.chunk_objects[self.cx][self.cy][self] = self
end
function Orchard_tree:animate()
    local updated = self.animation:update(_G.dt)
    if not self.instancemesh and _G.object_mesh then
        local offset_x, offset_y = 0, 0
        if quad_offset[self.animation:getQuad()] then
            offset_x, offset_y = quad_offset[self.animation:getQuad()][1] or 0,
                quad_offset[self.animation:getQuad()][2] or 0
        end
        local instancemesh = object_mesh[self.cx][self.cy]
        local quad, x, y, _, _, _, _, _, _, _ = self.animation:getFrameInfo(self.x + (self.offset_x or 0) + offset_x,
            self.y + (self.offset_y or 0) + offset_y - _G.height_map[self.gx][self.gy])
        local qx, qy, qw, qh = quad:getViewport()
        -- TODO FIXME, TO REQUEST VERTEX WITH API
        self.vert_id = _G.vertices_per_tile * (self.i + self.o * chunk_width) + 1
        self.instancemesh = instancemesh
        self.instancemesh:setVertex(self.vert_id, x, y, qx, qy, qw, qh)
    end
    if self.instancemesh and updated then
        self.last_updated = 0
        local offset_x, offset_y = 0, 0
        if quad_offset[self.animation:getQuad()] then
            offset_x, offset_y = quad_offset[self.animation:getQuad()][1] or 0,
                quad_offset[self.animation:getQuad()][2] or 0
        end
        local quad, x, y, _, _, _, _, _, _, _ = self.animation:getFrameInfo(self.x + (self.offset_x or 0) + offset_x,
            self.y + (self.offset_y or 0) + offset_y - _G.height_map[self.gx][self.gy])
        local qx, qy, qw, qh = quad:getViewport()
        self.instancemesh:setVertex(self.vert_id, x, y, qx, qy, qw, qh)
        return
    end
end
function Orchard_tree:update()
    return
end

local Orchard = class('Orchard', Structure)
function Orchard:initialize(gx, gy, type)
    _G.JobController:add("OrchardFarmer", self)
    local mytype = "Static structure"
    Structure.initialize(self, gx, gy, mytype)
    setWalkable(self.gx, self.gy, 1)
    self.health = 400
    self.qid = nil
    self.tile = quad_array[tiles + 1]
    self.stone_quantity = 0
    self.working = false
    self.offset_x = 0
    self.offset_y = -48 - 6
    self.level = 1
    self.rotation = 1
    self.state = 0
    for xx = -1, 13 do
        for yy = -1, 13 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.dirt)
        end
    end

    for tile = 1, tiles do
        Orchard_alias:new(quad_array[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offset_y + 8 * (tiles - tile + 1))
    end

    for tile = 1, tiles do
        Orchard_alias:new(quad_array[tiles + 1 + tile], self.gx + tile, self.gy, self, -self.offset_y + 8 * tile, 14)
    end
    -- Orchard_alias:new(tile_quads[2302],self.gx,self.gy+5,self,118+8*5)				
    -- Orchard_alias:new(tile_quads[2303],self.gx,self.gy+4,self,118+8*4)
    -- Orchard_alias:new(tile_quads[2304],self.gx,self.gy+3,self,118+8*3)
    -- Orchard_alias:new(tile_quads[2305],self.gx,self.gy+2,self,118+8*2)
    -- Orchard_alias:new(tile_quads[2306],self.gx,self.gy+1,self,118+8*1)
    local offset_x, offset_y = -64 - 8, 116
    self.tree1 = Orchard_tree:new(self.gx + 1, self.gy + 6, self, offset_y, offset_x)
    self.tree2 = Orchard_tree:new(self.gx + 1, self.gy + 11, self, offset_y, offset_x)

    self.tree3 = Orchard_tree:new(self.gx + 6, self.gy + 1, self, offset_y, offset_x)
    self.tree4 = Orchard_tree:new(self.gx + 6, self.gy + 6, self, offset_y, offset_x)
    self.tree5 = Orchard_tree:new(self.gx + 6, self.gy + 11, self, offset_y, offset_x)

    self.tree6 = Orchard_tree:new(self.gx + 11, self.gy + 1, self, offset_y, offset_x)
    self.tree7 = Orchard_tree:new(self.gx + 11, self.gy + 6, self, offset_y, offset_x)
    self.tree8 = Orchard_tree:new(self.gx + 11, self.gy + 11, self, offset_y, offset_x)
    -- Orchard_alias:new(tile_quads[2308],self.gx+1,self.gy,self,118+8*1,14)
    -- Orchard_alias:new(tile_quads[2309],self.gx+2,self.gy,self,118+8*2,14)
    -- Orchard_alias:new(tile_quads[2310],self.gx+3,self.gy,self,118+8*3,14)
    -- Orchard_alias:new(tile_quads[2311],self.gx+4,self.gy,self,118+8*4,14)
    -- Orchard_alias:new(tile_quads[2312],self.gx+5,self.gy,self,118+8*5,14)

    -- Orchard_alias:new(tile_quads["empty"],self.gx+5,self.gy+1,self,12+8*4,16)
    -- Orchard_alias:new(tile_quads["empty"],self.gx+5,self.gy+2,self,12w+8*4,16)
    -- Orchard_alias:new(tile_quads["empty"],self.gx+5,self.gy+3,self,12+8*4,16)
    -- Orchard_alias:new(tile_quads["empty"],self.gx+5,self.gy+4,self,12+8*4,16)
    -- Orchard_alias:new(tile_quads["empty"],self.gx+5,self.gy+5,self,12+8*4,16)
    -- Orchard_alias:new(tile_quads["empty"],self.gx+1,self.gy+5,self,12+8*4,16)
    -- Orchard_alias:new(tile_quads["empty"],self.gx+2,self.gy+5,self,12+8*4,16)
    -- Orchard_alias:new(tile_quads["empty"],self.gx+3,self.gy+5,self,12+8*4,16)
    -- Orchard_alias:new(tile_quads["empty"],self.gx+4,self.gy+5,self,12+8*4,16)

    self.free_spots = 1
    Structure.render(self)
end
function Orchard:join(worker)
    -- if self.free_spots == 3 then
    -- 	self.lift_worker = worker
    -- 	worker.workplace = self
    -- 	self.free_spots = self.free_spots - 1
    -- elseif self.free_spots == 2 then
    -- 	self.pull_worker = worker
    -- 	worker.workplace = self
    -- 	self.free_spots = self.free_spots - 1
    if self.free_spots == 1 then
        self.apple_worker = worker
        worker.workplace = self
        self.free_spots = self.free_spots - 1
    end
end
function Orchard:work(worker)
    -- if self.lift_worker == worker then
    -- 	worker.state = "Working"
    -- 	worker.tile = tile_quads["empty"]
    -- 	worker.animated = false
    -- 	worker.gx = self.gx+3
    -- 	worker.gy = self.gy+2
    -- 	worker:job_update()
    -- 	self.lifter.tile = tile_quads["anim_quarry_lower (1)"]
    -- elseif self.pull_worker == worker then
    -- 	worker.state = "Working"
    -- 	worker.tile = tile_quads["empty"]
    -- 	worker.animated = false
    -- 	worker.gx = self.gx+4
    -- 	worker.gy = self.gy+3
    -- 	worker:job_update()
    -- 	self.puller.tile = tile_quads["anim_quarry_pull (1)"]
    -- elseif self.apple_worker == worker then
    -- 	worker.state = "Working"
    -- 	worker.tile = tile_quads["empty"]
    -- 	worker.animated = false
    -- 	worker.gx = self.gx+3
    -- 	worker.gy = self.gy+4
    -- 	worker:job_update()
    -- 	self.shaper.tile = tile_quads["anim_quarry_cut (1)"]
    -- end
    if self.apple_worker == worker then
        self.apple_worker.state = "Working"
        if self.state == 0 then
            self.tree1.animation = self.tree1.anim_full
            self.tree2.animation = self.tree2.anim_full
            self.tree3.animation = self.tree3.anim_full
            self.tree4.animation = self.tree4.anim_full
            self.tree5.animation = self.tree5.anim_full
            self.tree6.animation = self.tree6.anim_full
            self.tree7.animation = self.tree7.anim_full
            self.tree8.animation = self.tree8.anim_full
            self.apple_worker:requestPath(self.gx + 1, self.gy + 7)
            self.apple_worker.state = "Going to apple tree"
            self.apple_worker.move_dir = "none"
            self.state = 1
        elseif self.state == 1 then
            self.tree1.animation = self.tree1.anim_raw
            self.apple_worker:requestPath(self.gx + 1, self.gy + 12)
            self.apple_worker.state = "Going to apple tree"
            self.apple_worker.move_dir = "none"
            self.state = 2
        elseif self.state == 2 then
            self.tree2.animation = self.tree2.anim_raw
            self.apple_worker:requestPath(self.gx + 6, self.gy + 12)
            self.apple_worker.state = "Going to apple tree"
            self.apple_worker.move_dir = "none"
            self.state = 3
        elseif self.state == 3 then
            self.tree5.animation = self.tree5.anim_raw
            self.apple_worker:requestPath(self.gx + 6, self.gy + 7)
            self.apple_worker.state = "Going to apple tree"
            self.apple_worker.move_dir = "none"
            self.state = 4
        elseif self.state == 4 then
            self.tree4.animation = self.tree4.anim_raw
            self.apple_worker:requestPath(self.gx + 6, self.gy + 2)
            self.apple_worker.state = "Going to apple tree"
            self.apple_worker.move_dir = "none"
            self.state = 5
        elseif self.state == 5 then
            self.tree3.animation = self.tree3.anim_raw
            self.apple_worker:requestPath(self.gx + 11, self.gy + 2)
            self.apple_worker.state = "Going to apple tree"
            self.apple_worker.move_dir = "none"
            self.state = 6
        elseif self.state == 6 then
            self.tree6.animation = self.tree6.anim_raw
            self.apple_worker:requestPath(self.gx + 11, self.gy + 7)
            self.apple_worker.state = "Going to apple tree"
            self.apple_worker.move_dir = "none"
            self.state = 7
        elseif self.state == 7 then
            self.tree7.animation = self.tree7.anim_raw
            self.apple_worker:requestPath(self.gx + 11, self.gy + 12)
            self.apple_worker.state = "Going to apple tree"
            self.apple_worker.move_dir = "none"
            self.state = 8
        elseif self.state == 8 then
            self.tree8.animation = self.tree8.anim_raw
            self:send_to_stockpile()
            self.state = 0
        end

    end
end
function Orchard:send_to_stockpile()
    self.apple_worker.state = "Go to foodpile"
    self.apple_worker.move_dir = "none"
    -- addObjectAt(cx, cy, i, o, self.apple_worker)		
    self.working = false
end

return Orchard
