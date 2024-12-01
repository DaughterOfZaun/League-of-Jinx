class_name SpellTargetMissile extends Missile

func _process(delta: float) -> void:
	if linear_movement(delta):
		destroy_self()
