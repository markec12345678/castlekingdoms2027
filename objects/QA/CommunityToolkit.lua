-- objects/QA/CommunityToolkit.lua
-- Stronghold 2027 - Community Toolkit
-- Discord integration, bug report launcher, feedback collection

local CommunityToolkit = {}

local initialized = false
local DISCORD_INVITE_URL = "https://discord.gg/your-invite-code"
local GITHUB_ISSUES_URL = "https://github.com/markec12345678/stronghold2027/issues"
local GITHUB_REPO_URL = "https://github.com/markec12345678/stronghold2027"

function CommunityToolkit.init()
    if initialized then return end
    initialized = true
    print("[CommunityToolkit] Initialized")
end

-- Open Discord invite in browser
function CommunityToolkit.openDiscord()
    print("[CommunityToolkit] Opening Discord...")
    love.system.openURL(DISCORD_INVITE_URL)
end

-- Open GitHub issues page
function CommunityToolkit.openGitHubIssues()
    print("[CommunityToolkit] Opening GitHub Issues...")
    love.system.openURL(GITHUB_ISSUES_URL)
end

-- Open GitHub repo
function CommunityToolkit.openGitHub()
    print("[CommunityToolkit] Opening GitHub repo...")
    love.system.openURL(GITHUB_REPO_URL)
end

-- Submit in-game bug report (uses CommunityFeedbackSystem)
function CommunityToolkit.submitBugReport()
    local CommunityFeedback = require("objects.QA.CommunityFeedbackSystem")
    CommunityFeedback.init()

    -- Collect current game state
    local stateInfo = ""
    if _G.state then
        stateInfo = string.format("Gold: %d | Pop: %d/%d | Popularity: %d",
            _G.state.gold or 0,
            _G.state.population or 0,
            _G.state.maxPopulation or 0,
            _G.state.popularity or 0)
    end

    local PerfWatchdog = require("objects.QA.PerformanceWatchdog")
    local perfStats = PerfWatchdog.getStats()
    local perfInfo = string.format("FPS: %d | Quality: %s | Memory: %d MB",
        perfStats.fps, perfStats.quality, perfStats.memoryMB)

    local CrashHandler = require("objects.QA.CrashHandler")
    local crashSummary = CrashHandler.getSummary()

    -- Create report file
    local filename = CommunityFeedback.submitBugReport(
        "Bug Report from game",
        "Game state: " .. stateInfo .. "\nPerformance: " .. perfInfo ..
        "\nErrors: " .. crashSummary.totalErrors ..
        "\nDisabled systems: " .. crashSummary.disabledSystems,
        "1. Start game\n2. [describe what you did]\n3. [describe what happened]"
    )

    if _G.ModernUI then
        _G.ModernUI.notifySuccess("Bug report saved: " .. tostring(filename))
    end

    return filename
end

-- Submit suggestion
function CommunityToolkit.submitSuggestion()
    local CommunityFeedback = require("objects.QA.CommunityFeedbackSystem")
    CommunityFeedback.init()
    local filename = CommunityFeedback.submitSuggestion(
        "Player suggestion",
        "[Describe your suggestion here]"
    )
    if _G.ModernUI then
        _G.ModernUI.notifySuccess("Suggestion saved: " .. tostring(filename))
    end
    return filename
end

-- Copy save game path to clipboard (for support)
function CommunityToolkit.copySavePath()
    local path = love.filesystem.getSaveDirectory()
    love.system.setClipboardText(path)
    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Pot shranjevanja kopirana: " .. path)
    end
end

-- Get community info
function CommunityToolkit.getInfo()
    return {
        discord = DISCORD_INVITE_URL,
        github = GITHUB_REPO_URL,
        issues = GITHUB_ISSUES_URL,
        saveDir = love.filesystem.getSaveDirectory(),
    }
end

return CommunityToolkit
