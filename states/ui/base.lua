local w = {
    percent = {}
}
local h = {
    percent = {}
}

-- TODO: Update this on resize
local screenWidth, screenHeight = love.graphics.getDimensions()
for i = 1, 100 do
    w.percent[i] = screenWidth * (i / 100)
    h.percent[i] = screenHeight * (i / 100)
end
return {
    w = w,
    h = h
}
