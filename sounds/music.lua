-- TODO: load variables from user settings / options
local strongholdOstEnabled = true;
local extendedSoundtrackEnabled = true;

-- define mood structure
local music = {
    ["peaceful"] = {},
    ["combat"] = {}
}

-- Stronghold OST
if strongholdOstEnabled then
    table.insert(music["peaceful"], love.audio.newSource("sounds/music/stronghold_ost/02 Appy Times.mp3", "stream"))
    table.insert(music["peaceful"], love.audio.newSource("sounds/music/stronghold_ost/03 Castle Jam.mp3", "stream"))
    table.insert(music["peaceful"], love.audio.newSource("sounds/music/stronghold_ost/08 Matt's Jig.mp3", "stream"))
    table.insert(music["peaceful"], love.audio.newSource("sounds/music/stronghold_ost/10 Sad Times.mp3", "stream"))
    table.insert(music["peaceful"], love.audio.newSource("sounds/music/stronghold_ost/12 Stained Glass.mp3", "stream"))
    table.insert(music["peaceful"], love.audio.newSource("sounds/music/stronghold_ost/13 The Maiden.mp3", "stream"))
    table.insert(music["peaceful"], love.audio.newSource("sounds/music/stronghold_ost/14 Under an Old Tree.mp3", "stream"))
    table.insert(music["peaceful"], love.audio.newSource("sounds/music/stronghold_ost/15 Two Mandolins.mp3", "stream"))

    table.insert(music["combat"], love.audio.newSource("sounds/music/stronghold_ost/04 Dark Time.mp3", "stream"))
    table.insert(music["combat"], love.audio.newSource("sounds/music/stronghold_ost/05 Exploration.mp3", "stream"))
    table.insert(music["combat"], love.audio.newSource("sounds/music/stronghold_ost/06 Honour Medley.mp3", "stream"))
    table.insert(music["combat"], love.audio.newSource("sounds/music/stronghold_ost/11 Stix & Stones Medley.mp3", "stream"))
end

-- Extended Soundtrack
if extendedSoundtrackEnabled then
    -- Alexander Nakarada
    table.insert(music["peaceful"], love.audio.newSource("sounds/music/extended_soundtrack/alexander_nakarada/Bonfire.mp3", "stream"))
    table.insert(music["peaceful"], love.audio.newSource("sounds/music/extended_soundtrack/alexander_nakarada/Horsemen Approach.mp3", "stream"))
    table.insert(music["peaceful"], love.audio.newSource("sounds/music/extended_soundtrack/alexander_nakarada/Tavern Loop One.mp3", "stream"))

    -- Kevin MacLeod
    table.insert(music["peaceful"], love.audio.newSource("sounds/music/extended_soundtrack/kevin_macleod/Achaidh Cheide.mp3", "stream"))
    table.insert(music["peaceful"], love.audio.newSource("sounds/music/extended_soundtrack/kevin_macleod/Angevin B.mp3", "stream"))
    table.insert(music["peaceful"], love.audio.newSource("sounds/music/extended_soundtrack/kevin_macleod/Folk Round.mp3", "stream"))
    table.insert(music["peaceful"], love.audio.newSource("sounds/music/extended_soundtrack/kevin_macleod/Midnight Tale.mp3", "stream"))
    table.insert(music["peaceful"], love.audio.newSource("sounds/music/extended_soundtrack/kevin_macleod/Painting Room.mp3", "stream"))
    table.insert(music["peaceful"], love.audio.newSource("sounds/music/extended_soundtrack/kevin_macleod/Pippin the Hunchback.mp3", "stream"))
    table.insert(music["peaceful"], love.audio.newSource("sounds/music/extended_soundtrack/kevin_macleod/Skye Cuillin.mp3", "stream"))
    table.insert(music["peaceful"], love.audio.newSource("sounds/music/extended_soundtrack/kevin_macleod/Suonatore di Liuto.mp3", "stream"))
    table.insert(music["peaceful"], love.audio.newSource("sounds/music/extended_soundtrack/kevin_macleod/Teller of the Tales.mp3", "stream"))
    table.insert(music["peaceful"], love.audio.newSource("sounds/music/extended_soundtrack/kevin_macleod/The Britons.mp3", "stream"))
    table.insert(music["peaceful"], love.audio.newSource("sounds/music/extended_soundtrack/kevin_macleod/The Pyre.mp3", "stream"))
    table.insert(music["peaceful"], love.audio.newSource("sounds/music/extended_soundtrack/kevin_macleod/Village Consort.mp3", "stream"))

    table.insert(music["combat"], love.audio.newSource("sounds/music/extended_soundtrack/kevin_macleod/Lord of the Land.mp3", "stream"))

    -- Random Mind
    table.insert(music["peaceful"], love.audio.newSource("sounds/music/extended_soundtrack/random_mind/The_Bards_Tale.mp3", "stream"))
    table.insert(music["peaceful"], love.audio.newSource("sounds/music/extended_soundtrack/random_mind/The_Old_Tower_Inn.mp3", "stream"))
end

return music
