shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// Synapticore Central Core - Pulsing energy sphere
// Creates a glowing neural core effect

uniform vec4 core_color : source_color = vec4(0.2, 0.6, 1.0, 1.0);
uniform vec4 pulse_color : source_color = vec4(0.4, 0.8, 1.0, 1.0);
uniform float pulse_speed : hint_range(0.1, 5.0) = 1.5;
uniform float pulse_intensity : hint_range(0.0, 3.0) = 1.0;
uniform float fresnel_power : hint_range(0.5, 5.0) = 2.0;
uniform float base_emission : hint_range(0.0, 5.0) = 2.0;

void fragment() {
	// Fresnel effect for edge glow
	float fresnel = pow(1.0 - dot(NORMAL, VIEW), fresnel_power);

	// Pulsing animation
	float pulse = sin(TIME * pulse_speed) * 0.5 + 0.5;
	float pulse2 = sin(TIME * pulse_speed * 1.7 + 1.0) * 0.5 + 0.5;

	// Combine pulses for organic feel
	float combined_pulse = mix(pulse, pulse2, 0.3);

	// Core color with pulse
	vec3 color = mix(core_color.rgb, pulse_color.rgb, combined_pulse * 0.4);

	ALBEDO = color * 0.3;
	METALLIC = 0.0;
	ROUGHNESS = 0.8;

	// Emission with fresnel edge glow and pulse
	float emission_strength = base_emission + fresnel * 2.0 + combined_pulse * pulse_intensity;
	EMISSION = color * emission_strength;
}
