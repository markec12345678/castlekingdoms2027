-- objects/Network/GameServer.lua
-- Castle Kingdoms 2027 - Game Server
--
-- Hosts a multiplayer game. Accepts client connections, broadcasts
-- game state, and relays player actions between clients.
--
-- Usage:
--   local GameServer = require("objects.Network.GameServer")
--   GameServer.start(25565, "Player1")
--   GameServer.update(dt)  -- call every frame
--   GameServer.stop()

local socket = require("socket")
local NetworkProtocol = require("objects.Network.NetworkProtocol")

local GameServer = {}

local server = nil
local clients = {}        -- {clientSocket = {id, name, ready, addr}}
local nextPlayerId = 1
local hostPlayerName = ""
local isRunning = false
local port = 25565
local incomingBuffer = {}
local outgoingQueue = {}
local lastPingTime = 0

-- Start the server
function GameServer.start(listenPort, hostName)
    if isRunning then return false, "Server already running" end

    port = listenPort or 25565
    hostPlayerName = hostName or "Host"

    server = socket.tcp()
    server:setoption("reuseaddr", true)
    local ok, err = server:bind("*", port)
    if not ok then
        print("[GameServer] Failed to bind: " .. tostring(err))
        return false, err
    end
    server:listen(8)
    server:settimeout(0)  -- non-blocking

    isRunning = true
    nextPlayerId = 1

    -- Host is player 1
    clients["host"] = {
        id = 1,
        name = hostPlayerName,
        ready = true,
        addr = "localhost",
        isHost = true,
    }
    nextPlayerId = 2

    print(string.format("[GameServer] Started on port %d (host: %s)", port, hostPlayerName))
    return true
end

-- Stop the server
function GameServer.stop()
    if not isRunning then return end

    -- Notify all clients
    for clientSocket, client in pairs(clients) do
        if clientSocket ~= "host" then
            pcall(function()
                local msg = NetworkProtocol.create(NetworkProtocol.MSG.KICK, {reason = "Server shutting down"})
                clientSocket:send(NetworkProtocol.serialize(msg))
                clientSocket:close()
            end)
        end
    end

    if server then server:close() end
    server = nil
    clients = {}
    isRunning = false
    print("[GameServer] Stopped")
end

function GameServer.isRunning()
    return isRunning
end

function GameServer.getPort()
    return port
end

function GameServer.getClientCount()
    local count = 0
    for _, c in pairs(clients) do
        count = count + 1
    end
    return count
end

function GameServer.getClients()
    return clients
end

-- Accept new connections
local function acceptNewClients()
    if not server then return end

    local client, err = server:accept()
    while client do
        client:settimeout(0)
        local addr = client:getpeername()
        local playerId = nextPlayerId
        nextPlayerId = nextPlayerId + 1

        clients[client] = {
            id = playerId,
            name = "Player" .. playerId,
            ready = false,
            addr = addr,
            buffer = "",
        }

        print(string.format("[GameServer] Client connected from %s (id=%d)", tostring(addr), playerId))

        -- Send WELCOME
        local welcome = NetworkProtocol.create(NetworkProtocol.MSG.WELCOME, {
            playerId = playerId,
            hostName = hostPlayerName,
        })
        client:send(NetworkProtocol.serialize(welcome))

        -- Send current player list
        GameServer.broadcastPlayerList()

        client = server:accept()
    end
end

-- Read data from a client
local function readFromClient(clientSocket, client)
    local data, err = clientSocket:receive(8192)
    if data then
        client.buffer = client.buffer .. data
    elseif err == "closed" then
        GameServer.disconnectClient(clientSocket, "Connection closed")
        return
    end

    -- Process complete messages
    while true do
        local msg, consumed = NetworkProtocol.deserialize(client.buffer)
        if not msg or consumed == 0 then break end
        client.buffer = client.buffer:sub(consumed + 1)
        GameServer.handleMessage(clientSocket, client, msg)
    end
end

-- Handle incoming message from client
function GameServer.handleMessage(clientSocket, client, msg)
    if not NetworkProtocol.isValid(msg) then
        print("[GameServer] Invalid message from client " .. client.id)
        return
    end

    if msg.type == NetworkProtocol.MSG.HELLO then
        client.name = msg.playerName or client.name
        client.ready = msg.ready or false
        print(string.format("[GameServer] Player %d set name: %s", client.id, client.name))

        -- Broadcast JOIN to all clients
        local joinMsg = NetworkProtocol.create(NetworkProtocol.MSG.JOIN, {
            playerId = client.id,
            playerName = client.name,
        })
        GameServer.broadcast(joinMsg)

        GameServer.broadcastPlayerList()

    elseif msg.type == NetworkProtocol.MSG.CHAT then
        -- Relay chat to all clients
        local chatMsg = NetworkProtocol.create(NetworkProtocol.MSG.CHAT, {
            playerId = client.id,
            playerName = client.name,
            text = msg.text,
        })
        GameServer.broadcast(chatMsg)

    elseif msg.type == NetworkProtocol.MSG.BUILD then
        -- Relay build action to all other clients
        local buildMsg = NetworkProtocol.create(NetworkProtocol.MSG.BUILD, {
            playerId = client.id,
            buildingType = msg.buildingType,
            gx = msg.gx,
            gy = msg.gy,
        })
        GameServer.broadcast(buildMsg)

    elseif msg.type == NetworkProtocol.MSG.DESTROY then
        local destroyMsg = NetworkProtocol.create(NetworkProtocol.MSG.DESTROY, {
            playerId = client.id,
            gx = msg.gx,
            gy = msg.gy,
        })
        GameServer.broadcast(destroyMsg)

    elseif msg.type == NetworkProtocol.MSG.MOVE_UNIT then
        local moveMsg = NetworkProtocol.create(NetworkProtocol.MSG.MOVE_UNIT, {
            playerId = client.id,
            unitIds = msg.unitIds,
            targetGx = msg.targetGx,
            targetGy = msg.targetGy,
        })
        GameServer.broadcast(moveMsg)

    elseif msg.type == NetworkProtocol.MSG.ATTACK then
        local attackMsg = NetworkProtocol.create(NetworkProtocol.MSG.ATTACK, {
            playerId = client.id,
            unitIds = msg.unitIds,
            targetGx = msg.targetGx,
            targetGy = msg.targetGy,
        })
        GameServer.broadcast(attackMsg)

    elseif msg.type == NetworkProtocol.MSG.READY then
        client.ready = msg.ready or false
        GameServer.broadcastPlayerList()

    elseif msg.type == NetworkProtocol.MSG.PING then
        local pong = NetworkProtocol.create(NetworkProtocol.MSG.PONG)
        clientSocket:send(NetworkProtocol.serialize(pong))

    elseif msg.type == NetworkProtocol.MSG.PONG then
        -- Update latency tracking
        client.lastPong = os.time()
    end
end

-- Disconnect a client
function GameServer.disconnectClient(clientSocket, reason)
    local client = clients[clientSocket]
    if not client then return end

    print(string.format("[GameServer] Player %d (%s) disconnected: %s", client.id, client.name, reason))

    pcall(function() clientSocket:close() end)
    clients[clientSocket] = nil

    -- Broadcast LEAVE
    local leaveMsg = NetworkProtocol.create(NetworkProtocol.MSG.LEAVE, {
        playerId = client.id,
        playerName = client.name,
        reason = reason,
    })
    GameServer.broadcast(leaveMsg)
    GameServer.broadcastPlayerList()
end

-- Broadcast message to all clients
function GameServer.broadcast(msg)
    local data = NetworkProtocol.serialize(msg)
    for clientSocket, _ in pairs(clients) do
        if clientSocket ~= "host" and type(clientSocket) == "userdata" then
            pcall(function() clientSocket:send(data) end)
        end
    end
end

-- Broadcast player list
function GameServer.broadcastPlayerList()
    local players = {}
    for _, client in pairs(clients) do
        table.insert(players, {
            id = client.id,
            name = client.name,
            ready = client.ready,
            isHost = client.isHost or false,
        })
    end

    local msg = NetworkProtocol.create(NetworkProtocol.MSG.PLAYER_LIST, {players = players})
    GameServer.broadcast(msg)
end

-- Send game state to all clients
function GameServer.broadcastGameState(state)
    local msg = NetworkProtocol.create(NetworkProtocol.MSG.GAME_STATE, {state = state})
    GameServer.broadcast(msg)
end

-- Update server (call every frame)
function GameServer.update(dt)
    if not isRunning then return end

    -- Accept new connections
    acceptNewClients()

    -- Read from all clients
    for clientSocket, client in pairs(clients) do
        if clientSocket ~= "host" and type(clientSocket) == "userdata" then
            readFromClient(clientSocket, client)
        end
    end

    -- Send periodic pings
    lastPingTime = lastPingTime + dt
    if lastPingTime > 5 then
        lastPingTime = 0
        local pingMsg = NetworkProtocol.create(NetworkProtocol.MSG.PING)
        GameServer.broadcast(pingMsg)
    end
end

-- Get local IP address
function GameServer.getLocalIP()
    local s = socket.udp()
    s:setpeername("8.8.8.8", 53)
    local ip = s:getsockname()
    s:close()
    return ip
end

return GameServer
