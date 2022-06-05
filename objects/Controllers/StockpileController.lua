local StockpileController = _G.class("StockpileController")
local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")

local stockpileFx = {
    ["wood"] = {_G.fx["plank1"], _G.fx["plank2"], _G.fx["plank3"]},
    ["stone"] = {_G.fx["stckstone1"]},
    ["wheat"] = {_G.fx["stckwheat1"]},
    ["iron"] = {_G.fx["stckiron2"]}
}

function StockpileController:initialize()
    self.list = {}
    self.resources = {
        ["wood"] = {},
        ["stone"] = {},
        ["wheat"] = {},
        ["iron"] = {},
        ["flour"] = {}
    }
    self.nodeList = {}

    local resourceText = loveframes.Create("text")
    self.resourceText = resourceText
    resourceText:SetState(states.STATE_INGAME_CONSTRUCTION)
    resourceText:SetFont(loveframes.basicfont)
    resourceText:SetPos(20, 20)
    resourceText:SetText("")
    resourceText:SetShadowColor(0, 0, 0)
    resourceText:SetShadow(true)
end
function StockpileController:store(resource) -- TODO: add amount
    if _G.state.notFullStockpiles[resource] < 1 then
        for _, v in ipairs(self.list) do
            if v:store(resource) then
                if stockpileFx[resource] then
                    _G.playSfx(v, stockpileFx[resource])
                end
                break
            end
        end
    else
        self.resources[resource][#self.resources[resource]].id.parent:store(resource)
        if stockpileFx[resource] then
            _G.playSfx(self.resources[resource][#self.resources[resource]].id, stockpileFx[resource])
        end
    end
    self:updateResourceCount()
end
function StockpileController:take(resource, amount)
    amount = amount or 1
    -- TODO: won't work with multiple amount - will return true even if 1 out of 3 resources are present
    for _ = 1, amount do
        if next(self.resources[resource]) == nil then
            return false
        else
            local resTable = self.resources[resource]
            resTable[#resTable].id.parent:take(resource, resTable[#resTable])
        end
    end
    self:updateResourceCount()
    return true
end
function StockpileController:updateResourceCount()
    local count = {}
    for resource, stockpile in pairs(self.resources) do
        if not count[resource] then
            count[resource] = 0
        end
        if stockpile then
            for _, node in ipairs(stockpile) do
                count[resource] = count[resource] + node.quantity
            end
        end
    end
    local text = string.format("Wood: %d\nStone: %d\nIron: %d\nFlour: %d\nWheat: %d", count.wood, count.stone,
        count.iron, count.flour, count.wheat)
    self.resourceText:SetText({{
        color = {240 / 255, 240 / 255, 224 / 255}
    }, text})
    return count
end
function StockpileController:serialize()
    local data = {
        dummy = true
    }
    return data
end
function StockpileController:deserialize(_)
end
return StockpileController:new()
