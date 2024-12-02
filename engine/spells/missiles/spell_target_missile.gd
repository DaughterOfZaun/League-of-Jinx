class_name SpellTargetMissile extends Missile

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if linear_movement(delta):
		destroy_self()
