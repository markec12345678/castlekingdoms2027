local _, _ = ...
local Unit = require("objects.Units.Unit")
local Object = require("objects.Object")
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

local AN_BOWING = "Bowing"
local AN_BOWING_FOR_A_JOB = "Bowing for a job"
local AN_WALKING_WEST = "Walking west"
local AN_WALKING_SOUTHWEST = "Walking southwest"
local AN_WALKING_NORTHWEST = "Walking northwest"
local AN_WALKING_NORTH = "Walking north"
local AN_WALKING_SOUTH = "Walking south"
local AN_WALKING_EAST = "Walking east"
local AN_WALKING_SOUTHEAST = "Walking southeast"
local AN_WALKING_NORTHEAST = "Walking northeast"
local AN_IDLE_WEST = "Idling west"
local AN_IDLE_SOUTHWEST = "Idling southwest"
local AN_IDLE_NORTHWEST = "Idling northwest"
local AN_IDLE_NORTH = "Idling north"
local AN_IDLE_SOUTH = "Idling south"
local AN_IDLE_EAST = "Idling east"
local AN_IDLE_SOUTHEAST = "Idling southeast"
local AN_IDLE_NORTHEAST = "Idling northeast"

local an = {
    [AN_BOWING] = fr_bowing_north,
    [AN_BOWING_FOR_A_JOB] = fr_bowing_north,
    [AN_WALKING_WEST] = fr_walking_west,
    [AN_WALKING_SOUTHWEST] = fr_walking_southwest,
    [AN_WALKING_NORTHWEST] = fr_walking_northwest,
    [AN_WALKING_NORTH] = fr_walking_north,
    [AN_WALKING_SOUTH] = fr_walking_south,
    [AN_WALKING_EAST] = fr_walking_east,
    [AN_WALKING_SOUTHEAST] = fr_walking_southeast,
    [AN_WALKING_NORTHEAST] = fr_walking_northeast,
    [AN_IDLE_WEST] = fr_idle_west_2,
    [AN_IDLE_SOUTHWEST] = fr_idle_southwest_2,
    [AN_IDLE_NORTHWEST] = fr_idle_northwest_2,
    [AN_IDLE_NORTH] = fr_idle_north_2,
    [AN_IDLE_SOUTH] = fr_idle_south_2,
    [AN_IDLE_EAST] = fr_idle_east_2,
    [AN_IDLE_SOUTHEAST] = fr_idle_southeast_2,
    [AN_IDLE_NORTHEAST] = fr_idle_northeast_2
}

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
    self.animation = anim.newAnimation(an[AN_BOWING], 0.12, bowing_end, AN_BOWING)
    local camp_x, camp_y, orientation = _G.campfire:get_next_free_spot(self)
    self.orientation = orientation
    self:requestPath(camp_x, camp_y)
    self.try_to_get_a_job = false
end
function Peasant:load(data)
    Object.deserialize(self, data)
    Unit.load(self, data)
    local an_data = data.animation
    local callback
    if an_data then
        if an_data.animation_identifier == AN_BOWING then
            callback = function(animation)
                animation:pause()
                self.state = "Going to campfire"
            end
        elseif an_data.animation_identifier == AN_BOWING_FOR_A_JOB then
            callback = function()
                self:bowing_job_callback()
            end
        end
        self.animation = anim.newAnimation(an[an_data.animation_identifier], 1, callback, an_data.animation_identifier)
        self.animation:deserialize(an_data)
    end
end
function Peasant:dir_sub_update()
    if self.move_dir == "west" then
        self.animation = anim.newAnimation(an[AN_WALKING_WEST], 0.05, nil, AN_WALKING_WEST)
    elseif self.move_dir == "southwest" then
        self.animation = anim.newAnimation(an[AN_WALKING_SOUTHWEST], 0.05, nil, AN_WALKING_SOUTHWEST)
    elseif self.move_dir == "northwest" then
        self.animation = anim.newAnimation(an[AN_WALKING_NORTHWEST], 0.05, nil, AN_WALKING_NORTHWEST)
    elseif self.move_dir == "north" then
        self.animation = anim.newAnimation(an[AN_WALKING_NORTH], 0.05, nil, AN_WALKING_NORTH)
    elseif self.move_dir == "south" then
        self.animation = anim.newAnimation(an[AN_WALKING_SOUTH], 0.05, nil, AN_WALKING_SOUTH)
    elseif self.move_dir == "east" then
        self.animation = anim.newAnimation(an[AN_WALKING_EAST], 0.05, nil, AN_WALKING_EAST)
    elseif self.move_dir == "southeast" then
        self.animation = anim.newAnimation(an[AN_WALKING_SOUTHEAST], 0.05, nil, AN_WALKING_SOUTHEAST)
    elseif self.move_dir == "northeast" then
        self.animation = anim.newAnimation(an[AN_WALKING_NORTHEAST], 0.05, nil, AN_WALKING_NORTHEAST)
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
            if self:reached_path_end() then
                self.nd = {}
                self.waypoint_x, self.waypoint_y = nil, nil
                self.move_dir = "none"
                self.count = 1
                if self.state == "Going to campfire" then
                    self.state = "Waiting"
                    if self.orientation == "west" then
                        self.animation = anim.newAnimation(an[AN_IDLE_WEST], 0.11, 'pauseAtEnd', AN_IDLE_WEST)
                    elseif self.orientation == "southwest" then
                        self.animation = anim.newAnimation(an[AN_IDLE_SOUTHWEST], 0.11, 'pauseAtEnd', AN_IDLE_SOUTHWEST)
                    elseif self.orientation == "northwest" then
                        self.animation = anim.newAnimation(an[AN_IDLE_NORTHWEST], 0.11, 'pauseAtEnd', AN_IDLE_NORTHWEST)
                    elseif self.orientation == "north" then
                        self.animation = anim.newAnimation(an[AN_IDLE_NORTH], 0.11, 'pauseAtEnd', AN_IDLE_NORTH)
                    elseif self.orientation == "south" then
                        self.animation = anim.newAnimation(an[AN_IDLE_SOUTH], 0.11, 'pauseAtEnd', AN_IDLE_SOUTH)
                    elseif self.orientation == "east" then
                        self.animation = anim.newAnimation(an[AN_IDLE_EAST], 0.11, 'pauseAtEnd', AN_IDLE_EAST)
                    elseif self.orientation == "southeast" then
                        self.animation = anim.newAnimation(an[AN_IDLE_SOUTHEAST], 0.11, 'pauseAtEnd', AN_IDLE_SOUTHEAST)
                    elseif self.orientation == "northeast" then
                        self.animation = anim.newAnimation(an[AN_IDLE_NORTHEAST], 0.11, 'pauseAtEnd', AN_IDLE_NORTHEAST)
                    end
                elseif self.state == "Going to door" then
                    self.state = "Getting a job"
                    self.animation = anim.newAnimation(an[AN_BOWING_FOR_A_JOB], 0.12, function()
                        self:bowing_job_callback()
                    end, AN_BOWING_FOR_A_JOB)
                end
                return
            else
                self:set_next_waypoint()
            end
            self.count = self.count + 1
        end
    end
end
function Peasant:bowing_job_callback()
    self.to_be_deleted = true
    _G.freeVertexFromTile(self.cx, self.cy, self.previous_vert_id)
    self.animation = nil
    _G.freeVertexFromTile(self.cx, self.cy, self.vert_id)
    _G.removeObjectAt(self.cx, self.cy, self.i, self.o, self)
    _G.JobController:add_available_worker()
end
function Peasant:animate()
    self:update()
    Unit.animate(self)
end
function Peasant:serialize()
    local data = {}
    local unit_data = Unit.serialize(self)
    for k, v in pairs(unit_data) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.workplace = self.workplace
    data.state = self.state
    data.marked = self.marked
    data.count = self.count
    data.offset_y = self.offset_y
    data.offset_x = self.offset_x
    data.eat_timer = self.eat_timer
    data.orientation = self.orientation
    data.timr = self.timr
    data.animated = self.animated
    if self.animation then
        data.animation = self.animation:serialize()
    end
    data.try_to_get_a_job = self.try_to_get_a_job
    return data
end

return Peasant
