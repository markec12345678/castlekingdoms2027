local _, _, _, _ = ...
local StoneGateBig = require("objects.Structures.StoneGateBig")
local StoneGateBigEast = _G.class("StoneGateBigEast", StoneGateBig)
StoneGateBigEast.static.WIDTH = 7
StoneGateBigEast.static.LENGTH = 7
StoneGateBigEast.static.HEIGHT = 17
StoneGateBigEast.static.DESTRUCTIBLE = true
function StoneGateBigEast:initialize(gx, gy)
    StoneGateBig.initialize(self, gx, gy, "east")
end

return StoneGateBigEast
