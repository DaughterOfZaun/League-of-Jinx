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

uniform sampler2D texture_heightmap : hint_default_black, filter_linear_mipmap, REPEAT_MODE;
uniform float heightmap_scale : hint_range(-16.0, 16.0, 0.001) = 1.0;
uniform vec2 heightmap_flip;

uniform sampler2D texture_normal : hint_roughness_normal, filter_linear_mipmap, REPEAT_MODE;
uniform float normal_scale : hint_range(-16.0, 16.0) = 1.0;

uniform vec3 uv1_scale = vec3(1, 1, 1);
uniform vec3 uv1_offset = vec3(0, 0, 0);

varying vec3 world_position;
void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

#define GD_3D_to_2D ((70. / 50.) * (512. / 294.))

uniform sampler2D density_texture: hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec2 density_texture_offset = vec2(64, -64);
/*uniform*/ const float density_texture_scale = GD_3D_to_2D;

void fragment() {
	vec2 base_uv = UV;

	vec3 view_dir = normalize(normalize(-VERTEX + EYE_OFFSET) * mat3(TANGENT * heightmap_flip.x, -BINORMAL * heightmap_flip.y, NORMAL));
	float depth = 1.0 - texture(texture_heightmap, base_uv).r;
	vec2 ofs = base_uv - view_dir.xy * depth * heightmap_scale * 0.01;
	base_uv = ofs;

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

	#if defined(ALPHA_USED) || defined(ALPHA_SCISSOR_USED) || defined(ALPHA_HASH_USED)
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
#include "blur.gdshaderinc"

void light() {
	float alpha;
	float ao = 1.0;
	float size_A = 0.0;
	vec3 diffuse_light = vec3(0, 0, 0);
	vec3 specular_light = vec3(0, 0, 0);
	vec3 f0 = F0(metallic, specular, ALBEDO);
	uint orms = packUnorm4x8(vec4(ao, roughness, metallic, specular));
	light_compute(NORMAL, LIGHT, VIEW, size_A, LIGHT_COLOR, LIGHT_IS_DIRECTIONAL, ATTENUATION, f0, orms, SPECULAR_AMOUNT, ALBEDO, alpha, diffuse_light, specular_light);

	vec2 off = 1.0 / vec2(textureSize(density_texture, 0));
	vec2 density_uv = (world_position.xz * density_texture_scale + density_texture_offset) * off;
	//float density = textureLod(density_texture, density_uv, 0).r;
	float density = blur(density_texture, density_uv, off).r;

	if(LIGHT_IS_DIRECTIONAL){
		diffuse_light *= density;
		specular_light *= density;
	}
	DIFFUSE_LIGHT += diffuse_light;
	SPECULAR_LIGHT += specular_light;
}
