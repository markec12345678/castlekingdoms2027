-- objects/Network/GameClient.lua
-- Stronghold 2027 - Game Client
--
-- Connects to a multiplayer game server. Sends local player actions
-- and receives remote player actions + game state updates.
--
-- Usage:
--   local GameClient = require("objects.Network.GameClient")
--   GameClient.connect("127.0.0.1", 25565, "Player1")
--   GameClient.update(dt)  -- call every frame
--   GameClient.disconnect()

local socket = require("socket")
local NetworkProtocol = require("objects.Network.NetworkProtocol")

local GameClient = {}

local client = nil
local isConnected = false
local isConnecting = false
local playerId = 0
local playerName = ""
local serverAddr = ""
local serverPort = 0
local buffer = ""
local messageQueue = {}     -- Messages received, waiting to be processed
local lastPingTime = 0
local connectTimeout = 0

-- Callbacks (set by game)
GameClient.onMessage = nil       -- function(msg)
GameClient.onConnect = nil       -- function(playerId)
GameClient.onDisconnect = nil    -- function(reason)
GameClient.onError = nil         -- function(err)

-- Connect to server
function GameClient.connect(addr, port, name)
    if isConnected or isConnecting then return false, "Already connected" end

    serverAddr = addr or "127.0.0.1"
    serverPort = port or 25565
    playerName = name or "Player"
    isConnecting = true
    connectTimeout = 5  -- 5 second timeout

    client = socket.tcp()
    client:settimeout(0)
    client:connect(serverAddr, serverPort)

    print(string.format("[GameClient] Connecting to %s:%d as %s...", serverAddr, serverPort, playerName))
    return true
end

-- Disconnect from server
function GameClient.disconnect()
    if not isConnected and not isConnecting then return end

    if client then
        pcall(function()
            local msg = NetworkProtocol.create(NetworkProtocol.MSG.LEAVE, {reason = "Client disconnect"})
            client:send(NetworkProtocol.serialize(msg))
            client:close()
        end)
    end

    client = nil
    isConnected = false
    isConnecting = false
    playerId = 0
    buffer = ""
    print("[GameClient] Disconnected")
end

function GameClient.isConnected()
    return isConnected
end

function GameClient.isConnecting()
    return isConnecting
end

function GameClient.getPlayerId()
    return playerId
end

function GameClient.getPlayerName()
    return playerName
end

-- Send a message to server
function GameClient.send(msgType, data)
    if not isConnected or not client then return false end

    local msg = NetworkProtocol.create(msgType, data)
    local ok, err = pcall(function()
        client:send(NetworkProtocol.serialize(msg))
    end)

    if not ok then
        print("[GameClient] Send error: " .. tostring(err))
        return false
    end
    return true
end

-- Send chat message
function GameClient.sendChat(text)
    return GameClient.send(NetworkProtocol.MSG.CHAT, {text = text})
end

-- Send build action
function GameClient.sendBuild(buildingType, gx, gy)
    return GameClient.send(NetworkProtocol.MSG.BUILD, {
        buildingType = buildingType,
        gx = gx,
        gy = gy,
    })
end

-- Send destroy action
function GameClient.sendDestroy(gx, gy)
    return GameClient.send(NetworkProtocol.MSG.DESTROY, {gx = gx, gy = gy})
end

-- Send move unit order
function GameClient.sendMoveUnit(unitIds, targetGx, targetGy)
    return GameClient.send(NetworkProtocol.MSG.MOVE_UNIT, {
        unitIds = unitIds,
        targetGx = targetGx,
        targetGy = targetGy,
    })
end

-- Send attack order
function GameClient.sendAttack(unitIds, targetGx, targetGy)
    return GameClient.send(NetworkProtocol.MSG.ATTACK, {
        unitIds = unitIds,
        targetGx = targetGx,
        targetGy = targetGy,
    })
end

-- Send ready status
function GameClient.sendReady(ready)
    return GameClient.send(NetworkProtocol.MSG.READY, {ready = ready})
end

-- Update client (call every frame)
function GameClient.update(dt)
    if isConnecting then
        -- Check if connection completed
        local ok, err = client:connect(serverAddr, serverPort)
        if ok or err == "already connected" then
            isConnected = true
            isConnecting = false

            -- Send HELLO
            GameClient.send(NetworkProtocol.MSG.HELLO, {
                playerName = playerName,
                ready = false,
            })

            print("[GameClient] Connected!")
            if GameClient.onConnect then
                GameClient.onConnect(playerId)
            end
        else
            connectTimeout = connectTimeout - dt
            if connectTimeout <= 0 then
                print("[GameClient] Connection timeout")
                isConnecting = false
                if client then client:close() end
                client = nil
                if GameClient.onError then
                    GameClient.onError("Connection timeout")
                end
            end
        end
        return
    end

    if not isConnected then return end

    -- Read data from server
    local data, err = client:receive(8192)
    if data then
        buffer = buffer .. data
    elseif err == "closed" then
        print("[GameClient] Server closed connection")
        GameClient.disconnect()
        if GameClient.onDisconnect then
            GameClient.onDisconnect("Server closed")
        end
        return
    end

    -- Process complete messages
    while true do
        local msg, consumed = NetworkProtocol.deserialize(buffer)
        if not msg or consumed == 0 then break end
        buffer = buffer:sub(consumed + 1)

        if NetworkProtocol.isValid(msg) then
            GameClient.handleMessage(msg)
        end
    end

    -- Send periodic pings
    lastPingTime = lastPingTime + dt
    if lastPingTime > 5 then
        lastPingTime = 0
        GameClient.send(NetworkProtocol.MSG.PING)
    end
end

-- Handle received message
function GameClient.handleMessage(msg)
    if msg.type == NetworkProtocol.MSG.WELCOME then
        playerId = msg.playerId or 0
        print(string.format("[GameClient] Welcome! Player ID: %d", playerId))
        if GameClient.onConnect then
            GameClient.onConnect(playerId)
        end

    elseif msg.type == NetworkProtocol.MSG.KICK then
        print("[GameClient] Kicked: " .. tostring(msg.reason))
        GameClient.disconnect()
        if GameClient.onDisconnect then
            GameClient.onDisconnect("Kicked: " .. tostring(msg.reason))
        end
    end

    -- Forward to game callback
    if GameClient.onMessage then
        GameClient.onMessage(msg)
    end
end

return GameClient
