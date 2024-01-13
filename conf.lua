if jit.arch == "arm64" then
    print("Detected ARM processor, turning off JIT")
    jit.off()
end

local function tobool(v)
    return v and ((type(v) == "number") and (v == 1) or ((type(v) == "string") and (v == "true")))
end

function love.conf(t)
    _G.testMode = false
    _G.args = {}
    _G.currentLang = "ENG"
    local config = require("config_file")
    local resolutionWidth = config.video.resolutionWidth
    local resolutionHeight = config.video.resolutionHeight
    local fullscreen = config.video.fullscreen
    local resizable = config.video.resizable
    local borderless = config.video.borderless

    for ind, val in ipairs(_G.arg) do
        if val == "--test" then
            _G.testMode = true
            table.remove(_G.arg, ind)
            break
        elseif val == "--debug" then
            _G.debugMode = true
        elseif val == "new" then
            love.filesystem.remove("status.bin")
        elseif val == "--resolution" then
            resolutionWidth = tonumber(_G.arg[ind + 1])
            resolutionHeight = tonumber(_G.arg[ind + 2])
        elseif val == "--fullscreen" then
            fullscreen = tobool(_G.arg[ind + 1])
            borderless = fullscreen
        elseif val == "--resize" then
            resizable = tobool(_G.arg[ind + 1])
        elseif val == "--pol" or val == "--POL" then
            _G.currentLang = "POL"
        elseif val == "--por" or val == "--POR" then
            _G.currentLang = "POR"
        end
    end

    -- Apply config
    t.identity = "StoneKingdoms"                          -- The name of the save directory (string)
    t.version = "11.5"                                    -- The LÖVE version this game was made for (string)
    t.console = config.general.attachConsole              -- Attach a console (boolean, Windows only)
    t.accelerometerjoystick = false                       -- Enable the accelerometer on iOS and Android by exposing it as a Joystick (boolean)
    t.externalstorage = false                             -- True to save files (and read from the save directory) in external storage on Android (boolean)
    t.gammacorrect = false                                -- Enable gamma-correct rendering, when supported by the system (boolean)
    t.window.title = "Stone Kingdoms"                     -- The window title (string)
    t.window.icon = nil                                   -- Filepath to an image to use as the window's icon (string)
    t.window.width = resolutionWidth                      -- The window width (number)
    t.window.height = resolutionHeight                    -- The window height (number)
    t.window.borderless = borderless                      -- Remove all border visuals from the window (boolean)
    t.window.resizable = resizable                        -- Let the window be user-resizable (boolean)
    t.window.minwidth = 1                                 -- Minimum window width if the window is resizable (number)
    t.window.minheight = 1                                -- Minimum window height if the window is resizable (number)
    t.window.fullscreen = fullscreen                      -- config.video.fullscreen -- Enable fullscreen (boolean)
    t.window.fullscreentype = config.video.fullscreenType -- Choose between "desktop" fullscreen or "exclusive" fullscreen mode (string)
    t.window.vsync = config.video.vsync                   -- Enable vertical sync (boolean)
    t.window.msaa = 1                                     -- The number of samples to use with multi-sampled antialiasing (number)
    t.window.display = config.video.display               -- Index of the monitor to show the window in (number)
    t.window.highdpi = false                              -- Enable high-dpi mode for the window on a Retina display (boolean)
    t.window.x = nil                                      -- The x-coordinate of the window's position in the specified display (number)
    t.window.y = nil                                      -- The y-coordinate of the window's position in the specified display (number)

    t.modules.audio = not _G.testMode                     -- Enable the audio module (boolean)
    t.modules.event = true                                -- Enable the event module (boolean)
    t.modules.graphics = not _G.testMode                  -- Enable the graphics module (boolean)
    t.modules.image = true                                -- Enable the image module (boolean)
    t.modules.joystick = false                            -- Enable the joystick module (boolean)
    t.modules.keyboard = true                             -- Enable the keyboard module (boolean)
    t.modules.math = true                                 -- Enable the math module (boolean)
    t.modules.mouse = true                                -- Enable the mouse module (boolean)
    t.modules.physics = false                             -- Enable the physics module (boolean)
    t.modules.sound = true                                -- Enable the sound module (boolean)
    t.modules.system = true                               -- Enable the system module (boolean)
    t.modules.timer = true                                -- Enable the timer module (boolean), Disabling it will result 0 delta time in love.update
    t.modules.touch = true                                -- Enable the touch module (boolean)
    t.modules.video = false                               -- Enable the video module (boolean)
    t.modules.window = not _G.testMode                    -- Enable the window module (boolean)
    t.modules.thread = true                               -- Enable the thread module (boolean)
end
