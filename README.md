
## Stone Kingdoms


A real-time strategy game built with LÖVE.


### Under the hood
---

##### Rendering  
> My goal for this project was for it to run at least 30 fps on my PC (GT 720, Core2Duo) and this why I took this approach:  
 
I used spritebatches to reduce the drawcalls from N objects on screen to 2M where M is the amount of chunks drawn. It's 2 because we draw a spritebatch for the terrain, and a spritebatch for the object layer. This caused some issues that were solved in 0.1 and hopefully one last issue #1 in 0.2  
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

TODO
     

    