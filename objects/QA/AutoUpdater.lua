-- objects/QA/AutoUpdater.lua
-- Castle Kingdoms 2027 - Auto Update Checker
-- Checks for new versions on GitHub and notifies the player

local AutoUpdater = {}

local CURRENT_VERSION = "2.2.0"
local GITHUB_API_URL = "https://api.github.com/repos/markec12345678/castlekingdoms2027/releases/latest"
local initialized = false
local lastCheckTime = 0
local checkInterval = 3600  -- Check every hour
local updateAvailable = false
local latestVersion = nil
local downloadUrl = nil

function AutoUpdater.init()
    if initialized then return end
    initialized = true
    print("[AutoUpdater] Initialized (current version: " .. CURRENT_VERSION .. ")")
end

function AutoUpdater.getCurrentVersion()
    return CURRENT_VERSION
end

function AutoUpdater.checkForUpdates()
    if not initialized then AutoUpdater.init() end

    print("[AutoUpdater] Checking for updates...")

    -- In production, this would make an HTTP request to GitHub API
    -- For now, we simulate the check
    -- local http = require("socket.http")
    -- local response = http.request(GITHUB_API_URL)

    -- Simulated response (stub)
    latestVersion = CURRENT_VERSION  -- No update available (stub)
    updateAvailable = false

    -- If we had a real response:
    -- Parse JSON, extract tag_name and assets[0].browser_download_url
    -- Compare versions
    -- If newer, set updateAvailable = true

    if updateAvailable then
        print("[AutoUpdater] Update available: " .. tostring(latestVersion))
        if _G.ModernUI then
            _G.ModernUI.notifyInfo("Nova verzija: " .. tostring(latestVersion) .. " — posodobi na GitHub!")
        end
    else
        print("[AutoUpdater] Up to date (v" .. CURRENT_VERSION .. ")")
    end

    return updateAvailable
end

function AutoUpdater.update(dt)
    if not initialized then return end

    lastCheckTime = lastCheckTime + dt
    if lastCheckTime >= checkInterval then
        lastCheckTime = 0
        AutoUpdater.checkForUpdates()
    end
end

function AutoUpdater.isUpdateAvailable()
    return updateAvailable
end

function AutoUpdater.getLatestVersion()
    return latestVersion
end

function AutoUpdater.downloadUpdate()
    if not updateAvailable or not downloadUrl then
        if _G.ModernUI then
            _G.ModernUI.notifyInfo("Ni nobene posodobitve na voljo.")
        end
        return false
    end

    -- Open download page in browser
    love.system.openURL(downloadUrl)
    return true
end

function AutoUpdater.openReleasesPage()
    love.system.openURL("https://github.com/markec12345678/castlekingdoms2027/releases")
end

-- Compare version strings (e.g., "2.0.0" vs "2.1.0")
function AutoUpdater._compareVersions(v1, v2)
    local parts1 = {}
    for part in v1:gmatch("(%d+)") do
        table.insert(parts1, tonumber(part))
    end

    local parts2 = {}
    for part in v2:gmatch("(%d+)") do
        table.insert(parts2, tonumber(part))
    end

    for i = 1, math.max(#parts1, #parts2) do
        local p1 = parts1[i] or 0
        local p2 = parts2[i] or 0
        if p1 < p2 then return -1 end
        if p1 > p2 then return 1 end
    end

    return 0
end

function AutoUpdater.getInfo()
    return {
        currentVersion = CURRENT_VERSION,
        latestVersion = latestVersion,
        updateAvailable = updateAvailable,
        lastCheckTime = lastCheckTime,
        checkInterval = checkInterval,
    }
end

return AutoUpdater
