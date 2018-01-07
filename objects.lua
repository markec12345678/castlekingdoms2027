local object_image= ... 
local bitser = require("libraries.bitser")

    --Declarations
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
			local active_chunks = {}
			local object = newAutotable(4)
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
local Tree 		 	= love.filesystem.load('objects/Tree.lua')(object_batch, active_objects, tile_quads)
local Woodcutter 	= love.filesystem.load('objects/Woodcutter.lua')(object_batch, active_objects, tile_quads)
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
		for i=1,chunk_width,1 do
			for o=1,chunk_height,1 do
				local rand = math.random(490)
						if rand == 5 then
						object[cx][cy][i][o] = Tree:new(cx,cy,i,o, --TODO fix tile_offset/_x
						IsoX + (i - o) * tile_width  * 0.5 - (tile_offset_x[object[chunk_x][chunk_y][i][o]] or 50),
						IsoY + (i + o) * tile_height * 0.5 - (tile_offset[object[chunk_x][chunk_y][i][o]] or 170),"Pine tree")
						object[cx][cy][i][o].animation:gotoFrame(math.random(6))
						end 
						--TODO add shadow gen here	
				if object[cx][cy][i][o] == nil or object[cx][cy][i][o] == 0 then else
					object[cx][cy][i][o].qid = object_batch[chunk_x][chunk_y]:
					add(object[cx][cy][i][o].animation:getFrameInfo(object[cx][cy][i][o].x,object[cx][cy][i][o].y))
				end
			end
		end
end
function objectClean(cx,cy)	
	--todo finish up here
	write(1)
	local save = false
	local chunk_ser = {terrain = {},objects = {}}
	chunk_ser.position = {cx,cy}			
	-- for index, obj in ipairs ( active_objects ) do 
	-- 		if obj.cx == cx and obj.cy == cy then 
	-- 			table.insert(chunk_ser.objects,obj:ser())
	-- 		end
	-- end
	local time = love.timer.getTime()
	local filename = "chunk-test"..cx.."l"..cy..".bin"
	--if tstatus[cx][cy] ~= nil and tstatus[cx][cy] == 1 then print("Found:"..(bitser.loads(bitser.dumps(terrain[cx][cy])))[60][60]) end
	if status ~= nil then 
		if status[cx][cy] == 1 then 
			chunk_ser.terrain = terrain[cx][cy]
			status[cx][cy] = 2
			--print(chunk_ser.terrain[2][2])
			save = true
		end
	end
	write(2)
	if save then write(3) bitser.dumpLoveFile(filename, chunk_ser) else
	status[cx][cy] = nil end
	--if save then assert(inspect(bitser.loadLoveFile(filename))) end
	object[cx][cy] = nil
	object_batch[cx][cy] = nil
	shadow_batch[cx][cy] = nil
	remove(1)
	remove(2)
	remove(3)
end

local function update_objects(cx,cy)
	local chunk_x = cx or current_chunk_x
	local chunk_y = cy or current_chunk_y

	object_batch[chunk_x][chunk_y] =  object_batch[chunk_x][chunk_y] or love.graphics.newSpriteBatch(object_image, chunk_width*chunk_height)
	--shadow_batch[chunk_x][chunk_y] =  shadow_batch[chunk_x][chunk_y] or love.graphics.newSpriteBatch(object_image, chunk_width*chunk_height)
  	object_batch[chunk_x][chunk_y]:clear() 
  	--shadow_batch[chunk_x][chunk_y]:clear()
  	for i=1,chunk_width,1 do
    	for o=1,chunk_height,1 do
			if object[chunk_x][chunk_y][i][o] ~= nil then
					object[chunk_x][chunk_y][i][o].qid = object_batch[chunk_x][chunk_y]:
					add(object[chunk_x][chunk_y][i][o].animation
					:getFrameInfo(object[chunk_x][chunk_y][i][o].x,
								  object[chunk_x][chunk_y][i][o].y))
			end
    	end
  	end				  
 	 object_batch[chunk_x][chunk_y]:flush()
 	 --shadow_batch[chunk_x][chunk_y]:flush()
end

local function draw_object()
	love.graphics.setCanvas(canvas)
	love.graphics.clear()
	local l1 = terrain_chunks
		while l1 do
			if l1.chunkx ~= nil and shadow_batch[l1.chunkx][l1.chunky] ~= nil then  
				love.graphics.draw(shadow_batch[l1.chunkx][l1.chunky], 
						-view_xview+(l1.chunkx-l1.chunky)*chunk_width*tile_width*0.5*scale_x, 
						-view_yview+(l1.chunkx+l1.chunky)*chunk_height*tile_height*0.5*scale_y
						, 0, scale_x, scale_y)
			end
				l1 = l1.next 
				--TODO sort the linked list first so depth order is right between chunks
		end
  	--love.graphics.draw(shadow_batch[0][0],    -view_xview, -view_yview, 0, scale_x, scale_y)
	love.graphics.setCanvas()
    --love.graphics.draw(object_image,tile_quads[building_selection],IsoToScreenX(LocalX,LocalY)-view_xview-(tile_offset_x[building_selection] or 0),IsoToScreenY(LocalX,LocalY)-view_yview-(tile_offset[building_selection] or 0),nil,scale_x)
	
	love.graphics.setColor(255,255,255,70)
	love.graphics.draw(canvas,0,0)
	love.graphics.setColor(255,255,255,255)
	local l = terrain_chunks
	while l do
			if l.chunkx == nil or object_batch[l.chunkx][l.chunky] == nil then break end
  			love.graphics.draw(object_batch[l.chunkx][l.chunky], 
     				-view_xview+(l.chunkx-l.chunky)*chunk_width*tile_width*0.5*scale_x, 
					-view_yview+(l.chunkx+l.chunky)*chunk_height*tile_height*0.5*scale_y
					, 0, scale_x, scale_y)
			l = l.next 
	end
	love.graphics.setColor(255,255,255,255)
end


local function mousepressed(x, y, button, istouch)
	local mx, my = x,y
		LocalX = math.round(ScreenToIsoX(mx-16+view_xview, my-8+view_yview)) 
		LocalY = math.round(ScreenToIsoY(mx-16+view_xview, my-8+view_yview)) 
		first_location.gx = LocalX
		first_location.gy = LocalY
		first_location.x = LocalX % (chunk_width)
		first_location.y = LocalY % (chunk_width)
		first_location.cx = math.floor(LocalX/chunk_width)
		first_location.cy = math.floor(LocalY/chunk_width)
		print("Button", button)
   if button == 1 then 
		print("Pressed at",first_location.x,first_location.y,object[first_location.cx][first_location.cy][first_location.x][first_location.y] )
		if object[first_location.cx][first_location.cy][first_location.x][first_location.y] ~= nil then
		object[first_location.cx][first_location.cy][first_location.x][first_location.y]:cut() end --todo remove this in prod
   elseif button == 2 then
		--if object[first_location.cx][first_location.cy][first_location.x][first_location.y] ~ then
			print("Trying to spawn woodcutter", first_location.x, first_location.y)
			object[first_location.cx][first_location.cy][first_location.x][first_location.y] =  
						Woodcutter:new(first_location.cx,first_location.cy,first_location.x,first_location.y, --TODO fix tile_offset/_x
						IsoX + (first_location.x - first_location.y) * tile_width  * 0.5 -47,
						IsoY + (first_location.x + first_location.y) * tile_height * 0.5 -77,"Woodcutter")
					object[first_location.cx][first_location.cy][first_location.x][first_location.y].qid = object_batch[first_location.cx][first_location.cy]:
					add(object[first_location.cx][first_location.cy][first_location.x][first_location.y].animation
					:getFrameInfo(object[first_location.cx][first_location.cy][first_location.x][first_location.y].x,
								  object[first_location.cx][first_location.cy][first_location.x][first_location.y].y))
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
	 --fixme update all chunks which need to be updated
	for index, chunk in ipairs ( active_chunks ) do 
		--print("Chunk to update: "..chunk.x.."|"..chunk.y)
		update_objects(chunk.x,chunk.y)
	end

	for index, obj in ipairs ( active_objects ) do 
				counter = counter + 1 --note remove this in prod
				if (obj.cx > current_chunk_x+1) or (obj.cx < current_chunk_x-1)
				or (obj.cy > current_chunk_y+1) or (obj.cy < current_chunk_y-1) or obj.animated == false then
					table.remove(active_objects,index)
				else
					obj:animate()
				end
	end
	if previous_count ~= counter then --note remove this in prod
	print("Amount of animated objects: "..counter) end --note remove this in prod
	previous_count = counter --note remove this in prod
end


--chunkUpdateList()

local tableOfFunctions = {
                        update = update, 
                        draw = draw_object,
                        chunk = object[first_location.cx][first_location.cy], 
                        mousereleased = mousereleased, 
                        mousepressed = mousepressed                        
                        }
return tableOfFunctions, update_objects














