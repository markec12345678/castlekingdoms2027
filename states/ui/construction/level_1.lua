local states = require("states.ui.states")
local ab = require("states.ui.action_bar_frames")
local ActionBarButton = require("states.ui.ActionBarButton")
local ActionBar = require("states.ui.ActionBar")
local SID = require("objects.Controllers.LanguageController").lines

local castleButton = ActionBarButton:new(love.graphics.newImage("assets/ui/castle_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 1)
castleButton:setTooltip(SID.groups.castle.name, SID.groups.castle.description)

local hammerButton = ActionBarButton:new(love.graphics.newImage("assets/ui/hammer_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 2)
hammerButton:setTooltip(SID.groups.industry.name, SID.groups.industry.description)

local appleButton = ActionBarButton:new(love.graphics.newImage("assets/ui/apple_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 3)
appleButton:setTooltip(SID.groups.apple.name, SID.groups.apple.description)

local houseButton = ActionBarButton:new(love.graphics.newImage("assets/ui/house_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 4)
houseButton:setTooltip(SID.groups.house.name, SID.groups.house.description)

local shieldButton = ActionBarButton:new(love.graphics.newImage("assets/ui/shield_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 5)
shieldButton:setTooltip(SID.groups.shield.name, SID.groups.shield.description)

local sickleButton = ActionBarButton:new(love.graphics.newImage("assets/ui/sickle_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 6)
shieldButton:setTooltip(SID.groups.sickle.name, SID.groups.sickle.description)

local destroyButton = ActionBarButton:new(love.graphics.newImage("assets/ui/cursor_destroy.png"),
    states.STATE_INGAME_CONSTRUCTION, 11)
destroyButton:setTooltip(SID.groups.destroy.name, SID.groups.destroy.description)
destroyButton:setOnClick(function(self)
    ActionBar:unselectAll()
    local enabled = _G.DestructionController:toggle()
    if enabled then
        destroyButton:setTooltip(SID.groups.destroy.exitTooltip, SID.groups.destroy.exitTooltip)
        ActionBar:selectButton(destroyButton)
    end
end)

destroyButton:setOnUnselect(function(self)
    destroyButton:setTooltip(SID.groups.destroy.name, SID.groups.destroy.description)
    _G.DestructionController:disable()
end)

ActionBar:registerGroup("main",
    { castleButton, hammerButton, appleButton, houseButton, shieldButton, sickleButton, destroyButton })

local backButton = ActionBarButton:new(love.graphics.newImage("assets/ui/back_ab.png"), states.STATE_INGAME_CONSTRUCTION,
    12)
backButton:setOnClick(function(self)
    ActionBar:showGroup("main")
    if not _G.BuildController.start then
        _G.BuildController:disable()
        if _G.BuildController.onBuildCallback then
            _G.BuildController.onBuildCallback()
            _G.BuildController.onBuildCallback = nil
            ActionBar:unselectAll()
        end
    end
end)

ActionBar:showGroup("main")
local elements = {
    buttons = {
        castleButton = castleButton,
        hammerButton = hammerButton,
        appleButton = appleButton,
        houseButton = houseButton,
        shieldButton = shieldButton,
        sickleButton = sickleButton
    },
    parentScale = ab.frFull.scale
}

---@param buildingIndex string
---@param buildingDescription string
---@return table|string
local function getCostAndType(buildId, buildingDescription)
    local buildings = require("objects.buildings")
    if buildId == "Stronghold" then
        return "Not supported yet"
    end
    local c = buildings[buildId].cost
    local costtype = ""
    local fullText = { buildingDescription, "\n" }
    local affordable = true
    local first = true
    if c then
        for type, quantity in pairs(c) do
            if (type == "gold" and quantity > _G.state.gold) or (type ~= "gold" and quantity > _G.state.resources[type]) then
                affordable = false
            else
                affordable = true
            end
            if not first then
                fullText[#fullText + 1] = "\n"
            end
            first = false
            if type == "gold" then
                costtype = " • " .. quantity .. " (" .. _G.state.gold .. ") " .. (SID[type] or type)
            else
                costtype = " • " ..
                    quantity .. " (" .. _G.state.resources[type] .. ") " .. (SID[type] or type)
            end
            if not affordable then
                fullText[#fullText + 1] = { color = { 1, 0, 0, 1 } }
                fullText[#fullText + 1] = costtype
            else
                fullText[#fullText + 1] = { color = { 0.67 + 0.1, 1, 0.57 + 0.1, 1 } }
                fullText[#fullText + 1] = costtype
            end
        end
        return fullText
    end
    return ""
end

---@class Building
---@field button ActionBarButton
---@field id string|nil
---@field name string
---@field description string
---@field tier number
---@field desription string
---@param buildings table<number, Building>
local function setBuildingsTooltips(buildings)
    for _, building in ipairs(buildings) do
        local tooltipText = getCostAndType(building.id or building.name, building.description)
        building.button:setTooltip(building.name, tooltipText)
        if building.tier <= _G.state.tier then
            building.button:enable()
        else
            building.button:disable()
            building.button:setTooltip(SID.tips.upgradeKeep)
        end
    end
end

---@param buttonList table<string, ActionBarButton>
local function disableUnavailableButtons(buttonList)
    local lockedList = _G.MissionController:getLockedBuildings()

    if lockedList ~= nil then
        for _, value in ipairs(lockedList) do
            local button = buttonList[value]
            if button then
                button:disable(SID.tips.notAvailableInMission)
            end
        end
    end
end

package.loaded["states.ui.construction.level_2_castle"] = love.filesystem.load(
    "states/ui/construction/level_2_castle.lua")(elements, backButton, destroyButton, setBuildingsTooltips, disableUnavailableButtons)
package.loaded["states.ui.construction.level_2_farms"] = love.filesystem.load("states/ui/construction/level_2_farms.lua")(
    elements, backButton, destroyButton, setBuildingsTooltips, disableUnavailableButtons)
package.loaded["states.ui.construction.level_2_resource"] = love.filesystem.load(
    "states/ui/construction/level_2_resource.lua")(elements, backButton, destroyButton, setBuildingsTooltips, disableUnavailableButtons)
package.loaded["states.ui.construction.level_2_house"] = love.filesystem.load("states/ui/construction/level_2_house.lua")(
    elements, backButton, destroyButton, setBuildingsTooltips, disableUnavailableButtons)
package.loaded["states.ui.construction.level_2_sickle"] = love.filesystem.load(
    "states/ui/construction/level_2_sickle.lua")(elements, backButton, destroyButton, setBuildingsTooltips, disableUnavailableButtons)
package.loaded["states.ui.construction.level_2_shield"] = love.filesystem.load(
    "states/ui/construction/level_2_shield.lua")(elements, backButton, destroyButton, setBuildingsTooltips, disableUnavailableButtons)
