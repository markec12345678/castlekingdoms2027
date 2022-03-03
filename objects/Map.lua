local Map = _G.class('Map')

function Map:initialize()
    self.heightmap = newAutotable(4)
    self.shadowmap = newAutotable(4)
    self.buildingheightmap = newAutotable(4)
    self.terrain_tile = newAutotable(4)
    self.terrain = newAutotable(2)
    -- TODO: Make it dynamic
    self.walking_heightmap = _G.ffi.new("unsigned short[2048][2048]", {})
end

function Map:setWalkable(gx, gy, walkable)
    _G.channel.map_update:push({gx, gy, walkable})
end

function Map:setHeight(gx, gy, height)
    self.walking_heightmap[gx][gy] = height
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

function Map:serialize()
    local data = {}
    data.terrain = self:serializeTerrain()
    data.heightmap = self:serializeHeightmap()
    return data
end

function Map:deserialize(data)
    self:deserializeTerrain(data.terrain)
    self:deserializeHeightmap(data.heightmap)
end

return Map
