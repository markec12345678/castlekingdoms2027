-- objects/QA/CommunityFeedbackSystem.lua
-- Castle Kingdoms 2027 - Community Feedback System
-- Bug reports, suggestions, crash reports

local CommunityFeedback = {}

local initialized = false
local feedbackLog = {}

function CommunityFeedback.init()
    if initialized then return end
    initialized = true
    love.filesystem.createDirectory("feedback")
    print("[CommunityFeedback] Initialized (feedback dir: feedback/)")
end

-- Submit a bug report
function CommunityFeedback.submitBugReport(title, description, steps)
    local report = {
        type = "bug",
        title = title or "Untitled bug",
        description = description or "",
        steps = steps or "",
        timestamp = os.time(),
        timeStr = os.date("%Y-%m-%d %H:%M:%S"),
        gameVersion = _G.version or "1.18.0",
        system = CommunityFeedback._getSystemInfo(),
    }

    local filename = "feedback/bug_" .. os.date("%Y%m%d_%H%M%S") .. ".txt"
    local file = love.filesystem.newFile(filename)
    if file:open("w") then
        file:write(CommunityFeedback._formatReport(report))
        file:close()
    end

    table.insert(feedbackLog, report)
    print("[CommunityFeedback] Bug report saved: " .. filename)
    return filename
end

-- Submit a suggestion
function CommunityFeedback.submitSuggestion(title, description)
    local suggestion = {
        type = "suggestion",
        title = title or "Untitled suggestion",
        description = description or "",
        timestamp = os.time(),
        timeStr = os.date("%Y-%m-%d %H:%M:%S"),
        gameVersion = _G.version or "1.18.0",
    }

    local filename = "feedback/suggestion_" .. os.date("%Y%m%d_%H%M%S") .. ".txt"
    local file = love.filesystem.newFile(filename)
    if file:open("w") then
        file:write(CommunityFeedback._formatReport(suggestion))
        file:close()
    end

    table.insert(feedbackLog, suggestion)
    print("[CommunityFeedback] Suggestion saved: " .. filename)
    return filename
end

-- Submit a crash report
function CommunityFeedback.submitCrashReport(errorMsg, stackTrace)
    local report = {
        type = "crash",
        title = "Crash report",
        error = errorMsg or "Unknown error",
        stack = stackTrace or "",
        timestamp = os.time(),
        timeStr = os.date("%Y-%m-%d %H:%M:%S"),
        gameVersion = _G.version or "1.18.0",
        system = CommunityFeedback._getSystemInfo(),
        gameState = CommunityFeedback._getGameState(),
    }

    local filename = "feedback/crash_" .. os.date("%Y%m%d_%H%M%S") .. ".txt"
    local file = love.filesystem.newFile(filename)
    if file:open("w") then
        file:write(CommunityFeedback._formatReport(report))
        file:close()
    end

    print("[CommunityFeedback] Crash report saved: " .. filename)
    return filename
end

-- Get system info
function CommunityFeedback._getSystemInfo()
    local w, h = love.graphics.getDimensions()
    local mem = collectgarbage("count")
    return {
        resolution = string.format("%dx%d", w, h),
        memoryMB = math.floor(mem / 1024),
        os = love.system.getOS(),
        processorCount = love.system.getProcessorCount(),
    }
end

-- Get game state snapshot
function CommunityFeedback._getGameState()
    if not _G.state then return { available = false } end
    return {
        available = true,
        gold = _G.state.gold or 0,
        popularity = _G.state.popularity or 0,
        population = _G.state.population or 0,
        maxPopulation = _G.state.maxPopulation or 0,
        newGame = _G.state.newGame or false,
    }
end

-- Format report as text
function CommunityFeedback._formatReport(report)
    local lines = {}
    table.insert(lines, "========================================")
    table.insert(lines, "Castle Kingdoms 2027 - " .. (report.type or "feedback"):upper() .. " REPORT")
    table.insert(lines, "========================================")
    table.insert(lines, "")
    table.insert(lines, "Timestamp: " .. report.timeStr)
    table.insert(lines, "Game Version: " .. report.gameVersion)
    table.insert(lines, "")

    if report.title then
        table.insert(lines, "Title: " .. report.title)
    end
    if report.description then
        table.insert(lines, "")
        table.insert(lines, "Description:")
        table.insert(lines, report.description)
    end
    if report.steps then
        table.insert(lines, "")
        table.insert(lines, "Steps to reproduce:")
        table.insert(lines, report.steps)
    end
    if report.error then
        table.insert(lines, "")
        table.insert(lines, "Error:")
        table.insert(lines, report.error)
    end
    if report.stack then
        table.insert(lines, "")
        table.insert(lines, "Stack trace:")
        table.insert(lines, report.stack)
    end

    if report.system then
        table.insert(lines, "")
        table.insert(lines, "System Info:")
        table.insert(lines, "  OS: " .. tostring(report.system.os))
        table.insert(lines, "  Resolution: " .. tostring(report.system.resolution))
        table.insert(lines, "  Memory: " .. tostring(report.system.memoryMB) .. " MB")
        table.insert(lines, "  CPU cores: " .. tostring(report.system.processorCount))
    end

    if report.gameState then
        table.insert(lines, "")
        table.insert(lines, "Game State:")
        if report.gameState.available then
            table.insert(lines, "  Gold: " .. tostring(report.gameState.gold))
            table.insert(lines, "  Popularity: " .. tostring(report.gameState.popularity))
            table.insert(lines, "  Population: " .. tostring(report.gameState.population) .. "/" .. tostring(report.gameState.maxPopulation))
        else
            table.insert(lines, "  (not available)")
        end
    end

    table.insert(lines, "")
    table.insert(lines, "========================================")
    return table.concat(lines, "\n")
end

-- List all feedback files
function CommunityFeedback.listFeedback()
    local feedback = {}
    local files = love.filesystem.getDirectoryItems("feedback")
    for _, file in ipairs(files) do
        local info = love.filesystem.getInfo("feedback/" .. file)
        table.insert(feedback, {
            filename = file,
            type = file:match("^(%w+)_") or "unknown",
            size = info and info.size or 0,
            modified = info and info.modtime or 0,
        })
    end
    return feedback
end

-- Get feedback count
function CommunityFeedback.getCount()
    local count = 0
    for _ in pairs(feedbackLog) do count = count + 1 end
    return count
end

return CommunityFeedback
