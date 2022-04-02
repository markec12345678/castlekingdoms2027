local Map = _G.class('Map')

function Map:initialize()
    self.heightmap = newAutotable(4)
    self.shadowmap = newAutotable(4)
    self.buildingheightmap = newAutotable(4)
    self.terrain_tile = newAutotable(4)
    self.terrain = newAutotable(2)
    self.water = newAutotable(2)
    self.collision_map = _G.ffi.new("unsigned char[2048][2048]", {})
    -- TODO: Make it dynamic
    self.walking_heightmap = _G.ffi.new("unsigned short[2048][2048]", {})
end

function Map:setWalkable(gx, gy, walkable)
    walkable = walkable or 0
    if gx >= 0 and gx < 2048 and gy >= 0 and gy < 2048 then
        _G.channel.map_update:push({gx, gy, walkable})
        self.collision_map[gx][gy] = walkable
    else
        print("Trying to set out of bounds as walkable..", gx, gy)
    end
end

function Map:getWalkable(gx, gy)
    if gx >= 1 and gx < 2048 and gy >= 0 and gy < 2048 then
        return self.collision_map[gx][gy]
    end
end

function Map:setHeight(gx, gy, height)
    self.walking_heightmap[gx][gy] = height
end

function Map:setWater(gx, gy)
    local pgx, pgy = gx, gy
    for i = -1, 1 do
        for o = -1, 1 do
            if i == 1 or i == -1 or o == 1 or o == -1 then
                _G.terrainSetTileAt(pgx + i, pgy + o, _G.terrain_biome.sea_beach, _G.terrain_biome.abundant_grass)
            else
                _G.state.map:setWalkable(pgx + i, pgy + o, 1)
                self.water[gx][gy] = true
                _G.terrainSetTileAt(pgx + i, pgy + o, _G.terrain_biome.sea)
            end
        end
    end
end

function Map:isWaterAt(gx, gy)
    return self.water[gx][gy]
end

function Map:serializeTerrain()
    local data = {}
    for cx = 0, _G.chunks_wide - 1 do
        data[cx] = {}
        if self.terrain[cx] then
            for cy = 0, _G.chunks_high - 1 do
                if self.terrain[cx][cy] then
                    data[cx][cy] = {}
                    for i = 0, _G.chunk_width - 1, 1 do
                        data[cx][cy][i] = {}
                        for o = 0, _G.chunk_width - 1, 1 do
                            data[cx][cy][i][o] = self.terrain[cx][cy][i][o]
                        end
                    end
                end
            end
        end
    end
    return data
end

function Map:serializeHeightmap()
    local data = {}
    for cx = 0, _G.chunks_wide - 1 do
        data[cx] = {}
        if self.heightmap[cx] then
            for cy = 0, _G.chunks_high - 1 do
                if self.heightmap[cx][cy] then
                    data[cx][cy] = {}
                    for i = 0, _G.chunk_width - 1, 1 do
                        data[cx][cy][i] = {}
                        for o = 0, _G.chunk_width - 1, 1 do
                            data[cx][cy][i][o] = self.heightmap[cx][cy][i][o]
                        end
                    end
                end
            end
        end
    end
    return data
end

function Map:serializeBuildingHeightmap()
    local data = {}
    for cx = 0, _G.chunks_wide - 1 do
        data[cx] = {}
        if self.buildingheightmap[cx] then
            for cy = 0, _G.chunks_high - 1 do
                if self.buildingheightmap[cx][cy] then
                    data[cx][cy] = {}
                    for i = 0, _G.chunk_width - 1, 1 do
                        data[cx][cy][i] = {}
                        for o = 0, _G.chunk_width - 1, 1 do
                            data[cx][cy][i][o] = self.buildingheightmap[cx][cy][i][o]
                        end
                    end
                end
            end
        end
    end
    return data
end

function Map:serializeCollisionMap()
    local data = {}
    for x = 0, 2048 do
        data[x] = {}
        for y = 0, 2048 do
            data[x][y] = self:getWalkable(x, y)
        end
    end
    return data
end

function Map:deserializeCollisionMap(data)
    for x = 0, 2048 - 1 do
        for y = 0, 2048 - 1 do
            self:setWalkable(x, y, data[x][y])
        end
    end
    return data
end

function Map:forceRefresh()
    for cx = 0, _G.chunks_wide - 1 do
        for cy = 0, _G.chunks_high - 1 do
            for i = 0, _G.chunk_width - 1, 1 do
                for o = 0, _G.chunk_width - 1, 1 do
                    _G.schedule_terrain_update(cx, cy, i, o)
                end
            end
        end
    end
end

function Map:deserializeTerrain(data)
    for cx = 0, _G.chunks_wide - 1 do
        for cy = 0, _G.chunks_high - 1 do
            self.terrain[cx][cy] = newAutotable(2)
            for i = 0, _G.chunk_width - 1, 1 do
                for o = 0, _G.chunk_width - 1, 1 do
                    if data[cx] and data[cx][cy] and data[cx][cy][i] and data[cx][cy][i][o] then
                        self.terrain[cx][cy][i][o] = data[cx][cy][i][o]
                    end
                end
            end
        end
    end
end

function Map:deserializeHeightmap(data)
    for cx = 0, _G.chunks_wide - 1 do
        for cy = 0, _G.chunks_high - 1 do
            for i = 0, _G.chunk_width - 1, 1 do
                for o = 0, _G.chunk_width - 1, 1 do
                    if data[cx] and data[cx][cy] and data[cx][cy][i] and data[cx][cy][i][o] then
                        self.heightmap[cx][cy][i][o] = data[cx][cy][i][o]
                    end
                end
            end
        end
    end
end

function Map:deserializeBuildingHeightmap(data)
    for cx = 0, _G.chunks_wide - 1 do
        for cy = 0, _G.chunks_high - 1 do
            for i = 0, _G.chunk_width - 1, 1 do
                for o = 0, _G.chunk_width - 1, 1 do
                    if data[cx] and data[cx][cy] and data[cx][cy][i] and data[cx][cy][i][o] then
                        self.buildingheightmap[cx][cy][i][o] = data[cx][cy][i][o]
                    end
                end
            end
        end
    end
end

function Map:serialize()
    local data = {}
    data.terrain = self:serializeTerrain()
    data.heightmap = self:serializeHeightmap()
    data.collision = self:serializeCollisionMap()
    data.buildingheightmap = self:serializeBuildingHeightmap()
    return data
end

function Map:deserialize(data)
    self:deserializeTerrain(data.terrain)
    self:deserializeHeightmap(data.heightmap)
    self:deserializeCollisionMap(data.collision)
    self:deserializeBuildingHeightmap(data.buildingheightmap)
end

return Map
