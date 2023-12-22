local indexQuads = _G.indexQuads
local tq = require("objects.object_quads")

local directionalAnimations = {
    ["body_archer_attack_1"] = { ["end"] = 16 },
    ["body_archer_attack_2"] = { ["end"] = 20 },
    ["body_archer_idle"] = { ["end"] = 24 },
    ["body_archer_idle_stand"] = { ["end"] = 16, ["start"] = 16, ["indexQuadsName"] = "body_archer_walk" },
    ["body_archer_walk"] = { ["end"] = 16 },
    ["body_archer_walk_sword"] = { ["end"] = 16 },
}
local directions = { "n", "ne", "e", "se", "s", "sw", "w", "nw" }

local function multiplyDirections(directionalAnimations, directions)
    local animations = {}
    for d_a, f in pairs(directionalAnimations) do
        local endIndex = f["end"]
        local startIndex = f["start"] or 1
        local indexQuadsKey = f["indexQuadsName"] or d_a
        for k, d in ipairs(directions) do
            -- build animations for every direction
            local animationName = indexQuadsKey .. "_" .. d
            local animationKey = d_a .. "_" .. d

            animations[animationKey] = _G.indexQuads(animationName, endIndex, startIndex)
            if startIndex == endIndex then
                -- ensures that single animation frames don't get stuck
                -- animations don't play if they exist as 1 frame. Therefore, doubling the same frame
                -- allows the single-frame animation to play
                animations[animationKey][2] = animations[animationKey][1]
            end
        end
    end
    return animations
end

local animations = multiplyDirections(directionalAnimations, directions)

-- insert additional animations
animations["body_archer_die"] = _G.indexQuads("body_archer_die", 28)
return animations
