class_name SpellLineMissile
extends Missile

func _process(delta: float) -> void:
	if linear_movement(delta, target_position):
		destroy_self()