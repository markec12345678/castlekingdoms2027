-- Test script za Stronghold 2027
-- Preverja sintakso Lua datotek in YAML prevodov
-- Namen: hitra validacija brez LÖVE graphics modula

local function printHeader(title)
    print("\n" .. string.rep("=", 60))
    print("  " .. title)
    print(string.rep("=", 60))
end

local function printResult(name, ok, msg)
    local status = ok and "✓ PASS" or "✗ FAIL"
    print(string.format("  %s | %s%s", status, name, msg and (" - " .. msg) or ""))
end

local pass, fail = 0, 0

-- Test 1: Preveri vse Lua datoteke za sintakso
printHeader("TEST 1: Lua sintaksa datotek")
local luaFiles = {
    "main.lua",
    "conf.lua",
    "global.lua",
    "config_file.lua",
    "misc.lua",
    "objects/Enums/Languages.lua",
    "objects/Controllers/LanguageController.lua",
}

for _, file in ipairs(luaFiles) do
    local f = io.open(file, "r")
    if f then
        local content = f:read("*all")
        f:close()
        local fn, err = loadstring(content)
        if fn then
            printResult(file, true)
            pass = pass + 1
        else
            printResult(file, false, err)
            fail = fail + 1
        end
    else
        printResult(file, false, "file not found")
        fail = fail + 1
    end
end

-- Test 2: Preveri slovenski prevod
printHeader("TEST 2: Slovenski prevod (slv.yaml)")

local slvFile = io.open("locale/slv.yaml", "r")
if slvFile then
    local content = slvFile:read("*all")
    slvFile:close()

    local checks = {
        {"Naziv misije 1", content:match("Les in Kamen")},
        {"Naziv misije 2", content:match("Tekma v oboroževanju")},
        {"Naziv misije 3", content:match("Praznik ali lakota")},
        {"Lovčeva koliba", content:match("Lovčeva koliba")},
        {"Žitnica", content:match("Žitnica")},
        {"Vojašnica", content:match("Vojašnica")},
        {"Katedrala", content:match("Katedrala")},
        {"Lokostrelec", content:match("Lokostrelec")},
        {"Vitez", content:match("Vitez")},
        {"Mesec januar", content:match("Jan")},
        {"Mesec december", content:match("Dec")},
        {"Brez obrokov", content:match("Brez obrokov")},
        {"Brez davka", content:match("Brez davka")},
    }

    for _, check in ipairs(checks) do
        if check[2] then
            printResult(check[1], true)
            pass = pass + 1
        else
            printResult(check[1], false, "manjka v prevodu")
            fail = fail + 1
        end
    end

    local _, lines = content:gsub("\n", "\n")
    if lines > 400 then
        printResult(string.format("Število vrstic (%d)", lines), true)
        pass = pass + 1
    else
        printResult(string.format("Število vrstic (%d)", lines), false, "premalo")
        fail = fail + 1
    end
else
    printResult("slv.yaml", false, "datoteka ne obstaja")
    fail = fail + 1
end

-- Test 3: Preveri registracijo slovenščine v kodi
printHeader("TEST 3: Registracija slovenščine v kodi")

local langFile = io.open("objects/Enums/Languages.lua", "r")
if langFile then
    local content = langFile:read("*all")
    langFile:close()
    if content:match('SLV = "SLV"') then
        printResult("SLV v Languages.lua", true)
        pass = pass + 1
    else
        printResult("SLV v Languages.lua", false, "manjka")
        fail = fail + 1
    end
end

local lcFile = io.open("objects/Controllers/LanguageController.lua", "r")
if lcFile then
    local content = lcFile:read("*all")
    lcFile:close()
    if content:match('LANG%.SLV') then
        printResult("SLV v LanguageController (translations array)", true)
        pass = pass + 1
    else
        printResult("SLV v LanguageController (translations array)", false, "manjka")
        fail = fail + 1
    end
    if content:match('SLV = "Slovenščina"') then
        printResult("Slovenščina ime v translationNames", true)
        pass = pass + 1
    else
        printResult("Slovenščina ime v translationNames", false, "manjka")
        fail = fail + 1
    end
end

-- Povzetek
printHeader("POVZETEK TESTOV")
print(string.format("  Uspešnih: %d", pass))
print(string.format("  Neuspešnih: %d", fail))
print(string.format("  Skupno: %d", pass + fail))
print(string.rep("=", 60))

if fail == 0 then
    print("  VSI TESTI USPELI!")
else
    print(string.format("  %d testov ni uspelo", fail))
end
print("")

os.exit(fail == 0 and 0 or 1)
