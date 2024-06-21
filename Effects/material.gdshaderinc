//shader_type spatial;

const float EPSILON = 0.0001;

uniform vec4 albedo : source_color = vec4(1, 1, 1, 1);
uniform sampler2D texture_albedo : source_color,hint_default_white,filter_linear_mipmap,repeat_enable;

uniform vec2 uv_scale = vec2(1, 1);
uniform vec2 uv_offset;
//uniform sampler2D uv_offset_a_p : hint_default_white,filter_nearest;

uniform vec2 texdiv = vec2(1, 1);
uniform bool random_start_frame;
uniform float start_frame = 0;
uniform float num_frames = 1;
uniform float frame_rate;

#define ROTATION_Z INSTANCE_CUSTOM.x
#define TIME_PASSED INSTANCE_CUSTOM.y
#define ALT_SEED INSTANCE_CUSTOM.z

#include "res://Effects/random.gdshaderinc"

void vertex() {
    UV = UV * uv_scale.xy + uv_offset.xy;
    
    #ifdef BILLBOARD
    // Billboard Mode: Particles
    MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
        normalize(INV_VIEW_MATRIX[0]),
        normalize(INV_VIEW_MATRIX[1]),
        normalize(INV_VIEW_MATRIX[2]),
        MODEL_MATRIX[3]
    ) * mat4(
        vec4(cos(ROTATION_Z), -sin(ROTATION_Z), 0.0, 0.0),
        vec4(sin(ROTATION_Z),  cos(ROTATION_Z), 0.0, 0.0),
        vec4(0.0, 0.0, 1.0, 0.0),
        vec4(0.0, 0.0, 0.0, 1.0)
    // Billboard Keep Scale: Enabled
    ) * mat4(
        vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0),
        vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0),
        vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0),
        vec4(0.0, 0.0, 0.0, 1.0)
    );
    MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
    #endif
    
    float frame = (num_frames == 0.) ? 0. : floor(mod(((frame_rate == 0.) ? 0. : (TIME_PASSED / frame_rate)) + start_frame, num_frames));
    
    UV /= vec2(texdiv.x, texdiv.y);
    UV += vec2(mod(frame, texdiv.x) / texdiv.x, floor((frame + 0.5) / texdiv.x) / texdiv.y);
}

void fragment() {
    vec2 base_uv = UV;
    vec4 albedo_tex = texture(texture_albedo, base_uv);
    albedo_tex *= COLOR;
    ALBEDO = albedo.rgb * albedo_tex.rgb;
}