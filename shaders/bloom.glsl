-- shaders/bloom.glsl
-- Bloom effect for HD mode - creates glow around bright areas
-- Stronghold 2027 - modern visual enhancement

#pragma language glsl3

extern vec2 screen;
extern float intensity;
extern float threshold;

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

    // Luminance threshold for bloom
    float luminance = dot(base.rgb, vec3(0.299, 0.587, 0.114));

    if (luminance > threshold) {
        // Sample neighboring pixels for blur
        vec2 texelSize = 1.0 / screen;
        vec4 bloom = vec4(0.0);

        // 9-tap gaussian blur
        bloom += Texel(texture, texture_coords + vec2(-1.0, -1.0) * texelSize) * 0.0625;
        bloom += Texel(texture, texture_coords + vec2( 0.0, -1.0) * texelSize) * 0.125;
        bloom += Texel(texture, texture_coords + vec2( 1.0, -1.0) * texelSize) * 0.0625;
        bloom += Texel(texture, texture_coords + vec2(-1.0,  0.0) * texelSize) * 0.125;
        bloom += Texel(texture, texture_coords + vec2( 0.0,  0.0) * texelSize) * 0.25;
        bloom += Texel(texture, texture_coords + vec2( 1.0,  0.0) * texelSize) * 0.125;
        bloom += Texel(texture, texture_coords + vec2(-1.0,  1.0) * texelSize) * 0.0625;
        bloom += Texel(texture, texture_coords + vec2( 0.0,  1.0) * texelSize) * 0.125;
        bloom += Texel(texture, texture_coords + vec2( 1.0,  1.0) * texelSize) * 0.0625;

        // Combine base with bloom
        return vec4(base.rgb + bloom.rgb * intensity, base.a);
    }

    return base;
}
#endif
