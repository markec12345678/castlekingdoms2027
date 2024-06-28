local HerdController = _G.class("HerdController")

function HerdController:initialize()
    if not self.deerHerds then
        self.deerHerds = require("objects.Herds.DeerHerds")
    else
        self.deerHerds:initialize()
    end
end

function HerdController:update()
    self.deerHerds:update()
end

function HerdController:serialize()
    local data = {}
    data.deerHerds = self.deerHerds:serialize()
    return data
end

function HerdController:deserialize(data)
    if data then
        self.deerHerds:deserialize(data.deerHerds)
    end
end

return HerdController:new()