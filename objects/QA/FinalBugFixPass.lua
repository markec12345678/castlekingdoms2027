-- objects/QA/FinalBugFixPass.lua
-- Castle Kingdoms 2027 - Final Bug Fix Pass
-- Comprehensive nil-safety, error handling, and edge case fixes

local FinalBugFix = {}

local fixesApplied = {}
local initialized = false

function FinalBugFix.init()
    if initialized then return end
    initialized = true

    -- 1. Patch _G.state access with nil-safety
    FinalBugFix._patchStateAccess()

    -- 2. Patch love.graphics calls with error handling
    FinalBugFix._patchGraphicsCalls()

    -- 3. Patch table operations with bounds checking
    FinalBugFix._patchTableOperations()

    -- 4. Patch filesystem operations
    FinalBugFix._patchFilesystem()

    print("[FinalBugFix] Initialized with " .. #fixesApplied .. " safety patches")
end

-- Patch state access to prevent nil crashes
function FinalBugFix._patchStateAccess()
    -- Safe state getter
    if not _G.safeGetState then
        _G.safeGetState = function(key, default)
            if not _G.state then return default end
            local value = _G.state[key]
            if value == nil then return default end
            return value
        end
        table.insert(fixesApplied, "safeGetState()")
    end

    -- Safe resource getter
    if not _G.safeGetResource then
        _G.safeGetResource = function(resourceType, default)
            if not _G.state or not _G.state.resources then return default or 0 end
            return _G.state.resources[resourceType] or default or 0
        end
        table.insert(fixesApplied, "safeGetResource()")
    end

    -- Safe gameObjectList access
    if not _G.safeGetGameObjectList then
        _G.safeGetGameObjectList = function()
            if not _G.state or not _G.state.gameObjectList then return {} end
            return _G.state.gameObjectList
        end
        table.insert(fixesApplied, "safeGetGameObjectList()")
    end
end

-- Patch graphics calls to prevent crashes on nil images
function FinalBugFix._patchGraphicsCalls()
    -- Safe draw
    if not _G.safeDraw then
        _G.safeDraw = function(image, ...)
            if not image then return end
            local ok, err = pcall(love.graphics.draw, image, ...)
            if not ok then
                print("[FinalBugFix] draw error: " .. tostring(err))
            end
        end
        table.insert(fixesApplied, "safeDraw()")
    end

    -- Safe newImage with fallback
    if not _G.safeNewImage then
        _G.safeNewImage = function(path)
            if not path then return nil end
            local info = love.filesystem.getInfo(path)
            if not info then
                print("[FinalBugFix] Image not found: " .. path)
                return nil
            end
            local ok, image = pcall(love.graphics.newImage, path)
            if not ok or not image then
                print("[FinalBugFix] Failed to load image: " .. path .. " - " .. tostring(image))
                return nil
            end
            return image
        end
        table.insert(fixesApplied, "safeNewImage()")
    end

    -- Safe setColor
    if not _G.safeSetColor then
        _G.safeSetColor = function(r, g, b, a)
            r = tonumber(r) or 1
            g = tonumber(g) or 1
            b = tonumber(b) or 1
            a = tonumber(a) or 1
            r = math.max(0, math.min(1, r))
            g = math.max(0, math.min(1, g))
            b = math.max(0, math.min(1, b))
            a = math.max(0, math.min(1, a))
            love.graphics.setColor(r, g, b, a)
        end
        table.insert(fixesApplied, "safeSetColor()")
    end
end

-- Patch table operations
function FinalBugFix._patchTableOperations()
    -- Safe table insert
    if not _G.safeInsert then
        _G.safeInsert = function(t, value, pos)
            if not t then return end
            if value == nil then return end
            if pos then
                table.insert(t, pos, value)
            else
                table.insert(t, value)
            end
        end
        table.insert(fixesApplied, "safeInsert()")
    end

    -- Safe table remove
    if not _G.safeRemove then
        _G.safeRemove = function(t, pos)
            if not t or #t == 0 then return nil end
            pos = pos or #t
            if pos < 1 or pos > #t then return nil end
            return table.remove(t, pos)
        end
        table.insert(fixesApplied, "safeRemove()")
    end

    -- Safe ipairs (handles nil entries)
    if not _G.safeIpairs then
        _G.safeIpairs = function(t)
            if not t then return function() end end
            local i = 0
            return function()
                i = i + 1
                local v = t[i]
                if v ~= nil then return i, v end
                return nil
            end
        end
        table.insert(fixesApplied, "safeIpairs()")
    end

    -- Safe table length
    if not _G.safeLen then
        _G.safeLen = function(t)
            if not t then return 0 end
            local count = 0
            for _ in pairs(t) do count = count + 1 end
            return count
        end
        table.insert(fixesApplied, "safeLen()")
    end
end

-- Patch filesystem operations
function FinalBugFix._patchFilesystem()
    -- Safe file read
    if not _G.safeReadFile then
        _G.safeReadFile = function(path)
            if not path then return nil end
            local file = love.filesystem.newFile(path)
            if not file then return nil end
            local ok = pcall(function() file:open("r") end)
            if not ok then return nil end
            local content = file:read()
            file:close()
            return content
        end
        table.insert(fixesApplied, "safeReadFile()")
    end

    -- Safe file write
    if not _G.safeWriteFile then
        _G.safeWriteFile = function(path, content)
            if not path or not content then return false end
            local ok, err = pcall(function()
                local file = love.filesystem.newFile(path)
                file:open("w")
                file:write(content)
                file:close()
            end)
            if not ok then
                print("[FinalBugFix] Write error: " .. tostring(err))
                return false
            end
            return true
        end
        table.insert(fixesApplied, "safeWriteFile()")
    end
end

-- Get list of applied fixes
function FinalBugFix.getAppliedFixes()
    return fixesApplied
end

-- Run comprehensive safety check
function FinalBugFix.runSafetyCheck()
    local results = {
        passed = 0,
        failed = 0,
        checks = {},
    }

    -- Check 1: _G.state exists
    if _G.state then
        results.passed = results.passed + 1
        table.insert(results.checks, "PASS: _G.state exists")
    else
        results.failed = results.failed + 1
        table.insert(results.checks, "WARN: _G.state is nil (game not started)")
    end

    -- Check 2: love.graphics functional
    if love.graphics and love.graphics.draw then
        results.passed = results.passed + 1
        table.insert(results.checks, "PASS: love.graphics functional")
    else
        results.failed = results.failed + 1
        table.insert(results.checks, "FAIL: love.graphics not functional")
    end

    -- Check 3: love.filesystem functional
    if love.filesystem and love.filesystem.getInfo then
        results.passed = results.passed + 1
        table.insert(results.checks, "PASS: love.filesystem functional")
    else
        results.failed = results.failed + 1
        table.insert(results.checks, "FAIL: love.filesystem not functional")
    end

    -- Check 4: Key systems initialized
    local systems = {"BuildController", "Commander", "SaveManager"}
    for _, sys in ipairs(systems) do
        if _G[sys] then
            results.passed = results.passed + 1
            table.insert(results.checks, "PASS: " .. sys .. " initialized")
        else
            results.failed = results.failed + 1
            table.insert(results.checks, "WARN: " .. sys .. " not initialized")
        end
    end

    -- Check 5: Memory usage
    local memKB = collectgarbage("count")
    if memKB < 500000 then  -- Under 500MB
        results.passed = results.passed + 1
        table.insert(results.checks, string.format("PASS: Memory usage %.1f MB", memKB / 1024))
    else
        results.failed = results.failed + 1
        table.insert(results.checks, string.format("WARN: High memory usage %.1f MB", memKB / 1024))
    end

    return results
end

-- Print safety check results
function FinalBugFix.printSafetyCheck()
    local results = FinalBugFix.runSafetyCheck()
    print("\n" .. string.rep("=", 50))
    print("FINAL BUG FIX - SAFETY CHECK")
    print(string.rep("=", 50))
    print(string.format("Passed: %d | Failed: %d", results.passed, results.failed))
    print(string.rep("-", 50))
    for _, check in ipairs(results.checks) do
        print("  " .. check)
    end
    print(string.rep("=", 50))
    return results
end

return FinalBugFix
