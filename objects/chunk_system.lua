
local bitser = require("libraries.bitser")
local terrain_table = require('terrain.terrain')
local object_table     = require('objects.objects')
local terrain_batch = terrain_table.batch
local genTerrain = terrain_table.genTerrain
local active_objects = object_table.active
local object 		= object_table.object
local object_batch  = object_table.batch
local shadow_batch  = object_table.shadow
local update_objects = object_table.update
local Tree = require('objects.Environment.Tree')
local object_hashMap = {
	["Tree"] = Tree:new(0,0,0,0,0,0,"")
}

local function objectClean(cx,cy)	
	if true then return end --warning temporarily disabled
	--todo finish up here
	local save = false
	local chunk_ser = {terrain = {},objects = {}}
	chunk_ser.position = {cx,cy}		
	local counter = 1	
	for index, obj in ipairs ( active_objects ) do 
			if obj.cx == cx and obj.cy == cy then 
				chunk_ser.objects[counter] = obj:serialize()
				counter = counter + 1
			end
	end
	--local time = love.timer.getTime()
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
	if save then bitser.dumpLoveFile(filename, chunk_ser) else
	status[cx][cy] = nil end
	--if save then assert(inspect(bitser.loadLoveFile(filename))) end
	--object[cx][cy] = nil
	--object_batch[cx][cy] = nil
	shadow_batch[cx][cy] = nil
end

local function loadObjects(cx, cy, data)
	for _,obj in ipairs(data) do
		local ob = object_hashMap[obj.class]
		ob:deserialize(obj)
	end
end

local function loadChunk(cx,cy)
		status[cx][cy] = 3 
		-- for k,v in pairs(_G.chunk_objects[cx][cy]) do
		-- 	v:activate();
		-- end
		--print("Activating..")
		--update_terrain(cx,cy,chunk_ser.terrain)
		if true then return end --warning temp disabled
		local chunk_ser = bitser.loadLoveFile("chunk-test"..cx.."l"..cy..".bin")
		print("Loading",cx,cy)
		loadObjects(cx,cy,chunk_ser.objects)
		update_objects(cx,cy, true)
end 

local function chunkGarbageCollect()
		--print(terrain[current_chunk_x+2][current_chunk_y-2][1][1])
		objectClean(current_chunk_x+2,current_chunk_y+2)
		objectClean(current_chunk_x+2,current_chunk_y+1)
		objectClean(current_chunk_x+2,current_chunk_y)
		objectClean(current_chunk_x+2,current_chunk_y-1)
		objectClean(current_chunk_x+2,current_chunk_y-2)
		-- terrain[current_chunk_x+2][current_chunk_y-2] = nil 
		-- terrain[current_chunk_x+2][current_chunk_y-1] = nil 
		-- terrain[current_chunk_x+2][current_chunk_y] = nil 
		-- terrain[current_chunk_x+2][current_chunk_y+1] = nil 
		-- terrain[current_chunk_x+2][current_chunk_y+2] = nil 
		-- terrain_batch[current_chunk_x+2][current_chunk_y-2] = nil 
		-- terrain_batch[current_chunk_x+2][current_chunk_y-1] = nil 
		-- terrain_batch[current_chunk_x+2][current_chunk_y] = nil 
		-- terrain_batch[current_chunk_x+2][current_chunk_y+1] = nil 
		-- terrain_batch[current_chunk_x+2][current_chunk_y+2] = nil 
		--status[current_chunk_x+2][current_chunk_y-2] = nil 
		--status[current_chunk_x+2][current_chunk_y-1] = nil 
		--status[current_chunk_x+2][current_chunk_y] = nil 
		--status[current_chunk_x+2][current_chunk_y+1] = nil 
		--status[current_chunk_x+2][current_chunk_y+2] = nil 

		objectClean(current_chunk_x-2,current_chunk_y+2)
		objectClean(current_chunk_x-2,current_chunk_y+1)
		objectClean(current_chunk_x-2,current_chunk_y)
		objectClean(current_chunk_x-2,current_chunk_y-1)
		objectClean(current_chunk_x-2,current_chunk_y-2)		
		-- terrain[current_chunk_x-2][current_chunk_y-2] = nil 
		-- terrain[current_chunk_x-2][current_chunk_y-1] = nil 
		-- terrain[current_chunk_x-2][current_chunk_y] = nil 
		-- terrain[current_chunk_x-2][current_chunk_y+1] = nil 
		-- terrain[current_chunk_x-2][current_chunk_y+2] = nil 
		-- terrain_batch[current_chunk_x-2][current_chunk_y-2] = nil 
		-- terrain_batch[current_chunk_x-2][current_chunk_y-1] = nil 
		-- terrain_batch[current_chunk_x-2][current_chunk_y] = nil 
		-- terrain_batch[current_chunk_x-2][current_chunk_y+1] = nil 
		-- terrain_batch[current_chunk_x-2][current_chunk_y+2] = nil 
		--status[current_chunk_x-2][current_chunk_y-2] = nil 
		--status[current_chunk_x-2][current_chunk_y-1] = nil 
		--status[current_chunk_x-2][current_chunk_y] = nil 
		--status[current_chunk_x-2][current_chunk_y+1] = nil 
		--status[current_chunk_x-2][current_chunk_y+2] = nil 
		
		objectClean(current_chunk_x+1,current_chunk_y-2)
		objectClean(current_chunk_x,current_chunk_y-2)
		objectClean(current_chunk_x-1,current_chunk_y-2)		
		-- terrain[current_chunk_x-1][current_chunk_y-2] = nil 
		-- terrain[current_chunk_x][current_chunk_y-2] = nil 
		-- terrain[current_chunk_x+1][current_chunk_y-2] = nil 
		-- terrain_batch[current_chunk_x-1][current_chunk_y-2] = nil 
		-- terrain_batch[current_chunk_x][current_chunk_y-2] = nil 
		-- terrain_batch[current_chunk_x+1][current_chunk_y-2] = nil 
		--status[current_chunk_x-1][current_chunk_y-2] = nil 
		--status[current_chunk_x][current_chunk_y-2] = nil 
		--status[current_chunk_x+1][current_chunk_y-2] = nil 

		
		objectClean(current_chunk_x+1,current_chunk_y+2)
		objectClean(current_chunk_x,current_chunk_y+2)
		objectClean(current_chunk_x-1,current_chunk_y+2)
		-- terrain[current_chunk_x-1][current_chunk_y+2] = nil 
		-- terrain[current_chunk_x][current_chunk_y+2] = nil 
		-- terrain[current_chunk_x+1][current_chunk_y+2] = nil 
		-- terrain_batch[current_chunk_x-1][current_chunk_y+2] = nil 
		-- terrain_batch[current_chunk_x][current_chunk_y+2] = nil 
		-- terrain_batch[current_chunk_x+1][current_chunk_y+2] = nil 
		--status[current_chunk_x-1][current_chunk_y+2] = nil 
		--status[current_chunk_x][current_chunk_y+2] = nil 
		--status[current_chunk_x+1][current_chunk_y+2] = nil 
		
end

local function chunkUnload(x,y)
	local l = terrain_chunks
	local previous = nil 
	local first = true 
	while l do
		if (l.chunkx == x and l.chunky == y ) then
			l.chunkx = nil
			l.chunky = nil
			l.next = nil
			if first == true then first = false elseif first == false then
				previous.next = l.next  
			end  
		end
	previous = l
	l = l.next
	end
end


local function chunkUpdateList()
	local l = terrain_chunks 	
	while l do
		chunkUnload(l.chunkx,l.chunky)
		l = l.next
	end		

		terrain_chunks = {next = terrain_chunks, chunkx = current_chunk_x+1, chunky = current_chunk_y+0} 
	if status[current_chunk_x+1][current_chunk_y] == nil then 
		--genTerrain(current_chunk_x+1,current_chunk_y) 
		--status[current_chunk_x+1][current_chunk_y] = 1  
	elseif status[current_chunk_x+1][current_chunk_y] == 2 then
		loadChunk(current_chunk_x+1,current_chunk_y)
	end 
	--NOTE --------------------------------------------
		terrain_chunks = {next = terrain_chunks, chunkx = current_chunk_x+1, chunky = current_chunk_y+1}
	if status[current_chunk_x+1][current_chunk_y+1] == nil then 
		--genTerrain(current_chunk_x+1,current_chunk_y+1)
		--status[current_chunk_x+1][current_chunk_y+1] = 1    
	elseif status[current_chunk_x+1][current_chunk_y+1] == 2 then
		loadChunk(current_chunk_x+1,current_chunk_y+1)
	end 
	--NOTE --------------------------------------------
		terrain_chunks = {next = terrain_chunks, chunkx = current_chunk_x+1, chunky = current_chunk_y-1}
	if status[current_chunk_x+1][current_chunk_y-1] == nil then 
		--genTerrain(current_chunk_x+1,current_chunk_y-1)
		--status[current_chunk_x+1][current_chunk_y-1] = 1   
	elseif status[current_chunk_x+1][current_chunk_y-1] == 2 then
		loadChunk(current_chunk_x+1,current_chunk_y-1)
	end 
	--NOTE 2--------------------------------------------
		terrain_chunks = {next = terrain_chunks, chunkx = current_chunk_x, chunky = current_chunk_y+1}
	if status[current_chunk_x][current_chunk_y+1] == nil then 
		--genTerrain(current_chunk_x,current_chunk_y+1)
		--status[current_chunk_x][current_chunk_y+1] = 1    
	elseif status[current_chunk_x][current_chunk_y+1] == 2 then
		loadChunk(current_chunk_x,current_chunk_y+1)
	end 
	--NOTE --------------------------------------------
		terrain_chunks = {next = terrain_chunks, chunkx = current_chunk_x, chunky = current_chunk_y}
	if status[current_chunk_x][current_chunk_y] == nil then 
		--genTerrain(current_chunk_x,current_chunk_y)
		--status[current_chunk_x][current_chunk_y] = 1    
	elseif status[current_chunk_x][current_chunk_y] == 2 then
		loadChunk(current_chunk_x,current_chunk_y)
	end 
	--NOTE --------------------------------------------
		terrain_chunks = {next = terrain_chunks, chunkx = current_chunk_x, chunky = current_chunk_y-1}
	if status[current_chunk_x][current_chunk_y-1] == nil then 
		--genTerrain(current_chunk_x,current_chunk_y-1)
		--status[current_chunk_x][current_chunk_y-1] = 1   
	elseif status[current_chunk_x][current_chunk_y-1] == 2 then
		loadChunk(current_chunk_x,current_chunk_y-1)
	end 
	--NOTE 3--------------------------------------------
		terrain_chunks = {next = terrain_chunks, chunkx = current_chunk_x-1, chunky = current_chunk_y+1}
	if status[current_chunk_x-1][current_chunk_y+1] == nil then 
		--genTerrain(current_chunk_x-1,current_chunk_y+1)
		--status[current_chunk_x-1][current_chunk_y+1] = 1   
	elseif status[current_chunk_x-1][current_chunk_y+1] == 2 then
		loadChunk(current_chunk_x-1,current_chunk_y+1)
	end 
	--NOTE --------------------------------------------
		terrain_chunks = {next = terrain_chunks, chunkx = current_chunk_x-1, chunky = current_chunk_y}
	if status[current_chunk_x-1][current_chunk_y] == nil then 
		--genTerrain(current_chunk_x-1,current_chunk_y)
		--status[current_chunk_x-1][current_chunk_y] = 1   
	elseif status[current_chunk_x-1][current_chunk_y] == 2 then
		loadChunk(current_chunk_x-1,current_chunk_y)
	end 
	--NOTE --------------------------------------------
		terrain_chunks = {next = terrain_chunks, chunkx = current_chunk_x-1, chunky = current_chunk_y-1}
	if status[current_chunk_x-1][current_chunk_y-1] == nil then 
		--genTerrain(current_chunk_x-1,current_chunk_y-1)
		--status[current_chunk_x-1][current_chunk_y-1] = 1   
	elseif status[current_chunk_x-1][current_chunk_y-1] == 2 then
		loadChunk(current_chunk_x-1,current_chunk_y-1)
	end 
end

return chunkUpdateList