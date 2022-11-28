local Object = require("objects.Object")
local Stonemason = require("objects.Units.Stonemason")
local Unit = require("objects.Units.Unit")
local anim = require("libraries.anim8")
local Structure = require("objects.Structure")

local an = Stonemason.static.animations

local OxHandler = _G.class("OxHandler", Stonemason)
function OxHandler:initialize(gx, gy, type)
    Stonemason.initialize(self, gx, gy, type)
    self.targetQuarry = nil
end

function OxHandler:update()
    if self.pathState == "Waiting for path" then
        self:pathfind()
    elseif self.state == "Find a job" then
        _G.JobController:findJob(self, "OxHandler")
    elseif self.state == "Go to workplace" then
        self:requestPath(self.workplace.gx + 3, self.workplace.gy + 1)
        self.state = "Going to workplace"
        self.moveDir = "none"
    elseif self.state == "Go to workplace with stone" then
        self:requestPath(self.workplace.gx + 3, self.workplace.gy + 1)
        self.state = "Going to workplace with stone"
        self.moveDir = "none"
    elseif self.state == "Go to quarry" then
        self:setIdle()
        if self.workplace.quantity < 8 then
            for x = self.workplace.gx - 25, self.workplace.gx + 25, 5 do
                for y = self.workplace.gy - 25, self.workplace.gy + 25, 5 do
                    local str = _G.objectFromSubclassAtGlobal(x, y, Structure)
                    if not str then goto continue end
                    str = str.parent or str
                    if str.class.name == "Quarry" then
                        self.targetQuarry = str
                        if self.targetQuarry.stack.quantity > 0 and self.targetQuarry.assignedOxHandler == nil then
                            self.targetQuarry.assignedOxHandler = self
                            self:requestPath(str.gx + 6, str.gy + 3)
                            self.state = "Going to quarry"
                            self.moveDir = "none"
                            self.animation:resume()
                            return
                        end
                    end
                    ::continue::
                end
            end
        end
    elseif self.moveDir == "none" and self.state == "Going to workplace" then
        self:updateDirection()
    elseif self.moveDir == "none" and self.state == "Going to quarry" then
        self:updateDirection()
    elseif self.moveDir == "none" and self.state == "Going to workplace with stone" then
        self:updateDirection()
    elseif self.state == "Going to workplace" or self.state == "Going to quarry" or self.state ==
        "Going to workplace with stone" then
        self:move()
    end
    if self.fx * 0.001 == self.waypointX and self.fy * 0.001 == self.waypointY and self.moveDir ~= "none" then
        if self.state == "Going to workplace" then
            if self:reachedPathEnd() then
                self.workplace:work(self)
                self:clearPath()
                return
            else
                self:setNextWaypoint()
            end
            self.count = self.count + 1
        end
        if self.state == "Going to quarry" then
            if self.targetQuarry.assignedOxHandler ~= self then
                self.state = "Go to workplace"
            end
            if self:reachedPathEnd() then
                self.targetQuarry.stack:take()
                self.targetQuarry.assignedOxHandler = nil
                self.state = "Go to workplace with stone"
                self:clearPath()
                return
            else
                self:setNextWaypoint()
            end
            self.count = self.count + 1
        end
        if self.state == "Going to workplace with stone" then
            if self:reachedPathEnd() then
                self.workplace:add()
                self.workplace:work(self)
                self:clearPath()
                return
            else
                self:setNextWaypoint()
            end
            self.count = self.count + 1
        end
    end
end

function OxHandler:sendToQuarry()
    self.state = "Go to quarry"
end

function OxHandler:load(data)
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
    if data.targetQuarry then
        self.targetQuarry = _G.state:dereferenceObject(data.targetQuarry)
    end
end

function OxHandler:serialize()
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
    data.eatTimer = self.eatTimer
    data.offsetY = self.offsetY
    data.offsetX = self.offsetX
    data.animated = self.animated
    data.count = self.count
    if self.targetQuarry then
        data.targetQuarry = _G.state:serializeObject(self.targetQuarry)
    end
    return data
end

return OxHandler
