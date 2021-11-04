local _, _ = ...
local Unit = require("objects.Units.Unit")
local anim = require("libraries.anim8")
local indexQuads = _G.indexQuads

local fr_walking_east = indexQuads("body_peasant_walk_e", 16)
local fr_walking_north = indexQuads("body_peasant_walk_n", 16)
local fr_walking_northeast = indexQuads("body_peasant_walk_ne", 16)
local fr_walking_northwest = indexQuads("body_peasant_walk_nw", 16)
local fr_walking_south = indexQuads("body_peasant_walk_s", 16)
local fr_walking_southeast = indexQuads("body_peasant_walk_se", 16)
local fr_walking_southwest = indexQuads("body_peasant_walk_sw", 16)
local fr_walking_west = indexQuads("body_peasant_walk_w", 16)
local fr_bowing_north = indexQuads("body_peasant_bow_n", 6, nil, true)

local fr_idle_east_2 = indexQuads("body_peasant_walk_e", 11, 10)
local fr_idle_north_2 = indexQuads("body_peasant_walk_n", 11, 10)
local fr_idle_northeast_2 = indexQuads("body_peasant_walk_ne", 11, 10)
local fr_idle_northwest_2 = indexQuads("body_peasant_walk_nw", 11, 10)
local fr_idle_south_2 = indexQuads("body_peasant_walk_s", 11, 10)
local fr_idle_southeast_2 = indexQuads("body_peasant_walk_se", 11, 10)
local fr_idle_southwest_2 = indexQuads("body_peasant_walk_sw", 11, 10)
local fr_idle_west_2 = indexQuads("body_peasant_walk_w", 11, 10)
local Peasant = _G.class('Peasant', Unit)
function Peasant:initialize(gx, gy, type)
    Unit.initialize(self, gx, gy, type)
    self.workplace = nil
    self.state = 'Bowing'
    self.marked = 0
    self.count = 1
    self.offset_y = -10
    self.offset_x = -5
    self.eat_timer = 0
    self.timr = 0
    self.animated = true
    self.orientation = ""
    local bowing_end = function(animation)
        animation:pause()
        self.state = "Going to campfire"
    end
    self.animation = anim.newAnimation(fr_bowing_north, 0.12, bowing_end)
    local camp_x, camp_y, orientation = _G.campfire:get_next_free_spot(self)
    self.orientation = orientation
    self:requestPath(camp_x, camp_y)
    self.try_to_get_a_job = false
end
function Peasant:dir_sub_update()
    if self.move_dir == "west" then
        self.animation = anim.newAnimation(fr_walking_west, 0.05)
    elseif self.move_dir == "southwest" then
        self.animation = anim.newAnimation(fr_walking_southwest, 0.05)
    elseif self.move_dir == "northwest" then
        self.animation = anim.newAnimation(fr_walking_northwest, 0.05)
    elseif self.move_dir == "north" then
        self.animation = anim.newAnimation(fr_walking_north, 0.05)
    elseif self.move_dir == "south" then
        self.animation = anim.newAnimation(fr_walking_south, 0.05)
    elseif self.move_dir == "east" then
        self.animation = anim.newAnimation(fr_walking_east, 0.05)
    elseif self.move_dir == "southeast" then
        self.animation = anim.newAnimation(fr_walking_southeast, 0.05)
    elseif self.move_dir == "northeast" then
        self.animation = anim.newAnimation(fr_walking_northeast, 0.05)
    end
end
function Peasant:job_update()
    _G.removeObjectAt(self.lrcx, self.lrcy, self.lrx, self.lry, self)
end
function Peasant:get_a_job()
    if self.state == "Waiting" then
        self:requestPath(_G.spawn_point_x, _G.spawn_point_y)
        self.state = "Going to door"
    else
        self.try_to_get_a_job = true
    end
end
function Peasant:update()
    if self.try_to_get_a_job and self.state == "Waiting" then
        self:get_a_job()
    end
    self.eat_timer = self.eat_timer + 1
    if self.eat_timer > 3000 then
        _G.foodpile:take()
        self.eat_timer = 0
    end
    if self.path_state == "Waiting for path" then
        self:pathfind()
    elseif self.state == "Going to campfire" then
        self:update_direction()
        self:move()
    elseif self.state == "Going to door" then
        self:update_direction()
        self:move()
    end
    if self.fx * 0.001 == self.waypoint_x and self.fy * 0.001 == self.waypoint_y and self.move_dir ~= "none" then
        if self.state == "Going to campfire" or self.state == "Going to door" then
            if self.count == self.nd_len or self.nd[self.count] == nil then
                self.nd = {}
                self.waypoint_x, self.waypoint_y = nil, nil
                self.move_dir = "none"
                self.count = 1
                if self.state == "Going to campfire" then
                    self.state = "Waiting"
                    if self.orientation == "west" then
                        self.animation = anim.newAnimation(fr_idle_west_2, 0.11, 'pauseAtEnd')
                    elseif self.orientation == "southwest" then
                        self.animation = anim.newAnimation(fr_idle_southwest_2, 0.11, 'pauseAtEnd')
                    elseif self.orientation == "northwest" then
                        self.animation = anim.newAnimation(fr_idle_northwest_2, 0.11, 'pauseAtEnd')
                    elseif self.orientation == "north" then
                        self.animation = anim.newAnimation(fr_idle_north_2, 0.11, 'pauseAtEnd')
                    elseif self.orientation == "south" then
                        self.animation = anim.newAnimation(fr_idle_south_2, 0.11, 'pauseAtEnd')
                    elseif self.orientation == "east" then
                        self.animation = anim.newAnimation(fr_idle_east_2, 0.11, 'pauseAtEnd')
                    elseif self.orientation == "southeast" then
                        self.animation = anim.newAnimation(fr_idle_southeast_2, 0.11, 'pauseAtEnd')
                    elseif self.orientation == "northeast" then
                        self.animation = anim.newAnimation(fr_idle_northeast_2, 0.11, 'pauseAtEnd')
                    end
                elseif self.state == "Going to door" then
                    self.state = "Getting a job"
                    local getting_job = function()
                        self.to_be_deleted = true
                        _G.freeVertexFromTile(self.cx, self.cy, self.previous_vert_id)
                        self.animation = nil
                        _G.freeVertexFromTile(self.cx, self.cy, self.vert_id)
                        _G.removeObjectAt(self.cx, self.cy, self.i, self.o, self)
                        _G.JobController:add_available_worker()
                    end
                    self.animation = anim.newAnimation(fr_bowing_north, 0.12, getting_job)
                end
                return
            else
                -- TODO: Likes to throw an exception here, indexing a nil value at self.nd[self.count][1]
                -- fixed by making the upper if check if last node is same as first
                self.waypoint_x = self.nd[self.count][1]
                self.waypoint_y = self.nd[self.count][2]
                self.move_dir = "none"
            end
            self.count = self.count + 1
        end
    end
end
function Peasant:animate(dt)
    self:update()
    Unit.animate(self)
end
return Peasant
