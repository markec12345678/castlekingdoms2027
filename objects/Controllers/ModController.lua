-- objects/Controllers/ModController.lua
-- Stronghold 2027 - Modding API
--
-- Loads and manages user-created mods from the mods/ directory.
-- Mods can extend gameplay, add buildings, units, or modify existing behavior.
--
-- Usage:
--   local ModController = require("objects.Controllers.ModController")
--   ModController:initialize()
--   ModController:loadAll()
--
-- Mod structure:
--   mods/my_mod/
--   ├── mod.lua          (required - mod metadata and entry point)
--   ├── assets/          (optional - mod-specific assets)
--   ├── locale/          (optional - translations)
--   └── scripts/         (optional - additional Lua scripts)

local ModController = _G.class("ModController")

local function readModManifest(modPath)
    local manifestPath = modPath .. "/mod.lua"
    local content = love.filesystem.read("string", manifestPath)
    if not content then return nil end

    -- Execute the mod.lua in a sandboxed environment
    local env = {
        name = "unknown",
        version = "0.0.0",
        author = "unknown",
        description = "",
        dependencies = {},
        onLoad = function() end,
        onUnload = function() end,
        onTick = function(dt) end,
        onBuildingPlaced = function(building) end,
        onUnitRecruited = function(unit) end,
    }

    local fn, err = loadstring(content, manifestPath)
    if not fn then
        print("Error loading mod manifest: " .. tostring(err))
        return nil
    end

    setfenv(fn, env)
    local ok, err2 = pcall(fn)
    if not ok then
        print("Error executing mod manifest: " .. tostring(err2))
        return nil
    end

    return env
end

function ModController:initialize()
    self.mods = {}
    self.loadedMods = {}
    self.enabledMods = {}
    self.hooks = {
        onLoad = {},
        onUnload = {},
        onTick = {},
        onBuildingPlaced = {},
        onUnitRecruited = {},
    }
    print("ModController initialized")
end

function ModController:discoverMods()
    local modsDir = "mods"
    local items = love.filesystem.getDirectoryItems(modsDir)

    self.mods = {}
    for _, item in ipairs(items) do
        local modPath = modsDir .. "/" .. item
        local info = love.filesystem.getInfo(modPath)
        if info and info.type == "directory" then
            -- Skip example mod
            if item ~= "example_mod" then
                local manifest = readModManifest(modPath)
                if manifest then
                    manifest.path = modPath
                    manifest.directory = item
                    self.mods[item] = manifest
                    print(string.format("Discovered mod: %s v%s by %s",
                        manifest.name, manifest.version, manifest.author))
                end
            end
        end
    end

    return self.mods
end

function ModController:loadMod(modName)
    local mod = self.mods[modName]
    if not mod then
        print("Mod not found: " .. modName)
        return false
    end

    if self.loadedMods[modName] then
        print("Mod already loaded: " .. modName)
        return true
    end

    -- Check dependencies
    for dep, version in pairs(mod.dependencies or {}) do
        if not self.loadedMods[dep] then
            print(string.format("Missing dependency for %s: %s (required %s)",
                modName, dep, version))
            return false
        end
    end

    -- Add mod path to package.path for require()
    local modScriptsPath = mod.path .. "/scripts/?.lua"
    package.path = package.path .. ";" .. modScriptsPath

    -- Call onLoad hook
    local ok, err = pcall(mod.onLoad)
    if not ok then
        print(string.format("Error in %s.onLoad: %s", modName, tostring(err)))
        return false
    end

    self.loadedMods[modName] = mod
    self.enabledMods[modName] = true

    -- Register hooks
    for hookName, _ in pairs(self.hooks) do
        if mod[hookName] then
            table.insert(self.hooks[hookName], mod)
        end
    end

    print(string.format("Loaded mod: %s v%s", mod.name, mod.version))
    return true
end

function ModController:unloadMod(modName)
    local mod = self.loadedMods[modName]
    if not mod then return false end

    -- Call onUnload hook
    local ok, err = pcall(mod.onUnload)
    if not ok then
        print(string.format("Error in %s.onUnload: %s", modName, tostring(err)))
    end

    -- Remove from hooks
    for hookName, _ in pairs(self.hooks) do
        for i, m in ipairs(self.hooks[hookName]) do
            if m == mod then
                table.remove(self.hooks[hookName], i)
                break
            end
        end
    end

    self.loadedMods[modName] = nil
    self.enabledMods[modName] = nil
    print(string.format("Unloaded mod: %s", modName))
    return true
end

function ModController:loadAll()
    self:discoverMods()
    local loaded, failed = 0, 0
    for modName, _ in pairs(self.mods) do
        if self:loadMod(modName) then
            loaded = loaded + 1
        else
            failed = failed + 1
        end
    end
    print(string.format("Mod loading complete: %d loaded, %d failed", loaded, failed))
    return loaded, failed
end

function ModController:unloadAll()
    for modName, _ in pairs(self.loadedMods) do
        self:unloadMod(modName)
    end
end

-- Hook system - called from various points in the game
function ModController:callHook(hookName, ...)
    if not self.hooks[hookName] then return end
    for _, mod in ipairs(self.hooks[hookName]) do
        if self.enabledMods[mod.directory] and mod[hookName] then
            local ok, err = pcall(mod[hookName], ...)
            if not ok then
                print(string.format("Error in %s.%s: %s", mod.directory, hookName, tostring(err)))
            end
        end
    end
end

function ModController:onTick(dt)
    self:callHook("onTick", dt)
end

function ModController:onBuildingPlaced(building)
    self:callHook("onBuildingPlaced", building)
end

function ModController:onUnitRecruited(unit)
    self:callHook("onUnitRecruited", unit)
end

function ModController:getLoadedMods()
    local list = {}
    for name, mod in pairs(self.loadedMods) do
        table.insert(list, {
            name = mod.name,
            version = mod.version,
            author = mod.author,
            description = mod.description,
            directory = mod.directory,
        })
    end
    return list
end

function ModController:enableMod(modName)
    if self.loadedMods[modName] then
        self.enabledMods[modName] = true
        return true
    end
    return false
end

function ModController:disableMod(modName)
    if self.loadedMods[modName] then
        self.enabledMods[modName] = false
        return true
    end
    return false
end

return ModController:new()
