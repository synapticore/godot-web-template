shader_type canvas_item;

// Animated gradient background
// Perfect for menus and showcases

uniform vec4 color_top : source_color = vec4(0.1, 0.1, 0.15, 1.0);
uniform vec4 color_bottom : source_color = vec4(0.05, 0.05, 0.08, 1.0);
uniform float angle : hint_range(-180.0, 180.0, 1.0) = 0.0;
uniform float noise_strength : hint_range(0.0, 0.1, 0.001) = 0.02;
uniform float animation_speed : hint_range(0.0, 2.0, 0.1) = 0.5;

// Simple noise function
float random(vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	// Rotate UV for angled gradient
	float rad = radians(angle);
	vec2 center = vec2(0.5);
	vec2 uv_rotated = UV - center;
	uv_rotated = vec2(
		uv_rotated.x * cos(rad) - uv_rotated.y * sin(rad),
		uv_rotated.x * sin(rad) + uv_rotated.y * cos(rad)
	);
	uv_rotated += center;

	// Animated gradient position
	float t = uv_rotated.y + sin(TIME * animation_speed) * 0.05;

	// Mix colors
	vec4 color = mix(color_bottom, color_top, t);

	// Add subtle noise/grain
	float noise = (random(UV + TIME * 0.1) - 0.5) * noise_strength;
	color.rgb += noise;

	COLOR = color;
}
