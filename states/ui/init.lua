local actionBar = require("states.ui.ActionBar")
require("states.ui.construction.level_1")
local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")
local ab = require("states.ui.action_bar_frames")
local el = actionBar.element

local imgKeybinds = love.graphics.newImage("assets/ui/keybindings_action_bar.png")
local keybinds = loveframes.Create("image")
keybinds:SetState(states.STATE_INGAME_CONSTRUCTION)
keybinds:SetImage(imgKeybinds)
keybinds.disablehover = true
keybinds:SetOffsetY(imgKeybinds:getHeight())
keybinds:SetPos(ab.frAction_1.x + ab.frAction_1.width - 14 * el.scalex,
    ab.frActionBar.y + ab.frActionBar.height - 3 * el.scalex)
keybinds:SetScale(el.scalex)

require("states.ui.building_tooltip")
require("states.ui.main_menu.menu")
require("states.ui.pause.menu")
require("states.ui.main_menu.load_game")
require("states.ui.settings.settings")
require("states.ui.granary.food_rations")
require("states.ui.stockpile.stockpile_goods")
require("states.ui.market.market_trade")
require("states.ui.market.market_trade_main")
require("states.ui.keep.keep_tax")
require("states.ui.armoury.armoury_ui")
