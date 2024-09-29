class_name Ground
extends CollisionObject3D

@onready var input_manager := get_node("%InputManager") as InputManager;

func _ready() -> void:
	if Engine.is_editor_hint(): return
	Input.use_accumulated_input = false

func _input_event(camera: Camera3D, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	var iemb := event as InputEventMouseButton
	var iemm := event as InputEventMouseMotion
	if iemb and iemb.pressed:
		input_manager.on_ground_clicked(event_position, event.button_index)
	elif iemm:
		input_manager.on_ground_hovered(event_position)
