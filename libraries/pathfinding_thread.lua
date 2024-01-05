local id, mapWidth = ...
local ffi = require('ffi')
require("love.timer")
ffi.cdef [[
        void *calloc(size_t nitems, size_t size);
        void free(void *ptr);
        typedef struct node node;

        struct node {
            short _x,_y,_h,_g,_f;
            unsigned char walkable;
            bool _opened, _closed, init;
            node* _parent;
        };
        ]]
_G.collisionMap = ffi.new("unsigned char[" .. mapWidth .. "][" .. mapWidth .. "]", {})
local Grid = require("libraries.jumper.grid")             -- The grid class
local Pathfinder = require("libraries.jumper.pathfinder") -- The pathfinder class
local bitser = require("libraries.bitser")
local grid = Grid(_G.collisionMap)
local finder = Pathfinder(grid, 'JPS', 0)
local channel = {}
channel.request = love.thread.getChannel("request")
channel.receive = love.thread.getChannel("receive")
channel.mapUpdate = love.thread.getChannel("mapUpdate" .. id)
channel.stop = love.thread.getChannel("stop" .. id)

local mapUpdate
local count = 0
while true do
    mapUpdate = channel.mapUpdate:pop()
    if mapUpdate == "final" then
        break
    end
    if mapUpdate then
        count = count + 1
        _G.nodes[mapUpdate[1]][mapUpdate[2]].walkable = mapUpdate[3]
    end
end

local backupMapUpdates = {}

while true do
    if channel.stop:pop() then
        -- Free the memory from the pathfinding nodes
        for i = 0, mapWidth - 1 do
            ffi.C.free(_G.nodes[i])
        end
        ffi.C.free(_G.nodes)
        return
    end
    -- Wait while we get next path request, but timeout after 1 second
    -- so we can check for map updates from time to time
    local pathRequest = channel.request:demand(1)
    repeat
        mapUpdate = channel.mapUpdate:pop()
        if mapUpdate then
            _G.nodes[mapUpdate[1]][mapUpdate[2]].walkable = mapUpdate[3]
        else
            break
        end
    until (not mapUpdate)
    if pathRequest then
        if pathRequest.endNodes and #pathRequest.endNodes == 1 then
            -- Only one valid end node, use regular search
            pathRequest.ex = pathRequest.endNodes[1].x
            pathRequest.ey = pathRequest.endNodes[1].y
            pathRequest.endNodes = nil
        end
        if pathRequest.walkableNodes then
            -- Temporarily set these nodes to walkable
            -- remember them so we can revert this
            for _, v in ipairs(pathRequest.walkableNodes) do
                backupMapUpdates[#backupMapUpdates + 1] = { v[1], v[2], _G.nodes[v[1]][v[2]].walkable }
                _G.nodes[v[1]][v[2]].walkable = 0
            end
        end
        if pathRequest.endNodes then
            local path = finder:getPath(pathRequest.sx, pathRequest.sy, pathRequest.endNodes, nil, nil, true)
            if path and path.found and pathRequest.walkableNodes then
                path = path:fill()
            end
            local pathToSend = {}
            pathToSend.sx = pathRequest.sx
            pathToSend.sy = pathRequest.sy
            if pathRequest.uuid then
                pathToSend.uuid = pathRequest.uuid
            end
            pathToSend.nodes = {}
            local offsetCount = 0
            local exitedLocalBuilding = false
            if path then
                pathToSend.found = true
                for node, count in path:nodes() do
                    if not exitedLocalBuilding and pathRequest.walkableNodes then
                        local isInside = false
                        for _, wn in ipairs(pathRequest.walkableNodes) do
                            if node._x == wn[1] and node._y == wn[2] then
                                isInside = true
                            end
                        end
                        if not isInside then
                            exitedLocalBuilding = true
                            pathToSend.nodes[count - offsetCount] = { node._x, node._y }
                        else
                            offsetCount = offsetCount + 1
                        end
                    else
                        pathToSend.nodes[count - offsetCount] = { node._x, node._y }
                    end
                end
            end
            pathToSend.ex = pathRequest.endNodes[1].x
            pathToSend.ey = pathRequest.endNodes[1].y

            channel.receive:push(bitser.dumps(pathToSend))
        else -- single goal pathfinding request
            -- Check if start or end node is walkable
            if _G.nodes[pathRequest.sx][pathRequest.sy].walkable == 1 or _G.nodes[pathRequest.ex][pathRequest.ey].walkable == 1 then
                -- it's not walkable, we're probably missing updates from the main thread!
                love.timer.sleep(0.005)
                -- fetch all updates
                repeat
                    mapUpdate = channel.mapUpdate:pop()
                    if mapUpdate then
                        _G.nodes[mapUpdate[1]][mapUpdate[2]].walkable = mapUpdate[3]
                    else
                        break
                    end
                until (not mapUpdate)
                -- check again
                if _G.nodes[pathRequest.sx][pathRequest.sy].walkable == 1 or _G.nodes[pathRequest.ex][pathRequest.ey].walkable == 1 then
                    -- still unwalkable, don't bother pathfinding
                    local noPathFound = {}
                    noPathFound.sx = pathRequest.sx
                    noPathFound.sy = pathRequest.sy
                    noPathFound.ex = pathRequest.ex
                    noPathFound.ey = pathRequest.ey
                    if pathRequest.uuid then
                        noPathFound.uuid = pathRequest.uuid
                    end
                    noPathFound.found = false
                    channel.receive:push(bitser.dumps(noPathFound))
                    goto continue
                end
            end
            local path = finder:getPath(pathRequest.sx, pathRequest.sy, pathRequest.ex, pathRequest.ey)
            if path and path.found and pathRequest.walkableNodes then
                path = path:fill()
            end
            local pathToSend = {}
            pathToSend.sx = pathRequest.sx
            pathToSend.sy = pathRequest.sy
            pathToSend.ex = pathRequest.ex
            pathToSend.ey = pathRequest.ey
            if pathRequest.uuid then
                pathToSend.uuid = pathRequest.uuid
            end
            pathToSend.nodes = {}
            local offsetCount = 0
            local exitedLocalBuilding = false
            if path then
                pathToSend.found = true
                for node, count in path:nodes() do
                    if not exitedLocalBuilding and pathRequest.walkableNodes then
                        local isInside = false
                        for _, wn in ipairs(pathRequest.walkableNodes) do
                            if node._x == wn[1] and node._y == wn[2] then
                                isInside = true
                            end
                        end
                        if not isInside then
                            exitedLocalBuilding = true
                            pathToSend.nodes[count - offsetCount] = { node._x, node._y }
                        else
                            offsetCount = offsetCount + 1
                        end
                    else
                        pathToSend.nodes[count - offsetCount] = { node._x, node._y }
                    end
                end
            end

            channel.receive:push(bitser.dumps(pathToSend))
            ::continue::
        end

        -- revert overriden walkable tiles back to normal
        if next(backupMapUpdates) then
            for _, v in ipairs(backupMapUpdates) do
                _G.nodes[v[1]][v[2]].walkable = v[3]
            end
            backupMapUpdates = {}
        end
    end
end
