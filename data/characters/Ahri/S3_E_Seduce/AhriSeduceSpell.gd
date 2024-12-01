class_name AhriSeduceSpell extends Spell

func self_execute() -> void:
	var target_pos := spell.target_position
	host.face_direction(target_pos)
	if host.position_3d.distance_to(target_pos) > 1000:
		target_pos = host.get_point_by_facing_offset(950, 0)
	(host.spells.extra[4] as AhriSeduceMissileSpell).cast(null, target_pos, target_pos, level, true, true, false, false, false, false)