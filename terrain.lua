
local first_location_x, first_location_y, last_location_x, last_location_y = 0 
local location_distance = 0 
local angle, first = 0, 0  
local ffi = require('ffi')


	--Terrain Initialize
	----Rows and columns
            local cols = chunk_width 
            local rows = chunk_height 
	----Chunk 2D array
			-- Statuses: 
			-- [1] loaded unsaved
			-- [2] unloaded - chunk exist on hard disk
			-- [3] loaded saved - chunk hasn't been changed so no need to save it
			-- nil - chunk needs to be generated first
			
	----Generate spriteBatch
	        local terrain_image = love.graphics.newImage( "assets/tiles/image_strip.png" ) 
			terrain_image:setFilter('nearest','nearest')
	        local tile_quads = {} 
			local tile_offset = {} 
			local imageW,imageH = terrain_image:getWidth(), terrain_image:getHeight() 
	        tile_quads[1] = love.graphics.newQuad(724, 1850, 29, 20, imageW,imageH)
			tile_offset[1] = 5
			tile_offset[2] = 5
			tile_offset[3] = 5
			tile_offset[4] = 5
			tile_offset[5] = 5
			tile_offset[6] = 0
			tile_offset[7] = 0
			tile_offset[8] = 0
			tile_offset[9] = 0
			tile_offset[10] = 0
			tile_quads[2] = love.graphics.newQuad(724+30+2, 1850, 30, 20, imageW,imageH)
			tile_quads[3] = love.graphics.newQuad(724+30*2+2*2, 1850, 30, 20, imageW,imageH)
			tile_quads[4] = love.graphics.newQuad(724+30*3+2*3, 1850, 30, 20, imageW,imageH)
			tile_quads[5] = love.graphics.newQuad(724+30*4+2*4, 1850, 30, 20, imageW,imageH)
			-- tile_quads[6] = love.graphics.newQuad(724, 1891, 30, 16, imageW,imageH)
			-- tile_quads[7] = love.graphics.newQuad(724+30+2, 1891, 30, 16, imageW,imageH)
			-- tile_quads[8] = love.graphics.newQuad(724+30*2+2*2, 1891, 30, 16, imageW,imageH)
			-- tile_quads[9] = love.graphics.newQuad(724+30*3+2*4, 1891, 30, 16, imageW,imageH)
			-- tile_quads[10] = love.graphics.newQuad(724+30*3+2*4, 1891, 30, 16, imageW,imageH)
			tile_quads[11] = love.graphics.newQuad(420, 1850, 30, 107, imageW,imageH)
			tile_offset[11] = 107-16
			tile_quads[12] = love.graphics.newQuad(450, 1850, 30, 107, imageW,imageH)
			tile_offset[12] = 107-16
			tile_quads[6] = love.graphics.newQuad(724, 1909, 30, 16, imageW,imageH)
			tile_quads[7] = love.graphics.newQuad(724+30+2, 1909, 30, 16, imageW,imageH)
			tile_quads[8] = love.graphics.newQuad(724+30*2+2*2, 1909, 30, 16, imageW,imageH)
			tile_quads[9] = love.graphics.newQuad(724+30*3+2*4, 1909, 30, 16, imageW,imageH)
			tile_quads[10] = love.graphics.newQuad(724+30*3+2*4, 1909, 30, 16, imageW,imageH)
			local terrain_batch = newAutotable(2) 
			terrain_batch[0][0] = love.graphics.newSpriteBatch(terrain_image, chunk_width*chunk_height)
			
			
			
function getTerrainChunk()
	return chunk or {} 
end

function getLocationDistance()
	return location_distance or 0 
end

-- NOTE -- deprecated
function update_terrain(chunk_x,chunk_y,opdata)
	opdata = opdata or print("-----This shouldn't happen")
	chunk_x = chunk_x or current_chunk_x 
	chunk_y = chunk_y or current_chunk_y 
	--genObjects(cx,cy) --TODO load objects, don't gen them
	if terrain_batch[chunk_x][chunk_y] == nil then 
		terrain_batch[chunk_x][chunk_y] = love.graphics.newSpriteBatch(terrain_image, chunk_width*chunk_height)
	end
	terrain_batch[chunk_x][chunk_y]:clear()  
	for i=1,chunk_width,1 do
		for o=1,chunk_width,1 do
		terrain_batch[chunk_x][chunk_y]:add(
							tile_quads[opdata[i][o]], 
							IsoX + (i - o) * tile_width  * 0.5,
							IsoY + (i + o) * tile_height * 0.5 - (tile_offset[opdata[i][o]] or 0)
							) 
		end
	end				  
end

local function genTerrain(cx,cy)
	local chunk_x = cx or current_chunk_x 
	local chunk_y = cy or current_chunk_y 
	genObjects(cx,cy)  --TODO OPTIMIZE: move genObjects in this loop so we don't loop twice!
	if terrain_batch[chunk_x][chunk_y] == nil then 
		terrain_batch[chunk_x][chunk_y] = love.graphics.newSpriteBatch(terrain_image, chunk_width*chunk_height)
	end

	terrain_batch[chunk_x][chunk_y]:clear() 
	terrain[cx][cy] = ffi.new("unsigned char[64][64]", {})
		for i=0,chunk_width-1,1 do
			for o=0,chunk_height-1,1 do
				if i == chunk_width-1 or o == chunk_width-1 then 
				else
				local rand = math.random(8)  --FIXME tile 9 or 10 is not correct size
				terrain[cx][cy][i][o]=rand 	
				terrain_batch[chunk_x][chunk_y]:add(
									tile_quads[rand], 
									IsoX + (i - o) * tile_width  * 0.5,
									IsoY + (i + o) * tile_height * 0.5 - (tile_offset[terrain[chunk_x][chunk_y][i][o]] or 0)
									,0,1.07,1) 
				end
			end
		end
end

local function chunkDraw() 
	for x = 1, 3 do
		for y = 1, 3 do
			local xx,yy = current_chunk_x+x-2, current_chunk_y+y-2
			if terrain_batch[xx][yy] ~= nil then
				if xx <= 32 and yy <= 32 and xx > 0 and yy > 0 then
					love.graphics.draw(terrain_batch[xx][yy], 
						-view_xview*scale_x+(xx*scale_x-yy*scale_x)*chunk_width*tile_width*0.5, 
						-view_yview*scale_x+(xx*scale_x+yy*scale_x)*chunk_height*tile_height*0.5
						, 0, scale_x, scale_y)
				end
			end
		end
	end
	-- local l = _G.terrain_chunks
	-- while l do
	-- 		if l.chunkx == nil or terrain_batch[l.chunkx][l.chunky] == nil then break end 
	-- 		if l.chunkx <= 32 and l.chunky <= 32 and l.chunkx > 0 and l.chunky > 0 then
	-- 			love.graphics.draw(terrain_batch[l.chunkx][l.chunky], 
	-- 					-view_xview+(l.chunkx-l.chunky)*chunk_width*tile_width*0.5*scale_x, 
	-- 					-view_yview+(l.chunkx+l.chunky)*chunk_height*tile_height*0.5*scale_y
	-- 					, 0, scale_x, scale_y)
	-- 		end 
	-- 		l = l.next 
	-- end
end 


for i = 1, 32 do
 for o = 1, 32 do
	genTerrain(i,o)
	_G.status[i][o] = 2
 end
end

	

local tableOfFunctions = { 
	update_terrain= update_terrain, 
	draw = chunkDraw,
	chunk = chunk, 
	mousepressed = function() end, 
	batch = terrain_batch,
	genTerrain = genTerrain,
	}
return tableOfFunctions














