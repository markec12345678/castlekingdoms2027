

local FoodController = class('FoodController')
			function FoodController:initialize()
                self.list = {}
                self.food = {
                    ["apples"] = {},
                    ["bread"] = {},
                    ["cheese"] = {},
                }


                self.node_list = {}
			end
            function FoodController:store(food) --TODO add amount
                if _G.not_full_foods[food] < 1 then
                    for k,v in ipairs(self.list) do
                        if v:store(food) then break end
                    end
                else
                    print(inspect(_G.not_full_foods))
                    self.food[food][#self.food[food]].id.parent:store(food)
                end
			end
            function FoodController:take(food, amount)
                for i = 1, amount do
                    if next(self.food[food]) == nil then
                        print("Ran out?",i,amount)
                        break
                    else
                        self.food[food][#self.food[food]].id.parent:take(food,self.food[food][#self.food[food]])
                    end    
                end        
            end
return FoodController:new()