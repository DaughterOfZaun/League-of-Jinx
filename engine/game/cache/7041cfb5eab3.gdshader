shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx, depth_prepass_alpha;
#define REPEAT_MODE repeat_disable
#define ALPHA_USED
#include "res://engine/game/level/level.gdshaderinc"
