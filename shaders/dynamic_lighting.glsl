-- shaders/dynamic_lighting.glsl
-- Dynamic lighting shader for day/night cycle
-- Stronghold 2027 - enhanced atmospheric effects

#pragma language glsl3

extern vec2 screen;
extern float timeOfDay;       // 0.0 = midnight, 0.5 = noon, 1.0 = midnight
extern float ambientIntensity;
extern vec3 sunColor;
extern vec2 sunPosition;      // Normalized sun position

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

    // Day/night color shift
    vec3 nightTint = vec3(0.4, 0.5, 0.8);   // Cool blue at night
    vec3 dayTint = vec3(1.0, 0.95, 0.85);   // Warm yellow at day
    vec3 sunsetTint = vec3(1.0, 0.6, 0.3);  // Orange at sunset/sunrise

    vec3 lightingTint;
    if (timeOfDay < 0.25) {
        // Night to sunrise
        float t = timeOfDay / 0.25;
        lightingTint = mix(nightTint, sunsetTint, t);
    } elseif (timeOfDay < 0.5) {
        // Sunrise to noon
        float t = (timeOfDay - 0.25) / 0.25;
        lightingTint = mix(sunsetTint, dayTint, t);
    } elseif (timeOfDay < 0.75) {
        // Noon to sunset
        float t = (timeOfDay - 0.5) / 0.25;
        lightingTint = mix(dayTint, sunsetTint, t);
    } else {
        // Sunset to night
        float t = (timeOfDay - 0.75) / 0.25;
        lightingTint = mix(sunsetTint, nightTint, t);
    }

    // Apply lighting
    vec3 result = base.rgb * lightingTint * ambientIntensity;

    // Add subtle sun glow
    vec2 center = vec2(0.5);
    float distFromSun = distance(texture_coords, sunPosition);
    float sunGlow = exp(-distFromSun * 4.0) * 0.3;
    result += sunColor * sunGlow * (1.0 - timeOfDay * 0.5);

    return vec4(result, base.a);
}
#endif
