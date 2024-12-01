class_name Radius extends Area3D

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

	assert(char.team != 0)
	var team_mask := 1 << char.team
	collision_mask = ~(team_mask | 1) if monitoring else 0
	collision_layer = team_mask if monitorable else 0
	if input_ray_pickable and collision_layer == 0:
		collision_layer = 1

@onready var root := get_tree().current_scene
@onready var input_manager: InputManager = root.get_node("%InputManager")
func _input_event(camera: Camera3D, unknown_event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if unknown_event is InputEventMouseButton:
		var event := unknown_event as InputEventMouseButton
		if event.pressed:
			input_manager.on_unit_clicked(event, char)

func _mouse_enter() -> void:
	input_manager.on_unit_hovered(char)
