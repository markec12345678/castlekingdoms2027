local loveframes = require("libraries.loveframes")
local freebuildFrames = require("states.ui.freebuild.frames")
local frames, scale = freebuildFrames[1], freebuildFrames[2]

local listImageHover = love.graphics.newImage("assets/ui/freebuild/hover.png")
local listImageSelected = love.graphics.newImage("assets/ui/freebuild/selected.png")

local MapListItem = _G.class("MapListItem")
function MapListItem:initialize(position, onSelectCallback, state, frListItem, mapData, startButton, titleText, descriptionText, mapPreview)
    if position < 1 or position > 12 then
        error("received invalid position argument for action bar: " .. tostring(position))
    end
    if not state then
        error("state cannot be nil")
    end
    if not mapData then
        error("mapData cannot be nil")
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
    if not mapPreview then
        error("mapPreview cannot be nil")
    end


    self.state = state
    self.mapData = mapData
    self.selected = false
    self.startButton = startButton
    self.titleText = titleText
    self.descriptionText = descriptionText
    self.mapPreview = mapPreview
    self.onSelectCallback = onSelectCallback

    local list = loveframes.Create("image")
    list:SetState(state)
    list:SetImage(listImageHover)
    list:SetScaleX(frListItem.width / listImageHover:getWidth())
    list:SetScaleY(list:GetScaleX())
    list:SetImage()
    list:SetPos(frListItem.x, frListItem.y)
    list.OnMouseEnter = function(this)
        if not self.selected then
            list:SetImage(listImageHover)
            self.nameText:SetX(self.nameTextOriginalX + 10)
            self.nameText:SetText({ { color = { 0.35 + 0.5, 0.3 + 0.5, 0.2 + 0.5 } }, self.nameText:GetText() })
        end
    end
    list.OnClick = function(this)
        self:onClick()
    end
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
    nameText:SetText(mapData.name)
    nameText:SetPos(frListItem.x + 30 * scale, frListItem.y + frListItem.height / 2 - nameText.font:getHeight("A") / 2)
    nameText:SetShadowColor(0.35, 0.3, 0.26, 1)
    nameText.disablehover = true
    self.nameText = nameText
    self.nameTextOriginalX = nameText:GetX()
end

function MapListItem:unselect()
    self.selected = false
    self.background:SetImage()
    self.nameText:SetX(self.nameTextOriginalX)
    self.nameText:SetText(self.nameText:GetText()) -- gets rid of color
end

function MapListItem:onClick()
    self.selected = true
    if self.onSelectCallback then self.onSelectCallback(self) end
    self.background:SetImage(listImageSelected)
    self.startButton:SetVisible(true)
    self.titleText:SetText(self.mapData.name)
    self.descriptionText:SetText(self.mapData.description)
    self.mapPreview:SetImage(self.mapData.preview)
    self.mapPreview:SetScaleX(frames["frMapPreview"].width / self.mapData.preview:getWidth())
    self.mapPreview:SetScaleY(self.mapPreview:GetScaleX())
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
