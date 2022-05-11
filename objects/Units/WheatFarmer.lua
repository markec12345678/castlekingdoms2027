local _, _ = ...
local Unit = require("objects.Units.Unit")
local Object = require("objects.Object")
local indexQuads = _G.indexQuads
local anim = _G.anim

local harvestFx = {_G.fx["harvest_01"], _G.fx["harvest_02"], _G.fx["harvest_03"], _G.fx["harvest_04"],
                   _G.fx["harvest_05"], _G.fx["harvest_06"]}

local hoeFx = {_G.fx["hoe_01"], _G.fx["hoe_02"], _G.fx["hoe_03"], _G.fx["hoe_04"], _G.fx["hoe_05"], _G.fx["hoe_06"],
               _G.fx["hoe_07"]}

local fr = {
    walking_apples_east = indexQuads("body_farmer_walk_apples_e", 16),
    walking_apples_north = indexQuads("body_farmer_walk_apples_n", 16),
    walking_apples_west = indexQuads("body_farmer_walk_apples_w", 16),
    walking_apples_south = indexQuads("body_farmer_walk_apples_s", 16),
    walking_apples_northeast = indexQuads("body_farmer_walk_apples_ne", 16),
    walking_apples_northwest = indexQuads("body_farmer_walk_apples_nw", 16),
    walking_apples_southeast = indexQuads("body_farmer_walk_apples_se", 16),
    walking_apples_southwest = indexQuads("body_farmer_walk_apples_sw", 16),
    walking_wheat_east = indexQuads("body_farmer_walk_wheat_e", 16),
    walking_wheat_north = indexQuads("body_farmer_walk_wheat_n", 16),
    walking_wheat_west = indexQuads("body_farmer_walk_wheat_w", 16),
    walking_wheat_south = indexQuads("body_farmer_walk_wheat_s", 16),
    walking_wheat_northeast = indexQuads("body_farmer_walk_wheat_ne", 16),
    walking_wheat_northwest = indexQuads("body_farmer_walk_wheat_nw", 16),
    walking_wheat_southeast = indexQuads("body_farmer_walk_wheat_se", 16),
    walking_wheat_southwest = indexQuads("body_farmer_walk_wheat_sw", 16),
    walking_east = indexQuads("body_farmer_walk_e", 16),
    walking_north = indexQuads("body_farmer_walk_n", 16),
    walking_northeast = indexQuads("body_farmer_walk_ne", 16),
    walking_northwest = indexQuads("body_farmer_walk_nw", 16),
    walking_south = indexQuads("body_farmer_walk_s", 16),
    walking_southeast = indexQuads("body_farmer_walk_se", 16),
    walking_southwest = indexQuads("body_farmer_walk_sw", 16),
    walking_west = indexQuads("body_farmer_walk_w", 16),
    -- hoe
    gather_walk_hoe_north = indexQuads("body_farmer_hoe_n", 8),
    gather_walk_hoe_west = indexQuads("body_farmer_hoe_w", 8),
    gather_walk_hoe_south = indexQuads("body_farmer_hoe_s", 8),
    gather_walk_hoe_east = indexQuads("body_farmer_hoe_e", 8),
    gather_walk_hoe_northeast = indexQuads("body_farmer_hoe_ne", 8),
    gather_walk_hoe_northwest = indexQuads("body_farmer_hoe_nw", 8),
    gather_walk_hoe_southeast = indexQuads("body_farmer_hoe_se", 8),
    gather_walk_hoe_southwest = indexQuads("body_farmer_hoe_sw", 8),
    gather_hoe_north = indexQuads("body_farmer_hoe_n", 12, 9),
    gather_hoe_west = indexQuads("body_farmer_hoe_w", 12, 9),
    gather_hoe_south = indexQuads("body_farmer_hoe_s", 12, 9),
    gather_hoe_east = indexQuads("body_farmer_hoe_e", 12, 9),
    gather_hoe_northeast = indexQuads("body_farmer_hoe_ne", 12, 9),
    gather_hoe_northwest = indexQuads("body_farmer_hoe_nw", 12, 9),
    gather_hoe_southeast = indexQuads("body_farmer_hoe_se", 12, 9),
    gather_hoe_southwest = indexQuads("body_farmer_hoe_sw", 12, 9),
    gather_hoe_part2_north = indexQuads("body_farmer_hoe_n", 16, 13),
    gather_hoe_part2_west = indexQuads("body_farmer_hoe_w", 16, 13),
    gather_hoe_part2_south = indexQuads("body_farmer_hoe_s", 16, 13),
    gather_hoe_part2_east = indexQuads("body_farmer_hoe_e", 16, 13),
    gather_hoe_part2_northeast = indexQuads("body_farmer_hoe_ne", 16, 13),
    gather_hoe_part2_northwest = indexQuads("body_farmer_hoe_nw", 16, 13),
    gather_hoe_part2_southeast = indexQuads("body_farmer_hoe_se", 16, 13),
    gather_hoe_part2_southwest = indexQuads("body_farmer_hoe_sw", 16, 13),
    -- moving with scythe
    gather_moving_scythe_1_north = indexQuads("body_farmer_mow_scythe_n", 6),
    gather_moving_scythe_1_west = indexQuads("body_farmer_mow_scythe_w", 6),
    gather_moving_scythe_1_south = indexQuads("body_farmer_mow_scythe_s", 6),
    gather_moving_scythe_1_east = indexQuads("body_farmer_mow_scythe_e", 6),
    gather_moving_scythe_1_northeast = indexQuads("body_farmer_mow_scythe_ne", 6),
    gather_moving_scythe_1_northwest = indexQuads("body_farmer_mow_scythe_nw", 6),
    gather_moving_scythe_1_southeast = indexQuads("body_farmer_mow_scythe_se", 6),
    gather_moving_scythe_1_southwest = indexQuads("body_farmer_mow_scythe_sw", 6),
    -- moving with scythe
    gather_moving_scythe_2_north = indexQuads("body_farmer_mow_scythe_n", 9, 7),
    gather_moving_scythe_2_west = indexQuads("body_farmer_mow_scythe_w", 9, 7),
    gather_moving_scythe_2_south = indexQuads("body_farmer_mow_scythe_s", 9, 7),
    gather_moving_scythe_2_east = indexQuads("body_farmer_mow_scythe_e", 9, 7),
    gather_moving_scythe_2_northeast = indexQuads("body_farmer_mow_scythe_ne", 9, 7),
    gather_moving_scythe_2_northwest = indexQuads("body_farmer_mow_scythe_nw", 9, 7),
    gather_moving_scythe_2_southeast = indexQuads("body_farmer_mow_scythe_se", 9, 7),
    gather_moving_scythe_2_southwest = indexQuads("body_farmer_mow_scythe_sw", 9, 7),
    -- moving with scythe
    gather_moving_scythe_3_north = indexQuads("body_farmer_mow_scythe_n", 16, 10),
    gather_moving_scythe_3_west = indexQuads("body_farmer_mow_scythe_w", 16, 10),
    gather_moving_scythe_3_south = indexQuads("body_farmer_mow_scythe_s", 16, 10),
    gather_moving_scythe_3_east = indexQuads("body_farmer_mow_scythe_e", 16, 10),
    gather_moving_scythe_3_northeast = indexQuads("body_farmer_mow_scythe_ne", 16, 10),
    gather_moving_scythe_3_northwest = indexQuads("body_farmer_mow_scythe_nw", 16, 10),
    gather_moving_scythe_3_southeast = indexQuads("body_farmer_mow_scythe_se", 16, 10),
    gather_moving_scythe_3_southwest = indexQuads("body_farmer_mow_scythe_sw", 16, 10),
    -- mowing scythe
    gather_scythe_north = indexQuads("body_farmer_mow_scythe_n", 8),
    gather_scythe_west = indexQuads("body_farmer_mow_scythe_w", 8),
    gather_scythe_south = indexQuads("body_farmer_mow_scythe_s", 8),
    gather_scythe_northeast = indexQuads("body_farmer_mow_scythe_ne", 8),
    gather_scythe_northwest = indexQuads("body_farmer_mow_scythe_nw", 8),
    gather_scythe_southeast = indexQuads("body_farmer_mow_scythe_se", 8),
    gather_scythe_southwest = indexQuads("body_farmer_mow_scythe_sw", 8),
    -- walking scythe
    gather_walk_scythe_north = indexQuads("body_farmer_walk_scythe_n", 16),
    gather_walk_scythe_west = indexQuads("body_farmer_walk_scythe_w", 16),
    gather_walk_scythe_south = indexQuads("body_farmer_walk_scythe_s", 16),
    gather_walk_scythe_northeast = indexQuads("body_farmer_walk_scythe_ne", 16),
    gather_walk_scythe_northwest = indexQuads("body_farmer_walk_scythe_nw", 16),
    gather_walk_scythe_southeast = indexQuads("body_farmer_walk_scythe_se", 16),
    gather_walk_scythe_southwest = indexQuads("body_farmer_walk_scythe_sw", 16),
    -- earthing
    gather_earthing_north = indexQuads("body_farmer_earth_n", 8),
    gather_earthing_west = indexQuads("body_farmer_earth_w", 8),
    gather_earthing_south = indexQuads("body_farmer_earth_s", 8),
    gather_earthing_northeast = indexQuads("body_farmer_earth_ne", 8),
    gather_earthing_northwest = indexQuads("body_farmer_earth_nw", 8),
    gather_earthing_southeast = indexQuads("body_farmer_earth_se", 8),
    gather_earthing_southwest = indexQuads("body_farmer_earth_sw", 8),
    -- planting
    gather_planting_north = indexQuads("body_farmer_seed_n", 16),
    gather_planting_west = indexQuads("body_farmer_seed_w", 16),
    gather_planting_south = indexQuads("body_farmer_seed_s", 16),
    gather_planting_east = indexQuads("body_farmer_seed_e", 16),
    gather_planting_northeast = indexQuads("body_farmer_seed_ne", 16),
    gather_planting_northwest = indexQuads("body_farmer_seed_nw", 16),
    gather_planting_southeast = indexQuads("body_farmer_seed_se", 16),
    gather_planting_southwest = indexQuads("body_farmer_seed_sw", 16),
    -- walk wheat
    gather_walk_wheat_north = indexQuads("body_farmer_walk_wheat_n", 16),
    gather_walk_wheat_west = indexQuads("body_farmer_walk_wheat_w", 16),
    gather_walk_wheat_south = indexQuads("body_farmer_walk_wheat_s", 16),
    gather_walk_wheat_northeast = indexQuads("body_farmer_walk_wheat_ne", 16),
    gather_walk_wheat_northwest = indexQuads("body_farmer_walk_wheat_nw", 16),
    gather_walk_wheat_southeast = indexQuads("body_farmer_walk_wheat_se", 16),
    gather_walk_wheat_southwest = indexQuads("body_farmer_walk_wheat_sw", 16),
    -- idle

    idle = indexQuads("body_farmer_idle", 16),
    idle_loop = indexQuads("body_farmer_idle", 16, 12, true)
}

local AN = {
    WALKING_APPLES_EAST = "Walking_Apples_East",
    WALKING_APPLES_NORTH = "Walking_Apples_North",
    WALKING_APPLES_WEST = "Walking_Apples_West",
    WALKING_APPLES_SOUTH = "Walking_Apples_South",
    WALKING_APPLES_NORTHEAST = "Walking_Apples_Northeast",
    WALKING_APPLES_NORTHWEST = "Walking_Apples_Northwest",
    WALKING_APPLES_SOUTHEAST = "Walking_Apples_Southeast",
    WALKING_APPLES_SOUTHWEST = "Walking_Apples_Southwest",
    WALKING_WHEAT_EAST = "Walking_Wheat_East",
    WALKING_WHEAT_NORTH = "Walking_Wheat_North",
    WALKING_WHEAT_WEST = "Walking_Wheat_West",
    WALKING_WHEAT_SOUTH = "Walking_Wheat_South",
    WALKING_WHEAT_NORTHEAST = "Walking_Wheat_Northeast",
    WALKING_WHEAT_NORTHWEST = "Walking_Wheat_Northwest",
    WALKING_WHEAT_SOUTHEAST = "Walking_Wheat_Southeast",
    WALKING_WHEAT_SOUTHWEST = "Walking_Wheat_Southwest",
    WALKING_EAST = "Walking_East",
    WALKING_NORTH = "Walking_North",
    WALKING_NORTHEAST = "Walking_Northeast",
    WALKING_NORTHWEST = "Walking_Northwest",
    WALKING_SOUTH = "Walking_South",
    WALKING_SOUTHEAST = "Walking_Southeast",
    WALKING_SOUTHWEST = "Walking_Southwest",
    WALKING_WEST = "Walking_West",
    -- hoe
    GATHER_WALK_HOE_NORTH = "Gather_Walk_Hoe_North",
    GATHER_WALK_HOE_WEST = "Gather_Walk_Hoe_West",
    GATHER_WALK_HOE_SOUTH = "Gather_Walk_Hoe_South",
    GATHER_WALK_HOE_EAST = "Gather_Walk_Hoe_East",
    GATHER_WALK_HOE_NORTHEAST = "Gather_Walk_Hoe_Northeast",
    GATHER_WALK_HOE_NORTHWEST = "Gather_Walk_Hoe_Northwest",
    GATHER_WALK_HOE_SOUTHEAST = "Gather_Walk_Hoe_Southeast",
    GATHER_WALK_HOE_SOUTHWEST = "Gather_Walk_Hoe_Southwest",
    GATHER_HOE_NORTH = "Gather_Hoe_North",
    GATHER_HOE_WEST = "Gather_Hoe_West",
    GATHER_HOE_SOUTH = "Gather_Hoe_South",
    GATHER_HOE_EAST = "Gather_Hoe_East",
    GATHER_HOE_NORTHEAST = "Gather_Hoe_Northeast",
    GATHER_HOE_NORTHWEST = "Gather_Hoe_Northwest",
    GATHER_HOE_SOUTHEAST = "Gather_Hoe_Southeast",
    GATHER_HOE_SOUTHWEST = "Gather_Hoe_Southwest",
    GATHER_HOE_PART2_NORTH = "Gather_Hoe_Part2_North",
    GATHER_HOE_PART2_WEST = "Gather_Hoe_Part2_West",
    GATHER_HOE_PART2_SOUTH = "Gather_Hoe_Part2_South",
    GATHER_HOE_PART2_EAST = "Gather_Hoe_Part2_East",
    GATHER_HOE_PART2_NORTHEAST = "Gather_Hoe_Part2_Northeast",
    GATHER_HOE_PART2_NORTHWEST = "Gather_Hoe_Part2_Northwest",
    GATHER_HOE_PART2_SOUTHEAST = "Gather_Hoe_Part2_Southeast",
    GATHER_HOE_PART2_SOUTHWEST = "Gather_Hoe_Part2_Southwest",
    -- moving with scythe
    GATHER_MOVING_SCYTHE_1_NORTH = "Gather_Moving_Scythe_1_North",
    GATHER_MOVING_SCYTHE_1_WEST = "Gather_Moving_Scythe_1_West",
    GATHER_MOVING_SCYTHE_1_SOUTH = "Gather_Moving_Scythe_1_South",
    GATHER_MOVING_SCYTHE_1_EAST = "Gather_Moving_Scythe_1_East",
    GATHER_MOVING_SCYTHE_1_NORTHEAST = "Gather_Moving_Scythe_1_Northeast",
    GATHER_MOVING_SCYTHE_1_NORTHWEST = "Gather_Moving_Scythe_1_Northwest",
    GATHER_MOVING_SCYTHE_1_SOUTHEAST = "Gather_Moving_Scythe_1_Southeast",
    GATHER_MOVING_SCYTHE_1_SOUTHWEST = "Gather_Moving_Scythe_1_Southwest",
    -- moving with scythe
    GATHER_MOVING_SCYTHE_2_NORTH = "Gather_Moving_Scythe_2_North",
    GATHER_MOVING_SCYTHE_2_WEST = "Gather_Moving_Scythe_2_West",
    GATHER_MOVING_SCYTHE_2_SOUTH = "Gather_Moving_Scythe_2_South",
    GATHER_MOVING_SCYTHE_2_EAST = "Gather_Moving_Scythe_2_East",
    GATHER_MOVING_SCYTHE_2_NORTHEAST = "Gather_Moving_Scythe_2_Northeast",
    GATHER_MOVING_SCYTHE_2_NORTHWEST = "Gather_Moving_Scythe_2_Northwest",
    GATHER_MOVING_SCYTHE_2_SOUTHEAST = "Gather_Moving_Scythe_2_Southeast",
    GATHER_MOVING_SCYTHE_2_SOUTHWEST = "Gather_Moving_Scythe_2_Southwest",
    -- moving with scythe
    GATHER_MOVING_SCYTHE_3_NORTH = "Gather_Moving_Scythe_3_North",
    GATHER_MOVING_SCYTHE_3_WEST = "Gather_Moving_Scythe_3_West",
    GATHER_MOVING_SCYTHE_3_SOUTH = "Gather_Moving_Scythe_3_South",
    GATHER_MOVING_SCYTHE_3_EAST = "Gather_Moving_Scythe_3_East",
    GATHER_MOVING_SCYTHE_3_NORTHEAST = "Gather_Moving_Scythe_3_Northeast",
    GATHER_MOVING_SCYTHE_3_NORTHWEST = "Gather_Moving_Scythe_3_Northwest",
    GATHER_MOVING_SCYTHE_3_SOUTHEAST = "Gather_Moving_Scythe_3_Southeast",
    GATHER_MOVING_SCYTHE_3_SOUTHWEST = "Gather_Moving_Scythe_3_Southwest",
    -- mowing scythe
    GATHER_SCYTHE_NORTH = "Gather_Scythe_North",
    GATHER_SCYTHE_WEST = "Gather_Scythe_West",
    GATHER_SCYTHE_SOUTH = "Gather_Scythe_South",
    GATHER_SCYTHE_NORTHEAST = "Gather_Scythe_Northeast",
    GATHER_SCYTHE_NORTHWEST = "Gather_Scythe_Northwest",
    GATHER_SCYTHE_SOUTHEAST = "Gather_Scythe_Southeast",
    GATHER_SCYTHE_SOUTHWEST = "Gather_Scythe_Southwest",
    -- walking scythe
    GATHER_WALK_SCYTHE_NORTH = "Gather_Walk_Scythe_North",
    GATHER_WALK_SCYTHE_WEST = "Gather_Walk_Scythe_West",
    GATHER_WALK_SCYTHE_SOUTH = "Gather_Walk_Scythe_South",
    GATHER_WALK_SCYTHE_NORTHEAST = "Gather_Walk_Scythe_Northeast",
    GATHER_WALK_SCYTHE_NORTHWEST = "Gather_Walk_Scythe_Northwest",
    GATHER_WALK_SCYTHE_SOUTHEAST = "Gather_Walk_Scythe_Southeast",
    GATHER_WALK_SCYTHE_SOUTHWEST = "Gather_Walk_Scythe_Southwest",
    -- earthing
    GATHER_EARTHING_NORTH = "Gather_Earthing_North",
    GATHER_EARTHING_WEST = "Gather_Earthing_West",
    GATHER_EARTHING_SOUTH = "Gather_Earthing_South",
    GATHER_EARTHING_NORTHEAST = "Gather_Earthing_Northeast",
    GATHER_EARTHING_NORTHWEST = "Gather_Earthing_Northwest",
    GATHER_EARTHING_SOUTHEAST = "Gather_Earthing_Southeast",
    GATHER_EARTHING_SOUTHWEST = "Gather_Earthing_Southwest",
    -- planting
    GATHER_PLANTING_NORTH = "Gather_Planting_North",
    GATHER_PLANTING_WEST = "Gather_Planting_West",
    GATHER_PLANTING_SOUTH = "Gather_Planting_South",
    GATHER_PLANTING_EAST = "Gather_Planting_East",
    GATHER_PLANTING_NORTHEAST = "Gather_Planting_Northeast",
    GATHER_PLANTING_NORTHWEST = "Gather_Planting_Northwest",
    GATHER_PLANTING_SOUTHEAST = "Gather_Planting_Southeast",
    GATHER_PLANTING_SOUTHWEST = "Gather_Planting_Southwest",
    -- walk wheat
    GATHER_WALK_WHEAT_NORTH = "Gather_Walk_Wheat_North",
    GATHER_WALK_WHEAT_WEST = "Gather_Walk_Wheat_West",
    GATHER_WALK_WHEAT_SOUTH = "Gather_Walk_Wheat_South",
    GATHER_WALK_WHEAT_NORTHEAST = "Gather_Walk_Wheat_Northeast",
    GATHER_WALK_WHEAT_NORTHWEST = "Gather_Walk_Wheat_Northwest",
    GATHER_WALK_WHEAT_SOUTHEAST = "Gather_Walk_Wheat_Southeast",
    GATHER_WALK_WHEAT_SOUTHWEST = "Gather_Walk_Wheat_Southwest",
    -- idle
    IDLE = "Idle",
    IDLE_LOOP = "Idle_Loop"
}

local an = {
    [AN.WALKING_APPLES_EAST] = fr.walking_apples_east,
    [AN.WALKING_APPLES_NORTH] = fr.walking_apples_north,
    [AN.WALKING_APPLES_WEST] = fr.walking_apples_west,
    [AN.WALKING_APPLES_SOUTH] = fr.walking_apples_south,
    [AN.WALKING_APPLES_NORTHEAST] = fr.walking_apples_northeast,
    [AN.WALKING_APPLES_NORTHWEST] = fr.walking_apples_northwest,
    [AN.WALKING_APPLES_SOUTHEAST] = fr.walking_apples_southeast,
    [AN.WALKING_APPLES_SOUTHWEST] = fr.walking_apples_southwest,
    [AN.WALKING_WHEAT_EAST] = fr.walking_wheat_east,
    [AN.WALKING_WHEAT_NORTH] = fr.walking_wheat_north,
    [AN.WALKING_WHEAT_WEST] = fr.walking_wheat_west,
    [AN.WALKING_WHEAT_SOUTH] = fr.walking_wheat_south,
    [AN.WALKING_WHEAT_NORTHEAST] = fr.walking_wheat_northeast,
    [AN.WALKING_WHEAT_NORTHWEST] = fr.walking_wheat_northwest,
    [AN.WALKING_WHEAT_SOUTHEAST] = fr.walking_wheat_southeast,
    [AN.WALKING_WHEAT_SOUTHWEST] = fr.walking_wheat_southwest,
    [AN.WALKING_EAST] = fr.walking_east,
    [AN.WALKING_NORTH] = fr.walking_north,
    [AN.WALKING_NORTHEAST] = fr.walking_northeast,
    [AN.WALKING_NORTHWEST] = fr.walking_northwest,
    [AN.WALKING_SOUTH] = fr.walking_south,
    [AN.WALKING_SOUTHEAST] = fr.walking_southeast,
    [AN.WALKING_SOUTHWEST] = fr.walking_southwest,
    [AN.WALKING_WEST] = fr.walking_west,
    -- hoe
    [AN.GATHER_WALK_HOE_NORTH] = fr.gather_walk_hoe_north,
    [AN.GATHER_WALK_HOE_WEST] = fr.gather_walk_hoe_west,
    [AN.GATHER_WALK_HOE_SOUTH] = fr.gather_walk_hoe_south,
    [AN.GATHER_WALK_HOE_EAST] = fr.gather_walk_hoe_east,
    [AN.GATHER_WALK_HOE_NORTHEAST] = fr.gather_walk_hoe_northeast,
    [AN.GATHER_WALK_HOE_NORTHWEST] = fr.gather_walk_hoe_northwest,
    [AN.GATHER_WALK_HOE_SOUTHEAST] = fr.gather_walk_hoe_southeast,
    [AN.GATHER_WALK_HOE_SOUTHWEST] = fr.gather_walk_hoe_southwest,
    [AN.GATHER_HOE_NORTH] = fr.gather_hoe_north,
    [AN.GATHER_HOE_WEST] = fr.gather_hoe_west,
    [AN.GATHER_HOE_SOUTH] = fr.gather_hoe_south,
    [AN.GATHER_HOE_EAST] = fr.gather_hoe_east,
    [AN.GATHER_HOE_NORTHEAST] = fr.gather_hoe_northeast,
    [AN.GATHER_HOE_NORTHWEST] = fr.gather_hoe_northwest,
    [AN.GATHER_HOE_SOUTHEAST] = fr.gather_hoe_southeast,
    [AN.GATHER_HOE_SOUTHWEST] = fr.gather_hoe_southwest,
    [AN.GATHER_HOE_PART2_NORTH] = fr.gather_hoe_part2_north,
    [AN.GATHER_HOE_PART2_WEST] = fr.gather_hoe_part2_west,
    [AN.GATHER_HOE_PART2_SOUTH] = fr.gather_hoe_part2_south,
    [AN.GATHER_HOE_PART2_EAST] = fr.gather_hoe_part2_east,
    [AN.GATHER_HOE_PART2_NORTHEAST] = fr.gather_hoe_part2_northeast,
    [AN.GATHER_HOE_PART2_NORTHWEST] = fr.gather_hoe_part2_northwest,
    [AN.GATHER_HOE_PART2_SOUTHEAST] = fr.gather_hoe_part2_southeast,
    [AN.GATHER_HOE_PART2_SOUTHWEST] = fr.gather_hoe_part2_southwest,
    -- moving with scythe
    [AN.GATHER_MOVING_SCYTHE_1_NORTH] = fr.gather_moving_scythe_1_north,
    [AN.GATHER_MOVING_SCYTHE_1_WEST] = fr.gather_moving_scythe_1_west,
    [AN.GATHER_MOVING_SCYTHE_1_SOUTH] = fr.gather_moving_scythe_1_south,
    [AN.GATHER_MOVING_SCYTHE_1_EAST] = fr.gather_moving_scythe_1_east,
    [AN.GATHER_MOVING_SCYTHE_1_NORTHEAST] = fr.gather_moving_scythe_1_northeast,
    [AN.GATHER_MOVING_SCYTHE_1_NORTHWEST] = fr.gather_moving_scythe_1_northwest,
    [AN.GATHER_MOVING_SCYTHE_1_SOUTHEAST] = fr.gather_moving_scythe_1_southeast,
    [AN.GATHER_MOVING_SCYTHE_1_SOUTHWEST] = fr.gather_moving_scythe_1_southwest,
    -- moving with scythe
    [AN.GATHER_MOVING_SCYTHE_2_NORTH] = fr.gather_moving_scythe_2_north,
    [AN.GATHER_MOVING_SCYTHE_2_WEST] = fr.gather_moving_scythe_2_west,
    [AN.GATHER_MOVING_SCYTHE_2_SOUTH] = fr.gather_moving_scythe_2_south,
    [AN.GATHER_MOVING_SCYTHE_2_EAST] = fr.gather_moving_scythe_2_east,
    [AN.GATHER_MOVING_SCYTHE_2_NORTHEAST] = fr.gather_moving_scythe_2_northeast,
    [AN.GATHER_MOVING_SCYTHE_2_NORTHWEST] = fr.gather_moving_scythe_2_northwest,
    [AN.GATHER_MOVING_SCYTHE_2_SOUTHEAST] = fr.gather_moving_scythe_2_southeast,
    [AN.GATHER_MOVING_SCYTHE_2_SOUTHWEST] = fr.gather_moving_scythe_2_southwest,
    -- moving with scythe
    [AN.GATHER_MOVING_SCYTHE_3_NORTH] = fr.gather_moving_scythe_3_north,
    [AN.GATHER_MOVING_SCYTHE_3_WEST] = fr.gather_moving_scythe_3_west,
    [AN.GATHER_MOVING_SCYTHE_3_SOUTH] = fr.gather_moving_scythe_3_south,
    [AN.GATHER_MOVING_SCYTHE_3_EAST] = fr.gather_moving_scythe_3_east,
    [AN.GATHER_MOVING_SCYTHE_3_NORTHEAST] = fr.gather_moving_scythe_3_northeast,
    [AN.GATHER_MOVING_SCYTHE_3_NORTHWEST] = fr.gather_moving_scythe_3_northwest,
    [AN.GATHER_MOVING_SCYTHE_3_SOUTHEAST] = fr.gather_moving_scythe_3_southeast,
    [AN.GATHER_MOVING_SCYTHE_3_SOUTHWEST] = fr.gather_moving_scythe_3_southwest,
    -- mowing scythe
    [AN.GATHER_SCYTHE_NORTH] = fr.gather_scythe_north,
    [AN.GATHER_SCYTHE_WEST] = fr.gather_scythe_west,
    [AN.GATHER_SCYTHE_SOUTH] = fr.gather_scythe_south,
    [AN.GATHER_SCYTHE_NORTHEAST] = fr.gather_scythe_northeast,
    [AN.GATHER_SCYTHE_NORTHWEST] = fr.gather_scythe_northwest,
    [AN.GATHER_SCYTHE_SOUTHEAST] = fr.gather_scythe_southeast,
    [AN.GATHER_SCYTHE_SOUTHWEST] = fr.gather_scythe_southwest,
    -- walking scythe
    [AN.GATHER_WALK_SCYTHE_NORTH] = fr.gather_walk_scythe_north,
    [AN.GATHER_WALK_SCYTHE_WEST] = fr.gather_walk_scythe_west,
    [AN.GATHER_WALK_SCYTHE_SOUTH] = fr.gather_walk_scythe_south,
    [AN.GATHER_WALK_SCYTHE_NORTHEAST] = fr.gather_walk_scythe_northeast,
    [AN.GATHER_WALK_SCYTHE_NORTHWEST] = fr.gather_walk_scythe_northwest,
    [AN.GATHER_WALK_SCYTHE_SOUTHEAST] = fr.gather_walk_scythe_southeast,
    [AN.GATHER_WALK_SCYTHE_SOUTHWEST] = fr.gather_walk_scythe_southwest,
    -- earthing
    [AN.GATHER_EARTHING_NORTH] = fr.gather_earthing_north,
    [AN.GATHER_EARTHING_WEST] = fr.gather_earthing_west,
    [AN.GATHER_EARTHING_SOUTH] = fr.gather_earthing_south,
    [AN.GATHER_EARTHING_NORTHEAST] = fr.gather_earthing_northeast,
    [AN.GATHER_EARTHING_NORTHWEST] = fr.gather_earthing_northwest,
    [AN.GATHER_EARTHING_SOUTHEAST] = fr.gather_earthing_southeast,
    [AN.GATHER_EARTHING_SOUTHWEST] = fr.gather_earthing_southwest,
    -- planting
    [AN.GATHER_PLANTING_NORTH] = fr.gather_planting_north,
    [AN.GATHER_PLANTING_WEST] = fr.gather_planting_west,
    [AN.GATHER_PLANTING_SOUTH] = fr.gather_planting_south,
    [AN.GATHER_PLANTING_EAST] = fr.gather_planting_east,
    [AN.GATHER_PLANTING_NORTHEAST] = fr.gather_planting_northeast,
    [AN.GATHER_PLANTING_NORTHWEST] = fr.gather_planting_northwest,
    [AN.GATHER_PLANTING_SOUTHEAST] = fr.gather_planting_southeast,
    [AN.GATHER_PLANTING_SOUTHWEST] = fr.gather_planting_southwest,
    -- walk wheat
    [AN.GATHER_WALK_WHEAT_NORTH] = fr.gather_walk_wheat_north,
    [AN.GATHER_WALK_WHEAT_WEST] = fr.gather_walk_wheat_west,
    [AN.GATHER_WALK_WHEAT_SOUTH] = fr.gather_walk_wheat_south,
    [AN.GATHER_WALK_WHEAT_NORTHEAST] = fr.gather_walk_wheat_northeast,
    [AN.GATHER_WALK_WHEAT_NORTHWEST] = fr.gather_walk_wheat_northwest,
    [AN.GATHER_WALK_WHEAT_SOUTHEAST] = fr.gather_walk_wheat_southeast,
    [AN.GATHER_WALK_WHEAT_SOUTHWEST] = fr.gather_walk_wheat_southwest,
    -- idle
    [AN.IDLE] = fr.idle,
    [AN.IDLE_LOOP] = fr.idle_loop
}

local WheatFarmer = _G.class('WheatFarmer', Unit)
function WheatFarmer:initialize(gx, gy, type)
    Unit.initialize(self, gx, gy, type)
    self.workplace = nil
    self.state = 'Find a job'
    self.marked = 0
    self.count = 1
    self.farmlandTiles = {}
    self.offsetY = -10
    self.offsetX = -5
    self.eatTimer = 0
    self.timr = 0
    self.animated = true
    self.animation = anim.newAnimation(an[AN.WALKING_WEST], 10, nil, AN.WALKING_WEST)
    self.wheat = 0
end
function WheatFarmer:dirSubUpdate()
    if self.state == "Working" then
        return
    end
    if self.moveDir == "west" then
        if self.state == "Going to stockpile" or (self.state == "Going to pick up wheat" and self.wheat > 0) then
            self.animation = anim.newAnimation(an[AN.WALKING_WHEAT_WEST], 0.05, nil, AN.WALKING_WHEAT_WEST)
        elseif self.state == "Going to seed the land" then
            self.animation = anim.newAnimation(an[AN.WALKING_APPLES_WEST], 0.05, nil, AN.WALKING_APPLES_WEST)
        else
            self.animation = anim.newAnimation(an[AN.WALKING_WEST], 0.05, nil, AN.WALKING_WEST)
        end
    elseif self.moveDir == "southwest" then
        if self.state == "Going to stockpile" or (self.state == "Going to pick up wheat" and self.wheat > 0) then
            self.animation = anim.newAnimation(an[AN.WALKING_WHEAT_SOUTHWEST], 0.05, nil, AN.WALKING_WHEAT_SOUTHWEST)
        elseif self.state == "Going to seed the land" then
            self.animation = anim.newAnimation(an[AN.WALKING_APPLES_SOUTHWEST], 0.05, nil, AN.WALKING_APPLES_SOUTHWEST)
        else
            self.animation = anim.newAnimation(an[AN.WALKING_SOUTHWEST], 0.05, nil, AN.WALKING_SOUTHWEST)
        end
    elseif self.moveDir == "northwest" then
        if self.state == "Going to stockpile" or (self.state == "Going to pick up wheat" and self.wheat > 0) then
            self.animation = anim.newAnimation(an[AN.WALKING_WHEAT_NORTHWEST], 0.05, nil, AN.WALKING_WHEAT_NORTHWEST)
        elseif self.state == "Going to seed the land" then
            self.animation = anim.newAnimation(an[AN.WALKING_APPLES_NORTHWEST], 0.05, nil, AN.WALKING_APPLES_NORTHWEST)
        else
            self.animation = anim.newAnimation(an[AN.WALKING_NORTHWEST], 0.05, nil, AN.WALKING_NORTHWEST)
        end
    elseif self.moveDir == "north" then
        if self.state == "Going to stockpile" or (self.state == "Going to pick up wheat" and self.wheat > 0) then
            self.animation = anim.newAnimation(an[AN.WALKING_WHEAT_NORTH], 0.05, nil, AN.WALKING_WHEAT_NORTH)
        elseif self.state == "Going to seed the land" then
            self.animation = anim.newAnimation(an[AN.WALKING_APPLES_NORTH], 0.05, nil, AN.WALKING_APPLES_NORTH)
        else
            self.animation = anim.newAnimation(an[AN.WALKING_NORTH], 0.05, nil, AN.WALKING_NORTH)
        end
    elseif self.moveDir == "south" then
        if self.state == "Going to stockpile" or (self.state == "Going to pick up wheat" and self.wheat > 0) then
            self.animation = anim.newAnimation(an[AN.WALKING_WHEAT_SOUTH], 0.05, nil, AN.WALKING_WHEAT_SOUTH)
        elseif self.state == "Going to seed the land" then
            self.animation = anim.newAnimation(an[AN.WALKING_APPLES_SOUTH], 0.05, nil, AN.WALKING_APPLES_SOUTH)
        else
            self.animation = anim.newAnimation(an[AN.WALKING_SOUTH], 0.05, nil, AN.WALKING_SOUTH)
        end
    elseif self.moveDir == "east" then
        if self.state == "Going to stockpile" or (self.state == "Going to pick up wheat" and self.wheat > 0) then
            self.animation = anim.newAnimation(an[AN.WALKING_WHEAT_EAST], 0.05, nil, AN.WALKING_WHEAT_EAST)
        elseif self.state == "Going to seed the land" then
            self.animation = anim.newAnimation(an[AN.WALKING_APPLES_EAST], 0.05, nil, AN.WALKING_APPLES_EAST)
        else
            self.animation = anim.newAnimation(an[AN.WALKING_EAST], 0.05, nil, AN.WALKING_EAST)
        end
    elseif self.moveDir == "southeast" then
        if self.state == "Going to stockpile" or (self.state == "Going to pick up wheat" and self.wheat > 0) then
            self.animation = anim.newAnimation(an[AN.WALKING_WHEAT_SOUTHEAST], 0.05, nil, AN.WALKING_WHEAT_SOUTHEAST)
        elseif self.state == "Going to seed the land" then
            self.animation = anim.newAnimation(an[AN.WALKING_APPLES_SOUTHEAST], 0.05, nil, AN.WALKING_APPLES_SOUTHEAST)
        else
            self.animation = anim.newAnimation(an[AN.WALKING_SOUTHEAST], 0.05, nil, AN.WALKING_SOUTHEAST)
        end
    elseif self.moveDir == "northeast" then
        if self.state == "Going to stockpile" or (self.state == "Going to pick up wheat" and self.wheat > 0) then
            self.animation = anim.newAnimation(an[AN.WALKING_WHEAT_NORTHEAST], 0.05, nil, AN.WALKING_WHEAT_NORTHEAST)
        elseif self.state == "Going to seed the land" then
            self.animation = anim.newAnimation(an[AN.WALKING_APPLES_NORTHEAST], 0.05, nil, AN.WALKING_APPLES_NORTHEAST)
        else
            self.animation = anim.newAnimation(an[AN.WALKING_NORTHEAST], 0.05, nil, AN.WALKING_NORTHEAST)
        end
    end
end
function WheatFarmer:jobUpdate()
    _G.removeObjectAt(self.lrcx, self.lrcy, self.lrx, self.lry, self)
end
function WheatFarmer:anchorWorkPosition()
    self.fx = self.waypointX * 1000
    self.fy = self.waypointY * 1000
    self.gy = math.round(self.fx * 0.001)
    self.gy = math.round(self.fy * 0.001)
end
function WheatFarmer:load(data)
    Object.deserialize(self, data)
    Unit.load(self, data)
    local farmlandTiles = {}
    for _, ftile in ipairs(data.farmlandTiles) do
        if ftile == false then
            farmlandTiles[#farmlandTiles + 1] = ftile
        else
            farmlandTiles[#farmlandTiles + 1] = _G.state:dereferenceObject(ftile)
        end
    end
    self.farmlandTiles = farmlandTiles
    if data.resourceTile then
        self.resourceTile = _G.state:dereferenceObject(data.resourceTile)
    end
    local anData = data.animation
    if anData then
        local animId = anData.animationIdentifier
        self.animationIdentifier = animId
        local seedLandAnimations = {
            [AN.GATHER_PLANTING_SOUTH] = true,
            [AN.GATHER_PLANTING_NORTH] = true,
            [AN.GATHER_PLANTING_EAST] = true,
            [AN.GATHER_PLANTING_NORTHEAST] = true,
            [AN.GATHER_PLANTING_SOUTHEAST] = true
        }
        local callback
        if seedLandAnimations[animId] then
            -- seed land sequence
            callback = function()
                self:seedLandCallback()
            end
        end
        local hoeLandAnimations_1 = {
            [AN.GATHER_WALK_HOE_SOUTH] = true,
            [AN.GATHER_WALK_HOE_NORTH] = true,
            [AN.GATHER_WALK_HOE_EAST] = true,
            [AN.GATHER_WALK_HOE_NORTHEAST] = true,
            [AN.GATHER_WALK_HOE_SOUTHEAST] = true
        }
        if hoeLandAnimations_1[animId] then
            -- hoe land sequence 1
            callback = function()
                self:hoeLandCallback(1)
            end
        end
        local hoeLandAnimations_2 = {
            [AN.GATHER_HOE_SOUTH] = true,
            [AN.GATHER_HOE_NORTH] = true,
            [AN.GATHER_HOE_EAST] = true,
            [AN.GATHER_HOE_NORTHEAST] = true,
            [AN.GATHER_HOE_SOUTHEAST] = true
        }
        if hoeLandAnimations_2[animId] then
            -- hoe land sequence 2
            callback = function()
                self:hoeLandCallback(2)
            end
        end
        local hoeLandAnimations_3 = {
            [AN.GATHER_HOE_PART2_SOUTH] = true,
            [AN.GATHER_HOE_PART2_NORTH] = true,
            [AN.GATHER_HOE_PART2_EAST] = true,
            [AN.GATHER_HOE_PART2_NORTHEAST] = true,
            [AN.GATHER_HOE_PART2_SOUTHEAST] = true
        }
        if hoeLandAnimations_3[animId] then
            -- hoe land sequence 3
            callback = function()
                self:hoeLandCallback(3)
            end
        end
        local scytheLandAnimations_1 = {
            [AN.GATHER_MOVING_SCYTHE_1_SOUTH] = true,
            [AN.GATHER_MOVING_SCYTHE_1_NORTH] = true,
            [AN.GATHER_MOVING_SCYTHE_1_EAST] = true,
            [AN.GATHER_MOVING_SCYTHE_1_NORTHEAST] = true,
            [AN.GATHER_MOVING_SCYTHE_1_SOUTHEAST] = true
        }
        if scytheLandAnimations_1[animId] then
            -- scythe land sequence 3
            callback = function()
                self:scytheLandCallback(1)
            end
        end
        local scytheLandAnimations_2 = {
            [AN.GATHER_MOVING_SCYTHE_2_SOUTH] = true,
            [AN.GATHER_MOVING_SCYTHE_2_NORTH] = true,
            [AN.GATHER_MOVING_SCYTHE_2_EAST] = true,
            [AN.GATHER_MOVING_SCYTHE_2_NORTHEAST] = true,
            [AN.GATHER_MOVING_SCYTHE_2_SOUTHEAST] = true
        }
        if scytheLandAnimations_2[animId] then
            -- scythe land sequence 3
            callback = function()
                self:scytheLandCallback(2)
            end
        end
        local scytheLandAnimations_3 = {
            [AN.GATHER_MOVING_SCYTHE_3_SOUTH] = true,
            [AN.GATHER_MOVING_SCYTHE_3_NORTH] = true,
            [AN.GATHER_MOVING_SCYTHE_3_EAST] = true,
            [AN.GATHER_MOVING_SCYTHE_3_NORTHEAST] = true,
            [AN.GATHER_MOVING_SCYTHE_3_SOUTHEAST] = true
        }
        if scytheLandAnimations_3[animId] then
            -- scythe land sequence 3
            callback = function()
                self:scytheLandCallback(3)
            end
        end
        self.animation = anim.newAnimation(an[anData.animationIdentifier], 1, callback, anData.animationIdentifier)
        self.animation:deserialize(anData)
    end
    if self.path == 2 then
        self.path = 0
        self:clearPath()
        self:requestPath(self.endx, self.endy)
    end
end
function WheatFarmer:serialize()
    local data = {}
    local unitData = Unit.serialize(self)
    for k, v in pairs(unitData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    if self.animation then
        data.animation = self.animation:serialize()
    end
    data.state = self.state
    data.count = self.count
    data.eatTimer = self.eatTimer
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    data.wheat = self.wheat
    data.storeTimer = self.storeTimer
    local farmlandTilesRaw = {}
    for _, tile in ipairs(self.farmlandTiles) do
        if tile then
            farmlandTilesRaw[#farmlandTilesRaw + 1] = _G.state:serializeObject(tile)
        else
            farmlandTilesRaw[#farmlandTilesRaw + 1] = tile
        end
    end
    if #farmlandTilesRaw > 0 then
        data.farmlandTiles = farmlandTilesRaw
    end
    if self.resourceTile then
        data.resourceTile = _G.state:serializeObject(self.resourceTile)
    end
    return data
end
function WheatFarmer:hoeLandCallback(state)
    local _, anim2, anim3 = self:hoeLandGetAnim()
    local function state_3Callback()
        self.straightWalkSpeed = 2400
        self.diagonalWalkSpeed = self.straightWalkSpeed * 1.414
        self:updatePosition()
        self.animation:pause()
        self.workplace:work(self)
        self:clearPath()
    end
    if state == 1 then
        self:anchorWorkPosition()
        self:updatePosition()
        self.moveDir = "none"
        self.animation = anim.newAnimation(an[anim2], 0.1, function()
            self.workplace:updateTiles(self.farmlandTiles)
            self.animation = anim.newAnimation(an[anim3], 0.1, function()
                state_3Callback()
            end, anim3)
        end, anim2)
    elseif state == 2 then
        self.workplace:updateTiles(self.farmlandTiles)
        _G.playSfx(self, hoeFx)
        self.animation = anim.newAnimation(an[anim3], 0.1, function()
            state_3Callback()
        end, anim3)
    elseif state == 3 then
        state_3Callback()
    else
        error("Received unknown state for hoe_land: " .. tostring(state))
    end
end
function WheatFarmer:hoeLandGetAnim()
    local anim1, anim2, anim3
    if self.state == "Working" then
        if self.moveDir == nil or self.moveDir == "none" then
            if string.find(self.animationIdentifier, "South") then
                anim1 = AN.GATHER_WALK_HOE_SOUTH
                anim2 = AN.GATHER_HOE_SOUTH
                anim3 = AN.GATHER_HOE_PART2_SOUTH
            elseif string.find(self.animationIdentifier, "North") then
                anim1 = AN.GATHER_WALK_HOE_NORTH
                anim2 = AN.GATHER_HOE_NORTH
                anim3 = AN.GATHER_HOE_PART2_NORTH
            elseif string.find(self.animationIdentifier, "East") then
                anim1 = AN.GATHER_WALK_HOE_EAST
                anim2 = AN.GATHER_HOE_EAST
                anim3 = AN.GATHER_HOE_PART2_EAST
            elseif string.find(self.animationIdentifier, "Northeast") then
                anim1 = AN.GATHER_WALK_HOE_NORTHEAST
                anim2 = AN.GATHER_WALK_HOE_NORTHEAST
                anim3 = AN.GATHER_HOE_PART2_NORTHEAST
            elseif string.find(self.animationIdentifier, "Southeast") then
                anim1 = AN.GATHER_WALK_HOE_SOUTHEAST
                anim2 = AN.GATHER_HOE_SOUTHEAST
                anim3 = AN.GATHER_HOE_PART2_SOUTHEAST
            end
        elseif self.moveDir == "south" then
            anim1 = AN.GATHER_WALK_HOE_SOUTH
            anim2 = AN.GATHER_HOE_SOUTH
            anim3 = AN.GATHER_HOE_PART2_SOUTH
        elseif self.moveDir == "north" then
            anim1 = AN.GATHER_WALK_HOE_NORTH
            anim2 = AN.GATHER_HOE_NORTH
            anim3 = AN.GATHER_HOE_PART2_NORTH
        elseif self.moveDir == "east" then
            anim1 = AN.GATHER_WALK_HOE_EAST
            anim2 = AN.GATHER_HOE_EAST
            anim3 = AN.GATHER_HOE_PART2_EAST
        elseif self.moveDir == "northeast" then
            anim1 = AN.GATHER_WALK_HOE_NORTHEAST
            anim2 = AN.GATHER_HOE_NORTHEAST
            anim3 = AN.GATHER_HOE_PART2_NORTHEAST
            if self.currentTile and self:isPositionAt(self.currentTile.gx - 1, self.currentTile.gy + 2) then
                anim2 = AN.GATHER_HOE_NORTH
                anim3 = AN.GATHER_HOE_PART2_NORTH
            end
        elseif self.moveDir == "southeast" then
            anim1 = AN.GATHER_WALK_HOE_SOUTHEAST
            anim2 = AN.GATHER_HOE_SOUTHEAST
            anim3 = AN.GATHER_HOE_PART2_SOUTHEAST
        end
    else
        anim1, anim2, anim3, _, _, _ = self:hoeLandPreprocess()
    end
    if not anim1 then
        print("num 1", self.moveDir)
        error("bro")
    end
    if not anim2 then
        print("num 2", self.moveDir)
        error("bro")
    end
    if not anim3 then
        print("num 3", self.moveDir)
        error("bro")
    end
    return anim1, anim2, anim3
end
function WheatFarmer:hoeLandPreprocess()
    local anim1, anim2, anim3, skipWalking
    local futureWaypointX, futureWaypointY = self.gx, self.gy
    if self.state == "Going to hoe the land from south" or self.state == "Going to hoe the land from north" then
        skipWalking = true
    end
    if self.state == "Hoe walking to southern tile" or self.state == "Going to hoe the land from north" then
        self.moveDir = "south"
        anim1 = AN.GATHER_WALK_HOE_SOUTH
        anim2 = AN.GATHER_HOE_SOUTH
        anim3 = AN.GATHER_HOE_PART2_SOUTH
        futureWaypointY = self.gy + 1
    elseif self.state == "Hoe walking to northern tile" or self.state == "Going to hoe the land from south" then
        self.moveDir = "north"
        anim1 = AN.GATHER_WALK_HOE_NORTH
        anim2 = AN.GATHER_HOE_NORTH
        anim3 = AN.GATHER_HOE_PART2_NORTH
        futureWaypointY = self.gy - 1
    elseif self.state == "Hoe walking to eastern tile" or self.state == "Going to hoe the land from east" then
        self.moveDir = "east"
        anim1 = AN.GATHER_WALK_HOE_EAST
        anim2 = AN.GATHER_HOE_EAST
        anim3 = AN.GATHER_HOE_PART2_EAST
        futureWaypointX = self.gx + 1
    elseif self.state == "Hoe walking to northeastern tile" then
        self.moveDir = "northeast"
        anim1 = AN.GATHER_WALK_HOE_NORTHEAST
        anim2 = AN.GATHER_HOE_NORTHEAST
        anim3 = AN.GATHER_HOE_PART2_NORTHEAST
        futureWaypointX = self.gx + 1
        futureWaypointY = self.gy - 1
        if self.currentTile and self:isPositionAt(self.currentTile.gx - 1, self.currentTile.gy + 1) then
            skipWalking = true
            futureWaypointX = self.gx
            futureWaypointY = self.gy
        elseif self.currentTile and self:isPositionAt(self.currentTile.gx - 2, self.currentTile.gy + 1) then
            skipWalking = true
            futureWaypointX = self.gx
            futureWaypointY = self.gy
        elseif self.currentTile and self:isPositionAt(self.currentTile.gx - 1, self.currentTile.gy + 2) then
            anim2 = AN.GATHER_HOE_NORTH
            anim3 = AN.GATHER_HOE_PART2_NORTH
        end
    elseif self.state == "Hoe walking to southeastern tile" then
        self.moveDir = "southeast"
        anim1 = AN.GATHER_WALK_HOE_SOUTHEAST
        anim2 = AN.GATHER_HOE_SOUTHEAST
        anim3 = AN.GATHER_HOE_PART2_SOUTHEAST
        futureWaypointX = self.gx + 1
        futureWaypointY = self.gy + 1
    end
    return anim1, anim2, anim3, skipWalking, futureWaypointX, futureWaypointY
end
function WheatFarmer:hoeLand()
    local anim1, anim2, _, skipWalking, futureWaypointX, futureWaypointY = self:hoeLandPreprocess()
    self.state = "Working"
    self.hasMoveDir = true
    self.straightWalkSpeed = 0
    self.animation:resume()
    self.waypointX, self.waypointY = futureWaypointX, futureWaypointY
    if skipWalking then
        self.animation = anim.newAnimation(an[anim2], 0.1, function()
            self:hoeLandCallback(2)
        end, anim2)
    else
        self.straightWalkSpeed = 1276.7
        self.diagonalWalkSpeed = self.straightWalkSpeed * 1.414 * 1
        self:updatePosition()
        self.animation = anim.newAnimation(an[anim1], 0.1, function()
            self:hoeLandCallback(1)
        end, anim1)
    end
end
function WheatFarmer:seedLandCallback()
    self:anchorWorkPosition()
    self:updatePosition()
    self.moveDir = "none"
    self.straightWalkSpeed = 2400
    self.diagonalWalkSpeed = self.straightWalkSpeed * 1.414
    self.animation:pause()
    self.workplace:updateTiles(self.farmlandTiles)
    self.workplace:work(self)
    self:clearPath()
end
function WheatFarmer:seedLand()
    local anim1, skipWalking
    local futureWaypointX, futureWaypointY = self.gx, self.gy
    if self.state == "Going to seed the land from south" or self.state == "Going to seed the land from north" then
        skipWalking = true
    end
    if self.state == "Seed walking to southern tile" or self.state == "Going to seed the land from north" then
        self.moveDir = "south"
        anim1 = AN.GATHER_PLANTING_SOUTH
        futureWaypointY = self.gy + 1
    elseif self.state == "Seed walking to northern tile" or self.state == "Going to seed the land from south" then
        self.moveDir = "north"
        anim1 = AN.GATHER_PLANTING_NORTH
        futureWaypointY = self.gy - 1
    elseif self.state == "Seed walking to eastern tile" or self.state == "Going to seed the land from east" then
        self.moveDir = "east"
        anim1 = AN.GATHER_PLANTING_EAST
        futureWaypointX = self.gx + 1
    elseif self.state == "Seed walking to northeastern tile" then
        self.moveDir = "northeast"
        anim1 = AN.GATHER_PLANTING_NORTHEAST
        futureWaypointX = self.gx + 1
        futureWaypointY = self.gy - 1
        if self.currentTile and self:isPositionAt(self.currentTile.gx - 1, self.currentTile.gy + 1) then
            skipWalking = true
            futureWaypointX = self.gx
            futureWaypointY = self.gy
        elseif self.currentTile and self:isPositionAt(self.currentTile.gx - 2, self.currentTile.gy + 1) then
            skipWalking = true
            futureWaypointX = self.gx
            futureWaypointY = self.gy
        end
    elseif self.state == "Seed walking to southeastern tile" then
        self.moveDir = "southeast"
        anim1 = AN.GATHER_PLANTING_SOUTHEAST
        futureWaypointX = self.gx + 1
        futureWaypointY = self.gy + 1
    end
    self.state = "Working"
    self.hasMoveDir = true
    self.animation:resume()
    self.waypointX, self.waypointY = futureWaypointX, futureWaypointY
    if skipWalking then
        self.workplace:updateTiles(self.farmlandTiles)
        self.workplace:work(self)
        self:clearPath()
    else
        self.straightWalkSpeed = 638.4
        self.diagonalWalkSpeed = self.straightWalkSpeed * 1.414
        self.animation = anim.newAnimation(an[anim1], 0.1, function()
            self:seedLandCallback()
        end, anim1)
    end
end
function WheatFarmer:scytheLandGetAnim()
    local anim1, anim2, anim3
    if self.state == "Working" then
        if self.moveDir == nil or self.moveDir == "none" then
            if string.find(self.animationIdentifier, "South") then
                anim1 = AN.GATHER_MOVING_SCYTHE_1_SOUTH
                anim2 = AN.GATHER_MOVING_SCYTHE_2_SOUTH
                anim3 = AN.GATHER_MOVING_SCYTHE_3_SOUTH
            elseif string.find(self.animationIdentifier, "North") then
                anim1 = AN.GATHER_MOVING_SCYTHE_1_NORTH
                anim2 = AN.GATHER_MOVING_SCYTHE_2_NORTH
                anim3 = AN.GATHER_MOVING_SCYTHE_3_NORTH
            elseif string.find(self.animationIdentifier, "East") then
                anim1 = AN.GATHER_MOVING_SCYTHE_1_EAST
                anim2 = AN.GATHER_MOVING_SCYTHE_2_EAST
                anim3 = AN.GATHER_MOVING_SCYTHE_3_EAST
            elseif string.find(self.animationIdentifier, "Northeast") then
                anim1 = AN.GATHER_MOVING_SCYTHE_1_NORTHEAST
                anim2 = AN.GATHER_MOVING_SCYTHE_2_NORTHEAST
                anim3 = AN.GATHER_MOVING_SCYTHE_3_NORTHEAST
            elseif string.find(self.animationIdentifier, "Southeast") then
                anim1 = AN.GATHER_MOVING_SCYTHE_1_SOUTHEAST
                anim2 = AN.GATHER_MOVING_SCYTHE_2_SOUTHEAST
                anim3 = AN.GATHER_MOVING_SCYTHE_3_SOUTHEAST
            end
        elseif self.moveDir == "south" then
            anim1 = AN.GATHER_MOVING_SCYTHE_1_SOUTH
            anim2 = AN.GATHER_MOVING_SCYTHE_2_SOUTH
            anim3 = AN.GATHER_MOVING_SCYTHE_3_SOUTH
        elseif self.moveDir == "north" then
            anim1 = AN.GATHER_MOVING_SCYTHE_1_NORTH
            anim2 = AN.GATHER_MOVING_SCYTHE_2_NORTH
            anim3 = AN.GATHER_MOVING_SCYTHE_3_NORTH
        elseif self.moveDir == "east" then
            anim1 = AN.GATHER_MOVING_SCYTHE_1_EAST
            anim2 = AN.GATHER_MOVING_SCYTHE_2_EAST
            anim3 = AN.GATHER_MOVING_SCYTHE_3_EAST
        elseif self.moveDir == "northeast" then
            anim1 = AN.GATHER_MOVING_SCYTHE_1_NORTHEAST
            anim2 = AN.GATHER_MOVING_SCYTHE_2_NORTHEAST
            anim3 = AN.GATHER_MOVING_SCYTHE_3_NORTHEAST
            if self.currentTile and self:isPositionAt(self.currentTile.gx - 1, self.currentTile.gy + 2) then
                anim2 = AN.GATHER_HOE_NORTH
                anim3 = AN.GATHER_HOE_PART2_NORTH
            end
        elseif self.moveDir == "southeast" then
            anim1 = AN.GATHER_MOVING_SCYTHE_1_SOUTHEAST
            anim2 = AN.GATHER_MOVING_SCYTHE_2_SOUTHEAST
            anim3 = AN.GATHER_MOVING_SCYTHE_3_SOUTHEAST
        end
    else
        anim1, anim2, anim3, _, _, _ = self:scytheLandPreprocess()
    end
    return anim1, anim2, anim3
end
function WheatFarmer:scytheLandPreprocess()
    local anim1, anim2, anim3, skipWalking
    local futureWaypointX, futureWaypointY = self.gx, self.gy
    if self.state == "Going to scythe the land from south" or self.state == "Going to scythe the land from north" then
        skipWalking = true
    end
    if self.state == "Scythe walking to southern tile" or self.state == "Going to scythe the land from north" then
        self.moveDir = "south"
        anim1 = AN.GATHER_MOVING_SCYTHE_1_SOUTH
        anim2 = AN.GATHER_MOVING_SCYTHE_2_SOUTH
        anim3 = AN.GATHER_MOVING_SCYTHE_3_SOUTH
        futureWaypointY = self.gy + 1
    elseif self.state == "Scythe walking to northern tile" or self.state == "Going to scythe the land from south" then
        self.moveDir = "north"
        anim1 = AN.GATHER_MOVING_SCYTHE_1_NORTH
        anim2 = AN.GATHER_MOVING_SCYTHE_2_NORTH
        anim3 = AN.GATHER_MOVING_SCYTHE_3_NORTH
        futureWaypointY = self.gy - 1
    elseif self.state == "Scythe walking to eastern tile" or self.state == "Going to scythe the land from east" then
        self.moveDir = "east"
        anim1 = AN.GATHER_MOVING_SCYTHE_1_EAST
        anim2 = AN.GATHER_MOVING_SCYTHE_2_EAST
        anim3 = AN.GATHER_MOVING_SCYTHE_3_EAST
        futureWaypointX = self.gx + 1
    elseif self.state == "Scythe walking to northeastern tile" then
        self.moveDir = "northeast"
        anim1 = AN.GATHER_MOVING_SCYTHE_1_NORTHEAST
        anim2 = AN.GATHER_MOVING_SCYTHE_2_NORTHEAST
        anim3 = AN.GATHER_MOVING_SCYTHE_3_NORTHEAST
        futureWaypointX = self.gx + 1
        futureWaypointY = self.gy - 1
        if self.currentTile and self:isPositionAt(self.currentTile.gx - 1, self.currentTile.gy + 1) then
            skipWalking = true
            futureWaypointX = self.gx
            futureWaypointY = self.gy
        elseif self.currentTile and self:isPositionAt(self.currentTile.gx - 2, self.currentTile.gy + 1) then
            skipWalking = true
            futureWaypointX = self.gx
            futureWaypointY = self.gy
        elseif self.currentTile and self:isPositionAt(self.currentTile.gx - 1, self.currentTile.gy + 2) then
            anim2 = AN.GATHER_MOVING_SCYTHE_2_NORTH
            anim3 = AN.GATHER_MOVING_SCYTHE_3_NORTH
        end
    elseif self.state == "Scythe walking to southeastern tile" then
        self.moveDir = "southeast"
        anim1 = AN.GATHER_MOVING_SCYTHE_1_SOUTHEAST
        anim2 = AN.GATHER_MOVING_SCYTHE_2_SOUTHEAST
        anim3 = AN.GATHER_MOVING_SCYTHE_3_SOUTHEAST
        futureWaypointX = self.gx + 1
        futureWaypointY = self.gy + 1
    end
    return anim1, anim2, anim3, skipWalking, futureWaypointX, futureWaypointY
end
function WheatFarmer:scytheLandCallback(state)
    local _, anim2, anim3, _, _, _ = self:scytheLandGetAnim()
    local function state_3Callback()
        self.moveDir = "none"
        self.straightWalkSpeed = 2400
        self.diagonalWalkSpeed = self.straightWalkSpeed * 1.414
        self.animation:pauseAtEnd()
        self.workplace:work(self)
        self:clearPath()
    end
    if state == 1 then
        self:anchorWorkPosition()
        self:updatePosition()
        self.moveDir = "none"
        self.animation = anim.newAnimation(an[anim2], 0.1, function()
            self.workplace:updateTiles(self.farmlandTiles)
            _G.playSfx(self, harvestFx)
            self.animation = anim.newAnimation(an[anim3], 0.1, function()
                state_3Callback()
            end, anim3)
        end, anim2)
    elseif state == 2 then
        self.workplace:updateTiles(self.farmlandTiles)
        _G.playSfx(self, harvestFx)
        self.animation = anim.newAnimation(an[anim3], 0.1, function()
            state_3Callback()
        end, anim3)
    elseif state == 3 then
        state_3Callback()
    else
        error("Received unknown state for hoe_land: " .. tostring(state))
    end
end
function WheatFarmer:scytheLand()
    local anim1, anim2, _, skipWalking, futureWaypointX, futureWaypointY = self:scytheLandPreprocess()
    self.state = "Working"
    self.hasMoveDir = true
    self.straightWalkSpeed = 0
    self.animation:resume()
    self.waypointX, self.waypointY = futureWaypointX, futureWaypointY
    if skipWalking then
        self.animation = anim.newAnimation(an[anim2], 0.1, function()
            self:scytheLandCallback(2)
        end, anim2)
    else
        self.straightWalkSpeed = 1715.26586621
        self.diagonalWalkSpeed = self.straightWalkSpeed * 1.414
        self.animation = anim.newAnimation(an[anim1], 0.1, function()
            self:scytheLandCallback(1)
        end, anim1)
    end
end
function WheatFarmer:update()
    self.eatTimer = self.eatTimer + 1
    if self.eatTimer > 3000 then
        _G.foodpile:take()
        self.eatTimer = 0
    end
    if self.pathState == "Waiting for path" and self.state ~= "Working" and self.state ~= "Resting" then
        self:pathfind()
    elseif self.state == "Working" and self.moveDir ~= "none" then
        self:move(true)
    elseif self.state == "Go to rest" then
        self.animation = anim.newAnimation(an[AN.IDLE], 0.1, "pauseAtEnd", AN.IDLE)
        self.state = "Resting"
    elseif self.state == "Resting" then
        self.workplace:work(self)
    elseif self.state ~= "No path to farm" then
        if self.state == "Find a job" then
            _G.JobController:findJob(self, "WheatFarmer")
        elseif self.state == "Go to stockpile" then
            if _G.stockpile then
                self.state = "Going to stockpile"
                local closestNode
                local distance = math.huge
                for _, v in ipairs(_G.stockpile.nodeList) do
                    local tmp = _G.manhattanDistance(v.gx, v.gy, self.gx, self.gy)
                    if tmp < distance then
                        distance = tmp
                        closestNode = v
                    end
                end
                if not closestNode then
                    print("Closest stockpile node not found")
                else
                    self:requestPath(closestNode.gx, closestNode.gy)
                end
                self.moveDir = "none"
            end
        elseif self.state == "Go to workplace" then
            self:requestPath(self.workplace.gx, self.workplace.gy + 4)
            self.state = "Going to workplace"
            self.moveDir = "none"
        elseif self.moveDir == "none" and _G.string.startsWith(self.state, "Going") then
            self:updateDirection()
        end
        if _G.string.startsWith(self.state, "Going") then
            self:move()
        end
        if self.state == "Hoe walking to southern tile" or self.state == "Hoe walking to northern tile" or self.state ==
            "Hoe walking to eastern tile" or self.state == "Hoe walking to southeastern tile" or self.state ==
            "Hoe walking to northeastern tile" then
            self:hoeLand()
        elseif self.state == "Seed walking to southern tile" or self.state == "Seed walking to northern tile" or
            self.state == "Seed walking to eastern tile" or self.state == "Seed walking to southeastern tile" or
            self.state == "Seed walking to northeastern tile" then
            self:seedLand()
        elseif self.state == "Scythe walking to southern tile" or self.state == "Scythe walking to northern tile" or
            self.state == "Scythe walking to eastern tile" or self.state == "Scythe walking to southeastern tile" or
            self.state == "Scythe walking to northeastern tile" then
            self:scytheLand()
        elseif self.fx * 0.001 == self.waypointX and self.fy * 0.001 == self.waypointY and self.moveDir ~= "none" then
            if self.state == "Going to workplace" or self.state == "Going to hoe the land from south" or self.state ==
                "Going to hoe the land from north" or self.state == "Going to seed the land from south" or self.state ==
                "Going to seed the land from north" or self.state == "Going to scythe the land from north" or self.state ==
                "Going to scythe the land from south" then
                if self:reachedPathEnd() then
                    if self.state == "Going to hoe the land from south" or self.state ==
                        "Going to hoe the land from north" then
                        self:hoeLand()
                    elseif self.state == "Going to seed the land from south" or self.state ==
                        "Going to seed the land from north" then
                        self:seedLand()
                    elseif self.state == "Going to scythe the land from south" or self.state ==
                        "Going to scythe the land from north" then
                        self:scytheLand()
                    else
                        self.workplace:work(self)
                        self:clearPath()
                        self:updatePosition()
                    end
                    return
                else
                    self:setNextWaypoint()

                end
                self.count = self.count + 1
            elseif self.state == "Going to pick up wheat" then
                if self:reachedPathEnd() then
                    self.resourceTile:takeResource()
                    self.wheat = self.wheat + 1
                    if self.wheat < 3 then
                        self.workplace:work(self)
                        self:clearPath()
                    else
                        self.state = "Go to stockpile"
                        self:clearPath()
                        return
                    end
                else
                    self:setNextWaypoint()
                end
                self.count = self.count + 1
            elseif self.state == "Going to stockpile" then
                if self:reachedPathEnd() then
                    if self.wheat > 0 then
                        _G.stockpile:store('wheat')
                    end
                    if self.wheat > 1 then
                        _G.stockpile:store('wheat')
                    end
                    if self.wheat > 2 then
                        _G.stockpile:store('wheat')
                    end
                    self.wheat = 0
                    self.state = "Go to workplace"
                    self:clearPath()
                    return
                else
                    self:setNextWaypoint()

                end
                self.count = self.count + 1
            end
        end
    end
end
function WheatFarmer:animate()
    self:update()
    Unit.animate(self)
end
return WheatFarmer
