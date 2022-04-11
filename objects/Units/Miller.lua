local _, _ = ...
local Unit = require("objects.Units.Unit")
local Object = require("objects.Object")
local anim = require("libraries.anim8")

local fr_walking_east = _G.indexQuads("body_miller_run_e", 16)
local fr_walking_north = _G.indexQuads("body_miller_run_n", 16)
local fr_walking_northeast = _G.indexQuads("body_miller_run_ne", 16)
local fr_walking_northwest = _G.indexQuads("body_miller_run_nw", 16)
local fr_walking_south = _G.indexQuads("body_miller_run_s", 16)
local fr_walking_southeast = _G.indexQuads("body_miller_run_se", 16)
local fr_walking_southwest = _G.indexQuads("body_miller_run_sw", 16)
local fr_walking_west = _G.indexQuads("body_miller_run_w", 16)
-- wheat
local fr_walking_wheat_east = _G.indexQuads("body_miller_walk_wheat_e", 16)
local fr_walking_wheat_north = _G.indexQuads("body_miller_walk_wheat_n", 16)
local fr_walking_wheat_northeast = _G.indexQuads("body_miller_walk_wheat_ne", 16)
local fr_walking_wheat_northwest = _G.indexQuads("body_miller_walk_wheat_nw", 16)
local fr_walking_wheat_south = _G.indexQuads("body_miller_walk_wheat_s", 16)
local fr_walking_wheat_southeast = _G.indexQuads("body_miller_walk_wheat_se", 16)
local fr_walking_wheat_southwest = _G.indexQuads("body_miller_walk_wheat_sw", 16)
local fr_walking_wheat_west = _G.indexQuads("body_miller_walk_wheat_w", 16)
-- flower
local fr_walking_flour_east = _G.indexQuads("body_miller_walk_flour_e", 16)
local fr_walking_flour_north = _G.indexQuads("body_miller_walk_flour_n", 16)
local fr_walking_flour_northeast = _G.indexQuads("body_miller_walk_flour_ne", 16)
local fr_walking_flour_northwest = _G.indexQuads("body_miller_walk_flour_nw", 16)
local fr_walking_flour_south = _G.indexQuads("body_miller_walk_flour_s", 16)
local fr_walking_flour_southeast = _G.indexQuads("body_miller_walk_flour_se", 16)
local fr_walking_flour_southwest = _G.indexQuads("body_miller_walk_flour_sw", 16)
local fr_walking_flour_west = _G.indexQuads("body_miller_walk_flour_w", 16)

local ANIM_WALKING_EAST = "Walking_East"
local ANIM_WALKING_NORTH = "Walking_North"
local ANIM_WALKING_NORTHEAST = "Walking_Northeast"
local ANIM_WALKING_NORTHWEST = "Walking_Northwest"
local ANIM_WALKING_SOUTH = "Walking_South"
local ANIM_WALKING_SOUTHEAST = "Walking_Southeast"
local ANIM_WALKING_SOUTHWEST = "Walking_Southwest"
local ANIM_WALKING_WEST = "Walking_West"
-- wheat
local ANIM_WALKING_WHEAT_EAST = "Walking_Wheat_East"
local ANIM_WALKING_WHEAT_NORTH = "Walking_Wheat_North"
local ANIM_WALKING_WHEAT_NORTHEAST = "Walking_Wheat_Northeast"
local ANIM_WALKING_WHEAT_NORTHWEST = "Walking_Wheat_Northwest"
local ANIM_WALKING_WHEAT_SOUTH = "Walking_Wheat_South"
local ANIM_WALKING_WHEAT_SOUTHEAST = "Walking_Wheat_Southeast"
local ANIM_WALKING_WHEAT_SOUTHWEST = "Walking_Wheat_Southwest"
local ANIM_WALKING_WHEAT_WEST = "Walking_Wheat_West"
-- flower
local ANIM_WALKING_FLOUR_EAST = "Walking_Flour_East"
local ANIM_WALKING_FLOUR_NORTH = "Walking_Flour_North"
local ANIM_WALKING_FLOUR_NORTHEAST = "Walking_Flour_Northeast"
local ANIM_WALKING_FLOUR_NORTHWEST = "Walking_Flour_Northwest"
local ANIM_WALKING_FLOUR_SOUTH = "Walking_Flour_South"
local ANIM_WALKING_FLOUR_SOUTHEAST = "Walking_Flour_Southeast"
local ANIM_WALKING_FLOUR_SOUTHWEST = "Walking_Flour_Southwest"
local ANIM_WALKING_FLOUR_WEST = "Walking_Flour_West"

local an = {
    [ANIM_WALKING_EAST] = fr_walking_east,
    [ANIM_WALKING_NORTH] = fr_walking_north,
    [ANIM_WALKING_NORTHEAST] = fr_walking_northeast,
    [ANIM_WALKING_NORTHWEST] = fr_walking_northwest,
    [ANIM_WALKING_SOUTH] = fr_walking_south,
    [ANIM_WALKING_SOUTHEAST] = fr_walking_southeast,
    [ANIM_WALKING_SOUTHWEST] = fr_walking_southwest,
    [ANIM_WALKING_WEST] = fr_walking_west,
    [ANIM_WALKING_WHEAT_EAST] = fr_walking_wheat_east,
    [ANIM_WALKING_WHEAT_NORTH] = fr_walking_wheat_north,
    [ANIM_WALKING_WHEAT_NORTHEAST] = fr_walking_wheat_northeast,
    [ANIM_WALKING_WHEAT_NORTHWEST] = fr_walking_wheat_northwest,
    [ANIM_WALKING_WHEAT_SOUTH] = fr_walking_wheat_south,
    [ANIM_WALKING_WHEAT_SOUTHEAST] = fr_walking_wheat_southeast,
    [ANIM_WALKING_WHEAT_SOUTHWEST] = fr_walking_wheat_southwest,
    [ANIM_WALKING_WHEAT_WEST] = fr_walking_wheat_west,
    [ANIM_WALKING_FLOUR_EAST] = fr_walking_flour_east,
    [ANIM_WALKING_FLOUR_NORTH] = fr_walking_flour_north,
    [ANIM_WALKING_FLOUR_NORTHEAST] = fr_walking_flour_northeast,
    [ANIM_WALKING_FLOUR_NORTHWEST] = fr_walking_flour_northwest,
    [ANIM_WALKING_FLOUR_SOUTH] = fr_walking_flour_south,
    [ANIM_WALKING_FLOUR_SOUTHEAST] = fr_walking_flour_southeast,
    [ANIM_WALKING_FLOUR_SOUTHWEST] = fr_walking_flour_southwest,
    [ANIM_WALKING_FLOUR_WEST] = fr_walking_flour_west
}

local Miller = _G.class('Miller', Unit)

function Miller:initialize(gx, gy, type)
    Unit.initialize(self, gx, gy, type)
    self.state = 'Find a job'
    self.eat_timer = 0
    self.wait_timer = 0
    self.offset_y = -10
    self.offset_x = -5
    self.count = 1
    self.animation = anim.newAnimation(an[ANIM_WALKING_WEST], 10, nil, ANIM_WALKING_WEST)
end
function Miller:load(data)
    Object.deserialize(self, data)
    Unit.load(self, data)
    local an_data = data.animation
    if an_data then
        self.animation = anim.newAnimation(an[an_data.animation_identifier], 1, nil, an_data.animation_identifier)
        self.animation:deserialize(an_data)
    end
end
function Miller:serialize()
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

function Miller:dir_sub_update()
    if self.move_dir == "west" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_FLOUR_WEST], 0.05, nil, ANIM_WALKING_FLOUR_WEST)
        elseif self.state == "Going to workplace with wheat" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_WHEAT_WEST], 0.05, nil, ANIM_WALKING_WHEAT_WEST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_WEST], 0.05, nil, ANIM_WALKING_WEST)
        end
    elseif self.move_dir == "southwest" then
        if self.state == "Going to stockpile" then
            self.animation =
                anim.newAnimation(an[ANIM_WALKING_FLOUR_SOUTHWEST], 0.05, nil, ANIM_WALKING_FLOUR_SOUTHWEST)
        elseif self.state == "Going to workplace with wheat" then
            self.animation =
                anim.newAnimation(an[ANIM_WALKING_WHEAT_SOUTHWEST], 0.05, nil, ANIM_WALKING_WHEAT_SOUTHWEST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_SOUTHWEST], 0.05, nil, ANIM_WALKING_SOUTHWEST)
        end
    elseif self.move_dir == "northwest" then
        if self.state == "Going to stockpile" then
            self.animation =
                anim.newAnimation(an[ANIM_WALKING_FLOUR_NORTHWEST], 0.05, nil, ANIM_WALKING_FLOUR_NORTHWEST)
        elseif self.state == "Going to workplace with wheat" then
            self.animation =
                anim.newAnimation(an[ANIM_WALKING_WHEAT_NORTHWEST], 0.05, nil, ANIM_WALKING_WHEAT_NORTHWEST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_NORTHWEST], 0.05, nil, ANIM_WALKING_NORTHWEST)
        end
    elseif self.move_dir == "north" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_FLOUR_NORTH], 0.05, nil, ANIM_WALKING_FLOUR_NORTH)
        elseif self.state == "Going to workplace with wheat" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_WHEAT_NORTH], 0.05, nil, ANIM_WALKING_WHEAT_NORTH)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_NORTH], 0.05, nil, ANIM_WALKING_NORTH)
        end
    elseif self.move_dir == "south" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_FLOUR_SOUTH], 0.05, nil, ANIM_WALKING_FLOUR_SOUTH)
        elseif self.state == "Going to workplace with wheat" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_WHEAT_SOUTH], 0.05, nil, ANIM_WALKING_WHEAT_SOUTH)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_SOUTH], 0.05, nil, ANIM_WALKING_SOUTH)
        end
    elseif self.move_dir == "east" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_FLOUR_EAST], 0.05, nil, ANIM_WALKING_FLOUR_EAST)
        elseif self.state == "Going to workplace with wheat" then
            self.animation = anim.newAnimation(an[ANIM_WALKING_WHEAT_EAST], 0.05, nil, ANIM_WALKING_WHEAT_EAST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_EAST], 0.05, nil, ANIM_WALKING_EAST)
        end
    elseif self.move_dir == "southeast" then
        if self.state == "Going to stockpile" then
            self.animation =
                anim.newAnimation(an[ANIM_WALKING_FLOUR_SOUTHEAST], 0.05, nil, ANIM_WALKING_FLOUR_SOUTHEAST)
        elseif self.state == "Going to workplace with wheat" then
            self.animation =
                anim.newAnimation(an[ANIM_WALKING_WHEAT_SOUTHEAST], 0.05, nil, ANIM_WALKING_WHEAT_SOUTHEAST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_SOUTHEAST], 0.05, nil, ANIM_WALKING_SOUTHEAST)
        end
    elseif self.move_dir == "northeast" then
        if self.state == "Going to stockpile" then
            self.animation =
                anim.newAnimation(an[ANIM_WALKING_FLOUR_NORTHEAST], 0.05, nil, ANIM_WALKING_FLOUR_NORTHEAST)
        elseif self.state == "Going to workplace with wheat" then
            self.animation =
                anim.newAnimation(an[ANIM_WALKING_WHEAT_NORTHEAST], 0.05, nil, ANIM_WALKING_WHEAT_NORTHEAST)
        else
            self.animation = anim.newAnimation(an[ANIM_WALKING_NORTHEAST], 0.05, nil, ANIM_WALKING_NORTHEAST)
        end
    end
end

function Miller:update()
    self.eat_timer = self.eat_timer + 1
    if self.eat_timer > 3000 then
        self.eat_timer = 0
        _G.foodpile:take()
    end
    self.wait_timer = self.wait_timer + _G.dt
    if self.wait_timer > 1 then
        self.wait_timer = 0
        if self.state == "Waiting for wheat" then
            self.wait_timer = 0
            local got_resource = _G.stockpile:take('wheat')
            if not got_resource then
                self.state = "Waiting for wheat"
                return
            else
                self.state = "Go to workplace with wheat"
                self:clear_path()
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
                    self:set_next_waypoint()

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
                        self:clear_path()
                        return
                    end
                else
                    self:set_next_waypoint()

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
