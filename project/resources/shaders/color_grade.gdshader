shader_type canvas_item;

// Color grading post-process shader
// Supports exposure, contrast, saturation, and color tint

uniform float exposure : hint_range(-4.0, 4.0, 0.1) = 0.0;
uniform float contrast : hint_range(0.0, 2.0, 0.01) = 1.0;
uniform float saturation : hint_range(0.0, 2.0, 0.01) = 1.0;
uniform vec4 tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float tint_strength : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float vignette_strength : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float vignette_softness : hint_range(0.0, 1.0, 0.01) = 0.5;

// Rec.709 luminance coefficients
const vec3 LUMINANCE = vec3(0.2126, 0.7152, 0.0722);

void fragment() {
	vec4 color = texture(TEXTURE, UV);

	// Exposure (EV adjustment)
	color.rgb *= pow(2.0, exposure);

	// Contrast (around 18% gray)
	color.rgb = mix(vec3(0.18), color.rgb, contrast);

	// Saturation
	float lum = dot(color.rgb, LUMINANCE);
	color.rgb = mix(vec3(lum), color.rgb, saturation);

	// Color tint
	color.rgb = mix(color.rgb, color.rgb * tint.rgb, tint_strength);

	// Vignette
	if (vignette_strength > 0.0) {
		vec2 uv_centered = UV - 0.5;
		float dist = length(uv_centered);
		float vignette = smoothstep(0.5, 0.5 - vignette_softness, dist);
		color.rgb *= mix(1.0, vignette, vignette_strength);
	}

	COLOR = color;
}
