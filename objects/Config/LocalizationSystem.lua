-- objects/Config/LocalizationSystem.lua
-- Castle Kingdoms 2027 - Localization System
--
-- Manages multi-language support:
-- - 32 languages (SL, EN, SR, EL, BG, MK, LT, LV, DE, FR, ES, IT, ...)
-- - Runtime language switching
-- - Fallback to English if translation missing
-- - YAML file loading from /locale/
-- - Font switching per language (CJK, Cyrillic, etc.)
--
-- Usage:
--   local L10n = require("objects.Config.LocalizationSystem")
--   L10n.init()
--   L10n.setLanguage("slv")
--   local text = L10n.get("buildings.barracks.name")

local LocalizationSystem = {}

local SUPPORTED_LANGUAGES = {
    slv = { name = "Slovenian",  nativeName = "Slovenščina",  font = "default" },
    eng = { name = "English",    nativeName = "English",       font = "default" },
    srp = { name = "Serbian",    nativeName = "Српски",        font = "cyrillic" },
    ell = { name = "Greek",      nativeName = "Ελληνικά",      font = "greek" },
    bul = { name = "Bulgarian",  nativeName = "Български",     font = "cyrillic" },
    mkd = { name = "Macedonian", nativeName = "Македонски",    font = "cyrillic" },
    lit = { name = "Lithuanian", nativeName = "Lietuvių",      font = "default" },
    lav = { name = "Latvian",    nativeName = "Latviešu",      font = "default" },
    deu = { name = "German",     nativeName = "Deutsch",       font = "default" },
    fra = { name = "French",     nativeName = "Français",      font = "default" },
    spa = { name = "Spanish",    nativeName = "Español",       font = "default" },
    ita = { name = "Italian",    nativeName = "Italiano",      font = "default" },
    pol = { name = "Polish",     nativeName = "Polski",        font = "default" },
    rus = { name = "Russian",    nativeName = "Русский",       font = "cyrillic" },
    ukr = { name = "Ukrainian",  nativeName = "Українська",    font = "cyrillic" },
    ces = { name = "Czech",      nativeName = "Čeština",       font = "default" },
    hun = { name = "Hungarian",  nativeName = "Magyar",        font = "default" },
    ron = { name = "Romanian",   nativeName = "Română",        font = "default" },
    nld = { name = "Dutch",      nativeName = "Nederlands",    font = "default" },
    swe = { name = "Swedish",    nativeName = "Svenska",       font = "default" },
    dan = { name = "Danish",     nativeName = "Dansk",         font = "default" },
    fin = { name = "Finnish",    nativeName = "Suomi",         font = "default" },
    nor = { name = "Norwegian",  nativeName = "Norsk",         font = "default" },
    por = { name = "Portuguese", nativeName = "Português",     font = "default" },
    tur = { name = "Turkish",    nativeName = "Türkçe",        font = "default" },
    ara = { name = "Arabic",     nativeName = "العربية",       font = "arabic", rtl = true },
    heb = { name = "Hebrew",     nativeName = "עברית",         font = "hebrew",  rtl = true },
    jpn = { name = "Japanese",   nativeName = "日本語",         font = "cjk" },
    kor = { name = "Korean",     nativeName = "한국어",         font = "cjk" },
    zho = { name = "Chinese",    nativeName = "中文",           font = "cjk" },
    vie = { name = "Vietnamese", nativeName = "Tiếng Việt",    font = "default" },
    tha = { name = "Thai",       nativeName = "ไทย",           font = "thai" },
    est = { name = "Estonian",   nativeName = "Eesti",         font = "default" },
}

LocalizationSystem.SUPPORTED_LANGUAGES = SUPPORTED_LANGUAGES

local currentLanguage = "eng"
local translations = {}
local fallbackTranslations = {}
local initialized = false
local missingKeys = {}

-- Initialize
function LocalizationSystem.init()
    if initialized then return end
    initialized = true

    -- Load English as fallback
    LocalizationSystem._loadLanguage("eng", fallbackTranslations)

    -- Load saved language preference
    local savedLang = LocalizationSystem._getSavedLanguage()
    if savedLang and SUPPORTED_LANGUAGES[savedLang] then
        LocalizationSystem.setLanguage(savedLang)
    else
        LocalizationSystem.setLanguage("eng")
    end

    print("[LocalizationSystem] Initialized (language: " .. currentLanguage .. ")")
    print("[LocalizationSystem] Supported: " .. #LocalizationSystem.getLanguageList() .. " languages")
end

-- Get saved language from config
function LocalizationSystem._getSavedLanguage()
    local config = require("config_file")
    return config.general and config.general.language or nil
end

-- Save language preference
function LocalizationSystem._saveLanguage(lang)
    local config = require("config_file")
    if not config.general then config.general = {} end
    config.general.language = lang
    pcall(function() config:save() end)
end

-- Load a language file (YAML)
function LocalizationSystem._loadLanguage(langCode, targetTable)
    local filename = "locale/" .. langCode .. ".yaml"
    local file = love.filesystem.newFile(filename)
    if not file:open("r") then
        print("[LocalizationSystem] Language file not found: " .. filename)
        return false
    end

    local content = file:read()
    file:close()

    if not content then return false end

    -- Simple YAML parser (key: value format)
    -- For production, use a proper YAML library
    local currentSection = targetTable
    local stack = {targetTable}

    for line in content:gmatch("[^\r\n]+") do
        -- Skip comments and empty lines
        if not line:match("^%s*#") and not line:match("^%s*$") then
            -- Check indentation
            local indent = 0
            local trimmed = line:gsub("^%s+", function(s)
                indent = #s
                return ""
            end)

            -- Parse key: value
            local key, value = trimmed:match("^(.-):%s*(.*)$")
            if key and value and value ~= "" then
                -- Remove quotes from value
                value = value:gsub('^"', ''):gsub('"$', '')
                currentSection[key] = value
            elseif key then
                -- New section
                currentSection[key] = {}
                currentSection = currentSection[key]
            end
        end
    end

    return true
end

-- Set current language
function LocalizationSystem.setLanguage(langCode)
    if not SUPPORTED_LANGUAGES[langCode] then
        print("[LocalizationSystem] Unsupported language: " .. tostring(langCode))
        return false
    end

    if langCode == currentLanguage and next(translations) then
        return true
    end

    -- Load the language
    translations = {}
    if langCode ~= "eng" then
        LocalizationSystem._loadLanguage(langCode, translations)
    else
        -- English is already loaded as fallback
        for k, v in pairs(fallbackTranslations) do
            translations[k] = v
        end
    end

    currentLanguage = langCode
    LocalizationSystem._saveLanguage(langCode)

    print("[LocalizationSystem] Language set to: " .. langCode .. " (" .. SUPPORTED_LANGUAGES[langCode].nativeName .. ")")
    return true
end

-- Get current language
function LocalizationSystem.getLanguage()
    return currentLanguage
end

-- Get language info
function LocalizationSystem.getLanguageInfo(langCode)
    return SUPPORTED_LANGUAGES[langCode]
end

-- Get list of all languages
function LocalizationSystem.getLanguageList()
    local list = {}
    for code, info in pairs(SUPPORTED_LANGUAGES) do
        table.insert(list, {
            code = code,
            name = info.name,
            nativeName = info.nativeName,
            rtl = info.rtl or false,
        })
    end
    table.sort(list, function(a, b) return a.name < b.name end)
    return list
end

-- Get translated string
-- Supports dot notation: L10n.get("buildings.barracks.name")
-- Supports format args: L10n.get("welcome_message", playerName)
function LocalizationSystem.get(key, ...)
    -- Try current language first
    local value = LocalizationSystem._getNestedValue(translations, key)

    -- Fallback to English
    if not value then
        value = LocalizationSystem._getNestedValue(fallbackTranslations, key)
    end

    -- If still not found, return the key itself
    if not value then
        if not missingKeys[key] then
            missingKeys[key] = true
            print("[LocalizationSystem] Missing key: " .. key)
        end
        return key
    end

    -- Format with args
    local args = { ... }
    if #args > 0 then
        local ok, formatted = pcall(string.format, value, ...)
        if ok then
            return formatted
        end
    end

    return value
end

-- Shorthand alias
function LocalizationSystem.t(key, ...)
    return LocalizationSystem.get(key, ...)
end

-- Get nested value from table using dot notation
function LocalizationSystem._getNestedValue(tbl, key)
    local parts = {}
    for part in key:gmatch("[^.]+") do
        table.insert(parts, part)
    end

    local current = tbl
    for _, part in ipairs(parts) do
        if type(current) ~= "table" then return nil end
        current = current[part]
    end

    if type(current) == "string" then
        return current
    end
    return nil
end

-- Check if a language is RTL (right-to-left)
function LocalizationSystem.isRTL()
    local info = SUPPORTED_LANGUAGES[currentLanguage]
    return info and info.rtl or false
end

-- Get font type for current language
function LocalizationSystem.getFontType()
    local info = SUPPORTED_LANGUAGES[currentLanguage]
    return info and info.font or "default"
end

-- Get missing keys (for translation debugging)
function LocalizationSystem.getMissingKeys()
    local keys = {}
    for k, _ in pairs(missingKeys) do
        table.insert(keys, k)
    end
    return keys
end

-- Clear missing keys cache
function LocalizationSystem.clearMissingKeys()
    missingKeys = {}
end

-- Get stats
function LocalizationSystem.getStats()
    return {
        currentLanguage = currentLanguage,
        languageName = SUPPORTED_LANGUAGES[currentLanguage] and SUPPORTED_LANGUAGES[currentLanguage].name or "Unknown",
        totalSupported = 0,
        missingKeys = #LocalizationSystem.getMissingKeys(),
    }
end

return LocalizationSystem
