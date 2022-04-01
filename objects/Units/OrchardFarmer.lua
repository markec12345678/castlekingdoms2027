local _, _ = ...
local Unit = require("objects.Units.Unit")
local Object = require("objects.Object")
local anim = require("libraries.anim8")

local fr_walking_apples_east = _G.indexQuads("body_farmer_walk_apples_e", 16)
local fr_walking_apples_north = _G.indexQuads("body_farmer_walk_apples_n", 16)
local fr_walking_apples_west = _G.indexQuads("body_farmer_walk_apples_w", 16)
local fr_walking_apples_south = _G.indexQuads("body_farmer_walk_apples_s", 16)
local fr_walking_apples_northeast = _G.indexQuads("body_farmer_walk_apples_ne", 16)
local fr_walking_apples_northwest = _G.indexQuads("body_farmer_walk_apples_nw", 16)
local fr_walking_apples_southeast = _G.indexQuads("body_farmer_walk_apples_se", 16)
local fr_walking_apples_southwest = _G.indexQuads("body_farmer_walk_apples_sw", 16)
local fr_walking_east = _G.indexQuads("body_farmer_walk_e", 16)
local fr_walking_north = _G.indexQuads("body_farmer_walk_n", 16)
local fr_walking_northeast = _G.indexQuads("body_farmer_walk_ne", 16)
local fr_walking_northwest = _G.indexQuads("body_farmer_walk_nw", 16)
local fr_walking_south = _G.indexQuads("body_farmer_walk_s", 16)
local fr_walking_southeast = _G.indexQuads("body_farmer_walk_se", 16)
local fr_walking_southwest = _G.indexQuads("body_farmer_walk_sw", 16)
local fr_walking_west = _G.indexQuads("body_farmer_walk_w", 16)
local fr_gather_apples_east = _G.indexQuads("body_farmer_actual_apples_e", 10)

local WALKING_APPLES_EAST = "walking_apples_east"
local WALKING_APPLES_NORTH = "walking_apples_north"
local WALKING_APPLES_WEST = "walking_apples_west"
local WALKING_APPLES_SOUTH = "walking_apples_south"
local WALKING_APPLES_NORTHEAST = "walking_apples_northeast"
local WALKING_APPLES_NORTHWEST = "walking_apples_northwest"
local WALKING_APPLES_SOUTHEAST = "walking_apples_southeast"
local WALKING_APPLES_SOUTHWEST = "walking_apples_southwest"
local WALKING_EAST = "walking_east"
local WALKING_NORTH = "walking_north"
local WALKING_NORTHEAST = "walking_northeast"
local WALKING_NORTHWEST = "walking_northwest"
local WALKING_SOUTH = "walking_south"
local WALKING_SOUTHEAST = "walking_southeast"
local WALKING_SOUTHWEST = "walking_southwest"
local WALKING_WEST = "walking_west"
local GATHER_APPLES_EAST = "gather_apples_east"

local an = {
    [WALKING_APPLES_EAST] = fr_walking_apples_east,
    [WALKING_APPLES_NORTH] = fr_walking_apples_north,
    [WALKING_APPLES_WEST] = fr_walking_apples_west,
    [WALKING_APPLES_SOUTH] = fr_walking_apples_south,
    [WALKING_APPLES_NORTHEAST] = fr_walking_apples_northeast,
    [WALKING_APPLES_NORTHWEST] = fr_walking_apples_northwest,
    [WALKING_APPLES_SOUTHEAST] = fr_walking_apples_southeast,
    [WALKING_APPLES_SOUTHWEST] = fr_walking_apples_southwest,
    [WALKING_EAST] = fr_walking_east,
    [WALKING_NORTH] = fr_walking_north,
    [WALKING_NORTHEAST] = fr_walking_northeast,
    [WALKING_NORTHWEST] = fr_walking_northwest,
    [WALKING_SOUTH] = fr_walking_south,
    [WALKING_SOUTHEAST] = fr_walking_southeast,
    [WALKING_SOUTHWEST] = fr_walking_southwest,
    [WALKING_WEST] = fr_walking_west,
    [GATHER_APPLES_EAST] = fr_gather_apples_east
}

local OrchardFarmer = _G.class('OrchardFarmer', Unit)
function OrchardFarmer:initialize(gx, gy, type)
    Unit.initialize(self, gx, gy, type)
    self.workplace = nil
    self.state = 'Find a job'
    self.count = 1
    self.offset_y = -10
    self.offset_x = -5
    self.eat_timer = 0
    self.animated = true
    self.gather_loop_count = 0
    self.animation = anim.newAnimation(an[WALKING_WEST], 10, nil, WALKING_WEST)
end
function OrchardFarmer:serialize()
    local data = {}
    local unit_data = Unit.serialize(self)
    for k, v in pairs(unit_data) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.animation = self.animation:serialize()
    data.state = self.state
    data.animated = self.animated
    data.count = self.count
    data.eat_timer = self.eat_timer
    data.offset_x = self.offset_x
    data.offset_y = self.offset_y
    data.gather_loop_count = self.gather_loop_count
    return data
end
function OrchardFarmer:load(data)
    Object.deserialize(self, data)
    Unit.load(self, data)
    self.gather_loop_count = data.gather_loop_count or 0
    local an_data = data.animation
    if an_data then
        local callback
        if an_data.animation_identifier == GATHER_APPLES_EAST then
            callback = function()
                self:gather_callback()
            end
        end
        self.animation = anim.newAnimation(an[an_data.animation_identifier], 1, callback, an_data.animation_identifier)
        self.animation:deserialize(an_data)
    end
end
function OrchardFarmer:dir_sub_update()
    if self.move_dir == "west" then
        if self.state == "Going to foodpile" or self.state == "Going to apple tree" then
            self.animation = anim.newAnimation(an[WALKING_APPLES_WEST], 0.05, nil, WALKING_APPLES_WEST)
        else
            self.animation = anim.newAnimation(an[WALKING_WEST], 0.05, nil, WALKING_WEST)
        end
    elseif self.move_dir == "southwest" then
        if self.state == "Going to foodpile" or self.state == "Going to apple tree" then
            self.animation = anim.newAnimation(an[WALKING_APPLES_SOUTHWEST], 0.05, nil, WALKING_APPLES_SOUTHWEST)
        else
            self.animation = anim.newAnimation(an[WALKING_SOUTHWEST], 0.05, nil, WALKING_SOUTHWEST)
        end
    elseif self.move_dir == "northwest" then
        if self.state == "Going to foodpile" or self.state == "Going to apple tree" then
            self.animation = anim.newAnimation(an[WALKING_APPLES_NORTHWEST], 0.05, nil, WALKING_APPLES_NORTHWEST)
        else
            self.animation = anim.newAnimation(an[WALKING_NORTHWEST], 0.05, nil, WALKING_NORTHWEST)
        end
    elseif self.move_dir == "north" then
        if self.state == "Going to foodpile" or self.state == "Going to apple tree" then
            self.animation = anim.newAnimation(an[WALKING_APPLES_NORTH], 0.05, nil, WALKING_APPLES_NORTH)
        else
            self.animation = anim.newAnimation(an[WALKING_NORTH], 0.05, nil, WALKING_NORTH)
        end
    elseif self.move_dir == "south" then
        if self.state == "Going to foodpile" or self.state == "Going to apple tree" then
            self.animation = anim.newAnimation(an[WALKING_APPLES_SOUTH], 0.05, nil, WALKING_APPLES_SOUTH)
        else
            self.animation = anim.newAnimation(an[WALKING_SOUTH], 0.05, nil, WALKING_SOUTH)
        end
    elseif self.move_dir == "east" then
        if self.state == "Going to foodpile" or self.state == "Going to apple tree" then
            self.animation = anim.newAnimation(an[WALKING_APPLES_EAST], 0.05, nil, WALKING_APPLES_EAST)
        else
            self.animation = anim.newAnimation(an[WALKING_EAST], 0.05, nil, WALKING_EAST)
        end
    elseif self.move_dir == "southeast" then
        if self.state == "Going to foodpile" or self.state == "Going to apple tree" then
            self.animation = anim.newAnimation(an[WALKING_APPLES_SOUTHEAST], 0.05, nil, WALKING_APPLES_SOUTHEAST)
        else
            self.animation = anim.newAnimation(an[WALKING_SOUTHEAST], 0.05, nil, WALKING_SOUTHEAST)
        end
    elseif self.move_dir == "northeast" then
        if self.state == "Going to foodpile" or self.state == "Going to apple tree" then
            self.animation = anim.newAnimation(an[WALKING_APPLES_NORTHEAST], 0.05, nil, WALKING_APPLES_NORTHEAST)
        else
            self.animation = anim.newAnimation(an[WALKING_NORTHEAST], 0.05, nil, WALKING_NORTHEAST)
        end
    end
end
function OrchardFarmer:job_update()
    _G.removeObjectAt(self.lrcx, self.lrcy, self.lrx, self.lry, self)
end
function OrchardFarmer:gather_callback()
    self.gather_loop_count = self.gather_loop_count + 1
    if self.gather_loop_count > 3 then
        self.gather_loop_count = 0
        self.workplace:work(self)
    end
end
function OrchardFarmer:update()
    self.eat_timer = self.eat_timer + 1
    if self.eat_timer > 3000 then
        _G.foodpile:take()
        self.eat_timer = 0
    end
    if self.path_state == "Waiting for path" and self.state ~= "Working" then
        self:pathfind()
    elseif self.state ~= "No path to farm" then
        if self.state == "Find a job" then
            _G.JobController:find_job(self, "OrchardFarmer")
        elseif self.state == "Go to foodpile" then
            if _G.foodpile then
                self.state = "Going to foodpile"
                local closest_node
                local distance = math.huge
                for _, v in ipairs(_G.foodpile.node_list) do
                    local tmp = _G.manhattan_distance(v.gx, v.gy, self.gx, self.gy)
                    if tmp < distance then
                        distance = tmp
                        closest_node = v
                    end
                end
                if not closest_node then
                    print("Closest foodpile node not found")
                else
                    print("Requesting path to ", closest_node.gx, closest_node.gy)
                    self:requestPath(closest_node.gx, closest_node.gy)
                end
                self.move_dir = "none"
            end
        elseif self.state == "Go to workplace" then
            self:requestPath(self.workplace.gx - 1, self.workplace.gy - 1)
            self.state = "Going to workplace"
            self.move_dir = "none"
        elseif self.move_dir == "none" and self.state == "Going to workplace" then
            self:update_direction()
        elseif self.move_dir == "none" and self.state == "Going to foodpile" then
            self:update_direction()
        elseif self.move_dir == "none" and self.state == "Going to apple tree" then
            self:update_direction()
        end
        if self.state == "Going to workplace" or self.state == "Going to foodpile" or self.state ==
            "Going to apple tree" then
            self:move()
        end
        if self.fx * 0.001 == self.waypoint_x and self.fy * 0.001 == self.waypoint_y and self.move_dir ~= "none" then
            if self.state == "Going to workplace" or self.state == "Going to apple tree" then
                if self:reached_path_end() then
                    if self.state == "Going to apple tree" then
                        self.state = "Working"
                        self.animation = anim.newAnimation(an[GATHER_APPLES_EAST], 0.1, function()
                            self:gather_callback()
                        end, GATHER_APPLES_EAST)
                    else
                        self.workplace:work(self)
                    end
                    self.nd = {}
                    self.waypoint_x, self.waypoint_y = nil, nil
                    self.move_dir = "none"
                    self.count = 1
                    return
                else
                    self:set_next_waypoint()

                end
                self.count = self.count + 1
            elseif self.state == "Going to foodpile" then
                if self:reached_path_end() then
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
                    self:set_next_waypoint()

                end
                self.count = self.count + 1
            end
        end
    end
end
function OrchardFarmer:animate()
    self:update()
    Unit.animate(self)
end
return OrchardFarmer
