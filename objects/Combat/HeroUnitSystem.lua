-- objects/Combat/HeroUnitSystem.lua
-- Castle Kingdoms 2027 v2.8.7 - Hero Unit System
--
-- Special hero units with unique abilities, leveling, and persistent progression.
-- Heroes are more powerful than regular units and can turn the tide of battle.
--
-- Hero features:
-- - 6 hero types with unique abilities
-- - Hero leveling (1-10) with stat increases
-- - Active abilities with cooldowns
-- - Passive bonuses to nearby units
-- - Persistent progression across missions
-- - Hero death penalty (respawn timer)

local HeroSystem = {}

-- Hero definitions
local HERO_TYPES = {
    knight_commander = {
        name = "Viteški poveljnik",
        nameEn = "Knight Commander",
        baseHealth = 300,
        baseDamage = 40,
        baseSpeed = 1.2,
        baseArmor = 0.50,
        ability = {
            name = "Bojni poklič",
            nameEn = "Battle Cry",
            cooldown = 60,
            duration = 15,
            radius = 10,
            effect = { damageBonus = 1.5, speedBonus = 1.3 },
            description = "+50% damage in +30% speed vsem enotam v radiju 10",
        },
        passive = { name = "Vodstvo", desc = "+10% damage vsem zaveznikom v radiju 5" },
        auraRadius = 5,
        auraBonus = { damage = 1.10 },
        cost = { gold = 1000, iron = 50 },
        recruitTime = 120,
    },
    master_archer = {
        name = "Mojster lokostrelec",
        nameEn = "Master Archer",
        baseHealth = 120,
        baseDamage = 35,
        baseSpeed = 1.1,
        baseArmor = 0.10,
        range = 15,
        ability = {
            name = "Strelna nevihta",
            nameEn = "Arrow Storm",
            cooldown = 45,
            duration = 5,
            radius = 8,
            effect = { arrowRain = true, damagePerSecond = 20 },
            description = "Dež puščic — 20 damage/s v radiju 8 za 5s",
        },
        passive = { name = "Ostro oko", desc = "+2 range vsem lokostrelcem v radiju 5" },
        auraRadius = 5,
        auraBonus = { range = 2 },
        cost = { gold = 800, wood = 50 },
        recruitTime = 90,
    },
    siege_engineer = {
        name = "Inženir obleganja",
        nameEn = "Siege Engineer",
        baseHealth = 200,
        baseDamage = 25,
        baseSpeed = 0.8,
        baseArmor = 0.30,
        ability = {
            name = "Hitra gradnja",
            nameEn = "Rapid Construction",
            cooldown = 90,
            duration = 0,
            radius = 0,
            effect = { instantBuild = true, buildingType = "Trebuchet" },
            description = "Takoj zgradi trebuchet na trenutni poziciji",
        },
        passive = { name = "Inženirska znanja", desc = "-30% cost oblegovalnih orožij v radiju 10" },
        auraRadius = 10,
        auraBonus = { siegeCostReduction = 0.70 },
        cost = { gold = 900, iron = 30, wood = 50 },
        recruitTime = 100,
    },
    battle_mage = {
        name = "Bojni mag",
        nameEn = "Battle Mage",
        baseHealth = 150,
        baseDamage = 45,
        baseSpeed = 1.0,
        baseArmor = 0.15,
        ability = {
            name = "Ognjena krogla",
            nameEn = "Fireball",
            cooldown = 30,
            duration = 0,
            radius = 5,
            effect = { instantDamage = 80, splashDamage = 40, splashRadius = 3 },
            description = "80 damage na cilj + 40 splash v radiju 3",
        },
        passive = { name = "Magična aura", desc = "+15% damage vsem enotam v radiju 7" },
        auraRadius = 7,
        auraBonus = { damage = 1.15 },
        cost = { gold = 1200, iron = 20 },
        recruitTime = 150,
    },
    shield_maiden = {
        name = "Ščitna devica",
        nameEn = "Shield Maiden",
        baseHealth = 250,
        baseDamage = 20,
        baseSpeed = 1.1,
        baseArmor = 0.60,
        ability = {
            name = "Neprebojni ščit",
            nameEn = "Aegis Shield",
            cooldown = 75,
            duration = 20,
            radius = 8,
            effect = { invulnerable = true, damageReduction = 0.90 },
            description = "-90% damage vsem zaveznikom v radiju 8 za 20s",
        },
        passive = { name = "Zaščitnica", desc = "+20% armor vsem zaveznikom v radiju 6" },
        auraRadius = 6,
        auraBonus = { armor = 1.20 },
        cost = { gold = 950, iron = 40 },
        recruitTime = 110,
    },
    shadow_assassin = {
        name = "Sence morilec",
        nameEn = "Shadow Assassin",
        baseHealth = 130,
        baseDamage = 55,
        baseSpeed = 1.5,
        baseArmor = 0.05,
        ability = {
            name = "Brezsenčni korak",
            nameEn = "Shadow Step",
            cooldown = 40,
            duration = 0,
            radius = 0,
            effect = { teleport = true, maxRange = 20, backstabDamage = 100 },
            description = "Teleport do 20 ploščic + 100 backstab damage",
        },
        passive = { name = "Nevidnost", desc = "-30% možnost odkritja s strani sovražnika" },
        auraRadius = 0,
        auraBonus = {},
        cost = { gold = 1100, iron = 30 },
        recruitTime = 130,
    },
}

HeroSystem.HERO_TYPES = HERO_TYPES

local initialized = false
local activeHeroes = {}  -- [heroId] = { type, level, health, abilityCooldown, ... }
local nextHeroId = 1
local deadHeroes = {}  -- [heroId] = respawnTimer
local heroProgression = {}  -- persistent across missions

function HeroSystem.init()
    if initialized then return end
    initialized = true
    HeroSystem._loadProgression()
    print("[HeroSystem] Initialized with " .. HeroSystem._getHeroTypeCount() .. " hero types")
end

function HeroSystem._getHeroTypeCount()
    local count = 0
    for _ in pairs(HERO_TYPES) do count = count + 1 end
    return count
end

-- Recruit a hero
function HeroSystem.recruit(heroType)
    local def = HERO_TYPES[heroType]
    if not def then return nil, "Unknown hero type" end

    -- Check cost
    if _G.state then
        if def.cost.gold and (_G.state.gold or 0) < def.cost.gold then
            return nil, "Not enough gold (" .. def.cost.gold .. "g)"
        end
        -- Deduct cost
        _G.state.gold = (_G.state.gold or 0) - (def.cost.gold or 0)
    end

    local heroId = nextHeroId
    nextHeroId = nextHeroId + 1

    -- Get saved level if hero type was used before
    local savedLevel = heroProgression[heroType] and heroProgression[heroType].level or 1

    local hero = {
        id = heroId,
        type = heroType,
        name = def.name,
        level = savedLevel,
        maxHealth = def.baseHealth + (savedLevel - 1) * 30,
        health = def.baseHealth + (savedLevel - 1) * 30,
        damage = def.baseDamage + (savedLevel - 1) * 5,
        speed = def.baseSpeed,
        armor = def.baseArmor,
        abilityCooldown = 0,
        abilityActive = 0,
        gx = nil,
        gy = nil,
        unit = nil,  -- reference to actual game unit
    }

    activeHeroes[heroId] = hero

    if _G.ModernUI then
        _G.ModernUI.notifySuccess("Hero rekrutiran: " .. def.name .. " (Lvl " .. hero.level .. ")")
    end
    if _G.VoiceOver then
        pcall(function() _G.VoiceOver.notify("unit_legendary", def.name) end)
    end
    if _G.GameEventBus then
        pcall(function() _G.GameEventBus.emit("hero_recruited", { heroId = heroId, type = heroType, level = hero.level }) end)
    end

    print("[HeroSystem] Recruited: " .. def.name .. " Lvl " .. hero.level)
    return heroId
end

-- Use hero ability
function HeroSystem.useAbility(heroId, targetGx, targetGy)
    local hero = activeHeroes[heroId]
    if not hero then return false, "Hero not found" end
    if hero.abilityCooldown > 0 then
        return false, "Cooldown: " .. math.ceil(hero.abilityCooldown) .. "s"
    end

    local def = HERO_TYPES[hero.type]
    local ability = def.ability
    hero.abilityCooldown = ability.cooldown

    -- Handle different ability types
    if hero.type == "battle_mage" then
        -- Fireball: instant damage + splash
        HeroSystem._fireball(targetGx, targetGy, ability.effect)
    elseif hero.type == "shadow_assassin" then
        -- Shadow Step: teleport + backstab
        HeroSystem._shadowStep(hero, targetGx, targetGy, ability.effect)
    elseif hero.type == "siege_engineer" then
        -- Instant build trebuchet
        HeroSystem._instantBuild(hero, ability.effect)
    elseif hero.type == "master_archer" then
        -- Arrow storm: AoE damage over time
        hero.abilityActive = ability.duration
        hero.abilityTarget = { gx = targetGx, gy = targetGy }
    else
        -- Buff abilities (Knight Commander, Shield Maiden)
        hero.abilityActive = ability.duration
    end

    if _G.ModernUI then
        _G.ModernUI.notifySuccess(def.name .. ": " .. ability.name .. "!")
    end
    if _G.GameEventBus then
        pcall(function() _G.GameEventBus.emit("hero_ability_used", { heroId = heroId, ability = ability.name }) end)
    end

    print("[HeroSystem] " .. def.name .. " used: " .. ability.name)
    return true
end

-- Fireball effect
function HeroSystem._fireball(gx, gy, effect)
    if not _G.state or not _G.state.gameObjectList then return end
    local radius = 3
    for _, unit in ipairs(_G.state.gameObjectList) do
        if unit.faction and unit.faction ~= 1 and unit.faction ~= 5
            and unit.health and unit.health > 0 and unit.gx and unit.gy then
            local dx = unit.gx - (gx or 0)
            local dy = unit.gy - (gy or 0)
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist <= radius then
                unit.health = unit.health - (effect.splashDamage or 40)
            end
        end
    end
    -- Visual effect
    if _G.VisualPolish and _G.state and gx and gy then
        local sx = _G.IsoToScreenX(gx, gy) - (_G.state.viewXview or 0)
        local sy = _G.IsoToScreenY(gx, gy) - (_G.state.viewYview or 0)
        pcall(function() _G.VisualPolish.spawnEffect(sx, sy, "fire", 30) end)
    end
    if _G.GameFeel then
        pcall(function() _G.GameFeel.shake(10, 0.4) end)
    end
end

-- Shadow step effect
function HeroSystem._shadowStep(hero, targetGx, targetGy, effect)
    if not hero.unit then return end
    -- Teleport unit
    if hero.unit.gx and hero.unit.gy then
        hero.unit.gx = targetGx or hero.unit.gx
        hero.unit.gy = targetGy or hero.unit.gy
    end
    -- Backstab: find enemy at target and deal damage
    if _G.state and _G.state.gameObjectList then
        for _, enemy in ipairs(_G.state.gameObjectList) do
            if enemy.faction and enemy.faction ~= 1 and enemy.faction ~= 5
                and enemy.health and enemy.health > 0 and enemy.gx and enemy.gy then
                local dx = enemy.gx - (targetGx or 0)
                local dy = enemy.gy - (targetGy or 0)
                if dx * dx + dy * dy <= 4 then
                    enemy.health = enemy.health - (effect.backstabDamage or 100)
                    break
                end
            end
        end
    end
end

-- Instant build
function HeroSystem._instantBuild(hero, effect)
    if not _G.state or not _G.state.keepX then return end
    local SiegeWeapons = _G.SiegeWeapons
    if SiegeWeapons and SiegeWeapons.create then
        local gx = hero.gx or _G.state.keepX + 5
        local gy = hero.gy or _G.state.keepY + 5
        pcall(function() SiegeWeapons.create(effect.buildingType or "catapult", gx, gy, 1) end)
    end
end

-- Level up a hero
function HeroSystem.levelUp(heroId)
    local hero = activeHeroes[heroId]
    if not hero then return false end
    if hero.level >= 10 then return false, "Max level reached" end

    hero.level = hero.level + 1
    local def = HERO_TYPES[hero.type]
    hero.maxHealth = def.baseHealth + (hero.level - 1) * 30
    hero.health = hero.maxHealth  -- full heal on level up
    hero.damage = def.baseDamage + (hero.level - 1) * 5

    -- Save progression
    if not heroProgression[hero.type] then
        heroProgression[hero.type] = { level = 1, totalXp = 0 }
    end
    heroProgression[hero.type].level = hero.level
    HeroSystem._saveProgression()

    if _G.ModernUI then
        _G.ModernUI.notifySuccess(hero.name .. " napredoval na nivo " .. hero.level .. "!")
    end
    if _G.Prestige then
        pcall(function() _G.Prestige.award("achievement_epic") end)
    end
    if _G.GameEventBus then
        pcall(function() _G.GameEventBus.emit("hero_levelup", { heroId = heroId, newLevel = hero.level }) end)
    end

    print("[HeroSystem] " .. hero.name .. " leveled up to " .. hero.level)
    return true
end

-- Update heroes
function HeroSystem.update(dt)
    if not initialized then return end

    -- Update active heroes
    for heroId, hero in pairs(activeHeroes) do
        -- Update ability cooldown
        if hero.abilityCooldown > 0 then
            hero.abilityCooldown = hero.abilityCooldown - dt
            if hero.abilityCooldown < 0 then hero.abilityCooldown = 0 end
        end
        -- Update active ability duration
        if hero.abilityActive > 0 then
            hero.abilityActive = hero.abilityActive - dt
            if hero.abilityActive < 0 then hero.abilityActive = 0 end
        end
        -- Track position from unit
        if hero.unit and hero.unit.gx then
            hero.gx = hero.unit.gx
            hero.gy = hero.unit.gy
        end
        -- Check if hero died
        if hero.unit and hero.unit.health and hero.unit.health <= 0 then
            HeroSystem._heroDied(heroId)
        end
    end

    -- Update dead hero respawn timers
    for heroId, timer in pairs(deadHeroes) do
        deadHeroes[heroId] = timer - dt
        if deadHeroes[heroId] <= 0 then
            deadHeroes[heroId] = nil
            -- Respawn hero
            if activeHeroes[heroId] then
                local def = HERO_TYPES[activeHeroes[heroId].type]
                activeHeroes[heroId].health = activeHeroes[heroId].maxHealth
                if _G.ModernUI then
                    _G.ModernUI.notifySuccess(activeHeroes[heroId].name .. " oživljen!")
                end
            end
        end
    end
end

-- Hero died
function HeroSystem._heroDied(heroId)
    local hero = activeHeroes[heroId]
    if not hero then return end
    deadHeroes[heroId] = 120  -- 2 minute respawn
    if _G.ModernUI then
        _G.ModernUI.notifyError(hero.name .. " je padel! Oživitev čez 120s")
    end
    if _G.GameEventBus then
        pcall(function() _G.GameEventBus.emit("hero_died", { heroId = heroId, name = hero.name }) end)
    end
    print("[HeroSystem] " .. hero.name .. " died — respawn in 120s")
end

-- Get hero info
function HeroSystem.getHero(heroId)
    local hero = activeHeroes[heroId]
    if not hero then return nil end
    local def = HERO_TYPES[hero.type]
    return {
        id = hero.id,
        type = hero.type,
        name = hero.name,
        level = hero.level,
        health = hero.health,
        maxHealth = hero.maxHealth,
        damage = hero.damage,
        armor = hero.armor,
        abilityCooldown = math.ceil(hero.abilityCooldown),
        abilityActive = math.ceil(hero.abilityActive),
        abilityName = def.ability.name,
        abilityReady = hero.abilityCooldown <= 0,
        isDead = deadHeroes[heroId] ~= nil,
        respawnTimer = deadHeroes[heroId] and math.ceil(deadHeroes[heroId]) or 0,
        gx = hero.gx,
        gy = hero.gy,
    }
end

-- Get all heroes
function HeroSystem.getAllHeroes()
    local result = {}
    for heroId, _ in pairs(activeHeroes) do
        table.insert(result, HeroSystem.getHero(heroId))
    end
    return result
end

-- Get stats
function HeroSystem.getStats()
    local alive = 0
    local dead = 0
    local totalLevel = 0
    for heroId, hero in pairs(activeHeroes) do
        if deadHeroes[heroId] then
            dead = dead + 1
        else
            alive = alive + 1
            totalLevel = totalLevel + hero.level
        end
    end
    return {
        totalHeroes = #activeHeroes,
        aliveHeroes = alive,
        deadHeroes = dead,
        avgLevel = alive > 0 and (totalLevel / alive) or 0,
        heroTypesAvailable = HeroSystem._getHeroTypeCount(),
    }
end

-- Save progression
function HeroSystem._saveProgression()
    local file = love.filesystem.newFile("hero_progression.json")
    if file:open("w") then
        local lines = {"return {"}
        for heroType, data in pairs(heroProgression) do
            table.insert(lines, string.format("  ['%s'] = { level = %d, totalXp = %d },",
                heroType, data.level or 1, data.totalXp or 0))
        end
        table.insert(lines, "}")
        file:write(table.concat(lines, "\n"))
        file:close()
    end
end

-- Load progression
function HeroSystem._loadProgression()
    local file = love.filesystem.newFile("hero_progression.json")
    if file:open("r") then
        local content = file:read()
        file:close()
        if content then
            local ok, chunk = pcall(load, content)
            if ok and chunk then
                local dataOk, data = pcall(chunk)
                if dataOk and type(data) == "table" then
                    heroProgression = data
                end
            end
        end
    end
end

return HeroSystem
