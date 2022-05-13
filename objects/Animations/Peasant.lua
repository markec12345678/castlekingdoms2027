local indexQuads = _G.indexQuads
local tq = require("objects.object_quads")
local fr_idling_east_1 = {tq["body_peasant_idle_1_ne (1)"], tq["body_peasant_idle_1_sw (1)"],

                          tq["body_peasant_idle_1_ne (2)"], tq["body_peasant_idle_1_sw (2)"],

                          tq["body_peasant_idle_1_ne (3)"], tq["body_peasant_idle_1_sw (3)"],

                          tq["body_peasant_idle_1_ne (4)"], tq["body_peasant_idle_1_sw (4)"],

                          tq["body_peasant_idle_1_ne (5)"], tq["body_peasant_idle_1_sw (5)"],

                          tq["body_peasant_idle_1_ne (6)"], tq["body_peasant_idle_1_sw (6)"]}
fr_idling_east_1 = _G.addReverse(fr_idling_east_1)
local fr_idling_north_1 = {tq["body_peasant_idle_1_n (1)"], tq["body_peasant_idle_1_s (1)"],

                           tq["body_peasant_idle_1_n (2)"], tq["body_peasant_idle_1_s (2)"],

                           tq["body_peasant_idle_1_n (3)"], tq["body_peasant_idle_1_s (3)"],

                           tq["body_peasant_idle_1_n (4)"], tq["body_peasant_idle_1_s (4)"],

                           tq["body_peasant_idle_1_n (5)"], tq["body_peasant_idle_1_s (5)"],

                           tq["body_peasant_idle_1_n (6)"], tq["body_peasant_idle_1_s (6)"]}
fr_idling_north_1 = _G.addReverse(fr_idling_north_1)
local fr_idling_south_1 = {tq["body_peasant_idle_1_e (1)"], tq["body_peasant_idle_1_w (1)"],

                           tq["body_peasant_idle_1_e (2)"], tq["body_peasant_idle_1_w (2)"],

                           tq["body_peasant_idle_1_e (3)"], tq["body_peasant_idle_1_w (3)"],

                           tq["body_peasant_idle_1_e (4)"], tq["body_peasant_idle_1_w (4)"],

                           tq["body_peasant_idle_1_e (5)"], tq["body_peasant_idle_1_w (5)"],

                           tq["body_peasant_idle_1_e (6)"], tq["body_peasant_idle_1_w (6)"]}
fr_idling_south_1 = _G.addReverse(fr_idling_south_1)
local fr_idling_west_1 = {tq["body_peasant_idle_1_se (1)"], tq["body_peasant_idle_1_nw (1)"],

                          tq["body_peasant_idle_1_se (2)"], tq["body_peasant_idle_1_nw (2)"],

                          tq["body_peasant_idle_1_se (3)"], tq["body_peasant_idle_1_nw (3)"],

                          tq["body_peasant_idle_1_se (4)"], tq["body_peasant_idle_1_nw (4)"],

                          tq["body_peasant_idle_1_se (5)"], tq["body_peasant_idle_1_nw (5)"],

                          tq["body_peasant_idle_1_se (6)"], tq["body_peasant_idle_1_nw (6)"]}
fr_idling_west_1 = _G.addReverse(fr_idling_west_1)
local fr_idling_northeast_1 = fr_idling_north_1
local fr_idling_northwest_1 = fr_idling_west_1
local fr_idling_southeast_1 = fr_idling_east_1
local fr_idling_southwest_1 = fr_idling_south_1
local fr_idling_east_2 = {tq["body_peasant_idle_2_ne (1)"], tq["body_peasant_idle_2_sw (1)"],

                          tq["body_peasant_idle_2_ne (2)"], tq["body_peasant_idle_2_sw (2)"],

                          tq["body_peasant_idle_2_ne (3)"], tq["body_peasant_idle_2_sw (3)"],

                          tq["body_peasant_idle_2_ne (4)"], tq["body_peasant_idle_2_sw (4)"],

                          tq["body_peasant_idle_2_ne (5)"], tq["body_peasant_idle_2_sw (5)"],

                          tq["body_peasant_idle_2_ne (6)"], tq["body_peasant_idle_2_sw (6)"],

                          tq["body_peasant_idle_2_ne (7)"], tq["body_peasant_idle_2_sw (7)"],

                          tq["body_peasant_idle_2_ne (8)"], tq["body_peasant_idle_2_sw (8)"],

                          tq["body_peasant_idle_2_ne (9)"], tq["body_peasant_idle_2_sw (9)"],

                          tq["body_peasant_idle_2_ne (10)"], tq["body_peasant_idle_2_sw (10)"],

                          tq["body_peasant_idle_2_ne (11)"], tq["body_peasant_idle_2_sw (11)"],

                          tq["body_peasant_idle_2_ne (12)"], tq["body_peasant_idle_2_sw (12)"],

                          tq["body_peasant_idle_2_ne (13)"], tq["body_peasant_idle_2_sw (13)"],

                          tq["body_peasant_idle_2_ne (14)"], tq["body_peasant_idle_2_sw (14)"]}
fr_idling_east_2 = _G.addReverse(fr_idling_east_2)
local fr_idling_north_2 = {tq["body_peasant_idle_2_n (1)"], tq["body_peasant_idle_2_s (1)"],

                           tq["body_peasant_idle_2_n (2)"], tq["body_peasant_idle_2_s (2)"],

                           tq["body_peasant_idle_2_n (3)"], tq["body_peasant_idle_2_s (3)"],

                           tq["body_peasant_idle_2_n (4)"], tq["body_peasant_idle_2_s (4)"],

                           tq["body_peasant_idle_2_n (5)"], tq["body_peasant_idle_2_s (5)"],

                           tq["body_peasant_idle_2_n (6)"], tq["body_peasant_idle_2_s (6)"],

                           tq["body_peasant_idle_2_n (7)"], tq["body_peasant_idle_2_s (7)"],

                           tq["body_peasant_idle_2_n (8)"], tq["body_peasant_idle_2_s (8)"],

                           tq["body_peasant_idle_2_n (9)"], tq["body_peasant_idle_2_s (9)"],

                           tq["body_peasant_idle_2_n (10)"], tq["body_peasant_idle_2_s (10)"],

                           tq["body_peasant_idle_2_n (11)"], tq["body_peasant_idle_2_s (11)"],

                           tq["body_peasant_idle_2_n (12)"], tq["body_peasant_idle_2_s (12)"],

                           tq["body_peasant_idle_2_n (13)"], tq["body_peasant_idle_2_s (13)"],

                           tq["body_peasant_idle_2_n (14)"], tq["body_peasant_idle_2_s (14)"]}
fr_idling_north_2 = _G.addReverse(fr_idling_north_2)
local fr_idling_south_2 = {tq["body_peasant_idle_2_e (1)"], tq["body_peasant_idle_2_w (1)"],

                           tq["body_peasant_idle_2_e (2)"], tq["body_peasant_idle_2_w (2)"],

                           tq["body_peasant_idle_2_e (3)"], tq["body_peasant_idle_2_w (3)"],

                           tq["body_peasant_idle_2_e (4)"], tq["body_peasant_idle_2_w (4)"],

                           tq["body_peasant_idle_2_e (5)"], tq["body_peasant_idle_2_w (5)"],

                           tq["body_peasant_idle_2_e (6)"], tq["body_peasant_idle_2_w (6)"],

                           tq["body_peasant_idle_2_e (7)"], tq["body_peasant_idle_2_w (7)"],

                           tq["body_peasant_idle_2_e (8)"], tq["body_peasant_idle_2_w (8)"],

                           tq["body_peasant_idle_2_e (9)"], tq["body_peasant_idle_2_w (9)"],

                           tq["body_peasant_idle_2_e (10)"], tq["body_peasant_idle_2_w (10)"],

                           tq["body_peasant_idle_2_e (11)"], tq["body_peasant_idle_2_w (11)"],

                           tq["body_peasant_idle_2_e (12)"], tq["body_peasant_idle_2_w (12)"],

                           tq["body_peasant_idle_2_e (13)"], tq["body_peasant_idle_2_w (13)"],

                           tq["body_peasant_idle_2_e (14)"], tq["body_peasant_idle_2_w (14)"]}
fr_idling_south_2 = _G.addReverse(fr_idling_south_2)
local fr_idling_west_2 = {tq["body_peasant_idle_2_se (1)"], tq["body_peasant_idle_2_nw (1)"],

                          tq["body_peasant_idle_2_se (2)"], tq["body_peasant_idle_2_nw (2)"],

                          tq["body_peasant_idle_2_se (3)"], tq["body_peasant_idle_2_nw (3)"],

                          tq["body_peasant_idle_2_se (4)"], tq["body_peasant_idle_2_nw (4)"],

                          tq["body_peasant_idle_2_se (5)"], tq["body_peasant_idle_2_nw (5)"],

                          tq["body_peasant_idle_2_se (6)"], tq["body_peasant_idle_2_nw (6)"],

                          tq["body_peasant_idle_2_se (7)"], tq["body_peasant_idle_2_nw (7)"],

                          tq["body_peasant_idle_2_se (8)"], tq["body_peasant_idle_2_nw (8)"],

                          tq["body_peasant_idle_2_se (9)"], tq["body_peasant_idle_2_nw (9)"],

                          tq["body_peasant_idle_2_se (10)"], tq["body_peasant_idle_2_nw (10)"],

                          tq["body_peasant_idle_2_se (11)"], tq["body_peasant_idle_2_nw (11)"],

                          tq["body_peasant_idle_2_se (12)"], tq["body_peasant_idle_2_nw (12)"],

                          tq["body_peasant_idle_2_se (13)"], tq["body_peasant_idle_2_nw (13)"],

                          tq["body_peasant_idle_2_se (14)"], tq["body_peasant_idle_2_nw (14)"]}
fr_idling_west_2 = _G.addReverse(fr_idling_west_2)
local fr_idling_northeast_2 = fr_idling_north_2
local fr_idling_northwest_2 = fr_idling_west_2
local fr_idling_southeast_2 = fr_idling_east_2
local fr_idling_southwest_2 = fr_idling_south_2

local fr_idling_east_3 = {tq["body_peasant_idle_3_ne (1)"], tq["body_peasant_idle_3_sw (1)"],

                          tq["body_peasant_idle_3_ne (2)"], tq["body_peasant_idle_3_sw (2)"],

                          tq["body_peasant_idle_3_ne (3)"], tq["body_peasant_idle_3_sw (3)"],

                          tq["body_peasant_idle_3_ne (4)"], tq["body_peasant_idle_3_sw (4)"],

                          tq["body_peasant_idle_3_ne (5)"], tq["body_peasant_idle_3_sw (5)"],

                          tq["body_peasant_idle_3_ne (6)"], tq["body_peasant_idle_3_sw (6)"],

                          tq["body_peasant_idle_3_ne (7)"], tq["body_peasant_idle_3_sw (7)"],

                          tq["body_peasant_idle_3_ne (8)"], tq["body_peasant_idle_3_sw (8)"],

                          tq["body_peasant_idle_3_ne (9)"], tq["body_peasant_idle_3_sw (9)"],

                          tq["body_peasant_idle_3_ne (10)"], tq["body_peasant_idle_3_sw (10)"],

                          tq["body_peasant_idle_3_ne (11)"], tq["body_peasant_idle_3_sw (11)"],

                          tq["body_peasant_idle_3_ne (12)"], tq["body_peasant_idle_3_sw (12)"],

                          tq["body_peasant_idle_3_ne (13)"], tq["body_peasant_idle_3_sw (13)"],

                          tq["body_peasant_idle_3_ne (14)"], tq["body_peasant_idle_3_sw (14)"]}
fr_idling_east_3 = _G.addReverse(fr_idling_east_3)
local fr_idling_north_3 = {tq["body_peasant_idle_3_n (1)"], tq["body_peasant_idle_3_s (1)"],

                           tq["body_peasant_idle_3_n (2)"], tq["body_peasant_idle_3_s (2)"],

                           tq["body_peasant_idle_3_n (3)"], tq["body_peasant_idle_3_s (3)"],

                           tq["body_peasant_idle_3_n (4)"], tq["body_peasant_idle_3_s (4)"],

                           tq["body_peasant_idle_3_n (5)"], tq["body_peasant_idle_3_s (5)"],

                           tq["body_peasant_idle_3_n (6)"], tq["body_peasant_idle_3_s (6)"],

                           tq["body_peasant_idle_3_n (7)"], tq["body_peasant_idle_3_s (7)"],

                           tq["body_peasant_idle_3_n (8)"], tq["body_peasant_idle_3_s (8)"],

                           tq["body_peasant_idle_3_n (9)"], tq["body_peasant_idle_3_s (9)"],

                           tq["body_peasant_idle_3_n (10)"], tq["body_peasant_idle_3_s (10)"],

                           tq["body_peasant_idle_3_n (11)"], tq["body_peasant_idle_3_s (11)"],

                           tq["body_peasant_idle_3_n (12)"], tq["body_peasant_idle_3_s (12)"],

                           tq["body_peasant_idle_3_n (13)"], tq["body_peasant_idle_3_s (13)"],

                           tq["body_peasant_idle_3_n (14)"], tq["body_peasant_idle_3_s (14)"]}
fr_idling_north_3 = _G.addReverse(fr_idling_north_3)
local fr_idling_south_3 = {tq["body_peasant_idle_3_e (1)"], tq["body_peasant_idle_3_w (1)"],

                           tq["body_peasant_idle_3_e (2)"], tq["body_peasant_idle_3_w (2)"],

                           tq["body_peasant_idle_3_e (3)"], tq["body_peasant_idle_3_w (3)"],

                           tq["body_peasant_idle_3_e (4)"], tq["body_peasant_idle_3_w (4)"],

                           tq["body_peasant_idle_3_e (5)"], tq["body_peasant_idle_3_w (5)"],

                           tq["body_peasant_idle_3_e (6)"], tq["body_peasant_idle_3_w (6)"],

                           tq["body_peasant_idle_3_e (7)"], tq["body_peasant_idle_3_w (7)"],

                           tq["body_peasant_idle_3_e (8)"], tq["body_peasant_idle_3_w (8)"],

                           tq["body_peasant_idle_3_e (9)"], tq["body_peasant_idle_3_w (9)"],

                           tq["body_peasant_idle_3_e (10)"], tq["body_peasant_idle_3_w (10)"],

                           tq["body_peasant_idle_3_e (11)"], tq["body_peasant_idle_3_w (11)"],

                           tq["body_peasant_idle_3_e (12)"], tq["body_peasant_idle_3_w (12)"],

                           tq["body_peasant_idle_3_e (13)"], tq["body_peasant_idle_3_w (13)"],

                           tq["body_peasant_idle_3_e (14)"], tq["body_peasant_idle_3_w (14)"]}
fr_idling_south_3 = _G.addReverse(fr_idling_south_3)
local fr_idling_west_3 = {tq["body_peasant_idle_3_se (1)"], tq["body_peasant_idle_3_nw (1)"],

                          tq["body_peasant_idle_3_se (2)"], tq["body_peasant_idle_3_nw (2)"],

                          tq["body_peasant_idle_3_se (3)"], tq["body_peasant_idle_3_nw (3)"],

                          tq["body_peasant_idle_3_se (4)"], tq["body_peasant_idle_3_nw (4)"],

                          tq["body_peasant_idle_3_se (5)"], tq["body_peasant_idle_3_nw (5)"],

                          tq["body_peasant_idle_3_se (6)"], tq["body_peasant_idle_3_nw (6)"],

                          tq["body_peasant_idle_3_se (7)"], tq["body_peasant_idle_3_nw (7)"],

                          tq["body_peasant_idle_3_se (8)"], tq["body_peasant_idle_3_nw (8)"],

                          tq["body_peasant_idle_3_se (9)"], tq["body_peasant_idle_3_nw (9)"],

                          tq["body_peasant_idle_3_se (10)"], tq["body_peasant_idle_3_nw (10)"],

                          tq["body_peasant_idle_3_se (11)"], tq["body_peasant_idle_3_nw (11)"],

                          tq["body_peasant_idle_3_se (12)"], tq["body_peasant_idle_3_nw (12)"],

                          tq["body_peasant_idle_3_se (13)"], tq["body_peasant_idle_3_nw (13)"],

                          tq["body_peasant_idle_3_se (14)"], tq["body_peasant_idle_3_nw (14)"]}
fr_idling_west_3 = _G.addReverse(fr_idling_west_3)
local fr_idling_northeast_3 = fr_idling_north_3
local fr_idling_northwest_3 = fr_idling_west_3
local fr_idling_southeast_3 = fr_idling_east_3
local fr_idling_southwest_3 = fr_idling_south_3

return {
    fr_walking_east = indexQuads("body_peasant_walk_e", 16),
    fr_walking_north = indexQuads("body_peasant_walk_n", 16),
    fr_walking_northeast = indexQuads("body_peasant_walk_ne", 16),
    fr_walking_northwest = indexQuads("body_peasant_walk_nw", 16),
    fr_walking_south = indexQuads("body_peasant_walk_s", 16),
    fr_walking_southeast = indexQuads("body_peasant_walk_se", 16),
    fr_walking_southwest = indexQuads("body_peasant_walk_sw", 16),
    fr_walking_west = indexQuads("body_peasant_walk_w", 16),
    fr_bowing_north = indexQuads("body_peasant_bow_n", 6, nil, true),
    fr_idle_east_2 = indexQuads("body_peasant_walk_e", 11, 10),
    fr_idle_north_2 = indexQuads("body_peasant_walk_n", 11, 10),
    fr_idle_northeast_2 = indexQuads("body_peasant_walk_ne", 11, 10),
    fr_idle_northwest_2 = indexQuads("body_peasant_walk_nw", 11, 10),
    fr_idle_south_2 = indexQuads("body_peasant_walk_s", 11, 10),
    fr_idle_southeast_2 = indexQuads("body_peasant_walk_se", 11, 10),
    fr_idle_southwest_2 = indexQuads("body_peasant_walk_sw", 11, 10),
    fr_idle_west_2 = indexQuads("body_peasant_walk_w", 11, 10),
    fr_idling_east_1 = fr_idling_east_1,
    fr_idling_north_1 = fr_idling_north_1,
    fr_idling_south_1 = fr_idling_south_1,
    fr_idling_west_1 = fr_idling_west_1,
    fr_idling_northeast_1 = fr_idling_northeast_1,
    fr_idling_northwest_1 = fr_idling_northwest_1,
    fr_idling_southeast_1 = fr_idling_southeast_1,
    fr_idling_southwest_1 = fr_idling_southwest_1,
    fr_idling_east_2 = fr_idling_east_2,
    fr_idling_north_2 = fr_idling_north_2,
    fr_idling_south_2 = fr_idling_south_2,
    fr_idling_west_2 = fr_idling_west_2,
    fr_idling_northeast_2 = fr_idling_northeast_2,
    fr_idling_northwest_2 = fr_idling_northwest_2,
    fr_idling_southeast_2 = fr_idling_southeast_2,
    fr_idling_southwest_2 = fr_idling_southwest_2,
    fr_idling_east_3 = fr_idling_east_3,
    fr_idling_north_3 = fr_idling_north_3,
    fr_idling_south_3 = fr_idling_south_3,
    fr_idling_west_3 = fr_idling_west_3,
    fr_idling_northeast_3 = fr_idling_northeast_3,
    fr_idling_northwest_3 = fr_idling_northwest_3,
    fr_idling_southeast_3 = fr_idling_southeast_3,
    fr_idling_southwest_3 = fr_idling_southwest_3
}
