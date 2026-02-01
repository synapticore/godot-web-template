shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// Studio PBR material with customizable parameters
// Designed for showcase demos

group_uniforms Albedo;
uniform vec4 albedo : source_color = vec4(1.0);
uniform sampler2D albedo_texture : source_color, filter_linear_mipmap, repeat_enable;

group_uniforms Metallic;
uniform float metallic : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float metallic_specular : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform sampler2D metallic_texture : hint_default_white, filter_linear_mipmap, repeat_enable;

group_uniforms Roughness;
uniform float roughness : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform sampler2D roughness_texture : hint_roughness_r, filter_linear_mipmap, repeat_enable;

group_uniforms Normal;
uniform float normal_strength : hint_range(-2.0, 2.0, 0.01) = 1.0;
uniform sampler2D normal_texture : hint_roughness_normal, filter_linear_mipmap, repeat_enable;

group_uniforms Emission;
uniform vec4 emission_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float emission_strength : hint_range(0.0, 16.0, 0.1) = 0.0;

group_uniforms Effects;
uniform float fresnel_power : hint_range(0.0, 8.0, 0.1) = 5.0;
uniform float fresnel_strength : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform vec4 fresnel_color : source_color = vec4(1.0);

void fragment() {
	// Albedo
	vec4 albedo_tex = texture(albedo_texture, UV);
	ALBEDO = albedo.rgb * albedo_tex.rgb;

	// Metallic
	float metallic_tex = texture(metallic_texture, UV).r;
	METALLIC = metallic * metallic_tex;
	SPECULAR = metallic_specular;

	// Roughness
	float roughness_tex = texture(roughness_texture, UV).r;
	ROUGHNESS = roughness * roughness_tex;

	// Normal
	vec3 normal_tex = texture(normal_texture, UV).rgb;
	NORMAL_MAP = normal_tex;
	NORMAL_MAP_DEPTH = normal_strength;

	// Emission
	EMISSION = emission_color.rgb * emission_strength;

	// Fresnel rim effect
	if (fresnel_strength > 0.0) {
		float fresnel = pow(1.0 - dot(NORMAL, VIEW), fresnel_power);
		EMISSION += fresnel_color.rgb * fresnel * fresnel_strength;
	}
}
