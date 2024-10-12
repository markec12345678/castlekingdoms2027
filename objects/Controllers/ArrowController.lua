local images = {}

for group = 1, 16 do
    images[group] = {}
    for count = 1, 9 do
        local filename = string.format("assets/projectiles/arrows/arrows_%d (%d).png", group, count)
        images[group][count] = love.graphics.newImage(filename)
    end
end

local ArrowController = _G.class("ArrowController")
function ArrowController:initialize()
end

local ARROW_CONSTANT = 490

local Arrow = _G.class("Arrow")
function Arrow:initialize(originx, originy, hsp, vsp, direction, lowArc, originh, onhit)
    self.flying = true
    self.hsp = hsp
    self.vsp = vsp
    self.direction = direction
    self.arrowAngle = 0
    self.lowArc = lowArc
    self.altitude = 0 -- TODO: starting altitude needs to be a parameter
    self.fx, self.fy = originx, originy
    self._x, self._y = 0, ARROW_CONSTANT - 40 - originh
    self.onHit = onhit or function()
    end
    self:registerAsProjectile()
end

function Arrow:registerAsProjectile()
    table.insert(_G.state.projectiles, self)
end

function Arrow:getHorizontalSpriteIndex()
    local val = math.floor((math.deg(self.direction) / 22.5) + 0.5) - 12
    return (val % 16) + 1
end

function Arrow:getVerticalSpriteIndex()
    -- we have 9 sprites, so that leaves us at about 20 degrees per sprite
    -- vertical angle is from -90 to +90
    local verticalAngle = math.deg(self.arrowAngle)
    if verticalAngle > -10 and verticalAngle <= 10 then
        return 5
    end
    if verticalAngle < 0 then
        return math.ceil(9 - (verticalAngle + 90) / 20)
    end
    return math.floor(10 - (verticalAngle + 90) / 20)
end

function Arrow:update(dt)
    if not self.flying then return end
    dt = dt or _G.dt
    local SPEED_MODIFIER = self.lowArc and 13 or 20
    self.vsp = self.vsp + (dt * SPEED_MODIFIER)
    local newy = self._y + (self.vsp * dt * SPEED_MODIFIER)
    local newx = self._x + (self.hsp * dt * SPEED_MODIFIER)
    if self._hsp ~= 0 then
        self.arrowAngle = math.atan2(newy - self._y, newx - self._x)
    end
    self._x = newx
    self._y = newy
    self.altitude = ARROW_CONSTANT - newy


    local cx, cy, xx, yy = _G.getLocalCoordinatesFromGlobal(math.floor(self.fx / 10), math.floor(self.fy / 10))
    local elevationOffsetY = (_G.state.map.heightmap[cx][cy][xx][yy] or 0) * 2
    if self.altitude <= elevationOffsetY then
        self._hsp = 0
        self.flying = false
        self:onHit()
        self.toBeDeleted = true
    end


    self.fx = self.fx + (self.hsp * dt * SPEED_MODIFIER * math.cos(self.direction));
    self.fy = self.fy + (self.hsp * dt * SPEED_MODIFIER * math.sin(self.direction));
end

local function sign(x)
    return x > 0 and 1 or x < 0 and -1 or 0
end
local function distanceFrom(x1, y1, x2, y2) return math.abs(math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)) end
local function anglerad(x1, y1, x2, y2)
    return math.atan2(y2 - y1, x2 - x1)
end

function ArrowController:shootArrow(originUnit, targetGX, targetGY, onHit)
    local x = 0
    local low_arc = true
    local ox, oy = (originUnit.fx / 1000), (originUnit.fy / 1000)
    local distance = distanceFrom(ox * 10, oy * 10, targetGX * 10, targetGY * 10)
    if distance < 0 then
        print("too close to shoot")
        return
    end
    local angle = anglerad(targetGX * 10, targetGY * 10, ox * 10, oy * 10) - math.pi
    local _x = distance - x;
    local cx, cy, xx, yy = _G.getLocalCoordinatesFromGlobal(math.floor(originUnit.gx), math.floor(originUnit.gy))
    local elevationOffsetY = (_G.state.map.heightmap[cx][cy][xx][yy] or 0) * 2
    local tcx, tcy, txx, tyy = _G.getLocalCoordinatesFromGlobal(math.floor(targetGX), math.floor(targetGY))
    local targetElevationOffsetY = (_G.state.map.heightmap[tcx][tcy][txx][tyy] or 0) * 2
    local _y = elevationOffsetY - targetElevationOffsetY + 40;
    local _v = 20.0 * sign(_x); --pr speed is 20.0
    local _v2 = _v * _v;
    local _g = 1.0;             --gravitational acceleration (1.0 pixels per step per step)
    ----------------------------------------------------------
    local _a = _v2 * _v2 - _g * (_g * _x * _x - 2 * _y * _v2);
    local _b = 0
    if _a < 0 then
        print("not in range") -- TODO: handle this better
        return
    end
    local bresenham = require('libraries.bresenham')
    local directLOS = bresenham.los(math.floor(ox), math.floor(oy), targetGX, targetGY, function(gx, gy)
        if gx == math.floor(ox) and gy == math.floor(oy) then return true end
        local cx, cy, xx, yy = _G.getLocalCoordinatesFromGlobal(math.floor(gx), math.floor(gy))
        local elevationOffsetAtTile = (_G.state.map.heightmap[cx][cy][xx][yy] or 0) * 2
        if elevationOffsetY > targetElevationOffsetY then
            if elevationOffsetY >= elevationOffsetAtTile - 10 and elevationOffsetAtTile + 10 >= targetElevationOffsetY then
                return true
            end
        else
            if targetElevationOffsetY >= elevationOffsetAtTile - 10 and elevationOffsetAtTile + 10 >= elevationOffsetY then
                return true
            end
        end
        return false
    end)

    low_arc = directLOS
    if low_arc then
        _b = -(_v2 - math.sqrt(_a)) / (_g * _x) --low arc trajectory
    else
        _b = -(_v2 + math.sqrt(_a)) / (_g * _x)
    end --high arc
    local _an = math.atan(_b);
    local _hsp = math.cos(_an) * _v;
    local _vsp = math.sin(_an) * _v;
    return Arrow:new(ox * 10, oy * 10, _hsp, _vsp, angle, low_arc, elevationOffsetY, onHit)
end

function ArrowController:draw()
    for _, proj in ipairs(_G.state.projectiles) do
        local gx, gy = proj.fx / 10, proj.fy / 10
        local sx, sy = gx + proj.altitude / 50, gy
        local fx = IsoToScreenX(gx, gy) - _G.state.viewXview - ((IsoToScreenX(gx, gy)) - _G.state.viewXview) * (1 - _G.state.scaleX)
        local fy = IsoToScreenY(gx, gy) - _G.state.viewYview - ((IsoToScreenY(gx, gy)) - _G.state.viewYview) * (1 - _G.state.scaleX)
        local sfx = IsoToScreenX(sx, sy) - _G.state.viewXview - ((IsoToScreenX(sx, sy)) - _G.state.viewXview) * (1 - _G.state.scaleX)
        local sfy = IsoToScreenY(sx, sy) - _G.state.viewYview - ((IsoToScreenY(sx, sy)) - _G.state.viewYview) * (1 - _G.state.scaleX)

        local cx, cy, xx, yy = _G.getLocalCoordinatesFromGlobal(math.floor(gx), math.floor(gy))
        local elevationOffsetY = (_G.state.map.heightmap[cx][cy][xx][yy] or 0) * 2
        -- render arrow itself
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(images[proj:getHorizontalSpriteIndex()][proj:getVerticalSpriteIndex()], fx - 27, fy - 27 + (-proj.altitude) * _G.state.scaleX)
        -- render arrow shadow
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.draw(images[proj:getHorizontalSpriteIndex()][5], sfx - 27, sfy - 27 + (elevationOffsetY * _G.state.scaleX) * _G.state.scaleX)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

return ArrowController:new()
