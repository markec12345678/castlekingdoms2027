local _, _, _, _ = ...
local WoodenGateBig = require("objects.Structures.WoodenGateBig")
local WoodenGateSouthBig = _G.class("WoodenGateSouthBig", WoodenGateBig)
WoodenGateSouthBig.static.WIDTH = 5
WoodenGateSouthBig.static.LENGTH = 5
WoodenGateSouthBig.static.HEIGHT = 17
WoodenGateSouthBig.static.DESTRUCTIBLE = true
function WoodenGateSouthBig:initialize(gx, gy)
    WoodenGateBig.initialize(self, gx, gy, "south")
end

return WoodenGateSouthBig