local indexQuads = _G.indexQuads
local tq = require("objects.object_quads")

local directionalAnimations = {
    ["body_ladder_bearer_break"] = { ["end"] = 8 },
    ["body_ladder_bearer_idle_1"] = { ["end"] = 16 },
    ["body_ladder_bearer_idle_2"] = { ["end"] = 16 },
    ["body_ladder_bearer_idle_stand"] = { ["end"] = 16, ["start"] = 16, ["indexQuadsName"] = "body_ladder_bearer_walk" },
    ["body_ladder_bearer_walk"] = { ["end"] = 16 },
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
animations["body_ladder_bearer_die"] = _G.indexQuads("body_ladder_bearer_die", 24)
return animations
