local object, tile_quads, object_batch = ...
local Structure = require("objects.Structure")
local tiles, quad_array = indexBuildingQuads("farm (2)")
local wheat_tile = tile_quads["tile_farmland_stage_4 (1)"]
local quad_offset = require('objects.quad_offset')
local farmland_tiles_stage_0 = {tile_quads["tile_farmland_stage_0 (1)"], tile_quads["tile_farmland_stage_0 (2)"],
                                tile_quads["tile_farmland_stage_0 (3)"], tile_quads["tile_farmland_stage_0 (4)"]}
local farmland_tiles_stage_1 = {tile_quads["tile_farmland_stage_1 (1)"], tile_quads["tile_farmland_stage_1 (2)"],
                                tile_quads["tile_farmland_stage_1 (3)"], tile_quads["tile_farmland_stage_1 (4)"]}
local farmland_tiles_stage_2 = {tile_quads["tile_farmland_stage_2 (1)"], tile_quads["tile_farmland_stage_2 (2)"],
                                tile_quads["tile_farmland_stage_2 (3)"], tile_quads["tile_farmland_stage_2 (4)"]}
local farmland_tiles_stage_3 = {tile_quads["tile_farmland_stage_3 (1)"], tile_quads["tile_farmland_stage_3 (2)"],
                                tile_quads["tile_farmland_stage_3 (3)"], tile_quads["tile_farmland_stage_3 (4)"]}
local farmland_tiles_stage_4 = {tile_quads["tile_farmland_stage_4 (1)"], tile_quads["tile_farmland_stage_4 (2)"],
                                tile_quads["tile_farmland_stage_4 (3)"], tile_quads["tile_farmland_stage_4 (4)"]}
local farmland_hay_tile = tile_quads["tile_farmland_hay (1)"]

local WheatFarm_alias = class('WheatFarm_alias', Structure)
function WheatFarm_alias:initialize(tile, gx, gy, parent, offset_y, offset_x)
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
end
local WheatFarm_plant = class('WheatFarm_plant', Structure)
function WheatFarm_plant:initialize(gx, gy, parent, is_plant)
    local mytype = "Wheat Plant"
    local i = (gx) % (chunk_width)
    local o = (gy) % (chunk_width)
    local cx = math.floor(gx / chunk_width)
    local cy = math.floor(gy / chunk_width)
    local x = IsoX + (i - o) * tile_width * 0.5
    local y = IsoY + (i + o) * tile_height * 0.5
    Structure.initialize(self, gx, gy, mytype)
    self.is_plant = is_plant or false
    self.animated = false
    self.gx = gx
    self.gy = gy
    self.state = -1
    self.has_wheat_resource = false
    self.parent = parent
    if is_plant then
        parent.available_plant_tiles = parent.available_plant_tiles + 1
    end
    if parent.available_plant_tiles % 8 == 0 then
        self.has_wheat_resource = true
    end
    self.qid = 0
    self.offset_x = 0
    self.offset_y = 0
    self.tile = tile_quads["empty"]
    local random_tile = love.math.random(1, 4)
    -- if is_plant then
    --     self.tile = farmland_tiles_stage_4[random_tile]
    --     self.offset_y = -16
    -- else
    -- self.tile = farmland_tiles_stage_0[random_tile]
    -- end
    _G.saw = self
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
    self.wheat_mature_counter = 0
    self.started_growing = false
    -- addObjectAt(self.cx, self.cy, self.i, self.o, self)
end
-- function WheatFarm_plant:animate()
--     self.animation:update(dt)
-- end
function WheatFarm_plant:update(dt)
    dt = dt or _G.dt
    if self.state > 0 and self.state < 4 and self.is_plant and self.parent.tiles_sowed ==
        self.parent.available_plant_tiles and (_G.wheat_growing_season or self.started_growing) then
        self.started_growing = true
        self.wheat_mature_counter = self.wheat_mature_counter + dt
        if self.wheat_mature_counter > 3 then
            self.state = self.state + 1
            self:set_state()
            if self.state == 4 then
                self.parent.tiles_fully_grown = self.parent.tiles_fully_grown + 1
            end
            self.wheat_mature_counter = 0
        end
    end
end
function WheatFarm_plant:set_state(state)
    state = state or self.state
    local random_tile = love.math.random(1, 4)
    if self.is_plant then
        self.state = state
        if state == 0 then
            self.tile = farmland_tiles_stage_0[random_tile]
        elseif state == 1 then
            self.tile = farmland_tiles_stage_1[random_tile]
        elseif state == 2 then
            self.tile = farmland_tiles_stage_2[random_tile]
        elseif state == 3 then
            self.tile = farmland_tiles_stage_3[random_tile]
        elseif state == 4 then
            self.tile = farmland_tiles_stage_4[random_tile]
        elseif state == 5 then
            if self.has_wheat_resource then
                self.tile = farmland_hay_tile
            else
                self.tile = farmland_tiles_stage_0[random_tile]
            end
        end
        local _, _, _, wh = self.tile:getViewport()
        self.offset_y = -(wh - 16)
    else
        self.state = state
        if state == 0 then
            self.tile = farmland_tiles_stage_0[random_tile]
        elseif state == 1 then
            self.tile = farmland_tiles_stage_1[random_tile]
        end
    end
end

local WheatFarm = class('WheatFarm', Structure)
function WheatFarm:initialize(gx, gy, type)
    _G.JobController:add("WheatFarmer", self)
    local mytype = "Static structure"
    Structure.initialize(self, gx, gy, mytype)
    setWalkable(self.gx, self.gy, 1)
    self.health = 400
    self.qid = nil
    self.tile = quad_array[tiles + 1]
    self.stone_quantity = 0
    self.working = false
    self.offset_x = 0
    self.offset_y = -64 - 6 - 8
    self.level = 1
    self.rotation = 1
    self.state = 0
    self.last_tile = nil
    for xx = -1, 13 do
        for yy = -1, 13 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.dirt)
        end
    end

    for tile = 1, tiles do
        WheatFarm_alias:new(quad_array[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offset_y + 8 * (tiles - tile + 1))
    end

    for tile = 1, tiles do
        WheatFarm_alias:new(quad_array[tiles + 1 + tile], self.gx + tile, self.gy, self, -self.offset_y + 8 * tile, 14)
    end
    self.available_plant_tiles = 0
    self.land_tiles = {}
    local t1, t2
    for y = 4, 11 do
        t1 = WheatFarm_plant:new(self.gx + 0, self.gy + y, self, true)
        t2 = WheatFarm_plant:new(self.gx + 1, self.gy + y, self, true)
        table.insert(self.land_tiles, {t1, t2})
    end
    for y = 11, 0, -1 do
        t1 = false
        if y > 3 then
            t1 = WheatFarm_plant:new(self.gx + 2, self.gy + y, self, true)
        end
        t2 = WheatFarm_plant:new(self.gx + 3, self.gy + y, self, true)
        table.insert(self.land_tiles, {t1, t2})
    end
    for y = 0, 11 do
        t1 = WheatFarm_plant:new(self.gx + 4, self.gy + y, self, true)
        t2 = WheatFarm_plant:new(self.gx + 5, self.gy + y, self, true)
        table.insert(self.land_tiles, {t1, t2})
    end
    for y = 11, 0, -1 do
        t1 = WheatFarm_plant:new(self.gx + 6, self.gy + y, self, true)
        t2 = WheatFarm_plant:new(self.gx + 7, self.gy + y, self, true)
        table.insert(self.land_tiles, {t1, t2})
    end
    for y = 0, 11 do
        t1 = WheatFarm_plant:new(self.gx + 8, self.gy + y, self, true)
        t2 = WheatFarm_plant:new(self.gx + 9, self.gy + y, self, true)
        table.insert(self.land_tiles, {t1, t2})
    end
    for y = 11, 0, -1 do
        t1 = WheatFarm_plant:new(self.gx + 10, self.gy + y, self, true)
        t2 = WheatFarm_plant:new(self.gx + 11, self.gy + y, self, true)
        table.insert(self.land_tiles, {t1, t2})
    end
    -- for y = 11, 0, -1 do
    --     t1 = false
    --     if y > 3 then
    --         t1 = WheatFarm_plant:new(self.gx + 2, self.gy + y, self, true)
    --     end
    --     t2 = WheatFarm_plant:new(self.gx + 3, self.gy + y, self)
    --     table.insert(self.land_tiles, {t1, t2})
    -- end
    -- for y = 0, 11 do
    --     t1 = WheatFarm_plant:new(self.gx + 4, self.gy + y, self, true)
    --     t2 = WheatFarm_plant:new(self.gx + 5, self.gy + y, self)
    --     table.insert(self.land_tiles, {t1, t2})
    -- end
    -- for y = 11, 0, -1 do
    --     t1 = WheatFarm_plant:new(self.gx + 6, self.gy + y, self, true)
    --     t2 = WheatFarm_plant:new(self.gx + 7, self.gy + y, self)
    --     table.insert(self.land_tiles, {t1, t2})
    -- end
    -- for y = 0, 11 do
    --     t1 = WheatFarm_plant:new(self.gx + 8, self.gy + y, self, true)
    --     t2 = WheatFarm_plant:new(self.gx + 9, self.gy + y, self)
    --     table.insert(self.land_tiles, {t1, t2})
    -- end
    -- for y = 11, 0, -1 do
    --     t1 = WheatFarm_plant:new(self.gx + 10, self.gy + y, self, true)
    --     t2 = WheatFarm_plant:new(self.gx + 11, self.gy + y, self)
    --     table.insert(self.land_tiles, {t1, t2})
    -- end
    table.insert(self.land_tiles[1], WheatFarm_plant:new(self.gx + 0, self.gy + 3, self, true))
    table.insert(self.land_tiles[1], WheatFarm_plant:new(self.gx + 2, self.gy + 3, self, true))
    table.insert(self.land_tiles[1], WheatFarm_plant:new(self.gx + 1, self.gy + 3, self, true))
    self.tiles_sowed = 0
    self.tiles_fully_grown = 0
    -- WheatFarm_plant:new(self.gx + 0, self.gy + 3, self)
    -- WheatFarm_plant:new(self.gx + 2, self.gy + 3, self)
    -- WheatFarm_plant:new(self.gx + 1, self.gy + 3, self)
    -- WheatFarm_plant:new(self.gx + 3, self.gy + 3, self)
    self.max_land_tiles = #self.land_tiles
    self.processed_tiles = 0
    -- for x =i

    self.free_spots = 1
end
function WheatFarm:join(worker)
    -- if self.free_spots == 3 then
    --  self.lift_worker = worker
    --  worker.workplace = self
    --  self.free_spots = self.free_spots - 1
    -- elseif self.free_spots == 2 then
    --  self.pull_worker = worker
    --  worker.workplace = self
    --  self.free_spots = self.free_spots - 1
    if self.free_spots == 1 then
        self.wheat_worker = worker
        worker.workplace = self
        self.free_spots = self.free_spots - 1
    end
end
function WheatFarm:update_tiles(farmland_tiles)
    for _, tile in ipairs(farmland_tiles) do
        if tile then
            if tile.state == -1 then
                tile:set_state(0)
            elseif tile.state == 0 then
                tile:set_state(1)
                if tile.is_plant then
                    self.tiles_sowed = self.tiles_sowed + 1
                end
            elseif tile.state == 4 then
                if tile.is_plant then
                    tile:set_state(5)
                end
            end
        end
    end
end
function WheatFarm:work(worker)
    if self.wheat_worker == worker then
        if self.wheat_worker.state ~= "Resting" then
            self.wheat_worker.state = "Working"
        end
        if self.state == 0 then
            self.processed_tiles = self.processed_tiles + 1
            local current_tile = self.land_tiles[self.processed_tiles][2]
            if self.wheat_worker.gx == current_tile.gx and self.wheat_worker.gy == current_tile.gy - 2 then
                self.wheat_worker.state = "Hoe walking to southern tile"
            elseif self.wheat_worker.gx == current_tile.gx and self.wheat_worker.gy == current_tile.gy + 2 then
                self.wheat_worker.state = "Hoe walking to northern tile"
            elseif self.wheat_worker.gx == current_tile.gx - 2 and self.wheat_worker.gy == current_tile.gy - 1 then
                self.wheat_worker:requestPath(current_tile.gx, current_tile.gy + 1)
                self.wheat_worker.state = "Going to hoe the land from south"
                self.wheat_worker.move_dir = "none"
            else
                self.wheat_worker:requestPath(current_tile.gx, current_tile.gy - 1)
                self.wheat_worker.state = "Going to hoe the land from north"
                self.wheat_worker.move_dir = "none"
            end
            self.wheat_worker.farmland_tiles = self.land_tiles[self.processed_tiles]
            if self.processed_tiles == self.max_land_tiles then
                self.state = 1
                self.processed_tiles = 0
            end
        elseif self.state == 1 then
            if self.processed_tiles == self.max_land_tiles then
                self.state = 2
                self.processed_tiles = 0
                self.wheat_worker.state = "Go to rest"
                return
            end
            self.processed_tiles = self.processed_tiles + 1
            local current_tile = self.land_tiles[self.processed_tiles][2]
            if self.wheat_worker.gx == current_tile.gx and self.wheat_worker.gy == current_tile.gy - 2 then
                self.wheat_worker.state = "Seed walking to southern tile"
            elseif self.wheat_worker.gx == current_tile.gx and self.wheat_worker.gy == current_tile.gy + 2 then
                self.wheat_worker.state = "Seed walking to northern tile"
            elseif self.wheat_worker.gx == current_tile.gx - 2 and self.wheat_worker.gy == current_tile.gy - 1 then
                self.wheat_worker:requestPath(current_tile.gx, current_tile.gy + 1)
                self.wheat_worker.state = "Going to seed the land from south"
                self.wheat_worker.move_dir = "none"
            else
                self.wheat_worker:requestPath(current_tile.gx, current_tile.gy - 1)
                self.wheat_worker.state = "Going to seed the land from north"
                self.wheat_worker.move_dir = "none"
            end
            self.wheat_worker.farmland_tiles = self.land_tiles[self.processed_tiles]
        elseif self.state == 2 then
            -- on each rest cycle, check if plants are ready
            if self.tiles_fully_grown == self.available_plant_tiles then
                self.state = 3
                self.processed_tiles = 0
            end
        elseif self.state == 3 then
            self.processed_tiles = self.processed_tiles + 1
            local current_tile = self.land_tiles[self.processed_tiles][2]
            if self.wheat_worker.gx == current_tile.gx and self.wheat_worker.gy == current_tile.gy - 2 then
                self.wheat_worker.state = "Scythe walking to southern tile"
            elseif self.wheat_worker.gx == current_tile.gx and self.wheat_worker.gy == current_tile.gy + 2 then
                self.wheat_worker.state = "Scythe walking to northern tile"
            elseif self.wheat_worker.gx == current_tile.gx - 2 and self.wheat_worker.gy == current_tile.gy - 1 then
                self.wheat_worker:requestPath(current_tile.gx, current_tile.gy + 1)
                self.wheat_worker.state = "Going to scythe the land from south"
                self.wheat_worker.move_dir = "none"
            else
                self.wheat_worker:requestPath(current_tile.gx, current_tile.gy - 1)
                self.wheat_worker.state = "Going to scythe the land from north"
                self.wheat_worker.move_dir = "none"
            end
            self.wheat_worker.farmland_tiles = self.land_tiles[self.processed_tiles]
            if self.processed_tiles == self.max_land_tiles then
                self.state = 1
                self.processed_tiles = 0
            end
        elseif self.state == 4 then
            self.tree4.animation = self.tree4.anim_raw
            self.wheat_worker:requestPath(self.gx + 6, self.gy + 2)
            self.wheat_worker.state = "Going to apple tree"
            self.wheat_worker.move_dir = "none"
            self.state = 5
        elseif self.state == 5 then
            self.tree3.animation = self.tree3.anim_raw
            self.wheat_worker:requestPath(self.gx + 11, self.gy + 2)
            self.wheat_worker.state = "Going to apple tree"
            self.wheat_worker.move_dir = "none"
            self.state = 6
        elseif self.state == 6 then
            self.tree6.animation = self.tree6.anim_raw
            self.wheat_worker:requestPath(self.gx + 11, self.gy + 7)
            self.wheat_worker.state = "Going to apple tree"
            self.wheat_worker.move_dir = "none"
            self.state = 7
        elseif self.state == 7 then
            self.tree7.animation = self.tree7.anim_raw
            self.wheat_worker:requestPath(self.gx + 11, self.gy + 12)
            self.wheat_worker.state = "Going to apple tree"
            self.wheat_worker.move_dir = "none"
            self.state = 8
        elseif self.state == 8 then
            self.tree8.animation = self.tree8.anim_raw
            self:send_to_stockpile()
            self.state = 0
        end
    end
end
function WheatFarm:send_to_stockpile()
    self.wheat_worker.state = "Go to foodpile"
    self.wheat_worker.move_dir = "none"
    -- addObjectAt(cx, cy, i, o, self.wheat_worker)     
    self.working = false
end

return WheatFarm
