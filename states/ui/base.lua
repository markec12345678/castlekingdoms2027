local w = {
    percent = {}
}
local h = {
    percent = {}
}

-- TODO: Update this on resize
local screen_width, screen_height = love.graphics.getDimensions()
for i = 1, 100 do
    w.percent[i] = screen_width * (i / 100)
    h.percent[i] = screen_height * (i / 100)
end
return {
    w = w,
    h = h
}
