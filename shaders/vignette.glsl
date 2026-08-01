-- shaders/vignette.glsl
-- Subtle vignette effect for cinematic feel
-- Darkens edges of screen to draw focus to center

#pragma language glsl3

extern vec2 screen;
extern float intensity;
extern float radius;

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

    // Calculate distance from center (normalized 0-1)
    vec2 center = vec2(0.5);
    vec2 uv = texture_coords;
    float dist = distance(uv, center);

    // Smooth vignette falloff
    float vignette = smoothstep(radius, radius - 0.3, dist);

    // Apply vignette
    vec3 result = base.rgb * mix(1.0 - intensity, 1.0, vignette);

    return vec4(result, base.a);
}
#endif
