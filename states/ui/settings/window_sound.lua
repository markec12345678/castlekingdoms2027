local widgets = require("states.ui.settings.widgets")
local config = require("config_file")
local SID = require("objects.Controllers.LanguageController").lines

local elements = {}

-- MASTER VOLUME

local masterRow = widgets.addRow(elements, 1, true, SID.settings.categories.sound.items.masterVolume)
widgets.addSlider(elements, masterRow, config.sound.master, function(volume)
    config.sound.master = volume * 100
    _G.OPTIONS.MASTER_VOLUME = volume
    config:save(config)
    if _G.CURRENT_MUSIC and _G.CURRENT_MUSIC:isPlaying() then
        _G.CURRENT_MUSIC:setVolume(_G.OPTIONS.MUSIC_VOLUME * _G.OPTIONS.MASTER_VOLUME)
    end
end)

-- MUSIC VOLUME

local musicRow = widgets.addRow(elements, 2, true, SID.settings.categories.sound.items.musicVolume)
widgets.addSlider(elements, musicRow, config.sound.music, function(volume)
    config.sound.music = volume * 100
    _G.OPTIONS.MUSIC_VOLUME = volume
    config:save(config)
    if _G.CURRENT_MUSIC and _G.CURRENT_MUSIC:isPlaying() then
        _G.CURRENT_MUSIC:setVolume(_G.OPTIONS.MUSIC_VOLUME * _G.OPTIONS.MASTER_VOLUME)
    end
end)

-- SOUND EFFECTS VOLUME

local soundRow = widgets.addRow(elements, 3, true, SID.settings.categories.sound.items.soundVolume)
widgets.addSlider(elements, soundRow, config.sound.effects, function(volume)
    config.sound.effects = volume * 100
    _G.OPTIONS.SFX_VOLUME = volume
    config:save(config)
end)

-- SPEECH VOLUME

local speechRow = widgets.addRow(elements, 4, true, SID.settings.categories.sound.items.speechVolume)
widgets.addSlider(elements, speechRow, config.sound.speech, function(volume)
    config.sound.speech = volume * 100
    _G.OPTIONS.SPEECH_VOLUME = volume
    config:save(config)
end)

return elements
