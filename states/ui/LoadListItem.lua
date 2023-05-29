local loveframes = require("libraries.loveframes")
local SaveManager = require("objects.Controllers.SaveManager")
local Gamestate = require("libraries.gamestate")
local game = require("states.game")

local listImage = love.graphics.newImage("assets/ui/load_game_list.png")
local listImageHover = love.graphics.newImage("assets/ui/load_game_list_hover.png")
local listImageDown = love.graphics.newImage("assets/ui/load_game_list_selected.png")
local deleteButtonImage = love.graphics.newImage("assets/ui/trash_can_clean.png")
local deleteButtonImageHover = love.graphics.newImage("assets/ui/trash_can_red.png")
local deleteButtonImageDown = love.graphics.newImage("assets/ui/trash_can_dirty.png")

local LoadListItem = _G.class("LoadListItem")
function LoadListItem:initialize(position, state, frListItem, frColumnSaveName, frColumnMap, frColumnDate,
                                 frColumnVersion, frDeleteButton)
    if position < 1 or position > 8 then
        error("received invalid position argument for action bar: " .. tostring(position))
    end
    if not state then
        error("state cannot be nil")
    end

    self.state = state

    local list = loveframes.Create("image")
    self.background = list
    list:SetState(self.state)
    list:SetImage(listImage)
    list:SetScaleX(frListItem.width / list:GetImageWidth())
    list:SetScaleY(frListItem.height / list:GetImageHeight())
    list:SetPos(frListItem.x, frListItem.y)
    list.OnMouseEnter = function(this)
        this:SetImage(listImageHover)
    end
    list.OnMouseDown = function(this)
        this:SetImage(listImageDown)
    end
    list.OnClick = function()
        self:onClick()
    end
    list.OnMouseExit = function(this)
        this:SetImage(listImage)
    end
    local nameText = loveframes.Create("text")
    self.nameText = nameText
    nameText:SetState(self.state)
    nameText:SetFont(loveframes.font_vera_bold)
    nameText:SetPos(frColumnSaveName.x, frColumnSaveName.y)
    nameText:SetText("Milano")
    nameText:SetShadowColor(0.8, 0.8, 0.8, 1)
    nameText.disablehover = true
    local mapText = loveframes.Create("text")
    self.mapText = mapText
    mapText:SetState(self.state)
    mapText:SetFont(loveframes.basicfont)
    mapText:SetPos(frColumnMap.x, frColumnMap.y)
    mapText:SetText("Fernhaven")
    mapText:SetShadowColor(0.8, 0.8, 0.8, 1)
    mapText.disablehover = true
    local dateText = loveframes.Create("text")
    self.dateText = dateText
    dateText:SetState(self.state)
    dateText:SetFont(loveframes.basicfont)
    dateText:SetPos(frColumnDate.x, frColumnDate.y)
    dateText:SetText("2022-06-04\n  14:47:00")
    dateText:SetShadowColor(0.8, 0.8, 0.8, 1)
    dateText.disablehover = true
    local versionText = loveframes.Create("text")
    self.versionText = versionText
    versionText:SetState(self.state)
    versionText:SetFont(loveframes.basicfont)
    versionText:SetPos(frColumnVersion.x, frColumnVersion.y)
    versionText:SetText("0.4.0")
    versionText:SetShadowColor(0.8, 0.8, 0.8, 1)
    versionText.visible = false
    versionText.disablehover = true
    local deleteButton = loveframes.Create("image")
    self.deleteButton = deleteButton
    deleteButton:SetState(self.state)
    deleteButton:SetImage(deleteButtonImage)
    deleteButton:SetScaleX(frDeleteButton.width / deleteButton:GetImageWidth())
    deleteButton:SetScaleY(deleteButton:GetScaleX())
    deleteButton:SetPos(frDeleteButton.x, frDeleteButton.y)
    deleteButton.OnMouseEnter = function(this)
        this:SetImage(deleteButtonImageHover)
    end
    deleteButton.OnMouseDown = function(this)
        this:SetImage(deleteButtonImageDown)
    end
    deleteButton.OnClick = function(this)
        SaveManager:delete(self.nameText:GetText())
    end
    deleteButton.OnMouseExit = function(this)
        this:SetImage(deleteButtonImage)
    end

    if self.disabled then
        self.foreground:SetColor(0.6, 0.6, 0.6, 0.6)
    end
end

function LoadListItem:onClick()
    _G.playSpeech("General_Loading")
    _G.loaded = false
    local State = require("objects.State")
    _G.state = State:new()
    if _G.state then _G.state.initialized = false end
    loveframes.SetState()
    Gamestate.switch(game, self.nameText:GetText())
end

function LoadListItem:setValues(name, mapName, rawDateModified, version)
    self.nameText:SetText(name)
    self.mapText:SetText(mapName)
    local dateModified = rawDateModified:gsub(" ", "\n  ")
    self.dateText:SetText(dateModified)
    self.versionText:SetText(version)
    if version ~= "0.5.0" then
        self.versionText:SetText({ {
            color = { 204 / 255, 51 / 255, 0, 1 }
        }, version })
    else
        self.versionText:SetText(version)
    end
end

function LoadListItem:hide()
    self.background.visible = false
    self.nameText.visible = false
    self.mapText.visible = false
    self.dateText.visible = false
    self.versionText.visible = false
    self.deleteButton.visible = false
end

function LoadListItem:show()
    self.background.visible = true
    self.nameText.visible = true
    self.mapText.visible = true
    self.dateText.visible = true
    self.versionText.visible = true
    self.deleteButton.visible = true
end

return LoadListItem
