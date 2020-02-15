local object_image= ... 

--Declarations
----Library setup
		local bitser = require("libraries.bitser")
----Direction and distance
		local previous_distance, location_distance = 0, 0
		local previous_total_chunks_to_traverse = 0
		local previous_dir = 'none'
		local angle
		local quad_offset = require('objects.quad_offset')
----Location thing
		local location = {
			gx = 0,
			gy = 0,
			x = 0,
			y = 0,
			cx = 0, 
			cy = 0
		}
		function location:new (o)
			o = o or {}  
			setmetatable(o, self)
			self.__index = self
			return o
		end
		local press = location:new()
		local last_location = location:new()
----Rows and columns
		local cols = chunk_width
		local rows = chunk_height
----Chunk 2D array 	
		local active_objects = newAutotable(1)
		local active_entities = newAutotable(1)
		_G.active_chunks = {}
		local object = newAutotable(4)
----Calculate center chunk
		local CenterX = math.round(ScreenToIsoX(width/2-16+view_xview, height/2-8+view_yview));
		local CenterY = math.round(ScreenToIsoY(width/2-16+view_xview, height/2-8+view_yview))
		---------------------------------------
		_G.xchunk = math.floor(CenterX/(chunk_width))
		_G.ychunk = math.floor(CenterY/(chunk_width))
----Generate spriteBatch
		local object_batch = newAutotable(2)   
		local shadow_batch = newAutotable(2)
		--local canvas = love.graphics.newCanvas()  
		if not _G.test_mode then
			object_image:setFilter('nearest','nearest')
		end
		local tile_quads = require('objects.object_quads')
		object_batch[0][0] = love.graphics.newSpriteBatch(object_image, chunk_width*chunk_height)
		shadow_batch[0][0] = love.graphics.newSpriteBatch(object_image, chunk_width*chunk_height)		


--- NOTE Object classes START ---
--- NOTE --------------------------
--- NOTE --------------------------
local Object 		= require('objects.Object')
local Unit 			= love.filesystem.load('objects/Units/Unit.lua')(active_entities, object_batch)
package.loaded['objects.Units.Unit'] = Unit

local Tree 		 	= love.filesystem.load('objects/Environment/Tree.lua')(object_batch, active_objects, tile_quads, object)
local Woodcutter 	= love.filesystem.load('objects/Units/Woodcutter.lua')(object, tile_quads)
local Stonemason 	= love.filesystem.load('objects/Units/Stonemason.lua')(object, tile_quads)
local Miner 		= love.filesystem.load('objects/Units/Miner.lua')(object, tile_quads)
local Castle 		= love.filesystem.load('objects/Structures/Castle.lua')(object, tile_quads)
local Stockpile 	= love.filesystem.load('objects/Structures/Stockpile.lua')(object, tile_quads, object_batch)
local Granary       = love.filesystem.load('objects/Structures/Granary.lua')(object, tile_quads, object_batch)
local Quarry        = love.filesystem.load('objects/Structures/Quarry.lua')(object, tile_quads, object_batch)
local Mine 			= love.filesystem.load('objects/Structures/Mine.lua')(object, tile_quads, object_batch)
package.loaded['objects.Environment.Tree']  		= Tree
package.loaded['objects.Units.Woodcutter']  		= Woodcutter
package.loaded['objects.Units.Stonemason']  		= Stonemason
package.loaded['objects.Units.Miner'] 				= Miner
package.loaded['objects.Structures.Castle'] 		= Castle
package.loaded['objects.Structures.Stockpile'] 		= Stockpile
package.loaded['objects.Structures.Granary'] 		= Granary
package.loaded['objects.Structures.Quarry'] 		= Quarry
package.loaded['objects.Structures.Mine'] 			= Mine
_G.stockpile = require('objects.Controllers.StockpileController')
--- NOTE --------------------------
--- NOTE --------------------------
--- NOTE Object classes END ---

function addObjectAt(cx,cy,x,y,object_to_add)
	if type(object[cx][cy][x][y]) ~= 'table' then
		object[cx][cy][x][y] = {}
	end
	object[cx][cy][x][y][#object[cx][cy][x][y] + 1] = object_to_add
	return object_to_add
end

function removeObjectAt(cx,cy,x,y,object_to_remove)
	if type(object[cx][cy][x][y]) == 'table' then
		if object_to_remove then
			for index, current_object in ipairs(object[cx][cy][x][y]) do
				if current_object == object_to_remove then 
					table.remove(object[cx][cy][x][y], index)
					break
				end
			end
		else
			for index, current_object in ipairs(object[cx][cy][x][y]) do
				current_object:destroy()
			end
			object[cx][cy][x][y] = {}
		end
	end
end

function objectFromTypeAt(cx,cy,x,y,obj_type)
	if type(object[cx][cy][x][y]) == 'table' then
		for index,current_object in ipairs(object[cx][cy][x][y]) do
			if (current_object.type and current_object.type == obj_type) or current_object.class.name == obj_type then
				return current_object
			end
		end
	end
	return false
end

function isObjectAt(cx, cy, x, y, object_compared)
	if type(object[cx][cy][x][y]) == 'table' then
		for index,current_object in ipairs(object[cx][cy][x][y]) do
			if current_object == object_compared then
				return current_object
			end
		end
	end
	return false
end

function objectAt(cx,cy,x,y)
	if (type(object[cx][cy][x][y]) == 'table' and next(object[cx][cy][x][y]) == nil) or not object[cx][cy][x][y] then
		return false
	else return true end
end

function genObjects(cx,cy)
	local chunk_x = cx or current_chunk_x
	local chunk_y = cy or current_chunk_y
	
	if object_batch[chunk_x][chunk_y] == nil then 
		object_batch[chunk_x][chunk_y] = love.graphics.newSpriteBatch(object_image, chunk_width*chunk_height)
	end
	object_batch[chunk_x][chunk_y]:clear()	
	for i=0,chunk_width-1,1 do
		for o=0,chunk_height-1,1 do
			local rand = math.random(60)
					if rand == 4 then
					if o == 0 and objectAt(cx,cy-1,i,o-1) then goto continue end
					if o ~= 0 and objectAt(cx,cy,i,o-1) then goto continue end
					local tree = addObjectAt(cx, cy, i, o, Tree:new(cx,cy,i,o, --TODO fix tile_offset/_x
					IsoX + (i - o) * tile_width  * 0.5 - (tile_offset_x[obj] or 38),
					IsoY + (i + o) * tile_height * 0.5 - (tile_offset[obj] or 166),"Pine tree"))
					tree.animation:gotoFrame(math.random(6))
					end 
			if objectAt(cx,cy,i,o) then
				for index, ob in ipairs(object[cx][cy][i][o]) do
					if ob.animated then
						ob.qid = object_batch[chunk_x][chunk_y]:add(ob.animation:getFrameInfo(ob.x,ob.y))
					end
				end
			end
			::continue::
		end
	end
end

function update_objects(cx,cy,deser) 
	prof.push("ST")  
	local chunk_x = cx or current_chunk_x
	local chunk_y = cy or current_chunk_y
	local deser = deser or false
	object_batch[chunk_x][chunk_y] =  object_batch[chunk_x][chunk_y] or love.graphics.newSpriteBatch(object_image, chunk_width*chunk_height)
  	object_batch[chunk_x][chunk_y]:clear() 
	prof.pop("ST")  
	prof.push("LP") 
	for i=0,chunk_width-1,1 do
		for o=0,chunk_height-1,1 do
			local object_index = object[cx][cy][i][o]
			if type(object_index) == 'table' then
				local c = false
				for index, obj in ipairs(object_index) do 
					c = true
					if obj.cx ~= chunk_x or obj.cy ~= chunk_y then
						removeObjectAt(cx,cy,i,o,obj)
						goto continue
					end
					if obj.animated then
						obj.qid = object_batch[chunk_x][chunk_y]
						:add(obj.animation
							:getFrameInfo(
								obj.x+(obj.offset_x or 0) + quad_offset[obj.animation:getQuad()][1],
								obj.y+(obj.offset_y or 0) + quad_offset[obj.animation:getQuad()][2]
							)
						)
					else 
						local offset_x, offset_y = 0, 0
						if quad_offset[obj.tile] then
							offset_x, offset_y = quad_offset[obj.tile][1], quad_offset[obj.tile][2]
						end
						obj.qid = object_batch[chunk_x][chunk_y]
						:add(obj.tile,
							obj.x+(obj.offset_x or 0) + offset_x,
							obj.y+(obj.offset_y or 0) + offset_y)
					end	
					::continue::
				end
				if not c then object[cx][cy][i][o] = nil end
			end
    	end
	end				
	prof.pop("LP")    
	prof.push("FL")  
	object_batch[chunk_x][chunk_y]:flush()
	prof.pop("FL")  
end

local function draw_object()	
	for x = 1, 3 do
		for y = 1, 3 do
			local xx,yy = current_chunk_x+x-2, current_chunk_y+y-2
			if object_batch[xx][yy] ~= nil then
				if xx <= 31 and yy <= 31 and xx >= 0 and yy >= 0 then --FIXME MAGIC NUMBERS
					love.graphics.draw(object_batch[xx][yy], 
						-view_xview*scale_x+(xx*scale_x-yy*scale_x)*chunk_width*tile_width*0.5, 
						-view_yview*scale_x+(xx*scale_x+yy*scale_x)*chunk_height*tile_height*0.5
						, 0, scale_x, scale_y)
				end
			end
		end
	end
	love.graphics.setColor(1,1,1,1)
end


local function mousepressed(x, y, button, istouch)
	local mx, my = x,y
	local vx = mx-width/2
	local vy = (my)-height/2
    LocalX = math.round(ScreenToIsoX(vx/scale_x+view_xview-16, vy/scale_x+view_yview-8 )); 
    LocalY = math.round(ScreenToIsoY(vx/scale_x+view_xview-16, vy/scale_x+view_yview-8 )); 
	    
                local MX, MY = love.mouse.getPosition();  
                MX = (MX - width/2)/scale_x +view_xview - 16
                MY = (MY - height/2)/scale_x +view_yview - 8
                LocalX = math.round(ScreenToIsoX(MX, MY))
                LocalY = math.round(ScreenToIsoY(MX, MY))
		press.gx = LocalX
		press.gy = LocalY
		press.x = (LocalX) % (chunk_width)
		press.y = (LocalY) % (chunk_width)
		press.cx = math.floor(LocalX/chunk_width)
		press.cy = math.floor(LocalY/chunk_width)
		local obj
   	if button == 1 then 
		_G.BuildController:build(press.cx,press.cy,press.x,press.y)
   	elseif button == 2 then
		if not objectAt(press.cx, press.cy, press.x, press.y) then
			if love.keyboard.isDown('m') then			
				obj = addObjectAt(press.cx, press.cy, press.x, press.y,
						Miner:new(press.cx,press.cy,press.x,press.y, --TODO replace magic number with tile_offset/_x
						IsoX + (press.x - press.y) * tile_width  * 0.5 -34,
						IsoY + (press.x + press.y) * tile_height * 0.5 -50+8,"Miner"))					
					obj.qid = object_batch[press.cx][press.cy]					
					:add(obj.animation:getFrameInfo(obj.x, obj.y))
			else
				obj = addObjectAt(press.cx, press.cy, press.x, press.y,  
						Woodcutter:new(press.cx,press.cy,press.x,press.y, --TODO replace magic number with tile_offset/_x
						IsoX + (press.x - press.y) * tile_width  * 0.5 -31,
						IsoY + (press.x + press.y) * tile_height * 0.5 -50,"Woodcutter"))
					obj.qid = object_batch[press.cx][press.cy]
					:add(obj.animation:getFrameInfo(obj.x, obj.y))
				obj = addObjectAt(press.cx, press.cy, press.x, press.y,  
						Woodcutter:new(press.cx,press.cy,press.x,press.y, --TODO replace magic number with tile_offset/_x
						IsoX + (press.x - press.y) * tile_width  * 0.5 -31,
						IsoY + (press.x + press.y) * tile_height * 0.5 -50,"Woodcutter"))
					obj.qid = object_batch[press.cx][press.cy]
					:add(obj.animation:getFrameInfo(obj.x, obj.y))
				obj = addObjectAt(press.cx, press.cy, press.x, press.y,  
						Woodcutter:new(press.cx,press.cy,press.x,press.y, --TODO replace magic number with tile_offset/_x
						IsoX + (press.x - press.y) * tile_width  * 0.5 -31,
						IsoY + (press.x + press.y) * tile_height * 0.5 -50,"Woodcutter"))
					obj.qid = object_batch[press.cx][press.cy]
					:add(obj.animation:getFrameInfo(obj.x, obj.y))
				obj = addObjectAt(press.cx, press.cy, press.x, press.y,  
						Woodcutter:new(press.cx,press.cy,press.x,press.y, --TODO replace magic number with tile_offset/_x
						IsoX + (press.x - press.y) * tile_width  * 0.5 -31,
						IsoY + (press.x + press.y) * tile_height * 0.5 -50,"Woodcutter"))
					obj.qid = object_batch[press.cx][press.cy]
					:add(obj.animation:getFrameInfo(obj.x, obj.y))
			end
		end 
	elseif button == 3 then
		local insp = object[press.cx][press.cy][press.x][press.y]
		if insp then
			print(inspect(insp))
		end
			-- obj = addObjectAt(press.cx, press.cy, press.x, press.y, 
			-- 			Stonemason:new(press.cx,press.cy,press.x,press.y, --TODO replace magic number with tile_offset/_x
			-- 			IsoX + (press.x - press.y) * tile_width  * 0.5 -34,
			-- 			IsoY + (press.x + press.y) * tile_height * 0.5 -50+8,"Stonemason"))
			-- 		obj.qid = object_batch[press.cx][press.cy]					
			-- 		:add(obj.animation:getFrameInfo(obj.x, obj.y))
	end
end 
local previous_count = 0 --note remove this in prod
local upd = 0
local function update()	
	prof.push("CUL")
    if previous_chunk_x ~= current_chunk_x or previous_chunk_y ~= current_chunk_y then 
        chunkUpdateList()
    end
	prof.pop("CUL")
	prof.push("AE")
    previous_chunk_x = current_chunk_x
    previous_chunk_y = current_chunk_y
	

	for index, obj in ipairs(active_entities) do
		obj:animate()
	end
	prof.pop("AE")
	prof.push("UPDATE")
	local l = terrain_chunks
	while l do
		if l.chunkx == nil then break end 
		update_objects(l.chunkx,l.chunky)
		if _G.chunk_objects[l.chunkx][l.chunky] then
			for _,obj in pairs(_G.chunk_objects[l.chunkx][l.chunky]) do
				obj:animate()
			end
		end
		l = l.next 
	end
	prof.pop("UPDATE")
end


local tableOfFunctions = {
                        update = update, 
                        draw = draw_object,
                        chunk = object[press.cx][press.cy], 
                        mousereleased = mousereleased, 
                        mousepressed = mousepressed,
						active = active_objects,
						object = object,
						batch = object_batch,               
                        shadow = shadow_batch,
						update_objects = update_objects,
						addObjectAt = addObjectAt,
						}
return tableOfFunctions














