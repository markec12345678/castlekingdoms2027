local object, tile_quads = ...
local Unit = require("objects.Units.Unit")

local fr_walking_east = indexQuads("body_baker_walk_e", 16)
local fr_walking_north = indexQuads("body_baker_walk_n", 16)
local fr_walking_northeast = indexQuads("body_baker_walk_ne", 16)
local fr_walking_northwest = indexQuads("body_baker_walk_nw", 16)
local fr_walking_south = indexQuads("body_baker_walk_s", 16)
local fr_walking_southeast = indexQuads("body_baker_walk_se", 16)
local fr_walking_southwest = indexQuads("body_baker_walk_sw", 16)
local fr_walking_west = indexQuads("body_baker_walk_w", 16)
-- flour
local fr_walking_flour_east = indexQuads("body_baker_walk_flour_e", 16)
local fr_walking_flour_north = indexQuads("body_baker_walk_flour_n", 16)
local fr_walking_flour_northeast = indexQuads("body_baker_walk_flour_ne", 16)
local fr_walking_flour_northwest = indexQuads("body_baker_walk_flour_nw", 16)
local fr_walking_flour_south = indexQuads("body_baker_walk_flour_s", 16)
local fr_walking_flour_southeast = indexQuads("body_baker_walk_flour_se", 16)
local fr_walking_flour_southwest = indexQuads("body_baker_walk_flour_sw", 16)
local fr_walking_flour_west = indexQuads("body_baker_walk_flour_w", 16)
-- bread
local fr_walking_bread_east = indexQuads("body_baker_walk_bread_e", 16)
local fr_walking_bread_north = indexQuads("body_baker_walk_bread_n", 16)
local fr_walking_bread_northeast = indexQuads("body_baker_walk_bread_ne", 16)
local fr_walking_bread_northwest = indexQuads("body_baker_walk_bread_nw", 16)
local fr_walking_bread_south = indexQuads("body_baker_walk_bread_s", 16)
local fr_walking_bread_southeast = indexQuads("body_baker_walk_bread_se", 16)
local fr_walking_bread_southwest = indexQuads("body_baker_walk_bread_sw", 16)
local fr_walking_bread_west = indexQuads("body_baker_walk_bread_w", 16)

local Baker = class('Baker', Unit)

function Baker:initialize(gx, gy, type)
    Unit.initialize(self, gx, gy, type)
    self.state = 'Find a job'
    self.marked = 0
    self.eat_timer = 0
    self.wait_timer = 0
    self.offset_y = -10
    self.offset_x = -5
    self.count = 1
    self.timr = 0
    self.animation = anim.newAnimation(fr_walking_west, 10)
end

function Baker:dir_sub_update()
    if self.move_dir == "west" then
        if self.state == "Going to granary" then
            self.animation = anim.newAnimation(fr_walking_bread_west, 0.05)
        elseif self.state == "Going to workplace with flour" then
            self.animation = anim.newAnimation(fr_walking_flour_west, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_west, 0.05)
        end
    elseif self.move_dir == "southwest" then
        if self.state == "Going to granary" then
            self.animation = anim.newAnimation(fr_walking_bread_southwest, 0.05)
        elseif self.state == "Going to workplace with flour" then
            self.animation = anim.newAnimation(fr_walking_flour_southwest, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_southwest, 0.05)
        end
    elseif self.move_dir == "northwest" then
        if self.state == "Going to granary" then
            self.animation = anim.newAnimation(fr_walking_bread_northwest, 0.05)
        elseif self.state == "Going to workplace with flour" then
            self.animation = anim.newAnimation(fr_walking_flour_northwest, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_northwest, 0.05)
        end
    elseif self.move_dir == "north" then
        if self.state == "Going to granary" then
            self.animation = anim.newAnimation(fr_walking_bread_north, 0.05)
        elseif self.state == "Going to workplace with flour" then
            self.animation = anim.newAnimation(fr_walking_flour_north, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_north, 0.05)
        end
    elseif self.move_dir == "south" then
        if self.state == "Going to granary" then
            self.animation = anim.newAnimation(fr_walking_bread_south, 0.05)
        elseif self.state == "Going to workplace with flour" then
            self.animation = anim.newAnimation(fr_walking_flour_south, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_south, 0.05)
        end
    elseif self.move_dir == "east" then
        if self.state == "Going to granary" then
            self.animation = anim.newAnimation(fr_walking_bread_east, 0.05)
        elseif self.state == "Going to workplace with flour" then
            self.animation = anim.newAnimation(fr_walking_flour_east, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_east, 0.05)
        end
    elseif self.move_dir == "southeast" then
        if self.state == "Going to granary" then
            self.animation = anim.newAnimation(fr_walking_bread_southeast, 0.05)
        elseif self.state == "Going to workplace with flour" then
            self.animation = anim.newAnimation(fr_walking_flour_southeast, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_southeast, 0.05)
        end
    elseif self.move_dir == "northeast" then
        if self.state == "Going to granary" then
            self.animation = anim.newAnimation(fr_walking_bread_northeast, 0.05)
        elseif self.state == "Going to workplace with flour" then
            self.animation = anim.newAnimation(fr_walking_flour_northeast, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_northeast, 0.05)
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
                self.nd = {}
                self.waypoint_x, self.waypoint_y = nil, nil
                self.move_dir = "none"
                self.count = 1
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
        elseif self.state == "Go to stockpile for flour" then
            if _G.stockpile then
                if self.state == "Go to stockpile" then
                    self.state = "Going to granary"
                else
                    self.state = "Going to stockpile for flour"
                end
                local closest_node
                local distance = math.huge
                for k, v in ipairs(_G.stockpile.node_list) do
                    local tmp = manhattan_distance(v.gx, v.gy, self.gx, self.gy)
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
        self.timr = self.timr + 1
        self.timr = self.timr % 60
        if (self.state == "Going to workplace" or self.state == "Going to granary" or self.state ==
            "Going to workplace with flour" or self.state == "Going to stockpile for flour") then
            self:move()
        end
        if self.fx * 0.001 == self.waypoint_x and self.fy * 0.001 == self.waypoint_y and self.move_dir ~= "none" then
            if self.state == "Going to workplace" or self.state == "Going to workplace with flour" then
                if self:reached_path_end() then
                    self.workplace:work(self)
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
            elseif self.state == "Going to stockpile for flour" then
                if self:reached_path_end() then
                    local got_resource = _G.stockpile:take('flour')
                    if not got_resource then
                        self.state = "Waiting for flour"
                        return
                    else
                        self.state = "Go to workplace with flour"
                        self.nd = {}
                        self.waypoint_x, self.waypoint_y = nil, nil
                        self.move_dir = "none"
                        self.count = 1
                        return
                    end
                else
                    self.waypoint_x = self.nd[self.count][1]
                    self.waypoint_y = self.nd[self.count][2]
                    self.move_dir = "none"
                end
                self.count = self.count + 1
            elseif self.state == "Going to granary" then
                if self:reached_path_end() then
                    _G.foodpile:store('bread')
                    _G.foodpile:store('bread')
                    _G.foodpile:store('bread')
                    _G.foodpile:store('bread')
                    self.state = "Go to stockpile for flour"
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

function Baker:animate()
    self:update()
    Unit.animate(self)
end

return Baker
