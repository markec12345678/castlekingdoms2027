local _, _ = ...
local Unit = require("objects.Units.Unit")
local Object = require("objects.Object")
local anim = _G.anim
local indexQuads = _G.indexQuads

local cutting_fx = {_G.fx["chop1 22k"], _G.fx["chop2 22k"], _G.fx["chop3 22k"], _G.fx["chop4 22k"]}
local chopping_fx = {_G.fx["wood_chop_1"], _G.fx["wood_chop_2"], _G.fx["wood_chop_3"]}
local footstep_fx = {_G.fx["footstep_grass_1"], _G.fx["footstep_grass_2"], _G.fx["footstep_grass_3"],
                     _G.fx["footstep_grass_4"], _G.fx["footstep_grass_5"]}

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

local AN_CUTTING_NORTHEAST = "Cutting northeast"
local AN_WALKING_WEST = "Walking west"
local AN_WALKING_SOUTHWEST = "Walking southwest"
local AN_WALKING_NORTHWEST = "Walking northwest"
local AN_WALKING_NORTH = "Walking north"
local AN_WALKING_SOUTH = "Walking south"
local AN_WALKING_EAST = "Walking east"
local AN_WALKING_SOUTHEAST = "Walking southeast"
local AN_WALKING_NORTHEAST = "Walking northeast"
local AN_WALKING_PLANK_WEST = "Walking with plank west"
local AN_WALKING_PLANK_SOUTHWEST = "Walking with plank southwest"
local AN_WALKING_PLANK_NORTHWEST = "Walking with plank northwest"
local AN_WALKING_PLANK_NORTH = "Walking with plank north"
local AN_WALKING_PLANK_SOUTH = "Walking with plank south"
local AN_WALKING_PLANK_EAST = "Walking with plank east"
local AN_WALKING_PLANK_SOUTHEAST = "Walking with plank southeast"
local AN_WALKING_PLANK_NORTHEAST = "Walking with plank northeast"
local AN_WALKING_LOG_WEST = "Walking with log west"
local AN_WALKING_LOG_SOUTHWEST = "Walking with log southwest"
local AN_WALKING_LOG_NORTHWEST = "Walking with log northwest"
local AN_WALKING_LOG_NORTH = "Walking with log north"
local AN_WALKING_LOG_SOUTH = "Walking with log south"
local AN_WALKING_LOG_EAST = "Walking with log east"
local AN_WALKING_LOG_SOUTHEAST = "Walking with log southeast"
local AN_WALKING_LOG_NORTHEAST = "Walking with log northeast"

local an = {
    [AN_CUTTING_NORTHEAST] = fr_cutting_northeast,
    [AN_WALKING_WEST] = fr_walking_west,
    [AN_WALKING_SOUTHWEST] = fr_walking_southwest,
    [AN_WALKING_NORTHWEST] = fr_walking_northwest,
    [AN_WALKING_NORTH] = fr_walking_north,
    [AN_WALKING_SOUTH] = fr_walking_south,
    [AN_WALKING_EAST] = fr_walking_east,
    [AN_WALKING_SOUTHEAST] = fr_walking_southeast,
    [AN_WALKING_NORTHEAST] = fr_walking_northeast,
    [AN_WALKING_PLANK_WEST] = fr_walking_plank_west,
    [AN_WALKING_PLANK_SOUTHWEST] = fr_walking_plank_southwest,
    [AN_WALKING_PLANK_NORTHWEST] = fr_walking_plank_northwest,
    [AN_WALKING_PLANK_NORTH] = fr_walking_plank_north,
    [AN_WALKING_PLANK_SOUTH] = fr_walking_plank_south,
    [AN_WALKING_PLANK_EAST] = fr_walking_plank_east,
    [AN_WALKING_PLANK_SOUTHEAST] = fr_walking_plank_southeast,
    [AN_WALKING_PLANK_NORTHEAST] = fr_walking_plank_northeast,
    [AN_WALKING_LOG_WEST] = fr_walking_log_west,
    [AN_WALKING_LOG_SOUTHWEST] = fr_walking_log_southwest,
    [AN_WALKING_LOG_NORTHWEST] = fr_walking_log_northwest,
    [AN_WALKING_LOG_NORTH] = fr_walking_log_north,
    [AN_WALKING_LOG_SOUTH] = fr_walking_log_south,
    [AN_WALKING_LOG_EAST] = fr_walking_log_east,
    [AN_WALKING_LOG_SOUTHEAST] = fr_walking_log_southeast,
    [AN_WALKING_LOG_NORTHEAST] = fr_walking_log_northeast
}

local Woodcutter = _G.class('Woodcutter', Unit)
function Woodcutter:initialize(gx, gy, type)
    Unit.initialize(self, gx, gy, type)
    local an_spd = 0.05
    self.workplace = nil
    self.an_walking_plank_west = anim.newAnimation(an[AN_WALKING_PLANK_WEST], an_spd, nil, AN_WALKING_PLANK_WEST)
    self.an_walking_log_west = anim.newAnimation(an[AN_WALKING_LOG_WEST], an_spd, nil, AN_WALKING_LOG_WEST)
    self.an_walking_west = anim.newAnimation(an[AN_WALKING_WEST], an_spd, nil, AN_WALKING_WEST)
    self.an_walking_plank_southwest = anim.newAnimation(an[AN_WALKING_PLANK_SOUTHWEST], an_spd, nil,
        AN_WALKING_PLANK_SOUTHWEST)
    self.an_walking_log_southwest = anim.newAnimation(an[AN_WALKING_LOG_SOUTHWEST], an_spd, nil,
        AN_WALKING_LOG_SOUTHWEST)
    self.an_walking_southwest = anim.newAnimation(an[AN_WALKING_SOUTHWEST], an_spd, nil, AN_WALKING_SOUTHWEST)
    self.an_walking_plank_northwest = anim.newAnimation(an[AN_WALKING_PLANK_NORTHWEST], an_spd, nil,
        AN_WALKING_PLANK_NORTHWEST)
    self.an_walking_log_northwest = anim.newAnimation(an[AN_WALKING_LOG_NORTHWEST], an_spd, nil,
        AN_WALKING_LOG_NORTHWEST)
    self.an_walking_northwest = anim.newAnimation(an[AN_WALKING_NORTHWEST], an_spd, nil, AN_WALKING_NORTHWEST)
    self.an_walking_plank_north = anim.newAnimation(an[AN_WALKING_PLANK_NORTH], an_spd, nil, AN_WALKING_PLANK_NORTH)
    self.an_walking_log_north = anim.newAnimation(an[AN_WALKING_LOG_NORTH], an_spd, nil, AN_WALKING_LOG_NORTH)
    self.an_walking_north = anim.newAnimation(an[AN_WALKING_NORTH], an_spd, nil, AN_WALKING_NORTH)
    self.an_walking_plank_south = anim.newAnimation(an[AN_WALKING_PLANK_SOUTH], an_spd, nil, AN_WALKING_PLANK_SOUTH)
    self.an_walking_log_south = anim.newAnimation(an[AN_WALKING_LOG_SOUTH], an_spd, nil, AN_WALKING_LOG_SOUTH)
    self.an_walking_south = anim.newAnimation(an[AN_WALKING_SOUTH], an_spd, nil, AN_WALKING_SOUTH)
    self.an_walking_plank_east = anim.newAnimation(an[AN_WALKING_PLANK_EAST], an_spd, nil, AN_WALKING_PLANK_EAST)
    self.an_walking_log_east = anim.newAnimation(an[AN_WALKING_LOG_EAST], an_spd, nil, AN_WALKING_LOG_EAST)
    self.an_walking_east = anim.newAnimation(an[AN_WALKING_EAST], an_spd, nil, AN_WALKING_EAST)
    self.an_walking_plank_southeast = anim.newAnimation(an[AN_WALKING_PLANK_SOUTHEAST], an_spd, nil,
        AN_WALKING_PLANK_SOUTHEAST)
    self.an_walking_log_southeast = anim.newAnimation(an[AN_WALKING_LOG_SOUTHEAST], an_spd, nil,
        AN_WALKING_LOG_SOUTHEAST)
    self.an_walking_southeast = anim.newAnimation(an[AN_WALKING_SOUTHEAST], an_spd, nil, AN_WALKING_SOUTHEAST)
    self.an_walking_plank_northeast = anim.newAnimation(an[AN_WALKING_PLANK_NORTHEAST], an_spd, nil,
        AN_WALKING_PLANK_NORTHEAST)
    self.an_walking_log_northeast = anim.newAnimation(an[AN_WALKING_LOG_NORTHEAST], an_spd, nil,
        AN_WALKING_LOG_NORTHEAST)
    self.an_walking_northeast = anim.newAnimation(an[AN_WALKING_NORTHEAST], an_spd, nil, AN_WALKING_NORTHEAST)
    self.state = 'Find a job'
    -- self.marked = 0
    self.count = 1
    self.eat_timer = 0
    self.offset_x = -5
    self.offset_y = -10
    self.store_timer = 0
    self.target_tree = nil
    self.animation = self.an_walking_west
    self.cut = function()
        self:cut_callback()
    end
end
function Woodcutter:load(data)
    Object.deserialize(self, data)
    Unit.load(self, data)
    self.cut = function()
        self:cut_callback()
    end
    local an_data = data.animation
    if an_data then
        local callback
        if an_data.animation_identifier == AN_CUTTING_NORTHEAST then
            callback = self.cut
        end
        self.animation = anim.newAnimation(an[an_data.animation_identifier], 1, callback, an_data.animation_identifier)
        self.animation:deserialize(an_data)
    end
    self.an_walking_plank_west = anim.newAnimation(an[data.an_walking_plank_west.animation_identifier], 1, nil,
        data.an_walking_plank_west.animation_identifier)
    self.an_walking_plank_west:deserialize(data.an_walking_plank_west)
    self.an_walking_log_west = anim.newAnimation(an[data.an_walking_log_west.animation_identifier], 1, nil,
        data.an_walking_log_west.animation_identifier)
    self.an_walking_log_west:deserialize(data.an_walking_log_west)
    self.an_walking_west = anim.newAnimation(an[data.an_walking_west.animation_identifier], 1, nil,
        data.an_walking_west.animation_identifier)
    self.an_walking_west:deserialize(data.an_walking_west)
    self.an_walking_plank_southwest = anim.newAnimation(an[data.an_walking_plank_southwest.animation_identifier], 1,
        nil, data.an_walking_plank_southwest.animation_identifier)
    self.an_walking_plank_southwest:deserialize(data.an_walking_plank_southwest)
    self.an_walking_log_southwest = anim.newAnimation(an[data.an_walking_log_southwest.animation_identifier], 1, nil,
        data.an_walking_log_southwest.animation_identifier)
    self.an_walking_log_southwest:deserialize(data.an_walking_log_southwest)
    self.an_walking_southwest = anim.newAnimation(an[data.an_walking_southwest.animation_identifier], 1, nil,
        data.an_walking_southwest.animation_identifier)
    self.an_walking_southwest:deserialize(data.an_walking_southwest)
    self.an_walking_plank_northwest = anim.newAnimation(an[data.an_walking_plank_northwest.animation_identifier], 1,
        nil, data.an_walking_plank_northwest.animation_identifier)
    self.an_walking_plank_northwest:deserialize(data.an_walking_plank_northwest)
    self.an_walking_log_northwest = anim.newAnimation(an[data.an_walking_log_northwest.animation_identifier], 1, nil,
        data.an_walking_log_northwest.animation_identifier)
    self.an_walking_log_northwest:deserialize(data.an_walking_log_northwest)
    self.an_walking_northwest = anim.newAnimation(an[data.an_walking_northwest.animation_identifier], 1, nil,
        data.an_walking_northwest.animation_identifier)
    self.an_walking_northwest:deserialize(data.an_walking_northwest)
    self.an_walking_plank_north = anim.newAnimation(an[data.an_walking_plank_north.animation_identifier], 1, nil,
        data.an_walking_plank_north.animation_identifier)
    self.an_walking_plank_north:deserialize(data.an_walking_plank_north)
    self.an_walking_log_north = anim.newAnimation(an[data.an_walking_log_north.animation_identifier], 1, nil,
        data.an_walking_log_north.animation_identifier)
    self.an_walking_log_north:deserialize(data.an_walking_log_north)
    self.an_walking_north = anim.newAnimation(an[data.an_walking_north.animation_identifier], 1, nil,
        data.an_walking_north.animation_identifier)
    self.an_walking_north:deserialize(data.an_walking_north)
    self.an_walking_plank_south = anim.newAnimation(an[data.an_walking_plank_south.animation_identifier], 1, nil,
        data.an_walking_plank_south.animation_identifier)
    self.an_walking_plank_south:deserialize(data.an_walking_plank_south)
    self.an_walking_log_south = anim.newAnimation(an[data.an_walking_log_south.animation_identifier], 1, nil,
        data.an_walking_log_south.animation_identifier)
    self.an_walking_log_south:deserialize(data.an_walking_log_south)
    self.an_walking_south = anim.newAnimation(an[data.an_walking_south.animation_identifier], 1, nil,
        data.an_walking_south.animation_identifier)
    self.an_walking_south:deserialize(data.an_walking_south)
    self.an_walking_plank_east = anim.newAnimation(an[data.an_walking_plank_east.animation_identifier], 1, nil,
        data.an_walking_plank_east.animation_identifier)
    self.an_walking_plank_east:deserialize(data.an_walking_plank_east)
    self.an_walking_log_east = anim.newAnimation(an[data.an_walking_log_east.animation_identifier], 1, nil,
        data.an_walking_log_east.animation_identifier)
    self.an_walking_log_east:deserialize(data.an_walking_log_east)
    self.an_walking_east = anim.newAnimation(an[data.an_walking_east.animation_identifier], 1, nil,
        data.an_walking_east.animation_identifier)
    self.an_walking_east:deserialize(data.an_walking_east)
    self.an_walking_plank_southeast = anim.newAnimation(an[data.an_walking_plank_southeast.animation_identifier], 1,
        nil, data.an_walking_plank_southeast.animation_identifier)
    self.an_walking_plank_southeast:deserialize(data.an_walking_plank_southeast)
    self.an_walking_log_southeast = anim.newAnimation(an[data.an_walking_log_southeast.animation_identifier], 1, nil,
        data.an_walking_log_southeast.animation_identifier)
    self.an_walking_log_southeast:deserialize(data.an_walking_log_southeast)
    self.an_walking_southeast = anim.newAnimation(an[data.an_walking_southeast.animation_identifier], 1, nil,
        data.an_walking_southeast.animation_identifier)
    self.an_walking_southeast:deserialize(data.an_walking_southeast)
    self.an_walking_plank_northeast = anim.newAnimation(an[data.an_walking_plank_northeast.animation_identifier], 1,
        nil, data.an_walking_plank_northeast.animation_identifier)
    self.an_walking_plank_northeast:deserialize(data.an_walking_plank_northeast)
    self.an_walking_log_northeast = anim.newAnimation(an[data.an_walking_log_northeast.animation_identifier], 1, nil,
        data.an_walking_log_northeast.animation_identifier)
    self.an_walking_log_northeast:deserialize(data.an_walking_log_northeast)
    self.an_walking_northeast = anim.newAnimation(an[data.an_walking_northeast.animation_identifier], 1, nil,
        data.an_walking_northeast.animation_identifier)
    self.an_walking_northeast:deserialize(data.an_walking_northeast)
    if data.target_tree then
        self.target_tree = _G.state:dereferenceObject(data.target_tree)
    end
end
function Woodcutter:serialize()
    local data = {}
    local unit_data = Unit.serialize(self)
    for k, v in pairs(unit_data) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    -- self.marked = 0
    data.an_walking_plank_west = self.an_walking_plank_west:serialize()
    data.an_walking_log_west = self.an_walking_log_west:serialize()
    data.an_walking_west = self.an_walking_west:serialize()
    data.an_walking_plank_southwest = self.an_walking_plank_southwest:serialize()
    data.an_walking_log_southwest = self.an_walking_log_southwest:serialize()
    data.an_walking_southwest = self.an_walking_southwest:serialize()
    data.an_walking_plank_northwest = self.an_walking_plank_northwest:serialize()
    data.an_walking_log_northwest = self.an_walking_log_northwest:serialize()
    data.an_walking_northwest = self.an_walking_northwest:serialize()
    data.an_walking_plank_north = self.an_walking_plank_north:serialize()
    data.an_walking_log_north = self.an_walking_log_north:serialize()
    data.an_walking_north = self.an_walking_north:serialize()
    data.an_walking_plank_south = self.an_walking_plank_south:serialize()
    data.an_walking_log_south = self.an_walking_log_south:serialize()
    data.an_walking_south = self.an_walking_south:serialize()
    data.an_walking_plank_east = self.an_walking_plank_east:serialize()
    data.an_walking_log_east = self.an_walking_log_east:serialize()
    data.an_walking_east = self.an_walking_east:serialize()
    data.an_walking_plank_southeast = self.an_walking_plank_southeast:serialize()
    data.an_walking_log_southeast = self.an_walking_log_southeast:serialize()
    data.an_walking_southeast = self.an_walking_southeast:serialize()
    data.an_walking_plank_northeast = self.an_walking_plank_northeast:serialize()
    data.an_walking_log_northeast = self.an_walking_log_northeast:serialize()
    data.an_walking_northeast = self.an_walking_northeast:serialize()
    if self.animation then
        data.animation = self.animation:serialize()
    end
    data.state = self.state
    data.count = self.count
    data.eat_timer = self.eat_timer
    data.offset_x = self.offset_x
    data.offset_y = self.offset_y
    data.store_timer = self.store_timer
    if self.target_tree then
        data.target_tree = _G.state:serializeObject(self.target_tree)
    end
    return data
end
function Woodcutter:cut_callback()
    if self.state == "Cutting down" then
        local tree_progress
        if self.target_tree.tree and self.target_tree.cuttable then
            tree_progress = self.target_tree:cut()
            if self.target_tree.chop or self.target_tree.falling then
                _G.play_sfx(self, chopping_fx)
            else
                _G.play_sfx(self, cutting_fx)
            end
        else
            self.state = "Looking to chop tree"
            self.move_dir = "none"
        end
        if tree_progress == 2 then
            self.animation:pause()
            self.move_dir = "none"
            self.count = 1
            self.state = "Going to workplace with wood"
            self:requestPath(self.workplace.gx + 1, self.workplace.gy + 3)
        end
    end
end
function Woodcutter:job_update()
    _G.removeObjectAt(self.lrcx, self.lrcy, self.lrx, self.lry, self)
    _G.freeVertexFromTile(self.cx, self.cy, self.vert_id)
    self.instancemesh = nil
    self.animation = nil
end
function Woodcutter:check_trees(cx, cy)
    local chunkx, chunky = cx or self.cx, cy or self.cy
    local closest_object, closest_distance = nil, 10000000
    if _G.state.chunk_objects[chunkx][chunky] then
        for _, obj in pairs(_G.state.chunk_objects[chunkx][chunky]) do
            if (obj.type == 'Pine tree' or obj.type == "Small pine tree" or obj.type == "Medium pine tree" or obj.type ==
                'Oak tree' or obj.type == "Small oak tree" or obj.type == "Medium oak tree") and obj.marked == false then
                -- TODO: Fix magic numbers CRITICAL
                if obj.gx > 0 and obj.gx < 2047 and obj.gy > 0 and obj.gy < 2047 then -- and _G.nodes[obj.gx][obj.gy+1].walkable == 0 then --fixme
                    local dist = _G.manhattan_distance(self.gx, self.gy, obj.gx, obj.gy)
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

    if objt and not _G.importantObjectAtGlobal(objt.gx, objt.gy + 1) then
        if disto and disto < closest_distance then
            closest_object = objt
        end
    end
    if not closest_object then
        print("No trees nearby!")
        self.state = "No trees"
        -- TODO: Mark woodcutters hut as inactive
        return
    end
    self.target_tree = closest_object
    self.endx = closest_object.gx
    self.endy = closest_object.gy + 1
    if self.endx == self.gx and self.endy == self.gy then
        self.state = "Cutting down"
        self.animation = anim.newAnimation(an[AN_CUTTING_NORTHEAST], 0.08, self.cut, AN_CUTTING_NORTHEAST)
        self:clear_path()
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
            for _, v in ipairs(_G.stockpile.node_list) do
                local tmp = _G.manhattan_distance(v.gx, v.gy, self.gx, self.gy)
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
            self.fx, self.fy = self.gx * 1000 + 500, self.gy * 1000 + 500
            self:requestPath(self.workplace.gx + 1, self.workplace.gy + 3)
            self.state = "Going to workplace"
            self.move_dir = "none"
        elseif self.state == "Going to tree" or self.state == "Going to stockpile" or self.state == "Going to workplace" or
            self.state == "Going to workplace with wood" or self.state == "Going to waypoint" then
            if self.move_dir == "none" then
                self:update_direction()
                self:dir_sub_update()
            end
            self:move()
        end
        if self.fx * 0.001 == self.waypoint_x and self.fy * 0.001 == self.waypoint_y and self.move_dir ~= "none" then
            if self.state == "Going to tree" then
                if self:reached_path_end() then
                    self.state = "Cutting down"
                    self.animation = anim.newAnimation(an[AN_CUTTING_NORTHEAST], 0.08, self.cut, AN_CUTTING_NORTHEAST)
                    self:clear_path()
                    return
                else
                    self:set_next_waypoint()
                end
                self.count = self.count + 1
            elseif self.state == "Going to workplace with wood" then
                if self:reached_path_end() then
                    self.workplace:work(self)
                    self:clear_path()
                    return
                else
                    self:set_next_waypoint()
                end
                self.count = self.count + 1
            elseif self.state == "Going to stockpile" then
                if self:reached_path_end() then
                    _G.stockpile:store('wood')
                    self.state = "Storing second plank"
                    self.animation:pause()
                    self.store_timer = 0
                    self:clear_path()
                    return
                else
                    self:set_next_waypoint()
                end
                self.count = self.count + 1
            elseif self.state == "Going to workplace" then
                if self:reached_path_end() then
                    self.state = "Looking to chop tree"
                    self:clear_path()
                    return
                else
                    self:set_next_waypoint()
                end
                self.count = self.count + 1
            elseif self.state == "Going to waypoint" then
                if self:reached_path_end() then
                    self.state = "none"
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
function Woodcutter:animate()
    if self.move_dir ~= "none" and self.animation and (self.animation.position == 2 or self.animation.position == 10) then
        _G.play_sfx(self, footstep_fx)
    end
    self:update()
    Unit.animate(self)
end
return Woodcutter
