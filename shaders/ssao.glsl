-- shaders/ssao.glsl
-- Screen-Space Ambient Occlusion
-- Stronghold 2027 - Adds depth and realism to terrain and buildings

#pragma language glsl3

extern vec2 screen;
extern float radius;        // SSAO sample radius
extern float intensity;     // SSAO intensity
extern float bias;          // Bias to prevent self-occlusion

#ifdef VERTEX
vec4 position(mat4 transform_projection, vec4 vertex_position)
{
    return transform_projection * vertex_position;
}
#endif

#ifdef PIXEL

// Simple hash for random sampling
vec2 hash2(vec2 p)
{
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return fract(sin(p) * 43758.5453);
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 baseColor = Texel(texture, texture_coords);

    // Simple SSAO approximation using luminance variation
    vec2 texelSize = 1.0 / screen;

    // Sample 16 points in a kernel
    float occlusion = 0.0;
    float totalWeight = 0.0;

    for (int x = -2; x <= 2; x++) {
        for (int y = -2; y <= 2; y++) {
            if (x == 0 && y == 0) continue;

            vec2 offset = vec2(float(x), float(y)) * texelSize * radius;
            vec4 neighbor = Texel(texture, texture_coords + offset);

            // Use luminance as proxy for depth (brighter = closer)
            float centerLum = dot(baseColor.rgb, vec3(0.299, 0.587, 0.114));
            float neighborLum = dot(neighbor.rgb, vec3(0.299, 0.587, 0.114));

            float diff = neighborLum - centerLum - bias;
            float weight = 1.0 - abs(float(x + y)) / 4.0;
            occlusion += max(0.0, diff) * weight;
            totalWeight += weight;
        }
    }

    occlusion = 1.0 - (occlusion / max(totalWeight, 1.0)) * intensity;

    return vec4(baseColor.rgb * occlusion, baseColor.a);
}
#endif
