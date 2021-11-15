local object, tile_quads = ...
local Unit = require("objects.Units.Unit")

local fr_walking_east = indexQuads("body_miller_run_e", 16)
local fr_walking_north = indexQuads("body_miller_run_n", 16)
local fr_walking_northeast = indexQuads("body_miller_run_ne", 16)
local fr_walking_northwest = indexQuads("body_miller_run_nw", 16)
local fr_walking_south = indexQuads("body_miller_run_s", 16)
local fr_walking_southeast = indexQuads("body_miller_run_se", 16)
local fr_walking_southwest = indexQuads("body_miller_run_sw", 16)
local fr_walking_west = indexQuads("body_miller_run_w", 16)
-- wheat
local fr_walking_wheat_east = indexQuads("body_miller_walk_wheat_e", 16)
local fr_walking_wheat_north = indexQuads("body_miller_walk_wheat_n", 16)
local fr_walking_wheat_northeast = indexQuads("body_miller_walk_wheat_ne", 16)
local fr_walking_wheat_northwest = indexQuads("body_miller_walk_wheat_nw", 16)
local fr_walking_wheat_south = indexQuads("body_miller_walk_wheat_s", 16)
local fr_walking_wheat_southeast = indexQuads("body_miller_walk_wheat_se", 16)
local fr_walking_wheat_southwest = indexQuads("body_miller_walk_wheat_sw", 16)
local fr_walking_wheat_west = indexQuads("body_miller_walk_wheat_w", 16)
-- flower
local fr_walking_flour_east = indexQuads("body_miller_walk_flour_e", 16)
local fr_walking_flour_north = indexQuads("body_miller_walk_flour_n", 16)
local fr_walking_flour_northeast = indexQuads("body_miller_walk_flour_ne", 16)
local fr_walking_flour_northwest = indexQuads("body_miller_walk_flour_nw", 16)
local fr_walking_flour_south = indexQuads("body_miller_walk_flour_s", 16)
local fr_walking_flour_southeast = indexQuads("body_miller_walk_flour_se", 16)
local fr_walking_flour_southwest = indexQuads("body_miller_walk_flour_sw", 16)
local fr_walking_flour_west = indexQuads("body_miller_walk_flour_w", 16)

local Miller = class('Miller', Unit)

function Miller:initialize(gx, gy, type)
    Unit.initialize(self, gx, gy, type)
    self.state = 'Find a job'
    self.marked = 0
    self.eat_timer = 0
    self.wait_timer = 0
    self.offset_y = -10
    self.offset_x = -5
    self.count = 1
    self.animation = anim.newAnimation(fr_walking_west, 10)
end

function Miller:dir_sub_update()
    if self.move_dir == "west" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(fr_walking_flour_west, 0.05)
        elseif self.state == "Going to workplace with wheat" then
            self.animation = anim.newAnimation(fr_walking_wheat_west, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_west, 0.05)
        end
    elseif self.move_dir == "southwest" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(fr_walking_flour_southwest, 0.05)
        elseif self.state == "Going to workplace with wheat" then
            self.animation = anim.newAnimation(fr_walking_wheat_southwest, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_southwest, 0.05)
        end
    elseif self.move_dir == "northwest" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(fr_walking_flour_northwest, 0.05)
        elseif self.state == "Going to workplace with wheat" then
            self.animation = anim.newAnimation(fr_walking_wheat_northwest, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_northwest, 0.05)
        end
    elseif self.move_dir == "north" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(fr_walking_flour_north, 0.05)
        elseif self.state == "Going to workplace with wheat" then
            self.animation = anim.newAnimation(fr_walking_wheat_north, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_north, 0.05)
        end
    elseif self.move_dir == "south" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(fr_walking_flour_south, 0.05)
        elseif self.state == "Going to workplace with wheat" then
            self.animation = anim.newAnimation(fr_walking_wheat_south, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_south, 0.05)
        end
    elseif self.move_dir == "east" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(fr_walking_flour_east, 0.05)
        elseif self.state == "Going to workplace with wheat" then
            self.animation = anim.newAnimation(fr_walking_wheat_east, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_east, 0.05)
        end
    elseif self.move_dir == "southeast" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(fr_walking_flour_southeast, 0.05)
        elseif self.state == "Going to workplace with wheat" then
            self.animation = anim.newAnimation(fr_walking_wheat_southeast, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_southeast, 0.05)
        end
    elseif self.move_dir == "northeast" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(fr_walking_flour_northeast, 0.05)
        elseif self.state == "Going to workplace with wheat" then
            self.animation = anim.newAnimation(fr_walking_wheat_northeast, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_northeast, 0.05)
        end
    end
end

function Miller:update()
    self.eat_timer = self.eat_timer + 1
    if self.eat_timer > 3000 then
        _G.foodpile:take()
        self.eat_timer = 0
    end
    self.wait_timer = self.wait_timer + _G.dt
    if self.wait_timer > 1 then
        if self.state == "Waiting for wheat" then
            self.wait_timer = 0
            local got_resource = _G.stockpile:take('wheat')
            if not got_resource then
                self.state = "Waiting for wheat"
                return
            else
                self.state = "Go to workplace with wheat"
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
    elseif self.state == "Waiting for work" then
        self.workplace:work(self)
    elseif self.state ~= "No path to workplace" and self.state ~= "Working" then
        if self.state == "Find a job" then
            _G.JobController:find_job(self, "Miller")
        elseif self.state == "Go to stockpile" or self.state == "Go to stockpile for wheat" then
            if _G.stockpile then
                if self.state == "Go to stockpile" then
                    self.state = "Going to stockpile"
                else
                    self.state = "Going to stockpile for wheat"
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
        elseif self.state == "Go to workplace" or self.state == "Go to workplace with wheat" then
            if self.workplace.worker == self then
                self:requestPath(self.workplace.gx, self.workplace.gy + 4)
            elseif self.workplace.worker2 == self then
                self:requestPath(self.workplace.gx + 1, self.workplace.gy + 4)
            else
                self:requestPath(self.workplace.gx + 2, self.workplace.gy + 4)
            end
            if self.state == "Go to workplace with wheat" then
                self.state = "Going to workplace with wheat"
            else
                self.state = "Going to workplace"
            end
            self.move_dir = "none"
            return
        elseif self.move_dir == "none" and
            (self.state == "Going to workplace" or self.state == "Going to stockpile" or self.state ==
                "Going to workplace with wheat" or self.state == "Going to stockpile for wheat") then
            self:update_direction()
            self:dir_sub_update()
        end
        if (self.state == "Going to workplace" or self.state == "Going to stockpile" or self.state ==
            "Going to workplace with wheat" or self.state == "Going to stockpile for wheat") then
            self:move()
        end
        if self.fx * 0.001 == self.waypoint_x and self.fy * 0.001 == self.waypoint_y and self.move_dir ~= "none" then
            if self.state == "Going to workplace" or self.state == "Going to workplace with wheat" then
                if self:reached_path_end() then
                    self.workplace:work(self)
                    return
                else
                    self.waypoint_x = self.nd[self.count][1]
                    self.waypoint_y = self.nd[self.count][2]
                    self.move_dir = "none"
                end
                self.count = self.count + 1
            elseif self.state == "Going to stockpile for wheat" or self.state == "Going to stockpile" then
                if self:reached_path_end() then
                    if self.state == "Going to stockpile" then
                        _G.stockpile:store('flour')
                    end
                    local got_resource = _G.stockpile:take('wheat')
                    if not got_resource then
                        self.state = "Waiting for wheat"
                        return
                    else
                        self.state = "Go to workplace with wheat"
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
            end
        end
    end
end

function Miller:animate()
    self:update()
    Unit.animate(self)
end

return Miller
