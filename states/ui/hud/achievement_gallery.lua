-- states/ui/hud/achievement_gallery.lua
-- Stronghold 2027 - Achievement Gallery

local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")
local SteamWorks = require("objects.Steam.SteamWorks")

local AchievementGallery = {}
local panel = nil
local isVisible = false
local list = nil
local progressText = nil

function AchievementGallery.init()
    if panel then return end
    local w, h = love.graphics.getDimensions()
    panel = loveframes.Create("frame")
    panel:SetName("Dosezki - Stronghold 2027")
    panel:SetSize(700, 500)
    panel:SetPos((w-700)/2, (h-500)/2)
    panel:SetState(states.STATE_INGAME_CONSTRUCTION)
    panel:ShowCloseButton(false)
    panel:SetVisible(false)

    local title = loveframes.Create("text", panel)
    title:SetPos(20, 30)
    title:SetText("=== Dosezki ===")

    progressText = loveframes.Create("text", panel)
    progressText:SetPos(20, 55)
    progressText:SetSize(300, 30)
    progressText:SetText("Nalodi...")

    list = loveframes.Create("list", panel)
    list:SetPos(20, 90)
    list:SetSize(660, 340)
    list:SetPadding(5)
    list:SetSpacing(5)

    local closeBtn = loveframes.Create("button", panel)
    closeBtn:SetPos(280, 450)
    closeBtn:SetSize(140, 35)
    closeBtn:SetText("Zapri (Ctrl+A)")
    closeBtn.OnClick = function() AchievementGallery.hide() end
end

function AchievementGallery.refresh()
    if not list then return end
    list:Clear()
    local achievements = SteamWorks.getAllAchievements()
    local unlocked, total = 0, 0
    for id, ach in pairs(achievements or {}) do
        total = total + 1
        if ach.unlocked then unlocked = unlocked + 1 end
        local entry = loveframes.Create("frame")
        entry:SetName("")
        entry:SetSize(620, 60)
        entry:ShowCloseButton(false)
        entry:SetDraggable(false)
        local st = loveframes.Create("text", entry)
        st:SetPos(10, 10)
        st:SetText(ach.unlocked and "[ODKLENJENO]" or "[ZAKLENJENO]")
        local nm = loveframes.Create("text", entry)
        nm:SetPos(120, 10)
        nm:SetText(ach.name or id)
        local dc = loveframes.Create("text", entry)
        dc:SetPos(120, 30)
        dc:SetText(ach.description or "")
        list:AddItem(entry)
    end
    if progressText then
        progressText:SetText(string.format("Napredek: %d / %d odklenjenih", unlocked, total))
    end
end

function AchievementGallery.show()
    AchievementGallery.init()
    isVisible = true
    panel:SetVisible(true)
    AchievementGallery.refresh()
end

function AchievementGallery.hide()
    isVisible = false
    if panel then panel:SetVisible(false) end
end

function AchievementGallery.toggle()
    if isVisible then AchievementGallery.hide() else AchievementGallery.show() end
end

function AchievementGallery.isVisible() return isVisible end

return AchievementGallery
