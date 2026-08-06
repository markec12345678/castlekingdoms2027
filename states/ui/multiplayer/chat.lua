-- states/ui/multiplayer/chat.lua
-- Stronghold 2027 - In-Game Chat System
--
-- Shows a chat overlay during multiplayer games.
-- Press Enter to open chat, type message, Enter to send.
-- Press Escape to close chat without sending.

local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")
local GameClient = require("objects.Network.GameClient")
local GameServer = require("objects.Network.GameServer")
local NetworkProtocol = require("objects.Network.NetworkProtocol")

local Chat = {}

local chatMessages = {}     -- {playerName, text, timestamp}
local maxMessages = 10
local chatInput = nil
local chatFrame = nil
local chatText = nil
local isVisible = false
local isInputActive = false

-- Initialize chat UI
function Chat.init()
    if chatFrame then return end

    local w, h = love.graphics.getDimensions()

    -- Chat background frame (bottom-left, above action bar)
    chatFrame = loveframes.Create("frame")
    chatFrame:SetName("Chat")
    chatFrame:SetSize(400, 200)
    chatFrame:SetPos(10, h - 350)
    chatFrame:SetState(states.STATE_INGAME_CONSTRUCTION)
    chatFrame:ShowCloseButton(false)
    chatFrame:SetVisible(false)

    -- Chat messages display
    chatText = loveframes.Create("text", chatFrame)
    chatText:SetPos(10, 30)
    chatText:SetSize(380, 130)

    -- Chat input
    chatInput = loveframes.Create("textinput", chatFrame)
    chatInput:SetPos(10, 165)
    chatInput:SetSize(380, 25)
    chatInput.OnEnter = function()
        local text = chatInput:GetText()
        if text and #text > 0 then
            Chat.sendMessage(text)
        end
        chatInput:SetText("")
        Chat.setInputActive(false)
    end
    chatInput.OnEscape = function()
        chatInput:SetText("")
        Chat.setInputActive(false)
    end

    -- Set up message handler
    if GameClient.onMessage then
        local origCallback = GameClient.onMessage
        GameClient.onMessage = function(msg)
            origCallback(msg)
            if msg.type == NetworkProtocol.MSG.CHAT then
                Chat.addMessage(msg.playerName or "Unknown", msg.text or "")
            end
        end
    else
        GameClient.onMessage = function(msg)
            if msg.type == NetworkProtocol.MSG.CHAT then
                Chat.addMessage(msg.playerName or "Unknown", msg.text or "")
            end
        end
    end
end

-- Add a message to chat
function Chat.addMessage(playerName, text)
    table.insert(chatMessages, {
        playerName = playerName,
        text = text,
        timestamp = os.time(),
    })

    -- Keep only last N messages
    while #chatMessages > maxMessages do
        table.remove(chatMessages, 1)
    end

    Chat.updateDisplay()
end

-- Update chat display
function Chat.updateDisplay()
    if not chatText then return end

    local lines = {}
    for _, msg in ipairs(chatMessages) do
        local timeStr = os.date("%H:%M", msg.timestamp)
        table.insert(lines, string.format("[%s] %s: %s", timeStr, msg.playerName, msg.text))
    end

    chatText:SetText(table.concat(lines, "\n"))
end

-- Send a chat message
function Chat.sendMessage(text)
    if GameClient.isConnected() then
        GameClient.sendChat(text)
    elseif GameServer.isRunning() then
        -- Host only - add locally
        Chat.addMessage("Host", text)
    end
end

-- Toggle chat visibility
function Chat.toggle()
    isVisible = not isVisible
    if chatFrame then
        chatFrame:SetVisible(isVisible)
    end
end

-- Show chat
function Chat.show()
    isVisible = true
    if chatFrame then
        chatFrame:SetVisible(true)
    end
end

-- Hide chat
function Chat.hide()
    isVisible = false
    if chatFrame then
        chatFrame:SetVisible(false)
    end
    Chat.setInputActive(false)
end

-- Activate/deactivate input
function Chat.setInputActive(active)
    isInputActive = active
    if chatInput then
        if active then
            chatInput:Focus()
        else
            chatInput:ClearFocus()
        end
    end
end

function Chat.isInputActive()
    return isInputActive
end

function Chat.isVisible()
    return isVisible
end

-- Key handler (call from game:keypressed)
function Chat.keypressed(key)
    if key == "return" or key == "kpenter" then
        if not isVisible then
            Chat.show()
        end
        Chat.setInputActive(not isInputActive)
        return true
    elseif key == "escape" and isInputActive then
        Chat.setInputActive(false)
        if chatInput then chatInput:SetText("") end
        return true
    end
    return false
end

-- Update (call from game loop)
function Chat.update(dt)
    -- Network updates handled by GameClient/GameServer
end

-- Draw debug info
function Chat.draw()
    if not isVisible then return end

    -- Draw a semi-transparent background
    local w, h = love.graphics.getDimensions()
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 5, h - 355, 410, 210)
    love.graphics.setColor(1, 1, 1, 1)
end

-- Clear messages
function Chat.clear()
    chatMessages = {}
    Chat.updateDisplay()
end

return Chat
