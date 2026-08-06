-- shaders/color_grading.glsl
-- Color grading shader for cinematic look
-- Applies warm medieval tone with enhanced contrast

#pragma language glsl3

extern vec3 shadows;
extern vec3 midtones;
extern vec3 highlights;
extern float saturation;
extern float contrast;
extern float brightness;

#ifdef VERTEX
vec4 position(mat4 transform_projection, vec4 vertex_position)
{
    return transform_projection * vertex_position;
}
#endif

#ifdef PIXEL
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 base = Texel(texture, texture_coords);

    // Convert to luminance
    float lum = dot(base.rgb, vec3(0.299, 0.587, 0.114));

    // Apply color grading based on luminance
    vec3 graded;
    if (lum < 0.5) {
        graded = mix(base.rgb * shadows, base.rgb * midtones, lum * 2.0);
    } else {
        graded = mix(base.rgb * midtones, base.rgb * highlights, (lum - 0.5) * 2.0);
    }

    // Apply contrast
    graded = (graded - 0.5) * contrast + 0.5;

    // Apply brightness
    graded += brightness;

    // Apply saturation
    float gray = dot(graded, vec3(0.299, 0.587, 0.114));
    graded = mix(vec3(gray), graded, saturation);

    return vec4(graded, base.a);
}
#endif
