local _, _, _, _ = ...
local WoodenGateBig = require("objects.Structures.WoodenGateBig")
local WoodenGateEastBig = _G.class("WoodenGateEastBig", WoodenGateBig)
WoodenGateEastBig.static.WIDTH = 5
WoodenGateEastBig.static.LENGTH = 5
WoodenGateEastBig.static.HEIGHT = 17
WoodenGateEastBig.static.DESTRUCTIBLE = true
function WoodenGateEastBig:initialize(gx, gy)
    WoodenGateBig.initialize(self, gx, gy, "east")
end

return WoodenGateEastBig