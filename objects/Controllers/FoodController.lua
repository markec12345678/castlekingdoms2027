local FoodController = _G.class('FoodController')
local FOOD = require("objects.Enums.Food")

function FoodController:initialize()
    self.list = {}
    self.food = {}

    for _, v in pairs(FOOD) do
        self.food[v] = {}
    end

    self.nodeList = {}
end

function FoodController:foodsConsumed()
    local foods = 0
    for _, v in pairs(self.food) do
        if next(v) then foods = foods + 1 end
    end
    return foods
end

function FoodController:store(food) -- TODO add amount
    if _G.state.notFullFoods[food] < 1 then
        for _, v in ipairs(self.list) do
            if v:store(food) then
                return true
            end
        end
    else
        self.food[food][#self.food[food]].id.parent:store(food)
        return true
    end
end

function FoodController:take(food, amount)
    local takenFood = 0
    if not food then
        for _ = 1, (amount or 1) do
            for foodType, foodPile in pairs(self.food) do
                if takenFood == amount then
                    return
                end
                if next(foodPile) ~= nil then
                    takenFood = takenFood + 1
                    foodPile[#foodPile].id.parent:take(foodType, foodPile[#foodPile])
                end
            end
        end
    else
        for _ = 1, (amount or 1) do
            if next(self.food[food]) == nil then
                break
            else
                self.food[food][#self.food[food]].id.parent:take(food, self.food[food][#self.food[food]])
            end
        end
    end
end

function FoodController:serialize()
    local data = {}
    data.nodeList = self.nodeList
    local food = {}
    for foodtype, foodlist in pairs(self.food) do
        food[foodtype] = {}
        for i, foodpile in ipairs(foodlist) do
            food[foodtype][i] = {}
            for sk, sv in pairs(foodpile) do
                if sk == "id" then
                    food[foodtype][i][sk] = _G.state:serializeObject(sv)
                else
                    food[foodtype][i][sk] = sv
                end
            end
        end
    end
    local granaryList = {}
    for _, v in ipairs(self.list) do
        granaryList[#granaryList + 1] = _G.state:serializeObject(v)
    end
    data.granaryList = granaryList
    data.rawFood = food
    return data
end

function FoodController:deserialize(data)
    self.nodeList = data.nodeList
    for foodtype, foodlist in pairs(data.rawFood) do
        self.food[foodtype] = {}
        for i, foodpile in ipairs(foodlist) do
            self.food[foodtype][i] = {}
            for sk, sv in pairs(foodpile) do
                if sk == "id" then
                    self.food[foodtype][i][sk] = _G.state:dereferenceObject(sv)
                else
                    self.food[foodtype][i][sk] = sv
                end
            end
        end
    end
    for _, v in ipairs(data.granaryList) do
        self.list[#self.list + 1] = _G.state:dereferenceObject(v)
    end
end

return FoodController:new()
