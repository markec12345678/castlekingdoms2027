local _, _ = ...
local Unit = require("objects.Units.Unit")
local Object = require("objects.Object")
local anim = _G.anim
local indexQuads = _G.indexQuads

local cuttingFx = {_G.fx["chop1 22k"], _G.fx["chop2 22k"], _G.fx["chop3 22k"], _G.fx["chop4 22k"]}
local choppingFx = {_G.fx["wood_chop_1"], _G.fx["wood_chop_2"], _G.fx["wood_chop_3"]}
local footstepFx = {_G.fx["footstep_grass_1"], _G.fx["footstep_grass_2"], _G.fx["footstep_grass_3"],
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
    local anSpd = 0.05
    self.workplace = nil
    self.anWalkingPlankWest = anim.newAnimation(an[AN_WALKING_PLANK_WEST], anSpd, nil, AN_WALKING_PLANK_WEST)
    self.anWalkingLogWest = anim.newAnimation(an[AN_WALKING_LOG_WEST], anSpd, nil, AN_WALKING_LOG_WEST)
    self.anWalkingWest = anim.newAnimation(an[AN_WALKING_WEST], anSpd, nil, AN_WALKING_WEST)
    self.anWalkingPlankSouthwest = anim.newAnimation(an[AN_WALKING_PLANK_SOUTHWEST], anSpd, nil,
        AN_WALKING_PLANK_SOUTHWEST)
    self.anWalkingLogSouthwest = anim.newAnimation(an[AN_WALKING_LOG_SOUTHWEST], anSpd, nil, AN_WALKING_LOG_SOUTHWEST)
    self.anWalkingSouthwest = anim.newAnimation(an[AN_WALKING_SOUTHWEST], anSpd, nil, AN_WALKING_SOUTHWEST)
    self.anWalkingPlankNorthwest = anim.newAnimation(an[AN_WALKING_PLANK_NORTHWEST], anSpd, nil,
        AN_WALKING_PLANK_NORTHWEST)
    self.anWalkingLogNorthwest = anim.newAnimation(an[AN_WALKING_LOG_NORTHWEST], anSpd, nil, AN_WALKING_LOG_NORTHWEST)
    self.anWalkingNorthwest = anim.newAnimation(an[AN_WALKING_NORTHWEST], anSpd, nil, AN_WALKING_NORTHWEST)
    self.anWalkingPlankNorth = anim.newAnimation(an[AN_WALKING_PLANK_NORTH], anSpd, nil, AN_WALKING_PLANK_NORTH)
    self.anWalkingLogNorth = anim.newAnimation(an[AN_WALKING_LOG_NORTH], anSpd, nil, AN_WALKING_LOG_NORTH)
    self.anWalkingNorth = anim.newAnimation(an[AN_WALKING_NORTH], anSpd, nil, AN_WALKING_NORTH)
    self.anWalkingPlankSouth = anim.newAnimation(an[AN_WALKING_PLANK_SOUTH], anSpd, nil, AN_WALKING_PLANK_SOUTH)
    self.anWalkingLogSouth = anim.newAnimation(an[AN_WALKING_LOG_SOUTH], anSpd, nil, AN_WALKING_LOG_SOUTH)
    self.anWalkingSouth = anim.newAnimation(an[AN_WALKING_SOUTH], anSpd, nil, AN_WALKING_SOUTH)
    self.anWalkingPlankEast = anim.newAnimation(an[AN_WALKING_PLANK_EAST], anSpd, nil, AN_WALKING_PLANK_EAST)
    self.anWalkingLogEast = anim.newAnimation(an[AN_WALKING_LOG_EAST], anSpd, nil, AN_WALKING_LOG_EAST)
    self.anWalkingEast = anim.newAnimation(an[AN_WALKING_EAST], anSpd, nil, AN_WALKING_EAST)
    self.anWalkingPlankSoutheast = anim.newAnimation(an[AN_WALKING_PLANK_SOUTHEAST], anSpd, nil,
        AN_WALKING_PLANK_SOUTHEAST)
    self.anWalkingLogSoutheast = anim.newAnimation(an[AN_WALKING_LOG_SOUTHEAST], anSpd, nil, AN_WALKING_LOG_SOUTHEAST)
    self.anWalkingSoutheast = anim.newAnimation(an[AN_WALKING_SOUTHEAST], anSpd, nil, AN_WALKING_SOUTHEAST)
    self.anWalkingPlankNortheast = anim.newAnimation(an[AN_WALKING_PLANK_NORTHEAST], anSpd, nil,
        AN_WALKING_PLANK_NORTHEAST)
    self.anWalkingLogNortheast = anim.newAnimation(an[AN_WALKING_LOG_NORTHEAST], anSpd, nil, AN_WALKING_LOG_NORTHEAST)
    self.anWalkingNortheast = anim.newAnimation(an[AN_WALKING_NORTHEAST], anSpd, nil, AN_WALKING_NORTHEAST)
    self.state = 'Find a job'
    -- self.marked = 0
    self.count = 1
    self.offsetX = -5
    self.offsetY = -10
    self.storeTimer = 0
    self.targetTree = nil
    self.animation = self.anWalkingWest
    self.cut = function()
        self:cutCallback()
    end
end
function Woodcutter:load(data)
    Object.deserialize(self, data)
    Unit.load(self, data)
    self.cut = function()
        self:cutCallback()
    end
    local anData = data.animation
    if anData then
        local callback
        if anData.animationIdentifier == AN_CUTTING_NORTHEAST then
            callback = self.cut
        end
        self.animation = anim.newAnimation(an[anData.animationIdentifier], 1, callback, anData.animationIdentifier)
        self.animation:deserialize(anData)
    end
    self.anWalkingPlankWest = anim.newAnimation(an[data.anWalkingPlankWest.animationIdentifier], 1, nil,
        data.anWalkingPlankWest.animationIdentifier)
    self.anWalkingPlankWest:deserialize(data.anWalkingPlankWest)
    self.anWalkingLogWest = anim.newAnimation(an[data.anWalkingLogWest.animationIdentifier], 1, nil,
        data.anWalkingLogWest.animationIdentifier)
    self.anWalkingLogWest:deserialize(data.anWalkingLogWest)
    self.anWalkingWest = anim.newAnimation(an[data.anWalkingWest.animationIdentifier], 1, nil,
        data.anWalkingWest.animationIdentifier)
    self.anWalkingWest:deserialize(data.anWalkingWest)
    self.anWalkingPlankSouthwest = anim.newAnimation(an[data.anWalkingPlankSouthwest.animationIdentifier], 1, nil,
        data.anWalkingPlankSouthwest.animationIdentifier)
    self.anWalkingPlankSouthwest:deserialize(data.anWalkingPlankSouthwest)
    self.anWalkingLogSouthwest = anim.newAnimation(an[data.anWalkingLogSouthwest.animationIdentifier], 1, nil,
        data.anWalkingLogSouthwest.animationIdentifier)
    self.anWalkingLogSouthwest:deserialize(data.anWalkingLogSouthwest)
    self.anWalkingSouthwest = anim.newAnimation(an[data.anWalkingSouthwest.animationIdentifier], 1, nil,
        data.anWalkingSouthwest.animationIdentifier)
    self.anWalkingSouthwest:deserialize(data.anWalkingSouthwest)
    self.anWalkingPlankNorthwest = anim.newAnimation(an[data.anWalkingPlankNorthwest.animationIdentifier], 1, nil,
        data.anWalkingPlankNorthwest.animationIdentifier)
    self.anWalkingPlankNorthwest:deserialize(data.anWalkingPlankNorthwest)
    self.anWalkingLogNorthwest = anim.newAnimation(an[data.anWalkingLogNorthwest.animationIdentifier], 1, nil,
        data.anWalkingLogNorthwest.animationIdentifier)
    self.anWalkingLogNorthwest:deserialize(data.anWalkingLogNorthwest)
    self.anWalkingNorthwest = anim.newAnimation(an[data.anWalkingNorthwest.animationIdentifier], 1, nil,
        data.anWalkingNorthwest.animationIdentifier)
    self.anWalkingNorthwest:deserialize(data.anWalkingNorthwest)
    self.anWalkingPlankNorth = anim.newAnimation(an[data.anWalkingPlankNorth.animationIdentifier], 1, nil,
        data.anWalkingPlankNorth.animationIdentifier)
    self.anWalkingPlankNorth:deserialize(data.anWalkingPlankNorth)
    self.anWalkingLogNorth = anim.newAnimation(an[data.anWalkingLogNorth.animationIdentifier], 1, nil,
        data.anWalkingLogNorth.animationIdentifier)
    self.anWalkingLogNorth:deserialize(data.anWalkingLogNorth)
    self.anWalkingNorth = anim.newAnimation(an[data.anWalkingNorth.animationIdentifier], 1, nil,
        data.anWalkingNorth.animationIdentifier)
    self.anWalkingNorth:deserialize(data.anWalkingNorth)
    self.anWalkingPlankSouth = anim.newAnimation(an[data.anWalkingPlankSouth.animationIdentifier], 1, nil,
        data.anWalkingPlankSouth.animationIdentifier)
    self.anWalkingPlankSouth:deserialize(data.anWalkingPlankSouth)
    self.anWalkingLogSouth = anim.newAnimation(an[data.anWalkingLogSouth.animationIdentifier], 1, nil,
        data.anWalkingLogSouth.animationIdentifier)
    self.anWalkingLogSouth:deserialize(data.anWalkingLogSouth)
    self.anWalkingSouth = anim.newAnimation(an[data.anWalkingSouth.animationIdentifier], 1, nil,
        data.anWalkingSouth.animationIdentifier)
    self.anWalkingSouth:deserialize(data.anWalkingSouth)
    self.anWalkingPlankEast = anim.newAnimation(an[data.anWalkingPlankEast.animationIdentifier], 1, nil,
        data.anWalkingPlankEast.animationIdentifier)
    self.anWalkingPlankEast:deserialize(data.anWalkingPlankEast)
    self.anWalkingLogEast = anim.newAnimation(an[data.anWalkingLogEast.animationIdentifier], 1, nil,
        data.anWalkingLogEast.animationIdentifier)
    self.anWalkingLogEast:deserialize(data.anWalkingLogEast)
    self.anWalkingEast = anim.newAnimation(an[data.anWalkingEast.animationIdentifier], 1, nil,
        data.anWalkingEast.animationIdentifier)
    self.anWalkingEast:deserialize(data.anWalkingEast)
    self.anWalkingPlankSoutheast = anim.newAnimation(an[data.anWalkingPlankSoutheast.animationIdentifier], 1, nil,
        data.anWalkingPlankSoutheast.animationIdentifier)
    self.anWalkingPlankSoutheast:deserialize(data.anWalkingPlankSoutheast)
    self.anWalkingLogSoutheast = anim.newAnimation(an[data.anWalkingLogSoutheast.animationIdentifier], 1, nil,
        data.anWalkingLogSoutheast.animationIdentifier)
    self.anWalkingLogSoutheast:deserialize(data.anWalkingLogSoutheast)
    self.anWalkingSoutheast = anim.newAnimation(an[data.anWalkingSoutheast.animationIdentifier], 1, nil,
        data.anWalkingSoutheast.animationIdentifier)
    self.anWalkingSoutheast:deserialize(data.anWalkingSoutheast)
    self.anWalkingPlankNortheast = anim.newAnimation(an[data.anWalkingPlankNortheast.animationIdentifier], 1, nil,
        data.anWalkingPlankNortheast.animationIdentifier)
    self.anWalkingPlankNortheast:deserialize(data.anWalkingPlankNortheast)
    self.anWalkingLogNortheast = anim.newAnimation(an[data.anWalkingLogNortheast.animationIdentifier], 1, nil,
        data.anWalkingLogNortheast.animationIdentifier)
    self.anWalkingLogNortheast:deserialize(data.anWalkingLogNortheast)
    self.anWalkingNortheast = anim.newAnimation(an[data.anWalkingNortheast.animationIdentifier], 1, nil,
        data.anWalkingNortheast.animationIdentifier)
    self.anWalkingNortheast:deserialize(data.anWalkingNortheast)
    if data.targetTree then
        self.targetTree = _G.state:dereferenceObject(data.targetTree)
    end
end
function Woodcutter:serialize()
    local data = {}
    local unitData = Unit.serialize(self)
    for k, v in pairs(unitData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    -- self.marked = 0
    data.anWalkingPlankWest = self.anWalkingPlankWest:serialize()
    data.anWalkingLogWest = self.anWalkingLogWest:serialize()
    data.anWalkingWest = self.anWalkingWest:serialize()
    data.anWalkingPlankSouthwest = self.anWalkingPlankSouthwest:serialize()
    data.anWalkingLogSouthwest = self.anWalkingLogSouthwest:serialize()
    data.anWalkingSouthwest = self.anWalkingSouthwest:serialize()
    data.anWalkingPlankNorthwest = self.anWalkingPlankNorthwest:serialize()
    data.anWalkingLogNorthwest = self.anWalkingLogNorthwest:serialize()
    data.anWalkingNorthwest = self.anWalkingNorthwest:serialize()
    data.anWalkingPlankNorth = self.anWalkingPlankNorth:serialize()
    data.anWalkingLogNorth = self.anWalkingLogNorth:serialize()
    data.anWalkingNorth = self.anWalkingNorth:serialize()
    data.anWalkingPlankSouth = self.anWalkingPlankSouth:serialize()
    data.anWalkingLogSouth = self.anWalkingLogSouth:serialize()
    data.anWalkingSouth = self.anWalkingSouth:serialize()
    data.anWalkingPlankEast = self.anWalkingPlankEast:serialize()
    data.anWalkingLogEast = self.anWalkingLogEast:serialize()
    data.anWalkingEast = self.anWalkingEast:serialize()
    data.anWalkingPlankSoutheast = self.anWalkingPlankSoutheast:serialize()
    data.anWalkingLogSoutheast = self.anWalkingLogSoutheast:serialize()
    data.anWalkingSoutheast = self.anWalkingSoutheast:serialize()
    data.anWalkingPlankNortheast = self.anWalkingPlankNortheast:serialize()
    data.anWalkingLogNortheast = self.anWalkingLogNortheast:serialize()
    data.anWalkingNortheast = self.anWalkingNortheast:serialize()
    if self.animation then
        data.animation = self.animation:serialize()
    end
    data.state = self.state
    data.count = self.count
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    data.storeTimer = self.storeTimer
    if self.targetTree then
        data.targetTree = _G.state:serializeObject(self.targetTree)
    end
    return data
end
function Woodcutter:cutCallback()
    if self.state == "Cutting down" then
        local treeProgress
        if self.targetTree.tree and self.targetTree.cuttable then
            treeProgress = self.targetTree:cut()
            if self.targetTree.chop or self.targetTree.falling then
                _G.playSfx(self, choppingFx)
            else
                _G.playSfx(self, cuttingFx)
            end
        else
            self.state = "Looking to chop tree"
            self.moveDir = "none"
        end
        if treeProgress == 2 then
            self.animation:pause()
            self.moveDir = "none"
            self.count = 1
            self.state = "Going to workplace with wood"
            self:requestPath(self.workplace.gx + 1, self.workplace.gy + 3)
        end
    end
end
function Woodcutter:jobUpdate()
    _G.removeObjectAt(self.lrcx, self.lrcy, self.lrx, self.lry, self)
    _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
    self.instancemesh = nil
    self.animation = nil
end
function Woodcutter:checkTrees(cx, cy)
    local chunkx, chunky = cx or self.cx, cy or self.cy
    local closestObject, closestDistance = nil, 10000000
    if _G.state.chunkObjects[chunkx][chunky] then
        for _, obj in pairs(_G.state.chunkObjects[chunkx][chunky]) do
            if (obj.type == 'Pine tree' or obj.type == "Small pine tree" or obj.type == "Medium pine tree" or obj.type ==
                'Oak tree' or obj.type == "Small oak tree" or obj.type == "Medium oak tree") and obj.marked == false then
                -- TODO: Fix magic numbers CRITICAL
                if obj.gx > 0 and obj.gx < 2047 and obj.gy > 0 and obj.gy < 2047 then -- and _G.nodes[obj.gx][obj.gy+1].walkable == 0 then --fixme
                    local dist = _G.manhattanDistance(self.gx, self.gy, obj.gx, obj.gy)
                    if dist < closestDistance then
                        closestObject = obj
                        closestDistance = dist
                    end
                end
            end
        end
    end
    if not closestObject then
        return false, false
    else
        return closestObject, closestDistance
    end
end
function Woodcutter:findTree()
    local closestObject, closestDistance = nil, 10000000
    local objt, disto
    objt, disto = self:checkTrees(self.cx, self.cy)
    if disto and disto < closestDistance then
        closestObject = objt
        closestDistance = disto
    end
    objt, disto = self:checkTrees(self.cx + 1, self.cy)
    if disto and disto < closestDistance then
        closestObject = objt
        closestDistance = disto
    end
    objt, disto = self:checkTrees(self.cx + 1, self.cy + 1)
    if disto and disto < closestDistance then
        closestObject = objt
        closestDistance = disto
    end
    objt, disto = self:checkTrees(self.cx + 1, self.cy - 1)
    if disto and disto < closestDistance then
        closestObject = objt
        closestDistance = disto
    end
    objt, disto = self:checkTrees(self.cx - 1, self.cy + 1)
    if disto and disto < closestDistance then
        closestObject = objt
        closestDistance = disto
    end
    objt, disto = self:checkTrees(self.cx - 1, self.cy)
    if disto and disto < closestDistance then
        closestObject = objt
        closestDistance = disto
    end
    objt, disto = self:checkTrees(self.cx - 1, self.cy - 1)
    if disto and disto < closestDistance then
        closestObject = objt
        closestDistance = disto
    end
    objt, disto = self:checkTrees(self.cx, self.cy + 1)
    if disto and disto < closestDistance then
        closestObject = objt
        closestDistance = disto
    end
    objt, disto = self:checkTrees(self.cx, self.cy - 1)

    if objt and not _G.importantObjectAtGlobal(objt.gx, objt.gy + 1) then
        if disto and disto < closestDistance then
            closestObject = objt
        end
    end
    if not closestObject then
        print("No trees nearby!")
        self.state = "No trees"
        -- TODO: Mark woodcutters hut as inactive
        return
    end
    self.targetTree = closestObject
    self.endx = closestObject.gx
    self.endy = closestObject.gy + 1
    if self.endx == self.gx and self.endy == self.gy then
        self.state = "Cutting down"
        self.animation = anim.newAnimation(an[AN_CUTTING_NORTHEAST], 0.08, self.cut, AN_CUTTING_NORTHEAST)
        self:clearPath()
    else
        self:requestPath(self.endx, self.endy)
        self.state = "Going to tree"
    end
    closestObject.marked = true
end
function Woodcutter:dirSubUpdate()
    if self.moveDir == "west" then
        if self.state == "Going to stockpile" then
            self.animation = self.anWalkingPlankWest
        elseif self.state == "Going to workplace with wood" then
            self.animation = self.anWalkingLogWest
        else
            self.animation = self.anWalkingWest
        end
    elseif self.moveDir == "southwest" then
        if self.state == "Going to stockpile" then
            self.animation = self.anWalkingPlankSouthwest
        elseif self.state == "Going to workplace with wood" then
            self.animation = self.anWalkingLogSouthwest
        else
            self.animation = self.anWalkingSouthwest
        end
    elseif self.moveDir == "northwest" then
        if self.state == "Going to stockpile" then
            self.animation = self.anWalkingPlankNorthwest
        elseif self.state == "Going to workplace with wood" then
            self.animation = self.anWalkingLogNorthwest
        else
            self.animation = self.anWalkingNorthwest
        end
    elseif self.moveDir == "north" then
        if self.state == "Going to stockpile" then
            self.animation = self.anWalkingPlankNorth
        elseif self.state == "Going to workplace with wood" then
            self.animation = self.anWalkingLogNorth
        else
            self.animation = self.anWalkingNorth
        end
    elseif self.moveDir == "south" then
        if self.state == "Going to stockpile" then
            self.animation = self.anWalkingPlankSouth
        elseif self.state == "Going to workplace with wood" then
            self.animation = self.anWalkingLogSouth
        else
            self.animation = self.anWalkingSouth
        end
    elseif self.moveDir == "east" then
        if self.state == "Going to stockpile" then
            self.animation = self.anWalkingPlankEast
        elseif self.state == "Going to workplace with wood" then
            self.animation = self.anWalkingLogEast
        else
            self.animation = self.anWalkingEast
        end
    elseif self.moveDir == "southeast" then
        if self.state == "Going to stockpile" then
            self.animation = self.anWalkingPlankSoutheast
        elseif self.state == "Going to workplace with wood" then
            self.animation = self.anWalkingLogSoutheast
        else
            self.animation = self.anWalkingSoutheast
        end
    elseif self.moveDir == "northeast" then
        if self.state == "Going to stockpile" then
            self.animation = self.anWalkingPlankNortheast
        elseif self.state == "Going to workplace with wood" then
            self.animation = self.anWalkingLogNortheast
        else
            self.animation = self.anWalkingNortheast
        end
    end
end
function Woodcutter:update()
    self.storeTimer = self.storeTimer + 1
    if self.pathState == "Waiting for path" then
        self:pathfind()
    elseif self.state == "Find a job" then
        _G.JobController:findJob(self, "Woodcutter")
    elseif self.state == "Storing second plank" and self.storeTimer > 10 then
        self.storeTimer = 0
        self.state = "Storing third plank"
        _G.stockpile:store('wood')
    elseif self.state == "Storing third plank" and self.storeTimer > 10 then
        self.storeTimer = 0
        _G.stockpile:store('wood')
        self.state = "Storing fourth plank"
    elseif self.state == "Storing fourth plank" and self.storeTimer > 10 then
        self.storeTimer = 0
        _G.stockpile:store('wood')
        self.animation:resume()
        self.state = "Go to workplace"
    elseif self.state == "Go to stockpile" then
        if _G.stockpile then
            self.state = "Going to stockpile"
            local closestNode
            local distance = math.huge
            for _, v in ipairs(_G.stockpile.nodeList) do
                local tmp = _G.manhattanDistance(v.gx, v.gy, self.gx, self.gy)
                if tmp < distance then
                    distance = tmp
                    closestNode = v
                end
            end
            if not closestNode then
                print("Closest stockpile node not found")
            else
                self:requestPath(closestNode.gx, closestNode.gy)
            end
            self.moveDir = "none"
        end
    elseif self.state ~= "No trees" then
        if self.state == "Looking to chop tree" then
            self:findTree()
        elseif self.state == "Go to workplace" then
            self.gx, self.gy = math.round(self.gx), math.round(self.gy)
            self.fx, self.fy = self.gx * 1000 + 500, self.gy * 1000 + 500
            self:requestPath(self.workplace.gx + 1, self.workplace.gy + 3)
            self.state = "Going to workplace"
            self.moveDir = "none"
        elseif self.state == "Going to tree" or self.state == "Going to stockpile" or self.state == "Going to workplace" or
            self.state == "Going to workplace with wood" or self.state == "Going to waypoint" then
            if self.moveDir == "none" then
                self:updateDirection()
                self:dirSubUpdate()
            end
            self:move()
        end
        if self.fx * 0.001 == self.waypointX and self.fy * 0.001 == self.waypointY and self.moveDir ~= "none" then
            if self.state == "Going to tree" then
                if self:reachedPathEnd() then
                    self.state = "Cutting down"
                    self.animation = anim.newAnimation(an[AN_CUTTING_NORTHEAST], 0.08, self.cut, AN_CUTTING_NORTHEAST)
                    self:clearPath()
                    return
                else
                    self:setNextWaypoint()
                end
                self.count = self.count + 1
            elseif self.state == "Going to workplace with wood" then
                if self:reachedPathEnd() then
                    self.workplace:work(self)
                    self:clearPath()
                    return
                else
                    self:setNextWaypoint()
                end
                self.count = self.count + 1
            elseif self.state == "Going to stockpile" then
                if self:reachedPathEnd() then
                    _G.stockpile:store('wood')
                    self.state = "Storing second plank"
                    self.animation:pause()
                    self.storeTimer = 0
                    self:clearPath()
                    return
                else
                    self:setNextWaypoint()
                end
                self.count = self.count + 1
            elseif self.state == "Going to workplace" then
                if self:reachedPathEnd() then
                    self.state = "Looking to chop tree"
                    self:clearPath()
                    return
                else
                    self:setNextWaypoint()
                end
                self.count = self.count + 1
            elseif self.state == "Going to waypoint" then
                if self:reachedPathEnd() then
                    self.state = "none"
                    self:clearPath()
                    return
                else
                    self:setNextWaypoint()
                end
                self.count = self.count + 1
            end
        end
    end
end
function Woodcutter:animate()
    if self.moveDir ~= "none" and self.animation and (self.animation.position == 2 or self.animation.position == 10) then
        _G.playSfx(self, footstepFx)
    end
    self:update()
    Unit.animate(self)
end
return Woodcutter
