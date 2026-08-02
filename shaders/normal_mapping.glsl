-- shaders/normal_mapping.glsl
-- Normal mapping shader for terrain
-- Stronghold 2027 - HD terrain rendering with dynamic lighting

#pragma language glsl3

extern vec2 screen;
extern Image normalMap;      // Normal map texture
extern vec3 lightDir;        // Directional light direction (normalized)
extern vec3 lightColor;      // Light color (rgb 0-1)
extern float lightIntensity; // Light intensity
extern vec3 ambientColor;    // Ambient light color
extern float ambientIntensity;

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
    vec3 normal = Texel(normalMap, texture_coords).rgb;

    // Convert from 0-1 range to -1 to 1 range
    normal = normalize(normal * 2.0 - 1.0);

    // Ensure normal points up (terrain normals should generally point up)
    if (normal.z < 0.0) normal.z = -normal.z;

    // Normalize light direction
    vec3 light = normalize(lightDir);

    // Diffuse lighting (Lambertian)
    float diffuse = max(dot(normal, light), 0.0);

    // Rim lighting for edge highlights
    vec3 viewDir = vec3(0.0, 0.0, 1.0);
    float rim = 1.0 - max(dot(normal, viewDir), 0.0);
    rim = pow(rim, 3.0) * 0.3;

    // Combine ambient + diffuse + rim
    vec3 ambient = ambientColor * ambientIntensity;
    vec3 diffuseLight = lightColor * diffuse * lightIntensity;
    vec3 rimLight = lightColor * rim;

    vec3 finalColor = baseColor.rgb * (ambient + diffuseLight) + rimLight;

    return vec4(finalColor, baseColor.a);
}
#endif
