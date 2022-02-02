local ffi = require('ffi')
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
collision_map = ffi.new("unsigned char[2048][2048]", {})
local Grid = require("libraries.jumper.grid") -- The grid class
local Pathfinder = require("libraries.jumper.pathfinder") -- The pathfinder class
local bitser = require("libraries.bitser")
local grid = Grid(collision_map)
local finder = Pathfinder(grid, 'JPS', 0)
local channel = {}
channel.request = love.thread.getChannel("request")
channel.receive = love.thread.getChannel("receive")
channel.map_update = love.thread.getChannel("map_update")

while true do
    local table = channel.request:demand()
    local map_update
    repeat
        map_update = channel.map_update:pop()
        if map_update then
            _G.nodes[map_update[1]][map_update[2]].walkable = map_update[3]
        else
            break
        end
    until (not map_update)

    local path = finder:getPath(table.sx, table.sy, table.ex, table.ey)
    local path_to_send = {}
    path_to_send.sx = table.sx
    path_to_send.sy = table.sy
    path_to_send.ex = table.ex
    path_to_send.ey = table.ey
    path_to_send.nodes = {}
    if path then
        path_to_send.found = true
        for node, count in path:nodes() do
            path_to_send.nodes[count] = {node._x, node._y}
        end
    end

    channel.receive:push(bitser.dumps(path_to_send))
end
