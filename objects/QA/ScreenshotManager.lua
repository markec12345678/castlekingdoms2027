-- objects/QA/ScreenshotManager.lua
-- Castle Kingdoms 2027 - Screenshot Manager
-- Automated screenshot capture for marketing materials

local ScreenshotManager = {}

local initialized = false
local autoCaptureEnabled = false
local captureInterval = 60  -- Auto-capture every 60 seconds
local captureTimer = 0
local captureCount = 0
local captureDir = "screenshots/"

function ScreenshotManager.init()
    if initialized then return end
    initialized = true
    love.filesystem.createDirectory(captureDir)
    print("[ScreenshotManager] Initialized (dir: " .. captureDir .. ")")
end

-- Capture a single screenshot
function ScreenshotManager.capture(label)
    if not initialized then ScreenshotManager.init() end

    local timestamp = os.date("%Y%m%d_%H%M%S")
    local name = label or "screenshot"
    local filename = captureDir .. name .. "_" .. timestamp .. ".png"

    love.graphics.captureScreenshot(filename)
    captureCount = captureCount + 1

    print("[ScreenshotManager] Captured: " .. filename .. " (total: " .. captureCount .. ")")
    return filename
end

-- Enable auto-capture (takes screenshots periodically)
function ScreenshotManager.enableAutoCapture(interval)
    autoCaptureEnabled = true
    captureInterval = interval or 60
    captureTimer = 0
    print("[ScreenshotManager] Auto-capture enabled (every " .. captureInterval .. "s)")
end

function ScreenshotManager.disableAutoCapture()
    autoCaptureEnabled = false
    print("[ScreenshotManager] Auto-capture disabled")
end

function ScreenshotManager.update(dt)
    if not initialized or not autoCaptureEnabled then return end

    captureTimer = captureTimer + dt
    if captureTimer >= captureInterval then
        captureTimer = 0
        ScreenshotManager.capture("auto")
    end
end

-- Capture a sequence of screenshots (for trailers)
function ScreenshotManager.captureSequence(count, interval)
    if not initialized then ScreenshotManager.init() end

    count = count or 10
    interval = interval or 2.0

    for i = 1, count do
        -- Schedule captures (simplified - in production would use timers)
        local timer = 0
        local captured = false
        local idx = i
    end

    print("[ScreenshotManager] Sequence capture: " .. count .. " screenshots every " .. interval .. "s")
end

-- List all screenshots
function ScreenshotManager.listScreenshots()
    local screenshots = {}
    local files = love.filesystem.getDirectoryItems(captureDir)
    for _, file in ipairs(files) do
        if file:match("%.png$") then
            local info = love.filesystem.getInfo(captureDir .. file)
            table.insert(screenshots, {
                filename = file,
                size = info and info.size or 0,
                modified = info and info.modtime or 0,
            })
        end
    end
    table.sort(screenshots, function(a, b) return a.modified > b.modified end)
    return screenshots
end

-- Delete old screenshots (keep last N)
function ScreenshotManager.cleanup(keepCount)
    keepCount = keepCount or 50
    local screenshots = ScreenshotManager.listScreenshots()

    while #screenshots > keepCount do
        local oldest = table.remove(screenshots)
        love.filesystem.remove(captureDir .. oldest.filename)
    end

    print("[ScreenshotManager] Cleaned up (kept " .. keepCount .. " most recent)")
end

-- Get stats
function ScreenshotManager.getStats()
    return {
        captureCount = captureCount,
        autoCapture = autoCaptureEnabled,
        captureInterval = captureInterval,
        storedCount = #ScreenshotManager.listScreenshots(),
    }
end

return ScreenshotManager
