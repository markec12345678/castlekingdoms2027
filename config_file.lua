local ini = require("libraries.inifile")

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
    }
}

local config = {}

function config:save(config_in)
    -- Only get the relevent sections from config
    local config_save = {}
    config_save.general = config_in.general
    config_save.video = config_in.video
    config_save.sound = config_in.sound
    
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
    local configFile = ini.parse("config.ini")

    -- Transfer configFile sections into config
    config.general = configFile.general
    config.video = configFile.video
    config.sound = configFile.sound

    -- Check the config parameters
    local save = false
    if type(config.general.attachConsole) ~= "boolean" then
        print("Config Paramenter general.attachConsole is invalid type or does not exist. Using default value.")
        config.general.attachConsole = defaultConfig.general.attachConsole
        save = true
    end

    if type(config.video.resolutionHeight) ~= "number" or config.video.resolutionHeight < 0 then
        print("Config Paramenter video.resolutionHeight is invalid type or does not exist. Using default value.")
        config.video.resolutionHeight = defaultConfig.video.resolutionHeight
        save = true
    end

    if type(config.video.resolutionWidth) ~= "number" or config.video.resolutionWidth < 0 then
        print("Config Paramenter video.resolutionWidth is invalid type or does not exist. Using default value.")
        config.video.resolutionHeight = defaultConfig.video.resolutionHeight
        save = true
    end

    if type(config.video.vsync) ~= "boolean" then
        print("Config Paramenter video.vsync is invalid type or does not exist. Using default value.")
        config.video.vsync = defaultConfig.video.vsync
        save = true
    end

    if type(config.video.fullscreen) ~= "boolean" then
        print("Config Paramenter video.fullscreen is invalid type or does not exist. Using default value.")
        config.video.fullscreen = defaultConfig.video.fullscreen
        save = true
    end

    if type(config.video.borderless) ~= "boolean" then
        print("Config Paramenter video.borderless is invalid type or does not exist. Using default value.")
        config.video.borderless = defaultConfig.video.borderless
        save = true
    end

    if type(config.video.display) ~= "number" then
        print("Config Paramenter video.display is invalid type or does not exist. Using default value.")
        config.video.display = defaultConfig.video.display
        save = true
    end

    if type(config.video.fullscreenType) ~= "string" or
        (config.video.fullscreenType ~= "desktop" and config.video.fullscreenType ~= "exclusive") then
        print("Config Paramenter video.fullscreenType is invalid type or does not exist. Using default value.")
        config.video.fullscreenType = defaultConfig.video.fullscreenType
        save = true
    end

    if type(config.sound.effects) ~= "number" then
        print("Config Paramenter soud.effects is invalid type or does not exist. Using default value.")
        config.sound.effects = defaultConfig.sound.effects
        save = true
    elseif config.sound.effects > 100 or config.sound.effects < 1 then
        print("Config Paramenter sound.effects is out of range (must be betweeen 1 and 100). Using default value.")
        config.sound.effects = defaultConfig.sound.effects
        save = true
    end

    if type(config.sound.music) ~= "number" then
        print("Config Paramenter soud.music is invalid type or does not exist. Using default value.")
        config.sound.music = defaultConfig.sound.music
        save = true
    elseif config.sound.music > 100 or config.sound.music < 0 then
        print("Config Paramenter sound.music is out of range (must be betweeen 1 and 100). Using default value.")
        config.sound.music = defaultConfig.sound.music
        save = true
    end

    if type(config.sound.speech) ~= "number" then
        print("Config Paramenter soud.speech is invalid type or does not exist. Using default value.")
        config.sound.speech = defaultConfig.sound.speech
        save = true
    elseif config.sound.speech > 100 or config.sound.speech < 0 then
        print("Config Paramenter sound.speech is out of range (must be betweeen 1 and 100). Using default value.")
        config.sound.speech = defaultConfig.sound.speech
        save = true
    end

    if save then
        ini.save("config.ini", config)
    end

    return config
end

return config:new()
