--                    UNITS UI
local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")
local framesActionBar = require("states.ui.action_bar_frames")
local actionBar = require("states.ui.ActionBar")
local Events = require("objects.Enums.Events")
local scale = actionBar.element.scalex

local group = {}

local ActionBarButton = require("states.ui.ActionBarButton")
local backButton = ActionBarButton:new(love.graphics.newImage("assets/ui/back_ab.png"), states.STATE_UNITS, 12)
backButton:setOnClick(function(self)
    actionBar:switchMode()
end)
actionBar:registerGroup("unitsUI", { backButton })

--LEFT SIDE
--TOP
local idle_icon_hover = love.graphics.newImage("assets/ui/unit_ui/idle_hover.png")
local idle_icon_on = love.graphics.newImage("assets/ui/unit_ui/idle_on.png")
local idle_icon_normal = love.graphics.newImage("assets/ui/unit_ui/idle_normal.png")

local defend_icon_hover = love.graphics.newImage("assets/ui/unit_ui/defend_hover.png")
local defend_icon_on = love.graphics.newImage("assets/ui/unit_ui/defend_on.png")
local defend_icon_normal = love.graphics.newImage("assets/ui/unit_ui/defend_icon_normal.png")

local agr_icon_hover = love.graphics.newImage("assets/ui/unit_ui/agr_hover.png")
local agr_icon_on = love.graphics.newImage("assets/ui/unit_ui/agr_on.png")
local agr_icon_normal = love.graphics.newImage("assets/ui/unit_ui/agr_normal.png")
--BOT
local back_icon = love.graphics.newImage("assets/ui/unit_ui/back_icon.png")
local back_icon_hover = love.graphics.newImage("assets/ui/unit_ui/back_icon_hover.png")
local attack_icon = love.graphics.newImage("assets/ui/unit_ui/attack_icon.png")
local attack_icon_hover = love.graphics.newImage("assets/ui/unit_ui/attack_icon_hover.png")
local build_icon = love.graphics.newImage("assets/ui/unit_ui/build_icon.png")
local build_icon_hover = love.graphics.newImage("assets/ui/unit_ui/build_icon_hover.png")
local cow_icon = love.graphics.newImage("assets/ui/unit_ui/cow_icon.png")
local cow_icon_hover = love.graphics.newImage("assets/ui/unit_ui/cow_icon_hover.png")
local catapult_icon = love.graphics.newImage("assets/ui/unit_ui/catapult_icon.png")
local catapult_icon_hover = love.graphics.newImage("assets/ui/unit_ui/catapult_icon_hover.png")
local dig_icon = love.graphics.newImage("assets/ui/unit_ui/dig_icon.png")
local dig_icon_hover = love.graphics.newImage("assets/ui/unit_ui/dig_icon_hover.png")
local disband_icon = love.graphics.newImage("assets/ui/unit_ui/disband_icon.png")
local disband_icon_hover = love.graphics.newImage("assets/ui/unit_ui/disband_icon_hover.png")
local treb_icon = love.graphics.newImage("assets/ui/unit_ui/treb_icon.png")
local treb_icon_hover = love.graphics.newImage("assets/ui/unit_ui/treb_icon_hover.png")
local tower_icon = love.graphics.newImage("assets/ui/unit_ui/tower_icon.png")
local tower_icon_hover = love.graphics.newImage("assets/ui/unit_ui/tower_icon_hover.png")
local stop_icon = love.graphics.newImage("assets/ui/unit_ui/stop_icon.png")
local stop_icon_hover = love.graphics.newImage("assets/ui/unit_ui/stop_icon_hover.png")
local shield_icon = love.graphics.newImage("assets/ui/unit_ui/shield_icon.png")
local shield_icon_hover = love.graphics.newImage("assets/ui/unit_ui/shield_icon_hover.png")
local ram_icon = love.graphics.newImage("assets/ui/unit_ui/ram_icon.png")
local ram_icon_hover = love.graphics.newImage("assets/ui/unit_ui/ram_icon_hover.png")
local oil_icon = love.graphics.newImage("assets/ui/unit_ui/oil_icon.png")
local oil_icon_hover = love.graphics.newImage("assets/ui/unit_ui/oil_icon_hover.png")
local patrol_icon = love.graphics.newImage("assets/ui/unit_ui/patrol_icon.png")
local patrol_icon_hover = love.graphics.newImage("assets/ui/unit_ui/patrol_icon_hover.png")
local stone_to_projectile_icon = love.graphics.newImage("assets/ui/unit_ui/stone_to_projectile_icon.png")
local stone_to_projectile_hover = love.graphics.newImage("assets/ui/unit_ui/stone_to_projectile_icon_hover.png")

--RIGHT SIDE
local emptyShield = love.graphics.newImage("assets/ui/unit_ui/empty_shield.png")

local archer_shield = love.graphics.newImage("assets/ui/unit_ui/archer_shield.png")
local archer_shield_hover = love.graphics.newImage("assets/ui/unit_ui/archer_shield_hover.png")
local balista_shield = love.graphics.newImage("assets/ui/unit_ui/balista_shield.png")
local balista_shield_hover = love.graphics.newImage("assets/ui/unit_ui/balista_shield_hover.png")
local catapult_shield = love.graphics.newImage("assets/ui/unit_ui/catapult_shield.png")
local catapult_shield_hover = love.graphics.newImage("assets/ui/unit_ui/catapult_shield_hover.png")
local crossbowman_shield = love.graphics.newImage("assets/ui/unit_ui/crossbowman_shield.png")
local crossbowman_shield_hover = love.graphics.newImage("assets/ui/unit_ui/crossbowman_shield_hover.png")
local digger_shield = love.graphics.newImage("assets/ui/unit_ui/digger_shield.png")
local digger_shield_hover = love.graphics.newImage("assets/ui/unit_ui/digger_shield_hover.png")
local eng_shield = love.graphics.newImage("assets/ui/unit_ui/eng_shield.png")
local eng_shield_hover = love.graphics.newImage("assets/ui/unit_ui/eng_shield_hover.png")
local knight_shield = love.graphics.newImage("assets/ui/unit_ui/knight_shield.png")
local knight_shield_hover = love.graphics.newImage("assets/ui/unit_ui/knight_shield_hover.png")
local ladderman_shield = love.graphics.newImage("assets/ui/unit_ui/ladderman_shield.png")
local ladderman_shield_hover = love.graphics.newImage("assets/ui/unit_ui/ladderman_shield_hover.png")
local maceman_shield = love.graphics.newImage("assets/ui/unit_ui/maceman_shield.png")
local maceman_shield_hover = love.graphics.newImage("assets/ui/unit_ui/maceman_shield_hover.png")
local man_shield = love.graphics.newImage("assets/ui/unit_ui/man_shield.png")
local man_shield_hover = love.graphics.newImage("assets/ui/unit_ui/man_shield_hover.png")
local monk_shield = love.graphics.newImage("assets/ui/unit_ui/monk_shield.png")
local monk_shield_hover = love.graphics.newImage("assets/ui/unit_ui/monk_shield_hover.png")
local pikeman_shield = love.graphics.newImage("assets/ui/unit_ui/pikeman_shield.png")
local pikeman_shield_hover = love.graphics.newImage("assets/ui/unit_ui/pikeman_shield_hover.png")
local ram_shield = love.graphics.newImage("assets/ui/unit_ui/ram_shield.png")
local ram_shield_hover = love.graphics.newImage("assets/ui/unit_ui/ram_shield_hover.png")
local shield_shield = love.graphics.newImage("assets/ui/unit_ui/shield_shield.png")
local shield_shield_hover = love.graphics.newImage("assets/ui/unit_ui/shield_shield_hover.png")
local spearman_shield = love.graphics.newImage("assets/ui/unit_ui/spearman_shield.png")
local spearman_shield_hover = love.graphics.newImage("assets/ui/unit_ui/spearman_shield_on.png")
local swordsman_shield = love.graphics.newImage("assets/ui/unit_ui/swordsman_shield.png")
local swordsman_shield_hover = love.graphics.newImage("assets/ui/unit_ui/swordsman_shield_hover.png")
local tower_shield = love.graphics.newImage("assets/ui/unit_ui/tower_shield.png")
local tower_shield_hover = love.graphics.newImage("assets/ui/unit_ui/tower_shield_hover.png")
local treb_shield = love.graphics.newImage("assets/ui/unit_ui/treb_shield.png")
local treb_shield_hover = love.graphics.newImage("assets/ui/unit_ui/treb_shield_hover.png")

local UnitImages = {
    ["Archer"] = archer_shield,
    ["Spearman"] = spearman_shield,
    ["Pikeman"] = pikeman_shield,
    ["Swordsman"] = swordsman_shield,
    ["Crossbowman"] = crossbowman_shield,
    ["Engineer"] = eng_shield,
    ["Ladderman"] = ladderman_shield,
    ["Digger"] = digger_shield,
    ["Monk"] = monk_shield,
    ["Maceman"] = maceman_shield
}

local UnitHoverImages = {
    ["Archer"] = archer_shield_hover,
    ["Spearman"] = spearman_shield_hover,
    ["Pikeman"] = pikeman_shield_hover,
    ["Swordsman"] = swordsman_shield_hover,
    ["Crossbowman"] = crossbowman_shield_hover,
    ["Engineer"] = eng_shield_hover,
    ["Ladderman"] = ladderman_shield_hover,
    ["Digger"] = digger_shield_hover,
    ["Monk"] = monk_shield_hover,
    ["Maceman"] = maceman_shield_hover
}

local frIdleButton = {
    x = framesActionBar.frFull.x + 329 * scale,
    y = framesActionBar.frFull.y + 54 * scale,
    width = idle_icon_on:getWidth() * scale,
    height = idle_icon_on:getHeight() * scale
}

local frDefendButton = {
    x = framesActionBar.frFull.x + 375 * scale,
    y = framesActionBar.frFull.y + 69 * scale,
    width = defend_icon_on:getWidth() * scale,
    height = defend_icon_on:getHeight() * scale
}

local frAgrButton = {
    x = framesActionBar.frFull.x + 415 * scale,
    y = framesActionBar.frFull.y + 65 * scale,
    width = agr_icon_on:getWidth() * scale,
    height = agr_icon_on:getHeight() * scale
}
-- top left
local frTopLeft = {
    x = framesActionBar.frFull.x + 334 * scale,
    y = framesActionBar.frFull.y + 119 * scale,
    width = disband_icon:getWidth() * scale,
    height = disband_icon:getHeight() * scale
}
-- top mid
local frTopMid = {
    x = framesActionBar.frFull.x + 375 * scale,
    y = framesActionBar.frFull.y + 119 * scale,
    width = disband_icon:getWidth() * scale,
    height = disband_icon:getHeight() * scale
}
-- top right
local frTopRight = {
    x = framesActionBar.frFull.x + 416 * scale,
    y = framesActionBar.frFull.y + 119 * scale,
    width = disband_icon:getWidth() * scale,
    height = disband_icon:getHeight() * scale
}
-- bot left
local frBotLeft = {
    x = framesActionBar.frFull.x + 334 * scale,
    y = framesActionBar.frFull.y + 160 * scale,
    width = disband_icon:getWidth() * scale,
    height = disband_icon:getHeight() * scale
}
-- bot mid
local frBotMid = {
    x = framesActionBar.frFull.x + 375 * scale,
    y = framesActionBar.frFull.y + 160 * scale,
    width = disband_icon:getWidth() * scale,
    height = disband_icon:getHeight() * scale
}
-- bot right
local frBotRight = {
    x = framesActionBar.frFull.x + 416 * scale,
    y = framesActionBar.frFull.y + 160 * scale,
    width = disband_icon:getWidth() * scale,
    height = disband_icon:getHeight() * scale
}
local frShields = {
    {
        x = framesActionBar.frFull.x + 471 * scale,
        y = framesActionBar.frFull.y + 89 * scale,
        width = emptyShield:getWidth() * scale,
        height = emptyShield:getHeight() * scale
    },
    {
        x = framesActionBar.frFull.x + (471 + 51) * scale,
        y = framesActionBar.frFull.y + 89 * scale,
        width = emptyShield:getWidth() * scale,
        height = emptyShield:getHeight() * scale
    },
    {
        x = framesActionBar.frFull.x + (473 + 51 * 2) * scale,
        y = framesActionBar.frFull.y + 89 * scale,
        width = emptyShield:getWidth() * scale,
        height = emptyShield:getHeight() * scale
    },
    {
        x = framesActionBar.frFull.x + (473 + 51 * 3) * scale,
        y = framesActionBar.frFull.y + 89 * scale,
        width = emptyShield:getWidth() * scale,
        height = emptyShield:getHeight() * scale
    },
    {
        x = framesActionBar.frFull.x + (473 + 51 * 4) * scale,
        y = framesActionBar.frFull.y + 89 * scale,
        width = emptyShield:getWidth() * scale,
        height = emptyShield:getHeight() * scale
    },
    {
        x = framesActionBar.frFull.x + (473 + 51 * 5) * scale,
        y = framesActionBar.frFull.y + 89 * scale,
        width = emptyShield:getWidth() * scale,
        height = emptyShield:getHeight() * scale
    },
    {
        x = framesActionBar.frFull.x + (473 + 51 * 6) * scale,
        y = framesActionBar.frFull.y + 89 * scale,
        width = emptyShield:getWidth() * scale,
        height = emptyShield:getHeight() * scale
    },
    {
        x = framesActionBar.frFull.x + (473 + 51 * 7) * scale,
        y = framesActionBar.frFull.y + 89 * scale,
        width = emptyShield:getWidth() * scale,
        height = emptyShield:getHeight() * scale
    },
}

local isIdle = false
local isDef = false
local isAgr = false
local isOn = false

--TOP LEFT
local idleIconButton = loveframes.Create("image")
local defendIconButton = loveframes.Create("image")
local agrIconButton = loveframes.Create("image")
--BOT LEFT first row
local disbandIconButton = loveframes.Create("image")
local stopIconButton = loveframes.Create("image")
local patrolIconButton = loveframes.Create("image")
--BOT LEFT second row
local attackIconButton = loveframes.Create("image")
local digIconButton = loveframes.Create("image")
local buildIconButton = loveframes.Create("image")
local oilIconButton = loveframes.Create("image")
-- ENG sub menu
local catIconButton = loveframes.Create("image")
local trebIconButton = loveframes.Create("image")
local towerIconButton = loveframes.Create("image")
local ramIconButton = loveframes.Create("image")
local shieldIconButton = loveframes.Create("image")
local backIconButton = loveframes.Create("image")
-- CATAPULT/TREB icons
local cowIconButton = loveframes.Create("image")
local stoneToProjectileIconButton = loveframes.Create("image")

local defaultIcons = {
    disband = disbandIconButton,
    stop = stopIconButton,
    patrol = patrolIconButton,
    attack = attackIconButton
}
local actionIcons = {
    disband = disbandIconButton,
    stop = stopIconButton,
    patrol = patrolIconButton,
    attack = attackIconButton,
    dig = digIconButton,
    back = backIconButton,
    build = buildIconButton,
    cat = catIconButton,
    treb = trebIconButton,
    tower = towerIconButton,
    ram = ramIconButton,
    shield = shieldIconButton,
    cow = cowIconButton,
    stone = stoneToProjectileIconButton,
    oil = oilIconButton
}
--SHIELDS
local shields = {}
for idx, fr in ipairs(frShields) do
    local shield = loveframes.Create("image")
    shield:SetState(states.STATE_UNITS)
    shield:SetImage(emptyShield)
    shield.hoverImage = emptyShield
    shield.defaultImage = emptyShield
    shield:SetScaleY(scale)
    shield:SetScaleX(scale)
    shield:SetPos(fr.x, fr.y)
    shield.OnMouseEnter = function(self)
        self:SetImage(self.hoverImage)
    end
    shield.OnMouseExit = function(self)
        self:SetImage(self.defaultImage)
    end
    shields[idx] = shield
end

local unitCounts = {}
local frUnitCount = {}
for idx, v in ipairs(frShields) do
    local fr = {
        x = v.x + v.width / 2,
        y = v.y + v.height,
        width = v.width,
        height = v.height
    }
    frUnitCount[idx] = fr

    local text = loveframes.Create("text")
    text:SetState(states.STATE_UNITS)
    text:SetText("")
    text:SetFont(loveframes.font_times_new_normal_large)
    text:SetPos(fr.x, fr.y)
    text:SetShadow(false)
    unitCounts[idx] = text
end

local function clearSelection()
    -- reset shields and text
    for i, shield in ipairs(shields) do
        shield:SetImage(emptyShield)
        shield.hoverImage = emptyShield
        shield.defaultImage = emptyShield
        shield:SetScaleY(scale)
        shield:SetScaleX(scale)
        shield.OnClick = function()
        end
        unitCounts[i]:SetText("")
    end
end

_G.bus.on(Events.OnUnitsDeselected, function()
    if (loveframes.GetState() == states.STATE_UNITS) then
        clearSelection()
        local ActionBar = require("states.ui.ActionBar")
        ActionBar:switchMode()
    end
end)

local function HideIcons()
    for _, button in pairs(actionIcons) do
        button:SetVisible(false)
    end
end

local function DisplayDefaultIcons(option)
    option = (option ~= false)
    for _, button in pairs(defaultIcons) do
        button:SetVisible(option)
    end
end

local function ShowEngMenu()
    HideIcons()
    catIconButton:SetVisible(true)
    trebIconButton:SetVisible(true)
    towerIconButton:SetVisible(true)
    ramIconButton:SetVisible(true)
    shieldIconButton:SetVisible(true)
    backIconButton:SetVisible(true)
end

local function IconOperator(unit)
    --hide every icon
    HideIcons()
    --DEFUALT ICON GROUP (disband,stop,patrol,attack)
    --Archer/Spearman/Maceman/Crossbowman/Pikeman/Swordsman/Knight/Monk/Ladderman/Machines(except cat/treb)

    DisplayDefaultIcons(true)

    --Digger (dig icon)
    if unit == "Digger" then
        digIconButton:SetVisible(true)
    end
    --Engineer (build icon) + oil
    if unit == "Engineer" then
        attackIconButton:SetVisible(false)
        buildIconButton:SetVisible(true)
        --if has oil
        oilIconButton:SetVisible(true)
    end
    --Cat/Treb (stone to projectile icon, cow icon)
    if unit == "Catapult" then
        stoneToProjectileIconButton:SetVisible(true)
        cowIconButton:SetVisible(true)
    end
end

local colorWhite = { 1, 1, 1, 1 }
_G.bus.on(Events.OnUnitsSelected, function(selectedUnitsByType)
    clearSelection()
    local idx = 1
    for unitType, units in pairs(selectedUnitsByType) do
        local shield = shields[idx]
        if shield then
            shield.hoverImage = UnitHoverImages[unitType]
            shield.defaultImage = UnitImages[unitType]
            shield:SetImage(UnitImages[unitType])
            shield:SetOffsetY(-(emptyShield:getHeight() - shield.defaultImage:getHeight()) * scale)
            shield.OnClick = function(self)
                _G.Commander.selectedUnits = units
                _G.Commander.selectedUnitsByType = {
                    [unitType] = units
                }
                _G.bus.emit(Events.OnUnitsSelected, _G.Commander.selectedUnitsByType)
            end
            unitCounts[idx]:SetText({ {
                color = colorWhite
            }, tostring(#units) })
            unitCounts[idx]:SetX(frUnitCount[idx].x - unitCounts[idx].font:getWidth(tostring(#units)))
            idx = idx + 1
            IconOperator(unitType)
        end
    end
    local ActionBar = require("states.ui.ActionBar")
    if (loveframes.GetState() ~= states.STATE_UNITS) then
        ActionBar:switchMode("unitsUI")
    end
end)

idleIconButton:SetState(states.STATE_UNITS)
idleIconButton:SetImage(idle_icon_normal)
idleIconButton:SetScaleX(frIdleButton.width / idleIconButton:GetImageWidth())
idleIconButton:SetScaleY(idleIconButton:GetScaleX())
idleIconButton:SetPos(frIdleButton.x, frIdleButton.y)
idleIconButton.OnMouseEnter = function(self)
    if isIdle == false then
        self:SetImage(idle_icon_hover)
    end
end
idleIconButton.OnMouseDown = function(self)
    self:SetImage(idle_icon_on)
end
idleIconButton.OnClick = function(self)
    if isIdle == false then
        self:SetImage(idle_icon_on)
        isIdle = true
        isDef = false
        isAgr = false
        isOn = true
        defendIconButton:SetImage(defend_icon_normal)
        agrIconButton:SetImage(agr_icon_normal)
    end
end
idleIconButton.OnMouseExit = function(self)
    if isIdle == false then
        self:SetImage(idle_icon_normal)
    else
        self:SetImage(idle_icon_on)
    end
end

defendIconButton:SetState(states.STATE_UNITS)
defendIconButton:SetImage(defend_icon_normal)
defendIconButton:SetScaleX(frDefendButton.width / defendIconButton:GetImageWidth())
defendIconButton:SetScaleY(defendIconButton:GetScaleX())
defendIconButton:SetPos(frDefendButton.x, frDefendButton.y)
defendIconButton.OnMouseEnter = function(self)
    if isDef == false then
        self:SetImage(defend_icon_hover)
    end
end
defendIconButton.OnMouseDown = function(self)
    self:SetImage(defend_icon_on)
end
defendIconButton.OnClick = function(self)
    if isDef == false then
        self:SetImage(defend_icon_on)
        isIdle = false
        isDef = true
        isAgr = false
        isOn = true
        idleIconButton:SetImage(idle_icon_normal)
        agrIconButton:SetImage(agr_icon_normal)
    end
end
defendIconButton.OnMouseExit = function(self)
    if isDef == false then
        self:SetImage(defend_icon_normal)
    else
        self:SetImage(defend_icon_on)
    end
end

agrIconButton:SetState(states.STATE_UNITS)
agrIconButton:SetImage(agr_icon_normal)
agrIconButton:SetScaleX(frAgrButton.width / agrIconButton:GetImageWidth())
agrIconButton:SetScaleY(agrIconButton:GetScaleX())
agrIconButton:SetPos(frAgrButton.x, frAgrButton.y)
agrIconButton.OnMouseEnter = function(self)
    if isAgr == false then
        self:SetImage(agr_icon_hover)
    end
end
agrIconButton.OnMouseDown = function(self)
    self:SetImage(agr_icon_on)
end
agrIconButton.OnClick = function(self)
    if isAgr == false then
        self:SetImage(agr_icon_on)
        isIdle = false
        isDef = false
        isAgr = true
        isOn = true
        idleIconButton:SetImage(idle_icon_normal)
        defendIconButton:SetImage(defend_icon_normal)
    end
end
agrIconButton.OnMouseExit = function(self)
    if isAgr == false then
        self:SetImage(agr_icon_normal)
    else
        self:SetImage(agr_icon_on)
    end
end

disbandIconButton:SetState(states.STATE_UNITS)
disbandIconButton:SetImage(disband_icon)
disbandIconButton:SetScaleX(frTopLeft.width / disbandIconButton:GetImageWidth())
disbandIconButton:SetScaleY(disbandIconButton:GetScaleX())
disbandIconButton:SetPos(frTopLeft.x, frTopLeft.y)
disbandIconButton.OnMouseEnter = function(self)
    self:SetImage(disband_icon_hover)
end
disbandIconButton.OnClick = function(self)
    --
end
disbandIconButton.OnMouseExit = function(self)
    self:SetImage(disband_icon)
end

stopIconButton:SetState(states.STATE_UNITS)
stopIconButton:SetImage(stop_icon)
stopIconButton:SetScaleX(frTopMid.width / stopIconButton:GetImageWidth())
stopIconButton:SetScaleY(stopIconButton:GetScaleX())
stopIconButton:SetPos(frTopMid.x, frTopMid.y)
stopIconButton.OnMouseEnter = function(self)
    self:SetImage(stop_icon_hover)
end
stopIconButton.OnClick = function(self)
    --
end
stopIconButton.OnMouseExit = function(self)
    self:SetImage(stop_icon)
end

patrolIconButton:SetState(states.STATE_UNITS)
patrolIconButton:SetImage(patrol_icon)
patrolIconButton:SetScaleX(frTopRight.width / patrolIconButton:GetImageWidth())
patrolIconButton:SetScaleY(patrolIconButton:GetScaleX())
patrolIconButton:SetPos(frTopRight.x, frTopRight.y)
patrolIconButton.OnMouseEnter = function(self)
    self:SetImage(patrol_icon_hover)
end
patrolIconButton.OnClick = function(self)
    --
end
patrolIconButton.OnMouseExit = function(self)
    self:SetImage(patrol_icon)
end

attackIconButton:SetState(states.STATE_UNITS)
attackIconButton:SetImage(attack_icon)
attackIconButton:SetScaleX(frBotLeft.width / attackIconButton:GetImageWidth())
attackIconButton:SetScaleY(attackIconButton:GetScaleX())
attackIconButton:SetPos(frBotLeft.x, frBotLeft.y)
attackIconButton.OnMouseEnter = function(self)
    self:SetImage(attack_icon_hover)
end
attackIconButton.OnClick = function(self)
    --
end
attackIconButton.OnMouseExit = function(self)
    self:SetImage(attack_icon)
end

digIconButton:SetState(states.STATE_UNITS)
digIconButton:SetImage(dig_icon)
digIconButton:SetScaleX(frBotMid.width / digIconButton:GetImageWidth())
digIconButton:SetScaleY(digIconButton:GetScaleX())
digIconButton:SetPos(frBotMid.x, frBotMid.y)
digIconButton.OnMouseEnter = function(self)
    self:SetImage(dig_icon_hover)
end
digIconButton.OnClick = function(self)
    --
end
digIconButton.OnMouseExit = function(self)
    self:SetImage(dig_icon)
end

buildIconButton:SetState(states.STATE_UNITS)
buildIconButton:SetImage(build_icon)
buildIconButton:SetScaleX(frBotMid.width / buildIconButton:GetImageWidth())
buildIconButton:SetScaleY(buildIconButton:GetScaleX())
buildIconButton:SetPos(frBotMid.x, frBotMid.y)
buildIconButton.OnMouseEnter = function(self)
    self:SetImage(build_icon_hover)
end
buildIconButton.OnClick = function(self)
    ShowEngMenu()
end
buildIconButton.OnMouseExit = function(self)
    self:SetImage(build_icon)
end

--Eng sub menu
catIconButton:SetState(states.STATE_UNITS)
catIconButton:SetImage(catapult_icon)
catIconButton:SetScaleX(frTopLeft.width / catIconButton:GetImageWidth())
catIconButton:SetScaleY(catIconButton:GetScaleX())
catIconButton:SetPos(frTopLeft.x, frTopLeft.y)
catIconButton.OnMouseEnter = function(self)
    self:SetImage(catapult_icon_hover)
end
catIconButton.OnClick = function(self)
    --
end
catIconButton.OnMouseExit = function(self)
    self:SetImage(catapult_icon)
end

trebIconButton:SetState(states.STATE_UNITS)
trebIconButton:SetImage(treb_icon)
trebIconButton:SetScaleX(frTopMid.width / trebIconButton:GetImageWidth())
trebIconButton:SetScaleY(trebIconButton:GetScaleX())
trebIconButton:SetPos(frTopMid.x, frTopMid.y)
trebIconButton.OnMouseEnter = function(self)
    self:SetImage(treb_icon_hover)
end
trebIconButton.OnClick = function(self)
    --
end
trebIconButton.OnMouseExit = function(self)
    self:SetImage(treb_icon)
end

towerIconButton:SetState(states.STATE_UNITS)
towerIconButton:SetImage(tower_icon)
towerIconButton:SetScaleX(frTopRight.width / towerIconButton:GetImageWidth())
towerIconButton:SetScaleY(towerIconButton:GetScaleX())
towerIconButton:SetPos(frTopRight.x, frTopRight.y)
towerIconButton.OnMouseEnter = function(self)
    self:SetImage(tower_icon_hover)
end
towerIconButton.OnClick = function(self)
    --
end
towerIconButton.OnMouseExit = function(self)
    self:SetImage(tower_icon)
end

ramIconButton:SetState(states.STATE_UNITS)
ramIconButton:SetImage(ram_icon)
ramIconButton:SetScaleX(frBotLeft.width / ramIconButton:GetImageWidth())
ramIconButton:SetScaleY(ramIconButton:GetScaleX())
ramIconButton:SetPos(frBotLeft.x, frBotLeft.y)
ramIconButton.OnMouseEnter = function(self)
    self:SetImage(ram_icon_hover)
end
ramIconButton.OnClick = function(self)
    --
end
ramIconButton.OnMouseExit = function(self)
    self:SetImage(ram_icon)
end

shieldIconButton:SetState(states.STATE_UNITS)
shieldIconButton:SetImage(shield_icon)
shieldIconButton:SetScaleX(frBotMid.width / shieldIconButton:GetImageWidth())
shieldIconButton:SetScaleY(shieldIconButton:GetScaleX())
shieldIconButton:SetPos(frBotMid.x, frBotMid.y)
shieldIconButton.OnMouseEnter = function(self)
    self:SetImage(shield_icon_hover)
end
shieldIconButton.OnClick = function(self)
    --
end
shieldIconButton.OnMouseExit = function(self)
    self:SetImage(shield_icon)
end

backIconButton:SetState(states.STATE_UNITS)
backIconButton:SetImage(back_icon)
backIconButton:SetScaleX(frBotRight.width / backIconButton:GetImageWidth())
backIconButton:SetScaleY(backIconButton:GetScaleX())
backIconButton:SetPos(frBotRight.x, frBotRight.y)
backIconButton.OnMouseEnter = function(self)
    self:SetImage(back_icon_hover)
end
backIconButton.OnClick = function(self)
    IconOperator("Engineer")
end
backIconButton.OnMouseExit = function(self)
    self:SetImage(back_icon)
end

oilIconButton:SetState(states.STATE_UNITS)
oilIconButton:SetImage(oil_icon)
oilIconButton:SetScaleX(frBotLeft.width / oilIconButton:GetImageWidth())
oilIconButton:SetScaleY(oilIconButton:GetScaleX())
oilIconButton:SetPos(frBotLeft.x, frBotLeft.y)
oilIconButton.OnMouseEnter = function(self)
    self:SetImage(oil_icon_hover)
end
oilIconButton.OnClick = function(self)
    --
end
oilIconButton.OnMouseExit = function(self)
    self:SetImage(oil_icon)
end

stoneToProjectileIconButton:SetState(states.STATE_UNITS)
stoneToProjectileIconButton:SetImage(stone_to_projectile_icon)
stoneToProjectileIconButton:SetScaleX(frBotMid.width / stoneToProjectileIconButton:GetImageWidth())
stoneToProjectileIconButton:SetScaleY(stoneToProjectileIconButton:GetScaleX())
stoneToProjectileIconButton:SetPos(frBotMid.x, frBotMid.y)
stoneToProjectileIconButton.OnMouseEnter = function(self)
    self:SetImage(stone_to_projectile_hover)
end
stoneToProjectileIconButton.OnClick = function(self)
    --
end
stoneToProjectileIconButton.OnMouseExit = function(self)
    self:SetImage(stone_to_projectile_icon)
end

cowIconButton:SetState(states.STATE_UNITS)
cowIconButton:SetImage(cow_icon)
cowIconButton:SetScaleX(frBotRight.width / cowIconButton:GetImageWidth())
cowIconButton:SetScaleY(cowIconButton:GetScaleX())
cowIconButton:SetPos(frBotRight.x, frBotRight.y)
cowIconButton.OnMouseEnter = function(self)
    self:SetImage(cow_icon_hover)
end
cowIconButton.OnClick = function(self)
    --
end
cowIconButton.OnMouseExit = function(self)
    self:SetImage(cow_icon)
end


return group
