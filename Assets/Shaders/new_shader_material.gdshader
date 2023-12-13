shader_type canvas_item;

uniform float glow_size : hint_range(0.0, 0.1) = 0.01;

void vertex() {
    // Nothing needed here for a 2D shader.
}

void fragment() {
    vec2 uv = FRAGCOORD.xy / SCREEN_PIXEL_SIZE;

    // Create a glow effect based on distance from the screen borders
    float glow = smoothstep(0.0, glow_size, min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y)));

    // Adjust the glow color and intensity as needed
    COLOR.rgb += vec3(1.0, 0.5, 0.0) * glow;
}
