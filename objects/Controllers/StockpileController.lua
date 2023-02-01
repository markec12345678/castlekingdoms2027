local StockpileController = _G.class("StockpileController")

local stockpileFx = {
    ["wood"] = {_G.fx["plank1"], _G.fx["plank2"], _G.fx["plank3"]},
    ['hop'] = {_G.fx["stckhops1"]},
    ["stone"] = {_G.fx["stckstone1"]},
    ["iron"] = {_G.fx["stckiron2"]},
    ["tar"] = {_G.fx["stckpitch2"]},
    ["flour"] = {_G.fx["stckfood1"]},
    ["ale"] = {_G.fx["stckale1"]},
    ["wheat"] = {_G.fx["stckwheat1"]}
}

function StockpileController:initialize()
    self.list = {}
    self.resources = {
        ["wood"] = {},
        ['hop'] = {},
        ["stone"] = {},
        ["iron"] = {},
        ["tar"] = {},
        ["flour"] = {},
        ["ale"] = {},
        ["wheat"] = {}
    }
    self.nodeList = {}
end

function StockpileController:store(resource) -- TODO: add amount
    if _G.state.notFullStockpiles[resource] < 1 then
        for _, v in ipairs(self.list) do
            if v:store(resource) then
                if stockpileFx[resource] then
                    _G.playSfx(v, stockpileFx[resource])
                end
                return true
            end
        end
    else
        self.resources[resource][#self.resources[resource]].id.parent:store(resource)
        if stockpileFx[resource] then
            _G.playSfx(self.resources[resource][#self.resources[resource]].id, stockpileFx[resource])
        end
        return true
    end
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
    return true
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
