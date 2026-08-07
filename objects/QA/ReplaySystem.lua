-- objects/QA/ReplaySystem.lua
-- Castle Kingdoms 2027 - Replay System
--
-- Records game inputs and state snapshots for playback.
-- Useful for:
-- - Trailer recording (play back epic moments)
-- - Bug reproduction (send replay with crash report)
-- - Competitive play (review matches)
-- - Tutorial creation (scripted scenarios)
--
-- Recording format:
-- - Header: game version, map, timestamp, player info
-- - Input events: mouse clicks, key presses, with timestamps
-- - State snapshots: every 5 seconds (for seeking)
--
-- Usage:
--   local Replay = require("objects.QA.ReplaySystem")
--   Replay.init()
--   Replay.startRecording("my_replay")
--   Replay.update(dt)
--   Replay.stopRecording()
--   Replay.playback("my_replay")

local Replay = {}

local RECORDING_PATH = "replays/"
local SNAPSHOT_INTERVAL = 5.0  -- seconds between state snapshots
local MAX_REPLAY_LENGTH = 3600  -- 1 hour max

local initialized = false
local isRecording = false
local isPlaying = false
local recordBuffer = {}
local playbackBuffer = {}
local playbackIndex = 1
local recordTime = 0
local playbackTime = 0
local lastSnapshotTime = 0
local currentReplayName = ""
local playbackSpeed = 1.0
local paused = false

-- Callbacks
Replay.onPlaybackEvent = nil  -- function(event) - replay input event
Replay.onPlaybackComplete = nil
Replay.onSnapshotRestore = nil  -- function(snapshot)

-- Initialize
function Replay.init()
    if initialized then return end
    initialized = true
    love.filesystem.createDirectory(RECORDING_PATH)
    print("[ReplaySystem] Initialized (save dir: " .. RECORDING_PATH .. ")")
end

-- Start recording
function Replay.startRecording(name)
    if isRecording then return false end
    if isPlaying then return false end

    currentReplayName = name or ("replay_" .. os.date("%Y%m%d_%H%M%S"))
    recordBuffer = {}
    recordTime = 0
    lastSnapshotTime = 0
    isRecording = true

    -- Record header
    local header = {
        type = "header",
        timestamp = os.time(),
        version = _G.version or "1.0",
        map = _G.state and _G.state.mapName or "unknown",
        playerName = "Player",
        gameMode = "freebuild",
    }
    table.insert(recordBuffer, header)

    -- Record initial snapshot
    Replay._takeSnapshot()

    print("[ReplaySystem] Recording started: " .. currentReplayName)
    return true
end

-- Stop recording and save
function Replay.stopRecording()
    if not isRecording then return false end

    isRecording = false

    -- Save to file
    local filename = RECORDING_PATH .. currentReplayName .. ".replay"
    local file = love.filesystem.newFile(filename)
    if file:open("w") then
        -- Simple serialization
        for _, event in ipairs(recordBuffer) do
            local line = Replay._serializeEvent(event)
            file:write(line .. "\n")
        end
        file:close()
        print(string.format("[ReplaySystem] Recording saved: %s (%d events, %.1fs)",
            currentReplayName, #recordBuffer, recordTime))
    end

    return true
end

-- Record an input event
function Replay.recordEvent(eventType, data)
    if not isRecording then return end

    local event = {
        type = eventType,
        time = recordTime,
        data = data or {},
    }
    table.insert(recordBuffer, event)
end

-- Record mouse press
function Replay.recordMousePress(x, y, button)
    Replay.recordEvent("mousepressed", {x = x, y = y, button = button})
end

-- Record mouse release
function Replay.recordMouseRelease(x, y, button)
    Replay.recordEvent("mousereleased", {x = x, y = y, button = button})
end

-- Record key press
function Replay.recordKeyPress(key)
    Replay.recordEvent("keypressed", {key = key})
end

-- Take a state snapshot
function Replay._takeSnapshot()
    if not _G.state then return end

    local snapshot = {
        type = "snapshot",
        time = recordTime,
        gold = _G.state.gold or 0,
        popularity = _G.state.popularity or 0,
        population = _G.state.population or 0,
        maxPopulation = _G.state.maxPopulation or 0,
        resources = {},
        viewX = _G.state.viewXview or 0,
        viewY = _G.state.viewYview or 0,
        scaleX = _G.state.scaleX or 1,
    }

    -- Copy resources
    if _G.state.resources then
        for k, v in pairs(_G.state.resources) do
            snapshot.resources[k] = v
        end
    end

    table.insert(recordBuffer, snapshot)
    lastSnapshotTime = recordTime
end

-- Update recording
function Replay.update(dt)
    if not initialized then return end

    if isRecording then
        recordTime = recordTime + dt

        -- Take periodic snapshots
        if recordTime - lastSnapshotTime >= SNAPSHOT_INTERVAL then
            Replay._takeSnapshot()
        end

        -- Stop at max length
        if recordTime >= MAX_REPLAY_LENGTH then
            Replay.stopRecording()
        end

    elseif isPlaying and not paused then
        playbackTime = playbackTime + dt * playbackSpeed

        -- Process events up to current playback time
        while playbackIndex <= #playbackBuffer do
            local event = playbackBuffer[playbackIndex]
            if event.time and event.time > playbackTime then
                break
            end

            Replay._processPlaybackEvent(event)
            playbackIndex = playbackIndex + 1
        end

        -- Check if playback complete
        if playbackIndex > #playbackBuffer then
            Replay.stopPlayback()
            if Replay.onPlaybackComplete then
                Replay.onPlaybackComplete()
            end
        end
    end
end

-- Process a playback event
function Replay._processPlaybackEvent(event)
    if event.type == "snapshot" then
        -- Restore state snapshot
        if Replay.onSnapshotRestore then
            Replay.onSnapshotRestore(event)
        end
    elseif event.type == "mousepressed" or event.type == "mousereleased"
        or event.type == "keypressed" then
        -- Forward to game callback
        if Replay.onPlaybackEvent then
            Replay.onPlaybackEvent(event)
        end
    end
end

-- Start playback
function Replay.startPlayback(name)
    if isRecording then return false end
    if isPlaying then return false end

    local filename = RECORDING_PATH .. name .. ".replay"
    local file = love.filesystem.newFile(filename)
    if not file:open("r") then
        print("[ReplaySystem] Replay not found: " .. name)
        return false
    end

    playbackBuffer = {}
    playbackIndex = 1
    playbackTime = 0

    -- Parse file
    for line in file:lines() do
        local event = Replay._deserializeEvent(line)
        if event then
            table.insert(playbackBuffer, event)
        end
    end
    file:close()

    isPlaying = true
    paused = false
    currentReplayName = name
    print(string.format("[ReplaySystem] Playback started: %s (%d events)", name, #playbackBuffer))
    return true
end

-- Stop playback
function Replay.stopPlayback()
    if not isPlaying then return end
    isPlaying = false
    print("[ReplaySystem] Playback stopped")
end

-- Pause/resume playback
function Replay.pausePlayback()
    paused = true
end

function Replay.resumePlayback()
    paused = false
end

-- Set playback speed
function Replay.setPlaybackSpeed(speed)
    playbackSpeed = math.max(0.1, math.min(10, speed))
end

-- Seek to time
function Replay.seek(time)
    if not isPlaying then return end
    playbackTime = time
    playbackIndex = 1

    -- Find the right starting position
    for i, event in ipairs(playbackBuffer) do
        if event.type == "snapshot" and event.time <= time then
            playbackIndex = i
            Replay._processPlaybackEvent(event)
        elseif event.time and event.time > time then
            playbackIndex = i
            break
        end
    end
end

-- List available replays
function Replay.listReplays()
    local replays = {}
    local files = love.filesystem.getDirectoryItems(RECORDING_PATH)
    for _, file in ipairs(files) do
        if file:match("%.replay$") then
            local name = file:gsub("%.replay$", "")
            local info = love.filesystem.getInfo(RECORDING_PATH .. file)
            table.insert(replays, {
                name = name,
                size = info and info.size or 0,
                modified = info and info.modtime or 0,
            })
        end
    end
    return replays
end

-- Delete a replay
function Replay.deleteReplay(name)
    local filename = RECORDING_PATH .. name .. ".replay"
    return love.filesystem.remove(filename)
end

-- Serialize event to string
function Replay._serializeEvent(event)
    local parts = {}
    if event.type == "header" then
        parts = {"H", event.timestamp or 0, event.version or "", event.map or "", event.playerName or "", event.gameMode or ""}
    elseif event.type == "snapshot" then
        local resStr = ""
        for k, v in pairs(event.resources or {}) do
            resStr = resStr .. k .. "=" .. v .. ","
        end
        parts = {"S", event.time or 0, event.gold or 0, event.popularity or 0,
                 event.population or 0, event.maxPopulation or 0,
                 event.viewX or 0, event.viewY or 0, event.scaleX or 1, resStr}
    elseif event.type == "mousepressed" then
        parts = {"MP", event.time or 0, event.data.x or 0, event.data.y or 0, event.data.button or 1}
    elseif event.type == "mousereleased" then
        parts = {"MR", event.time or 0, event.data.x or 0, event.data.y or 0, event.data.button or 1}
    elseif event.type == "keypressed" then
        parts = {"KP", event.time or 0, event.data.key or ""}
    end
    return table.concat(parts, "|")
end

-- Deserialize event from string
function Replay._deserializeEvent(line)
    local parts = {}
    for part in line:gmatch("[^|]+") do
        table.insert(parts, part)
    end

    if #parts == 0 then return nil end

    local tag = parts[1]
    if tag == "H" then
        return {
            type = "header",
            timestamp = tonumber(parts[2]) or 0,
            version = parts[3] or "",
            map = parts[4] or "",
            playerName = parts[5] or "",
            gameMode = parts[6] or "",
        }
    elseif tag == "S" then
        local resources = {}
        if parts[10] then
            for k, v in parts[10]:gmatch("(%w+)=(%d+)") do
                resources[k] = tonumber(v) or 0
            end
        end
        return {
            type = "snapshot",
            time = tonumber(parts[2]) or 0,
            gold = tonumber(parts[3]) or 0,
            popularity = tonumber(parts[4]) or 0,
            population = tonumber(parts[5]) or 0,
            maxPopulation = tonumber(parts[6]) or 0,
            viewX = tonumber(parts[7]) or 0,
            viewY = tonumber(parts[8]) or 0,
            scaleX = tonumber(parts[9]) or 1,
            resources = resources,
        }
    elseif tag == "MP" then
        return {
            type = "mousepressed",
            time = tonumber(parts[2]) or 0,
            data = {x = tonumber(parts[3]) or 0, y = tonumber(parts[4]) or 0, button = tonumber(parts[5]) or 1},
        }
    elseif tag == "MR" then
        return {
            type = "mousereleased",
            time = tonumber(parts[2]) or 0,
            data = {x = tonumber(parts[3]) or 0, y = tonumber(parts[4]) or 0, button = tonumber(parts[5]) or 1},
        }
    elseif tag == "KP" then
        return {
            type = "keypressed",
            time = tonumber(parts[2]) or 0,
            data = {key = parts[3] or ""},
        }
    end

    return nil
end

-- Get recording status
function Replay.isRecording()
    return isRecording
end

function Replay.isPlaying()
    return isPlaying
end

function Replay.getRecordTime()
    return recordTime
end

function Replay.getPlaybackTime()
    return playbackTime
end

function Replay.getCurrentReplayName()
    return currentReplayName
end

-- Get info
function Replay.getInfo()
    return {
        isRecording = isRecording,
        isPlaying = isPlaying,
        paused = paused,
        recordTime = recordTime,
        playbackTime = playbackTime,
        playbackSpeed = playbackSpeed,
        eventCount = isRecording and #recordBuffer or #playbackBuffer,
        currentReplay = currentReplayName,
    }
end

return Replay
