local folder = "sounds/speech/" .. string.lower(_G.currentLang) .. "/"

function getSoundSource(fileName)
    local filePath = folder .. fileName
    if not love.filesystem.getInfo(filePath) then
        filePath = "sounds/speech/eng/" .. fileName
    end

    return love.audio.newSource(filePath, "static")
end

local speech = {
    ["Food_Warning1"] = getSoundSource("Food_Warning1.ogg"),
    ["Food_Warning2"] = getSoundSource("Food_Warning2.ogg"),
    ["Food_Warning3"] = getSoundSource("Food_Warning3.ogg"),
    ["Food_Warning4"] = getSoundSource("Food_Warning4.ogg"),
    ["Food_Warning5"] = getSoundSource("Food_Warning5.ogg"),
    ["Food_None"] = getSoundSource("Food_None.ogg"),
    ["Food_Half"] = getSoundSource("Food_Half.ogg"),
    ["Food_Normal"] = getSoundSource("Food_Normal.ogg"),
    ["Food_Extra"] = getSoundSource("Food_Extra.ogg"),
    ["Food_Double"] = getSoundSource("Food_Double.ogg"),    
    ["Pop_Emigrate"] = getSoundSource("Pop_Emigrate.ogg"),
    ["Pop_Immigrate"] = getSoundSource("Pop_Immigrate.ogg"),
    ["Resource_Need6"] = getSoundSource("Resource_Need6.ogg"),
    ["Resource_Need7"] = getSoundSource("Resource_Need7.ogg"),
    ["Resource_Need_Gold_1"] = getSoundSource("Resource_Need_Gold_1.ogg"),
    ["Resource_Need_Gold_2"] = getSoundSource("Resource_Need_Gold_2.ogg"),
    ["Resource_Need_Gold_3"] = getSoundSource("Resource_Need_Gold_3.ogg"),
    ["Resource_Need_Gold_4"] = getSoundSource("Resource_Need_Gold_4.ogg"),
    ["Resource_Need_Gold_5"] = getSoundSource("Resource_Need_Gold_5.ogg"),
    ["Resource_Need_Iron_1"] = getSoundSource("Resource_Need_Iron_1.ogg"),
    ["Resource_Need_Iron_2"] = getSoundSource("Resource_Need_Iron_2.ogg"),
    ["Resource_Need_Iron_3"] = getSoundSource("Resource_Need_Iron_3.ogg"),
    ["Resource_Need_Iron_4"] = getSoundSource("Resource_Need_Iron_4.ogg"),
    ["Resource_Need_Iron_5"] = getSoundSource("Resource_Need_Iron_5.ogg"),
    ["Resource_Need_Pitch_1"] = getSoundSource("Resource_Need_Pitch_1.ogg"),
    ["Resource_Need_Pitch_2"] = getSoundSource("Resource_Need_Pitch_2.ogg"),
    ["Resource_Need_Pitch_3"] = getSoundSource("Resource_Need_Pitch_3.ogg"),
    ["Resource_Need_Pitch_4"] = getSoundSource("Resource_Need_Pitch_4.ogg"),
    ["Resource_Need_Pitch_5"] = getSoundSource("Resource_Need_Pitch_5.ogg"),
    ["Resource_Need_Stone_1"] = getSoundSource("Resource_Need_Stone_1.ogg"),
    ["Resource_Need_Stone_2"] = getSoundSource("Resource_Need_Stone_2.ogg"),
    ["Resource_Need_Stone_3"] = getSoundSource("Resource_Need_Stone_3.ogg"),
    ["Resource_Need_Stone_4"] = getSoundSource("Resource_Need_Stone_4.ogg"),
    ["Resource_Need_Stone_5"] = getSoundSource("Resource_Need_Stone_5.ogg"),
    ["Resource_Need_Wood_1"] = getSoundSource("Resource_Need_Wood_1.ogg"),
    ["Resource_Need_Wood_2"] = getSoundSource("Resource_Need_Wood_2.ogg"),
    ["Resource_Need_Wood_3"] = getSoundSource("Resource_Need_Wood_3.ogg"),
    ["Resource_Need_Wood_4"] = getSoundSource("Resource_Need_Wood_4.ogg"),
    ["Resource_Need_Wood_5"] = getSoundSource("Resource_Need_Wood_5.ogg"),
    ["Resource_Need_Wood_And_Stone"] = getSoundSource("Resource_Need_Wood_And_Stone.ogg"),
    ["Taxes_Rate1"] = getSoundSource("Taxes_Rate1.ogg"),
    ["Taxes_Rate2"] = getSoundSource("Taxes_Rate2.ogg"),
    ["Taxes_Rate3"] = getSoundSource("Taxes_Rate3.ogg"),
    ["Taxes_Rate4"] = getSoundSource("Taxes_Rate4.ogg"),
    ["Taxes_Rate5"] = getSoundSource("Taxes_Rate5.ogg"),
    ["Taxes_Rate6"] = getSoundSource("Taxes_Rate6.ogg"),
    ["Taxes_Rate7"] = getSoundSource("Taxes_Rate7.ogg"),
    ["Taxes_Rate8"] = getSoundSource("Taxes_Rate8.ogg"),
    ["adjacent_armory"] = getSoundSource("adjacent_armory.ogg"),
    ["adjacent_barracks"] = getSoundSource("adjacent_barracks.ogg"),
    ["adjacent_granary"] = getSoundSource("adjacent_granary.ogg"),
    ["adjacent_stockpile"] = getSoundSource("adjacent_stockpile.ogg"),
    ["adjacent_to_stone_wall"] = getSoundSource("adjacent_to_stone_wall.ogg"),
    ["adjacent_to_wooden_wall"] = getSoundSource("adjacent_to_wooden_wall.ogg"),
    ["apple_farms_need_valley_floor"] = getSoundSource("apple_farms_need_valley_floor.ogg"),
    ["armory_full"] = getSoundSource("armory_full.ogg"),
    ["cannot_place_1"] = getSoundSource("cannot_place_1.ogg"),
    ["cannot_place_2"] = getSoundSource("cannot_place_2.ogg"),
    ["cattle_farms_cannot_be_placed_on_mountain"] = getSoundSource("cattle_farms_cannot_be_placed_on_mountain.ogg"),
    ["farms_valley_floor"] = getSoundSource("farms_valley_floor.ogg"),
    ["granary_full"] = getSoundSource("granary_full.ogg"),
    ["hop_farms_need_valley_floor"] = getSoundSource("hop_farms_need_valley_floor.ogg"),
    ["iron_mine_needs_iron_ore"] = getSoundSource("iron_mine_needs_iron_ore.ogg"),
    ["not_enough_workers"] = getSoundSource("not_enough_workers.ogg"),
    ["not_enough_goods"] = getSoundSource("not_enough_goods.ogg"),
    ["weapons_needed"] = getSoundSource("weapons_needed.ogg"),
    ["recruits_needed"] = getSoundSource("recruits_needed.ogg"),
    ["pitch_needs_oil"] = getSoundSource("pitch_needs_oil.ogg"),
    ["place_a_keep"] = getSoundSource("place_a_keep.ogg"),
    ["place_granary"] = getSoundSource("place_granary.ogg"),
    ["stockpile_full"] = getSoundSource("stockpile_full.ogg"),
    ["too_close_to_enemy"] = getSoundSource("too_close_to_enemy.ogg"),
    ["too_close_to_enemy_repair"] = getSoundSource("too_close_to_enemy_repair.ogg"),
    ["wheat_farms_valley_floor"] = getSoundSource("wheat_farms_valley_floor.ogg"),
    ["General_Saving"] = getSoundSource("General_Saving.ogg"),
    ["General_Startgame"] = getSoundSource("General_Startgame.ogg"),
    ["General_Loading"] = getSoundSource("General_Loading.ogg"),
    ["Archer_Ready"] = getSoundSource("Archer_Selected_2.ogg"),
    ["Spearman_Ready"] = getSoundSource("Spearman_Selected_1.ogg"),
    ["Maceman_Ready"] = getSoundSource("Maceman_Selected_2.ogg"),
    ["Crossbowman_Ready"] = getSoundSource("Crossbowman_Selected_1.ogg"),
    ["Pikeman_Ready"] = getSoundSource("Pikeman_Selected_1.ogg"),
    ["Swordsman_Ready"] = getSoundSource("Swordsman_Selected_2.ogg")
}
speech["General_Saving"]:setVolumeLimits(0, 0.8)
speech["General_Startgame"]:setVolumeLimits(0, 0.8)
speech["General_Loading"]:setVolumeLimits(0, 0.8)

for _, sf in pairs(speech) do
    sf:setRelative(true)
end

return speech
