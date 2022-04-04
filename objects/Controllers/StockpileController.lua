local StockpileController = _G.class('StockpileController')

local stockpile_fx = {
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
    self.node_list = {}
end
function StockpileController:store(resource) -- TODO: add amount
    if _G.state.not_full_stockpiles[resource] < 1 then
        for _, v in ipairs(self.list) do
            if v:store(resource) then
                if stockpile_fx[resource] then
                    _G.play_sfx(v, stockpile_fx[resource])
                end
                break
            end
        end
    else
        self.resources[resource][#self.resources[resource]].id.parent:store(resource)
        if stockpile_fx[resource] then
            _G.play_sfx(self.resources[resource][#self.resources[resource]].id, stockpile_fx[resource])
        end
    end
end
function StockpileController:take(resource, amount)
    amount = amount or 1
    -- TODO: won't work with multiple amount - will return true even if 1 out of 3 resources are present
    for _ = 1, amount do
        if next(self.resources[resource]) == nil then
            return false
        else
            local res_table = self.resources[resource]
            res_table[#res_table].id.parent:take(resource, res_table[#res_table])
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
