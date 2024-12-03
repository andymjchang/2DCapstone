shader_type canvas_item;

uniform vec4 baseColor : source_color = vec4(0.3058, 0.835, 0.960, 1.0);
uniform float speed : hint_range(0.0, 2.0) = 0.5;
uniform vec4 linesColor : source_color = vec4(0.633, 0.910, 0.556, 1.0);
uniform float linesColorIntensity : hint_range(0.0, 10.0) = 5.0;
uniform sampler2D hologramTexture : hint_default_white;  // Fixed this line
uniform vec2 hologramTextureTiling = vec2(1.0, 5.0);

vec2 tilingAndOffset(vec2 uv, vec2 tiling, vec2 offset) {
    return fract(uv * tiling + offset);
}

void fragment() {
    vec2 offset = vec2(TIME * speed, 0.0);
    vec2 tiling = tilingAndOffset(UV, hologramTextureTiling, offset);
    
    vec4 noise = texture(hologramTexture, tiling);
    vec4 base_texture = texture(TEXTURE, UV);
    
    float fresnel = 0.71;
    vec4 colorLines = linesColor * vec4(vec3(linesColorIntensity), 1.0);
    vec4 emission = colorLines * fresnel * noise;
    
    float alpha = dot(noise.rgb, vec3(1.0));
    
    COLOR.rgb = base_texture.rgb + emission.rgb * baseColor.rgb;
    COLOR.a = base_texture.a * alpha;
}