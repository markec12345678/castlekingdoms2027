local _, _, _, _ = ...
local StoneGateBig = require("objects.Structures.StoneGateBig")
local StoneGateBigSouth = _G.class("StoneGateBigSouth", StoneGateBig)
StoneGateBigSouth.static.WIDTH = 7
StoneGateBigSouth.static.LENGTH = 7
StoneGateBigSouth.static.HEIGHT = 17
StoneGateBigSouth.static.DESTRUCTIBLE = true
StoneGateBigSouth.static.NAMEINDEX = "stoneGateSouthBig"

function StoneGateBigSouth:initialize(gx, gy)
    StoneGateBig.initialize(self, gx, gy, "south")
end

return StoneGateBigSouth
