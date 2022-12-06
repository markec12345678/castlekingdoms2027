local _, _, _, _ = ...
local WoodenGate = require("objects.Structures.WoodenGate")
local WoodenGateEast = _G.class("WoodenGateEast", WoodenGate)
WoodenGateEast.static.WIDTH = 3
WoodenGateEast.static.LENGTH = 3
WoodenGateEast.static.HEIGHT = 17
WoodenGateEast.static.DESTRUCTIBLE = true
function WoodenGateEast:initialize(gx, gy)
    WoodenGate.initialize(self, gx, gy, "east")
end

return WoodenGateEast