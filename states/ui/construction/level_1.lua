local states = require("states.ui.states")
local ab = require("states.ui.action_bar_frames")
local ActionBarButton = require("states.ui.ActionBarButton")
local ActionBar = require("states.ui.ActionBar")

local castleButton = ActionBarButton:new(love.graphics.newImage("assets/ui/castle_ab.png"), states.STATE_INGAME_CONSTRUCTION, 1)
castleButton:setTooltip("Castle", "Walls, Towers, Gates and everything else you need to defend your Stronghold.")

local hammerButton = ActionBarButton:new(love.graphics.newImage("assets/ui/hammer_ab.png"), states.STATE_INGAME_CONSTRUCTION, 2)
hammerButton:setTooltip("Industry", "Build mighty Industries to defeat your enemies ... or fill your pockets.")

local appleButton = ActionBarButton:new(love.graphics.newImage("assets/ui/apple_ab.png"), states.STATE_INGAME_CONSTRUCTION, 3)
appleButton:setTooltip("Farms", "Produce basic agricultural products.")

local houseButton = ActionBarButton:new(love.graphics.newImage("assets/ui/house_ab.png"), states.STATE_INGAME_CONSTRUCTION, 4)
houseButton:setTooltip("Civillian", "Houses and amenities for your citizens.")

local shieldButton = ActionBarButton:new(love.graphics.newImage("assets/ui/shield_ab.png"), states.STATE_INGAME_CONSTRUCTION, 5, nil, nil, true)
shieldButton:setTooltip("Military", "Raise mighty armies and build terrifying siege weapons to crush your enemies.")

local sickleButton = ActionBarButton:new(love.graphics.newImage("assets/ui/sickle_ab.png"), states.STATE_INGAME_CONSTRUCTION, 6)
sickleButton:setTooltip("Food Production", "Turn basic farm products into high quality goods.")

local destroyButton = ActionBarButton:new(love.graphics.newImage("assets/ui/cursor_destroy.png"), states.STATE_INGAME_CONSTRUCTION, 11)
destroyButton:setTooltip("Demolish", "Enter demolish mode. Click on a building to destroy.")

destroyButton:setOnClick(function(self)
    ActionBar:unselectAll()
    local enabled = _G.DestructionController:toggle()
    if enabled then
        destroyButton:setTooltip("Exit Demolish Mode", "Exit demolish mode.")
        ActionBar:selectButton(destroyButton)
    end
end)

destroyButton:setOnUnselect(function(self)
    destroyButton:setTooltip("Demolish Mode", "Enter demolish mode. Click on a building to destroy.")
    _G.DestructionController:disable()
end)

ActionBar:registerGroup("main", {castleButton, hammerButton, appleButton, houseButton, shieldButton, sickleButton, destroyButton})

local backButton = ActionBarButton:new(love.graphics.newImage("assets/ui/back_ab.png"), states.STATE_INGAME_CONSTRUCTION, 12)
backButton:setOnClick(function(self)
    ActionBar:showGroup("main")
    if not _G.BuildController.start then
        _G.BuildController.active = false
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

--- @type fun(buildingIndex: string): string
local function getCostAndType(buildingIndex)
    local buildings = require("objects.buildings")
    local c = buildings.getCost(buildingIndex);
    local costAndType = ""
    local costtype = ""
    local first = true
    if c then
        for type, quantity in pairs(c) do
            print(type, quantity)
            if first then
                costtype = costtype .. quantity .. " " .. type
                first = false
            else
                costtype = costtype .. ", " .. quantity .. " " .. type
            end
        end
        costAndType = "Requires " .. costtype
    end
    return costAndType
end

package.loaded["states.ui.construction.level_2_castle"] = love.filesystem.load("states/ui/construction/level_2_castle.lua")(elements, backButton, destroyButton, getCostAndType)
package.loaded["states.ui.construction.level_2_farms"] = love.filesystem.load("states/ui/construction/level_2_farms.lua")(elements, backButton, destroyButton, getCostAndType)
package.loaded["states.ui.construction.level_2_resource"] = love.filesystem.load("states/ui/construction/level_2_resource.lua")(elements, backButton, destroyButton, getCostAndType)
package.loaded["states.ui.construction.level_2_house"] = love.filesystem.load("states/ui/construction/level_2_house.lua")(elements, backButton, destroyButton, getCostAndType)
package.loaded["states.ui.construction.level_2_sickle"] = love.filesystem.load("states/ui/construction/level_2_sickle.lua")(elements, backButton, destroyButton, getCostAndType)
