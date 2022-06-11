-- variables needed for camera when mouse button is pressed
local tempMX, tempMY = 0, 0;
local mouseDeadZoneValX, mouseDeadZoneValY = 0, 0;
--handleCmaera should be called once on update
function handleCamera()
    defMX, defMY = love.mouse.getPosition();
    mx = (defMX - 16 - _G.ScreenWidth / 2) / _G.state.scaleX + _G.state.viewXview
    my = (defMY - 8 - _G.ScreenHeight / 2) / _G.state.scaleX + _G.state.viewYview
    local finalScrollSpeed = (_G.scrollSpeed + ((1 - _G.state.scaleX) * 20)) * _G.dt
    if finalScrollSpeed < 5 then
        finalScrollSpeed = 5
    end
    local smoothModifier = finalScrollSpeed * 3
    if not _G.paused then
        if love.mouse.isDown(2) then
            handleOnMouseButtonDownCameraMovement(mx, my, smoothModifier)
        else
            if love.keyboard.isDown("up") or love.keyboard.isDown("w") or defMY == 0 then
                handleCameraMovement(nil, _G.state.viewYview - finalScrollSpeed)
            end
            if love.keyboard.isDown("down") or love.keyboard.isDown("s") or defMY == _G.ScreenHeight - 1 then
                handleCameraMovement(nil, _G.state.viewYview + finalScrollSpeed)
            end
            if love.keyboard.isDown("left") or love.keyboard.isDown("a") or defMX == 0 then
                handleCameraMovement(_G.state.viewXview - finalScrollSpeed, nil)
            end
            if love.keyboard.isDown("right") or love.keyboard.isDown("d") or defMX == _G.ScreenWidth - 1 then
                handleCameraMovement(_G.state.viewXview + finalScrollSpeed, nil)
            end
            resetMousePositionIfNeeded()
        end
    end
end
function handleOnMouseButtonDownCameraMovement(mx, my, smoothModifier)
    posX, posY = love.mouse.getPosition()
    if tempMX == 0 and tempMY == 0 and posX ~= 0 and posY ~= 0 then
        tempMX, tempMY = posX, posY
        --can be used in options if you want to reset mouse position to center
        --feels ok but not ok at the same time :D 
        --love.mouse.setPosition(_G.ScreenWidth / 2, _G.ScreenHeight / 2)
        -- let the next frame handle the movement
        -- this one will just set the cursor position to center
        return
    end
    if isMouseInDeadZone(posX, posY) then
        -- no movement needed
        return
    end
    distX = mx - _G.state.viewXview
    distY = my - _G.state.viewYview
    handleCameraMovement(_G.state.viewXview + distX / smoothModifier, _G.state.viewYview + distY / smoothModifier)
end
function resetMousePositionIfNeeded()
    if tempMX ~= 0 and tempMY ~= 0 then
        --can be used in options if you want to reset mouse position to center
        --feels ok but not ok at the same time :D 
        --love.mouse.setPosition(tempMX, tempMY)
        tempMX = 0
        tempMY = 0
    end
end
function isMouseInDeadZone(posX, posY)
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
function handleCameraMovement(posX, posY)
    if posX ~= nil then
        _G.state.viewXview = posX
    end
    if posY ~= nil then
        _G.state.viewYview = posY
    end
    love.audio.setPosition((_G.state.viewXview) / 100, (_G.state.viewYview) / 100, getZFromZoom())
end
function getZFromZoom()
    local val = 1
    local scale = _G.state.scaleX
    if scale < 1 then
        val = (1 - scale) * 50
    elseif scale > 1 then
        val = scale
    end
    return val
end
