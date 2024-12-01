class_name AhriFoxFireMissileTwoSpell extends Spell

var effect0: Array[float] = [ 20, 35, 50, 65, 80 ]
var effect2: Array[float] = [ 40, 70, 100, 130, 160 ]
func target_execute(target: Unit, missile: Missile) -> void:
	var team: Enums.Team # UNITIALIZED
	if target.buffs.count(AhriFoxFireMissileTwoBuff, attacker) > 0:
		if vars.fox_fire_is_active == 1:
			Particle.create("Ahri_PassiveHeal.troy").bind(attacker).target(attacker)
			Particle.create("Ahri_passive_tar.troy").fow(team, 10).bind(target, "spine").target(target).more_flags(true)
			attacker.buffs.add(attacker, GlobalDrainBuff.new(0.35, false), 1, 1, 0.01)
			target.apply_damage(attacker, effect0[level - 1], Enums.DamageType.MAGICAL, Enums.DamageSource.SPELL, 1, 0.1875, 0, false, false, attacker)
		else:
			if attacker.buffs.count(AhriSoulCrusher3Buff, attacker) == 0:
				if attacker.buffs.count(AhriSoulCrusherBuff, attacker) == 0:
					attacker.buffs.add(attacker, AhriSoulCrusherCounterBuff.new(), 9, 1, 25000, Enums.BuffAddType.STACKS_AND_RENEWS, Enums.BuffType.AURA)
				target.apply_damage(attacker, effect0[level - 1], Enums.DamageType.MAGICAL, Enums.DamageSource.SPELL, 1, 0.1875, 0, false, false, attacker)
		target.buffs.add(attacker, AhriFoxFireMissileTwoBuff.new(), 3, 1, 3, Enums.BuffAddType.STACKS_AND_CONTINUE)
	else:
		if vars.fox_fire_is_active == 1:
			Particle.create("Ahri_PassiveHeal.troy").bind(attacker).target(attacker)
			Particle.create("Ahri_passive_tar.troy").fow(team, 10).bind(target, "spine").target(target).more_flags(true)
			attacker.buffs.add(attacker, AhriSoulCrusher3Buff.new(), 3, 3, 5, Enums.BuffAddType.STACKS_AND_OVERLAPS, Enums.BuffType.INTERNAL, 0.25, true, false, false)
			attacker.buffs.add(attacker, GlobalDrainBuff.new(0.35, false), 1, 1, 0.01)
			target.apply_damage(attacker, effect2[level - 1], Enums.DamageType.MAGICAL, Enums.DamageSource.SPELL, 1, 0.375, 0, false, false, attacker)
			if attacker.buffs.count(AhriSoulCrusherBuff, attacker) > 0:
				attacker.buffs.remove_stacks(AhriSoulCrusherBuff, 1, attacker)
		else:
			if attacker.buffs.count(AhriSoulCrusher3Buff, attacker) == 0:
				if attacker.buffs.count(AhriSoulCrusherBuff, attacker) == 0:
					attacker.buffs.add(attacker, AhriSoulCrusherCounterBuff.new(), 9, 1, 25000, Enums.BuffAddType.STACKS_AND_RENEWS, Enums.BuffType.AURA)
				target.apply_damage(attacker, effect2[level - 1], Enums.DamageType.MAGICAL, Enums.DamageSource.SPELL, 1, 0.375, 0, false, false, attacker)
		target.buffs.add(attacker, AhriFoxFireMissileTwoBuff.new(), 3, 1, 6, Enums.BuffAddType.STACKS_AND_CONTINUE)
	missile.destroy()
