love.graphics = {
clear = function () end
,draw = function () end
,flushBatch  = function () end
,newImage  = function () end
,print  = function () end
,printf  = function () end
,newQuad  = function () end
,newSpriteBatch  = function () end
,setDefaultFilter  = function () end
,reset  = function () end
,push  = function () end
,translate  = function () end
,setBackgroundColor  = function () end
,pop  = function () end
,scale  = function () end
,isActive = function () return false end
}
local inspect = require('libraries.inspect')
local getMode = function() end
--table.insert(love, {window = {getMode = function() end}})
love.window = {["getMode"] = getMode}
print(inspect(love))
--love.window.getMode = function () end
