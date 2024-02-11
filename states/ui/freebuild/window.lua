local freebuildFrames = require("states.ui.freebuild.frames")
local frames, scale = freebuildFrames[1], freebuildFrames[2]
local loveframes = require("libraries.loveframes")
local base = require("states.ui.base")
local states = require("states.ui.states")
local config = require("config_file")
local SID = require("objects.Controllers.LanguageController").lines

local windowTitleText = loveframes.Create("text")
windowTitleText:SetState(states.STATE_FREE_BUILD_WINDOW)
windowTitleText:SetFont(loveframes.font_vera_bold_large)
windowTitleText:SetShadow(true)
windowTitleText:SetPos(frames["frTitle"].x, frames["frTitle"].y)
windowTitleText:SetShadowColor(0.35, 0.3, 0.26, 1)

local frStartButton = frames["frStart"]
local buttonStart = loveframes.Create("button")
buttonStart:SetState(states.STATE_FREE_BUILD_WINDOW)
buttonStart:SetPos(frStartButton.x, frStartButton.y)
buttonStart:SetSize(frStartButton.width * scale, math.min(53, 53 * scale))
buttonStart:SetText(SID.ui.global.start)
buttonStart:SetSkin("StoneKingdoms")
buttonStart.OnClick = function(self)
    _G.playSpeech("General_Loading")
    _G.loaded = false
    if _G.state then _G.state:destroy() end
    local State = require("objects.State")
    _G.state = State:new()
    if _G.state then _G.state.initialized = false end
    loveframes.SetState()
    local Gamestate = require("libraries.gamestate")
    local game = require("states.game")
    local SaveManager = require("objects.Controllers.SaveManager")
    Gamestate.switch(game, SaveManager.defaultMap.name)
end
buttonStart:SetVisible(false)


local titleText = loveframes.Create("text")
titleText:SetState(states.STATE_FREE_BUILD_WINDOW)
titleText:SetFont(loveframes.font_times_new_normal_large_48)
titleText:SetPos(frames["frTitle"].x, frames["frTitle"].y)

local descriptionText = loveframes.Create("text")
descriptionText:SetState(states.STATE_FREE_BUILD_WINDOW)
descriptionText:SetFont(loveframes.basicfontmedium)
descriptionText:SetPos(frames["frDescription"].x, frames["frDescription"].y)
descriptionText:SetMaxWidth(frames["frDescription"].width)

local previewImageElement = loveframes.Create("image")
previewImageElement:SetState(states.STATE_FREE_BUILD_WINDOW)
previewImageElement:SetImage()
previewImageElement:SetPos(frames["frMapPreview"].x, frames["frMapPreview"].y)


local MapListItem = require("states.ui.freebuild.MapListButton")
local mapList = {}
local callback = function(element)
    for _, item in ipairs(mapList) do
        if element ~= item then item:unselect() end
    end
end
mapList[#mapList + 1] =
    MapListItem:new(
        #mapList + 1,
        callback,
        states.STATE_FREE_BUILD_WINDOW,
        frames.frListItem_1,
        -- TODO: load the description and image from the map metadata
        {
            name = SID.freebuild.fernhaven.name,
            description = SID.freebuild.fernhaven.description,
            preview = love.graphics.newImage("saves/fernhaven_preview.png")
        },
        buttonStart,
        titleText,
        descriptionText,
        previewImageElement
    )
mapList[#mapList + 1] = MapListItem:new(
    #mapList + 1,
    callback,
    states.STATE_FREE_BUILD_WINDOW,
    frames.frListItem_2,
    {
        name = SID.freebuild.grasslands.name,
        description = SID.freebuild.grasslands.description,
        preview = love.graphics.newImage("saves/grasslands_preview.png")
    },
    buttonStart,
    titleText,
    descriptionText,
    previewImageElement
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
closeWindowButton:SetState(states.STATE_FREE_BUILD_WINDOW)
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
