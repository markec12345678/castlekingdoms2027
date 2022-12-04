local speech = {
    ["Food_Warning1"] = love.audio.newSource("sounds/speech/Food_Warning1.ogg", "static"),
    ["Food_Warning2"] = love.audio.newSource("sounds/speech/Food_Warning2.ogg", "static"),
    ["Food_Warning3"] = love.audio.newSource("sounds/speech/Food_Warning3.ogg", "static"),
    ["Food_Warning4"] = love.audio.newSource("sounds/speech/Food_Warning4.ogg", "static"),
    ["Food_Warning5"] = love.audio.newSource("sounds/speech/Food_Warning5.ogg", "static"),
    ["Pop_Emigrate"] = love.audio.newSource("sounds/speech/Pop_Emigrate.ogg", "static"),
    ["Pop_Immigrate"] = love.audio.newSource("sounds/speech/Pop_Immigrate.ogg", "static"),
    ["Resource_Need6"] = love.audio.newSource("sounds/speech/Resource_Need6.ogg", "static"),
    ["Resource_Need7"] = love.audio.newSource("sounds/speech/Resource_Need7.ogg", "static"),
    ["Resource_Need_Gold_1"] = love.audio.newSource("sounds/speech/Resource_Need_Gold_1.ogg", "static"),
    ["Resource_Need_Gold_2"] = love.audio.newSource("sounds/speech/Resource_Need_Gold_2.ogg", "static"),
    ["Resource_Need_Gold_3"] = love.audio.newSource("sounds/speech/Resource_Need_Gold_3.ogg", "static"),
    ["Resource_Need_Gold_4"] = love.audio.newSource("sounds/speech/Resource_Need_Gold_4.ogg", "static"),
    ["Resource_Need_Gold_5"] = love.audio.newSource("sounds/speech/Resource_Need_Gold_5.ogg", "static"),
    ["Resource_Need_Iron_1"] = love.audio.newSource("sounds/speech/Resource_Need_Iron_1.ogg", "static"),
    ["Resource_Need_Iron_2"] = love.audio.newSource("sounds/speech/Resource_Need_Iron_2.ogg", "static"),
    ["Resource_Need_Iron_3"] = love.audio.newSource("sounds/speech/Resource_Need_Iron_3.ogg", "static"),
    ["Resource_Need_Iron_4"] = love.audio.newSource("sounds/speech/Resource_Need_Iron_4.ogg", "static"),
    ["Resource_Need_Iron_5"] = love.audio.newSource("sounds/speech/Resource_Need_Iron_5.ogg", "static"),
    ["Resource_Need_Pitch_1"] = love.audio.newSource("sounds/speech/Resource_Need_Pitch_1.ogg", "static"),
    ["Resource_Need_Pitch_2"] = love.audio.newSource("sounds/speech/Resource_Need_Pitch_2.ogg", "static"),
    ["Resource_Need_Pitch_3"] = love.audio.newSource("sounds/speech/Resource_Need_Pitch_3.ogg", "static"),
    ["Resource_Need_Pitch_4"] = love.audio.newSource("sounds/speech/Resource_Need_Pitch_4.ogg", "static"),
    ["Resource_Need_Pitch_5"] = love.audio.newSource("sounds/speech/Resource_Need_Pitch_5.ogg", "static"),
    ["Resource_Need_Stone_1"] = love.audio.newSource("sounds/speech/Resource_Need_Stone_1.ogg", "static"),
    ["Resource_Need_Stone_2"] = love.audio.newSource("sounds/speech/Resource_Need_Stone_2.ogg", "static"),
    ["Resource_Need_Stone_3"] = love.audio.newSource("sounds/speech/Resource_Need_Stone_3.ogg", "static"),
    ["Resource_Need_Stone_4"] = love.audio.newSource("sounds/speech/Resource_Need_Stone_4.ogg", "static"),
    ["Resource_Need_Stone_5"] = love.audio.newSource("sounds/speech/Resource_Need_Stone_5.ogg", "static"),
    ["Resource_Need_Wood_1"] = love.audio.newSource("sounds/speech/Resource_Need_Wood_1.ogg", "static"),
    ["Resource_Need_Wood_2"] = love.audio.newSource("sounds/speech/Resource_Need_Wood_2.ogg", "static"),
    ["Resource_Need_Wood_3"] = love.audio.newSource("sounds/speech/Resource_Need_Wood_3.ogg", "static"),
    ["Resource_Need_Wood_4"] = love.audio.newSource("sounds/speech/Resource_Need_Wood_4.ogg", "static"),
    ["Resource_Need_Wood_5"] = love.audio.newSource("sounds/speech/Resource_Need_Wood_5.ogg", "static"),
    ["Resource_Need_Wood_And_Stone"] = love.audio.newSource("sounds/speech/Resource_Need_Wood_And_Stone.ogg", "static"),
    ["adjacent_armory"] = love.audio.newSource("sounds/speech/adjacent_armory.ogg", "static"),
    ["adjacent_barracks"] = love.audio.newSource("sounds/speech/adjacent_barracks.ogg", "static"),
    ["adjacent_granary"] = love.audio.newSource("sounds/speech/adjacent_granary.ogg", "static"),
    ["adjacent_stockpile"] = love.audio.newSource("sounds/speech/adjacent_stockpile.ogg", "static"),
    ["adjacent_to_stone_wall"] = love.audio.newSource("sounds/speech/adjacent_to_stone_wall.ogg", "static"),
    ["adjacent_to_wooden_wall"] = love.audio.newSource("sounds/speech/adjacent_to_wooden_wall.ogg", "static"),
    ["apple_farms_need_valley_floor"] = love.audio
        .newSource("sounds/speech/apple_farms_need_valley_floor.ogg", "static"),
    ["armory_full"] = love.audio.newSource("sounds/speech/armory_full.ogg", "static"),
    ["cannot_place_1"] = love.audio.newSource("sounds/speech/cannot_place_1.ogg", "static"),
    ["cannot_place_2"] = love.audio.newSource("sounds/speech/cannot_place_2.ogg", "static"),
    ["cattle_farms_cannot_be_placed_on_mountain"] = love.audio.newSource(
        "sounds/speech/cattle_farms_cannot_be_placed_on_mountain.ogg", "static"),
    ["farms_valley_floor"] = love.audio.newSource("sounds/speech/farms_valley_floor.ogg", "static"),
    ["granary_full"] = love.audio.newSource("sounds/speech/granary_full.ogg", "static"),
    ["hop_farms_need_valley_floor"] = love.audio.newSource("sounds/speech/hop_farms_need_valley_floor.ogg", "static"),
    ["iron_mine_needs_iron_ore"] = love.audio.newSource("sounds/speech/iron_mine_needs_iron_ore.ogg", "static"),
    ["not_enough_workers"] = love.audio.newSource("sounds/speech/not_enough_workers.ogg", "static"),
    ["not_enough_goods"] = love.audio.newSource("sounds/speech/not_enough_goods.ogg", "static"),
    ["pitch_needs_oil"] = love.audio.newSource("sounds/speech/pitch_needs_oil.ogg", "static"),
    ["place_a_keep"] = love.audio.newSource("sounds/speech/place_a_keep.ogg", "static"),
    ["place_granary"] = love.audio.newSource("sounds/speech/place_granary.ogg", "static"),
    ["stockpile_full"] = love.audio.newSource("sounds/speech/stockpile_full.ogg", "static"),
    ["too_close_to_enemy"] = love.audio.newSource("sounds/speech/too_close_to_enemy.ogg", "static"),
    ["too_close_to_enemy_repair"] = love.audio.newSource("sounds/speech/too_close_to_enemy_repair.ogg", "static"),
    ["wheat_farms_valley_floor"] = love.audio.newSource("sounds/speech/wheat_farms_valley_floor.ogg", "static"),
    ["General_Saving"] = love.audio.newSource("sounds/speech/General_Saving.ogg", "static"),
    ["General_Startgame"] = love.audio.newSource("sounds/speech/General_Startgame.ogg", "static"),
    ["General_Loading"] = love.audio.newSource("sounds/speech/General_Loading.ogg", "static")

}
speech["General_Saving"]:setVolumeLimits(0, 0.8)
speech["General_Startgame"]:setVolumeLimits(0, 0.8)
speech["General_Loading"]:setVolumeLimits(0, 0.8)

for _, sf in pairs(speech) do
    sf:setRelative(true)
end

return speech
