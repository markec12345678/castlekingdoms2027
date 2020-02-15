local object, tile_quads, object_batch = ...
local Object = require("objects.Object")

local tiles, quad_array = indexBuildingQuads("granary (1)")

local quad_map = {
	["apples"] = {},
	["bread"] = {},	
	["cheese"] = {},	
}

for i=1, 8 do
	quad_map["apples"][#quad_map["apples"] + 1] = tile_quads["apple_goods ("..tostring(i)..")"]
end

for i=1, 32 do
	quad_map["bread"][#quad_map["bread"] + 1] = tile_quads["bread_goods ("..tostring(i)..")"]
end

for i=1, 16 do
	quad_map["cheese"][#quad_map["cheese"] + 1] = tile_quads["cheese_goods ("..tostring(i)..")"]
end

local offset_y = {
	["apples"] = {
		0,-1, -7,-11,-11,
		-16,-22,-23
	},
	["bread"] = {
		0, -3, -7, -10, -14, -14, -14, -14, -14, -14, -14, -14,
		-18+4, -18+4, -18+4, -18+4, -21+4, -24+4, -28+4, -31+4, -31+4,-31+4,-31+4,-31+4,-31+4,-31+4,-31+4,-31+4,-31+4,-31+4,-31+4,-31+4,
	},
    ["cheese"] = {
		0,-3,-6,-12,-12,-12,-18,-18,-18,-24,-24,-24,-30,-30,-30,
		-33
	},
}

local max_quantity = {
	["apples"] = 8,
	["bread"] = 32,
	["cheese"] = 16,
}
local Granary_alias = class('Granary_alias', Object)
			function Granary_alias:initialize(tile,gx,gy,parent,offset_y,offset_x)
                local mytype = "Static structure"
				local i = (gx) % (chunk_width)
				local o = (gy) % (chunk_width)
				local cx = math.floor(gx/chunk_width)
				local cy = math.floor(gy/chunk_width)				 
				local x = IsoX + (i - o) * tile_width  * 0.5
				local y = IsoY + (i + o) * tile_height * 0.5
				Object.initialize(self,cx,cy,i,o,x,y,mytype)
				self.gx = gx
				self.gy = gy
					setWalkable(self.gx,self.gy,1)
				self.parent = parent
                self.qid = 0
                self.tile = tile
				self.base_offset_y = offset_y or 0
				self.additional_offset_y = 0
				self.offset_x = offset_x or 0
				self.offset_y = self.additional_offset_y-self.base_offset_y 
				for k,v in ipairs(_G.foodpile.node_list) do
					if v.gx == self.gx and v.gy == self.gy then
						table.remove(_G.foodpile.node_list, k)
						break
					end
				end
				addObjectAt(cx, cy, i, o, self)	
			end


local Granary = class('Granary', Object)
			function Granary:initialize(cx,cy,i,o,x,y,type)
                local mytype = "Static structure"
				Object.initialize(self,cx,cy,i,o,x,y,mytype)
				self.gx = chunk_width*self.cx+self.i
				self.gy = chunk_width*self.cy+self.o
					setWalkable(self.gx,self.gy,1)
				self.health = 1000
                self.qid = nil
				self.tile = quad_array[tiles + 1]
				self.offset_x = 0
				self.offset_y = -64-14
                self.level = 1
                self.rotation = 1
				self.hover_action = true
				self.foodpile = {}
				self.foodpile[1] = {id = nil, empty = true, type = nil, quantity = 0, index = 1}
				self.foodpile[2] = {id = nil, empty = true, type = nil, quantity = 0, index = 2}
				self.foodpile[3] = {id = nil, empty = true, type = nil, quantity = 0, index = 3}
				self.foodpile[4] = {id = nil, empty = true, type = nil, quantity = 0, index = 4}
				
				local ccx, ccy
                for xx = -1, 4 do
					for yy = -1, 4 do 					
						ccx, ccy = terrainSetTileAt(self.gx+xx,self.gy+yy,math.random(6,8))
					end
				end
				update_terrain(ccx,ccy)
		
				for tile=1, tiles do
					Granary_alias:new(quad_array[tile],self.gx,self.gy+(tiles-tile+1),self,-self.offset_y+8*(tiles-tile+1))
				end
				
				for tile=1, tiles do
					Granary_alias:new(quad_array[tiles + 1 + tile],self.gx+tile,self.gy,self,-self.offset_y+8*tile,14)
				end

                Granary_alias:new(tile_quads["empty"],self.gx+3,self.gy+3,self,0,0)
                Granary_alias:new(tile_quads["empty"],self.gx+2,self.gy+3,self,0,0)
                Granary_alias:new(tile_quads["empty"],self.gx+1,self.gy+3,self,0,0)
                Granary_alias:new(tile_quads["empty"],self.gx+3,self.gy+2,self,0,0)
                Granary_alias:new(tile_quads["empty"],self.gx+3,self.gy+1,self,0,0)


				self.foodpile[1].id = Granary_alias:new(tile_quads["empty"],self.gx+1,self.gy+1,self,32-4)
				self.foodpile[2].id = Granary_alias:new(tile_quads["empty"],self.gx+1,self.gy+3,self,32-4)
				self.foodpile[3].id = Granary_alias:new(tile_quads["empty"],self.gx+3,self.gy+1,self,32-4)
				self.foodpile[4].id = Granary_alias:new(tile_quads["empty"],self.gx+3,self.gy+3,self,32-4)
				table.insert(_G.foodpile.node_list,{gx = self.gx+2, gy = self.gy+3})
				table.insert(_G.foodpile.node_list,{gx = self.gx-1, gy = self.gy+2})
				table.insert(_G.foodpile.node_list,{gx = self.gx+2, gy = self.gy-1})
				table.insert(_G.foodpile.node_list,{gx = self.gx+3, gy = self.gy+2})

				_G.foodpile.list[(#foodpile.list or 0) + 1] = self
			end
			function Granary:store(food)
				local found = false
				for index = 1, 4 do
					if self.foodpile[index].type == food and self.foodpile[index].quantity < max_quantity[food] then
						self.foodpile[index].quantity = self.foodpile[index].quantity + 1				
						_G.food[food] = _G.food[food] + 1			
						found = true
						self:update_foodpile(index)
						return true
					end
				end 
				if not found then
					for index = 1, 4 do
						if self.foodpile[index].empty then
							self.foodpile[index].empty = false
							self.foodpile[index].type = food
							self.foodpile[index].quantity = 1	
							_G.not_full_foods[self.foodpile[index].type] = _G.not_full_foods[self.foodpile[index].type] + 1
							_G.food[food] = _G.food[food] + 1	
							self.foodpile[index].key = #_G.foodpile.food[food]+1
							_G.foodpile.food[food][self.foodpile[index].key] = self.foodpile[index]
							self:update_foodpile(index)
							found = true
							break
						end
					end
				end
				if not found then return false else return true end
			end
			function Granary:take(food, from)
				if from.type == food and from.quantity > 0 then
					if from.quantity == max_quantity[food] then
						_G.not_full_foods[food] = _G.not_full_foods[food] + 1
					end
					from.quantity = from.quantity - 1		
					_G.food[food] = _G.food[food] - 1		
					found = true
					self:update_foodpile(from)
					return true
				end
				local found = false
				for index = 1, 4 do
					if self.foodpile[index].type == food and self.foodpile[index].quantity > 0 then
						self.foodpile[index].quantity = self.foodpile[index].quantity - 1			
						_G.food[food] = _G.food[food] - 1
						found = true
						self:update_foodpile(index)
						return true
					end
				end 
				if not found then
					return false
				end
				return true
			end
			function Granary:update_foodpile(index)
				local pile
				if type(index) ~= "number" then pile = index else				 
					pile = self.foodpile[index]
				end
				if pile.quantity == 0 then
					table.remove(_G.foodpile.food[pile.type],pile.key)
					_G.not_full_foods[pile.type] = _G.not_full_foods[pile.type] - 1
					pile.quantity = -1
					pile.type = nil
					pile.empty = true				
					pile.id.tile = tile_quads["empty"]
					return
				end
				pile.id.tile = quad_map[pile.type][pile.quantity]
				pile.id.additional_offset_y = offset_y[pile.type][pile.quantity]
				pile.id.offset_y = pile.id.additional_offset_y - pile.id.base_offset_y
				if object_batch[pile.id.cx][pile.id.cy] then
					object_batch[pile.id.cx][pile.id.cy]
					:set(
						pile.id.qid, 
						pile.id.tile,
						pile.id.x+pile.id.offset_x,
						pile.id.y+pile.id.offset_y
						)
				end
				if pile.quantity == max_quantity[pile.type] then
					_G.not_full_foods[pile.type] = _G.not_full_foods[pile.type] - 1
				end
			end

return Granary