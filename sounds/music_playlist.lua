local music = require("sounds.music")

local function shuffle(x)
    for i = #x, 2, -1 do
        local j = math.random(i)
        x[i], x[j] = x[j], x[i]
    end
end

return function(mood)
    if mood == nil then
        mood = "peaceful"
    end

    if _G.CURRENT_MUSIC and _G.CURRENT_MUSIC:isPlaying() and _G.CURRENT_MUSIC_MOOD ~= mood then
        love.audio.stop(_G.CURRENT_MUSIC)
        _G.CURRENT_MUSIC = nil
        _G.CURRENT_PLAYLIST_INDEX = 0
    end
    
    local playlist = music[mood]

    -- handle empty playlist
    if (#playlist == 0) then
        return
    end

    shuffle(playlist)

    if not _G.CURRENT_MUSIC or not _G.CURRENT_MUSIC:isPlaying() then
        _G.CURRENT_PLAYLIST_INDEX = _G.CURRENT_PLAYLIST_INDEX + 1
        if _G.CURRENT_PLAYLIST_INDEX > #playlist then
            _G.CURRENT_PLAYLIST_INDEX = 1
        end
        playlist[_G.CURRENT_PLAYLIST_INDEX]:setVolume(_G.OPTIONS.MUSIC_VOLUME * _G.OPTIONS.MASTER_VOLUME)
        playlist[_G.CURRENT_PLAYLIST_INDEX]:play()
        _G.CURRENT_MUSIC = playlist[_G.CURRENT_PLAYLIST_INDEX]
        _G.CURRENT_MUSIC_MOOD = mood
    end
end
