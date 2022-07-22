local class = require("libraries.middleclass")
local ini = require("libraries.inifile")

local defaultConfig = {
    general = {
        attachConsole = true
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

_G.classes = {}
local ConfigFile = class("ConfigFile")
function ConfigFile:initialize()
        -- Load config file or create it if it does not exist
        if love.filesystem.getInfo("config.ini") == nil then
            print("config.ini not found! creating it...")
            ini.save("config.ini", defaultConfig)
        else
            self.config = ini.parse("config.ini")
        end
    
        -- Check the config parameters
        local save = false
        if type(self.config.general.attachConsole) ~= "boolean" then
            print("Config Paramenter general.attachConsole is invalid type or does not exist. Using default value.")
            self.config.general.attachConsole = defaultConfig.general.attachConsole
            save = true
        end
    
        if type(self.config.video.resolutionHeight) ~= "number" or self.config.video.resolutionHeight < 0 then
            print("Config Paramenter video.resolutionHeight is invalid type or does not exist. Using default value.")
            self.config.video.resolutionHeight = defaultConfig.video.resolutionHeight
            save = true
        end
    
        if type(self.config.video.resolutionWidth) ~= "number" or self.config.video.resolutionWidth < 0 then
            print("Config Paramenter video.resolutionWidth is invalid type or does not exist. Using default value.")
            self.config.video.resolutionHeight = defaultConfig.video.resolutionHeight
            save = true
        end
    
        if type(self.config.video.vsync) ~= "boolean" then
            print("Config Paramenter video.vsync is invalid type or does not exist. Using default value.")
            self.config.video.vsync = defaultConfig.video.vsync
            save = true
        end
    
        if type(self.config.video.fullscreen) ~= "boolean" then
            print("Config Paramenter video.fullscreen is invalid type or does not exist. Using default value.")
            self.config.video.fullscreen = defaultConfig.video.fullscreen
            save = true
        end
    
        if type(self.config.video.borderless) ~= "boolean" then
            print("Config Paramenter video.borderless is invalid type or does not exist. Using default value.")
            self.config.video.borderless = defaultConfig.video.borderless
            save = true
        end
        
        if type(self.config.video.display) ~= "number" then
            print("Config Paramenter video.display is invalid type or does not exist. Using default value.")
            self.config.video.display = defaultConfig.video.display
            save = true
        end

        if type(self.config.video.fullscreenType) ~= "string" or (self.config.video.fullscreenType ~= "desktop" and self.config.video.fullscreenType ~= "exclusive") then
            print("Config Paramenter video.fullscreenType is invalid type or does not exist. Using default value.")
            self.config.video.fullscreenType = defaultConfig.video.fullscreenType
            save = true
        end

        if type(self.config.sound.effects) ~= "number" then
            print("Config Paramenter soud.effects is invalid type or does not exist. Using default value.")
            self.config.sound.effects = defaultConfig.sound.effects
            save = true
        elseif self.config.sound.effects > 100 or self.config.sound.effects < 1 then
            print("Config Paramenter sound.effects is out of range (must be betweeen 1 and 100). Using default value.")
            self.config.sound.effects = defaultConfig.sound.effects
            save = true
        end

        if type(self.config.sound.music) ~= "number" then
            print("Config Paramenter soud.music is invalid type or does not exist. Using default value.")
            self.config.sound.music = defaultConfig.sound.music
            save = true
        elseif self.config.sound.music > 100 or self.config.sound.music < 0 then
            print("Config Paramenter sound.music is out of range (must be betweeen 1 and 100). Using default value.")
            self.config.sound.music = defaultConfig.sound.music
            save = true
        end

        if type(self.config.sound.speech) ~= "number" then
            print("Config Paramenter soud.speech is invalid type or does not exist. Using default value.")
            self.config.sound.speech = defaultConfig.sound.speech
            save = true
        elseif self.config.sound.speech > 100 or self.config.sound.speech < 0 then
            print("Config Paramenter sound.speech is out of range (must be betweeen 1 and 100). Using default value.")
            self.config.sound.speech = defaultConfig.sound.speech
            save = true
        end

        if save then    
            ini.save("config.ini", self.config)
        end
end

function ConfigFile:save()
    ini.save("config.ini", self.config)
end

return ConfigFile