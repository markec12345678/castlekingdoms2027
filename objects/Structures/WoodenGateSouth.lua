local _, _, _, _ = ...
local WoodenGate = require("objects.Structures.WoodenGate")
local WoodenGateSouth = _G.class("WoodenGateSouth", WoodenGate)
WoodenGateSouth.static.WIDTH = 3
WoodenGateSouth.static.LENGTH = 3
WoodenGateSouth.static.HEIGHT = 17
WoodenGateSouth.static.DESTRUCTIBLE = true
function WoodenGateSouth:initialize(gx, gy)
    WoodenGate.initialize(self, gx, gy, "south")
end

return WoodenGateSouth