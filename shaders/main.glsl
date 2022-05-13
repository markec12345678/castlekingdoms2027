varying vec2 uvoff;
varying vec2 imgdim;
varying float imgshd;

#ifdef VERTEX
attribute vec2 InstancePosition;
attribute vec2 UVOffset;
attribute vec2 ImageDim;
attribute float ImageShade;
attribute vec2 Scale;
varying vec2 imgscale;

vec4 position(mat4 transform_projection, vec4 vertex_position)
{
    uvoff = UVOffset;
    imgdim = ImageDim;
    imgshd = ImageShade;
    imgscale = Scale;
    if (imgscale.x == 0) {
        imgscale.x = 1.0;
    }
    if (imgscale.y == 0) {
        imgscale.y = 1.0;
    }
    vertex_position.xy *= ImageDim;
    vertex_position.xy *= imgscale;
    vertex_position.xy += InstancePosition;
	return transform_projection * vertex_position;
}
#endif

#ifdef PIXEL
vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
{
    color.xyz *= imgshd;
    texture_coords.x = (uvoff.x + imgdim.x*texture_coords.x)/8192.0;
    texture_coords.y = (uvoff.y + imgdim.y*texture_coords.y)/16384.0;
    vec4 texcolor = Texel(tex, texture_coords);
    return texcolor * color;
}
#endif
