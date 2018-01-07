-- function isPositionOpenfunc(x, y)
-- 		local xx = x % (chunk_width);
-- 		local yy = y % (chunk_width);
-- 		local cx = math.floor(x/chunk_width);
-- 		local cy = math.floor(y/chunk_width);
-- 		if object[cx][cy][xx][yy] == nil then
--     return true else return false; end
-- end

-- local location = {
-- 	gx = 0,
-- 	gy = 0,
-- 	x = 0,
-- 	y = 0,
-- 	cx = 0, 
-- 	cy = 0
-- }
-- function location:new (o)
-- 	o = o or {}  
-- 	setmetatable(o, self)
-- 	self.__index = self
-- 	return o
-- end
--TODO remove or find a use later, not needed for now
--local first_location = location:new()
--local last_location = location:new()

-- First, set a collision map
local map = {
	{0,1,0,1,0},
	{0,1,0,1,0},
	{0,1,1,1,0},
	{0,0,0,0,0},
}
-- Value for walkable tiles
local walkable = 0

-- Library setup
local Grid = require ("jumper.grid") -- The grid class
local Pathfinder = require ("jumper.pathfinder") -- The pathfinder lass

-- Creates a grid object
local grid = Grid(map) 
-- Creates a pathfinder object using Jump Point Search
local myFinder = Pathfinder(grid, 'JPS', walkable) 

-- Define start and goal locations coordinates
local startx, starty = 1,1
local endx, endy = 5,1

-- Calculates the path, and its length
local path = myFinder:getPath(startx, starty, endx, endy)
if path then
  print(('Path found! Length: %.2f'):format(path:getLength()))
	for node, count in path:nodes() do
	  print(('Step: %d - x: %d - y: %d'):format(count, node:getX(), node:getY()))
	end
end























--pathfinder ^^
local anim8 = require 'anim8'

local img = love.graphics.newImage('spritesheet.png')
img:setFilter('nearest')

local w,h = img:getDimensions()

local g = anim8.newGrid(16, 29, w, h, 0,0, 1)

local a1 = anim8.newAnimation(g('1-3',1, 2, 1), 0.1)
local a2 = a1:clone():flipH()
local a3 = a1:clone():flipV()
local a4 = a1:clone():flipH():flipV()

local kx, ky = 0,0

local batch = love.graphics.newSpriteBatch(img)
--etFrameInfo(x,y, r, sx, sy, ox, oy, kx, ky)
local id1 = batch:add(a1:getFrameInfo(200,100,0,4,4,0,0,kx,ky))
local id2 = batch:add(a1:getFrameInfo(500,100,0,4,4,0,0,kx,ky))
local id3 = batch:add(a1:getFrameInfo(200,300,0,4,4,0,0,kx,ky))
local id4 = batch:add(a1:getFrameInfo(500,300,0,4,4,0,0,kx,ky))

function love.draw()
  love.graphics.draw(batch, 0, 0)
  love.graphics.rectangle('line', 200,100, 16*4,29*4)
  love.graphics.rectangle('line', 500,100, 16*4,29*4)
  love.graphics.rectangle('line', 200,300, 16*4,29*4)
  love.graphics.rectangle('line', 500,300, 16*4,29*4)
  love.graphics.print(("kx=%f, ky=%f"):format(kx,ky), 20,20)
end

function love.update(dt)
  a1:update(dt)
  a2:update(dt)
  a3:update(dt)
  a4:update(dt)

  batch:set(id1, a1:getFrameInfo(200,100,0,4,4,0,0,kx,ky))
  batch:set(id2, a2:getFrameInfo(500,100,0,4,4,0,0,kx,ky))
  batch:set(id3, a3:getFrameInfo(200,300,0,4,4,0,0,kx,ky))
  batch:set(id4, a4:getFrameInfo(500,300,0,4,4,0,0,kx,ky))

  if love.keyboard.isDown('up')    then ky = ky - dt end
  if love.keyboard.isDown('down')  then ky = ky + dt end
  if love.keyboard.isDown('right') then kx = kx + dt end
  if love.keyboard.isDown('left')  then kx = kx - dt end
end

function love.keypressed(key)
  if key == 'escape' then love.event.quit() end
end
-------------------------------
local anim8 = require 'anim8'

function love.load()
  image = love.graphics.newImage('media/1945.png')

                         -- frame, image,    offsets, border
  local g32 = anim8.newGrid(32,32, 1024,768,   3,3,     1)

  spinning = {
                     -- type    -- frames                   --default delay
    anim8.newAnimation(g32('1-8',1),              0.1),
    anim8.newAnimation(g32(18,'8-11', 18,'10-7'), 0.2),
    anim8.newAnimation(g32('1-8',2),              0.3),
    anim8.newAnimation(g32(19,'8-11', 19,'10-7'), 0.4),
    anim8.newAnimation(g32('1-8',3),              0.5),
    anim8.newAnimation(g32(20,'8-11', 20,'10-7'), 0.6),
    anim8.newAnimation(g32('1-8',4),              0.7),
    anim8.newAnimation(g32(21,'8-11', 21,'10-7'), 0.8),
    anim8.newAnimation(g32('1-8',5),              0.9)
  }

                         -- frame, image,    offsets, border
  local g64 = anim8.newGrid(64,64, 1024,768,  299,101,   2)

  plane    = anim8.newAnimation(g64(1,'1-3'), 0.1)
  seaplane = anim8.newAnimation(g64('2-4',3), 0.1)
  seaplaneAngle = 0

                         -- frame, image,    offsets, border
  local gs = anim8.newGrid(32,98, 1024,768,  366,102,   1)

                                 -- type,  -- frames, d. delay, individual frame delays
  submarine = anim8.newAnimation(gs('1-7',1, '6-2',1), {2,['2-6']=0.1, [7]=1, ['8-12']=0.1})

end

function love.draw()
  for i=1,#spinning do
    spinning[i]:draw(image, i*75, i*50)
  end
  plane:draw(   image, 100, 400)
  seaplane:draw(image, 250, 432, seaplaneAngle, 1, 1, 32, 32)
  submarine:draw(image, 600, 100)
end

function love.update(dt)
  for i=1,#spinning do
    spinning[i]:update(dt)
  end
  plane:update(dt)
  seaplane:update(dt)
  submarine:update(dt)

  seaplaneAngle = seaplaneAngle + dt
end

function love.keypressed(key)
  if key == 'escape' then love.event.quit() end

  for i=1, #spinning do
    spinning[i]:flipH()
  end

  plane:flipV()
  seaplane:flipV(dt)
  submarine:flipV(dt)
end
--------------------
local object = {
    x = 0,
    y = 0,
    quad = 0,
    type = 'Pine tree',
    health = 100,
    animation = {}
}
function animate()
    
end
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


local menu = {} -- previously: Gamestate.new()
local game = {}

function menu:draw()
    love.graphics.print("Press Enter to continue", 10, 10)
end

function menu:keyreleased(key, code)
    if key == 'return' then
        Gamestate.switch(game)
    end
end

function game:enter()
    Entities.clear()
    -- setup entities here
end

function game:update(dt)
    Entities.update(dt)
end

function game:draw()
    Entities.draw()
end

function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(menu)
end