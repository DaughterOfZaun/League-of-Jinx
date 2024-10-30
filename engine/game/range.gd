class_name Radius
extends Area3D

@onready var char := get_parent() as Unit

func _ready() -> void:
	if Engine.is_editor_hint(): return

	monitoring = false
	monitorable = false
	input_ray_pickable = false

	match name:
		'GameplayRange':
			monitorable = true
		'SelectionRange':
			input_ray_pickable = true
		'AcquisitionRange', 'AttackRange', 'CancelAttackRange':
			monitoring = true

	monitoring = true
	monitorable = true

	var team_mask := 1 << char.team
	collision_mask = ~(team_mask | 1) if monitoring else 0
	collision_layer = team_mask if monitorable else 0
	if input_ray_pickable and collision_layer == 0:
		collision_layer = 1

@onready var input_manager: InputManager = get_tree().current_scene.get_node("%InputManager");
func _input_event(camera: Camera3D, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	var iemb := event as InputEventMouseButton
	var iemm := event as InputEventMouseMotion
	if iemb and iemb.pressed:
		input_manager.on_unit_clicked(char, iemb.button_index)
	elif iemm:
		input_manager.on_unit_hovered(char)
