//shader_type spatial;
//render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

#ifdef REPEAT_DISABLE
#define REPEAT_MODE repeat_disable
#else
#define REPEAT_MODE repeat_enable
#endif

uniform vec4 albedo : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, REPEAT_MODE;

#if defined(ALPHA_SCISSOR_USED)
	uniform float alpha_scissor_threshold : hint_range(0.0, 2.0, 0.01) = 1;
#elif defined(ALPHA_HASH_USED)
	uniform float alpha_hash_scale : hint_range(0.0, 2.0, 0.01) = 1;
#endif

uniform float roughness : hint_range(0.0, 1.0) = 1.0;
uniform sampler2D texture_metallic : hint_default_white, filter_linear_mipmap, REPEAT_MODE;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r, filter_linear_mipmap, REPEAT_MODE;

uniform float specular : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float metallic : hint_range(0.0, 1.0, 0.01) = 0.0;

uniform sampler2D texture_normal : hint_roughness_normal, filter_linear_mipmap, REPEAT_MODE;
uniform float normal_scale : hint_range(-16.0, 16.0) = 1.0;

uniform vec3 uv1_scale = vec3(1, 1, 1);
uniform vec3 uv1_offset;

varying vec3 world_position;
void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

uniform sampler2D density_texture: hint_default_white;
uniform vec3 a;
uniform vec3 b;
uniform vec3 c;
uniform vec3 d;

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

	#if defined(ALPHA_SCISSOR_USED) || defined(ALPHA_HASH_USED)
		ALPHA *= albedo.a * albedo_tex.a;
		#if defined(ALPHA_SCISSOR_USED)
			ALPHA_SCISSOR_THRESHOLD = alpha_scissor_threshold;
		#elif defined(ALPHA_HASH_USED)
			ALPHA_HASH_SCALE = alpha_hash_scale;
		#endif
	#endif
}

#define DIFFUSE_BURLEY
#define SPECULAR_SCHLICK_GGX
#include "light.gdshaderinc"

void light() {
	float alpha;
	float ao = 1.0;
	float size_A = 0.0;
	vec3 diffuse_light = vec3(0, 0, 0);
	vec3 specular_light = vec3(0, 0, 0);
	vec3 f0 = F0(metallic, specular, ALBEDO);
	uint orms = packUnorm4x8(vec4(ao, roughness, metallic, specular));
	light_compute(NORMAL, LIGHT, VIEW, size_A, LIGHT_COLOR, LIGHT_IS_DIRECTIONAL, ATTENUATION, f0, orms, SPECULAR_AMOUNT, ALBEDO, alpha, diffuse_light, specular_light);

	vec2 density_uv = vec2(
		(world_position.x - a.x) / (b.x - a.x),
		(world_position.z - b.z) / (c.z - b.z)
	);
	vec4 density_tex = texture(density_texture, density_uv);
	float density = density_tex.r;
	if(LIGHT_IS_DIRECTIONAL){
		diffuse_light *= density;
		specular_light *= density;
	}

	DIFFUSE_LIGHT += diffuse_light;
	SPECULAR_LIGHT += specular_light;
}