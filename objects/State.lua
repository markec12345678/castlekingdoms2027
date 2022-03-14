local bitser = require('libraries.bitser')
local Map = require('objects.Map')
local State = _G.class('State')

function State:initialize()
    self.serialized_object_ids = {}
    self.deserialized_object_ids = {}
    self.map = Map:new()
    self.top_left_chunk_x = 0
    self.top_left_chunk_y = 0
    self.bottom_right_chunk_x = 0
    self.bottom_right_chunk_y = 0
    self.terrain_chunks = nil
    self.object = newAutotable(4)
    self.object_mesh = newAutotable(2)
    self.object_mesh_vert_id_map = newAutotable(3)
    self.vertices_per_tile = 6
    self.chunk_objects = newAutotable(2)
    self.scale_x = 1
    self.view_xview = -100
    self.view_yview = 4000
    -- TODO: Make the collision map dynamic
    self.collision_map = ffi.new("unsigned char[2048][2048]", {})
    self.resources = {
        ['wood'] = 0,
        ['stone'] = 0,
        ['iron'] = 0,
        ['flour'] = 0,
        ['wheat'] = 0
    }
    self.food = {
        ["apples"] = 0,
        ["bread"] = 0,
        ["cheese"] = 0
    }
    self.not_full_stockpiles = {
        ["wood"] = 0,
        ["stone"] = 0,
        ["wheat"] = 0,
        ["iron"] = 0,
        ["flour"] = 0
    }
    self.not_full_foods = {
        ["apples"] = 0,
        ["bread"] = 0,
        ["cheese"] = 0
    }
    self.wheat_season_counter = 0
    self.wheat_growing_season = false
end

function State:save(filename)
    return self:serialize()
    -- bitser.saveLoveFile(filename)
end

function State:serializeObject(obj)
    if not self.serialized_object_ids[obj.id] then
        self.serialized_object_ids[obj.id] = obj:serialize()
        if not self.serialized_object_ids[obj.id] then
            error("Serialized object has no data!")
        end
    end
    return {
        _ref = obj.id,
        info = tostring(obj)
    }
end

function State:dereferenceObject(ref_obj)
    local ref = ref_obj._ref
    if not ref and ref_obj.class_name then
        -- Probably the object itself
        ref = ref_obj.id
    end
    -- Check if object has been deserialized already
    if self.deserialized_object_ids[ref] then
        return self.deserialized_object_ids[ref]
    end
    -- Find the object and deserialize it
    if self.raw_object_ids[ref] then
        local obj = self.raw_object_ids[ref]
        if obj and obj.class_name then
            local object = _G.getClassByName(obj.class_name)
            if object then
                local ret = object:deserialize(obj)
                self.deserialized_object_ids[ref] = ret
                return ret
            end
        end
    end
    error("Couldn't dereference object:" .. tostring(self.raw_object_ids[ref]) .. " with ref" .. tostring(inspect(ref)))
end

function State:serializeChunkObjects()
    local chunk_data = {}
    for cx = 0, _G.chunks_wide - 1 do
        chunk_data[cx] = {}
        for cy = 0, _G.chunks_high - 1 do
            chunk_data[cx][cy] = {}
            local data = chunk_data[cx][cy]
            if self.chunk_objects[cx][cy] then
                for _, obj in pairs(_G.state.chunk_objects[cx][cy]) do
                    if self.serialized_object_ids[obj.id] then
                        data[#data + 1] = self.serialized_object_ids[obj.id]
                    else
                        data[#data + 1] = obj:serialize()
                        self.serialized_object_ids[obj.id] = data[#data]
                    end
                end
            end
        end
    end
    return chunk_data
end

function State:deserializeChunkObjects(load_data)
    self.chunk_objects = newAutotable(2)
    for cx = 0, _G.chunks_wide - 1 do
        for cy = 0, _G.chunks_high - 1 do
            local data = load_data[cx] and load_data[cx][cy]
            if data then
                for _, obj in pairs(data) do
                    if obj and obj.class_name then
                        local object = _G.getClassByName(obj.class_name)
                        if object then
                            object:deserialize(obj)
                        end
                    end
                end
            end
        end
    end
    return self.chunk_objects
end

function State:deserializeObjects(data)
    for cx = 0, _G.chunks_wide - 1 do
        for cy = 0, _G.chunks_high - 1 do
            for i = 0, _G.chunk_width - 1 do
                for o = 0, _G.chunk_width - 1 do
                    if data[cx][cy][i][o] then
                        for _, obj in pairs(data[cx][cy][i][o]) do
                            if obj and next(obj) then
                                self:dereferenceObject(obj)
                            end
                        end
                    end
                end
            end
        end
    end
    return self.object
end

function State:serializeObjects()
    local data = {}
    for cx = 0, _G.chunks_wide - 1 do
        data[cx] = {}
        for cy = 0, _G.chunks_high - 1 do
            data[cx][cy] = {}
            for i = 0, _G.chunk_width - 1 do
                data[cx][cy][i] = {}
                for o = 0, _G.chunk_width - 1 do
                    data[cx][cy][i][o] = {}
                    if self.object[cx][cy][i][o] then
                        for _, obj in pairs(self.object[cx][cy][i][o]) do
                            if self.serialized_object_ids[obj.id] then
                                data[cx][cy][i][o][#data[cx][cy][i][o] + 1] = self.serialized_object_ids[obj.id]
                            else
                                local serial = obj:serialize()
                                data[cx][cy][i][o][#data[cx][cy][i][o] + 1] = serial
                                self.serialized_object_ids[obj.id] = serial
                            end
                        end
                    end
                end
            end
        end
    end
    return data
end

function State:serialize()
    local data = {}
    self.serialized_object_ids = {}
    data.resources = self.resources
    data.food = self.food
    data.not_full_stockpiles = self.not_full_stockpiles
    data.not_full_foods = self.not_full_foods
    data.wheat_season_counter = self.wheat_season_counter
    data.wheat_growing_season = self.wheat_growing_season
    data.collision_map = self.collision_map
    data.top_left_chunk_x = self.top_left_chunk_x
    data.top_left_chunk_y = self.top_left_chunk_y
    data.bottom_right_chunk_x = self.bottom_right_chunk_x
    data.bottom_right_chunk_y = self.bottom_right_chunk_y
    data.terrain_chunks = self.terrain_chunks
    data.build_controller = _G.BuildController:serialize()
    data.stockpile_controller = _G.stockpile:serialize()
    data.spawn_point_x, data.spawn_point_y = _G.spawn_point_x, _G.spawn_point_y
    data.offset_x, data.offset_y = _G.offset_x, _G.offset_y
    data.campfire = _G.campfire:serialize()
    -- data.object_mesh = self.object_mesh
    -- data.object_mesh_vert_id_map = self.object_mesh_vert_id_map
    data.vertices_per_tile = self.vertices_per_tile
    data.chunk_objects = self:serializeChunkObjects()
    data.object = self:serializeObjects()
    data.scale_x = self.scale_x
    data.view_xview = self.view_xview
    data.view_yview = self.view_yview
    data.serialized_object_ids = self.serialized_object_ids
    data.map = self.map:serialize()
    return data
end

function State:load(filename)
    local load = bitser.loadLoveFile(filename)
    self.deserialized_object_ids = {}
    self.resources = load.resources
    self.food = load.food
    self.raw_object_ids = load.serialized_object_ids
    self.not_full_stockpiles = load.not_full_stockpiles
    self.not_full_foods = load.not_full_foods
    self.wheat_season_counter = load.wheat_season_counter
    self.wheat_growing_season = load.wheat_growing_season
    self.collision_map = load.collision_map
    self.top_left_chunk_x = load.top_left_chunk_x
    self.top_left_chunk_y = load.top_left_chunk_y
    self.bottom_right_chunk_x = load.bottom_right_chunk_x
    self.bottom_right_chunk_y = load.bottom_right_chunk_y
    self.terrain_chunks = load.terrain_chunks
    -- self.object_mesh = load.object_mesh
    -- self.object_mesh_vert_id_map = load.object_mesh_vert_id_map
    self.vertices_per_tile = load.vertices_per_tile
    _G.BuildController:deserialize(load.build_controller)
    _G.spawn_point_x, _G.spawn_point_y = load.spawn_point_x, load.spawn_point_y
    _G.offset_x, _G.offset_y = load.offset_x, load.offset_y
    local campfireClass = _G.getClassByName(load.campfire.class_name)
    if campfireClass then
        campfireClass:deserialize(load.campfire)
    else
        print("Campfire is not deserialized")
        love.quit()
    end
    _G.stockpile:deserialize(load.stockpile_controller)
    self.chunk_objects = self:deserializeChunkObjects(load.chunk_objects)
    self.object = self:deserializeObjects(load.object)
    self.scale_x = load.scale_x
    self.view_xview = load.view_xview
    self.view_yview = load.view_yview
    self.map:deserialize(load.map)
    self.map:forceRefresh()
end

return State
