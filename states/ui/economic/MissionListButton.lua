local loveframes = require("libraries.loveframes")
local freebuildFrames = require("states.ui.freebuild.frames")
local frames, scale = freebuildFrames[1], freebuildFrames[2]
local Events = require("objects.Enums.Events")

local listImageHover = love.graphics.newImage("assets/ui/freebuild/hover.png")
local listImageSelected = love.graphics.newImage("assets/ui/freebuild/selected.png")

local MapListItem = _G.class("MapListItem")
function MapListItem:initialize(position, missionNumber, onSelectCallback, state, frListItem, missionData, startButton,
                                titleText, descriptionText, unlocked, mapPreview)
    if position < 1 or position > 12 then
        error("received invalid position argument for action bar: " .. tostring(position))
    end
    if not missionNumber then
        error("missionNumber cannot be nil")
    end
    if not state then
        error("state cannot be nil")
    end
    if not startButton then
        error("startButton cannot be nil")
    end
    if not titleText then
        error("titleText cannot be nil")
    end
    if not descriptionText then
        error("descriptionText cannot be nil")
    end
    if not missionData then
        error("missionData cannot be nil")
    end

    self.missionNumber = missionNumber
    self.state = state
    self.missionData = missionData
    self.selected = false
    self.startButton = startButton
    self.titleText = titleText
    self.descriptionText = descriptionText
    self.mapPreview = mapPreview
    self.onSelectCallback = onSelectCallback
    self.unlocked = unlocked

    local list = loveframes.Create("image")
    list:SetState(state)
    list:SetImage(listImageHover)
    list:SetScaleX(frListItem.width / listImageHover:getWidth())
    list:SetScaleY(list:GetScaleX())
    list:SetImage()
    list:SetPos(frListItem.x, frListItem.y)
    list.OnMouseEnter = function(this)
        if not self.selected and self.unlocked == true then
            list:SetImage(listImageHover)
            self.nameText:SetX(self.nameTextOriginalX + 10)
            self.nameText:SetText({ { color = { 0.35 + 0.5, 0.3 + 0.5, 0.2 + 0.5 } }, self.nameText:GetText() })
        end
    end
    list.OnClick = function(this)
        if self.unlocked == true then
            self:onClick()
        end
    end
    _G.bus.on(Events.OnMissionCompleted, list.OnClick)
    list.OnMouseExit = function(this)
        if not self.selected then
            self:unselect()
        end
    end
    self.background = list


    local nameText = loveframes.Create("text")
    nameText:SetState(state)
    nameText:SetFont(loveframes.font_times_new_normal_large)
    nameText:SetShadow(true)
    nameText:SetText(missionData.name)
    nameText:SetPos(frListItem.x + 30 * scale, frListItem.y + frListItem.height / 2 - nameText.font:getHeight("A") / 2)
    nameText:SetShadowColor(0.35, 0.3, 0.26, 1)
    nameText.disablehover = true
    self.nameText = nameText
    self.nameTextOriginalX = nameText:GetX()
    if self.unlocked == false then
        self.nameText:SetText({ { color = { 0.41, 0.41, 0.41 } }, missionData.name })
    end
end

function MapListItem:unselect()
    self.selected = false
    self.background:SetImage()
    self.nameText:SetX(self.nameTextOriginalX)
    if self.unlocked == true then
        self.nameText:SetText(self.nameText:GetText()) -- gets rid of color
    end
end

function MapListItem:onClick()
    self.selected = true
    if self.onSelectCallback then self.onSelectCallback(self) end
    self.background:SetImage(listImageSelected)
    self.startButton:SetVisible(true)
    self.startButton.missionNumber = self.missionNumber
    self.titleText:SetText(self.missionData.name)
    self.descriptionText:SetText(self.missionData.description)
end

function MapListItem:hide()
    self.background.visible = false
    self.nameText.visible = false
end

function MapListItem:show()
    self.background.visible = true
    self.nameText.visible = true
end

return MapListItem
