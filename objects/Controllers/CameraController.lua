local tempMX, tempMY = 0, 0
local mouseDeadZoneValX, mouseDeadZoneValY = 0, 0
local config = require("config_file")


local function getZFromZoom()
    local val = 1
    local scale = _G.state.scaleX
    if scale < 1 then
        val = (1 - scale) * 50
    elseif scale > 1 then
        val = scale
    end
    return val
end

local function resetMousePositionIfNeeded()
    if tempMX ~= 0 and tempMY ~= 0 then
        -- can be used in options if you want to reset mouse position to center
        -- feels ok but not ok at the same time :D
        -- love.mouse.setPosition(tempMX, tempMY)
        tempMX = 0
        tempMY = 0
    end
end

local function isMouseInDeadZone(posX, posY)
    if mouseDeadZoneValX == 0 and mouseDeadZoneValY == 0 then
        mouseDeadZoneValX, mouseDeadZoneValY = ((_G.ScreenWidth / 2) * 5) / 100, ((_G.ScreenHeight / 2) * 5) / 100
    end
    if posX > mouseDeadZoneValX + _G.ScreenWidth / 2 or posX < _G.ScreenWidth / 2 - mouseDeadZoneValX then
        return false
    end
    if posY > mouseDeadZoneValY + _G.ScreenHeight / 2 or posY < _G.ScreenHeight / 2 - mouseDeadZoneValY then
        return false
    end
    return true
end

local function handleCameraMovement(posX, posY)
    if posX ~= nil then
        _G.state.viewXview = posX
    end
    if posY ~= nil then
        _G.state.viewYview = posY
    end
    love.audio.setPosition((_G.state.viewXview) / 100, (_G.state.viewYview) / 100, getZFromZoom())
end

local function handleOnMouseButtonDownCameraMovement(mx, my, smoothModifier)
    local posX, posY = love.mouse.getPosition()
    if tempMX == 0 and tempMY == 0 and posX ~= 0 and posY ~= 0 then
        tempMX, tempMY = posX, posY
        -- can be used in options if you want to reset mouse position to center
        -- feels ok but not ok at the same time :D
        -- love.mouse.setPosition(_G.ScreenWidth / 2, _G.ScreenHeight / 2)
        -- let the next frame handle the movement
        -- this one will just set the cursor position to center
        return
    end
    if isMouseInDeadZone(posX, posY) then
        -- no movement needed
        return
    end
    local distX, distY = mx - _G.state.viewXview, my - _G.state.viewYview
    handleCameraMovement(_G.state.viewXview + distX / smoothModifier, _G.state.viewYview + distY / smoothModifier)
end

local panDirection = {
    up    = "up",
    down  = "down",
    left  = "left",
    right = "right",
}

local panDirectionToKeys = {
    [panDirection.up]    = {},
    [panDirection.down]  = {},
    [panDirection.left]  = {},
    [panDirection.right] = {}
}

if config.camera.panCameraWithWASD then
    table.insert(panDirectionToKeys[panDirection.up], "w")
    table.insert(panDirectionToKeys[panDirection.down], "s")
    table.insert(panDirectionToKeys[panDirection.left], "a")
    table.insert(panDirectionToKeys[panDirection.right], "d")
end

if config.camera.panCameraWithArrowKeys then
    table.insert(panDirectionToKeys[panDirection.up], "up")
    table.insert(panDirectionToKeys[panDirection.down], "down")
    table.insert(panDirectionToKeys[panDirection.left], "left")
    table.insert(panDirectionToKeys[panDirection.right], "right")
end

local panDirectionToMousePositions = {
    [panDirection.up]    = {y = 0},
    [panDirection.down]  = {y = _G.ScreenHeight - 1},
    [panDirection.left]  = {x = 0},
    [panDirection.right] = {x = _G.ScreenWidth - 1},
}

local function isAnyKeyDown(keys)
    for _, key in pairs(keys) do
        if love.keyboard.isDown(key) then
            return true
        end
    end
    return false
end

local function isMouseOnDirectionEdge(direction)
    if not config.camera.moveMouseToEdgesToPan then return end
    local mouseX, mouseY = love.mouse.getPosition()
    if (direction == panDirection.up or
        direction == panDirection.down)
        and mouseY == panDirectionToMousePositions[direction].y then
        return true
    end
    if (direction == panDirection.left or
        direction == panDirection.right)
        and mouseX == panDirectionToMousePositions[direction].x then
        return true
    end
    return false
end

local function shouldPan(direction)
    return isMouseOnDirectionEdge(direction)
        or isAnyKeyDown(panDirectionToKeys[direction])
end

local function handleCamera()
    local defMX, defMY = love.mouse.getPosition()
    local mx = (defMX - 16 - _G.ScreenWidth / 2) / _G.state.scaleX + _G.state.viewXview
    local my = (defMY - 8 - _G.ScreenHeight / 2) / _G.state.scaleX + _G.state.viewYview
    local finalScrollSpeed = (_G.scrollSpeed + ((1 - _G.state.scaleX) * 20)) * _G.dt / _G.speedModifier
    if finalScrollSpeed < 5 then
        finalScrollSpeed = 5
    end
    local smoothModifier = finalScrollSpeed * 3
    if not _G.paused then
        if love.mouse.isDown(2) and config.camera.holdRightButtonToPan then
            handleOnMouseButtonDownCameraMovement(mx, my, smoothModifier)
        else
            if shouldPan(panDirection.up) then
                handleCameraMovement(nil, _G.state.viewYview - finalScrollSpeed)
            end
            if shouldPan(panDirection.down) then
                handleCameraMovement(nil, _G.state.viewYview + finalScrollSpeed)
            end
            if shouldPan(panDirection.left) then
                handleCameraMovement(_G.state.viewXview - finalScrollSpeed, nil)
            end
            if shouldPan(panDirection.right) then
                handleCameraMovement(_G.state.viewXview + finalScrollSpeed, nil)
            end
            resetMousePositionIfNeeded()
        end
    end
end

return {
    handleCamera = handleCamera,
    getZFromZoom = getZFromZoom
}
