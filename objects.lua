local object_image= ... 



-- Define start and goal locations coordinates
-- local startx, starty = 1,1
-- local endx, endy = 154,1985

-- -- Calculates the path, and its length
-- local path = myFinder:getPath(startx, starty, endx, endy)

-- if path then
--   write1(('Path found! Length: %.2f'):format(path:getLength()))
-- 	for node, count in path:nodes() do
-- 	  print(('Step: %d - x: %d - y: %d'):format(count,node._x,node._y))
-- 	end
-- else print("Path not found!") end


    --Declarations
	----Library setup
			local bitser = require("libraries.bitser")
			local Grid = require ("libraries.jumper.grid") -- The grid class
			_G.Pathfinder = require ("libraries.jumper.pathfinder") -- The pathfinder class
	----Pathfinding setup
			_G.grid = Grid(_G.collision_map)
			_G.finder = Pathfinder(grid , 'JPS', 0) 
	----Direction and distance
			local previous_distance, location_distance = 0, 0
			local previous_total_chunks_to_traverse = 0
			local previous_dir = 'none'
			local angle 
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
			local first_location = location:new()
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
			local CenterY = math.round(ScreenToIsoY(width/2-16+view_xview,height/2-8+view_yview))
			---------------------------------------
			_G.xchunk = math.floor(CenterX/(chunk_width))
			_G.ychunk = math.floor(CenterY/(chunk_width))
	----Generate spriteBatch
			local object_batch = newAutotable(2)   
			local shadow_batch = newAutotable(2)
			local canvas = love.graphics.newCanvas()  
			object_image:setFilter('nearest','nearest')
	        local tile_quads = require('objects_quads')
			object_batch[0][0] = love.graphics.newSpriteBatch(object_image, chunk_width*chunk_height)
			shadow_batch[0][0] = love.graphics.newSpriteBatch(object_image, chunk_width*chunk_height)		


--- NOTE Object classes START ---
--- NOTE --------------------------
--- NOTE --------------------------
local Object 		= require('objects.Object')
local Tree 		 	= love.filesystem.load('objects/Environment/Tree.lua')(object_batch, active_objects, tile_quads,object)
local Woodcutter 	= love.filesystem.load('objects/Units/Woodcutter.lua')(object,object_batch, active_entities, tile_quads)
local Castle 	= love.filesystem.load('objects/Structures/Castle.lua')(object, tile_quads)
package.loaded['objects.Environment.Tree'],package.loaded['objects.Units.Woodcutter'] = Tree, Woodcutter
package.loaded['objects.Structures.Castle'] = Castle
--- NOTE --------------------------
--- NOTE --------------------------
--- NOTE Object classes END ---


function genObjects(cx,cy)
	local chunk_x = cx or current_chunk_x
	local chunk_y = cy or current_chunk_y
	
	if object_batch[chunk_x][chunk_y] == nil then 
		object_batch[chunk_x][chunk_y] = love.graphics.newSpriteBatch(object_image, chunk_width*chunk_height)
	end
	object_batch[chunk_x][chunk_y]:clear()	
		for i=0,chunk_width-1,1 do
			for o=0,chunk_height-1,1 do
				-- if i == 62 and o == 63 then 
				-- 		object[cx][cy][i][o] = Tree:new(cx,cy,i,o, --TODO fix tile_offset/_x
				-- 		IsoX + (i - o) * tile_width  * 0.5 - (tile_offset_x[object[chunk_x][chunk_y][i][o]] or 38),
				-- 		IsoY + (i + o) * tile_height * 0.5 - (tile_offset[object[chunk_x][chunk_y][i][o]] or 166),"Pine tree")
				-- 		object[cx][cy][i][o].animation:gotoFrame(math.random(6))
				-- end
				local rand = math.random(300)
						if rand == 4 then
						if o == 0 and object[cx][cy-1][i][o-1] and object[cx][cy-1][i][o-1].type == "Pine tree" then goto continue end
						if o ~= 0 and object[cx][cy][i][o-1] and object[cx][cy][i][o-1].type == "Pine tree" then goto continue end
						object[cx][cy][i][o] = Tree:new(cx,cy,i,o, --TODO fix tile_offset/_x
						IsoX + (i - o) * tile_width  * 0.5 - (tile_offset_x[object[chunk_x][chunk_y][i][o]] or 38),
						IsoY + (i + o) * tile_height * 0.5 - (tile_offset[object[chunk_x][chunk_y][i][o]] or 166),"Pine tree")
						object[cx][cy][i][o].animation:gotoFrame(math.random(6))
						end 
						--TODO add shadow gen here	
				if object[cx][cy][i][o] == nil or object[cx][cy][i][o] == 0 then else
					object[cx][cy][i][o].qid = object_batch[chunk_x][chunk_y]:
					add(object[cx][cy][i][o].animation:getFrameInfo(object[cx][cy][i][o].x,object[cx][cy][i][o].y))
				end
				::continue::
			end
		end
end

local function update_objects(cx,cy,deser)
	local chunk_x = cx or current_chunk_x
	local chunk_y = cy or current_chunk_y
	local deser = deser or false

	object_batch[chunk_x][chunk_y] =  object_batch[chunk_x][chunk_y] or love.graphics.newSpriteBatch(object_image, chunk_width*chunk_height)
	--shadow_batch[chunk_x][chunk_y] =  shadow_batch[chunk_x][chunk_y] or love.graphics.newSpriteBatch(object_image, chunk_width*chunk_height)
  	object_batch[chunk_x][chunk_y]:clear() 
  	--shadow_batch[chunk_x][chunk_y]:clear()
  	for i=0,chunk_width-1,1 do
    	for o=0,chunk_height-1,1 do
			if object[chunk_x][chunk_y][i][o] then
				if object[chunk_x][chunk_y][i][o].cx ~= cx or object[chunk_x][chunk_y][i][o].cy ~= cy then
					if object[chunk_x][chunk_y][i][o].marked ~= 2 then
						object[chunk_x][chunk_y][i][o].marked = object[chunk_x][chunk_y][i][o].marked + 1
					else					
						object[chunk_x][chunk_y][i][o].marked = 0
						object[chunk_x][chunk_y][i][o] = nil	
						goto continue
					end
				end
				if object[chunk_x][chunk_y][i][o].type == "Pine tree" or object[chunk_x][chunk_y][i][o].type == "Stump" or object[chunk_x][chunk_y][i][o].type == "Woodcutter" then
					object[chunk_x][chunk_y][i][o].qid = object_batch[chunk_x][chunk_y]
					:add(object[chunk_x][chunk_y][i][o].animation
					:getFrameInfo(object[chunk_x][chunk_y][i][o].x,
								  object[chunk_x][chunk_y][i][o].y))	
				elseif object[chunk_x][chunk_y][i][o].type == "Static structure" then
					object[chunk_x][chunk_y][i][o].qid = object_batch[chunk_x][chunk_y]
					:add(object[chunk_x][chunk_y][i][o].tile,
						object[chunk_x][chunk_y][i][o].x+object[chunk_x][chunk_y][i][o].offset_x,
						object[chunk_x][chunk_y][i][o].y+object[chunk_x][chunk_y][i][o].offset_y)
				end
				::continue:: 	
			end
    	end
  	end				  
 	 object_batch[chunk_x][chunk_y]:flush()
 	 --shadow_batch[chunk_x][chunk_y]:flush()
end

local function draw_object()
	--love.graphics.setCanvas(canvas)
	--love.graphics.clear()
	-- local l1 = terrain_chunks
	-- 	while l1 do
	-- 		if l1.chunkx ~= nil and shadow_batch[l1.chunkx][l1.chunky] ~= nil then  
	-- 			love.graphics.draw(shadow_batch[l1.chunkx][l1.chunky], 
	-- 					-view_xview+(l1.chunkx-l1.chunky)*chunk_width*tile_width*0.5*scale_x, 
	-- 					-view_yview+(l1.chunkx+l1.chunky)*chunk_height*tile_height*0.5*scale_y
	-- 					, 0, scale_x, scale_y)
	-- 		end
	-- 			l1 = l1.next 
	-- 			--TODO sort the linked list first so depth order is right between chunks
	-- 	end
  	--love.graphics.draw(shadow_batch[0][0],    -view_xview, -view_yview, 0, scale_x, scale_y)
	--love.graphics.setCanvas()
    --love.graphics.draw(object_image,tile_quads[building_selection],IsoToScreenX(LocalX,LocalY)-view_xview-(tile_offset_x[building_selection] or 0),IsoToScreenY(LocalX,LocalY)-view_yview-(tile_offset[building_selection] or 0),nil,scale_x)
	
	--love.graphics.setColor(255,255,255,70)
	--love.graphics.draw(canvas,0,0)
	--love.graphics.setColor(255,255,255,255)
	
	for x = 1, 3 do
		for y = 1, 3 do
			local xx,yy = current_chunk_x+x-2, current_chunk_y+y-2
			if object_batch[xx][yy] ~= nil then
				if xx <= 32 and yy <= 32 and xx > 0 and yy > 0 then
					love.graphics.draw(object_batch[xx][yy], 
						-view_xview*scale_x+(xx*scale_x-yy*scale_x)*chunk_width*tile_width*0.5, 
						-view_yview*scale_x+(xx*scale_x+yy*scale_x)*chunk_height*tile_height*0.5
						, 0, scale_x, scale_y)
				end
			end
		end
	end
	-- local l = terrain_chunks
	-- while l do
	-- 		if l.chunkx == nil or object_batch[l.chunkx][l.chunky] == nil then break end
	-- 		if l.chunkx <= 32 and l.chunky <= 32 and l.chunkx > 0 and l.chunky > 0 then
	-- 			love.graphics.draw(object_batch[l.chunkx][l.chunky], 
	-- 					-view_xview+(l.chunkx-l.chunky)*chunk_width*tile_width*0.5*scale_x, 
	-- 					-view_yview+(l.chunkx+l.chunky)*chunk_height*tile_height*0.5*scale_y
	-- 					, 0, scale_x, scale_y)
	-- 		end
	-- 			l = l.next 
	-- end
	love.graphics.setColor(255,255,255,255)
end


local function mousepressed(x, y, button, istouch)
	local mx, my = x,y
    LocalX = math.round(ScreenToIsoX(mx-16+view_xview-width/2, my-8+view_yview-height/2)); 
    LocalY = math.round(ScreenToIsoY(mx-16+view_xview-width/2, my-8+view_yview-height/2)); 
		first_location.gx = LocalX
		first_location.gy = LocalY
		first_location.x = (LocalX) % (chunk_width)
		first_location.y = (LocalY) % (chunk_width)
		first_location.cx = math.floor(LocalX/chunk_width)
		first_location.cy = math.floor(LocalY/chunk_width)
		print("Button", button)
   if button == 1 then 
		--update_objects(first_location.cx,first_location.cy)
		--print("Pressed at",first_location.x,first_location.y,first_location.cx,first_location.cy)
		if not object[first_location.cx][first_location.cy][first_location.x][first_location.y] then
		object[first_location.cx][first_location.cy][first_location.x][first_location.y] = 
			Castle:new(first_location.cx,first_location.cy,first_location.x,first_location.y, 
			IsoX + (first_location.x - first_location.y) * tile_width  * 0.5 - 0,
			IsoY + (first_location.x + first_location.y) * tile_height * 0.5 - 0)
			--update_objects(first_location.cx,first_location.cy) 
		else
		print(object[first_location.cx][first_location.cy][first_location.x][first_location.y]) end
   elseif button == 2 then
	print(object[first_location.cx][first_location.cy][first_location.x][first_location.y])
		--if object[first_location.cx][first_location.cy][first_location.x][first_location.y] ~ then
			-- print("Trying to spawn woodcutter", first_location.x, first_location.y)
			-- object[first_location.cx][first_location.cy][first_location.x][first_location.y] =  
			-- 			Woodcutter:new(first_location.cx,first_location.cy,first_location.x,first_location.y, --TODO fix tile_offset/_x
			-- 			IsoX + (first_location.x - first_location.y) * tile_width  * 0.5 ,
			-- 			IsoY + (first_location.x + first_location.y) * tile_height * 0.5 ,"Woodcutter")
			-- 		object[first_location.cx][first_location.cy][first_location.x][first_location.y].qid = object_batch[first_location.cx][first_location.cy]
			-- 		:add(object[first_location.cx][first_location.cy][first_location.x][first_location.y].animation
			-- 		:getFrameInfo(object[first_location.cx][first_location.cy][first_location.x][first_location.y].x,
			-- 					  object[first_location.cx][first_location.cy][first_location.x][first_location.y].y))
			-- 					  update_objects(first_location.cx,first_location.cy)
		--end 
   end
end 
local previous_count = 0 --note remove this in prod
local upd = 0
local function update()
    if previous_chunk_x ~= current_chunk_x or previous_chunk_y ~= current_chunk_y then 
        chunkUpdateList()
    end
    previous_chunk_x = current_chunk_x
    previous_chunk_y = current_chunk_y
	
	local counter = 0 --note remove this in prod

	for index, obj in ipairs(active_entities) do
		obj:animate()
	end

	if previous_count ~= counter then --note remove this in prod
	print("Amount of animated objects: "..counter) end --note remove this in prod
	previous_count = counter --note remove this in prod
	local l = terrain_chunks
	while l do
		if l.chunkx == nil then break end 
		update_objects(l.chunkx,l.chunky)
		if _G.chunk_objects[l.chunkx][l.chunky] then
			for _,obj in ipairs(_G.chunk_objects[l.chunkx][l.chunky]) do
				obj:animate()
			end
		end
		l = l.next 
	end

	--collectgarbage()
end


--chunkUpdateList()

local tableOfFunctions = {
                        update = update, 
                        draw = draw_object,
                        chunk = object[first_location.cx][first_location.cy], 
                        mousereleased = mousereleased, 
                        mousepressed = mousepressed,
						active = active_objects,
						object = object,
						batch = object_batch,               
                        shadow = shadow_batch,
						update_objects = update_objects,
						}
return tableOfFunctions














