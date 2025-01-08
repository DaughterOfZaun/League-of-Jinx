class_name AhriOrbReturnSpell extends Spell

func target_execute(target: Unit, missile: Missile) -> void:
	if target != attacker:
		target.buffs.add(attacker, AhriOrbDamageSilenceBuff.new(vars.orb_of_deception_is_active), 1, 1, 2, Enums.BuffAddType.RENEW_EXISTING)
	else:
		missile.destroy()
		if vars.orb_of_deception_is_active == 1:
			vars.orb_of_deception_is_active = 0
