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
local fr_gather_apples_east = indexQuads("body_farmer_actual_apples_e", 10)
local fr_gather_apples_north = indexQuads("body_farmer_actual_apples_n", 10)
local fr_gather_apples_west = indexQuads("body_farmer_actual_apples_w", 10)
local fr_gather_apples_south = indexQuads("body_farmer_actual_apples_s", 10)
local fr_gather_apples_northeast = indexQuads("body_farmer_actual_apples_ne", 10)
local fr_gather_apples_northwest = indexQuads("body_farmer_actual_apples_nw", 10)
local fr_gather_apples_southeast = indexQuads("body_farmer_actual_apples_se", 10)
local fr_gather_apples_southwest = indexQuads("body_farmer_actual_apples_sw", 10)
local Farmer = class('Farmer', Unit)
function Farmer:initialize(gx, gy, type)
    Unit.initialize(self, gx, gy, type)
    self.workplace = nil
    self.state = 'Find a job'
    self.marked = 0
    self.count = 1
    self.offset_y = -10
    self.offset_x = -5
    self.eat_timer = 0
    self.timr = 0
    self.animated = true
    self.animation = anim.newAnimation(fr_walking_west, 10)
end
function Farmer:dir_sub_update()
    if self.move_dir == "west" then
        if self.state == "Going to foodpile" or self.state == "Going to apple tree" then
            self.animation = anim.newAnimation(fr_walking_apples_west, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_west, 0.05)
        end
    elseif self.move_dir == "southwest" then
        if self.state == "Going to foodpile" or self.state == "Going to apple tree" then
            self.animation = anim.newAnimation(fr_walking_apples_southwest, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_southwest, 0.05)
        end
    elseif self.move_dir == "northwest" then
        if self.state == "Going to foodpile" or self.state == "Going to apple tree" then
            self.animation = anim.newAnimation(fr_walking_apples_northwest, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_northwest, 0.05)
        end
    elseif self.move_dir == "north" then
        if self.state == "Going to foodpile" or self.state == "Going to apple tree" then
            self.animation = anim.newAnimation(fr_walking_apples_north, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_north, 0.05)
        end
    elseif self.move_dir == "south" then
        if self.state == "Going to foodpile" or self.state == "Going to apple tree" then
            self.animation = anim.newAnimation(fr_walking_apples_south, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_south, 0.05)
        end
    elseif self.move_dir == "east" then
        if self.state == "Going to foodpile" or self.state == "Going to apple tree" then
            self.animation = anim.newAnimation(fr_walking_apples_east, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_east, 0.05)
        end
    elseif self.move_dir == "southeast" then
        if self.state == "Going to foodpile" or self.state == "Going to apple tree" then
            self.animation = anim.newAnimation(fr_walking_apples_southeast, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_southeast, 0.05)
        end
    elseif self.move_dir == "northeast" then
        if self.state == "Going to foodpile" or self.state == "Going to apple tree" then
            self.animation = anim.newAnimation(fr_walking_apples_northeast, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_northeast, 0.05)
        end
    end
end
function Farmer:job_update()
    removeObjectAt(self.lrcx, self.lrcy, self.lrx, self.lry, self)
end
function Farmer:update()
    self.eat_timer = self.eat_timer + 1
    if self.eat_timer > 3000 then
        _G.foodpile:take()
        self.eat_timer = 0
    end
    if self.path_state == "Waiting for path" and self.state ~= "Working" then
        self:pathfind()
    elseif self.state ~= "No path to farm" then
        if self.state == "Find a job" then
            _G.JobController:find_job(self, "Farmer")
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
        self.timr = self.timr + 1
        self.timr = self.timr % 60
        if self.state == "Going to workplace" or self.state == "Going to foodpile" or self.state ==
            "Going to apple tree" then
            self:move()
        end
        if self.fx * 0.001 == self.waypoint_x and self.fy * 0.001 == self.waypoint_y and self.move_dir ~= "none" then
            if self.state == "Going to workplace" or self.state == "Going to apple tree" then
                if self.count == self.nd_len then
                    if self.state == "Going to apple tree" then
                        self.state = "Working"
                        local loop = 0
                        self.animation = anim.newAnimation(fr_gather_apples_east, 0.1, function()
                            loop = loop + 1
                            if loop > 3 then
                                self.workplace:work(self)
                                loop = 0
                            end
                        end)
                    else
                        self.workplace:work(self)
                    end
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
function Farmer:animate()
    self:update()
    self.animation:update(dt)
end
return Farmer
