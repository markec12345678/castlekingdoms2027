local music = {
    ["stainedglass"] = love.audio.newSource("sounds/music/stainedglass.mp3", "stream"),
    ["Mattsjig"] = love.audio.newSource("sounds/music/Mattsjig.mp3", "stream"),
    ["sadtimes"] = love.audio.newSource("sounds/music/sadtimes.mp3", "stream"),
    ["the maiden"] = love.audio.newSource("sounds/music/the maiden.mp3", "stream"),
    ["twomandolins"] = love.audio.newSource("sounds/music/twomandolins.mp3", "stream"),
    ["underanoldtree"] = love.audio.newSource("sounds/music/underanoldtree.mp3", "stream"),
    ["castlejam"] = love.audio.newSource("sounds/music/castlejam.mp3", "stream")
}

music["stainedglass"]:setVolumeLimits(0, 0.8)

return music
