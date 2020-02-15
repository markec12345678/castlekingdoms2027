local object, tile_quads, object_batch = ...
local Object = require("objects.Object")

local quad_map = {
	["apples"] = {
	 	[1] = tile_quads[1667],
		[2] = tile_quads[1666],
	 	[3] = tile_quads[1665],
	 	[4] = tile_quads[1664],
	 	[5] = tile_quads[1663],
	 	[6] = tile_quads[1662],
	 	[7] = tile_quads[1661],
	 	[8] = tile_quads[1660],
	 	[9] = tile_quads[1659],
	 	[10] = tile_quads[1657],
	 	[11] = tile_quads[1656],
	 	[12] = tile_quads[1655],
	 	[13] = tile_quads[1654],
	 	[14] = tile_quads[1653],
	 	[15] = tile_quads[1652],
	 	[16] = tile_quads[1651],
	 	[17] = tile_quads[1650],
	 	[18] = tile_quads[1649],
	 	[19] = tile_quads[1648],
	 	[20] = tile_quads[1646],
	 	[21] = tile_quads[1645],
	 	[22] = tile_quads[1644],
	 	[23] = tile_quads[1643],
	 	[24] = tile_quads[1642],
	 	[25] = tile_quads[1641],
	 	[26] = tile_quads[1640],
	 	[27] = tile_quads[1639],
	 	[28] = tile_quads[1638],
	 	[29] = tile_quads[1637],	 
	 	[30] = tile_quads[1635],
	 	[31] = tile_quads[1634],
	 	[32] = tile_quads[1633],
	 	[33] = tile_quads[1632],
	 	[34] = tile_quads[1631],
	 	[35] = tile_quads[1630],
	 	[36] = tile_quads[1629],
	 	[37] = tile_quads[1628],
	 	[38] = tile_quads[1627],
	 	[39] = tile_quads[1626],
	 	[40] = tile_quads[1672],
	 	[41] = tile_quads[1671],
	 	[42] = tile_quads[1670],
	 	[43] = tile_quads[1669],
	 	[44] = tile_quads[1668],
	 	[45] = tile_quads[1658],
	 	[46] = tile_quads[1647],
		[47] = tile_quads[1636],
		[48] = tile_quads[1625], 
	 },
	["bread"] = {
		[1] = tile_quads[1586],
		[2] = tile_quads[1585],
		[3] = tile_quads[1584],
		[4] = tile_quads[1583],
		[5] = tile_quads[1582],
		[6] = tile_quads[1581],
		[7] = tile_quads[1580],
		[8] = tile_quads[1579],
		[9] = tile_quads[1578],
		[10] = tile_quads[1576],
		[11] = tile_quads[1575],
		[12] = tile_quads[1574],
		[13] = tile_quads[1573],
		[14] = tile_quads[1572],
		[15] = tile_quads[1571],
		[16] = tile_quads[1570],
		[17] = tile_quads[1569],
		[18] = tile_quads[1568],
		[19] = tile_quads[1567],
		[20] = tile_quads[1565],
		[21] = tile_quads[1564],
		[22] = tile_quads[1563],
		[23] = tile_quads[1562],
		[24] = tile_quads[1561],
		[25] = tile_quads[1560],
		[26] = tile_quads[1559],
		[27] = tile_quads[1558],
		[28] = tile_quads[1557],
		[29] = tile_quads[1556],
		[30] = tile_quads[1554],
		[31] = tile_quads[1553],
		[32] = tile_quads[1552],
		[33] = tile_quads[1551],
		[34] = tile_quads[1550],
		[35] = tile_quads[1549],
		[36] = tile_quads[1548],
		[37] = tile_quads[1547],
		[38] = tile_quads[1546],
		[39] = tile_quads[1545],
		[40] = tile_quads[1591],
		[41] = tile_quads[1590],
		[42] = tile_quads[1589],
		[43] = tile_quads[1588],
		[44] = tile_quads[1587],
		[45] = tile_quads[1577],
		[46] = tile_quads[1566],
		[47] = tile_quads[1555],
		[48] = tile_quads[1544],
	 },	
	["cheese"] = {
		[1] = tile_quads[1586],
		[2] = tile_quads[1585],
		[3] = tile_quads[1584],
		[4] = tile_quads[1583],
		[5] = tile_quads[1582],
		[6] = tile_quads[1581],
		[7] = tile_quads[1580],
		[8] = tile_quads[1579],
		[9] = tile_quads[1578],
		[10] = tile_quads[1576],
		[11] = tile_quads[1575],
		[12] = tile_quads[1574],
		[13] = tile_quads[1573],
		[14] = tile_quads[1572],
		[15] = tile_quads[1571],
		[16] = tile_quads[1570],
		[17] = tile_quads[1569],
		[18] = tile_quads[1568],
		[19] = tile_quads[1567],
		[20] = tile_quads[1565],
		[21] = tile_quads[1564],
		[22] = tile_quads[1563],
		[23] = tile_quads[1562],
		[24] = tile_quads[1561],
		[25] = tile_quads[1560],
		[26] = tile_quads[1559],
		[27] = tile_quads[1558],
		[28] = tile_quads[1557],
		[29] = tile_quads[1556],
		[30] = tile_quads[1554],
		[31] = tile_quads[1553],
		[32] = tile_quads[1552],
		[33] = tile_quads[1551],
		[34] = tile_quads[1550],
		[35] = tile_quads[1549],
		[36] = tile_quads[1548],
		[37] = tile_quads[1547],
		[38] = tile_quads[1546],
		[39] = tile_quads[1545],
		[40] = tile_quads[1591],
		[41] = tile_quads[1590],
		[42] = tile_quads[1589],
		[43] = tile_quads[1588],
		[44] = tile_quads[1587],
		[45] = tile_quads[1577],
		[46] = tile_quads[1566],
		[47] = tile_quads[1555],
		[48] = tile_quads[1544],
	 },	
}

local offset_y = {
	["apples"] = {
		-2,-2,-2,
		-4,-4,-4,-4,
		-5,-5,-5,-5,
		-7,-7,-7,-7,
		-10,-10,-10,-10,
		-11,-11,-11,-11,
		-13,-13,-13,-13,
		-15,-15,-15,-15,
		-17,-17,-17,-17,
		-20,-20,-20,-20,
		-21,-21,-21,-21,
		-23,-23,-23,-23,
		-25 },
	["bread"] = {
		-9,-9,-9,-9,-9,-9,-9,-9,-9,
		-18,-18,-18,-18,-18,-18,-18,-18,-18,
		-26,-26,-26,-26,-26,-26,-26,-26,-26,
		-35,-35,-35,-35,-35,-35,-35,-35,-35,
		-43,-43,-43,-43,-43,-43,-43,-43,-43,
		-47,-47,-47,-47
		},
    ["cheese"] = {
		-9,-9,-9,-9,-9,-9,-9,-9,-9,
		-18,-18,-18,-18,-18,-18,-18,-18,-18,
		-26,-26,-26,-26,-26,-26,-26,-26,-26,
		-35,-35,-35,-35,-35,-35,-35,-35,-35,
		-43,-43,-43,-43,-43,-43,-43,-43,-43,
		-47,-47,-47,-47
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
				for k,v in ipairs(_G.stockpile.node_list) do
					if v.gx == self.gx and v.gy == self.gy then
						table.remove(_G.stockpile.node_list, k)
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
                self.tile = tile_quads[2323]
				self.offset_x = 0
				self.offset_y = -64-14
                self.level = 1
                self.rotation = 1
				self.hover_action = true
				-- self.stockpile = {}
				-- self.stockpile[1] = {id = nil, empty = true, type = nil, quantity = 0, index = 1}
				-- self.stockpile[2] = {id = nil, empty = true, type = nil, quantity = 0, index = 2}
				-- self.stockpile[3] = {id = nil, empty = true, type = nil, quantity = 0, index = 3}
				-- self.stockpile[4] = {id = nil, empty = true, type = nil, quantity = 0, index = 4}
				
				local ccx, ccy
                for xx = -1, 4 do
					for yy = -1, 4 do 					
						ccx, ccy = terrainSetTileAt(self.gx+xx,self.gy+yy,math.random(6,8))
					end
				end
				update_terrain(ccx,ccy)

                Granary_alias:new(tile_quads[2320],self.gx,self.gy+3,self,-(-64-14)+8*3)
                Granary_alias:new(tile_quads[2321],self.gx,self.gy+2,self,-(-64-14)+8*2)
                Granary_alias:new(tile_quads[2322],self.gx,self.gy+1,self,-(-64-14)+8*1)

                Granary_alias:new(tile_quads[2324],self.gx+1,self.gy,self,-(-64-14)+8*1,14)
                Granary_alias:new(tile_quads[2325],self.gx+2,self.gy,self,-(-64-14)+8*2,14)
                Granary_alias:new(tile_quads[2326],self.gx+3,self.gy,self,-(-64-14)+8*3,14)

                Granary_alias:new(tile_quads["empty"],self.gx+3,self.gy+3,self,0,0)
                Granary_alias:new(tile_quads["empty"],self.gx+2,self.gy+3,self,0,0)
                Granary_alias:new(tile_quads["empty"],self.gx+1,self.gy+3,self,0,0)
                Granary_alias:new(tile_quads["empty"],self.gx+3,self.gy+2,self,0,0)
                Granary_alias:new(tile_quads["empty"],self.gx+3,self.gy+1,self,0,0)


				-- self.stockpile[1].id = Granary_alias:new(tile_quads["empty"],self.gx+1,self.gy+1,self,32-4,-16)
				-- self.stockpile[2].id = Granary_alias:new(tile_quads["empty"],self.gx+1,self.gy+4,self,32-4,-16)
				-- self.stockpile[3].id = Granary_alias:new(tile_quads["empty"],self.gx+4,self.gy+1,self,32-4,-16)
				-- self.stockpile[4].id = Granary_alias:new(tile_quads["empty"],self.gx+4,self.gy+4,self,32-4,-16)
				-- table.insert(_G.stockpile.node_list,{gx = self.gx+2, gy = self.gy+5})
				-- table.insert(_G.stockpile.node_list,{gx = self.gx-1, gy = self.gy+2})
				-- table.insert(_G.stockpile.node_list,{gx = self.gx+2, gy = self.gy-1})
				-- table.insert(_G.stockpile.node_list,{gx = self.gx+5, gy = self.gy+2})

				-- _G.stockpile.list[(#stockpile.list or 0) + 1] = self
			end
			-- function Granary:store(resource)
			-- 	local found = false
			-- 	for index = 1, 4 do
			-- 		if self.stockpile[index].type == resource and self.stockpile[index].quantity < max_quantity[resource] then
			-- 			self.stockpile[index].quantity = self.stockpile[index].quantity + 1					
			-- 			found = true
			-- 			self:update_stockpile(index)
			-- 		end
			-- 	end 
			-- 	if not found then
			-- 		for index = 1, 4 do
			-- 			if self.stockpile[index].empty then
			-- 				self.stockpile[index].empty = false
			-- 				self.stockpile[index].type = resource
			-- 				self.stockpile[index].quantity = 1
			-- 				self.stockpile[index].key = #_G.stockpile.resources[resource]+1
			-- 				_G.stockpile.resources[resource][#_G.stockpile.resources[resource]+1] = self.stockpile[index]
			-- 				self:update_stockpile(index)
			-- 				found = true
			-- 				break
			-- 			end
			-- 		end
			-- 	end
			-- 	if not found then return true end
			-- end
			-- function Granary:update_stockpile(index)
			-- 	local pile = self.stockpile[index]
			-- 	pile.id.tile = quad_map[pile.type][pile.quantity]
			-- 	pile.id.additional_offset_y = offset_y[pile.type][pile.quantity]
			-- 	pile.id.offset_y = pile.id.additional_offset_y - pile.id.base_offset_y
			-- 	if object_batch[pile.id.cx][pile.id.cy] then
			-- 		object_batch[pile.id.cx][pile.id.cy]
			-- 		:set(
			-- 			pile.id.qid, 
			-- 			pile.id.tile,
			-- 			pile.id.x,
			-- 			pile.id.y
			-- 			)
			-- 	end
			-- 	if pile.quantity == max_quantity[pile.type] then
			-- 		table.remove(_G.stockpile.resources[pile.type],pile.key)
			-- 	end
			-- end

return Granary