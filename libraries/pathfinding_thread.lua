local id = ...
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
_G.collisionMap = ffi.new("unsigned char[2048][2048]", {})
local Grid = require("libraries.jumper.grid") -- The grid class
local Pathfinder = require("libraries.jumper.pathfinder") -- The pathfinder class
local bitser = require("libraries.bitser")
local grid = Grid(_G.collisionMap)
local finder = Pathfinder(grid, 'JPS', 0)
local channel = {}
channel.request = love.thread.getChannel("request")
channel.receive = love.thread.getChannel("receive")
channel.mapUpdate = love.thread.getChannel("mapUpdate" .. id)

local mapUpdate
-- Wait for first map update
mapUpdate = channel.mapUpdate:demand()
_G.nodes[mapUpdate[1]][mapUpdate[2]].walkable = mapUpdate[3]
-- We got first map update
-- now wait for the channel to fill up
-- with map updates while loading the map
love.timer.sleep(0.5)
-- We've probably got all the map updates
-- so let's apply them before we start pathfinding
repeat
    mapUpdate = channel.mapUpdate:pop()
    if mapUpdate then
        _G.nodes[mapUpdate[1]][mapUpdate[2]].walkable = mapUpdate[3]
    else
        break
    end
until (not mapUpdate)

while true do
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
        -- Check if start or end node is walkable
        if _G.nodes[pathRequest.sx][pathRequest.sy].walkable == 1 or _G.nodes[pathRequest.ex][pathRequest.ey].walkable == 1 then
            -- it's not walkable, we're probably missing updates from the main thread!
            love.timer.sleep(0.1)
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
                noPathFound.found = false
                channel.receive:push(bitser.dumps(noPathFound))
                goto continue
            end
        end
        local path = finder:getPath(pathRequest.sx, pathRequest.sy, pathRequest.ex, pathRequest.ey)
        local pathToSend = {}
        pathToSend.sx = pathRequest.sx
        pathToSend.sy = pathRequest.sy
        pathToSend.ex = pathRequest.ex
        pathToSend.ey = pathRequest.ey
        pathToSend.nodes = {}
        if path then
            pathToSend.found = true
            for node, count in path:nodes() do
                pathToSend.nodes[count] = {node._x, node._y}
            end
        end

        channel.receive:push(bitser.dumps(pathToSend))
        ::continue::
    end
end
