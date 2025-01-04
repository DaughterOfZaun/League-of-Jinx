shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;
#define REPEAT_MODE repeat_enable
#define ALPHA_SCISSOR_USED
#include "res://engine/game/level/level.gdshaderinc"
