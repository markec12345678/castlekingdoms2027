

local stone_wall = {
	state = "framework",
    id = 1,
    health = 100,
    cost = 20,
    material = 1,
}
function stone_wall.build() 
	if state == "framework" and resource[self.material] >= self.cost then
        resource[self.material] = resource[self.material]-self.cost;
        state = "built";
        id = 2;
    end
end
