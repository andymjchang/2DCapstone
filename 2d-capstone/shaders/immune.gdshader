shader_type canvas_item;

uniform float flash_speed : hint_range(0.1, 10.0) = 2.0;
uniform float rainbow_saturation : hint_range(0.0, 1.0) = 0.8;
uniform float rainbow_value : hint_range(0.0, 1.0) = 1.0;
uniform float flash_intensity : hint_range(0.0, 1.0) = 0.5;

// Convert HSV to RGB color space
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
    // Get the original texture color
    vec4 original_color = texture(TEXTURE, UV);
    
    // Calculate rainbow hue based on time
    float hue = fract(TIME * flash_speed);
    
    // Convert HSV to RGB for rainbow effect
    vec3 rainbow = hsv2rgb(vec3(hue, rainbow_saturation, rainbow_value));
    
    // Mix the original color with the rainbow effect
    vec3 final_color = mix(original_color.rgb, rainbow, flash_intensity);
    
    // Preserve the original alpha
    COLOR = vec4(final_color, original_color.a);
}