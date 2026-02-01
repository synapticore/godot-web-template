shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_disabled, unshaded;

// Energy stream connecting to central core
// Creates flowing energy/synapse effect

uniform vec4 stream_color : source_color = vec4(0.3, 0.7, 1.0, 1.0);
uniform float flow_speed : hint_range(0.1, 5.0) = 2.0;
uniform float glow_intensity : hint_range(0.1, 5.0) = 1.5;
uniform float fade_power : hint_range(0.5, 4.0) = 2.0;

void fragment() {
	// UV-based flow animation
	float flow = fract(UV.y - TIME * flow_speed);

	// Create pulse packets along the stream
	float packet = smoothstep(0.0, 0.3, flow) * smoothstep(0.6, 0.3, flow);

	// Edge fade for cylindrical look
	float edge = 1.0 - abs(UV.x - 0.5) * 2.0;
	edge = pow(edge, fade_power);

	// Combine for final alpha
	float alpha = packet * edge * glow_intensity;

	ALBEDO = stream_color.rgb * alpha;
	ALPHA = alpha * stream_color.a;
}
