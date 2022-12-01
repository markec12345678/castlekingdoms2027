local ini = require("libraries.inifile")

local function shallowCopy(t, seen)
    if type(t) ~= 'table' then return t end
    if seen and seen[t] then return seen[t] end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(t))
    s[t] = res
    for k, v in pairs(t) do res[shallowCopy(k, s)] = shallowCopy(v, s) end
    return res
end

local defaultConfig = {
    general = {
        attachConsole = true,
        skipSplashScreen = false
    },
    video = {
        resolutionWidth = 0,
        resolutionHeight = 0,
        vsync = true,
        fullscreen = true,
        borderless = false,
        display = 1,
        fullscreenType = "desktop"
    },
    sound = {
        effects = 100,
        speech = 100,
        music = 100
    },
    camera = {
        holdRightButtonToPan = true,
        moveMouseToEdgesToPan = true,
        panCameraWithWASD = true,
        panCameraWithArrowKeys = true
    }
}

local config = {}

function config:save(config_in)
    -- Only get the relevent sections from config
    local config_save = {}
    for k, v in pairs(config_in) do
        if type(v) == "table" then
            config_save[k] = v
        end
    end

    ini.save("config.ini", config_save)
end

function config:new()
    -- Set app identity so config gets put in the right directory (%appdata%\LOVE\StoneKingdoms\config.ini)
    love.filesystem.setIdentity("StoneKingdoms")

    -- Load config file or create it if it does not exist
    if love.filesystem.getInfo("config.ini") == nil then
        print("config.ini not found! creating it...")
        ini.save("config.ini", defaultConfig)
    end
    local configFile = shallowCopy(defaultConfig)
    local configFileValues = ini.parse("config.ini")
    for groupKey, group in pairs(configFileValues) do
        configFile[groupKey] = group
        for k, v in pairs(group) do
            configFile[groupKey][k] = v
        end
    end

    -- Transfer configFile sections into config
    for k, v in pairs(configFile) do
        config[k] = v
    end

    -- Check the config parameters
    local save = false
    if type(config.general.attachConsole) ~= "boolean" then
        print("Config Parameter general.attachConsole is invalid type or does not exist. Using default value.")
        config.general.attachConsole = defaultConfig.general.attachConsole
        save = true
    end

    if type(config.video.resolutionHeight) ~= "number" or config.video.resolutionHeight < 0 then
        print("Config Parameter video.resolutionHeight is invalid type or does not exist. Using default value.")
        config.video.resolutionHeight = defaultConfig.video.resolutionHeight
        save = true
    end

    if type(config.video.resolutionWidth) ~= "number" or config.video.resolutionWidth < 0 then
        print("Config Parameter video.resolutionWidth is invalid type or does not exist. Using default value.")
        config.video.resolutionHeight = defaultConfig.video.resolutionHeight
        save = true
    end

    if type(config.video.vsync) ~= "boolean" then
        print("Config Parameter video.vsync is invalid type or does not exist. Using default value.")
        config.video.vsync = defaultConfig.video.vsync
        save = true
    end

    if type(config.video.fullscreen) ~= "boolean" then
        print("Config Parameter video.fullscreen is invalid type or does not exist. Using default value.")
        config.video.fullscreen = defaultConfig.video.fullscreen
        save = true
    end

    if type(config.video.borderless) ~= "boolean" then
        print("Config Parameter video.borderless is invalid type or does not exist. Using default value.")
        config.video.borderless = defaultConfig.video.borderless
        save = true
    end

    if type(config.video.display) ~= "number" then
        print("Config Parameter video.display is invalid type or does not exist. Using default value.")
        config.video.display = defaultConfig.video.display
        save = true
    end

    if type(config.video.fullscreenType) ~= "string" or
        (config.video.fullscreenType ~= "desktop" and config.video.fullscreenType ~= "exclusive") then
        print("Config Parameter video.fullscreenType is invalid type or does not exist. Using default value.")
        config.video.fullscreenType = defaultConfig.video.fullscreenType
        save = true
    end

    if type(config.sound.effects) ~= "number" then
        print("Config Parameter soud.effects is invalid type or does not exist. Using default value.")
        config.sound.effects = defaultConfig.sound.effects
        save = true
    elseif config.sound.effects > 100 or config.sound.effects < 0 then
        print("Config Parameter sound.effects is out of range (must be betweeen 1 and 100). Using default value.")
        config.sound.effects = defaultConfig.sound.effects
        save = true
    end

    if type(config.sound.music) ~= "number" then
        print("Config Parameter soud.music is invalid type or does not exist. Using default value.")
        config.sound.music = defaultConfig.sound.music
        save = true
    elseif config.sound.music > 100 or config.sound.music < 0 then
        print("Config Parameter sound.music is out of range (must be betweeen 1 and 100). Using default value.")
        config.sound.music = defaultConfig.sound.music
        save = true
    end

    if type(config.sound.speech) ~= "number" then
        print("Config Parameter soud.speech is invalid type or does not exist. Using default value.")
        config.sound.speech = defaultConfig.sound.speech
        save = true
    elseif config.sound.speech > 100 or config.sound.speech < 0 then
        print("Config Parameter sound.speech is out of range (must be betweeen 1 and 100). Using default value.")
        config.sound.speech = defaultConfig.sound.speech
        save = true
    end

    local dataConfig = {}
    for k, v in pairs(config) do
        if type(v) ~= "function" and type(v) ~= "nil" and type(v) ~= "userdata" then
            dataConfig[k] = v
        end
    end

    if save then
        ini.save("config.ini", dataConfig)
    end

    return config
end

return config:new()
