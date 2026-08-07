-- objects/Network/NetworkProtocol.lua
-- Castle Kingdoms 2027 - Network Protocol
--
-- Defines the message format and serialization for multiplayer communication.
-- Uses a simple length-prefixed JSON protocol over TCP.

local NetworkProtocol = {}

-- Message types
NetworkProtocol.MSG = {
    HELLO       = "HELLO",
    WELCOME     = "WELCOME",
    JOIN        = "JOIN",
    LEAVE       = "LEAVE",
    CHAT        = "CHAT",
    STATE_SYNC  = "STATE_SYNC",
    BUILD       = "BUILD",
    DESTROY     = "DESTROY",
    MOVE_UNIT   = "MOVE_UNIT",
    ATTACK      = "ATTACK",
    RESOURCE    = "RESOURCE",
    PING        = "PING",
    PONG        = "PONG",
    KICK        = "KICK",
    PLAYER_LIST = "PLAYER_LIST",
    READY       = "READY",
    START_GAME  = "START_GAME",
    GAME_STATE  = "GAME_STATE",
    -- Diplomacy messages
    DECLARE_WAR     = "DECLARE_WAR",
    PROPOSE_ALLIANCE = "PROPOSE_ALLIANCE",
    PROPOSE_PEACE   = "PROPOSE_PEACE",
    ACCEPT_PROPOSAL = "ACCEPT_PROPOSAL",
    REJECT_PROPOSAL = "REJECT_PROPOSAL",
    BREAK_ALLIANCE  = "BREAK_ALLIANCE",
    DIPLOMACY_SYNC  = "DIPLOMACY_SYNC",
    -- Trade messages
    PROPOSE_TRADE   = "PROPOSE_TRADE",
    ACCEPT_TRADE    = "ACCEPT_TRADE",
    REJECT_TRADE    = "REJECT_TRADE",
    CANCEL_TRADE    = "CANCEL_TRADE",
    GIFT_RESOURCES  = "GIFT_RESOURCES",
    TRADE_SYNC      = "TRADE_SYNC",
}

-- Protocol version
NetworkProtocol.VERSION = 1

-- Simple JSON encoder (no external dependency)
local function jsonEncode(val)
    local t = type(val)
    if t == "nil" then return "null"
    elseif t == "boolean" then return val and "true" or "false"
    elseif t == "number" then
        if val ~= val then return "null" end  -- NaN
        if val == math.huge then return "1e999" end
        if val == -math.huge then return "-1e999" end
        return tostring(val)
    elseif t == "string" then
        local escaped = val:gsub('\\', '\\\\')
                           :gsub('"', '\\"')
                           :gsub('\n', '\\n')
                           :gsub('\r', '\\r')
                           :gsub('\t', '\\t')
        return '"' .. escaped .. '"'
    elseif t == "table" then
        -- Check if array or object
        local isArray = true
        local count = 0
        for k, _ in pairs(val) do
            count = count + 1
            if type(k) ~= "number" then isArray = false break end
        end
        if count == 0 then return "{}" end

        if isArray then
            local parts = {}
            for i = 1, count do
                parts[i] = jsonEncode(val[i])
            end
            return "[" .. table.concat(parts, ",") .. "]"
        else
            local parts = {}
            for k, v in pairs(val) do
                parts[#parts + 1] = jsonEncode(tostring(k)) .. ":" .. jsonEncode(v)
            end
            return "{" .. table.concat(parts, ",") .. "}"
        end
    end
    return "null"
end

-- Simple JSON decoder
local function jsonDecode(str, pos)
    pos = pos or 1
    local function skipWhitespace()
        while pos <= #str do
            local c = str:sub(pos, pos)
            if c == " " or c == "\t" or c == "\n" or c == "\r" then
                pos = pos + 1
            else
                break
            end
        end
    end

    local function parseValue()
        skipWhitespace()
        local c = str:sub(pos, pos)
        if c == "{" then return parseObject()
        elseif c == "[" then return parseArray()
        elseif c == '"' then return parseString()
        elseif c == "t" or c == "f" then return parseBool()
        elseif c == "n" then return parseNull()
        else return parseNumber() end
    end

    local function parseObject()
        pos = pos + 1  -- skip {
        local obj = {}
        skipWhitespace()
        if str:sub(pos, pos) == "}" then pos = pos + 1 return obj end
        while true do
            skipWhitespace()
            local key = parseString()
            skipWhitespace()
            pos = pos + 1  -- skip :
            obj[key] = parseValue()
            skipWhitespace()
            local c = str:sub(pos, pos)
            if c == "}" then pos = pos + 1 break
            elseif c == "," then pos = pos + 1
            else break end
        end
        return obj
    end

    local function parseArray()
        pos = pos + 1  -- skip [
        local arr = {}
        skipWhitespace()
        if str:sub(pos, pos) == "]" then pos = pos + 1 return arr end
        while true do
            arr[#arr + 1] = parseValue()
            skipWhitespace()
            local c = str:sub(pos, pos)
            if c == "]" then pos = pos + 1 break
            elseif c == "," then pos = pos + 1
            else break end
        end
        return arr
    end

    local function parseString()
        pos = pos + 1  -- skip "
        local result = {}
        while pos <= #str do
            local c = str:sub(pos, pos)
            if c == '"' then pos = pos + 1 break
            elseif c == "\\" then
                pos = pos + 1
                local esc = str:sub(pos, pos)
                if esc == "n" then result[#result + 1] = "\n"
                elseif esc == "r" then result[#result + 1] = "\r"
                elseif esc == "t" then result[#result + 1] = "\t"
                elseif esc == '"' then result[#result + 1] = '"'
                elseif esc == "\\" then result[#result + 1] = "\\"
                else result[#result + 1] = esc end
                pos = pos + 1
            else
                result[#result + 1] = c
                pos = pos + 1
            end
        end
        return table.concat(result)
    end

    local function parseNumber()
        local start = pos
        while pos <= #str do
            local c = str:sub(pos, pos)
            if c:match("[%-%d%.eE+]") then pos = pos + 1
            else break end
        end
        return tonumber(str:sub(start, pos - 1))
    end

    local function parseBool()
        if str:sub(pos, pos + 3) == "true" then pos = pos + 4 return true end
        if str:sub(pos, pos + 4) == "false" then pos = pos + 5 return false end
        return nil
    end

    local function parseNull()
        if str:sub(pos, pos + 3) == "null" then pos = pos + 4 return nil end
        return nil
    end

    return parseValue()
end

-- Serialize a message table to bytes
function NetworkProtocol.serialize(msg)
    msg.version = NetworkProtocol.VERSION
    msg.timestamp = os.time()
    local payload = jsonEncode(msg)
    local len = #payload
    local prefix = string.pack("<I4", len)
    return prefix .. payload
end

-- Deserialize bytes to a message table
function NetworkProtocol.deserialize(data)
    if #data < 4 then return nil, 0 end
    local len = string.unpack("<I4", data:sub(1, 4))
    if #data < 4 + len then return nil, 0 end
    local payload = data:sub(5, 4 + len)
    local ok, msg = pcall(jsonDecode, payload)
    if not ok or type(msg) ~= "table" then return nil, 4 + len end
    return msg, 4 + len
end

-- Create a message
function NetworkProtocol.create(msgType, data)
    local msg = data or {}
    msg.type = msgType
    msg.version = NetworkProtocol.VERSION
    msg.timestamp = os.time()
    return msg
end

-- Validate message version
function NetworkProtocol.isValid(msg)
    return msg and msg.version == NetworkProtocol.VERSION
end

NetworkProtocol._jsonEncode = jsonEncode
NetworkProtocol._jsonDecode = jsonDecode

return NetworkProtocol
