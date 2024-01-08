local freebuildFrames = require("states.ui.economic.frames")
local frames, scale = freebuildFrames[1], freebuildFrames[2]
local loveframes = require("libraries.loveframes")
local base = require("states.ui.base")
local states = require("states.ui.states")
local config = require("config_file")
local Events = require("objects.Enums.Events")

local bitser = require("libraries.bitser")
local path = "CampaignData.bin"
local missionsCompleted = { true, false, false, false, false }

if love.filesystem.getInfo(path) ~= nil then
    local campaignDataLoaded = bitser.loadLoveFile(path)
    local currentMissionLoaded = campaignDataLoaded.currentMission
    missionsCompleted = campaignDataLoaded.missionsCompleted
    print("Current mission:", currentMissionLoaded)
    print("Finished missions:", unpack(missionsCompleted))
end

local windowTitleText = loveframes.Create("text")
windowTitleText:SetState(states.STATE_ECONOMIC_MISSION_PICKER)
windowTitleText:SetFont(loveframes.font_vera_bold_large)
windowTitleText:SetShadow(true)
windowTitleText:SetPos(frames["frTitle"].x, frames["frTitle"].y)
windowTitleText:SetShadowColor(0.35, 0.3, 0.26, 1)

local frStartButton = frames["frStart"]
local buttonStartImage = love.graphics.newImage("assets/ui/freebuild/start.png")
local buttonStartHoverImage = love.graphics.newImage("assets/ui/freebuild/start_hover.png")
local buttonStart = loveframes.Create("image")
buttonStart:SetState(states.STATE_ECONOMIC_MISSION_PICKER)
buttonStart:SetImage(buttonStartImage)
buttonStart:SetScaleX(frStartButton.width / buttonStartImage:getWidth())
buttonStart:SetScaleY(buttonStart:GetScaleX())
buttonStart:SetPos(frStartButton.x, frStartButton.y)
buttonStart.OnMouseEnter = function(self)
    buttonStart:SetImage(buttonStartHoverImage)
end
buttonStart.OnClick = function(self)
    _G.playSpeech("General_Loading")
    _G.loaded = false
    if _G.state then _G.state:destroy() end
    local State = require("objects.State")
    _G.state = State:new()
    _G.state.missionNr = buttonStart.missionNumber
    _G.state.initialized = false
    loveframes.SetState()
    local Gamestate = require("libraries.gamestate")
    local game = require("states.game")
    local SaveManager = require("objects.Controllers.SaveManager")
    Gamestate.switch(game, SaveManager.defaultMap.name)
end
buttonStart.OnMouseExit = function(self)
    buttonStart:SetImage(buttonStartImage)
end
buttonStart:SetVisible(false)

local titleText = loveframes.Create("text")
titleText:SetState(states.STATE_ECONOMIC_MISSION_PICKER)
titleText:SetFont(loveframes.font_times_new_normal_large_48)
titleText:SetPos(frames["frTitle"].x, frames["frTitle"].y)

local descriptionText = loveframes.Create("text")
descriptionText:SetState(states.STATE_ECONOMIC_MISSION_PICKER)
descriptionText:SetFont(loveframes.basicfontmedium)
descriptionText:SetPos(frames["frDescription"].x, frames["frDescription"].y)
descriptionText:SetMaxWidth(frames["frDescription"].width)

local MissionListButton = require("states.ui.economic.MissionListButton")
local mapList = {}
local callback = function(element)
    for _, item in ipairs(mapList) do
        if element ~= item then item:unselect() end
    end
end

_G.bus.on(Events.OnMissionCompleted, function(name)
    local missionNumber = tonumber(name:gsub("%D", ""))
    if missionNumber ~= 5 then
        mapList[missionNumber + 1].unlocked = true
    end
end)

local mission1 = require("saves.Missions.mission1")
mapList[#mapList + 1] =
    MissionListButton:new(
        #mapList + 1,
        "mission1",
        callback,
        states.STATE_ECONOMIC_MISSION_PICKER,
        frames.frListItem_1,
        -- TODO: load the description and image from the map metadata
        {
            name = mission1.name,
            description = mission1.description,
        },
        buttonStart,
        titleText,
        descriptionText,
        true
    )
local mission2 = require("saves.Missions.mission2")
mapList[#mapList + 1] = MissionListButton:new(
    #mapList + 1,
    "mission2",
    callback,
    states.STATE_ECONOMIC_MISSION_PICKER,
    frames.frListItem_2,
    {
        name = mission2.name,
        description = mission2.description,
    },
    buttonStart,
    titleText,
    descriptionText,
    missionsCompleted[2]
)
local mission3 = require("saves.Missions.mission3")
mapList[#mapList + 1] = MissionListButton:new(
    #mapList + 1,
    "mission3",
    callback,
    states.STATE_ECONOMIC_MISSION_PICKER,
    frames.frListItem_3,
    {
        name = mission3.name,
        description = mission3.description,
    },
    buttonStart,
    titleText,
    descriptionText,
    missionsCompleted[3]
)
local mission4 = require("saves.Missions.mission4")
mapList[#mapList + 1] = MissionListButton:new(
    #mapList + 1,
    "mission4",
    callback,
    states.STATE_ECONOMIC_MISSION_PICKER,
    frames.frListItem_4,
    {
        name = mission4.name,
        description = mission4.description,
    },
    buttonStart,
    titleText,
    descriptionText,
    missionsCompleted[4]
)
local mission5 = require("saves.Missions.mission5")
mapList[#mapList + 1] = MissionListButton:new(
    #mapList + 1,
    "mission5",
    callback,
    states.STATE_ECONOMIC_MISSION_PICKER,
    frames.frListItem_5,
    {
        name = mission5.name,
        description = mission5.description,
    },
    buttonStart,
    titleText,
    descriptionText,
    missionsCompleted[5]
)


local closeWindowButtonImage = love.graphics.newImage("assets/ui/close_window_normal.png")
local closeWindowButtonImageHover = love.graphics.newImage("assets/ui/close_window_hover.png")
local closeWindowButtonImageDown = love.graphics.newImage("assets/ui/close_window_down.png")

local frCloseButton = {
    x = frames["frWindow"].x + 957 * scale,
    y = frames["frWindow"].y + 34 * scale,
    width = closeWindowButtonImage:getWidth() * scale,
    height = closeWindowButtonImage:getHeight() * scale
}
local closeWindowButton = loveframes.Create("image")
closeWindowButton:SetState(states.STATE_ECONOMIC_MISSION_PICKER)
closeWindowButton:SetImage(closeWindowButtonImage)
closeWindowButton:SetScaleX(frCloseButton.width / closeWindowButton:GetImageWidth())
closeWindowButton:SetScaleY(closeWindowButton:GetScaleX())
closeWindowButton:SetPos(frCloseButton.x, frCloseButton.y)
closeWindowButton.OnMouseEnter = function(self)
    self:SetImage(closeWindowButtonImageHover)
end
closeWindowButton.OnMouseDown = function(self)
    self:SetImage(closeWindowButtonImageDown)
end
closeWindowButton.Update = function(self)
    if love.keyboard.isDown("escape") then
        self:OnClick()
    end
end
closeWindowButton.OnClick = function(self)
    local Gamestate = require("libraries.gamestate")
    config:save(config)
    if Gamestate.current() == require("states.start_menu") then
        loveframes.SetState(states.STATE_MAIN_MENU)
    elseif Gamestate.current() == require("states.game") then
        loveframes.SetState(states.STATE_PAUSE_MENU)
    end
end
closeWindowButton.OnMouseExit = function(self)
    self:SetImage(closeWindowButtonImage)
end

return frames
