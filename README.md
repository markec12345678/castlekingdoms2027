## Stone Kingdoms


A real-time strategy game built with LÖVE.


### Under the hood
---

##### Rendering  
> My goal for this project was for it to run at least 30 fps on my PC (GT 720, Core2Duo) and this why I took this approach:  
 
I used spritebatches to reduce the drawcalls from N objects on screen to 2M where M is the amount of chunks drawn. It's 2 because we draw a spritebatch for the terrain, and a spritebatch for the object layer. This caused some issues that were solved in 0.1 and hopefully one last issue #2 in 0.2  
There's also a limitation, in such that for the object layer we can only use one texture atlas. I did some research and found out that 8k x 8k atlas is supported by 90% of steam users so that's what I went with. There's plenty of space left for the other assets that are not yet there.


##### Layers   
> There are two layers - objects and terrain. There used to be a shadow layer but that's postponed until 0.8 because it's only a graphical enhancement.    

   - Terrain - This is the layer that's drawn first right now it only consists of the grass. In the future it will have the water, shores and probably iron and stone resource.  
     It's mostly located in the terrain.lua module (see modules below for their description).  
   - Objects - This is the layer drawn on top of the terrain layer. It holds buildings, trees, units, etc.  
   `selected_object = object[chunk_x][chunk_y][x][y]` holds object selected_object which is in the chunk x,y at chunk_x, chunk_y and in that chunk it's location is x,y. Chunk size is 64x64.  
    
    
##### Units
> Oh boy, this is messy right now. This hopefully should be fixed with #14.  
  
##### Pathfinding  
I'm actually pretty glad with how it turned out. We don't have any more stuff to do with pathfinding ever again (except clearance, but I'll take care of that). Look at the PathController module for more info.  

##### Graphics  
They're in object_texture mostly. I load them as quads in the sprite_quads module.  
I use the library anim8 for animation and it's working pretty great so far.  

### Modules
---

##### main.lua  

Functions:
 - [love.load()](https://love2d.org/wiki/love.load) - Here we register the events for the gamestate (we use [gamestate by hump](http://hump.readthedocs.io/en/latest/gamestate.html)), and we say to the loader(lily) to load the 8k texture atlas in a separate thread, for more info look at [lily](https://love2d.org/wiki/Lily). Once loaded the image, it assigns it to object_image.
 - ui:update(dt) - where dt is delta time and **ui** is a gamestate. We have 2 gamestates for now, **ui** and **game**. Here we check if object_image has *anything* (when you do `if variable` in lua, everything except false and nil will return true) and if it does (it's the image) switch to the **game** gamestate
 - ui:draw() - While in the ui gamestate it will just print Loading assets... (look at ui:draw()).  
 - game:init() - the init method is called only once, even if we switch back to game twice. If you want a callback that triggers everytime you enter a gamestate, :enter() should be used.  
 Notice how I use two functions to load modules - **[require](https://love2d.org/wiki/require)** and **[love.filesystem.load](https://love2d.org/wiki/love.filesystem.load)**. For `objects` I use love.filesystem.load because I need to pass the `object_image` to it (to get it from the module, we do just `local variable_name = ... `). love.filesystem.load basically loads the file but doesn't run it. So now, after loading it becomes a function that's not yet called. That's why we have (object_image) it basically calls the file that we loaded with these parameters. We don't use require because we can't pass arguments with it. But what if we want to use require for the module after wards? Well that's why we populate **`package.loaded['objects.objects'] = objects`** so now when we do `require('objects.objects')` we will get what we need (which is a table of functions and variables in this case. It's important to know that require cannot return multiple values, that's why we put them in a table, but lua functions can easily do `return value1,value2` where value1/2 can be a number, a function, a table (which are always passed by reference), pretty much anything.  
The _G. is the global namespace. Variables by default are global, that's why I put local in front of variables that are not global. _G is not necessary, but it's more readable (you know it's a global variable).  
As you can see we use require for **terrain.lua** because we're not passing anything to it. Require automatically populates **package.loaded**.  
For BuildController at the end we do :new() which creates an instance of the class (it's a singleton) but it's not done properly - new() should be called in the return of BuildController.lua (`return BuildController:new()`), same for JobController.  
 - game:update(dt) - this is the update loop, it's called every frame/step. We use :update for stuff that's objects (: passes self as it's first argument (so _G.BuildController.update(_G.BuildController) would work fine as well, I think))
 - game:draw() - draws on the screen. You can check out the functions [here](https://love2d.org/wiki/love.graphics). I do `love.graphics.translate` to change the coordinate system to the center, this was used to fix a zooming issue where we zoomed out of the top left corner, not the middle. 
 - love.run() - this is pretty much the default function from LOVE, I only removed a timer.sleep(0.001) because we have our own way to limit the fps to 60.







