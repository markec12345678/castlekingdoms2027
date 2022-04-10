local terrain_table = require('terrain.terrain')
local object_table = require('objects.objects')
local terrain_batch = terrain_table.batch
local genTerrain = terrain_table.genTerrain
local active_entities = object_table.active
local object = object_table.object
local object_batch = object_table.batch
local shadow_batch = object_table.shadow
local Tree = require('objects.Environment.Tree')
local object_hashMap = {
    -- ["Tree"] = Tree:new(0,0,0,0,0,0,"")
}

local function objectClean(cx, cy)
    if true then
        return
    end -- warning temporarily disabled
    -- todo finish up here
    local save = false
    local chunk_ser = {
        terrain = {},
        objects = {}
    }
    chunk_ser.position = {cx, cy}
    local counter = 1
    for index, obj in ipairs(active_entities) do
        if obj.cx == cx and obj.cy == cy then
            chunk_ser.objects[counter] = obj:serialize()
            counter = counter + 1
        end
    end
    -- local time = love.timer.getTime()
    local filename = "chunk-test" .. cx .. "l" .. cy .. ".bin"
    -- if tstatus[cx][cy] ~= nil and tstatus[cx][cy] == 1 then print("Found:"..(bitser.loads(bitser.dumps(terrain[cx][cy])))[60][60]) end
    if status ~= nil then
        if status[cx][cy] == 1 then
            chunk_ser.terrain = terrain[cx][cy]
            status[cx][cy] = 2
            -- print(chunk_ser.terrain[2][2])
            save = true
        end
    end
    -- if save then
    --     bitser.dumpLoveFile(filename, chunk_ser)
    -- else
    --     status[cx][cy] = nil
    -- end
    -- if save then assert(inspect(bitser.loadLoveFile(filename))) end
    -- object[cx][cy] = nil
    -- object_batch[cx][cy] = nil
    shadow_batch[cx][cy] = nil
end

local function loadChunk(cx, cy)
    -- status[cx][cy] = 3
    -- for k,v in pairs(_G.state.chunk_objects[cx][cy]) do
    -- 	v:activate();
    -- end
    -- print("Activating..")
    -- update_terrain(cx,cy,chunk_ser.terrain)
    if true then
        return
    end -- warning temp disabled
    -- local chunk_ser = bitser.loadLoveFile("chunk-test" .. cx .. "l" .. cy .. ".bin")
    -- print("Loading", cx, cy)
    -- loadObjects(cx, cy, chunk_ser.objects)
end

local function chunkGarbageCollect()
    -- print(terrain[current_chunk_x+2][current_chunk_y-2][1][1])
    objectClean(current_chunk_x + 2, current_chunk_y + 2)
    objectClean(current_chunk_x + 2, current_chunk_y + 1)
    objectClean(current_chunk_x + 2, current_chunk_y)
    objectClean(current_chunk_x + 2, current_chunk_y - 1)
    objectClean(current_chunk_x + 2, current_chunk_y - 2)
    -- terrain[current_chunk_x+2][current_chunk_y-2] = nil 
    -- terrain[current_chunk_x+2][current_chunk_y-1] = nil 
    -- terrain[current_chunk_x+2][current_chunk_y] = nil 
    -- terrain[current_chunk_x+2][current_chunk_y+1] = nil 
    -- terrain[current_chunk_x+2][current_chunk_y+2] = nil 
    -- terrain_batch[current_chunk_x+2][current_chunk_y-2] = nil 
    -- terrain_batch[current_chunk_x+2][current_chunk_y-1] = nil 
    -- terrain_batch[current_chunk_x+2][current_chunk_y] = nil 
    -- terrain_batch[current_chunk_x+2][current_chunk_y+1] = nil 
    -- terrain_batch[current_chunk_x+2][current_chunk_y+2] = nil 
    -- status[current_chunk_x+2][current_chunk_y-2] = nil 
    -- status[current_chunk_x+2][current_chunk_y-1] = nil 
    -- status[current_chunk_x+2][current_chunk_y] = nil 
    -- status[current_chunk_x+2][current_chunk_y+1] = nil 
    -- status[current_chunk_x+2][current_chunk_y+2] = nil 

    objectClean(current_chunk_x - 2, current_chunk_y + 2)
    objectClean(current_chunk_x - 2, current_chunk_y + 1)
    objectClean(current_chunk_x - 2, current_chunk_y)
    objectClean(current_chunk_x - 2, current_chunk_y - 1)
    objectClean(current_chunk_x - 2, current_chunk_y - 2)
    -- terrain[current_chunk_x-2][current_chunk_y-2] = nil 
    -- terrain[current_chunk_x-2][current_chunk_y-1] = nil 
    -- terrain[current_chunk_x-2][current_chunk_y] = nil 
    -- terrain[current_chunk_x-2][current_chunk_y+1] = nil 
    -- terrain[current_chunk_x-2][current_chunk_y+2] = nil 
    -- terrain_batch[current_chunk_x-2][current_chunk_y-2] = nil 
    -- terrain_batch[current_chunk_x-2][current_chunk_y-1] = nil 
    -- terrain_batch[current_chunk_x-2][current_chunk_y] = nil 
    -- terrain_batch[current_chunk_x-2][current_chunk_y+1] = nil 
    -- terrain_batch[current_chunk_x-2][current_chunk_y+2] = nil 
    -- status[current_chunk_x-2][current_chunk_y-2] = nil 
    -- status[current_chunk_x-2][current_chunk_y-1] = nil 
    -- status[current_chunk_x-2][current_chunk_y] = nil 
    -- status[current_chunk_x-2][current_chunk_y+1] = nil 
    -- status[current_chunk_x-2][current_chunk_y+2] = nil 

    objectClean(current_chunk_x + 1, current_chunk_y - 2)
    objectClean(current_chunk_x, current_chunk_y - 2)
    objectClean(current_chunk_x - 1, current_chunk_y - 2)
    -- terrain[current_chunk_x-1][current_chunk_y-2] = nil 
    -- terrain[current_chunk_x][current_chunk_y-2] = nil 
    -- terrain[current_chunk_x+1][current_chunk_y-2] = nil 
    -- terrain_batch[current_chunk_x-1][current_chunk_y-2] = nil 
    -- terrain_batch[current_chunk_x][current_chunk_y-2] = nil 
    -- terrain_batch[current_chunk_x+1][current_chunk_y-2] = nil 
    -- status[current_chunk_x-1][current_chunk_y-2] = nil 
    -- status[current_chunk_x][current_chunk_y-2] = nil 
    -- status[current_chunk_x+1][current_chunk_y-2] = nil 

    objectClean(current_chunk_x + 1, current_chunk_y + 2)
    objectClean(current_chunk_x, current_chunk_y + 2)
    objectClean(current_chunk_x - 1, current_chunk_y + 2)
    -- terrain[current_chunk_x-1][current_chunk_y+2] = nil 
    -- terrain[current_chunk_x][current_chunk_y+2] = nil 
    -- terrain[current_chunk_x+1][current_chunk_y+2] = nil 
    -- terrain_batch[current_chunk_x-1][current_chunk_y+2] = nil 
    -- terrain_batch[current_chunk_x][current_chunk_y+2] = nil 
    -- terrain_batch[current_chunk_x+1][current_chunk_y+2] = nil 
    -- status[current_chunk_x-1][current_chunk_y+2] = nil 
    -- status[current_chunk_x][current_chunk_y+2] = nil 
    -- status[current_chunk_x+1][current_chunk_y+2] = nil 

end

local function chunkUnload(x, y)
    local l = _G.state.terrain_chunks
    local previous = nil
    local first = true
    while l do
        if (l.chunkx == x and l.chunky == y) then
            l.chunkx = nil
            l.chunky = nil
            l.next = nil
            if first == true then
                first = false
            elseif first == false then
                previous.next = l.next
            end
        end
        previous = l
        l = l.next
    end
end

local function chunkUpdateList()
    local l = _G.state.terrain_chunks
    while l do
        chunkUnload(l.chunkx, l.chunky)
        l = l.next
    end
    local chunk_width_in_pixels = _G.chunk_width * _G.tile_width * _G.state.scale_x
    local chunk_height_in_pixels = _G.chunk_height * _G.tile_height * _G.state.scale_x
    local chunks_to_load_wide = love.graphics.getWidth() / chunk_width_in_pixels
    local chunks_to_load_high = love.graphics.getHeight() / chunk_height_in_pixels

    local loaded_1, loaded_2, loaded_3, loaded_4 = false
    for x = -math.round(chunks_to_load_wide / 2), math.round(chunks_to_load_wide / 2) do
        for y = -math.round(chunks_to_load_high / 2), math.round(chunks_to_load_high / 2) do
            _G.state.terrain_chunks = {
                next = _G.state.terrain_chunks,
                chunkx = current_chunk_x + x,
                chunky = current_chunk_y + y
            }
            if current_chunk_x + x == _G.xchunk + 1 then
                loaded_1 = true
            end
            if current_chunk_x + x == _G.xchunk - 1 then
                loaded_2 = true
            end
            if current_chunk_y + y == _G.ychunk + 1 then
                loaded_3 = true
            end
            if current_chunk_y + y == _G.ychunk - 1 then
                loaded_4 = true
            end
            -- if status[current_chunk_x + x][current_chunk_y + y] == 2 then
            loadChunk(current_chunk_x + x, current_chunk_y + y)
            -- end
        end
    end
    if not loaded_1 then
        local lx, ly = _G.xchunk + 1, _G.ychunk
        _G.state.terrain_chunks = {
            next = _G.state.terrain_chunks,
            chunkx = lx,
            chunky = ly
        }
        loadChunk(lx, ly)
    end
    if not loaded_2 then
        local lx, ly = _G.xchunk - 1, _G.ychunk
        _G.state.terrain_chunks = {
            next = _G.state.terrain_chunks,
            chunkx = lx,
            chunky = ly
        }
        loadChunk(lx, ly)
    end
    if not loaded_3 then
        local lx, ly = _G.xchunk, _G.ychunk + 1
        _G.state.terrain_chunks = {
            next = _G.state.terrain_chunks,
            chunkx = lx,
            chunky = ly
        }
        loadChunk(lx, ly)
    end
    if not loaded_4 then
        local lx, ly = _G.xchunk, _G.ychunk - 1
        _G.state.terrain_chunks = {
            next = _G.state.terrain_chunks,
            chunkx = lx,
            chunky = ly
        }
        loadChunk(lx, ly)
    end
end

return chunkUpdateList
