local _, _ = ...
local Unit = require("objects.Units.Unit")
local Object = require("objects.Object")
local anim = require("libraries.anim8")

local ANIM_WALKING_EAST = "walking_east"
local ANIM_WALKING_NORTH = "walking_north"
local ANIM_WALKING_NORTHEAST = "walking_northeast"
local ANIM_WALKING_NORTHWEST = "walking_northwest"
local ANIM_WALKING_SOUTH = "walking_south"
local ANIM_WALKING_SOUTHEAST = "walking_southeast"
local ANIM_WALKING_SOUTHWEST = "walking_southwest"
local ANIM_WALKING_WEST = "walking_west"
-- flour
local ANIM_WALKING_FLOUR_EAST = "walking_flour_east"
local ANIM_WALKING_FLOUR_NORTH = "walking_flour_north"
local ANIM_WALKING_FLOUR_NORTHEAST = "walking_flour_northeast"
local ANIM_WALKING_FLOUR_NORTHWEST = "walking_flour_northwest"
local ANIM_WALKING_FLOUR_SOUTH = "walking_flour_south"
local ANIM_WALKING_FLOUR_SOUTHEAST = "walking_flour_southeast"
local ANIM_WALKING_FLOUR_SOUTHWEST = "walking_flour_southwest"
local ANIM_WALKING_FLOUR_WEST = "walking_flour_west"
-- bread
local ANIM_WALKING_BREAD_EAST = "walking_bread_east"
local ANIM_WALKING_BREAD_NORTH = "walking_bread_north"
local ANIM_WALKING_BREAD_NORTHEAST = "walking_bread_northeast"
local ANIM_WALKING_BREAD_NORTHWEST = "walking_bread_northwest"
local ANIM_WALKING_BREAD_SOUTH = "walking_bread_south"
local ANIM_WALKING_BREAD_SOUTHEAST = "walking_bread_southeast"
local ANIM_WALKING_BREAD_SOUTHWEST = "walking_bread_southwest"
local ANIM_WALKING_BREAD_WEST = "walking_bread_west"

local an = {
    [ANIM_WALKING_EAST] = _G.indexQuads("body_baker_walk_e", 16),
    [ANIM_WALKING_NORTH] = _G.indexQuads("body_baker_walk_n", 16),
    [ANIM_WALKING_NORTHEAST] = _G.indexQuads("body_baker_walk_ne", 16),
    [ANIM_WALKING_NORTHWEST] = _G.indexQuads("body_baker_walk_nw", 16),
    [ANIM_WALKING_SOUTH] = _G.indexQuads("body_baker_walk_s", 16),
    [ANIM_WALKING_SOUTHEAST] = _G.indexQuads("body_baker_walk_se", 16),
    [ANIM_WALKING_SOUTHWEST] = _G.indexQuads("body_baker_walk_sw", 16),
    [ANIM_WALKING_WEST] = _G.indexQuads("body_baker_walk_w", 16),
    [ANIM_WALKING_FLOUR_EAST] = _G.indexQuads("body_baker_walk_flour_e", 16),
    [ANIM_WALKING_FLOUR_NORTH] = _G.indexQuads("body_baker_walk_flour_n", 16),
    [ANIM_WALKING_FLOUR_NORTHEAST] = _G.indexQuads("body_baker_walk_flour_ne", 16),
    [ANIM_WALKING_FLOUR_NORTHWEST] = _G.indexQuads("body_baker_walk_flour_nw", 16),
    [ANIM_WALKING_FLOUR_SOUTH] = _G.indexQuads("body_baker_walk_flour_s", 16),
    [ANIM_WALKING_FLOUR_SOUTHEAST] = _G.indexQuads("body_baker_walk_flour_se", 16),
    [ANIM_WALKING_FLOUR_SOUTHWEST] = _G.indexQuads("body_baker_walk_flour_sw", 16),
    [ANIM_WALKING_FLOUR_WEST] = _G.indexQuads("body_baker_walk_flour_w", 16),
    [ANIM_WALKING_BREAD_EAST] = _G.indexQuads("body_baker_walk_bread_e", 16),
    [ANIM_WALKING_BREAD_NORTH] = _G.indexQuads("body_baker_walk_bread_n", 16),
    [ANIM_WALKING_BREAD_NORTHEAST] = _G.indexQuads("body_baker_walk_bread_ne", 16),
    [ANIM_WALKING_BREAD_NORTHWEST] = _G.indexQuads("body_baker_walk_bread_nw", 16),
    [ANIM_WALKING_BREAD_SOUTH] = _G.indexQuads("body_baker_walk_bread_s", 16),
    [ANIM_WALKING_BREAD_SOUTHEAST] = _G.indexQuads("body_baker_walk_bread_se", 16),
    [ANIM_WALKING_BREAD_SOUTHWEST] = _G.indexQuads("body_baker_walk_bread_sw", 16),
    [ANIM_WALKING_BREAD_WEST] = _G.indexQuads("body_baker_walk_bread_w", 16)
}

local Baker = _G.class('Baker', Unit)

function Baker:initialize(gx, gy, type)
    Unit.initialize(self, gx, gy, type)
    self.state = 'Find a job'
    self.eat_timer = 0
    self.wait_timer = 0
    self.offset_y = -10
    self.offset_x = -5
    self.count = 1
    self.animation = anim.newAnimation(an[ANIM_WALKING_WEST], 10, nil, ANIM_WALKING_WEST)
end

function Baker:dir_sub_update()
    if self.move_dir == "west" then
        if self.state == "Going to granary" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_BREAD_WEST], 0.05, nil, ANIM_WALKING_BREAD_WEST)
        elseif self.state == "Going to workplace with flour" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_FLOUR_WEST], 0.05, nil, ANIM_WALKING_FLOUR_WEST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_WEST], 0.05, nil, ANIM_WALKING_WEST)
        end
    elseif self.move_dir == "southwest" then
        if self.state == "Going to granary" then
            self.animation =
                anim.newAnimation(an[ANIM_WALKING_BREAD_SOUTHWEST], 0.05, nil, ANIM_WALKING_BREAD_SOUTHWEST)
        elseif self.state == "Going to workplace with flour" then
            self.animation =
                anim.newAnimation(an[ANIM_WALKING_FLOUR_SOUTHWEST], 0.05, nil, ANIM_WALKING_FLOUR_SOUTHWEST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_SOUTHWEST], 0.05, nil, ANIM_WALKING_SOUTHWEST)
        end
    elseif self.move_dir == "northwest" then
        if self.state == "Going to granary" then
            self.animation =
                anim.newAnimation(an[ANIM_WALKING_BREAD_NORTHWEST], 0.05, nil, ANIM_WALKING_BREAD_NORTHWEST)
        elseif self.state == "Going to workplace with flour" then
            self.animation =
                anim.newAnimation(an[ANIM_WALKING_FLOUR_NORTHWEST], 0.05, nil, ANIM_WALKING_FLOUR_NORTHWEST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_NORTHWEST], 0.05, nil, ANIM_WALKING_NORTHWEST)
        end
    elseif self.move_dir == "north" then
        if self.state == "Going to granary" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_BREAD_NORTH], 0.05, nil, ANIM_WALKING_BREAD_NORTH)
        elseif self.state == "Going to workplace with flour" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_FLOUR_NORTH], 0.05, nil, ANIM_WALKING_FLOUR_NORTH)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_NORTH], 0.05, nil, ANIM_WALKING_NORTH)
        end
    elseif self.move_dir == "south" then
        if self.state == "Going to granary" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_BREAD_SOUTH], 0.05, nil, ANIM_WALKING_BREAD_SOUTH)
        elseif self.state == "Going to workplace with flour" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_FLOUR_SOUTH], 0.05, nil, ANIM_WALKING_FLOUR_SOUTH)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_SOUTH], 0.05, nil, ANIM_WALKING_SOUTH)
        end
    elseif self.move_dir == "east" then
        if self.state == "Going to granary" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_BREAD_EAST], 0.05, nil, ANIM_WALKING_BREAD_EAST)
        elseif self.state == "Going to workplace with flour" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_FLOUR_EAST], 0.05, nil, ANIM_WALKING_FLOUR_EAST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_EAST], 0.05, nil, ANIM_WALKING_EAST)
        end
    elseif self.move_dir == "southeast" then
        if self.state == "Going to granary" then
            self.animation =
                anim.newAnimation(an[ANIM_WALKING_BREAD_SOUTHEAST], 0.05, nil, ANIM_WALKING_BREAD_SOUTHEAST)
        elseif self.state == "Going to workplace with flour" then
            self.animation =
                anim.newAnimation(an[ANIM_WALKING_FLOUR_SOUTHEAST], 0.05, nil, ANIM_WALKING_FLOUR_SOUTHEAST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_SOUTHEAST], 0.05, nil, ANIM_WALKING_SOUTHEAST)
        end
    elseif self.move_dir == "northeast" then
        if self.state == "Going to granary" then
            self.animation =
                anim.newAnimation(an[ANIM_WALKING_BREAD_NORTHEAST], 0.05, nil, ANIM_WALKING_BREAD_NORTHEAST)
        elseif self.state == "Going to workplace with flour" then
            self.animation =
                anim.newAnimation(an[ANIM_WALKING_FLOUR_NORTHEAST], 0.05, nil, ANIM_WALKING_FLOUR_NORTHEAST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_NORTHEAST], 0.05, nil, ANIM_WALKING_NORTHEAST)
        end
    end
end

function Baker:update()
    -- print(self.state, self.path_state)
    self.eat_timer = self.eat_timer + 1
    if self.eat_timer > 3000 then
        _G.foodpile:take()
        self.eat_timer = 0
    end
    self.wait_timer = self.wait_timer + _G.dt
    if self.wait_timer > 1 then
        if self.state == "Waiting for flour" then
            self.wait_timer = 0
            local got_resource = _G.stockpile:take('flour')
            if not got_resource then
                self.state = "Waiting for flour"
                return
            else
                self.state = "Go to workplace with flour"
                self:clear_path()
                return
            end
        end
    end
    if self.path_state == "Waiting for path" then
        self:pathfind()
    elseif self.state ~= "No path to workplace" and self.state ~= "Working" then
        if self.state == "Find a job" then
            _G.JobController:find_job(self, "Baker")
        elseif self.state == "Go to granary" then
            if _G.foodpile then
                self.state = "Going to granary"
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
                    self:requestPath(closest_node.gx, closest_node.gy)
                end
                self.move_dir = "none"
            end
        elseif self.state == "Go to stockpile for flour" then
            if _G.stockpile then
                if self.state == "Go to stockpile" then
                    self.state = "Going to granary"
                else
                    self.state = "Going to stockpile for flour"
                end
                local closest_node
                local distance = math.huge
                for _, v in ipairs(_G.stockpile.node_list) do
                    local tmp = _G.manhattan_distance(v.gx, v.gy, self.gx, self.gy)
                    if tmp < distance then
                        distance = tmp
                        closest_node = v
                    end
                end
                if not closest_node then
                    print("Closest node not found")
                else
                    self:requestPath(closest_node.gx, closest_node.gy)
                end
                self.move_dir = "none"
            end
        elseif self.state == "Go to workplace" or self.state == "Go to workplace with flour" then
            self:requestPath(self.workplace.gx, self.workplace.gy + 4)
            if self.state == "Go to workplace with flour" then
                self.state = "Going to workplace with flour"
            else
                self.state = "Going to workplace"
            end
            self.move_dir = "none"
        elseif self.move_dir == "none" and
            (self.state == "Going to workplace" or self.state == "Going to granary" or self.state ==
                "Going to workplace with flour" or self.state == "Going to stockpile for flour") then
            self:update_direction()
            self:dir_sub_update()
        end
        if (self.state == "Going to workplace" or self.state == "Going to granary" or self.state ==
            "Going to workplace with flour" or self.state == "Going to stockpile for flour") then
            self:move()
        end
        if self.fx * 0.001 == self.waypoint_x and self.fy * 0.001 == self.waypoint_y and self.move_dir ~= "none" then
            if self.state == "Going to workplace" or self.state == "Going to workplace with flour" then
                if self:reached_path_end() then
                    self.workplace:work(self)
                    self:clear_path()
                    return
                else
                    self:set_next_waypoint()

                end
                self.count = self.count + 1
            elseif self.state == "Going to stockpile for flour" then
                if self:reached_path_end() then
                    local got_resource = _G.stockpile:take('flour')
                    if not got_resource then
                        self.state = "Waiting for flour"
                        return
                    else
                        self.state = "Go to workplace with flour"
                        self:clear_path()
                        return
                    end
                else
                    self:set_next_waypoint()

                end
                self.count = self.count + 1
            elseif self.state == "Going to granary" then
                if self:reached_path_end() then
                    _G.foodpile:store('bread')
                    _G.foodpile:store('bread')
                    _G.foodpile:store('bread')
                    _G.foodpile:store('bread')
                    self.state = "Go to stockpile for flour"
                    self:clear_path()
                    return
                else
                    self:set_next_waypoint()

                end
                self.count = self.count + 1
            end
        end
    end
end
function Baker:animate()
    self:update()
    Unit.animate(self)
end
function Baker:load(data)
    Object.deserialize(self, data)
    Unit.load(self, data)
    local an_data = data.animation
    if an_data then
        self.animation = anim.newAnimation(an[an_data.animation_identifier], 1, nil, an_data.animation_identifier)
        self.animation:deserialize(an_data)
    end
end
function Baker:serialize()
    local data = {}
    local unit_data = Unit.serialize(self)
    for k, v in pairs(unit_data) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    if self.animation then
        data.animation = self.animation:serialize()
    end
    data.state = self.state
    data.eat_timer = self.eat_timer
    data.wait_timer = self.wait_timer
    data.offset_y = self.offset_y
    data.offset_x = self.offset_x
    data.count = self.count
    return data
end
return Baker
