local object, tile_quads = ...
local Unit = require("objects.Units.Unit")

local fr_walking_east = indexQuads("body_iron_miner_walk_e", 16)
local fr_walking_north = indexQuads("body_iron_miner_walk_n", 16)
local fr_walking_northeast = indexQuads("body_iron_miner_walk_ne", 16)
local fr_walking_northwest = indexQuads("body_iron_miner_walk_nw", 16)
local fr_walking_south = indexQuads("body_iron_miner_walk_s", 16)
local fr_walking_southeast = indexQuads("body_iron_miner_walk_se", 16)
local fr_walking_southwest = indexQuads("body_iron_miner_walk_sw", 16)
local fr_walking_west = indexQuads("body_iron_miner_walk_w", 16)
local fr_walking_iron_east = indexQuads("body_iron_miner_walk_ingot_e", 16)
local fr_walking_iron_north = indexQuads("body_iron_miner_walk_ingot_n", 16)
local fr_walking_iron_northeast = indexQuads("body_iron_miner_walk_ingot_ne", 16)
local fr_walking_iron_northwest = indexQuads("body_iron_miner_walk_ingot_nw", 16)
local fr_walking_iron_south = indexQuads("body_iron_miner_walk_ingot_s", 16)
local fr_walking_iron_southeast = indexQuads("body_iron_miner_walk_ingot_se", 16)
local fr_walking_iron_southwest = indexQuads("body_iron_miner_walk_ingot_sw", 16)
local fr_walking_iron_west = indexQuads("body_iron_miner_walk_ingot_w", 16)

local Miner = class('Miner', Unit)

function Miner:initialize(gx, gy, type)
    Unit.initialize(self, gx, gy, type)
    self.state = 'Find a job'
    self.marked = 0
    self.eat_timer = 0
    self.offset_y = -10
    self.offset_x = -5
    self.count = 1
    self.timr = 0
    self.animation = anim.newAnimation(fr_walking_west, 10)
end

function Miner:dir_sub_update()
    if self.move_dir == "west" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(fr_walking_iron_west, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_west, 0.05)
        end
    elseif self.move_dir == "southwest" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(fr_walking_iron_southwest, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_southwest, 0.05)
        end
    elseif self.move_dir == "northwest" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(fr_walking_iron_northwest, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_northwest, 0.05)
        end
    elseif self.move_dir == "north" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(fr_walking_iron_north, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_north, 0.05)
        end
    elseif self.move_dir == "south" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(fr_walking_iron_south, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_south, 0.05)
        end
    elseif self.move_dir == "east" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(fr_walking_iron_east, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_east, 0.05)
        end
    elseif self.move_dir == "southeast" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(fr_walking_iron_southeast, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_southeast, 0.05)
        end
    elseif self.move_dir == "northeast" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(fr_walking_iron_northeast, 0.05)
        else
            self.animation = anim.newAnimation(fr_walking_northeast, 0.05)
        end
    end
end

function Miner:job_update()
    removeObjectAt(self.lrcx, self.lrcy, self.lrx, self.lry, self)
end

function Miner:update()
    self.eat_timer = self.eat_timer + 1
    if self.eat_timer > 3000 then
        _G.foodpile:take()
        self.eat_timer = 0
    end
    if self.path_state == "Waiting for path" then
        self:pathfind()
    elseif self.state ~= "No path to workplace" and self.state ~= "Working" then
        if self.state == "Find a job" then
            _G.JobController:find_job(self, "Miner")
        elseif self.state == "Go to stockpile" then
            if _G.stockpile then
                self.state = "Going to stockpile"
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
        elseif self.state == "Go to workplace" then
            self:requestPath(self.workplace.gx - 1, self.workplace.gy + 1)
            self.state = "Going to workplace"
            self.move_dir = "none"
        elseif self.move_dir == "none" and self.state == "Going to workplace" then
            self:update_direction()
            self:dir_sub_update()
        elseif self.move_dir == "none" and self.state == "Going to stockpile" then
            self:update_direction()
            self:dir_sub_update()
        end
        self.timr = self.timr + 1
        self.timr = self.timr % 60
        if self.state == "Going to workplace" or self.state == "Going to stockpile" then
            self:move()
        end
        if self.fx * 0.001 == self.waypoint_x and self.fy * 0.001 == self.waypoint_y and self.move_dir ~= "none" then
            if self.state == "Going to workplace" then
                if self.count == self.nd_len then
                    self.workplace:work(self)
                    self.nd = {}
                    self.waypoint_x, self.waypoint_y = nil, nil
                    self.move_dir = "none"
                    self.count = 1
                    return
                else
                    self.waypoint_x = self.nd[self.count][1]
                    self.waypoint_y = self.nd[self.count][2]
                    -- self.previous_dir = self.move_dir
                    self.move_dir = "none"
                end
                self.count = self.count + 1
            elseif self.state == "Going to stockpile" then
                if self.count == self.nd_len then
                    _G.stockpile:store('iron')
                    self.state = "Go to workplace"
                    self.nd = {}
                    self.waypoint_x, self.waypoint_y = nil, nil
                    self.move_dir = "none"
                    self.count = 1
                    return
                else
                    self.waypoint_x = self.nd[self.count][1]
                    self.waypoint_y = self.nd[self.count][2]
                    -- self.previous_dir = self.move_dir
                    self.move_dir = "none"
                end
                self.count = self.count + 1
            end
        end
    end
end

function Miner:animate()
    self:update()
    Unit.animate(self)
end

return Miner
