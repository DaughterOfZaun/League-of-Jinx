extends Camera3D

@export var target: Node3D
var offset := Vector3.ZERO
@export var lerp_speed := 3.0

@export var max_zoom := 3.0
@export var min_zoom := 0.4
@export_range(0.05, 1.0) var zoom_speed := 0.09
var zoom := 1.0

func _ready() -> void:
	offset = self.global_position - target.global_position

func _unhandled_input(event: InputEvent) -> void:
	#if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED: return
	if event.is_action_pressed("zoom_in"):
		zoom -= zoom_speed
	if event.is_action_pressed("zoom_out"):
		zoom += zoom_speed
	zoom = clamp(zoom, min_zoom, max_zoom)

func _physics_process(delta: float) -> void:
	global_position = global_position.lerp(target.global_position + offset * zoom, lerp_speed * delta)

	#var target_xform := target.global_transform.translated(offset * zoom)
	#global_transform = global_transform.interpolate_with(target_xform, lerp_speed * delta)
	#look_at(target.global_transform.origin, target.transform.basis.y)
