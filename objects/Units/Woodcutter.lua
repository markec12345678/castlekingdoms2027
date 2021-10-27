local object, tile_quads = ...
local Unit = require("objects.Units.Unit")
local fr_walking_plank_east = indexQuads("body_woodcutter_walk_plank_e", 16)
local fr_walking_plank_north = indexQuads("body_woodcutter_walk_plank_n", 16)
local fr_walking_plank_west = indexQuads("body_woodcutter_walk_plank_w", 16)
local fr_walking_plank_south = indexQuads("body_woodcutter_walk_plank_s", 16)
local fr_walking_plank_northeast = indexQuads("body_woodcutter_walk_plank_ne", 16)
local fr_walking_plank_northwest = indexQuads("body_woodcutter_walk_plank_nw", 16)
local fr_walking_plank_southeast = indexQuads("body_woodcutter_walk_plank_se", 16)
local fr_walking_plank_southwest = indexQuads("body_woodcutter_walk_plank_sw", 16)
local fr_walking_log_east = indexQuads("body_woodcutter_walk_log_e", 16)
local fr_walking_log_north = indexQuads("body_woodcutter_walk_log_n", 16)
local fr_walking_log_west = indexQuads("body_woodcutter_walk_log_w", 16)
local fr_walking_log_south = indexQuads("body_woodcutter_walk_log_s", 16)
local fr_walking_log_northeast = indexQuads("body_woodcutter_walk_log_ne", 16)
local fr_walking_log_northwest = indexQuads("body_woodcutter_walk_log_nw", 16)
local fr_walking_log_southeast = indexQuads("body_woodcutter_walk_log_se", 16)
local fr_walking_log_southwest = indexQuads("body_woodcutter_walk_log_sw", 16)
local fr_walking_east = indexQuads("body_woodcutter_walk_e", 16)
local fr_walking_north = indexQuads("body_woodcutter_walk_n", 16)
local fr_walking_northeast = indexQuads("body_woodcutter_walk_ne", 16)
local fr_walking_northwest = indexQuads("body_woodcutter_walk_nw", 16)
local fr_walking_south = indexQuads("body_woodcutter_walk_s", 16)
local fr_walking_southeast = indexQuads("body_woodcutter_walk_se", 16)
local fr_walking_southwest = indexQuads("body_woodcutter_walk_sw", 16)
local fr_walking_west = indexQuads("body_woodcutter_walk_w", 16)
local fr_cutting_northeast = indexQuads("body_woodcutter_cut_ne", 12)

local Woodcutter = class('Woodcutter', Unit)
function Woodcutter:initialize(gx, gy, type)
    Unit.initialize(self, gx, gy, type)
    local walking_speed_anim = 0.05
    self.workplace = nil
    self.an_walking_plank_west = anim.newAnimation(fr_walking_plank_west, walking_speed_anim)
    self.an_walking_log_west = anim.newAnimation(fr_walking_log_west, walking_speed_anim)
    self.an_walking_west = anim.newAnimation(fr_walking_west, walking_speed_anim)
    self.an_walking_plank_southwest = anim.newAnimation(fr_walking_plank_southwest, walking_speed_anim)
    self.an_walking_log_southwest = anim.newAnimation(fr_walking_log_southwest, walking_speed_anim)
    self.an_walking_southwest = anim.newAnimation(fr_walking_southwest, walking_speed_anim)
    self.an_walking_plank_northwest = anim.newAnimation(fr_walking_plank_northwest, walking_speed_anim)
    self.an_walking_log_northwest = anim.newAnimation(fr_walking_log_northwest, walking_speed_anim)
    self.an_walking_northwest = anim.newAnimation(fr_walking_northwest, walking_speed_anim)
    self.an_walking_plank_north = anim.newAnimation(fr_walking_plank_north, walking_speed_anim)
    self.an_walking_log_north = anim.newAnimation(fr_walking_log_north, walking_speed_anim)
    self.an_walking_north = anim.newAnimation(fr_walking_north, walking_speed_anim)
    self.an_walking_plank_south = anim.newAnimation(fr_walking_plank_south, walking_speed_anim)
    self.an_walking_log_south = anim.newAnimation(fr_walking_log_south, walking_speed_anim)
    self.an_walking_south = anim.newAnimation(fr_walking_south, walking_speed_anim)
    self.an_walking_plank_east = anim.newAnimation(fr_walking_plank_east, walking_speed_anim)
    self.an_walking_log_east = anim.newAnimation(fr_walking_log_east, walking_speed_anim)
    self.an_walking_east = anim.newAnimation(fr_walking_east, walking_speed_anim)
    self.an_walking_plank_southeast = anim.newAnimation(fr_walking_plank_southeast, walking_speed_anim)
    self.an_walking_log_southeast = anim.newAnimation(fr_walking_log_southeast, walking_speed_anim)
    self.an_walking_southeast = anim.newAnimation(fr_walking_southeast, walking_speed_anim)
    self.an_walking_plank_northeast = anim.newAnimation(fr_walking_plank_northeast, walking_speed_anim)
    self.an_walking_log_northeast = anim.newAnimation(fr_walking_log_northeast, walking_speed_anim)
    self.an_walking_northeast = anim.newAnimation(fr_walking_northeast, walking_speed_anim)
    self.state = 'Find a job'
    self.marked = 0
    self.count = 1
    self.eat_timer = 0
    self.offset_x = -5
    self.offset_y = -10
    self.store_timer = 0
    self.target_tree = 0
    self.cut = function()
        if self.state == "Cutting down" then
            local tree_progress
            if self.target_tree.tree and self.target_tree.cuttable then
                tree_progress = self.target_tree:cut()
            else
                self.state = "Looking to chop tree"
                self.move_dir = "none"
            end
            if tree_progress == 2 then
                self.i = math.round((self.fx * 0.001)) % chunk_width
                self.o = math.round((self.fy * 0.001)) % chunk_width
                self.move_dir = "none"
                self.count = 1
                tree_progress = 3
                self.state = "Going to workplace with wood"
                self:requestPath(self.workplace.gx + 1, self.workplace.gy + 3)
            end
        end
    end
    self.animation = anim.newAnimation(fr_walking_west, 10)
end
function Woodcutter:job_update()
    removeObjectAt(self.lrcx, self.lrcy, self.lrx, self.lry, self)
end
function Woodcutter:check_trees(cx, cy)
    local chunkx, chunky = cx or self.cx, cy or self.cy
    local closest_object, closest_distance = nil, 10000000
    if _G.chunk_objects[chunkx][chunky] then
        for index, obj in pairs(_G.chunk_objects[chunkx][chunky]) do
            if (obj.type == 'Pine tree' or obj.type == "Small pine tree" or obj.type == "Medium pine tree") and
                obj.marked == false then
                -- TODO: Fix magic numbers CRITICAL
                if obj.gx > 0 and obj.gx < 2047 and obj.gy > 0 and obj.gy < 2047 then -- and _G.nodes[obj.gx][obj.gy+1].walkable == 0 then --fixme
                    local dist = manhattan_distance(self.gx, self.gy, obj.gx, obj.gy)
                    if dist < closest_distance then
                        closest_object = obj
                        closest_distance = dist
                    end
                end
            end
        end
    end
    if not closest_object then
        return false, false
    else
        return closest_object, closest_distance
    end
end
function Woodcutter:find_tree()
    local closest_object, closest_distance = nil, 10000000
    local objt, disto
    objt, disto = self:check_trees(self.cx, self.cy)
    if disto and disto < closest_distance then
        closest_object = objt
        closest_distance = disto
    end
    objt, disto = self:check_trees(self.cx + 1, self.cy)
    if disto and disto < closest_distance then
        closest_object = objt
        closest_distance = disto
    end
    objt, disto = self:check_trees(self.cx + 1, self.cy + 1)
    if disto and disto < closest_distance then
        closest_object = objt
        closest_distance = disto
    end
    objt, disto = self:check_trees(self.cx + 1, self.cy - 1)
    if disto and disto < closest_distance then
        closest_object = objt
        closest_distance = disto
    end
    objt, disto = self:check_trees(self.cx - 1, self.cy + 1)
    if disto and disto < closest_distance then
        closest_object = objt
        closest_distance = disto
    end
    objt, disto = self:check_trees(self.cx - 1, self.cy)
    if disto and disto < closest_distance then
        closest_object = objt
        closest_distance = disto
    end
    objt, disto = self:check_trees(self.cx - 1, self.cy - 1)
    if disto and disto < closest_distance then
        closest_object = objt
        closest_distance = disto
    end
    objt, disto = self:check_trees(self.cx, self.cy + 1)
    if disto and disto < closest_distance then
        closest_object = objt
        closest_distance = disto
    end
    objt, disto = self:check_trees(self.cx, self.cy - 1)

    if not importantObjectAtGlobal(objt.gx, objt.gy + 1) then
        if disto and disto < closest_distance then
            closest_object = objt
            closest_distance = disto
        end
    end
    if not closest_object then
        print("No trees nearby!")
        self.state = "No trees"
        return
    end
    self.target_tree = closest_object
    self.endx = closest_object.gx
    self.endy = closest_object.gy + 1
    if self.endx == self.gx and self.endy == self.gy then
        self.state = "Cutting down"
        self.animation = anim.newAnimation(fr_cutting_northeast, 0.08, self.cut)
        self.nd = {}
        self.waypoint_x, self.waypoint_y = nil, nil
        self.move_dir = "none"
        self.count = 1
    else
        self:requestPath(self.endx, self.endy)
        self.state = "Going to tree"
    end
    closest_object.marked = true
end
function Woodcutter:dir_sub_update()
    if self.move_dir == "west" then
        if self.state == "Going to stockpile" then
            self.animation = self.an_walking_plank_west
        elseif self.state == "Going to workplace with wood" then
            self.animation = self.an_walking_log_west
        else
            self.animation = self.an_walking_west
        end
    elseif self.move_dir == "southwest" then
        if self.state == "Going to stockpile" then
            self.animation = self.an_walking_plank_southwest
        elseif self.state == "Going to workplace with wood" then
            self.animation = self.an_walking_log_southwest
        else
            self.animation = self.an_walking_southwest
        end
    elseif self.move_dir == "northwest" then
        if self.state == "Going to stockpile" then
            self.animation = self.an_walking_plank_northwest
        elseif self.state == "Going to workplace with wood" then
            self.animation = self.an_walking_log_northwest
        else
            self.animation = self.an_walking_northwest
        end
    elseif self.move_dir == "north" then
        if self.state == "Going to stockpile" then
            self.animation = self.an_walking_plank_north
        elseif self.state == "Going to workplace with wood" then
            self.animation = self.an_walking_log_north
        else
            self.animation = self.an_walking_north
        end
    elseif self.move_dir == "south" then
        if self.state == "Going to stockpile" then
            self.animation = self.an_walking_plank_south
        elseif self.state == "Going to workplace with wood" then
            self.animation = self.an_walking_log_south
        else
            self.animation = self.an_walking_south
        end
    elseif self.move_dir == "east" then
        if self.state == "Going to stockpile" then
            self.animation = self.an_walking_plank_east
        elseif self.state == "Going to workplace with wood" then
            self.animation = self.an_walking_log_east
        else
            self.animation = self.an_walking_east
        end
    elseif self.move_dir == "southeast" then
        if self.state == "Going to stockpile" then
            self.animation = self.an_walking_plank_southeast
        elseif self.state == "Going to workplace with wood" then
            self.animation = self.an_walking_log_southeast
        else
            self.animation = self.an_walking_southeast
        end
    elseif self.move_dir == "northeast" then
        if self.state == "Going to stockpile" then
            self.animation = self.an_walking_plank_northeast
        elseif self.state == "Going to workplace with wood" then
            self.animation = self.an_walking_log_northeast
        else
            self.animation = self.an_walking_northeast
        end
    end
end
function Woodcutter:update()
    self.eat_timer = self.eat_timer + 1
    self.store_timer = self.store_timer + 1
    if self.eat_timer > 3000 then
        _G.foodpile:take()
        self.eat_timer = 0
    end
    if self.path_state == "Waiting for path" then
        self:pathfind()
    elseif self.state == "Find a job" then
        _G.JobController:find_job(self, "Woodcutter")
    elseif self.state == "Storing second plank" and self.store_timer > 10 then
        self.store_timer = 0
        self.state = "Storing third plank"
        _G.stockpile:store('wood')
    elseif self.state == "Storing third plank" and self.store_timer > 10 then
        self.store_timer = 0
        _G.stockpile:store('wood')
        self.state = "Storing fourth plank"
    elseif self.state == "Storing fourth plank" and self.store_timer > 10 then
        self.store_timer = 0
        _G.stockpile:store('wood')
        self.animation:resume()
        self.state = "Go to workplace"
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
                print("Closest stockpile node not found")
            else
                self:requestPath(closest_node.gx, closest_node.gy)
            end
            self.move_dir = "none"
        end
    elseif self.state ~= "No trees" then
        if self.state == "Looking to chop tree" then
            self:find_tree()
        elseif self.state == "Go to workplace" then
            self.gx, self.gy = math.round(self.gx), math.round(self.gy)
            self.fx, self.fy = self.gx * 1000, self.gy * 1000
            self:requestPath(self.workplace.gx + 1, self.workplace.gy + 3)
            self.state = "Going to workplace"
            self.move_dir = "none"
        elseif self.state == "Going to tree" or self.state == "Going to stockpile" or self.state == "Going to workplace" or
            self.state == "Going to workplace with wood" then
            if self.move_dir == "none" then
                self:update_direction()
                self:dir_sub_update()
            end
            self:move()
        end
        if self.fx * 0.001 == self.waypoint_x and self.fy * 0.001 == self.waypoint_y and self.move_dir ~= "none" then
            if self.state == "Going to tree" then
                if self.count == self.nd_len then
                    self.state = "Cutting down"
                    self.animation = anim.newAnimation(fr_cutting_northeast, 0.10, self.cut)
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
            elseif self.state == "Going to workplace with wood" then
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
                    self.move_dir = "none"
                end
                self.count = self.count + 1
            elseif self.state == "Going to stockpile" then
                if self.count == self.nd_len then
                    _G.stockpile:store('wood')
                    self.state = "Storing second plank"
                    self.animation:pause()
                    self.store_timer = 0
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
            elseif self.state == "Going to workplace" then
                if self.count == self.nd_len then
                    self.state = "Looking to chop tree"
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
function Woodcutter:animate()
    self:update()
    self.animation:update(dt)
end
return Woodcutter
