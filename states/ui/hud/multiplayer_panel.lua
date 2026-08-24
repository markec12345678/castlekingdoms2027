-- states/ui/hud/multiplayer_panel.lua
-- Castle Kingdoms 2027 v3.13.2 - Multiplayer Connection Panel
--
-- UI panel for connecting to / hosting multiplayer games.
-- Uses existing GameClient/GameServer (objects/Network/) infrastructure.
--
-- Features:
--   * Host game (start server)
--   * Join game (connect to IP:port)
--   * Player name input
--   * Connection status display
--   * Player list (when connected)
--   * Disconnect button
--   * Chat toggle
--
-- Toggle: Ctrl+Shift+N (N for "Network")
-- Note: Many Ctrl+Shift keys are taken, using N (was unused in Ctrl+Shift+N)

local PanelAnim = require("states.ui.hud.PanelAnimations")
local UISound = require("objects.Audio.UISoundHelper")

local MultiplayerPanel = {}

local visible = false
local mode = "menu"  -- "menu" | "host" | "join" | "connected" | "error"
local inputField = "name"  -- "name" | "ip" | "port"
local nameBuffer = "Player1"
local ipBuffer = "127.0.0.1"
local portBuffer = "25565"
local statusMessage = ""
local statusTime = 0

local animState = PanelAnim.createState({
    duration = 0.20,
    slideDir = "down",
    slideDist = 20,
    easing = "easeOut",
})

function MultiplayerPanel.toggle()
    if not visible then
        visible = true
        PanelAnim.open(animState)
        UISound.playPanelOpen()
        mode = "menu"
        statusMessage = ""
    else
        PanelAnim.close(animState)
        UISound.playPanelClose()
    end
end

function MultiplayerPanel.isVisible()
    return visible or PanelAnim.isAnimating(animState)
end

function MultiplayerPanel.update(dt)
    if not visible and not PanelAnim.isAnimating(animState) then return end
    PanelAnim.update(animState, dt)
    if animState.phase == "closed" then
        visible = false
    end
    if statusTime > 0 then
        statusTime = statusTime - dt
    end
end

-- Try to host a game
local function tryHost()
    local port = tonumber(portBuffer) or 25565
    if _G.GameServer then
        local ok, err = pcall(function()
            _G.GameServer.start(port)
        end)
        if ok then
            -- Also connect as local client
            if _G.GameClient then
                pcall(function()
                    _G.GameClient.connect("127.0.0.1", port, nameBuffer)
                end)
            end
            mode = "connected"
            statusMessage = "Hosting on port " .. port
            statusTime = 5
            if _G.NotificationCenter then
                pcall(function() _G.NotificationCenter.system("Multiplayer: Host odprt na portu " .. port) end)
            end
        else
            mode = "error"
            statusMessage = "Napaka pri hostingu: " .. tostring(err)
            statusTime = 5
        end
    end
end

-- Try to join a game
local function tryJoin()
    local port = tonumber(portBuffer) or 25565
    if _G.GameClient then
        local ok, err = pcall(function()
            _G.GameClient.connect(ipBuffer, port, nameBuffer)
        end)
        if ok then
            mode = "connected"
            statusMessage = "Povezujem na " .. ipBuffer .. ":" .. port .. "..."
            statusTime = 5
            if _G.NotificationCenter then
                pcall(function() _G.NotificationCenter.system("Multiplayer: Povezujem na " .. ipBuffer .. ":" .. port) end)
            end
        else
            mode = "error"
            statusMessage = "Napaka pri povezavi: " .. tostring(err)
            statusTime = 5
        end
    end
end

-- Disconnect
local function tryDisconnect()
    if _G.GameClient then
        pcall(function() _G.GameClient.disconnect() end)
    end
    if _G.GameServer then
        pcall(function() _G.GameServer.stop() end)
    end
    mode = "menu"
    statusMessage = "Odklopljen"
    statusTime = 3
    if _G.NotificationCenter then
        pcall(function() _G.NotificationCenter.system("Multiplayer: Odklopljen") end)
    end
end

function MultiplayerPanel.draw()
    if not visible and not PanelAnim.isAnimating(animState) then return end

    local alpha = PanelAnim.getAlpha(animState)
    local offsetY = PanelAnim.getOffsetY(animState)
    if not alpha or not offsetY then return end

    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    local panelW = 500
    local panelH = 380
    local panelX = (screenW - panelW) / 2
    local panelY = (screenH - panelH) / 2 + offsetY

    -- Background dim
    love.graphics.setColor(0, 0, 0, 0.5 * alpha)
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)

    -- Panel background
    love.graphics.setColor(0.08, 0.06, 0.04, 0.97 * alpha)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH, 8, 8, 8, 8)
    love.graphics.setColor(0.5, 0.7, 0.95, alpha)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", panelX, panelY, panelW, panelH, 8, 8, 8, 8)
    love.graphics.setLineWidth(1)

    -- Title
    love.graphics.setColor(0.8, 0.9, 1.0, alpha)
    love.graphics.print("🏰 MULTIPLAYER", panelX + 20, panelY + 16)

    -- Status message
    if statusTime > 0 and statusMessage ~= "" then
        love.graphics.setColor(0.9, 0.85, 0.4, alpha)
        love.graphics.print(statusMessage, panelX + 20, panelY + 40)
    end

    local y = panelY + 70

    if mode == "menu" then
        -- Menu mode: show Host / Join buttons
        love.graphics.setColor(0.9, 0.9, 0.9, alpha)
        love.graphics.print("Izberi način:", panelX + 20, y)
        y = y + 30

        -- Host button
        local hbX, hbY, hbW, hbH = panelX + 20, y, 200, 36
        local hbHover = _G.mousex and _G.mousex >= hbX and _G.mousex <= hbX + hbW
                        and _G.mousey and _G.mousey >= hbY and _G.mousey <= hbY + hbH
        love.graphics.setColor(0.2, 0.5, 0.2, alpha * (hbHover and 1 or 0.8))
        love.graphics.rectangle("fill", hbX, hbY, hbW, hbH, 4, 4, 4, 4)
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.print("🏠 HOST IGRO", hbX + 30, hbY + 8)

        -- Join button
        local jbX, jbY, jbW, jbH = panelX + 260, y, 200, 36
        local jbHover = _G.mousex and _G.mousex >= jbX and _G.mousex <= jbX + jbW
                        and _G.mousey and _G.mousey >= jbY and _G.mousey <= jbY + jbH
        love.graphics.setColor(0.2, 0.3, 0.6, alpha * (jbHover and 1 or 0.8))
        love.graphics.rectangle("fill", jbX, jbY, jbW, jbH, 4, 4, 4, 4)
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.print("🔗 POVEŽI SE", jbX + 30, jbY + 8)

        y = y + 60

        -- Player name input
        love.graphics.setColor(0.7, 0.7, 0.7, alpha)
        love.graphics.print("Ime igralca:", panelX + 20, y)
        love.graphics.setColor(0.2, 0.2, 0.25, alpha)
        love.graphics.rectangle("fill", panelX + 130, y - 2, 200, 22, 3, 3, 3, 3)
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.print(nameBuffer, panelX + 134, y)

    elseif mode == "host" or mode == "join" then
        -- Name input
        love.graphics.setColor(0.7, 0.7, 0.7, alpha)
        love.graphics.print("Ime igralca:", panelX + 20, y)
        love.graphics.setColor(0.2, 0.2, 0.25, alpha)
        love.graphics.rectangle("fill", panelX + 130, y - 2, 250, 22, 3, 3, 3, 3)
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.print(nameBuffer, panelX + 134, y)
        y = y + 30

        if mode == "join" then
            -- IP input
            love.graphics.setColor(0.7, 0.7, 0.7, alpha)
            love.graphics.print("IP naslov:", panelX + 20, y)
            love.graphics.setColor(0.2, 0.2, 0.25, alpha)
            love.graphics.rectangle("fill", panelX + 130, y - 2, 250, 22, 3, 3, 3, 3)
            love.graphics.setColor(1, 1, 1, alpha)
            love.graphics.print(ipBuffer, panelX + 134, y)
            y = y + 30
        end

        -- Port input
        love.graphics.setColor(0.7, 0.7, 0.7, alpha)
        love.graphics.print("Port:", panelX + 20, y)
        love.graphics.setColor(0.2, 0.2, 0.25, alpha)
        love.graphics.rectangle("fill", panelX + 130, y - 2, 100, 22, 3, 3, 3, 3)
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.print(portBuffer, panelX + 134, y)
        y = y + 40

        -- Connect/Start button
        local cbX, cbY, cbW, cbH = panelX + 20, y, 180, 36
        love.graphics.setColor(0.2, 0.5, 0.2, alpha * 0.9)
        love.graphics.rectangle("fill", cbX, cbY, cbW, cbH, 4, 4, 4, 4)
        love.graphics.setColor(1, 1, 1, alpha)
        local btnText = (mode == "host") and "🚀 ZAČNI IGRO" or "🔗 POVEŽI"
        love.graphics.print(btnText, cbX + 30, cbY + 8)

        -- Back button
        local bbX, bbY, bbW, bbH = panelX + 220, y, 100, 36
        love.graphics.setColor(0.4, 0.2, 0.2, alpha * 0.8)
        love.graphics.rectangle("fill", bbX, bbY, bbW, bbH, 4, 4, 4, 4)
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.print("← Nazaj", bbX + 20, bbY + 8)

    elseif mode == "connected" then
        -- Connected: show status
        love.graphics.setColor(0.4, 0.85, 0.4, alpha)
        love.graphics.print("✓ POVEZAN", panelX + 20, y)
        y = y + 30

        love.graphics.setColor(0.9, 0.9, 0.9, alpha)
        love.graphics.print("Ime: " .. nameBuffer, panelX + 20, y)
        y = y + 25

        if _G.GameClient and _G.GameClient.isConnected and _G.GameClient.isConnected() then
            love.graphics.print("Status: Povezan", panelX + 20, y)
        else
            love.graphics.print("Status: Čakam na povezavo...", panelX + 20, y)
        end
        y = y + 40

        -- Disconnect button
        local dbX, dbY, dbW, dbH = panelX + 20, y, 160, 36
        love.graphics.setColor(0.5, 0.2, 0.2, alpha * 0.9)
        love.graphics.rectangle("fill", dbX, dbY, dbW, dbH, 4, 4, 4, 4)
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.print("🔌 Odklopi", dbX + 20, dbY + 8)

    elseif mode == "error" then
        love.graphics.setColor(0.9, 0.4, 0.3, alpha)
        love.graphics.print("✗ NAPAKA", panelX + 20, y)
        y = y + 30
        love.graphics.setColor(0.8, 0.8, 0.8, alpha)
        love.graphics.print(statusMessage, panelX + 20, y)
        y = y + 40

        -- Back button
        local bbX, bbY, bbW, bbH = panelX + 20, y, 100, 36
        love.graphics.setColor(0.4, 0.2, 0.2, alpha * 0.8)
        love.graphics.rectangle("fill", bbX, bbY, bbW, bbH, 4, 4, 4, 4)
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.print("← Nazaj", bbX + 20, bbY + 8)
    end

    -- Hint
    love.graphics.setColor(0.5, 0.5, 0.5, alpha * 0.7)
    love.graphics.print("ESC: Zapri", panelX + panelW - 80, panelY + panelH - 20)

    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

-- Click areas (populated during draw, checked on mousepress)
local clickAreas = {}

function MultiplayerPanel.mousepressed(x, y, button)
    if not visible then return false end
    if button ~= 1 then return false end

    -- Check click areas
    for _, area in ipairs(clickAreas) do
        if x >= area.x and x <= area.x + area.w and y >= area.y and y <= area.y + area.h then
            if area.action == "host_mode" then
                mode = "host"
                UISound.playClick()
            elseif area.action == "join_mode" then
                mode = "join"
                UISound.playClick()
            elseif area.action == "start" then
                if mode == "host" then tryHost()
                else tryJoin() end
            elseif area.action == "back" then
                mode = "menu"
                UISound.playClick()
            elseif area.action == "disconnect" then
                tryDisconnect()
            end
            return true
        end
    end

    -- Click outside panel = close
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    local panelW = 500
    local panelH = 380
    local panelX = (screenW - panelW) / 2
    local panelY = (screenH - panelH) / 2
    if x < panelX or x > panelX + panelW or y < panelY or y > panelY + panelH then
        MultiplayerPanel.toggle()
        return true
    end

    return false
end

function MultiplayerPanel.keypressed(key)
    if not visible then return false end

    if key == "escape" then
        MultiplayerPanel.toggle()
        return true
    end

    -- Text input for name/ip/port
    if inputField == "name" then
        if key == "backspace" then
            nameBuffer = nameBuffer:sub(1, -2)
        end
    elseif inputField == "ip" then
        if key == "backspace" then
            ipBuffer = ipBuffer:sub(1, -2)
        end
    elseif inputField == "port" then
        if key == "backspace" then
            portBuffer = portBuffer:sub(1, -2)
        end
    end

    return false
end

function MultiplayerPanel.textinput(text)
    if not visible then return false end
    if inputField == "name" and #nameBuffer < 20 then
        nameBuffer = nameBuffer .. text
    elseif inputField == "ip" and #ipBuffer < 20 then
        ipBuffer = ipBuffer .. text
    elseif inputField == "port" and #portBuffer < 6 then
        portBuffer = portBuffer .. text
    end
    return false
end

return MultiplayerPanel
