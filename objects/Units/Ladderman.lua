local Soldier = require("objects.Units.Soldier")
local Unit = require("objects.Units.Unit")
local Object = require("objects.Object")
local anim = require("libraries.anim8")

local an = require("objects.Animations.Ladderman")

local Ladderman = _G.class("Ladderman", Soldier)

function Ladderman:initialize(gx, gy)
    Soldier.initialize(self, gx, gy, "Ladderman")
    self:usePallete(2)
    self.state = "Go to guild"
    self.count = 1
    self.offsetY = -60
    self.offsetX = -50
    self.animated = true
    self.pathState = "No path"
end

function Ladderman:load(data)
    Object.deserialize(self, data)
    Unit.load(self, data)
    local anData = data.animation
    local callback
    if anData then
        self.animation = anim.newAnimation(an[anData.animationIdentifier], 0.05, callback, anData.animationIdentifier)
        self.animation:deserialize(anData)
    end
end

function Ladderman:dirSubUpdate()
    local walkAnimationName = "body_ladder_bearer_walk"
    self.animation = self:getDirectionalAnimation(an, walkAnimationName, 0.08, nil, self.moveDir)
end

function Ladderman:serialize()
    local data = {}
    local unitData = Unit.serialize(self)
    for k, v in pairs(unitData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.state = self.state
    data.count = self.count
    data.offsetY = self.offsetY
    data.offsetX = self.offsetX
    data.animated = self.animated
    if self.animation then
        data.animation = self.animation:serialize()
    end
    return data
end

return Ladderman
