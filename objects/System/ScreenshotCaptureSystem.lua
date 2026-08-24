-- objects/System/ScreenshotCaptureSystem.lua
-- Castle Kingdoms 2027 v3.13.3 - Auto-Screenshot Capture System
--
-- Automatically captures screenshots for Steam store page marketing.
-- Uses LÖVE love.graphics.newScreenshot() to grab the framebuffer.
--
-- Features:
--   * Manual capture (Ctrl+M already exists, this extends it)
--   * Auto-tour mode: captures screenshots at intervals
--   * Named screenshots with timestamp
--   * Save to screenshots/ directory
--
-- Public API:
--   ScreenshotCapture.capture(name)      - take a single screenshot
--   ScreenshotCapture.startTour()        - start auto-capture tour
--   ScreenshotCapture.stopTour()         - stop auto-capture tour
--   ScreenshotCapture.isTouring()        - check if tour is active
--   ScreenshotCapture.getStats()         - debug info

local ScreenshotCapture = {}

local tourActive = false
local tourTimer = 0
local tourInterval = 10  -- seconds between captures
local tourCount = 0
local maxTourShots = 20  -- stop after 20 screenshots

local SCREENSHOT_DIR = "screenshots"

local function ensureDir()
    local info = love.filesystem.getInfo(SCREENSHOT_DIR)
    if not info or info.type ~= "directory" then
        love.filesystem.createDirectory(SCREENSHOT_DIR)
    end
end

function ScreenshotCapture.capture(name)
    ensureDir()
    local timestamp = os.date("%Y%m%d_%H%M%S")
    local filename = name or ("castlekingdoms_" .. timestamp)
    local filepath = SCREENSHOT_DIR .. "/" .. filename .. ".png"

    local screenshot = love.graphics.newScreenshot()
    local ok, data = pcall(function()
        return screenshot:encode("png", filepath)
    end)

    if ok then
        print("[ScreenshotCapture] Saved: " .. filepath)
        if _G.NotificationCenter then
            pcall(function()
                _G.NotificationCenter.system("Screenshot: " .. filepath)
            end)
        end
        return filepath
    else
        print("[ScreenshotCapture] Failed: " .. tostring(data))
        return nil
    end
end

function ScreenshotCapture.startTour(interval, maxShots)
    tourActive = true
    tourTimer = 0
    tourCount = 0
    tourInterval = interval or 10
    maxTourShots = maxShots or 20
    ScreenshotCapture.capture("tour_01")
    if _G.NotificationCenter then
        pcall(function()
            _G.NotificationCenter.system("Screenshot tour: " .. tourInterval .. "s, max: " .. maxTourShots)
        end)
    end
    if _G.UISoundHelper then
        pcall(function() _G.UISoundHelper.playSuccess() end)
    end
end

function ScreenshotCapture.stopTour()
    if not tourActive then return end
    tourActive = false
    if _G.NotificationCenter then
        pcall(function()
            _G.NotificationCenter.system("Screenshot tour končan (" .. tourCount .. " slik)")
        end)
    end
end

function ScreenshotCapture.isTouring()
    return tourActive
end

function ScreenshotCapture.update(dt)
    if not tourActive then return end
    tourTimer = tourTimer + dt
    if tourTimer >= tourInterval then
        tourTimer = 0
        tourCount = tourCount + 1
        if tourCount >= maxTourShots then
            ScreenshotCapture.stopTour()
            return
        end
        local name = string.format("tour_%02d", tourCount + 1)
        ScreenshotCapture.capture(name)
    end
end

function ScreenshotCapture.getStats()
    return {
        tourActive = tourActive,
        tourTimer = tourTimer,
        tourInterval = tourInterval,
        tourCount = tourCount,
        maxTourShots = maxTourShots,
        screenshotDir = SCREENSHOT_DIR,
    }
end

function ScreenshotCapture.reset()
    tourActive = false
    tourTimer = 0
    tourCount = 0
end

return ScreenshotCapture
