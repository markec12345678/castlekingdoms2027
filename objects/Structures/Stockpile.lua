local object, tile_quads, object_batch = ...
local Object = require("objects.Object")

local quad_map = {
	["wood"] = {
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
	["stone"] = {
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
	["wheat"] = {
		[1] = tile_quads[1618],
		[2] = tile_quads[1617],
		[3] = tile_quads[1616],
		[4] = tile_quads[1614],
		[5] = tile_quads[1613],
		[6] = tile_quads[1612],
		[7] = tile_quads[1611],
		[8] = tile_quads[1610],
		[9] = tile_quads[1609],
		[10] = tile_quads[1608],
		[11] = tile_quads[1607],
		[12] = tile_quads[1606],
		[13] = tile_quads[1605],
		[14] = tile_quads[1603],
		[15] = tile_quads[1602],
		[16] = tile_quads[1601],
		[17] = tile_quads[1600],
		[18] = tile_quads[1599],
		[19] = tile_quads[1598],
		[20] = tile_quads[1597],
		[21] = tile_quads[1596],
		[22] = tile_quads[1595],
		[23] = tile_quads[1594],
		[24] = tile_quads[1624],
		[25] = tile_quads[1623],
		[26] = tile_quads[1622],
		[27] = tile_quads[1621],
		[28] = tile_quads[1620],
		[29] = tile_quads[1619],
		[30] = tile_quads[1615],
		[31] = tile_quads[1604],
		[32] = tile_quads[1593]
	 },
	["iron"] = {
		[1] = tile_quads[1538],
		[2] = tile_quads[1537],
		[3] = tile_quads[1536],
		[4] = tile_quads[1535],
		[5] = tile_quads[1534],
		[6] = tile_quads[1533],
		[7] = tile_quads[1532],
		[8] = tile_quads[1531],
		[9] = tile_quads[1530],
		[10] = tile_quads[1528],
		[11] = tile_quads[1527],
		[12] = tile_quads[1526],
		[13] = tile_quads[1525],
		[14] = tile_quads[1524],
		[15] = tile_quads[1523],
		[16] = tile_quads[1522],
		[17] = tile_quads[1521],
		[18] = tile_quads[1520],
		[19] = tile_quads[1519],
		[20] = tile_quads[1517],
		[21] = tile_quads[1516],
		[22] = tile_quads[1515],
		[23] = tile_quads[1514],
		[24] = tile_quads[1513],
		[25] = tile_quads[1512],
		[26] = tile_quads[1511],
		[27] = tile_quads[1510],
		[28] = tile_quads[1509],
		[29] = tile_quads[1508],
		[30] = tile_quads[1506],
		[31] = tile_quads[1505],
		[32] = tile_quads[1504],
		[33] = tile_quads[1503],
		[34] = tile_quads[1502],
		[35] = tile_quads[1501],
		[36] = tile_quads[1500],
		[37] = tile_quads[1499],
		[38] = tile_quads[1498],
		[39] = tile_quads[1497],
		[40] = tile_quads[1543],
		[41] = tile_quads[1542],
		[42] = tile_quads[1541],
		[43] = tile_quads[1540],
		[44] = tile_quads[1539],
		[45] = tile_quads[1529],
		[46] = tile_quads[1518],
		[47] = tile_quads[1507],
		[48] = tile_quads[1496]
	 },
	["flour"] = {
		[1] = tile_quads[1489],
		[2] = tile_quads[1488],
		[3] = tile_quads[1487],
		[4] = tile_quads[1485],
		[5] = tile_quads[1484],
		[6] = tile_quads[1483],
		[7] = tile_quads[1482],
		[8] = tile_quads[1481],
		[9] = tile_quads[1480],
		[10] = tile_quads[1479],
		[11] = tile_quads[1478],
		[12] = tile_quads[1477],
		[13] = tile_quads[1476],
		[14] = tile_quads[1474],
		[15] = tile_quads[1473],
		[16] = tile_quads[1472],
		[17] = tile_quads[1471],
		[18] = tile_quads[1470],
		[19] = tile_quads[1469],
		[20] = tile_quads[1468],
		[21] = tile_quads[1467],
		[22] = tile_quads[1466],
		[23] = tile_quads[1465],		
		[24] = tile_quads[1495],
		[25] = tile_quads[1494],
		[26] = tile_quads[1493],
		[27] = tile_quads[1492],
		[28] = tile_quads[1491],
		[29] = tile_quads[1490],		
		[30] = tile_quads[1486],
		[31] = tile_quads[1475],
		[32] = tile_quads[1464]
	 }
}

local offset_y = {
	["wood"] = {
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
	["stone"] = {
		-9,-9,-9,-9,-9,-9,-9,-9,-9,
		-18,-18,-18,-18,-18,-18,-18,-18,-18,
		-26,-26,-26,-26,-26,-26,-26,-26,-26,
		-35,-35,-35,-35,-35,-35,-35,-35,-35,
		-43,-43,-43,-43,-43,-43,-43,-43,-43,
		-47,-47,-47,-47
		},
	["wheat"] = {
		-14,-14,-14,-14,
		-17,-17,-17,
		-19,-19,-19,-19,-19,-19,-19,-19,-19,
		-28,-28,-28,-28,
		-31,-31,-31,-31,-31,-31,-31,-31,
		-33,-33,-35,-35
		},
	["iron"] = {
		-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,
		-10,-10,-10,-10,-10,-10,-10,-10,-10,-10,-10,-10,
		-15,-15,-15,-15,-15,-15,-15,-15,-15,-15,-15,-15,
		-19,-19,-19,-19,-19,-19,-19,-19,-19,-19,-19,-19,
		},
	["flour"] = {
		-2,-2,-2,-2,-2,-2,-2,
		-3,-3,-3,-3,-3,-3,-3,
		-6,-6,-6,-6,-6,-6,-6,-6,
		-9,
		-13,-13,-13,-13,-13,-13,-13,
		-14,-15
		}
}

local max_quantity = {
	["wood"] = 48,
	["stone"] = 48,
	["wheat"] = 32,
	["iron"] = 48,
	["flour"] = 32
}
local Stockpile_alias = class('Stockpile_alias', Object)
			function Stockpile_alias:initialize(tile,gx,gy,parent,offset_y,offset_x)
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


local Stockpile = class('Stockpile', Object)
			function Stockpile:initialize(cx,cy,i,o,x,y,type)
                local mytype = "Static structure"
				Object.initialize(self,cx,cy,i,o,x,y,mytype)
				self.gx = chunk_width*self.cx+self.i
				self.gy = chunk_width*self.cy+self.o
					setWalkable(self.gx,self.gy,1)
				self.health = 1000
                self.qid = nil
                self.tile = tile_quads[2296]
				self.offset_x = 0
				self.offset_y = -12
                self.level = 1
                self.rotation = 1
				self.stockpile = {}
				self.stockpile[1] = {id = nil, empty = true, type = nil, quantity = 0, index = 1}
				self.stockpile[2] = {id = nil, empty = true, type = nil, quantity = 0, index = 2}
				self.stockpile[3] = {id = nil, empty = true, type = nil, quantity = 0, index = 3}
				self.stockpile[4] = {id = nil, empty = true, type = nil, quantity = 0, index = 4}
				
				local ccx, ccy
                for xx = -1, 5 do
					for yy = -1, 5 do 					
						ccx, ccy = terrainSetTileAt(self.gx+xx,self.gy+yy,math.random(6,8))
					end
				end
				update_terrain(ccx,ccy)

                Stockpile_alias:new(tile_quads[2292],self.gx,self.gy+4,self,12+8*4)
                Stockpile_alias:new(tile_quads[2293],self.gx,self.gy+3,self,12+8*3)
                Stockpile_alias:new(tile_quads[2294],self.gx,self.gy+2,self,12+8*2)
                Stockpile_alias:new(tile_quads[2295],self.gx,self.gy+1,self,12+8*1)

                Stockpile_alias:new(tile_quads[2297],self.gx+1,self.gy,self,12+8*1,16)
                Stockpile_alias:new(tile_quads[2298],self.gx+2,self.gy,self,12+8*2,16)
                Stockpile_alias:new(tile_quads[2299],self.gx+3,self.gy,self,12+8*3,16)
                Stockpile_alias:new(tile_quads[2300],self.gx+4,self.gy,self,12+8*4,16)

                Stockpile_alias:new(tile_quads[0],self.gx+4,self.gy+4-1,self,12+8*4,16)
                Stockpile_alias:new(tile_quads[0],self.gx+4,self.gy+4-2,self,12+8*4,16)
                Stockpile_alias:new(tile_quads[0],self.gx+4-1,self.gy+4,self,12+8*4,16)
                Stockpile_alias:new(tile_quads[0],self.gx+4-2,self.gy+4,self,12+8*4,16)


				self.stockpile[1].id = Stockpile_alias:new(tile_quads[0],self.gx+1,self.gy+1,self,32-4,-16)
				self.stockpile[2].id = Stockpile_alias:new(tile_quads[0],self.gx+1,self.gy+4,self,32-4,-16)
				self.stockpile[3].id = Stockpile_alias:new(tile_quads[0],self.gx+4,self.gy+1,self,32-4,-16)
				self.stockpile[4].id = Stockpile_alias:new(tile_quads[0],self.gx+4,self.gy+4,self,32-4,-16)
				table.insert(_G.stockpile.node_list,{gx = self.gx+2, gy = self.gy+5})
				table.insert(_G.stockpile.node_list,{gx = self.gx-1, gy = self.gy+2})
				table.insert(_G.stockpile.node_list,{gx = self.gx+2, gy = self.gy-1})
				table.insert(_G.stockpile.node_list,{gx = self.gx+5, gy = self.gy+2})

				_G.stockpile.list[(#stockpile.list or 0) + 1] = self
			end
			function Stockpile:store(resource)
				local found = false
				for index = 1, 4 do
					if self.stockpile[index].type == resource and self.stockpile[index].quantity < max_quantity[resource] then
						self.stockpile[index].quantity = self.stockpile[index].quantity + 1				
						_G.resources[resource] = _G.resources[resource] + 1			
						found = true
						self:update_stockpile(index)
						return true
					end
				end 
				if not found then
					for index = 1, 4 do
						if self.stockpile[index].empty then
							self.stockpile[index].empty = false
							self.stockpile[index].type = resource
							self.stockpile[index].quantity = 1	
							_G.not_full_stockpiles[self.stockpile[index].type] = _G.not_full_stockpiles[self.stockpile[index].type] + 1
							_G.resources[resource] = _G.resources[resource] + 1	
							self.stockpile[index].key = #_G.stockpile.resources[resource]+1
							_G.stockpile.resources[resource][self.stockpile[index].key] = self.stockpile[index]
							self:update_stockpile(index)
							found = true
							break
						end
					end
				end
				if not found then return false else return true end
			end
			function Stockpile:take(resource, from)
				if from.type == resource and from.quantity > 0 then
					if from.quantity == max_quantity[resource] then
						_G.not_full_stockpiles[resource] = _G.not_full_stockpiles[resource] + 1
					end
					from.quantity = from.quantity - 1		
					_G.resources[resource] = _G.resources[resource] - 1		
					found = true
					self:update_stockpile(from)
					return true
				end
				local found = false
				for index = 1, 4 do
					if self.stockpile[index].type == resource and self.stockpile[index].quantity > 0 then
						self.stockpile[index].quantity = self.stockpile[index].quantity - 1			
						_G.resources[resource] = _G.resources[resource] - 1
						found = true
						self:update_stockpile(index)
						return true
					end
				end 
				if not found then
					return false
				end
				return true
			end
			function Stockpile:update_stockpile(index)
				local pile
				if type(index) ~= "number" then pile = index else				 
					pile = self.stockpile[index]
				end
				if pile.quantity == 0 then
					table.remove(_G.stockpile.resources[pile.type],pile.key)
					_G.not_full_stockpiles[pile.type] = _G.not_full_stockpiles[pile.type] - 1
					pile.quantity = -1
					pile.type = nil
					pile.empty = true				
					pile.id.tile = tile_quads[0]
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
					_G.not_full_stockpiles[pile.type] = _G.not_full_stockpiles[pile.type] - 1
				end
			end

return Stockpile