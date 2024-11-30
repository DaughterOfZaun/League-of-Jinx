class_name SpellLineMissile
extends Missile

func _process(delta: float) -> void:
	
	var track_units := spell.data.line_missile_track_units
	if track_units && target != null:
		target_position = target.position_3d
	
	var ends_at_target_point := spell.data.line_missile_ends_at_target_point
	if linear_movement(delta):
		if ends_at_target_point: #TODO:
			destroy_self()