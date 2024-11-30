#pragma language glsl3
varying vec2 uvoff;
varying vec2 imgdim;
varying float imgshd;
varying float pallete;
extern VolumeImage colortables;

#ifdef VERTEX
attribute vec3 InstancePosition;
attribute vec2 UVOffset;
attribute vec2 ImageDim;
attribute float ImageShade;
attribute vec2 Scale;
attribute float Pallete;
varying vec2 imgscale;

vec4 position(mat4 transform_projection, vec4 vertex_position)
{
    uvoff = UVOffset;
    imgdim = ImageDim;
    imgshd = ImageShade;
    pallete = Pallete;
    imgscale = Scale;
    if (abs(imgscale.x) < 0.0001) {
        imgscale.x = 1.0;
    }
    if (abs(imgscale.y) < 0.0001) {
        imgscale.y = 1.0;
    }
    vertex_position.xy *= ImageDim;
    vertex_position.xy *= imgscale;
    vertex_position.xy += InstancePosition.xy;
    vertex_position.z = 1.0-InstancePosition.z;
	return transform_projection * vertex_position;
}
#endif

#ifdef PIXEL

ivec2 redGreenToPosition(float redValue, float greenValue) {
    int redIndex = int(floor(redValue * 255.0));
    int x = (redIndex / 8) * 10;

    int greenIndex = int(floor(greenValue * 255.0));
    int y = (greenIndex / 8) * 10;

    return ivec2(x, y);
}

vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
{
    color.xyz *= imgshd;
    ivec2 textr = ivec2(int(ceil(uvoff.x + imgdim.x*texture_coords.x)), int(ceil(uvoff.y + imgdim.y*texture_coords.y)));
    vec4 texcolor = texelFetch(tex, textr, 0);
    if (texcolor.a < 1.0) {
        discard;
    }
    if (pallete > 0) {
        vec2 ct = redGreenToPosition(texcolor.x, texcolor.y);
        if (ct.x == 0 && ct.y == 0) {
            return vec4(0,0,0,0);
        }
        return texelFetch(colortables, ivec3(int(ct.x), int(ct.y), int(floor(pallete-1))), 0) * color;
    }
    return texcolor * color;
}
#endif
