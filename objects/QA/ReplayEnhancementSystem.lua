-- objects/QA/ReplayEnhancementSystem.lua
-- Castle Kingdoms 2027 v2.8.4 - Replay Enhancement System
--
-- Enhanced replay system with timeline scrubbing, slow-motion,
-- and bookmarked highlights for competitive analysis.
--
-- Features:
-- - Timeline scrubbing (jump to any point in replay)
-- - Variable playback speed (0.25x to 8x)
-- - Bookmark highlights (key moments)
-- - Replay statistics
-- - Export replay summary

local ReplayEnhanced = {}

local initialized = false
local replayData = nil  -- loaded replay
local currentTime = 0
local playbackSpeed = 1.0
local isPlaying = false
local isPaused = false
local bookmarks = {}  -- { {time, label, type}, ... }
local stats = {}

-- Playback speed options
local SPEED_OPTIONS = {0.25, 0.5, 1.0, 2.0, 4.0, 8.0}
local currentSpeedIndex = 3  -- default 1.0x

ReplayEnhanced.SPEED_OPTIONS = SPEED_OPTIONS

function ReplayEnhanced.init()
    if initialized then return end
    initialized = true
    print("[ReplayEnhanced] Initialized")
end

-- Load a replay for enhanced playback
function ReplayEnhanced.load(replayName)
    local ReplaySystem = _G.ReplaySystem or require("objects.QA.ReplaySystem")
    if not ReplaySystem then return false end

    -- Use existing ReplaySystem to load
    local ok = pcall(function() ReplaySystem.startPlayback(replayName) end)
    if not ok then return false end

    replayData = {
        name = replayName,
        events = {},  -- populated from ReplaySystem
        duration = 0,
        loaded = true,
    }

    currentTime = 0
    isPlaying = true
    isPaused = false
    bookmarks = {}

    if _G.ModernUI then
        _G.ModernUI.notifySuccess("Replay naložen: " .. replayName)
    end
    print("[ReplayEnhanced] Loaded: " .. replayName)
    return true
end

-- Cycle playback speed
function ReplayEnhanced.cycleSpeed()
    currentSpeedIndex = (currentSpeedIndex % #SPEED_OPTIONS) + 1
    playbackSpeed = SPEED_OPTIONS[currentSpeedIndex]
    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Replay hitrost: " .. playbackSpeed .. "x")
    end
    return playbackSpeed
end

-- Set specific speed
function ReplayEnhanced.setSpeed(speed)
    for i, s in ipairs(SPEED_OPTIONS) do
        if s == speed then
            currentSpeedIndex = i
            playbackSpeed = speed
            return true
        end
    end
    return false
end

-- Pause/resume
function ReplayEnhanced.togglePause()
    isPaused = not isPaused
    if _G.ModernUI then
        _G.ModernUI.notifyInfo(isPaused and "Replay: pavza" or "Replay: predvajanje")
    end
    return isPaused
end

-- Jump to specific time
function ReplayEnhanced.seekTo(time)
    if not replayData then return false end
    currentTime = math.max(0, math.min(replayData.duration or 0, time))
    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Replay: skok na " .. math.floor(currentTime) .. "s")
    end
    return true
end

-- Skip forward/backward
function ReplayEnhanced.skip(seconds)
    return ReplayEnhanced.seekTo(currentTime + (seconds or 10))
end

-- Add a bookmark at current time
function ReplayEnhanced.addBookmark(label, btype)
    if not replayData then return false end
    local bookmark = {
        time = currentTime,
        label = label or "Oznaka " .. (#bookmarks + 1),
        type = btype or "note",  -- note, highlight, combat, economy
    }
    table.insert(bookmarks, bookmark)
    if _G.ModernUI then
        _G.ModernUI.notifySuccess("Oznaka dodana: " .. bookmark.label .. " (" .. math.floor(currentTime) .. "s)")
    end
    return bookmark
end

-- Remove a bookmark by index
function ReplayEnhanced.removeBookmark(index)
    if not bookmarks[index] then return false end
    table.remove(bookmarks, index)
    return true
end

-- Jump to a bookmark
function ReplayEnhanced.jumpToBookmark(index)
    if not bookmarks[index] then return false end
    return ReplayEnhanced.seekTo(bookmarks[index].time)
end

-- Update
function ReplayEnhanced.update(dt)
    if not initialized or not replayData then return end
    if isPaused then return end

    currentTime = currentTime + dt * playbackSpeed

    -- Check if replay ended
    if replayData.duration and currentTime >= replayData.duration then
        currentTime = replayData.duration
        isPlaying = false
        if _G.ModernUI then
            _G.ModernUI.notifyInfo("Replay končan")
        end
    end
end

-- Get current state
function ReplayEnhanced.getState()
    return {
        loaded = replayData ~= nil,
        playing = isPlaying and not isPaused,
        paused = isPaused,
        currentTime = currentTime,
        duration = replayData and replayData.duration or 0,
        speed = playbackSpeed,
        progress = replayData and replayData.duration and (currentTime / replayData.duration * 100) or 0,
        bookmarkCount = #bookmarks,
    }
end

-- Get all bookmarks
function ReplayEnhanced.getBookmarks()
    return bookmarks
end

-- Get stats
function ReplayEnhanced.getStats()
    return {
        totalBookmarks = #bookmarks,
        combatBookmarks = ReplayEnhanced._countByType("combat"),
        economyBookmarks = ReplayEnhanced._countByType("economy"),
        highlightBookmarks = ReplayEnhanced._countByType("highlight"),
    }
end

function ReplayEnhanced._countByType(btype)
    local count = 0
    for _, b in ipairs(bookmarks) do
        if b.type == btype then count = count + 1 end
    end
    return count
end

-- Export replay summary as string
function ReplayEnhanced.exportSummary()
    if not replayData then return nil end
    local lines = {"=== REPLAY POVZETEK ==="}
    table.insert(lines, "Ime: " .. (replayData.name or "neznan"))
    table.insert(lines, "Trajanje: " .. math.floor(replayData.duration or 0) .. "s")
    table.insert(lines, "Hitrost: " .. playbackSpeed .. "x")
    table.insert(lines, "Oznake: " .. #bookmarks)
    table.insert(lines, "")
    table.insert(lines, "=== OZNAKE ===")
    for i, b in ipairs(bookmarks) do
        table.insert(lines, string.format("%d. [%ds] %s (%s)", i, math.floor(b.time), b.label, b.type))
    end
    return table.concat(lines, "\n")
end

-- Draw replay controls (overlay)
function ReplayEnhanced.draw()
    if not initialized or not replayData then return end

    local screenWidth = love.graphics.getWidth()
    local y = screenHeight - 50

    -- Background bar
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, y, screenWidth, 40)

    -- Progress bar
    local progress = replayData.duration and (currentTime / replayData.duration) or 0
    love.graphics.setColor(0.3, 0.5, 0.9, 0.8)
    love.graphics.rectangle("fill", 10, y + 15, (screenWidth - 20) * progress, 10)

    -- Bookmark markers
    for _, b in ipairs(bookmarks) do
        local bProgress = replayData.duration and (b.time / replayData.duration) or 0
        local bx = 10 + (screenWidth - 20) * bProgress
        love.graphics.setColor(1, 0.8, 0, 1)
        love.graphics.circle("fill", bx, y + 20, 4)
    end

    -- Time display
    love.graphics.setColor(1, 1, 1, 1)
    local timeStr = string.format("%ds / %ds (%.1fx)", math.floor(currentTime), math.floor(replayData.duration or 0), playbackSpeed)
    love.graphics.print(timeStr, 15, y + 5)

    -- Speed indicator
    love.graphics.setColor(0.3, 0.9, 0.3, 1)
    love.graphics.print(playbackSpeed .. "x", screenWidth - 50, y + 5)

    love.graphics.setColor(1, 1, 1, 1)
end

-- Keybind handler
function ReplayEnhanced.keypressed(key)
    if not replayData then return false end

    if key == "space" then
        ReplayEnhanced.togglePause()
        return true
    elseif key == "left" then
        ReplayEnhanced.skip(-10)
        return true
    elseif key == "right" then
        ReplayEnhanced.skip(10)
        return true
    elseif key == "up" then
        ReplayEnhanced.cycleSpeed()
        return true
    elseif key == "b" then
        ReplayEnhanced.addBookmark()
        return true
    end
    return false
end

return ReplayEnhanced
