local object,object_batch, active_entities, tile_quads = ...
local Object = require("objects.Object")

local fr_walking_east = {
    tile_quads[1857],tile_quads[1858],tile_quads[1859],
    tile_quads[1860],tile_quads[1861],tile_quads[1862],
    tile_quads[1863],tile_quads[1864],
}
local fr_walking_north = {
    tile_quads[1865],tile_quads[1866],tile_quads[1867],
    tile_quads[1868],tile_quads[1869],tile_quads[1870],
    tile_quads[1871],tile_quads[1872],
}
local fr_walking_northeast = {
    tile_quads[1865],tile_quads[1866],tile_quads[1867],
    tile_quads[1868],tile_quads[1869],tile_quads[1870],
    tile_quads[1871],tile_quads[1872],
}