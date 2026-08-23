-- states/ui/hud/royal_icon_generator.lua
-- Castle Kingdoms 2027 - Procedural Royal System Icon Generator (v3.12.152)
--
-- Generates procedural placeholder icons for all 990 Royal systems.
-- Each icon is a 64x64 canvas with:
--   * Category-colored background (rounded square)
--   * 2-3 letter abbreviation (initials of system name)
--   * Decorative element based on category (anvil, book, leaf, etc.)
--   * Subtle border matching category color
--
-- Icons are cached after first generation — subsequent calls return cached canvas.
-- Toggle: not user-facing (used internally by Royal Systems Panel, Tech Tree, etc.)

local RoyalIconGenerator = {}

-- Cache of generated icons: key = systemName, value = love Canvas
local iconCache = {}

-- Icon size (square)
local ICON_SIZE = 64

-- Category color palette (matches ASSET_PRIORITY_PLAN.md categories)
-- Note: keys use ASCII-safe identifiers (no diacritics) for compatibility
local CATEGORY_COLORS = {
    -- Material crafts
    ["Steklarstvo"]     = { 0.30, 0.70, 0.90 },  -- light blue (glass)
    ["Livarnstvo"]      = { 0.90, 0.50, 0.20 },  -- orange (molten metal)
    ["Kovastvo"]        = { 0.80, 0.40, 0.30 },  -- red-brown (iron)
    ["Usnjarstvo"]      = { 0.55, 0.35, 0.20 },  -- brown (leather)
    ["Keramika"]        = { 0.85, 0.65, 0.50 },  -- terracotta
    ["Vrvicarstvo"]     = { 0.70, 0.55, 0.30 },  -- tan (rope)
    ["Nakit"]           = { 0.95, 0.80, 0.40 },  -- gold (jewelry)

    -- Document / writing
    ["Knjigovestvo"]    = { 0.70, 0.50, 0.80 },  -- purple (books)
    ["Aptekarstvo"]     = { 0.40, 0.80, 0.50 },  -- green (herbs)

    -- Food & beverage
    ["Mlinarstvo"]      = { 0.85, 0.75, 0.30 },  -- wheat yellow
    ["Pekarstvo"]       = { 0.90, 0.70, 0.40 },  -- bread crust
    ["Pivovarstvo"]     = { 0.75, 0.55, 0.25 },  -- ale amber
    ["Mlekarstvo"]      = { 0.95, 0.92, 0.85 },  -- milk white
    ["Vrtnarstvo"]      = { 0.40, 0.80, 0.30 },  -- leaf green
    ["Voskarstvo"]      = { 0.95, 0.85, 0.40 },  -- wax yellow

    -- Animals
    ["Zivali"]          = { 0.60, 0.45, 0.30 },  -- animal brown
    ["Konjenistvo"]     = { 0.45, 0.30, 0.20 },  -- horse dark brown

    -- Combat / weapons
    ["Orozje"]          = { 0.70, 0.30, 0.25 },  -- weapon red
    ["Heraldika"]       = { 0.80, 0.20, 0.25 },  -- heraldic red

    -- Light & sound
    ["Osvetlitev"]      = { 1.00, 0.85, 0.40 },  -- candle yellow
    ["Zvonjenje"]       = { 0.85, 0.75, 0.30 },  -- bell brass

    -- Infrastructure
    ["Vodovod"]         = { 0.30, 0.60, 0.85 },  -- water blue
    ["Arhitektura"]     = { 0.65, 0.60, 0.55 },  -- stone gray
    ["Voznistvo"]       = { 0.50, 0.40, 0.30 },  -- wood brown

    -- Science / astronomy
    ["Astronomija"]     = { 0.20, 0.20, 0.50 },  -- night blue
    ["Racunovodstvo"]   = { 0.40, 0.40, 0.45 },  -- slate

    -- Trade & misc
    ["Trgovina"]        = { 0.30, 0.65, 0.45 },  -- trade green

    -- Default / uncategorized
    ["Ostalo"]          = { 0.60, 0.60, 0.60 },  -- gray
}

-- Category decorative element type (drawn over initials)
local CATEGORY_DECOR = {
    ["Steklarstvo"]     = "vial",       -- bottle/vial shape
    ["Livarnstvo"]      = "ingot",      -- rectangular block
    ["Kovastvo"]        = "anvil",      -- T-shape
    ["Usnjarstvo"]      = "hide",       -- organic shape
    ["Keramika"]        = "pot",        -- bowl shape
    ["Vrvicarstvo"]     = "coil",       -- spiral
    ["Nakit"]           = "gem",        -- diamond

    ["Knjigovestvo"]    = "book",       -- rectangle with line
    ["Aptekarstvo"]     = "mortar",     -- U-shape

    ["Mlinarstvo"]      = "grain",      -- vertical lines
    ["Pekarstvo"]       = "loaf",       -- oval
    ["Pivovarstvo"]     = "barrel",     -- rectangle with bands
    ["Mlekarstvo"]      = "jug",        -- bottle
    ["Vrtnarstvo"]      = "leaf",       -- leaf shape
    ["Voskarstvo"]      = "candle",     -- vertical bar

    ["Zivali"]          = "paw",        -- circle + dots
    ["Konjenistvo"]     = "horseshoe",  -- arc

    ["Orozje"]          = "sword",      -- vertical line
    ["Heraldika"]       = "shield",      -- shield shape

    ["Osvetlitev"]      = "flame",      -- triangle
    ["Zvonjenje"]       = "bell",       -- bell shape

    ["Vodovod"]         = "wave",       -- wavy line
    ["Arhitektura"]     = "column",     -- vertical lines
    ["Voznistvo"]       = "wheel",      -- circle with spokes

    ["Astronomija"]     = "star",       -- star shape
    ["Racunovodstvo"]   = "abacus",     -- grid

    ["Trgovina"]        = "coin",       -- circle with border

    ["Ostalo"]          = "circle",    -- default
}

-- Category keywords for detection (lowercase match against system name)
local CATEGORY_KEYWORDS_LUA = {
    ["Steklarstvo"]     = { "glass", "stekl", "beaker", "flask", "alembic", "crucible" },
    ["Livarnstvo"]      = { "cast", "mold", "foundry", "ingot", "bronze", "brass", "copper", "lehr", "annealing" },
    ["Kovastvo"]        = { "anvil", "forge", "hammer", "smith", "iron", "steel", "bellows", "tongs", "hardy", "fuller", "clinker", "pritchel" },
    ["Usnjarstvo"]      = { "leather", "hide", "tanner", "fur" },
    ["Keramika"]        = { "tile", "mosaic", "glaze", "ceramic", "pottery", "potter" },
    ["Vrvicarstvo"]     = { "rope", "cord", "twine", "net", "bobbin" },
    ["Nakit"]           = { "jewel", "gem", "pendant", "ring", "necklace", "brooch" },

    ["Knjigovestvo"]    = { "book", "quill", "scroll", "manuscript", "parchment", "ink", "spine", "cover", "folio", "vellum", "writing", "chronicle", "codex" },
    ["Aptekarstvo"]     = { "apothecary", "mortar", "vial", "potion", "elixir" },

    ["Mlinarstvo"]      = { "mill", "grain", "hopper", "sail", "millstone", "flour", "dough", "bran", "auger" },
    ["Pekarstvo"]       = { "baker", "oven", "bread", "pastry", "confection", "baking" },
    ["Pivovarstvo"]     = { "brewer", "ale", "beer", "ferment", "wort", "distill", "vineyard", "wine" },
    ["Mlekarstvo"]      = { "cheese", "dairy", "milk", "cream", "yogurt", "butter" },
    ["Vrtnarstvo"]      = { "garden", "soil", "plant", "water", "hoe", "spade", "sickle", "trellis", "aloe", "cultivat", "compost", "mulch", "furrow", "pruning", "hedge" },
    ["Voskarstvo"]      = { "candle", "wax", "tallow", "chandlery" },

    ["Zivali"]          = { "apiary", "aviary", "aquarium", "menagerie", "bee", "honey", "butterfly", "breeder" },
    ["Konjenistvo"]     = { "horse", "bridle", "saddle", "stable", "horseshoe" },

    ["Orozje"]          = { "sword", "spear", "pike", "mace", "bow", "crossbow", "arbalest" },
    ["Heraldika"]       = { "banner", "flag", "herald", "crest", "shield" },

    ["Osvetlitev"]      = { "candle", "torch", "beacon", "lamp", "chandler", "candelabra", "candlestick" },
    ["Zvonjenje"]       = { "bell", "chime", "carillon", "glockenspiel" },

    ["Vodovod"]         = { "aqueduct", "bath", "well", "fountain", "cistern" },
    ["Arhitektura"]     = { "column", "pillar", "arch", "aqueduct" },
    ["Voznistvo"]       = { "cart", "wagon", "wheel", "carriage" },

    ["Astronomija"]     = { "astrolabe", "armillary", "quadrant", "compass", "sundial", "armillary" },
    ["Racunovodstvo"]   = { "abacus", "scale", "balance", "counter" },

    ["Trgovina"]        = { "market", "trade", "merchant" },
}

-- Get category for a system based on its name
function RoyalIconGenerator.getCategory(systemName)
    if not systemName or systemName == "" then
        return "Ostalo"
    end
    local lower = systemName:lower()
    for cat, keywords in pairs(CATEGORY_KEYWORDS_LUA) do
        for _, kw in ipairs(keywords) do
            if lower:find(kw, 1, true) then
                return cat
            end
        end
    end
    return "Ostalo"
end

-- Get category color (RGB 0-1)
function RoyalIconGenerator.getCategoryColor(category)
    return CATEGORY_COLORS[category] or CATEGORY_COLORS.Ostalo
end

-- Get initials from system name (first 2-3 letters, uppercase)
local function getInitials(name)
    if not name or name == "" then
        return "??"
    end
    -- Strip common prefixes
    local cleaned = name:gsub("^Royal", "")
    -- Take first 2-3 letters
    local initials = cleaned:sub(1, 3):upper()
    -- If starts with consonant cluster, take 2
    if initials:match("^[BCDFGHJKLMNPQRSTVWZ]{3}$") then
        initials = initials:sub(1, 2)
    end
    return initials
end

-- Draw decorative element based on category
local function drawDecor(decorType, cx, cy, size, r, g, b)
    love.graphics.setColor(r, g, b, 0.9)
    local s = size * 0.35  -- decor is ~35% of icon size

    if decorType == "anvil" then
        -- T-shape for anvil
        love.graphics.rectangle("fill", cx - s, cy - s*0.4, s*2, s*0.4)
        love.graphics.rectangle("fill", cx - s*0.3, cy - s*0.4, s*0.6, s*1.0)
    elseif decorType == "book" then
        -- Rectangle with line (book spine)
        love.graphics.rectangle("fill", cx - s*0.7, cy - s*0.9, s*1.4, s*1.8)
        love.graphics.setColor(0.15, 0.1, 0.05, 0.7)
        love.graphics.line(cx - s*0.7, cy, cx + s*0.7, cy)
    elseif decorType == "vial" or decorType == "flask" then
        -- Bottle shape
        love.graphics.rectangle("fill", cx - s*0.3, cy - s*0.9, s*0.6, s*0.3)  -- neck
        love.graphics.polygon("fill", cx - s*0.7, cy + s*0.9, cx + s*0.7, cy + s*0.9,
                              cx + s*0.5, cy - s*0.6, cx - s*0.5, cy - s*0.6)
    elseif decorType == "ingot" or decorType == "brick" then
        -- Rectangular block
        love.graphics.rectangle("fill", cx - s*0.8, cy - s*0.4, s*1.6, s*0.8)
    elseif decorType == "leaf" then
        -- Leaf shape (ellipse + line)
        love.graphics.ellipse("fill", cx, cy, s*0.7, s*1.0)
        love.graphics.setColor(0.2, 0.3, 0.15, 0.7)
        love.graphics.line(cx, cy - s, cx, cy + s)
    elseif decorType == "grain" then
        -- Vertical lines (wheat)
        for i = -1, 1 do
            love.graphics.line(cx + i*s*0.3, cy - s, cx + i*s*0.3, cy + s)
        end
    elseif decorType == "bell" then
        -- Bell shape (trapezoid + arc)
        love.graphics.polygon("fill", cx - s*0.6, cy + s*0.7, cx + s*0.6, cy + s*0.7,
                              cx + s*0.4, cy - s*0.6, cx - s*0.4, cy - s*0.6)
        love.graphics.circle("fill", cx, cy - s*0.8, s*0.15)
    elseif decorType == "candle" or decorType == "flame" then
        -- Vertical bar with flame tip
        love.graphics.rectangle("fill", cx - s*0.2, cy - s*0.3, s*0.4, s*1.3)
        love.graphics.polygon("fill", cx, cy - s, cx - s*0.2, cy - s*0.3, cx + s*0.2, cy - s*0.3)
    elseif decorType == "shield" then
        -- Shield shape
        love.graphics.polygon("fill", cx, cy - s, cx + s*0.8, cy - s*0.7,
                              cx + s*0.8, cy + s*0.3, cx, cy + s,
                              cx - s*0.8, cy + s*0.3, cx - s*0.8, cy - s*0.7)
    elseif decorType == "sword" then
        -- Vertical line (sword)
        love.graphics.rectangle("fill", cx - s*0.1, cy - s, s*0.2, s*1.8)
        love.graphics.rectangle("fill", cx - s*0.5, cy + s*0.5, s, s*0.15)
    elseif decorType == "gem" or decorType == "diamond" then
        -- Diamond shape
        love.graphics.polygon("fill", cx, cy - s, cx + s*0.7, cy, cx, cy + s, cx - s*0.7, cy)
    elseif decorType == "wheel" then
        -- Circle with spokes
        love.graphics.setLineWidth(2)
        love.graphics.circle("line", cx, cy, s*0.8)
        for i = 0, 3 do
            local a = i * math.pi / 2
            love.graphics.line(cx, cy, cx + math.cos(a)*s*0.8, cy + math.sin(a)*s*0.8)
        end
        love.graphics.setLineWidth(1)
    elseif decorType == "star" then
        -- 5-point star
        local pts = {}
        for i = 0, 9 do
            local a = (i * math.pi / 5) - math.pi / 2
            local r = (i % 2 == 0) and s or s*0.4
            table.insert(pts, cx + math.cos(a) * r)
            table.insert(pts, cy + math.sin(a) * r)
        end
        love.graphics.polygon("fill", pts)
    elseif decorType == "wave" then
        -- Wavy line
        love.graphics.setLineWidth(3)
        love.graphics.line(cx - s, cy, cx - s*0.5, cy - s*0.3, cx, cy, cx + s*0.5, cy - s*0.3, cx + s, cy)
        love.graphics.setLineWidth(1)
    elseif decorType == "coil" then
        -- Spiral
        love.graphics.setLineWidth(2)
        for i = 0, 3 do
            local r = s * (1 - i*0.2)
            love.graphics.arc("line", cx, cy, r, i * math.pi / 2, (i+1) * math.pi / 2)
        end
        love.graphics.setLineWidth(1)
    elseif decorType == "horseshoe" then
        -- Arc shape
        love.graphics.setLineWidth(4)
        love.graphics.arc("line", cx, cy, s*0.8, 0, math.pi)
        love.graphics.setLineWidth(1)
    elseif decorType == "pot" or decorType == "bowl" or decorType == "mortar" then
        -- Bowl/pot shape
        love.graphics.arc("fill", cx, cy, s*0.8, 0, math.pi)
        love.graphics.rectangle("fill", cx - s*0.8, cy - s*0.1, s*1.6, s*0.2)
    elseif decorType == "loaf" or decorType == "barrel" then
        -- Oval shape
        love.graphics.ellipse("fill", cx, cy, s*0.9, s*0.6)
    elseif decorType == "jug" then
        -- Bottle/jug
        love.graphics.rectangle("fill", cx - s*0.4, cy - s*0.9, s*0.8, s*1.6, 4, 4, 4, 4)
    elseif decorType == "column" then
        -- Vertical lines (column)
        love.graphics.rectangle("fill", cx - s*0.7, cy - s*0.9, s*0.15, s*1.8)
        love.graphics.rectangle("fill", cx + s*0.55, cy - s*0.9, s*0.15, s*1.8)
    elseif decorType == "abacus" then
        -- Grid
        love.graphics.setLineWidth(2)
        for i = -1, 1 do
            love.graphics.line(cx - s, cy + i*s*0.5, cx + s, cy + i*s*0.5)
        end
        for i = -1, 1 do
            love.graphics.line(cx + i*s*0.5, cy - s, cx + i*s*0.5, cy + s)
        end
        love.graphics.setLineWidth(1)
    elseif decorType == "coin" then
        -- Circle with border
        love.graphics.setLineWidth(2)
        love.graphics.circle("fill", cx, cy, s*0.7)
        love.graphics.setColor(r*0.5, g*0.5, b*0.5, 1)
        love.graphics.circle("line", cx, cy, s*0.7)
        love.graphics.setLineWidth(1)
    elseif decorType == "paw" then
        -- Circle + dots (paw print)
        love.graphics.circle("fill", cx, cy + s*0.3, s*0.4)
        for _, pos in ipairs({{-1, -0.4, 0.3}, {1, -0.4, 0.3}, {-0.5, -0.7, 0.25}, {0.5, -0.7, 0.25}}) do
            love.graphics.circle("fill", cx + pos[1]*s, cy + pos[2]*s, s*pos[3])
        end
    elseif decorType == "hide" then
        -- Organic shape
        love.graphics.ellipse("fill", cx, cy, s*0.9, s*0.7)
        love.graphics.setColor(r*0.5, g*0.5, b*0.5, 0.5)
        for i = 1, 4 do
            local a = i * math.pi / 2
            love.graphics.circle("fill", cx + math.cos(a)*s*0.5, cy + math.sin(a)*s*0.5, s*0.15)
        end
    elseif decorType == "circle" then
        -- Simple circle (default)
        love.graphics.circle("fill", cx, cy, s*0.7)
    else
        -- Fallback: filled circle
        love.graphics.circle("fill", cx, cy, s*0.7)
    end
end

-- Generate icon canvas for a system (cached)
-- @param systemName string - e.g. "RoyalAbacusMakerSystem" or "AbacusMaker"
-- @return love Canvas (cached)
function RoyalIconGenerator.getIcon(systemName)
    if not systemName then
        return nil
    end

    -- Check cache
    if iconCache[systemName] then
        return iconCache[systemName]
    end

    -- v3.12.154: Asset Override - check for PNG sprite in tier folders first
    -- Lookup order: assets/royal_systems/tier1/<name>.png → tier2 → procedural
    local sprite = RoyalIconGenerator.loadSpriteOverride(systemName)
    if sprite then
        iconCache[systemName] = sprite
        return sprite
    end

    -- Clean name (remove Royal prefix and Maker/System suffix for display)
    local displayName = systemName
    displayName = displayName:gsub("^Royal", "")
    displayName = displayName:gsub("MakerSystem$", "")
    displayName = displayName:gsub("System$", "")
    displayName = displayName:gsub("Maker$", "")

    -- Detect category
    local category = RoyalIconGenerator.getCategory(displayName)
    local color = RoyalIconGenerator.getCategoryColor(category)
    local decorType = CATEGORY_DECOR[category] or "circle"

    -- Create canvas
    local canvas = love.graphics.newCanvas(ICON_SIZE, ICON_SIZE, { dpiscale = 1 })
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0, 0)

    -- 1. Background (rounded square with category color tinted dark)
    love.graphics.setColor(color[1] * 0.25, color[2] * 0.25, color[3] * 0.25, 1)
    love.graphics.rectangle("fill", 2, 2, ICON_SIZE - 4, ICON_SIZE - 4, 6, 6, 6, 6)

    -- 2. Border (category color)
    love.graphics.setColor(color[1], color[2], color[3], 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", 2, 2, ICON_SIZE - 4, ICON_SIZE - 4, 6, 6, 6, 6)
    love.graphics.setLineWidth(1)

    -- 3. Decorative element (centered)
    local cx = ICON_SIZE / 2
    local cy = ICON_SIZE / 2
    drawDecor(decorType, cx, cy, ICON_SIZE, color[1], color[2], color[3])

    -- 4. Initials (top-left corner, small)
    local initials = getInitials(displayName)
    love.graphics.setColor(1, 1, 1, 0.95)
    -- Use default font scaled to fit
    local font = love.graphics.getFont()
    local prevFont = font
    -- If we have a small font available, use it; otherwise use default
    if font then
        local scale = 0.8
        local prevScale = { love.graphics.getColor() }
        -- Position initials in top-left
        love.graphics.print(initials, 5, 4, 0, scale, scale)
    end

    -- 5. Category color dot (bottom-right)
    love.graphics.setColor(color[1], color[2], color[3], 1)
    love.graphics.circle("fill", ICON_SIZE - 8, ICON_SIZE - 8, 4)
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.circle("line", ICON_SIZE - 8, ICON_SIZE - 8, 4)

    -- Restore canvas
    love.graphics.setCanvas()

    -- Cache and return
    iconCache[systemName] = canvas
    return canvas
end

-- v3.12.154: Asset Override system
-- Sprite override folders (checked in order, first match wins)
-- Tier 1 = highest quality (artist-created), Tier 2 = mid quality (AI-generated)
local SPRITE_FOLDERS = {
    { tier = "tier1", quality = 256 },  -- 256x256 PNG, hand-crafted
    { tier = "tier2", quality = 128 },   -- 128x128 PNG, AI-generated
}

-- Cache for already-checked (and not found) system names to avoid repeated disk I/O
local spriteCheckedCache = {}  -- [systemName] = true if checked (regardless of result)
local spriteImageCache = {}    -- [systemName] = love.Image or nil if not found

-- Normalize system name to a filesystem-safe filename
-- e.g. "RoyalAbacusMakerSystem" → "Abacus"
local function normalizeToFilename(systemName)
    if not systemName then return nil end
    local name = systemName
    name = name:gsub("^Royal", "")
    name = name:gsub("MakerSystem$", "")
    name = name:gsub("System$", "")
    name = name:gsub("Maker$", "")
    return name
end

-- Try to load a PNG sprite for a system from the override folders
-- @param systemName string
-- @return love.Image or nil if not found
function RoyalIconGenerator.loadSpriteOverride(systemName)
    if not systemName then
        return nil
    end

    -- Already checked? Return cached result
    if spriteCheckedCache[systemName] then
        return spriteImageCache[systemName]
    end

    spriteCheckedCache[systemName] = true  -- mark as checked

    local baseName = normalizeToFilename(systemName)
    if not baseName or baseName == "" then
        return nil
    end

    -- Try each tier folder in order
    for _, folder in ipairs(SPRITE_FOLDERS) do
        local path = "assets/royal_systems/" .. folder.tier .. "/" .. baseName .. ".png"
        local ok, imageData = pcall(love.image.newImageData, path)
        if ok and imageData then
            local ok2, image = pcall(love.graphics.newImage, imageData)
            if ok2 and image then
                -- Set filtering to smooth for high-quality sprites
                image:setFilter("linear", "linear")
                spriteImageCache[systemName] = image
                -- Optional debug print (remove in production)
                -- print("[RoyalIcon] Loaded override: " .. path)
                return image
            end
        end
    end

    -- No override found - return nil (procedural fallback will be used)
    return nil
end

-- Check if a system has a PNG override sprite (without loading it)
-- @param systemName string
-- @return boolean true if override exists
function RoyalIconGenerator.hasOverride(systemName)
    if not systemName then return false end
    if spriteCheckedCache[systemName] then
        return spriteImageCache[systemName] ~= nil
    end
    -- Force check
    local result = RoyalIconGenerator.loadSpriteOverride(systemName)
    return result ~= nil
end

-- Get list of all systems that have PNG overrides
-- @return table array of { name, tier, path }
function RoyalIconGenerator.getOverridesList()
    local overrides = {}
    for name, image in pairs(spriteImageCache) do
        if image then
            local baseName = normalizeToFilename(name)
            table.insert(overrides, {
                name = name,
                baseName = baseName,
                path = "assets/royal_systems/<tier>/" .. baseName .. ".png",
            })
        end
    end
    return overrides
end

-- Clear sprite override cache (for hot-reload during development)
function RoyalIconGenerator.clearOverrideCache()
    for k, img in pairs(spriteImageCache) do
        if img and img.release then
            pcall(function() img:release() end)
        end
    end
    spriteImageCache = {}
    spriteCheckedCache = {}
end

-- Draw an icon at position with given size
-- @param systemName string
-- @param x, y number - top-left position
-- @param size number - draw size (default ICON_SIZE)
function RoyalIconGenerator.draw(systemName, x, y, size)
    size = size or ICON_SIZE
    local icon = RoyalIconGenerator.getIcon(systemName)
    if not icon then
        -- Fallback: draw a placeholder rectangle
        love.graphics.setColor(0.4, 0.4, 0.4, 1)
        love.graphics.rectangle("fill", x, y, size, size, 4, 4, 4, 4)
        return
    end
    -- Draw icon scaled to requested size
    local sx = size / ICON_SIZE
    local sy = size / ICON_SIZE
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(icon, x, y, 0, sx, sy)
end

-- Get cache stats (for debugging)
function RoyalIconGenerator.getCacheStats()
    local count = 0
    for _ in pairs(iconCache) do
        count = count + 1
    end
    return {
        cachedIcons = count,
        cacheMemoryApproxKB = count * (ICON_SIZE * ICON_SIZE * 4) / 1024,  -- RGBA
    }
end

-- Clear cache (for memory management)
function RoyalIconGenerator.clearCache()
    for k, canvas in pairs(iconCache) do
        if canvas.release then
            canvas:release()
        end
    end
    iconCache = {}
end

-- Pre-generate icons for a list of system names (batch warm-up)
-- @param systemNames table - array of strings
function RoyalIconGenerator.prewarm(systemNames)
    if not systemNames then
        return 0
    end
    local count = 0
    for _, name in ipairs(systemNames) do
        if name and not iconCache[name] then
            RoyalIconGenerator.getIcon(name)
            count = count + 1
        end
    end
    return count
end

return RoyalIconGenerator
