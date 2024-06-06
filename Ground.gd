extends CollisionObject3D

@onready var input_manager := get_node("%InputManager") as InputManager;

func _input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		input_manager.on_ground_clicked(position, event.button_index)
