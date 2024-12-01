local HerdController = _G.class("HerdController")

function HerdController:initialize()
    if not self.deerHerds then
        self.deerHerds = require("objects.Herds.DeerHerds")
        self.rabbitHerds = require("objects.Herds.RabbitHerds")
    else
        self.deerHerds:initialize()
        self.rabbitHerds:initialize()
    end
end

function HerdController:update()
    self.deerHerds:update()
    self.rabbitHerds:update()
end

function HerdController:serialize()
    local data = {}
    data.deerHerds = self.deerHerds:serialize()
    data.rabbitHerds = self.rabbitHerds:serialize()
    return data
end

function HerdController:deserialize(data)
    if data then
        self.deerHerds:deserialize(data.deerHerds)
        self.rabbitHerds:deserialize(data.rabbitHerds)
    end
end

return HerdController:new()