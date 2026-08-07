-- states/ui/multiplayer/lobby.lua
-- Castle Kingdoms 2027 - Multiplayer Lobby UI

local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")
local base = require("states.ui.base")
local GameServer = require("objects.Network.GameServer")
local GameClient = require("objects.Network.GameClient")
local NetworkProtocol = require("objects.Network.NetworkProtocol")

local Lobby = {}

states.STATE_MULTIPLAYER_LOBBY = 21

local lobbyFrame = nil
local playerListText = nil
local ipInput = nil
local nameInput = nil
local statusText = nil
local players = {}

function Lobby.init()
    if lobbyFrame then return end

    local w, h = love.graphics.getDimensions()
    local frameW = 600
    local frameH = 500
    local frameX = (w - frameW) / 2
    local frameY = (h - frameH) / 2

    lobbyFrame = loveframes.Create("frame")
    lobbyFrame:SetName("Multiplayer Lobby - Castle Kingdoms 2027")
    lobbyFrame:SetSize(frameW, frameH)
    lobbyFrame:SetPos(frameX, frameY)
    lobbyFrame:SetState(states.STATE_MULTIPLAYER_LOBBY)
    lobbyFrame:ShowCloseButton(false)

    local nameLabel = loveframes.Create("text", lobbyFrame)
    nameLabel:SetPos(20, 40)
    nameLabel:SetText("Your Name:")

    nameInput = loveframes.Create("textinput", lobbyFrame)
    nameInput:SetPos(120, 35)
    nameInput:SetSize(200, 30)
    nameInput:SetText("Player" .. math.random(100, 999))

    local ipLabel = loveframes.Create("text", lobbyFrame)
    ipLabel:SetPos(20, 80)
    ipLabel:SetText("Server IP:")

    ipInput = loveframes.Create("textinput", lobbyFrame)
    ipInput:SetPos(120, 75)
    ipInput:SetSize(200, 30)
    ipInput:SetText("127.0.0.1")

    local portLabel = loveframes.Create("text", lobbyFrame)
    portLabel:SetPos(330, 80)
    portLabel:SetText("Port:")

    local portInput = loveframes.Create("textinput", lobbyFrame)
    portInput:SetPos(370, 75)
    portInput:SetSize(80, 30)
    portInput:SetText("25565")

    local hostButton = loveframes.Create("button", lobbyFrame)
    hostButton:SetPos(20, 120)
    hostButton:SetSize(150, 35)
    hostButton:SetText("Host Game")
    hostButton.OnClick = function()
        local name = nameInput:GetText()
        local port = tonumber(portInput:GetText()) or 25565
        Lobby.hostGame(name, port)
    end

    local joinButton = loveframes.Create("button", lobbyFrame)
    joinButton:SetPos(180, 120)
    joinButton:SetSize(150, 35)
    joinButton:SetText("Join Game")
    joinButton.OnClick = function()
        local name = nameInput:GetText()
        local ip = ipInput:GetText()
        local port = tonumber(portInput:GetText()) or 25565
        Lobby.joinGame(ip, port, name)
    end

    local disconnectButton = loveframes.Create("button", lobbyFrame)
    disconnectButton:SetPos(340, 120)
    disconnectButton:SetSize(150, 35)
    disconnectButton:SetText("Disconnect")
    disconnectButton.OnClick = function()
        Lobby.disconnect()
    end

    local listLabel = loveframes.Create("text", lobbyFrame)
    listLabel:SetPos(20, 170)
    listLabel:SetText("Connected Players:")

    playerListText = loveframes.Create("text", lobbyFrame)
    playerListText:SetPos(20, 195)
    playerListText:SetSize(400, 200)
    playerListText:SetText("Not connected")

    local startButton = loveframes.Create("button", lobbyFrame)
    startButton:SetPos(20, 410)
    startButton:SetSize(200, 35)
    startButton:SetText("Start Game (Host)")
    startButton.OnClick = function()
        Lobby.startGame()
    end

    local backButton = loveframes.Create("button", lobbyFrame)
    backButton:SetPos(230, 410)
    backButton:SetSize(150, 35)
    backButton:SetText("Back to Menu")
    backButton.OnClick = function()
        Lobby.disconnect()
        loveframes.SetState(states.STATE_MAIN_MENU)
    end

    statusText = loveframes.Create("text", lobbyFrame)
    statusText:SetPos(20, 455)
    statusText:SetSize(560, 30)
    statusText:SetText("")

    -- Set up client callbacks
    GameClient.onMessage = function(msg)
        if msg.type == NetworkProtocol.MSG.PLAYER_LIST then
            players = msg.players or {}
            Lobby.updatePlayerList()
        elseif msg.type == NetworkProtocol.MSG.START_GAME then
            Lobby.enterGame()
        elseif msg.type == NetworkProtocol.MSG.JOIN then
            Lobby.setStatus("Player joined: " .. tostring(msg.playerName))
        elseif msg.type == NetworkProtocol.MSG.LEAVE then
            Lobby.setStatus("Player left: " .. tostring(msg.playerName))
        end
    end

    GameClient.onConnect = function(pid)
        Lobby.setStatus("Connected! Player ID: " .. tostring(pid))
    end

    GameClient.onDisconnect = function(reason)
        Lobby.setStatus("Disconnected: " .. tostring(reason))
    end

    GameClient.onError = function(err)
        Lobby.setStatus("Error: " .. tostring(err))
    end
end

function Lobby.show()
    Lobby.init()
    loveframes.SetState(states.STATE_MULTIPLAYER_LOBBY)
end

function Lobby.hostGame(name, port)
    local ok, err = GameServer.start(port, name)
    if not ok then
        Lobby.setStatus("Failed to host: " .. tostring(err))
        return
    end
    GameClient.connect("127.0.0.1", port, name)
    local localIP = GameServer.getLocalIP()
    Lobby.setStatus(string.format("Hosting on port %d (LAN IP: %s)", port, tostring(localIP)))
end

function Lobby.joinGame(ip, port, name)
    GameClient.connect(ip, port, name)
    Lobby.setStatus("Connecting to " .. ip .. ":" .. port .. "...")
end

function Lobby.disconnect()
    GameClient.disconnect()
    GameServer.stop()
    players = {}
    Lobby.updatePlayerList()
    Lobby.setStatus("Disconnected")
end

function Lobby.startGame()
    if not GameServer.isRunning() then
        Lobby.setStatus("Only the host can start the game")
        return
    end
    local msg = NetworkProtocol.create(NetworkProtocol.MSG.START_GAME, {})
    GameServer.broadcast(msg)
    Lobby.enterGame()
end

function Lobby.enterGame()
    local Gamestate = require("libraries.gamestate")
    local game = require("states.game")
    loveframes.SetState(states.STATE_INGAME_CONSTRUCTION)
    _G.loaded = false
    if _G.state then _G.state:destroy() end
    local State = require("objects.State")
    _G.state = State:new()
    if _G.state then _G.state.initialized = false end
    local SaveManager = require("objects.Controllers.SaveManager")
    Gamestate.switch(game, SaveManager.defaultMap.name, 8, 8)
    Lobby.setStatus("Game started!")
end

function Lobby.updatePlayerList()
    if not playerListText then return end
    if #players == 0 then
        playerListText:SetText("No players connected")
        return
    end
    local lines = {}
    for _, p in ipairs(players) do
        local status = p.ready and " [Ready]" or " [Not Ready]"
        local hostTag = p.isHost and " (Host)" or ""
        table.insert(lines, string.format("Player %d: %s%s%s", p.id, p.name, hostTag, status))
    end
    playerListText:SetText(table.concat(lines, "\n"))
end

function Lobby.setStatus(text)
    if statusText then statusText:SetText(text) end
end

function Lobby.update(dt)
    GameServer.update(dt)
    GameClient.update(dt)
end

return Lobby
