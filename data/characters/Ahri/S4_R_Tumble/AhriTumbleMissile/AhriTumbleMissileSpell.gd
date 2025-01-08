class_name AhriTumbleMissileSpell extends Spell

const effect_0: Array[int] = [ 100, 140, 180, 0, 0 ]
func target_execute(target: Unit, missile: Missile) -> void:
	if vars.tumble_is_active == 1:
		var team_id := Enums.Team.UNKNOWN # UNITIALIZED. Verify
		#TODO: Particle.create(preload("Ahri_PassiveHeal.tscn")).bind(attacker).target(attacker)
		#TODO: Particle.create(preload("Ahri_passive_tar.tscn")).fow(team_id, 10).bind(target, "spine").target(target).more_flags(true)
		attacker.buffs.add(attacker, AhriSoulCrusher2Buff.new(), 1, 1, 0.5, Enums.BuffAddType.STACKS_AND_CONTINUE)
		attacker.buffs.add(attacker, GlobalDrainBuff.new(0.35, false), 1, 1, 0.01)
		if attacker.buffs.count(AhriSoulCrusherBuff, attacker) > 0:
			attacker.buffs.remove_stacks(AhriSoulCrusherBuff, 1, attacker)
	else:
		if attacker.buffs.count(AhriSoulCrusherBuff, attacker) == 0:
			attacker.buffs.add(attacker, AhriSoulCrusherCounterBuff.new(), 9, 1, 25000, Enums.BuffAddType.STACKS_AND_RENEWS, Enums.BuffType.AURA)
	target.apply_damage(attacker, effect_0[level - 1], Enums.DamageType.MAGICAL, Enums.DamageSource.SPELLAOE, 1, 0.3, 0, false, false, attacker)
