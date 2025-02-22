class_name CustomTextureRect extends CanvasItem

const GD_3D_to_2D := (70. / 50.) * (512. / 294.)
const HW_3D_to_GD_2D := (1. / 50.) * (512. / 294.)

var lights: Array[CustomLight2D] = []
var light_pos: Array[Vector2] = []
var light_rng: Array[float] = []

func _init() -> void:
	light_pos.resize(200)
	light_rng.resize(200)

func _process(delta: float) -> void:
	var light_n := len(lights)
	for i in light_n:
		var l_pos := lights[i].host.global_position
		light_pos[i] = Vector2(l_pos.x, l_pos.z) * GD_3D_to_2D
		light_rng[i] = lights[i].range * HW_3D_to_GD_2D
	var m: ShaderMaterial = material
	m.set_shader_parameter(&"light_n", light_n)
	m.set_shader_parameter(&"light_pos", light_pos)
	m.set_shader_parameter(&"light_rng", light_rng)
