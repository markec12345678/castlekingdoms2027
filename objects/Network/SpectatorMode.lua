-- objects/Network/SpectatorMode.lua
-- Stronghold 2027 - Spectator Mode
-- Watch multiplayer games as a spectator

local SpectatorMode = {}

local initialized = false
local isSpectating = false
local spectatedPlayer = 1
local spectatorSpeed = 1.0
local freeCamera = true
local cameraX = 0
local cameraY = 0
local cameraZoom = 1.0

function SpectatorMode.init()
    if initialized then return end
    initialized = true
    print("[SpectatorMode] Initialized")
end

function SpectatorMode.enter(targetPlayer)
    if not initialized then SpectatorMode.init() end
    isSpectating = true
    spectatedPlayer = targetPlayer or 1
    freeCamera = false

    -- Disable player controls
    _G.spectatorMode = true

    if _G.VoiceOver then
        _G.VoiceOver.notify("spectator_mode", "Opsazevalni nacin")
    end

    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Opsazovanje igralca " .. spectatedPlayer)
    end

    if _G.GameEventBus then
        _G.GameEventBus.emit("spectator_entered", { player = spectatedPlayer })
    end

    print("[SpectatorMode] Entering spectator mode (player: " .. spectatedPlayer .. ")")
end

function SpectatorMode.exit()
    if not isSpectating then return end
    isSpectating = false
    _G.spectatorMode = false

    if _G.GameEventBus then
        _G.GameEventBus.emit("spectator_exited")
    end

    print("[SpectatorMode] Exited spectator mode")
end

function SpectatorMode.isSpectating()
    return isSpectating
end

function SpectatorMode.setTarget(playerId)
    spectatedPlayer = playerId
    freeCamera = false
    print("[SpectatorMode] Following player " .. playerId)
end

function SpectatorMode.setFreeCamera(enabled)
    freeCamera = enabled
    print("[SpectatorMode] Free camera: " .. tostring(enabled))
end

function SpectatorMode.update(dt)
    if not isSpectating then return end

    if not freeCamera then
        -- Follow target player's keep
        if _G.state and _G.state.gameObjectList then
            for _, obj in ipairs(_G.state.gameObjectList) do
                if obj.faction == spectatedPlayer and obj.class and obj.class.name then
                    local name = obj.class.name
                    if name == "Keep" or name == "WoodenKeep" or name == "Fortress" or name == "Stronghold" then
                        if obj.gx and obj.gy and _G.state.viewXview then
                            -- Smoothly move camera towards target
                            local targetX = -_G.IsoToScreenX(obj.gx, obj.gy) + love.graphics.getWidth() / 2
                            local targetY = -_G.IsoToScreenY(obj.gx, obj.gy) + love.graphics.getHeight() / 2
                            _G.state.viewXview = _G.state.viewXview + (targetX - _G.state.viewXview) * dt * 3
                            _G.state.viewYview = _G.state.viewYview + (targetY - _G.state.viewYview) * dt * 3
                        end
                        break
                    end
                end
            end
        end
    else
        -- Free camera with WASD
        local speed = 500 * dt
        if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
            _G.state.viewYview = (_G.state.viewYview or 0) + speed
        end
        if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
            _G.state.viewYview = (_G.state.viewYview or 0) - speed
        end
        if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
            _G.state.viewXview = (_G.state.viewXview or 0) + speed
        end
        if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
            _G.state.viewXview = (_G.state.viewXview or 0) - speed
        end
    end
end

function SpectatorMode.draw()
    if not isSpectating then return end

    local w, h = love.graphics.getDimensions()

    -- Spectator overlay
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, w, 40)

    love.graphics.setColor(0.3, 0.6, 1.0, 1)
    love.graphics.print("OPSAZOVALNI NACIN", 10, 12)

    love.graphics.setColor(1, 1, 1, 1)
    local targetText = freeCamera and "Prosta kamera (WASD)" or "Sledim igralcu " .. spectatedPlayer
    love.graphics.print(targetText, 150, 12)

    -- Controls hint
    love.graphics.setColor(0.6, 0.6, 0.6, 1)
    love.graphics.print("TAB=preklopi igralca | F=prosta kamera | ESC=izhod", w - 350, 12)

    love.graphics.setColor(1, 1, 1, 1)
end

function SpectatorMode.keypressed(key)
    if not isSpectating then return false end

    if key == "tab" then
        -- Cycle through players
        spectatedPlayer = spectatedPlayer + 1
        if spectatedPlayer > 8 then spectatedPlayer = 1 end
        freeCamera = false
        if _G.ModernUI then
            _G.ModernUI.notifyInfo("Sledim igralcu " .. spectatedPlayer)
        end
        return true
    elseif key == "f" then
        freeCamera = not freeCamera
        if _G.ModernUI then
            _G.ModernUI.notifyInfo(freeCamera and "Prosta kamera" or "Sledenje igralcu")
        end
        return true
    elseif key == "escape" then
        SpectatorMode.exit()
        return true
    end

    return false
end

function SpectatorMode.getSpectatedPlayer()
    return spectatedPlayer
end

function SpectatorMode.isFreeCamera()
    return freeCamera
end

return SpectatorMode
