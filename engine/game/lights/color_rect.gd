class_name CustomTextureRect
extends ColorRect

var lights: Array[CustomLight2D] = []
var light_pos: Array[Vector2] = []
var light_rng: Array[float] = []

func _init() -> void:
	light_pos.resize(200)
	light_rng.resize(200)

@onready var camera: Camera2D = %Camera2D
func _process(delta: float) -> void:
	var light_n := len(lights)
	for i in light_n:
		light_pos[i] = lights[i].global_position
		light_rng[i] = lights[i].range
	var m: ShaderMaterial = material
	m.set_shader_parameter("light_n", light_n)
	m.set_shader_parameter("light_pos", light_pos)
	m.set_shader_parameter("light_rng", light_rng)
	m.set_shader_parameter("comp_mat", camera.get_canvas_transform())
