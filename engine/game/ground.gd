extends Area3D

@onready var root := get_tree().current_scene
@onready var input_manager: InputManager = root.get_node("%InputManager")
func _input_event(camera: Camera3D, unknown_event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if unknown_event is InputEventMouseButton:
		var event := unknown_event as InputEventMouseButton
		if event.pressed:
			input_manager.on_ground_clicked_on_screen(event)
	
func _mouse_enter() -> void:
	input_manager.on_ground_hovered()
