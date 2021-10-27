local object, tile_quads = ...
local Unit = require("objects.Units.Unit")

local fr_walking_apples_east = indexQuads("body_farmer_walk_apples_e", 16)
local fr_walking_apples_north = indexQuads("body_farmer_walk_apples_n", 16)
local fr_walking_apples_west = indexQuads("body_farmer_walk_apples_w", 16)
local fr_walking_apples_south = indexQuads("body_farmer_walk_apples_s", 16)
local fr_walking_apples_northeast = indexQuads("body_farmer_walk_apples_ne", 16)
local fr_walking_apples_northwest = indexQuads("body_farmer_walk_apples_nw", 16)
local fr_walking_apples_southeast = indexQuads("body_farmer_walk_apples_se", 16)
local fr_walking_apples_southwest = indexQuads("body_farmer_walk_apples_sw", 16)
local fr_walking_east = indexQuads("body_farmer_walk_e", 16)
local fr_walking_north = indexQuads("body_farmer_walk_n", 16)
local fr_walking_northeast = indexQuads("body_farmer_walk_ne", 16)
local fr_walking_northwest = indexQuads("body_farmer_walk_nw", 16)
local fr_walking_south = indexQuads("body_farmer_walk_s", 16)
local fr_walking_southeast = indexQuads("body_farmer_walk_se", 16)
local fr_walking_southwest = indexQuads("body_farmer_walk_sw", 16)
local fr_walking_west = indexQuads("body_farmer_walk_w", 16)
-- hoe
local fr_gather_walk_hoe_north = indexQuads("body_farmer_hoe_n", 8)
local fr_gather_walk_hoe_west = indexQuads("body_farmer_hoe_w", 8)
local fr_gather_walk_hoe_south = indexQuads("body_farmer_hoe_s", 8)
local fr_gather_walk_hoe_east = indexQuads("body_farmer_hoe_e", 8)
local fr_gather_walk_hoe_northeast = indexQuads("body_farmer_hoe_ne", 8)
local fr_gather_walk_hoe_northwest = indexQuads("body_farmer_hoe_nw", 8)
local fr_gather_walk_hoe_southeast = indexQuads("body_farmer_hoe_se", 8)
local fr_gather_walk_hoe_southwest = indexQuads("body_farmer_hoe_sw", 8)
local fr_gather_hoe_north = indexQuads("body_farmer_hoe_n", 12, 9)
local fr_gather_hoe_west = indexQuads("body_farmer_hoe_w", 12, 9)
local fr_gather_hoe_south = indexQuads("body_farmer_hoe_s", 12, 9)
local fr_gather_hoe_east = indexQuads("body_farmer_hoe_e", 12, 9)
local fr_gather_hoe_northeast = indexQuads("body_farmer_hoe_ne", 12, 9)
local fr_gather_hoe_northwest = indexQuads("body_farmer_hoe_nw", 12, 9)
local fr_gather_hoe_southeast = indexQuads("body_farmer_hoe_se", 12, 9)
local fr_gather_hoe_southwest = indexQuads("body_farmer_hoe_sw", 12, 9)
local fr_gather_hoe_part2_north = indexQuads("body_farmer_hoe_n", 16, 13)
local fr_gather_hoe_part2_west = indexQuads("body_farmer_hoe_w", 16, 13)
local fr_gather_hoe_part2_south = indexQuads("body_farmer_hoe_s", 16, 13)
local fr_gather_hoe_part2_east = indexQuads("body_farmer_hoe_e", 16, 13)
local fr_gather_hoe_part2_northeast = indexQuads("body_farmer_hoe_ne", 16, 13)
local fr_gather_hoe_part2_northwest = indexQuads("body_farmer_hoe_nw", 16, 13)
local fr_gather_hoe_part2_southeast = indexQuads("body_farmer_hoe_se", 16, 13)
local fr_gather_hoe_part2_southwest = indexQuads("body_farmer_hoe_sw", 16, 13)
-- moving with scythe
local fr_gather_moving_scythe_1_north = indexQuads("body_farmer_mow_scythe_n", 6)
local fr_gather_moving_scythe_1_west = indexQuads("body_farmer_mow_scythe_w", 6)
local fr_gather_moving_scythe_1_south = indexQuads("body_farmer_mow_scythe_s", 6)
local fr_gather_moving_scythe_1_northeast = indexQuads("body_farmer_mow_scythe_ne", 6)
local fr_gather_moving_scythe_1_northwest = indexQuads("body_farmer_mow_scythe_nw", 6)
local fr_gather_moving_scythe_1_southeast = indexQuads("body_farmer_mow_scythe_se", 6)
local fr_gather_moving_scythe_1_southwest = indexQuads("body_farmer_mow_scythe_sw", 6)
-- moving with scythe
local fr_gather_moving_scythe_2_north = indexQuads("body_farmer_mow_scythe_n", 9, 7)
local fr_gather_moving_scythe_2_west = indexQuads("body_farmer_mow_scythe_w", 9, 7)
local fr_gather_moving_scythe_2_south = indexQuads("body_farmer_mow_scythe_s", 9, 7)
local fr_gather_moving_scythe_2_northeast = indexQuads("body_farmer_mow_scythe_ne", 9, 7)
local fr_gather_moving_scythe_2_northwest = indexQuads("body_farmer_mow_scythe_nw", 9, 7)
local fr_gather_moving_scythe_2_southeast = indexQuads("body_farmer_mow_scythe_se", 9, 7)
local fr_gather_moving_scythe_2_southwest = indexQuads("body_farmer_mow_scythe_sw", 9, 7)
-- moving with scythe
local fr_gather_moving_scythe_3_north = indexQuads("body_farmer_mow_scythe_n", 16, 10)
local fr_gather_moving_scythe_3_west = indexQuads("body_farmer_mow_scythe_w", 16, 10)
local fr_gather_moving_scythe_3_south = indexQuads("body_farmer_mow_scythe_s", 16, 10)
local fr_gather_moving_scythe_3_northeast = indexQuads("body_farmer_mow_scythe_ne", 16, 10)
local fr_gather_moving_scythe_3_northwest = indexQuads("body_farmer_mow_scythe_nw", 16, 10)
local fr_gather_moving_scythe_3_southeast = indexQuads("body_farmer_mow_scythe_se", 16, 10)
local fr_gather_moving_scythe_3_southwest = indexQuads("body_farmer_mow_scythe_sw", 16, 10)
-- mowing scythe
local fr_gather_scythe_north = indexQuads("body_farmer_mow_scythe_n", 8)
local fr_gather_scythe_west = indexQuads("body_farmer_mow_scythe_w", 8)
local fr_gather_scythe_south = indexQuads("body_farmer_mow_scythe_s", 8)
local fr_gather_scythe_northeast = indexQuads("body_farmer_mow_scythe_ne", 8)
local fr_gather_scythe_northwest = indexQuads("body_farmer_mow_scythe_nw", 8)
local fr_gather_scythe_southeast = indexQuads("body_farmer_mow_scythe_se", 8)
local fr_gather_scythe_southwest = indexQuads("body_farmer_mow_scythe_sw", 8)
-- walking scythe
local fr_gather_walk_scythe_north = indexQuads("body_farmer_walk_scythe_n", 16)
local fr_gather_walk_scythe_west = indexQuads("body_farmer_walk_scythe_w", 16)
local fr_gather_walk_scythe_south = indexQuads("body_farmer_walk_scythe_s", 16)
local fr_gather_walk_scythe_northeast = indexQuads("body_farmer_walk_scythe_ne", 16)
local fr_gather_walk_scythe_northwest = indexQuads("body_farmer_walk_scythe_nw", 16)
local fr_gather_walk_scythe_southeast = indexQuads("body_farmer_walk_scythe_se", 16)
local fr_gather_walk_scythe_southwest = indexQuads("body_farmer_walk_scythe_sw", 16)
-- earthing
local fr_gather_earthing_north = indexQuads("body_farmer_earth_n", 8)
local fr_gather_earthing_west = indexQuads("body_farmer_earth_w", 8)
local fr_gather_earthing_south = indexQuads("body_farmer_earth_s", 8)
local fr_gather_earthing_northeast = indexQuads("body_farmer_earth_ne", 8)
local fr_gather_earthing_northwest = indexQuads("body_farmer_earth_nw", 8)
local fr_gather_earthing_southeast = indexQuads("body_farmer_earth_se", 8)
local fr_gather_earthing_southwest = indexQuads("body_farmer_earth_sw", 8)
-- planting
local fr_gather_planting_north = indexQuads("body_farmer_seed_n", 16)
local fr_gather_planting_west = indexQuads("body_farmer_seed_w", 16)
local fr_gather_planting_south = indexQuads("body_farmer_seed_s", 16)
local fr_gather_planting_northeast = indexQuads("body_farmer_seed_ne", 16)
local fr_gather_planting_northwest = indexQuads("body_farmer_seed_nw", 16)
local fr_gather_planting_southeast = indexQuads("body_farmer_seed_se", 16)
local fr_gather_planting_southwest = indexQuads("body_farmer_seed_sw", 16)
-- walk wheat
local fr_gather_walk_wheat_north = indexQuads("body_farmer_walk_wheat_n", 16)
local fr_gather_walk_wheat_west = indexQuads("body_farmer_walk_wheat_w", 16)
local fr_gather_walk_wheat_south = indexQuads("body_farmer_walk_wheat_s", 16)
local fr_gather_walk_wheat_northeast = indexQuads("body_farmer_walk_wheat_ne", 16)
local fr_gather_walk_wheat_northwest = indexQuads("body_farmer_walk_wheat_nw", 16)
local fr_gather_walk_wheat_southeast = indexQuads("body_farmer_walk_wheat_se", 16)
local fr_gather_walk_wheat_southwest = indexQuads("body_farmer_walk_wheat_sw", 16)
-- idle
local function reverse(t)
    local n = #t
    local i = 1
    while i < n do
        t[i], t[n] = t[n], t[i]
        i = i + 1
        n = n - 1
    end
end
local fr_idle = indexQuads("body_farmer_idle", 16)
local fr_idle_loop = indexQuads("body_farmer_idle", 16, 12, true)
-- reverse(fr_idle_loop)
local WheatFarmer = class('WheatFarmer', Unit)
function WheatFarmer:initialize(gx, gy, type)
    Unit.initialize(self, gx, gy, type)
    self.workplace = nil
    self.state = 'Find a job'
    self.marked = 0
    self.count = 1
    self.offset_y = -10
    self.offset_x = -5
    self.eat_timer = 0
    self.process_farmland = function()
    end
    self.timr = 0
    self.animated = true
    self.animation = anim.newAnimation(fr_walking_west, 10)
end
function WheatFarmer:dir_sub_update()
    if self.state == "Working" then
        return
    end
    if self.move_dir == "west" then
        if self.state == "Going to foodpile" then
            self.animation = anim.newAnimation(fr_walking_apples_west, 0.05)
        elseif self.state == "Going to seed the land" then
            self.animation = anim.newAnimation(fr_walking_apples_west, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_west, 0.05)
        end
    elseif self.move_dir == "southwest" then
        if self.state == "Going to foodpile" then
            self.animation = anim.newAnimation(fr_walking_apples_southwest, 0.05)
        elseif self.state == "Going to seed the land" then
            self.animation = anim.newAnimation(fr_walking_apples_southwest, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_southwest, 0.05)
        end
    elseif self.move_dir == "northwest" then
        if self.state == "Going to foodpile" then
            self.animation = anim.newAnimation(fr_walking_apples_northwest, 0.05)
        elseif self.state == "Going to seed the land" then
            self.animation = anim.newAnimation(fr_walking_apples_northwest, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_northwest, 0.05)
        end
    elseif self.move_dir == "north" then
        if self.state == "Going to foodpile" then
            self.animation = anim.newAnimation(fr_walking_apples_north, 0.05)
        elseif self.state == "Going to seed the land" then
            self.animation = anim.newAnimation(fr_walking_apples_north, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_north, 0.05)
        end
    elseif self.move_dir == "south" then
        if self.state == "Going to foodpile" then
            self.animation = anim.newAnimation(fr_walking_apples_south, 0.05)
        elseif self.state == "Going to seed the land" then
            self.animation = anim.newAnimation(fr_walking_apples_south, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_south, 0.05)
        end
    elseif self.move_dir == "east" then
        if self.state == "Going to foodpile" then
            self.animation = anim.newAnimation(fr_walking_apples_east, 0.05)
        elseif self.state == "Going to seed the land" then
            self.animation = anim.newAnimation(fr_walking_apples_east, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_east, 0.05)
        end
    elseif self.move_dir == "southeast" then
        if self.state == "Going to foodpile" then
            self.animation = anim.newAnimation(fr_walking_apples_southeast, 0.05)
        elseif self.state == "Going to seed the land" then
            self.animation = anim.newAnimation(fr_walking_apples_southeast, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_southeast, 0.05)
        end
    elseif self.move_dir == "northeast" then
        if self.state == "Going to foodpile" then
            self.animation = anim.newAnimation(fr_walking_apples_northeast, 0.05)
        elseif self.state == "Going to seed the land" then
            self.animation = anim.newAnimation(fr_walking_apples_northeast, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_northeast, 0.05)
        end
    end
end
function WheatFarmer:job_update()
    removeObjectAt(self.lrcx, self.lrcy, self.lrx, self.lry, self)
end
function WheatFarmer:seed_land()
    local anim1, anim2, anim3, skip_walking
    local future_waypoint_x, future_waypoint_y = self.gx, self.gy
    if self.state == "Going to seed the land from south" or self.state == "Going to seed the land from north" then
        skip_walking = true
    end
    if self.state == "Seed walking to southern tile" or self.state == "Going to seed the land from north" then
        self.move_dir = "south"
        anim1 = fr_gather_planting_south
        future_waypoint_y = self.gy + 1
    elseif self.state == "Seed walking to northern tile" or self.state == "Going to seed the land from south" then
        self.move_dir = "north"
        anim1 = fr_gather_planting_north
        future_waypoint_y = self.gy - 1
    end
    self.state = "Working"
    self.has_move_dir = true
    local loop = 0
    self.straight_walk_speed = 0
    self.animation:resume()
    self.waypoint_x, self.waypoint_y = future_waypoint_x, future_waypoint_y
    if skip_walking then
        self.workplace:update_tiles(self.farmland_tiles)
        self.workplace:work(self)
        self.nd = {}
        self.waypoint_x, self.waypoint_y = nil, nil
        self.move_dir = "none"
        self.count = 1
    else
        self.straight_walk_speed = 638.4
        self.animation = anim.newAnimation(anim1, 0.1, function()
            self.fy = math.round(self.fy / 1000) * 1000
            self:update_position()
            self:calculate_position()
            self.move_dir = "none"
            self.straight_walk_speed = 40
            self.animation = anim.newAnimation(anim1, 0.1)
            self.animation:pause()
            self.workplace:update_tiles(self.farmland_tiles)
            self.workplace:work(self)
            self.nd = {}
            self.waypoint_x, self.waypoint_y = nil, nil
            self.move_dir = "none"
            self.count = 1
        end)
    end
end
function WheatFarmer:hoe_land()
    local anim1, anim2, anim3, skip_walking
    local future_waypoint_x, future_waypoint_y = self.gx, self.gy
    if self.state == "Going to hoe the land from south" or self.state == "Going to hoe the land from north" then
        skip_walking = true
    end
    if self.state == "Hoe walking to southern tile" or self.state == "Going to hoe the land from north" then
        self.move_dir = "south"
        anim1 = fr_gather_walk_hoe_south
        anim2 = fr_gather_hoe_south
        anim3 = fr_gather_hoe_part2_south
        future_waypoint_y = self.gy + 1

    elseif self.state == "Hoe walking to northern tile" or self.state == "Going to hoe the land from south" then
        self.move_dir = "north"
        anim1 = fr_gather_walk_hoe_north
        anim2 = fr_gather_hoe_north
        anim3 = fr_gather_hoe_part2_north
        future_waypoint_y = self.gy - 1
    end
    self.state = "Working"
    self.has_move_dir = true
    local loop = 0
    self.straight_walk_speed = 0
    self.animation:resume()
    self.waypoint_x, self.waypoint_y = future_waypoint_x, future_waypoint_y
    if skip_walking then
        self.animation = anim.newAnimation(anim2, 0.1, function()
            self.workplace:update_tiles(self.farmland_tiles)
            self.animation = anim.newAnimation(anim3, 0.1, function()
                self.straight_walk_speed = 2400
                self.animation = anim.newAnimation(anim1, 0.1)
                self.animation:pause()
                self.workplace:work(self)
                self.nd = {}
                self.waypoint_x, self.waypoint_y = nil
                self.move_dir = "none"
                self.count = 1
            end)
        end)
    else
        self.straight_walk_speed = 1276.7
        self.animation = anim.newAnimation(anim1, 0.1, function()
            self.fy = math.round(self.fy / 1000) * 1000
            self:update_position()
            self:calculate_position()
            self.move_dir = "none"
            self.animation = anim.newAnimation(anim2, 0.1, function()
                self.workplace:update_tiles(self.farmland_tiles)
                self.animation = anim.newAnimation(anim3, 0.1, function()
                    self.straight_walk_speed = 2400
                    self.animation = anim.newAnimation(anim1, 0.1)
                    self.animation:pause()
                    self.workplace:work(self)
                    self.nd = {}
                    self.waypoint_x, self.waypoint_y = nil
                    self.move_dir = "none"
                    self.count = 1
                end)
            end)
        end)
    end
end

function WheatFarmer:scythe_land()
    local anim1, anim2, anim3, skip_walking
    local future_waypoint_x, future_waypoint_y = self.gx, self.gy
    if self.state == "Going to scythe the land from south" or self.state == "Going to scythe the land from north" then
        skip_walking = true
    end
    if self.state == "Scythe walking to southern tile" or self.state == "Going to scythe the land from north" then
        self.move_dir = "south"
        anim1 = fr_gather_moving_scythe_1_south
        anim2 = fr_gather_moving_scythe_2_south
        anim3 = fr_gather_moving_scythe_3_south
        future_waypoint_y = self.gy + 1
    elseif self.state == "Scythe walking to northern tile" or self.state == "Going to scythe the land from south" then
        self.move_dir = "north"
        anim1 = fr_gather_moving_scythe_1_north
        anim2 = fr_gather_moving_scythe_2_north
        anim3 = fr_gather_moving_scythe_3_north
        future_waypoint_y = self.gy - 1
    end
    self.state = "Working"
    self.has_move_dir = true
    local loop = 0
    self.straight_walk_speed = 0
    self.animation:resume()
    self.waypoint_x, self.waypoint_y = future_waypoint_x, future_waypoint_y
    if skip_walking then
        self.animation = anim.newAnimation(anim2, 0.1, function()
            self.workplace:update_tiles(self.farmland_tiles)
            self.animation = anim.newAnimation(anim3, 0.1, function()
                self.straight_walk_speed = 40
                self.animation = anim.newAnimation(anim1, 0.1)
                self.animation:pause()
                self.workplace:work(self)
                self.nd = {}
                self.waypoint_x, self.waypoint_y = nil, nil
                self.move_dir = "none"
                self.count = 1
            end)
        end)
    else
        self.straight_walk_speed = 21.2794
        self.animation = anim.newAnimation(anim1, 0.1, function()
            self.fy = math.round(self.fy / 1000) * 1000
            self:update_position()
            self:calculate_position()
            self.move_dir = "none"
            self.animation = anim.newAnimation(anim2, 0.1, function()
                self.workplace:update_tiles(self.farmland_tiles)
                self.animation = anim.newAnimation(anim3, 0.1, function()
                    self.straight_walk_speed = 40
                    self.animation = anim.newAnimation(anim1, 0.1)
                    self.animation:pause()
                    self.workplace:work(self)
                    self.nd = {}
                    self.waypoint_x, self.waypoint_y = nil, nil
                    self.move_dir = "none"
                    self.count = 1
                end)
            end)
        end)
    end
end
function WheatFarmer:update()
    local xx, yy = (math.round(self.gx)) % (chunk_width), (math.round(self.gy)) % (chunk_width)
    self.eat_timer = self.eat_timer + 1
    if self.eat_timer > 3000 then
        _G.foodpile:take()
        self.eat_timer = 0
    end
    if self.path_state == "Waiting for path" and self.state ~= "Working" and self.state ~= "Resting" then
        self:pathfind()
    elseif self.state == "Working" and self.move_dir ~= "none" then
        self:move(true)
    elseif self.state == "Go to rest" then
        self.animation = anim.newAnimation(fr_idle, 0.1, "pauseAtEnd")
        self.state = "Resting"
    elseif self.state == "Resting" then
        self.workplace:work(self)
    elseif self.state ~= "No path to farm" then
        if self.state == "Find a job" then
            _G.JobController:find_job(self, "WheatFarmer")
        elseif self.state == "Go to foodpile" then
            if _G.foodpile then
                self.state = "Going to foodpile"
                local closest_node
                local distance = math.huge
                for k, v in ipairs(_G.foodpile.node_list) do
                    local tmp = manhattan_distance(v.gx, v.gy, self.gx, self.gy)
                    if tmp < distance then
                        distance = tmp
                        closest_node = v
                    end
                end
                if not closest_node then
                    print("Closest foodpile node not found")
                else
                    self:requestPath(closest_node.gx, closest_node.gy)
                end
                self.move_dir = "none"
            end
        elseif self.state == "Go to workplace" then
            self:requestPath(self.workplace.gx, self.workplace.gy + 4)
            self.state = "Going to workplace"
            self.move_dir = "none"
        elseif self.move_dir == "none" and _G.string.starts_with(self.state, "Going") then
            self:update_direction()
        end
        if _G.string.starts_with(self.state, "Going") then
            self:move()
        end
        if self.state == "Hoe walking to southern tile" or self.state == "Hoe walking to northern tile" then
            self:hoe_land()
        elseif self.state == "Seed walking to southern tile" or self.state == "Seed walking to northern tile" then
            self:seed_land()
        elseif self.state == "Scythe walking to southern tile" or self.state == "Scythe walking to northern tile" then
            self:scythe_land()
        elseif self.fx * 0.001 == self.waypoint_x and self.fy * 0.001 == self.waypoint_y and self.move_dir ~= "none" then
            if self.state == "Going to workplace" or self.state == "Going to hoe the land from south" or self.state ==
                "Going to hoe the land from north" or self.state == "Going to seed the land from south" or self.state ==
                "Going to seed the land from north" or self.state == "Going to scythe the land from north" or self.state ==
                "Going to scythe the land from south" then
                if self.count == self.nd_len then
                    if self.state == "Going to hoe the land from south" or self.state ==
                        "Going to hoe the land from north" then
                        self:hoe_land()
                    elseif self.state == "Going to seed the land from south" or self.state ==
                        "Going to seed the land from north" then
                        self:seed_land()
                    elseif self.state == "Going to scythe the land from south" or self.state ==
                        "Going to scythe the land from north" then
                        self:scythe_land()
                    else
                        self.workplace:work(self)
                        self.nd = {}
                        self.waypoint_x, self.waypoint_y = nil, nil
                        self:update_position()
                        self.move_dir = "none"
                        self.count = 1
                    end
                    return
                else
                    self.waypoint_x = self.nd[self.count][1]
                    self.waypoint_y = self.nd[self.count][2]
                    self.move_dir = "none"
                end
                self.count = self.count + 1
            elseif self.state == "Going to foodpile" then
                if self.count == self.nd_len then
                    _G.foodpile:store('apples')
                    _G.foodpile:store('apples')
                    _G.foodpile:store('apples')
                    _G.foodpile:store('apples')
                    _G.foodpile:store('apples')
                    _G.foodpile:store('apples')
                    _G.foodpile:store('apples')
                    _G.foodpile:store('apples')
                    self.state = "Go to workplace"
                    self.nd = {}
                    self.waypoint_x, self.waypoint_y = nil, nil
                    self.move_dir = "none"
                    self.count = 1
                    return
                else
                    self.waypoint_x = self.nd[self.count][1]
                    self.waypoint_y = self.nd[self.count][2]
                    self.move_dir = "none"
                end
                self.count = self.count + 1
            end
        end
    end
end
function WheatFarmer:animate()
    self.animation:update(dt)
    self:update()
end
return WheatFarmer
