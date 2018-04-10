love.graphics = {
clear = function () end
,draw = function () end
,flushBatch  = function () end
,newImage  = function ()
    return {
        setFilter = function () end,
        getWidth = function () end,
        getHeight = function () end,
    }
end
,print  = function () end
,printf  = function () end
,newQuad  = function () end
,newSpriteBatch  = function () 
    return {
        add = function (a,b,c,d,e,f) end,
        attachAttribute = function (a,b,c,d,e,f) end,
        clear = function (a,b,c,d,e,f) end,
        flush = function (a,b,c,d,e,f) end,
        getBufferSize = function (a,b,c,d,e,f) end,
        getCount = function (a,b,c,d,e,f) end,
        getImage = function (a,b,c,d,e,f) end,
        getTexture = function (a,b,c,d,e,f) end,
        set = function (a,b,c,d,e,f) end,
        setColor = function (a,b,c,d,e,f) end,
        setImage = function (a,b,c,d,e,f) end,
        setTexture = function (a,b,c,d,e,f) end,
        }
end
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
--love.window.getMode = function () end
