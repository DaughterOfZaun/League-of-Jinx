class_name AhriOrbMissileSpell
extends Spell

func on_missile_end(missile: Missile) -> void:

	var missile_end_position := missile.position_3d - Vector3(0, 50, 0)

	for unit in API.get_units_in_area(
		attacker, missile_end_position, 100,
	   	Enums.SpellFlags.AFFECT_ENEMIES |\
		Enums.SpellFlags.AFFECT_NEUTRAL |\
		Enums.SpellFlags.AFFECT_MINIONS |\
		Enums.SpellFlags.AFFECT_HEROES, null, true
	):
		unit.break_spell_shields()
		unit.buffs.add(attacker, AhriOrbDamageBuff.new(vars.orb_of_deception_is_active), 1, 1, 2, Enums.BuffAddType.RENEW_EXISTING)

	for unit in API.get_units_in_area(
		host, missile_end_position, 100,
		Enums.SpellFlags.AFFECT_ENEMIES |\
		Enums.SpellFlags.AFFECT_NEUTRAL |\
		Enums.SpellFlags.AFFECT_MINIONS |\
		Enums.SpellFlags.AFFECT_HEROES, null, true
	):
		unit.break_spell_shields()
		unit.buffs.add(attacker, AhriOrbDamageSilenceBuff.new(vars.orb_of_deception_is_active), 1, 1, 2, Enums.BuffAddType.RENEW_EXISTING)

	var level := attacker.spells.q.level
	(host.spells.extra[1] as AhriOrbReturnSpell).cast(host, Vector3.INF, Vector3.INF, level, true, true, false, true, false, true, missile_end_position)

func target_execute(target: Unit, missile: Missile) -> void:
	target.buffs.add(host, AhriOrbDamageBuff.new(vars.orb_of_deception_is_active), 1, 1, 2, Enums.BuffAddType.RENEW_EXISTING)
