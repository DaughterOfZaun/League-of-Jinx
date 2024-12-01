class_name AhriFoxFireSpell
extends Spell

func SelfExecute() -> void:
	host.buffs.add(host, UnlockAnimationBuff.new(), 1, 1, 0.25)
	host.play_animation("Spell2", 0.71, false, true, true)
	var teamID := host.team
	Particle.create("Ahri_FoxFire_cas.troy").fow(teamID, 10).bind(target).target(target).more_flags(true)
	Particle.create("Ahri_FoxFire_weapon_cas.troy").fow(teamID, 10).bind(target, "BUFFBONE_GLB_WEAPON_1").target(target, "BUFFBONE_GLB_WEAPON_1").more_flags(true)
	var point1 := API.get_point_by_unit_facing_offset(host, 150, 45)
	var point2 := API.get_point_by_unit_facing_offset(host, 150, 165)
	var point3 := API.get_point_by_unit_facing_offset(host, 150, 285)
	var level := attacker.spells.w.level
	attacker.spells.extra[2].cast(attacker, Vector3.INF, Vector3.INF, level, true, true, false, true, false, true, point1)
	attacker.spells.extra[2].cast(attacker, Vector3.INF, Vector3.INF, level, true, true, false, true, false, true, point2)
	attacker.spells.extra[2].cast(attacker, Vector3.INF, Vector3.INF, level, true, true, false, true, false, true, point3)
	target.buffs.add(attacker, AhriFoxFireBuff.new(), 1, 1, 5, Enums.BuffAddType.REPLACE_EXISTING, Enums.BuffType.COMBAT_ENCHANCER)
	target.buffs.add(attacker, AhriFoxFireMissileBuff.new(), 3, 3, 5)
	if host.buffs.count(AhriFoxFireMissileTwoBuff, host) > 0:
		host.buffs.clear(AhriFoxFireMissileTwoBuff)
