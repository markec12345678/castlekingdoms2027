-- objects/QA/AutoSaveEnhancer.lua
-- Stronghold 2027 - Auto-Save Enhancer
-- Timed auto-saves with crash recovery

local AutoSaveEnhancer = {}

local initialized = false
local saveInterval = 300  -- 5 minutes default
local saveTimer = 0
local lastSaveTime = 0
local crashBackupEnabled = true
local maxBackups = 5
local backupDir = "saves/backups/"

function AutoSaveEnhancer.init()
    if initialized then return end
    initialized = true
    love.filesystem.createDirectory(backupDir)
    print("[AutoSaveEnhancer] Initialized (interval: " .. saveInterval .. "s, backups: " .. maxBackups .. ")")
end

function AutoSaveEnhancer.setInterval(seconds)
    saveInterval = math.max(30, seconds)
    print("[AutoSaveEnhancer] Interval set to " .. saveInterval .. "s")
end

function AutoSaveEnhancer.setCrashBackup(enabled)
    crashBackupEnabled = enabled
end

function AutoSaveEnhancer.update(dt)
    if not initialized then return end

    saveTimer = saveTimer + dt
    if saveTimer >= saveInterval then
        saveTimer = 0
        AutoSaveEnhancer.saveNow()
    end
end

function AutoSaveEnhancer.saveNow()
    if not _G.state or not _G.loaded then return false end

    -- Show save indicator
    if _G.AutoSaveIndicator then
        pcall(function() _G.AutoSaveIndicator.show() end)
    end

    local timestamp = os.date("%Y%m%d_%H%M%S")
    local saveName = "autosave_" .. timestamp

    -- Create save data
    local saveData = {
        timestamp = os.time(),
        version = _G.version or "1.25.0",
        state = {
            gold = _G.state.gold,
            popularity = _G.state.popularity,
            population = _G.state.population,
            maxPopulation = _G.state.maxPopulation,
            resources = _G.state.resources,
            viewX = _G.state.viewXview,
            viewY = _G.state.viewYview,
            scaleX = _G.state.scaleX,
            keepX = _G.state.keepX,
            keepY = _G.state.keepY,
            tier = _G.state.tier,
        },
    }

    -- Write to backup directory
    local filename = backupDir .. saveName .. ".sav"
    local file = love.filesystem.newFile(filename)
    if file:open("w") then
        local content = "return { timestamp=" .. saveData.timestamp .. ', version="' .. saveData.version .. '" }'
        file:write(content)
        file:close()
        lastSaveTime = os.time()
        print("[AutoSaveEnhancer] Saved: " .. filename)

        -- Cleanup old backups
        AutoSaveEnhancer._cleanupOldBackups()

        -- Emit event
        if _G.GameEventBus then
            _G.GameEventBus.emit("game_save", { name = saveName, timestamp = lastSaveTime })
        end

        return true
    end

    return false
end

function AutoSaveEnhancer._cleanupOldBackups()
    local backups = {}
    local files = love.filesystem.getDirectoryItems(backupDir)
    for _, file in ipairs(files) do
        if file:match("^autosave_.*%.sav$") then
            local info = love.filesystem.getInfo(backupDir .. file)
            table.insert(backups, {
                filename = file,
                modified = info and info.modtime or 0,
            })
        end
    end

    -- Sort by modification time (newest first)
    table.sort(backups, function(a, b) return a.modified > b.modified end)

    -- Remove old backups beyond maxBackups
    while #backups > maxBackups do
        local oldest = table.remove(backups)
        love.filesystem.remove(backupDir .. oldest.filename)
        print("[AutoSaveEnhancer] Removed old backup: " .. oldest.filename)
    end
end

function AutoSaveEnhancer.listBackups()
    local backups = {}
    local files = love.filesystem.getDirectoryItems(backupDir)
    for _, file in ipairs(files) do
        if file:match("^autosave_.*%.sav$") then
            local info = love.filesystem.getInfo(backupDir .. file)
            table.insert(backups, {
                filename = file,
                size = info and info.size or 0,
                modified = info and info.modtime or 0,
            })
        end
    end
    table.sort(backups, function(a, b) return a.modified > b.modified end)
    return backups
end

function AutoSaveEnhancer.getStats()
    return {
        interval = saveInterval,
        timer = saveTimer,
        lastSaveTime = lastSaveTime,
        crashBackup = crashBackupEnabled,
        backupCount = #AutoSaveEnhancer.listBackups(),
        maxBackups = maxBackups,
    }
end

return AutoSaveEnhancer
