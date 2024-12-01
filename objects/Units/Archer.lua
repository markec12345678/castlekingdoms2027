local Soldier = require("objects.Units.Soldier")
local Unit = require("objects.Units.Unit")
local Object = require("objects.Object")
local anim = require("libraries.anim8")

local an = require("objects.Animations.Archer")

local Archer = _G.class("Archer", Soldier)

Archer.static.SELECTED_SOUNDS = { _G.fx["Archer_Selected_1"], _G.fx["Archer_Selected_2"], _G.fx["Archer_Selected_3"], _G.fx["Archer_Selected_4"], _G.fx["Archer_Selected_5"], _G.fx["Archer_Selected_6"] }
Archer.static.MOVE_SOUNDS = { _G.fx["Archer_Move_1"], _G.fx["Archer_Move_2"], _G.fx["Archer_Move_3"] }
Archer.static.MOVE_INACCESSIBLE_SOUND = _G.fx["Archer_Move_Inaccessible"]

function Archer:initialize(gx, gy)
    Soldier.initialize(self, gx, gy, "Archer")
    self.count = 1
    self.offsetY = -10
    self.offsetX = -6
    self.animated = true
    self.timer = 1
    if love.keyboard.isDown(",") then
        self:usePallete(3)
    else
        self:usePallete(2)
    end
    self.targeted = false
end

function Archer:load(data)
    Object.deserialize(self, data)
    Unit.load(self, data)
    local anData = data.animation
    local callback
    if anData then
        self.animation = anim.newAnimation(an[anData.animationIdentifier], 0.05, callback, anData.animationIdentifier)
        self.animation:deserialize(anData)
    end
end

function Archer:dirSubUpdate()
    local walkAnimationName = "body_archer_walk"
    self.animation = self:getDirectionalAnimation(an, walkAnimationName, 0.08, nil, self.moveDir)
end

function Archer:getClosestAvailableEnemyArchers()
    -- TODO: this is just to test enemy projectiles, remove later
    if self.selectedTarget and self.selectedTarget.health > 0 then return self.selectedTarget end
    for idx, obj in ipairs(_G.state.activeEntities) do
        if obj.class.isSubclassOf and obj.class:isSubclassOf(Soldier) and obj.targeted == false then
            if self.pallete ~= obj.pallete then
                obj.targeted = true
                return obj
            end
        end
    end
end

local hunterFx = {
    ["shoot"] = { _G.fx["arrowshoot1 22k"] },
    ["hit"] = { _G.fx["arrowbasic_01"], _G.fx["arrowbasic_02"] }
}


function Archer:update()
    if self.timer > 0 then
        self.timer = self.timer + _G.dt
        if self.timer > 4 then
            self:findDeer()
        end
    end
    Soldier.update(self)
end

function Archer:damage()
    self.health = self.health - 10
    if self.health < 10 then self.health = 10 end
end

function Archer:findDeer()
    local selectedDeer = self:getClosestAvailableEnemyArchers()
    if not selectedDeer then
        self.timer = 0.1
        return
    end
    self.selectedTarget = selectedDeer

    _G.playSfx(self, hunterFx["shoot"])
    local tx, ty = math.round(selectedDeer.gx), math.round(selectedDeer.gy)
    self.timer = 0.1
    _G.ArrowController:shootArrow(self, tx, ty, function()
        selectedDeer:damage()
        _G.playSfx(selectedDeer, hunterFx["hit"])
        self.timer = 0.1
    end)


    -- self.targetDeer = selectedDeer
    -- self.targetDeer:waitForHunter()
    -- self.endx = selectedDeer.gx
    -- self.endy = selectedDeer.gy + 1
    -- if self.endx == self.gx and self.endy == self.gy then
    --     self.state = "Collecting deer"
    --     self:clearPath()
    --     self:collectDeer()
    --     return
    -- else
    --     self.state = "Walking to deer"
    --     self:setMovementSpeed("walk")
    --     self:requestPath(self.endx, self.endy, function() self:onNoAvailableDeer() end)
    --     return
    -- end
end

function Archer:serialize()
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

return Archer
