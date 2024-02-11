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
    local content = readAll("locale/source/strings.yaml")
    translations["ENG"] = yaml.eval(content)
    translations["base"] = yaml.eval(content)

    return translations
end

local function tableMerge(t1, t2)
    for k, v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k] or false) == "table" then
                tableMerge(t1[k] or {}, t2[k] or {})
            else
                t1[k] = v
            end
        else
            t1[k] = v
        end
    end
    return t1
end

function LanguageController:initialize()
    self.translations = { LANG.DEU, LANG.ENG, LANG.FRA, LANG.ITA, LANG.POL, LANG.POR, LANG.RUS, LANG.UKR, LANG.HUN }
    self.translationNames = {
        DEU = "Deutsch",
        ENG = "English",
        FRA = "Français",
        ITA = "Italiano",
        POL = "Polski",
        POR = "Português",
        RUS = "Русский",
        UKR = "Українська",
        HUN = "Magyar",
    }
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

    self.lines = tableMerge(self.allTranslations["base"], langFile)
end

return LanguageController
