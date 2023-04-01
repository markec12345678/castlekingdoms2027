local tempMX, tempMY = 0, 0
-- CamSpeed for making the deltatime movement faster.
local CamSpeed = 120
local mouseDeadZoneValX, mouseDeadZoneValY = 0, 0
local config = require("config_file")
local keybindManager = require("objects.Controllers.KeybindManager")
local EVENT = require("objects.Enums.KeyEvents")
local workshopWeaponChoosers = require("states.ui.workshops.workshops_ui")
local console = require("libraries.console")
local panning = false
local outsideDeadZone = false

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

---Check if the mouse is within the deadzone and return that boolean.
---@param posX number Mouse X position.
---@param posY number Mouse Y position.
---@return boolean
local function isMouseInDeadZone(posX, posY)
    -- Set deadzone to mouse position only once.
    if panning == false then
        mouseDeadZoneValX, mouseDeadZoneValY = posX, posY
        -- So that the origin of the mouse pointer stays the same.
        -- panning becomes false after the player stops pressing right click.
        panning = true
    end
    -- Check if the mouse is within the deadzone, if it exits the deadzone move the camera.
    -- If the mouse has exited the deadzone,
    -- make outsideDeadZone true so that if the mouse goes back into the deadzone the camera doesn't stop moving.
    if (posX > mouseDeadZoneValX + 5 or posX < mouseDeadZoneValX - 5) or outsideDeadZone then
        outsideDeadZone = true
        return false
    end
    if (posY > mouseDeadZoneValY + 5 or posY < mouseDeadZoneValY - 5) or outsideDeadZone then
        outsideDeadZone = true
        return false
    end
    return true
end

local function handleCameraMovement(posX, posY)
    -- Hide weapon choose UI when camera is moved
    for _, button in ipairs(workshopWeaponChoosers) do
        button.visible = false
    end
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

if keybindManager then
    table.insert(panDirectionToKeys[panDirection.up], keybindManager.keybinds.CamUp)
    table.insert(panDirectionToKeys[panDirection.down], keybindManager.keybinds.CamDown)
    table.insert(panDirectionToKeys[panDirection.left], keybindManager.keybinds.CamLeft)
    table.insert(panDirectionToKeys[panDirection.right], keybindManager.keybinds.CamRight)
end

local panDirectionToMousePositions = {
    [panDirection.up]    = {y = 0},
    [panDirection.down]  = {y = _G.ScreenHeight - 1},
    [panDirection.left]  = {x = 0},
    [panDirection.right] = {x = _G.ScreenWidth - 1},
}

--- Check if a certain table of keys are pressed, then returns true if a key is pressed from that table.
---@param keys table Key table to check.
---@return boolean Return if the Camera should pan or not.
local function isAnyKeyDown(keys)
    if console.isEnabled() then return false end
    for _, key in pairs(keys) do
        if love.keyboard.isDown(key) then
            return true
        end
    end
    return false
end

--- Check if the Mouse is on the edge of the screen.
---@param direction string Name of the pan direction. (up, down, left, right)
---@return boolean|nil Return if the Camera should pan or not.
local function isMouseOnDirectionEdge(direction)
    if not config.camera.moveMouseToEdgesToPan then return end
    local mouseX, mouseY = love.mouse.getPosition()
    -- Right click unaffected by changes in the next if statement.
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

--- Check and return if the Camera is supposed to pan (Either through keys or by having the mouse at the edge of the screen.).
---@param direction string Name of the pan direction. (up, down, left, right)
---@return boolean
local function shouldPan(direction)
    return isMouseOnDirectionEdge(direction)
        or isAnyKeyDown(panDirectionToKeys[direction])
end

---Handles and moves the camera depending on what is supposed to pan.
local function handleCamera()
    -- Right click affected.
    local defMX, defMY = love.mouse.getPosition()
    -- Multiply with deltatime for consistent camera movement across all framerates.
    -- Then divide dt with _G.speedModifier to make it not dependent on game Speed.
    local mx = (defMX - 16 - _G.ScreenWidth / 2) * ((dt / _G.speedModifier) * CamSpeed / 3) / _G.state.scaleX + _G.state.viewXview
    local my = (defMY - 8 - _G.ScreenHeight / 2) * ((dt / _G.speedModifier) * CamSpeed / 3) / _G.state.scaleX + _G.state.viewYview
    local finalScrollSpeed = (_G.scrollSpeed + ((1 - _G.state.scaleX) * 20)) * _G.dt / _G.speedModifier
    if finalScrollSpeed < 5 then
        finalScrollSpeed = 5
    end

    local smoothModifier = finalScrollSpeed * 3
    if not _G.paused then
        if love.mouse.isDown(2) and config.camera.holdRightButtonToPan then
            -- Only applies to Right Click panning.
            handleOnMouseButtonDownCameraMovement(mx, my, smoothModifier)
        else
            -- Reset booleans for isMouseInDeadZone() so that it can recalculate the deadzone and disable panning temporarily.
            panning = false
            outsideDeadZone = false
            -- Only applies to Key movement and when the mouse is on the edge of the screen.
            -- Multiply with deltatime for consistent camera movement across all framerates.
            -- dt / _G.speedModifier means that the Camera speed is no longer dependent on the Game's speed multiplier.
            -- Right click is not affected by this.
            if shouldPan(panDirection.up) then
                handleCameraMovement(nil, _G.state.viewYview - (finalScrollSpeed * 1.2))
            end
            if shouldPan(panDirection.down) then
                handleCameraMovement(nil, _G.state.viewYview + (finalScrollSpeed * 1.2))
            end
            if shouldPan(panDirection.left) then
                handleCameraMovement(_G.state.viewXview - (finalScrollSpeed * 1.2), nil)
            end
            if shouldPan(panDirection.right) then
                handleCameraMovement(_G.state.viewXview + (finalScrollSpeed * 1.2), nil)
            end
            resetMousePositionIfNeeded()
        end
    end
end

return {
    handleCamera = handleCamera,
    getZFromZoom = getZFromZoom
}
