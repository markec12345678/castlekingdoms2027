local ArrowController = _G.class("ArrowController")
function ArrowController:initialize()
end

local ARROW_CONSTANT = 490

local Arrow = _G.class("Arrow")
function Arrow:initialize(originx, originy, hsp, vsp, direction, lowArc, originh)
    self.flying = true
    self.hsp = hsp
    self.vsp = vsp
    self.direction = direction
    self.arrowAngle = 0
    self.lowArc = lowArc
    self.altitude = 0 -- TODO: starting altitude needs to be a parameter
    self.fx, self.fy = originx, originy
    self._x, self._y = 0, ARROW_CONSTANT - 40 - originh
    self:registerAsProjectile()
end

function Arrow:registerAsProjectile()
    table.insert(_G.state.projectiles, self)
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
    print(self.altitude, elevationOffsetY)
    if self.altitude <= elevationOffsetY then --TOOD: should check for terrain altitude
        self._hsp = 0
        self.flying = false
        print("arrow hit!")
        --self:onHit() -- TODO: implement
    end

    self.fx = self.fx + (self.hsp * dt * SPEED_MODIFIER * math.cos(self.direction));
    self.fy = self.fy + (self.hsp * dt * SPEED_MODIFIER * math.sin(self.direction));
    -- print(self.fx, self.fy, self.altitude)
    -- love.graphics.push()
    -- love.graphics.translate(pr.x - 20, pr.y + 5)
    -- love.graphics.rotate(angle)
    -- love.graphics.rectangle("fill", 0, 0, 20, 5, angle)
    -- love.graphics.pop()


    -- love.graphics.push()
    -- love.graphics.translate(velocityX, velocityY)
    -- love.graphics.scale(1 + altitude / 20, (1 + altitude / 20))
    -- love.graphics.rotate(pr.tdangle)
    -- love.graphics.rectangle("fill", 0, 0, 20 * (angle + 1), 5, pr.tdangle)
    -- love.graphics.pop()
end

local function sign(x)
    return x > 0 and 1 or x < 0 and -1 or 0
end
local function distanceFrom(x1, y1, x2, y2) return math.abs(math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)) end
local function anglerad(x1, y1, x2, y2)
    return math.atan2(y2 - y1, x2 - x1)
end

function ArrowController:shootArrow(originUnit, targetGX, targetGY)
    local x = 0
    local low_arc = true
    -- todo calculate distance and angle
    local ox, oy = (originUnit.fx / 1000), (originUnit.fy / 1000)
    local distance = distanceFrom(ox * 10, oy * 10, targetGX * 10, targetGY * 10) - 20
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
    -- if (_a > 0) then --if (_a > 0) then target is in range
    local _b = 0
    if _a < 0 then
        print("not in range")
        return
    end
    low_arc = _a > 100000
    if low_arc then
        _b = -(_v2 - math.sqrt(_a)) / (_g * _x) --low arc trajectory
    else
        _b = -(_v2 + math.sqrt(_a)) / (_g * _x)
    end --high arc
    local _an = math.atan(_b);
    local _hsp = math.cos(_an) * _v;
    local _vsp = math.sin(_an) * _v - _g * 1;
    -- pr.shoot = true
    -- pr._hsp = _hsp
    -- pr._vsp = _vsp
    -- pr.x = 0
    -- pr.y = 490
    -- pr.tdangle = angle
    return Arrow:new(ox * 10, oy * 10, _hsp, _vsp, angle, low_arc, elevationOffsetY)
end

function ArrowController:draw()
    for k, proj in ipairs(_G.state.projectiles) do
        -- if proj.flying then
        local gx, gy = proj.fx / 10, proj.fy / 10
        -- if proj.flying then
        --     print("ALT", proj.altitude)
        -- end
        local sx, sy = gx + proj.altitude / 50, gy
        -- print(gx, gy, proj.altitude)
        -- local cx, cy, x, y = _G.getLocalCoordinatesFromGlobal(gx, gy)
        -- local elevationOffsetY = (_G.state.map.heightmap[cx][cy][x][y] or 0) * 2
        local fx = IsoToScreenX(gx, gy) - _G.state.viewXview - ((IsoToScreenX(gx, gy)) - _G.state.viewXview) * (1 - _G.state.scaleX)
        local fy = IsoToScreenY(gx, gy) - _G.state.viewYview - ((IsoToScreenY(gx, gy)) - _G.state.viewYview) * (1 - _G.state.scaleX)
        local sfx = IsoToScreenX(sx, sy) - _G.state.viewXview - ((IsoToScreenX(sx, sy)) - _G.state.viewXview) * (1 - _G.state.scaleX)
        local sfy = IsoToScreenY(sx, sy) - _G.state.viewYview - ((IsoToScreenY(sx, sy)) - _G.state.viewYview) * (1 - _G.state.scaleX)

        local cx, cy, xx, yy = _G.getLocalCoordinatesFromGlobal(math.floor(gx), math.floor(gy))
        local elevationOffsetY = (_G.state.map.heightmap[cx][cy][xx][yy] or 0) * 2
        -- print(fx, fy)
        -- love.graphics.push()
        -- love.graphics.translate(fx, fy)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", fx, fy + (-proj.altitude) * _G.state.scaleX, 10, 10)
        love.graphics.setColor(0, 0, 0, 0.3)
        -- love.graphics.rectangle("fill", fx, fy, 10, 10)
        love.graphics.rectangle("fill", sfx, sfy - (elevationOffsetY * _G.state.scaleX), 10, 10)
        love.graphics.setColor(1, 1, 1, 1)
        -- love.graphics.rotate(proj.direction)
        -- love.graphics.pop()
        -- end
    end
end

return ArrowController:new()
