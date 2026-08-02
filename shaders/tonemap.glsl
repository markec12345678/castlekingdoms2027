-- shaders/tonemap.glsl
-- HDR Tone Mapping (ACES Filmic)
-- Stronghold 2027 - Cinematic tone mapping for HDR pipeline

#pragma language glsl3

extern float exposure;    // Exposure adjustment (default 1.0)
extern float gamma;       // Gamma correction (default 2.2)

#ifdef VERTEX
vec4 position(mat4 transform_projection, vec4 vertex_position)
{
    return transform_projection * vertex_position;
}
#endif

#ifdef PIXEL

// ACES Filmic tone mapping curve
vec3 ACESFilm(vec3 x)
{
    float a = 2.51;
    float b = 0.03;
    float c = 2.43;
    float d = 0.59;
    float e = 0.14;
    return clamp((x * (a * x + b)) / (x * (c * x + d) + e), 0.0, 1.0);
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 baseColor = Texel(texture, texture_coords);

    // Apply exposure
    vec3 hdrColor = baseColor.rgb * exposure;

    // Apply ACES tone mapping
    vec3 mapped = ACESFilm(hdrColor);

    // Gamma correction
    mapped = pow(mapped, vec3(1.0 / gamma));

    return vec4(mapped, baseColor.a);
}
#endif
