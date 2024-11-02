shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

#define REPEAT_DISABLE
#define ALPHA_HASH_USED
#include "level.gdshaderinc"
