shader_type canvas_item;

uniform float flash_speed : hint_range(0.1, 10.0) = 2.0;
uniform float damage_flash_speed : hint_range(0.1, 20.0) = 8.0;
uniform float rainbow_saturation : hint_range(0.0, 1.0) = 0.8;
uniform float rainbow_value : hint_range(0.0, 1.0) = 1.0;
uniform float invulnerable_intensity : hint_range(0.0, 1.0) = 0.0;
uniform float damage_intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec4 damage_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);

// Convert HSV to RGB color space
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
    // Get the original texture color
    vec4 original_color = texture(TEXTURE, UV);
    
    // Calculate rainbow effect for invulnerability
    float hue = fract(TIME * flash_speed);
    vec3 rainbow = hsv2rgb(vec3(hue, rainbow_saturation, rainbow_value));
    
    // Calculate damage flash (sin wave for smooth flashing)
    float damage_flash = (sin(TIME * damage_flash_speed) * 0.5 + 0.5);
    
    // Apply invulnerability effect if active
    vec3 color = mix(original_color.rgb, rainbow, invulnerable_intensity);
    
    // Apply damage effect if active, using the flash value
    color = mix(color, damage_color.rgb, damage_intensity * damage_flash);
    
    // Preserve the original alpha
    COLOR = vec4(color, original_color.a);
}