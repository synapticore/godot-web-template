shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// Synaptic node - smaller orbiting spheres
// Connected to core via energy streams

uniform vec4 node_color : source_color = vec4(0.4, 0.75, 1.0, 1.0);
uniform float pulse_speed : hint_range(0.1, 5.0) = 2.0;
uniform float pulse_offset : hint_range(0.0, 6.28) = 0.0;
uniform float emission_strength : hint_range(0.5, 4.0) = 1.5;
uniform float fresnel_power : hint_range(1.0, 5.0) = 3.0;

void fragment() {
	// Fresnel rim
	float fresnel = pow(1.0 - dot(NORMAL, VIEW), fresnel_power);

	// Pulse with offset for variety
	float pulse = sin(TIME * pulse_speed + pulse_offset) * 0.5 + 0.5;

	ALBEDO = node_color.rgb * 0.2;
	METALLIC = 0.3;
	ROUGHNESS = 0.5;

	// Glowing emission
	float emit = emission_strength * (0.8 + pulse * 0.4 + fresnel * 0.8);
	EMISSION = node_color.rgb * emit;
}
