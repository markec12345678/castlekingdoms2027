-- objects/Audio/ProceduralSFX.lua
-- Castle Kingdoms 2027 v3.12.163 - Procedural Sound Effect Synthesis
--
-- Generates combat sound effects procedurally using LÖVE's audio synthesis API.
-- No external audio files needed — all sounds are computed from waveforms.
--
-- Used as fallback when _G.fx doesn't have a particular sound loaded.
-- Each SFX is generated once at init and cached as love.Source.
--
-- Generated SFX:
--   sword_swing   - "whoosh" - filtered noise with fast attack/decay
--   sword_hit     - "clang" - metallic square wave with quick decay
--   shield_block  - "thud"  - low sine + noise burst
--   arrow_shoot   - "twang" - sine wave with quick pitch drop
--   arrow_hit     - "thwack"- short noise burst with envelope
--   death_male    - "groan"- low sine with vibrato
--   death_female  - "groan"- higher sine with vibrato
--   flee_scream   - "ahhh" - high sine with rising pitch
--   rally_horn    - "horn" - sine with vibrato, longer
--   morale_break  - "crack"- short noise burst
--   cavalry_hooves- "trtr"- filtered noise with rhythm
--
-- Public API:
--   ProceduralSFX.init()                - generate all sounds
--   ProceduralSFX.play(name, gx, gy)   - play by name (positional)
--   ProceduralSFX.has(name)             - check if sound exists
--   ProceduralSFX.getSound(name)        - get love.Source
--   ProceduralSFX.getStats()            - debug info

local ProceduralSFX = {}

-- Sound cache: name → love.Source
local soundCache = {}

-- Sample rate (44.1 kHz is standard)
local SAMPLE_RATE = 44100

-- ============================================================
-- Waveform helpers
-- ============================================================

-- Generate a sine wave sample at given time/frequency
local function sine(freq, t)
    return math.sin(2 * math.pi * freq * t)
end

-- Generate a square wave sample (for metallic sounds)
local function square(freq, t)
    return (sine(freq, t) >= 0) and 1 or -1
end

-- Generate a sawtooth wave sample (richer harmonics)
local function sawtooth(freq, t)
    local phase = (freq * t) % 1
    return 2 * phase - 1
end

-- Pseudo-random noise (deterministic for reproducibility)
local noiseState = 12345
local function noise()
    -- Linear congruential generator (fast, deterministic)
    noiseState = (noiseState * 1103515245 + 12345) % 2147483648
    return (noiseState / 1073741824) - 1  -- normalize to -1..1
end

-- Reset noise seed (for reproducible generation)
local function resetNoise(seed)
    noiseState = seed or 12345
end

-- Envelope: attack-decay-sustain-release (ADSR)
-- Returns amplitude 0-1 for given time t and total duration
local function adsr(t, duration, attack, decay, sustain, release)
    attack = attack or 0.01   -- 10ms attack
    decay = decay or 0.05     -- 50ms decay
    sustain = sustain or 0.5  -- sustain level
    release = release or 0.1  -- 100ms release

    if t < attack then
        return t / attack  -- attack phase
    elseif t < attack + decay then
        -- decay phase (attack level → sustain level)
        local dt = (t - attack) / decay
        return 1 - (1 - sustain) * dt
    elseif t < duration - release then
        return sustain  -- sustain phase
    elseif t < duration then
        -- release phase (sustain → 0)
        local dt = (t - (duration - release)) / release
        return sustain * (1 - dt)
    else
        return 0
    end
end

-- Simple exponential decay envelope (good for percussive sounds)
local function expDecay(t, duration, decayRate)
    decayRate = decayRate or 5  -- higher = faster decay
    if t > duration then return 0 end
    return math.exp(-decayRate * t / duration)
end

-- Apply low-pass filter (simple one-pole)
local function lowpass(prev, current, cutoff)
    -- cutoff: 0-1, higher = less filtering
    return prev + cutoff * (current - prev)
end

-- ============================================================
-- Sound generators (each returns SoundData)
-- ============================================================

-- "Whoosh" — sword swing (filtered noise, fast decay)
local function genSwordSwing()
    local duration = 0.25  -- 250ms
    local samples = math.floor(SAMPLE_RATE * duration)
    local data = love.sound.newSoundData(samples, SAMPLE_RATE, 16, 1)
    resetNoise(42)

    local prevSample = 0
    for i = 0, samples - 1 do
        local t = i / SAMPLE_RATE
        -- Noise with low-pass filter (creates whoosh effect)
        local rawNoise = noise()
        local filtered = lowpass(prevSample, rawNoise, 0.3)
        prevSample = filtered
        -- Apply envelope: build up then quick decay
        local env
        if t < 0.05 then
            env = t / 0.05  -- attack
        else
            env = math.exp(-8 * (t - 0.05))  -- quick decay
        end
        -- Slight pitch sweep (whoosh character)
        local sweep = 1 - t / duration * 0.3
        data:setSample(i, filtered * env * 0.5 * sweep)
    end
    return data
end

-- "Clang" — sword hit (metallic, square wave with quick decay)
local function genSwordHit()
    local duration = 0.3
    local samples = math.floor(SAMPLE_RATE * duration)
    local data = love.sound.newSoundData(samples, SAMPLE_RATE, 16, 1)

    -- Multiple frequencies for metallic character (inharmonic partials)
    local freqs = { 800, 1245, 1893, 2547 }  -- inharmonic set
    local amps = { 0.4, 0.3, 0.2, 0.15 }

    for i = 0, samples - 1 do
        local t = i / SAMPLE_RATE
        local sample = 0
        for j, freq in ipairs(freqs) do
            -- Square wave gives metallic character
            sample = sample + square(freq, t) * amps[j]
        end
        sample = sample / #freqs  -- normalize
        -- Apply decay envelope (metallic ring)
        local env = expDecay(t, duration, 6)
        data:setSample(i, sample * env * 0.7)
    end
    return data
end

-- "Thud" — shield block (low sine + noise burst)
local function genShieldBlock()
    local duration = 0.2
    local samples = math.floor(SAMPLE_RATE * duration)
    local data = love.sound.newSoundData(samples, SAMPLE_RATE, 16, 1)
    resetNoise(7)

    for i = 0, samples - 1 do
        local t = i / SAMPLE_RATE
        -- Low sine wave (impact thud)
        local sinePart = sine(80, t) * 0.6
        -- Noise burst (initial impact)
        local noisePart = noise() * 0.3
        -- Combine
        local sample = sinePart + noisePart
        -- Apply envelope
        local env = expDecay(t, duration, 8)
        data:setSample(i, sample * env * 0.6)
    end
    return data
end

-- "Twang" — arrow shoot (sine wave with pitch drop)
local function genArrowShoot()
    local duration = 0.15
    local samples = math.floor(SAMPLE_RATE * duration)
    local data = love.sound.newSoundData(samples, SAMPLE_RATE, 16, 1)

    for i = 0, samples - 1 do
        local t = i / SAMPLE_RATE
        -- Frequency drops from 600Hz to 200Hz (twang character)
        local freq = 600 - (t / duration) * 400
        local sample = sine(freq, t) * 0.7
        -- Quick decay
        local env = expDecay(t, duration, 10)
        data:setSample(i, sample * env * 0.5)
    end
    return data
end

-- "Thwack" — arrow hit (short noise burst)
local function genArrowHit()
    local duration = 0.1
    local samples = math.floor(SAMPLE_RATE * duration)
    local data = love.sound.newSoundData(samples, SAMPLE_RATE, 16, 1)
    resetNoise(99)

    local prevSample = 0
    for i = 0, samples - 1 do
        local t = i / SAMPLE_RATE
        -- Filtered noise (mid-freq thwack)
        local rawNoise = noise()
        local filtered = lowpass(prevSample, rawNoise, 0.5)
        prevSample = filtered
        -- Very quick decay (impact sound)
        local env = expDecay(t, duration, 15)
        data:setSample(i, filtered * env * 0.7)
    end
    return data
end

-- "Groan" — death sound (low sine with vibrato)
local function genDeathMale()
    local duration = 0.6
    local samples = math.floor(SAMPLE_RATE * duration)
    local data = love.sound.newSoundData(samples, SAMPLE_RATE, 16, 1)

    for i = 0, samples - 1 do
        local t = i / SAMPLE_RATE
        -- Low frequency with vibrato (5Hz modulation)
        local vibrato = sine(5, t) * 10
        local freq = 130 + vibrato  -- C3 with vibrato
        -- Add slight pitch drop (dying)
        freq = freq - (t / duration) * 30
        local sample = sine(freq, t) * 0.6
        -- Sawtooth for richer harmonics (grittier)
        sample = sample + sawtooth(freq * 2, t) * 0.15
        -- Envelope: attack, sustain, decay
        local env = adsr(t, duration, 0.05, 0.1, 0.6, 0.4)
        data:setSample(i, sample * env * 0.7)
    end
    return data
end

-- "Groan" — death sound (higher pitched)
local function genDeathFemale()
    local duration = 0.5
    local samples = math.floor(SAMPLE_RATE * duration)
    local data = love.sound.newSoundData(samples, SAMPLE_RATE, 16, 1)

    for i = 0, samples - 1 do
        local t = i / SAMPLE_RATE
        local vibrato = sine(6, t) * 12
        local freq = 220 + vibrato  -- A3 with vibrato
        freq = freq - (t / duration) * 40
        local sample = sine(freq, t) * 0.5
        sample = sample + sawtooth(freq * 2, t) * 0.1
        local env = adsr(t, duration, 0.05, 0.1, 0.5, 0.35)
        data:setSample(i, sample * env * 0.6)
    end
    return data
end

-- "Ahhh!" — flee scream (high sine with rising pitch)
local function genFleeScream()
    local duration = 0.4
    local samples = math.floor(SAMPLE_RATE * duration)
    local data = love.sound.newSoundData(samples, SAMPLE_RATE, 16, 1)

    for i = 0, samples - 1 do
        local t = i / SAMPLE_RATE
        -- Rising pitch (panic)
        local freq = 400 + (t / duration) * 300
        -- Strong vibrato (fear)
        local vibrato = sine(8, t) * 25
        local sample = sine(freq + vibrato, t) * 0.5
        -- Add some noise (distress)
        resetNoise(i + 1)
        sample = sample + noise() * 0.1
        -- Envelope
        local env = adsr(t, duration, 0.03, 0.05, 0.7, 0.3)
        data:setSample(i, sample * env * 0.5)
    end
    return data
end

-- "Horn" — rally horn (sine with vibrato, longer duration)
local function genRallyHorn()
    local duration = 0.8
    local samples = math.floor(SAMPLE_RATE * duration)
    local data = love.sound.newSoundData(samples, SAMPLE_RATE, 16, 1)

    for i = 0, samples - 1 do
        local t = i / SAMPLE_RATE
        -- Base frequency (horn-like, around 200Hz)
        local vibrato = sine(5, t) * 4
        local freq = 200 + vibrato
        -- Multiple harmonics for richer horn sound
        local sample = sine(freq, t) * 0.5
        sample = sample + sine(freq * 1.5, t) * 0.25
        sample = sample + sine(freq * 2, t) * 0.15
        -- Envelope: slow attack, long sustain, slow release
        local env = adsr(t, duration, 0.1, 0.1, 0.8, 0.3)
        data:setSample(i, sample * env * 0.7)
    end
    return data
end

-- "Crack" — morale break (short noise burst)
local function genMoraleBreak()
    local duration = 0.08
    local samples = math.floor(SAMPLE_RATE * duration)
    local data = love.sound.newSoundData(samples, SAMPLE_RATE, 16, 1)
    resetNoise(2023)

    local prevSample = 0
    for i = 0, samples - 1 do
        local t = i / SAMPLE_RATE
        -- High-frequency noise burst
        local rawNoise = noise()
        local filtered = lowpass(prevSample, rawNoise, 0.7)
        prevSample = filtered
        -- Very fast decay (sharp crack)
        local env = expDecay(t, duration, 20)
        data:setSample(i, filtered * env * 0.6)
    end
    return data
end

-- "Trtr" — cavalry hooves (filtered noise with rhythm)
local function genCavalryHooves()
    local duration = 0.5
    local samples = math.floor(SAMPLE_RATE * duration)
    local data = love.sound.newSoundData(samples, SAMPLE_RATE, 16, 1)
    resetNoise(77)

    local prevSample = 0
    -- Galloping rhythm: ~8 Hz (4 hooves × 2 beats per second)
    local gallopFreq = 8
    for i = 0, samples - 1 do
        local t = i / SAMPLE_RATE
        -- Filtered noise (low-freq thumps)
        local rawNoise = noise()
        local filtered = lowpass(prevSample, rawNoise, 0.2)
        prevSample = filtered
        -- Rhythmic envelope (galloping pattern)
        local beatPhase = (t * gallopFreq) % 1
        -- Two close beats then gap (gallop pattern: .. .. .. ..)
        local beatEnv
        if beatPhase < 0.2 then
            beatEnv = math.sin(beatPhase / 0.2 * math.pi)
        elseif beatPhase < 0.4 then
            beatEnv = math.sin((beatPhase - 0.2) / 0.2 * math.pi) * 0.7
        else
            beatEnv = 0
        end
        data:setSample(i, filtered * beatEnv * 0.6)
    end
    return data
end

-- "Bell" — retreat bell (sine with long decay)
local function genRetreatBell()
    local duration = 1.2
    local samples = math.floor(SAMPLE_RATE * duration)
    local data = love.sound.newSoundData(samples, SAMPLE_RATE, 16, 1)

    for i = 0, samples - 1 do
        local t = i / SAMPLE_RATE
        -- Bell-like: fundamental + inharmonic partials
        local sample = sine(440, t) * 0.4
        sample = sample + sine(660, t) * 0.2
        sample = sample + sine(880, t) * 0.15
        sample = sample + sine(1320, t) * 0.1
        -- Long decay (bell rings)
        local env = expDecay(t, duration, 3)
        data:setSample(i, sample * env * 0.5)
    end
    return data
end

-- ============================================================
-- Sound registry (logical name → generator function)
-- ============================================================

local SOUND_GENERATORS = {
    sword_swing    = genSwordSwing,
    sword_hit      = genSwordHit,
    shield_block   = genShieldBlock,
    arrow_shoot    = genArrowShoot,
    arrow_hit      = genArrowHit,
    death_male     = genDeathMale,
    death_female   = genDeathFemale,
    flee_scream    = genFleeScream,
    rally_horn     = genRallyHorn,
    morale_break   = genMoraleBreak,
    cavalry_hooves = genCavalryHooves,
    retreat_bell   = genRetreatBell,
}

-- ============================================================
-- Public API
-- ============================================================

local initialized = false

function ProceduralSFX.init()
    if initialized then return end
    if not love.sound or not love.audio then
        print("[ProceduralSFX] LÖVE audio not available")
        return
    end

    local count = 0
    for name, generator in pairs(SOUND_GENERATORS) do
        local ok, soundData = pcall(generator)
        if ok and soundData then
            local ok2, source = pcall(love.audio.newSource, soundData, "static")
            if ok2 and source then
                soundCache[name] = source
                count = count + 1
            else
                print("[ProceduralSFX] Failed to create source for: " .. name)
            end
        else
            print("[ProceduralSFX] Failed to generate: " .. name .. " - " .. tostring(soundData))
        end
    end

    initialized = true
    print(string.format("[ProceduralSFX] Initialized (%d procedural sounds)", count))
end

-- Get a sound source by name
-- @return love.Source or nil
function ProceduralSFX.getSound(name)
    if not initialized then ProceduralSFX.init() end
    return soundCache[name]
end

-- Check if a sound exists
function ProceduralSFX.has(name)
    return soundCache[name] ~= nil
end

-- Play a sound effect by name
-- @param name string Logical sound name
-- @param gx number World X position (optional, for 3D audio)
-- @param gy number World Y position (optional)
-- @param volume number Volume override (0-1, optional)
function ProceduralSFX.play(name, gx, gy, volume)
    if not initialized then ProceduralSFX.init() end
    if not initialized then return end  -- init failed

    local source = soundCache[name]
    if not source then return end

    -- Calculate volume
    local finalVolume = volume or 1.0

    -- 3D positional audio (distance-based)
    if gx and gy and _G.state and _G.state.viewXview and _G.IsoToScreenX then
        local screenX = _G.IsoToScreenX(gx, gy) - _G.state.viewXview
        local screenY = _G.IsoToScreenY(gx, gy) - _G.state.viewYview
        local centerX = love.graphics.getWidth() / 2
        local centerY = love.graphics.getHeight() / 2
        local dist = math.sqrt((screenX - centerX)^2 + (screenY - centerY)^2)
        local maxDist = 2000
        if dist > maxDist then return end  -- Too far
        finalVolume = finalVolume * (1 - (dist / maxDist) * 0.7)
    end

    -- Apply volume settings
    if _G.OPTIONS then
        finalVolume = finalVolume * (_G.OPTIONS.EFFECTS_VOLUME or 1) * (_G.OPTIONS.MASTER_VOLUME or 1)
    end

    -- Clone source for overlapping playback (otherwise restart)
    -- For perf: use :stop() + :play() if source is shared (no overlap)
    -- But cloning is better for rapid sounds; we use shared for now
    source:setVolume(math.max(0, math.min(1, finalVolume)))
    source:stop()
    source:play()
end

-- Get all sound names
function ProceduralSFX.getSoundNames()
    local names = {}
    for name, _ in pairs(soundCache) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

-- Get stats
function ProceduralSFX.getStats()
    local count = 0
    local totalBytes = 0
    for name, source in pairs(soundCache) do
        count = count + 1
        -- Each sample is 2 bytes (16-bit), mono
        -- Estimate: duration * SAMPLE_RATE * 2 bytes
    end
    -- Approximate memory: 12 sounds × ~0.4s avg × 44100 × 2 bytes = ~440KB
    return {
        soundCount = count,
        initialized = initialized,
        sampleRate = SAMPLE_RATE,
        estimatedMemoryKB = count * 200,  -- rough estimate per sound
    }
end

-- Reset (clear cache, will regenerate on next play)
function ProceduralSFX.reset()
    for name, source in pairs(soundCache) do
        if source.release then
            pcall(function() source:release() end)
        end
    end
    soundCache = {}
    initialized = false
end

return ProceduralSFX
