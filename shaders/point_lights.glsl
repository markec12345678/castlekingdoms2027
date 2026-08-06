-- shaders/point_lights.glsl
-- Dynamic point light shader
-- Stronghold 2027 - Real-time point lights for torches, fires, etc.

#pragma language glsl3

extern vec2 screen;
extern vec3 lightPositions[32];    // World-space light positions (x, y, radius)
extern vec3 lightColors[32];       // Light colors (r, g, b)
extern float lightIntensities[32]; // Per-light intensity
extern int lightCount;
extern vec2 viewOffset;            // Camera offset
extern float zoom;                 // Camera zoom

#ifdef VERTEX
vec4 position(mat4 transform_projection, vec4 vertex_position)
{
    return transform_projection * vertex_position;
}
#endif

#ifdef PIXEL
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 baseColor = Texel(texture, texture_coords);

    if (lightCount == 0) return baseColor;

    vec3 finalLight = vec3(0.0);

    // World position of this pixel
    vec2 worldPos = (screen_coords / screen - 0.5) / zoom + viewOffset;

    for (int i = 0; i < 32; i++) {
        if (i >= lightCount) break;

        vec3 lightPos = lightPositions[i];
        vec3 lightColor = lightColors[i];
        float intensity = lightIntensities[i];

        // Distance from pixel to light
        float dist = distance(worldPos, lightPos.xy);
        float radius = lightPos.z;

        if (dist < radius) {
            // Attenuation (inverse square with smooth falloff)
            float atten = 1.0 - (dist / radius);
            atten = atten * atten;  // Quadratic falloff

            // Add light contribution
            finalLight += lightColor * intensity * atten;
        }
    }

    // Add flicker noise for fire lights (subtle)
    float flickerNoise = fract(sin(dot(screen_coords, vec2(12.9898, 78.233))) * 43758.5453);
    finalLight *= (0.95 + flickerNoise * 0.1);

    // Combine base color with lights (additive)
    vec3 result = baseColor.rgb + finalLight * baseColor.rgb * 0.8 + finalLight * 0.2;

    return vec4(result, baseColor.a);
}
#endif
