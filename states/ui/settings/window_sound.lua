local widgets = require("states.ui.settings.widgets")
local config = require("config_file")

local elements = {}

-- MASTER VOLUME

widgets.addSlider(elements, 1, "Master volume", config.sound.master, true, function (volume)
    config.sound.master = volume * 100
    _G.OPTIONS.MASTER_VOLUME = volume
    config:save(config)
    if _G.CURRENT_MUSIC and _G.CURRENT_MUSIC:isPlaying() then
        _G.CURRENT_MUSIC:setVolume(_G.OPTIONS.MUSIC_VOLUME * _G.OPTIONS.MASTER_VOLUME)
    end
end)

-- MUSIC VOLUME

widgets.addSlider(elements, 2, "Music volume", config.sound.music, true, function (volume)
    config.sound.music = volume * 100
    _G.OPTIONS.MUSIC_VOLUME = volume
    config:save(config)
    if _G.CURRENT_MUSIC and _G.CURRENT_MUSIC:isPlaying() then
        _G.CURRENT_MUSIC:setVolume(_G.OPTIONS.MUSIC_VOLUME * _G.OPTIONS.MASTER_VOLUME)
    end
end)

-- SOUND EFFECTS VOLUME

widgets.addSlider(elements, 3, "Sound volume", config.sound.effects, true, function (volume)
    config.sound.effects = volume * 100
    _G.OPTIONS.SFX_VOLUME = volume / 100
    config:save(config)
end)

-- SPEECH VOLUME

widgets.addSlider(elements, 4, "Speech volume", config.sound.speech, true, function (volume)
    config.sound.speech = volume * 100
    _G.OPTIONS.SPEECH_VOLUME = volume
    config:save(config)
end)

return elements
