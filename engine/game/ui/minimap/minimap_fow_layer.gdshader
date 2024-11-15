shader_type canvas_item;
render_mode blend_mul, unshaded;

uniform float opacity = 0.5;

void fragment() {
    COLOR.rgb = COLOR.rgb * opacity + (1.0 - opacity);
    //COLOR.a = 1.0 - (COLOR.r * opacity + (1.0 - opacity));
}