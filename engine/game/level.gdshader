// NOTE: Shader automatically converted from Godot Engine 4.4.dev3's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 albedo : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;

uniform float roughness : hint_range(0.0, 1.0) = 1.0;
uniform sampler2D texture_metallic : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r, filter_linear_mipmap, repeat_enable;

uniform float specular : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float metallic : hint_range(0.0, 1.0, 0.01) = 0.0;

uniform sampler2D texture_normal : hint_roughness_normal, filter_linear_mipmap, repeat_enable;
uniform float normal_scale : hint_range(-16.0, 16.0) = 1.0;

uniform vec3 uv1_scale = vec3(1, 1, 1);
uniform vec3 uv1_offset;

void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;
}

void fragment() {
	vec2 base_uv = UV;

	vec4 albedo_tex = texture(texture_albedo, base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;

	float metallic_tex = dot(texture(texture_metallic, base_uv), metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	SPECULAR = specular;

	vec4 roughness_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
	float roughness_tex = dot(texture(texture_roughness, base_uv), roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;

	NORMAL_MAP = texture(texture_normal, base_uv).rgb;
	NORMAL_MAP_DEPTH = normal_scale;
}

#define DIFFUSE_BURLEY
#define SPECULAR_SCHLICK_GGX
#include "light.gdshaderinc"
void light() {
	float alpha;
	vec3 diffuse_light = vec3(0, 0, 0);
	vec3 specular_light = vec3(0, 0, 0);
	vec3 f0 = F0(METALLIC, SPECULAR_AMOUNT, ALBEDO);
	light_compute(NORMAL, LIGHT, VIEW, 0.0, LIGHT_COLOR, ATTENUATION, f0, ROUGHNESS, METALLIC, SPECULAR_AMOUNT, ALBEDO, alpha, diffuse_light, specular_light);
	DIFFUSE_LIGHT += diffuse_light;
	SPECULAR_LIGHT += specular_light;
}