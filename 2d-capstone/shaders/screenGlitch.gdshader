shader_type canvas_item;

// Base uniforms
uniform float shake_power = 0.03;
uniform float shake_block_size = 30.5;
uniform float fade : hint_range( 0.0, 1.0 ) = 0.01;
// RGB direction vectors
uniform vec2 direction_r = vec2( 1.0, 0.0 );
uniform vec2 direction_g = vec2( 0.4, 1.0 );
uniform vec2 direction_b = vec2( -0.7, -0.3 );
// Edge intensity control
uniform float edge_intensity = 2.0;
uniform float center_fade = 0.0;
// New uniform for edge power curve
uniform float edge_power = 3.0;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

float random( float seed )
{
    return fract( 543.2543 * sin( dot( vec2( seed, seed ), vec2( 3525.46, -54.3415 ) ) ) );
}

float calculate_edge_intensity(vec2 uv) {
    // Calculate distance from center using a circular pattern
    vec2 center_offset = abs(uv - 0.5) * 2.0;
    float dist = length(center_offset);
    
    // Create a dead zone in the center where no effect occurs
    float center_radius = center_fade;
    
    // Create a much steeper curve towards the edges
    float edge_factor = smoothstep(center_radius, 1.0, dist);
    // Apply power curve for stronger edge effect
    edge_factor = pow(edge_factor, edge_power);
    
    // Amplify the edge effect exponentially
    edge_factor *= (1.0 + 5.0 * edge_factor * edge_factor);
    
    // Ensure absolute zero effect in center
    return edge_factor * step(center_radius, dist) * edge_intensity;
}

void fragment()
{
    vec2 fixed_uv = SCREEN_UV;
    
    // Calculate edge intensity for this pixel
    float edge_strength = calculate_edge_intensity(SCREEN_UV);
    
    // Only apply shake effect outside center with increased intensity at edges
    fixed_uv.x += (
        random(
            ( trunc( SCREEN_UV.y * shake_block_size ) / shake_block_size )
        +    TIME
        ) - 0.5
    ) * shake_power * ( fade * 12.0 ) * edge_strength;
    
    // Calculate the aberration offset for each channel
    // Multiply the base fade by a larger factor for stronger edge effect
    float aberration_amount = fade * edge_strength * 3.0;
    
    // If we're in the center zone, just sample directly
    if (edge_strength <= 0.0) {
        COLOR = textureLod(SCREEN_TEXTURE, fixed_uv, 0.0);
    } else {
        // Apply enhanced chromatic aberration with stronger edge intensity
        vec2 r_offset = normalize(direction_r) * aberration_amount;
        vec2 g_offset = normalize(direction_g) * aberration_amount;
        vec2 b_offset = normalize(direction_b) * aberration_amount;
        
        COLOR = vec4(
            textureLod(SCREEN_TEXTURE, fixed_uv + r_offset, 0.0).r,
            textureLod(SCREEN_TEXTURE, fixed_uv + g_offset, 0.0).g,
            textureLod(SCREEN_TEXTURE, fixed_uv + b_offset, 0.0).b,
            1.0
        );
        
        // Apply additional intensity scaling at the edges
        float edge_fade = 1.0 - (fade * edge_strength * 0.5);
        COLOR.rgb *= edge_fade;
    }
}