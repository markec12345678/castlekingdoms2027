local Soldier = require("objects.Units.Soldier")
local Unit = require("objects.Units.Unit")
local Object = require("objects.Object")
local anim = require("libraries.anim8")

local an = require("objects.Animations.Spearman")

local Spearman = _G.class("Spearman", Soldier)

Spearman.static.MOVE_SOUNDS = { _G.fx["Spearman_Move_1"], _G.fx["Spearman_Move_2"], _G.fx["Spearman_Move_3"] }
Spearman.static.MOVE_INACCESSIBLE_SOUND = _G.fx["Spearman_Move_Inaccessible"]

function Spearman:initialize(gx, gy)
    Soldier.initialize(self, gx, gy, "Spearman")
    self.count = 1
    self.offsetY = -10
    self.offsetX = -6
    self.animated = true
end

function Spearman:load(data)
    Object.deserialize(self, data)
    Unit.load(self, data)
    local anData = data.animation
    local callback
    if anData then
        self.animation = anim.newAnimation(an[anData.animationIdentifier], 0.05, callback, anData.animationIdentifier)
        self.animation:deserialize(anData)
    end
end

function Spearman:dirSubUpdate()
    local walkAnimationName = "spearman_walk"
    self.animation = self:getDirectionalAnimation(an, walkAnimationName, 0.08, nil, self.moveDir)
end

function Spearman:serialize()
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

return Spearman
