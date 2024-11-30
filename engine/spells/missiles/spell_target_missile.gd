class_name SpellTargetMissile
extends Missile

func _process(delta: float) -> void:
	if linear_movement(delta, target.position_3d):
		destroy_self()
