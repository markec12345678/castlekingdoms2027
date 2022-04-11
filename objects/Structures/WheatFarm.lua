local _, tile_quads, _, active_entities = ...
local Structure = require("objects.Structure")
local Object = require("objects.Object")
local tiles, quad_array = _G.indexBuildingQuads("farm (2)")
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

local WheatFarm_alias = _G.class('WheatFarm_alias', Structure)
function WheatFarm_alias:initialize(tile, gx, gy, parent, offset_y, offset_x)
    local mytype = "Static structure"
    Structure.initialize(self, gx, gy, mytype)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.parent = parent
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
function WheatFarm_alias:serialize()
    local data = {}
    local struct_data = Structure.serialize(self)
    for k, v in pairs(struct_data) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.parent = _G.state:serializeObject(self.parent)
    data.tile_key = self.tile_key
    data.base_offset_y = self.base_offset_y
    data.additional_offset_y = self.additional_offset_y
    data.offset_x = self.offset_x
    data.offset_y = self.offset_y
    return data
end
function WheatFarm_alias.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    if data.tile_key then
        obj.tile = quad_array[data.tile_key]
        obj.tile_key = data.tile_key
        obj:render()
    end
    obj.parent = _G.state:dereferenceObject(data.parent)
    return obj
end

local WheatFarm_plant = _G.class('WheatFarm_plant', Structure)
function WheatFarm_plant:initialize(gx, gy, parent)
    local mytype = "Wheat Plant"
    Structure.initialize(self, gx, gy, mytype)
    self.animated = false
    self.is_plant = false
    self.state = -1
    self.has_wheat_resource = false
    self.parent = parent
    parent.available_plant_tiles = parent.available_plant_tiles + 1
    if parent.available_plant_tiles % 8 == 0 then
        self.is_plant = true
    end
    self.offset_x = 0
    self.offset_y = 0
    self.tile = tile_quads["empty"]
    self.tile_key = "empty"
    for k, v in ipairs(_G.stockpile.node_list) do
        if v.gx == self.gx and v.gy == self.gy then
            table.remove(_G.stockpile.node_list, k)
            break
        end
    end
    self.wheat_mature_counter = 0
    self.started_growing = false
    table.insert(active_entities, self)
end
function WheatFarm_plant:serialize()
    local data = {}
    local struct_data = Structure.serialize(self)
    for k, v in pairs(struct_data) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.animated = self.animated
    data.is_plant = self.is_plant
    data.state = self.state
    data.tile_key = self.tile_key
    data.has_wheat_resource = self.has_wheat_resource
    data.offset_x = self.offset_x
    data.offset_y = self.offset_y
    data.wheat_mature_counter = self.wheat_mature_counter
    data.started_growing = self.started_growing
    return data
end
function WheatFarm_plant.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    if data.tile_key then
        obj.tile = tile_quads[data.tile_key]
        obj.tile_key = data.tile_key
        obj:render()
    end
    table.insert(active_entities, obj)
    return obj
end
function WheatFarm_plant:render()
    Structure.render(self)
end
function WheatFarm_plant:animate(dt)
    self:update(dt)
end
function WheatFarm_plant:update(dt)
    dt = dt or _G.dt
    if self.state > 0 and self.state < 4 and self.parent.tiles_sowed == self.parent.available_plant_tiles and
        (_G.state.wheat_growing_season or self.started_growing) then
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
function WheatFarm_plant:take_resource()
    if self.has_wheat_resource then
        self:set_state(0)
        self.has_wheat_resource = false
        return true
    end
    return false
end
function WheatFarm_plant:set_state(state)
    state = state or self.state
    local random_tile = love.math.random(1, 4)
    self.state = state
    if state == 0 then
        self.tile = farmland_tiles_stage_0[random_tile]
        self.tile_key = "tile_farmland_stage_0 (" .. tostring(random_tile) .. ")"
    elseif state == 1 then
        self.tile = farmland_tiles_stage_1[random_tile]
        self.tile_key = "tile_farmland_stage_1 (" .. tostring(random_tile) .. ")"
    elseif state == 2 then
        self.tile = farmland_tiles_stage_2[random_tile]
        self.tile_key = "tile_farmland_stage_2 (" .. tostring(random_tile) .. ")"
    elseif state == 3 then
        self.tile = farmland_tiles_stage_3[random_tile]
        self.tile_key = "tile_farmland_stage_3 (" .. tostring(random_tile) .. ")"
    elseif state == 4 then
        self.tile = farmland_tiles_stage_4[random_tile]
        self.tile_key = "tile_farmland_stage_4 (" .. tostring(random_tile) .. ")"
    elseif state == 5 then
        if self.is_plant then
            self.tile = farmland_hay_tile
            self.tile_key = "tile_farmland_hay (1)"
        else
            self.tile = farmland_tiles_stage_0[random_tile]
            self.tile_key = "tile_farmland_stage_0 (" .. tostring(random_tile) .. ")"
        end
    end
    local _, _, _, wh = self.tile:getViewport()
    self.offset_y = -(wh - 16)
    self:render()
end

local WheatFarm = _G.class('WheatFarm', Structure)
function WheatFarm:initialize(gx, gy, type)
    _G.JobController:add("WheatFarmer", self)
    type = type or "Static structure"
    Structure.initialize(self, gx, gy, type)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 400
    self.tile = quad_array[tiles + 1]
    self.stone_quantity = 0
    self.working = false
    self.offset_x = 0
    self.offset_y = -64 - 6 - 8

    self.state = 0

    for xx = -1, 13 do
        for yy = -1, 13 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.scarce_grass)
        end
    end

    for xx = 0, 2 do
        for yy = 0, 2 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.none)
        end
    end

    for tile = 1, tiles do
        local whf = WheatFarm_alias:new(quad_array[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offset_y + 8 * (tiles - tile + 1))
        whf.tile_key = tile
    end

    for tile = 1, tiles do
        local whf = WheatFarm_alias:new(quad_array[tiles + 1 + tile], self.gx + tile, self.gy, self,
            -self.offset_y + 8 * tile, 14)
        whf.tile_key = tiles + 1 + tile
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
    for xx = 0, 2 do
        for yy = 0, 2 do
            local ccx, ccy, xxx, yyy = _G.getLocalCoordinatesFromGlobal(self.gx + xx, self.gy + yy)
            _G.buildingheightmap[ccx][ccy][xxx][yyy] = 14
        end
    end
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

    self.free_spots = 1
    Structure.render(self)
end
function WheatFarm:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    self.tile = quad_array[tiles + 1]
    self.land_tiles = {}
    for idx, ltiles in ipairs(data.land_tiles_raw) do
        self.land_tiles[idx] = {}
        for _, stile in ipairs(ltiles) do
            if stile == false then
                self.land_tiles[idx][#self.land_tiles[idx] + 1] = false
            else
                local farm_tile = _G.state:dereferenceObject(stile)
                self.land_tiles[idx][#self.land_tiles[idx] + 1] = farm_tile
                farm_tile.parent = self
            end
        end
    end
    if data.wheat_worker then
        self.wheat_worker = _G.state:dereferenceObject(data.wheat_worker)
        self.wheat_worker.workplace = self
    end
    Structure.render(self)
end
function WheatFarm:serialize()
    local data = {}
    local struct_data = Structure.serialize(self)
    for k, v in pairs(struct_data) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.available_plant_tiles = self.available_plant_tiles
    data.health = self.health
    data.stone_quantity = self.stone_quantity
    data.working = self.working
    data.offset_x = self.offset_x
    data.offset_y = self.offset_y
    data.max_land_tiles = self.max_land_tiles
    data.processed_tiles = self.processed_tiles
    data.tiles_sowed = self.tiles_sowed
    data.tiles_fully_grown = self.tiles_fully_grown
    data.free_spots = self.free_spots
    data.state = self.state
    if self.wheat_worker then
        data.wheat_worker = _G.state:serializeObject(self.wheat_worker)
    end
    local land_tiles = {}
    for idx, ltiles in ipairs(self.land_tiles) do
        land_tiles[idx] = {}
        for _, stile in ipairs(ltiles) do
            if stile then
                local farm_tile = _G.state:serializeObject(stile)
                land_tiles[idx][#land_tiles[idx] + 1] = farm_tile
            else
                land_tiles[idx][#land_tiles[idx] + 1] = false
            end
        end
    end
    data.land_tiles_raw = land_tiles
    return data
end
function WheatFarm.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

function WheatFarm:join(worker)
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
                self.tiles_sowed = self.tiles_sowed + 1
            elseif tile.state == 4 then
                if tile.is_plant then
                    tile:set_state(5)
                else
                    tile:set_state(0)
                end
            end
        end
    end
end
function WheatFarm:fill_resource_tiles()
    for _, tile_pair in ipairs(self.land_tiles) do
        for _, tile in ipairs(tile_pair) do
            if tile and tile.is_plant then
                tile.has_wheat_resource = true
            end
        end
    end
end
function WheatFarm:get_next_resource_tile()
    for _, tile_pair in ipairs(self.land_tiles) do
        for _, tile in ipairs(tile_pair) do
            if tile and tile.has_wheat_resource then
                return tile
            end
        end
    end
    return false
end
function WheatFarm:work(worker)
    if self.wheat_worker == worker then
        if self.wheat_worker.state ~= "Resting" then
            self.wheat_worker.state = "Working"
        end
        if self.state == 0 then
            self.processed_tiles = self.processed_tiles + 1
            local current_tile = self.land_tiles[self.processed_tiles][2]
            if not current_tile then
                current_tile = self.land_tiles[self.processed_tiles][1]
            end
            if self.wheat_worker:isPositionAt(current_tile.gx, current_tile.gy - 2) then
                self.wheat_worker.state = "Hoe walking to southern tile"
            elseif self.wheat_worker:isPositionAt(current_tile.gx, current_tile.gy + 2) then
                self.wheat_worker.state = "Hoe walking to northern tile"
            elseif self.wheat_worker:isPositionAt(current_tile.gx - 1, current_tile.gy + 2) then
                self.wheat_worker.state = "Hoe walking to northeastern tile"
                self.wheat_worker.current_tile = current_tile
            elseif self.wheat_worker:isPositionAt(current_tile.gx - 1, current_tile.gy + 1) then
                self.wheat_worker.state = "Hoe walking to northeastern tile"
                self.wheat_worker.current_tile = current_tile
            elseif self.wheat_worker:isPositionAt(current_tile.gx - 2, current_tile.gy + 1) then
                self.wheat_worker.state = "Hoe walking to northeastern tile"
                self.wheat_worker.current_tile = current_tile
            elseif self.wheat_worker:isPositionAt(current_tile.gx - 2, current_tile.gy - 1) then
                self.wheat_worker.state = "Hoe walking to southeastern tile"
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
                self:fill_resource_tiles()
                self.wheat_worker.state = "Go to rest"
                return
            end
            self.processed_tiles = self.processed_tiles + 1
            local current_tile = self.land_tiles[self.processed_tiles][2]
            if self.wheat_worker:isPositionAt(current_tile.gx, current_tile.gy - 2) then
                self.wheat_worker.state = "Seed walking to southern tile"
            elseif self.wheat_worker:isPositionAt(current_tile.gx, current_tile.gy + 2) then
                self.wheat_worker.state = "Seed walking to northern tile"
            elseif self.wheat_worker:isPositionAt(current_tile.gx - 1, current_tile.gy + 2) then
                self.wheat_worker.state = "Seed walking to northeastern tile"
                self.wheat_worker.current_tile = current_tile
            elseif self.wheat_worker:isPositionAt(current_tile.gx - 1, current_tile.gy + 1) then
                self.wheat_worker.state = "Seed walking to northeastern tile"
                self.wheat_worker.current_tile = current_tile
            elseif self.wheat_worker:isPositionAt(current_tile.gx - 2, current_tile.gy + 1) then
                self.wheat_worker.state = "Seed walking to northeastern tile"
                self.wheat_worker.current_tile = current_tile
            elseif self.wheat_worker:isPositionAt(current_tile.gx - 2, current_tile.gy - 1) then
                self.wheat_worker.state = "Seed walking to southeastern tile"
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
            if self.wheat_worker:isPositionAt(current_tile.gx, current_tile.gy - 2) then
                self.wheat_worker.state = "Scythe walking to southern tile"
            elseif self.wheat_worker:isPositionAt(current_tile.gx, current_tile.gy + 2) then
                self.wheat_worker.state = "Scythe walking to northern tile"
            elseif self.wheat_worker:isPositionAt(current_tile.gx - 1, current_tile.gy + 2) then
                self.wheat_worker.state = "Scythe walking to northeastern tile"
                self.wheat_worker.current_tile = current_tile
            elseif self.wheat_worker:isPositionAt(current_tile.gx - 1, current_tile.gy + 1) then
                self.wheat_worker.state = "Scythe walking to northeastern tile"
                self.wheat_worker.current_tile = current_tile
            elseif self.wheat_worker:isPositionAt(current_tile.gx - 2, current_tile.gy + 1) then
                self.wheat_worker.state = "Scythe walking to northeastern tile"
                self.wheat_worker.current_tile = current_tile
            elseif self.wheat_worker:isPositionAt(current_tile.gx - 2, current_tile.gy - 1) then
                self.wheat_worker.state = "Scythe walking to southeastern tile"
            else
                self.wheat_worker:requestPath(current_tile.gx, current_tile.gy - 1)
                self.wheat_worker.state = "Going to scythe the land from north"
                self.wheat_worker.move_dir = "none"
            end
            self.wheat_worker.farmland_tiles = self.land_tiles[self.processed_tiles]
            if self.processed_tiles == self.max_land_tiles then
                self.state = 4
                self.processed_tiles = 0
            end
        elseif self.state == 4 then
            local resource_tile = self:get_next_resource_tile()
            if resource_tile then
                self.wheat_worker.resource_tile = resource_tile
                self.wheat_worker.state = "Going to pick up wheat"
                self.wheat_worker:clear_path()
                self.wheat_worker:requestPath(resource_tile.gx, resource_tile.gy)
            else
                if self.wheat_worker.wheat > 0 then
                    self.wheat_worker.state = "Go to stockpile"
                    self.wheat_worker:clear_path()
                else
                    self.tiles_fully_grown = 0
                    self.tiles_sowed = 0
                    self.state = 1
                    self.processed_tiles = 0
                    self:work(self.wheat_worker)
                end
            end
        end
    end
end
function WheatFarm:send_to_stockpile()
    self.wheat_worker.state = "Go to foodpile"
    self.wheat_worker.move_dir = "none"
    self.working = false
end

return WheatFarm
