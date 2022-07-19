local _, _ = ...
local Unit = require("objects.Units.Unit")
local Object = require("objects.Object")
local anim = require("libraries.anim8")

local fr_idle_e = _G.indexQuads("body_ox_idle_e", 8, nil, true)
local fr_idle_w = _G.indexQuads("body_ox_idle_w", 8, nil, true)
local fr_idle_n = _G.indexQuads("body_ox_idle_n", 8, nil, true)
local fr_idle_s = _G.indexQuads("body_ox_idle_s", 8, nil, true)
local fr_idle_ne = _G.indexQuads("body_ox_idle_ne", 8, nil, true)
local fr_idle_nw = _G.indexQuads("body_ox_idle_nw", 8, nil, true)
local fr_idle_se = _G.indexQuads("body_ox_idle_se", 8, nil, true)
local fr_idle_sw = _G.indexQuads("body_ox_idle_sw", 8, nil, true)
local fr_walk_e = _G.indexQuads("body_ox_walk_e", 16)
local fr_walk_w = _G.indexQuads("body_ox_walk_w", 16)
local fr_walk_n = _G.indexQuads("body_ox_walk_n", 16)
local fr_walk_s = _G.indexQuads("body_ox_walk_s", 16)
local fr_walk_ne = _G.indexQuads("body_ox_walk_ne", 16)
local fr_walk_nw = _G.indexQuads("body_ox_walk_nw", 16)
local fr_walk_se = _G.indexQuads("body_ox_walk_se", 16)
local fr_walk_sw = _G.indexQuads("body_ox_walk_sw", 16)
local fr_walk_stone_e = _G.indexQuads("body_ox_walk_stone_e", 16)
local fr_walk_stone_w = _G.indexQuads("body_ox_walk_stone_w", 16)
local fr_walk_stone_n = _G.indexQuads("body_ox_walk_stone_n", 16)
local fr_walk_stone_s = _G.indexQuads("body_ox_walk_stone_s", 16)
local fr_walk_stone_ne = _G.indexQuads("body_ox_walk_stone_ne", 16)
local fr_walk_stone_nw = _G.indexQuads("body_ox_walk_stone_nw", 16)
local fr_walk_stone_se = _G.indexQuads("body_ox_walk_stone_se", 16)
local fr_walk_stone_sw = _G.indexQuads("body_ox_walk_stone_sw", 16)

local IDLE_EAST = "idle_east"
local IDLE_WEST = "idle_west"
local IDLE_NORTH = "idle_north"
local IDLE_SOUTH = "idle_south"
local IDLE_NORTHEAST = "idle_north_east"
local IDLE_NORTHWEST = "idle_north_west"
local IDLE_SOUTHEAST = "idle_south_east"
local IDLE_SOUTHWEST = "idle_south_west"
local WALK_EAST = "walk_east"
local WALK_WEST = "walk_west"
local WALK_NORTH = "walk_north"
local WALK_SOUTH = "walk_south"
local WALK_NORTHEAST = "walk_north_east"
local WALK_NORTHWEST = "walk_north_west"
local WALK_SOUTHEAST = "walk_south_east"
local WALK_SOUTHWEST = "walk_south_west"
local WALK_STONE_EAST = "walk_stone_east"
local WALK_STONE_WEST = "walk_stone_west"
local WALK_STONE_NORTH = "walk_stone_north"
local WALK_STONE_SOUTH = "walk_stone_south"
local WALK_STONE_NORTHEAST = "walk_stone_north_east"
local WALK_STONE_NORTHWEST = "walk_stone_north_west"
local WALK_STONE_SOUTHEAST = "walk_stone_south_east"
local WALK_STONE_SOUTHWEST = "walk_stone_south_west"

local an = {
    [IDLE_EAST] = fr_idle_e,
    [IDLE_WEST] = fr_idle_w,
    [IDLE_NORTH] = fr_idle_n,
    [IDLE_SOUTH] = fr_idle_s,
    [IDLE_NORTHEAST] = fr_idle_ne,
    [IDLE_NORTHWEST] = fr_idle_nw,
    [IDLE_SOUTHEAST] = fr_idle_se,
    [IDLE_SOUTHWEST] = fr_idle_sw,
    [WALK_EAST] = fr_walk_e,
    [WALK_WEST] = fr_walk_w,
    [WALK_NORTH] = fr_walk_n,
    [WALK_SOUTH] = fr_walk_s,
    [WALK_NORTHEAST] = fr_walk_ne,
    [WALK_NORTHWEST] = fr_walk_nw,
    [WALK_SOUTHEAST] = fr_walk_se,
    [WALK_SOUTHWEST] = fr_walk_sw,
    [WALK_STONE_EAST] = fr_walk_stone_e,
    [WALK_STONE_WEST] = fr_walk_stone_w,
    [WALK_STONE_NORTH] = fr_walk_stone_n,
    [WALK_STONE_SOUTH] = fr_walk_stone_s,
    [WALK_STONE_NORTHEAST] = fr_walk_stone_ne,
    [WALK_STONE_NORTHWEST] = fr_walk_stone_nw,
    [WALK_STONE_SOUTHEAST] = fr_walk_stone_se,
    [WALK_STONE_SOUTHWEST] = fr_walk_stone_sw
}

local Ox = _G.class("Ox", Unit)
function Ox:initialize(gx, gy, parent)
    Unit.initialize(self, gx, gy, "Ox")
    self.workplace = parent
    self.state = "Idle"
    self.count = 1
    self.offsetY = -10
    self.offsetX = -5
    -- TODO: add custom idle animation cycle
    self.animated = true
    self.animation = anim.newAnimation(an[IDLE_NORTH], 0.12, nil, IDLE_NORTH)
end

function Ox:dirSubUpdate()
    if self.moveDir == "west" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[WALK_STONE_WEST], 0.05, nil, WALK_STONE_WEST)
        elseif self.state == "Idle" then
            self.animation = anim.newAnimation(an[IDLE_WEST], 0.12, nil, IDLE_WEST)
        else
            self.animation = anim.newAnimation(an[WALK_WEST], 0.05, nil, WALK_WEST)
        end
    elseif self.moveDir == "southwest" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[WALK_STONE_SOUTHWEST], 0.05, nil, WALK_STONE_SOUTHWEST)
        elseif self.state == "Idle" then
            self.animation = anim.newAnimation(an[IDLE_SOUTHWEST], 0.12, nil, IDLE_SOUTHWEST)
        else
            self.animation = anim.newAnimation(an[WALK_SOUTHWEST], 0.05, nil, WALK_SOUTHWEST)
        end
    elseif self.moveDir == "northwest" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[WALK_STONE_NORTHWEST], 0.05, nil, WALK_STONE_NORTHWEST)
        elseif self.state == "Idle" then
            self.animation = anim.newAnimation(an[IDLE_NORTHWEST], 0.12, nil, IDLE_NORTHWEST)
        else
            self.animation = anim.newAnimation(an[WALK_NORTHWEST], 0.05, nil, WALK_NORTHWEST)
        end
    elseif self.moveDir == "north" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[WALK_STONE_NORTH], 0.05, nil, WALK_STONE_NORTH)
        elseif self.state == "Idle" then
            self.animation = anim.newAnimation(an[IDLE_NORTH], 0.12, nil, IDLE_NORTH)
        else
            self.animation = anim.newAnimation(an[WALK_NORTH], 0.05, nil, WALK_NORTH)
        end
    elseif self.moveDir == "south" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[WALK_STONE_SOUTH], 0.05, nil, WALK_STONE_SOUTH)
        elseif self.state == "Idle" then
            self.animation = anim.newAnimation(an[IDLE_SOUTH], 0.12, nil, IDLE_SOUTH)
        else
            self.animation = anim.newAnimation(an[WALK_SOUTH], 0.05, nil, WALK_SOUTH)
        end
    elseif self.moveDir == "east" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[WALK_STONE_EAST], 0.05, nil, WALK_STONE_EAST)
        elseif self.state == "Idle" then
            self.animation = anim.newAnimation(an[IDLE_EAST], 0.12, nil, IDLE_EAST)
        else
            self.animation = anim.newAnimation(an[WALK_EAST], 0.05, nil, WALK_EAST)
        end
    elseif self.moveDir == "southeast" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[WALK_STONE_SOUTHEAST], 0.05, nil, WALK_STONE_SOUTHEAST)
        elseif self.state == "Idle" then
            self.animation = anim.newAnimation(an[IDLE_SOUTHEAST], 0.12, nil, IDLE_SOUTHEAST)
        else
            self.animation = anim.newAnimation(an[WALK_SOUTHEAST], 0.05, nil, WALK_SOUTHEAST)
        end
    elseif self.moveDir == "northeast" then
        if self.state == "Going to stockpile" then
            self.animation = anim.newAnimation(an[WALK_STONE_NORTHEAST], 0.05, nil, WALK_STONE_NORTHEAST)
        elseif self.state == "Idle" then
            self.animation = anim.newAnimation(an[IDLE_NORTHEAST], 0.12, nil, IDLE_NORTHEAST)
        else
            self.animation = anim.newAnimation(an[WALK_NORTHEAST], 0.05, nil, WALK_NORTHEAST)
        end
    end
end

function Ox:update()
    if self.pathState == "Waiting for path" then
        self:pathfind()
    elseif self.moveDir == "none" and self.state == "Going to workplace" then
        self:updateDirection()
    elseif self.moveDir == "none" and self.state == "Going to stockpile" then
        self:updateDirection()
    elseif self.state == "Go to workplace" then
        self:requestPath(self.workplace.gx + 1, self.workplace.gy + 3)
        self.state = "Going to workplace"
        self.moveDir = "none"
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
    end
    if self.state == "Going to stockpile" or self.state == "Going to workplace" then
        self:move()
    end
    if self.fx * 0.001 == self.waypointX and self.fy * 0.001 == self.waypointY and self.moveDir ~= "none" then
        if self.state == "Going to workplace" then
            if self:reachedPathEnd() then
                self.state = "Idle"
                self.moveDir = "north"
                self:dirSubUpdate()
                self:clearPath()
                return
            else
                self:setNextWaypoint()

            end
            self.count = self.count + 1
        elseif self.state == "Going to stockpile" then
            if self:reachedPathEnd() then
                for i = 0, 7 do
                    _G.stockpile:store("stone")
                end
                self.state = "Go to workplace"
                self:clearPath()
                return
            else
                self:setNextWaypoint()

            end
            self.count = self.count + 1
        end
    end
end

function Ox:sendToStockpile()
    self.workplace.quantity = 0
    self.state = "Go to stockpile"
end

function Ox:animate()
    self:update()
    Unit.animate(self)
end

function Ox:load(data)
    Object.deserialize(self, data)
    Unit.load(self, data)
    local anData = data.animation
    if anData then
        self.animation = anim.newAnimation(an[anData.animationIdentifier], 1, nil, anData.animationIdentifier)
        self.animation:deserialize(anData)
    end
    self.state = data.state
    self.eatTimer = data.eatTimer
    self.offsetY = data.offsetY
    self.offsetX = data.offsetX
    self.animated = data.animated
    self.count = data.count
end

function Ox:serialize()
    local data = {}
    local unitData = Unit.serialize(self)
    for k, v in pairs(unitData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    if self.animation then
        data.animation = self.animation:serialize()
    end
    data.state = self.state
    data.offsetY = self.offsetY
    data.offsetX = self.offsetX
    data.animated = self.animated
    data.count = self.count
    return data
end

return Ox
