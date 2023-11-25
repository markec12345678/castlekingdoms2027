local LANG = require("objects.Enums.Languages")
local LanguageController = _G.class("LanguageController")
local langFile

local yaml = require("libraries.yaml.yaml")
local function readAll(file)
    local content, size = love.filesystem.read("string", file)
    if not content then error(size) end
    return content
end

local function loadTranslations(folder)
    ---@type { ENG: table }
    local translations = {}
    local filesTable = love.filesystem.getDirectoryItems(folder)
    for _, v in ipairs(filesTable) do
        local file = folder .. "/" .. v
        local info = love.filesystem.getInfo(folder .. "/" .. v)
        if info then
            if info.type == "file" then
                local extension = file:match("^.+(%..+)$")
                local filename = file:gsub("%.yaml", "")
                filename = filename:gsub(".*/", "")
                if extension == ".yaml" then
                    local content = readAll(file)
                    translations[string.upper(filename)] = yaml.eval(content)
                end
            end
        end
    end


    local english = readAll("locale/source/strings.yaml")
    translations["ENG"] = yaml.eval(english)
    local mt = {}
    function mt.__index(self, index)
        -- fallback to english translations if none are found
        return rawget(translations["ENG"], index)
    end

    for k, v in pairs(translations) do
        if k ~= "ENG" then
            setmetatable(v, mt)
        end
    end
    return translations
end

function LanguageController:initialize()
    self.translations = { LANG.POL, LANG.POR, LANG.ENG }
    self.allTranslations = loadTranslations("locale")
    self.currentLanguage = _G.currentLang or "ENG"
    self.lines = self.allTranslations[self.currentLanguage]
    if not self.lines then
        print("falling back to ENG translation, did not find for", self.currentLanguage)
        self.lines = self.allTranslations["ENG"]
    end
end

function LanguageController:loadLanguage()
    langFile = self.allTranslations[self.currentLanguage]
    if not langFile then error("missing translations for", self.currentLanguage) end
    self.lines = langFile
end

return LanguageController
