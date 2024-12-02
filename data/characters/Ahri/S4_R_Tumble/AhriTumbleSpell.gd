class_name AhriTumbleSpell extends Spell

func can_cast() -> bool:
	return host.status.can_move && host.status.can_cast

func self_execute() -> void:
	var count := host.buffs.count(AhriTumbleBuff)
	if count == 0:
		host.buffs.add(host, AhriTumbleBuff.new(), 2, 2, 10, Enums.BuffAddType.REPLACE_EXISTING, Enums.BuffType.COMBAT_ENCHANCER, 0.25, true, false, false)
		host.spells.r.set_cooldown(0.75, true)
		host.spells.r.set_cost_inc(-150, Enums.PARType.MANA)
	elif count == 1:
		host.buffs.remove_stacks(AhriTumbleBuff, 1, host)
	elif count == 2:
		host.buffs.remove_stacks(AhriTumbleBuff, 1, host)
		host.spells.r.set_cooldown(0.75, true)
	Particle.create(preload("Ahri_SpiritRush_cas.tscn")).bind(host, "BUFFBONE_GLB_GROUND_LOC").target(host, "BUFFBONE_GLB_GROUND_LOC")
	Particle.create(preload("Ahri_Orb_cas.tscn")).bind(host, "BUFFBONE_GLB_WEAPON_1").target(host, "BUFFBONE_GLB_WEAPON_1")
	var target_pos := spell.target_position
	var dash_speed := host.stats.get_movement_speed() + 1200
	var distance := host.position_3d.distance_to(target_pos)
	if distance > 500:
		host.face_direction(target_pos)
		target_pos = host.get_point_by_facing_offset(500, 0)
		distance = 500
		var nearest_available_pos := host.get_nearest_passable_position(target_pos)
		var distance2 := nearest_available_pos.distance_to(target_pos)
		if distance2 > 25:
			target_pos = host.get_point_by_facing_offset(600, 0)
			distance = 600
	host.buffs.add(host, AhriTumbleKickBuff.new(target_pos, distance, dash_speed), 1, 1, 2, Enums.BuffAddType.REPLACE_EXISTING, Enums.BuffType.INTERNAL, 0.25, true, false, false)