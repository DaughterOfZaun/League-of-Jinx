class_name AhriOrbOfDeceptionSpell extends Spell

func self_execute() -> void:
	var target_pos := spell.target_position
	host.face_direction(target_pos)
	target_pos = host.get_point_by_facing_offset(900, 0)
	(host.spells.extra[0] as AhriOrbMissileSpell).cast(null, target_pos, target_pos, level, true, true)

#var metadata := BuffMetadata.from({
#	auto_buff_activate_attach_bone_name = [ "root" ],
#	auto_buff_activate_effect = [ "Ahri_OrbofDeception.troy" ],
#})
