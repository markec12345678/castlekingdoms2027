local music = require("sounds.music")
local playlist = {music["stainedglass"], music["Mattsjig"], music["sadtimes"], music["the maiden"],
                  music["twomandolins"], music["underanoldtree"], music["castlejam"]}

local function shuffle(x)
    for i = #x, 2, -1 do
        local j = math.random(i)
        x[i], x[j] = x[j], x[i]
    end
end

shuffle(playlist)

return function()
    if not _G.CURRENT_MUSIC or not _G.CURRENT_MUSIC:isPlaying() then
        _G.CURRENT_PLAYLIST_INDEX = _G.CURRENT_PLAYLIST_INDEX + 1
        if _G.CURRENT_PLAYLIST_INDEX > #playlist then
            _G.CURRENT_PLAYLIST_INDEX = 1
        end
        playlist[_G.CURRENT_PLAYLIST_INDEX]:setVolume(_G.OPTIONS.MUSIC_VOLUME)
        playlist[_G.CURRENT_PLAYLIST_INDEX]:play()
        _G.CURRENT_MUSIC = playlist[_G.CURRENT_PLAYLIST_INDEX]
    end
end
