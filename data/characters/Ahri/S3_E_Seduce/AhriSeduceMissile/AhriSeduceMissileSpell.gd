class_name AhriSeduceMissileSpell extends Spell

var effect0: Array[float] = [ 60, 90, 120, 150, 180 ]
var effect1: Array[float] = [ 1, 1.25, 1.5, 1.75, 2 ]
func target_execute(target: Unit, missile: Missile) -> void:
	var damage_amount := effect0[level - 1]
	var taunt_length := effect1[level - 1]
	
	var slow_percent: float
	if target.is_in_front(attacker):
		slow_percent = -0.5
	else:
		slow_percent = -0.8
	
	if !target.status.stealthed || target is Champion || host.can_see(target):
		target.break_spell_shields()
		if vars.seduce_is_active == 1:
			#TODO: Particle.create(preload("Ahri_PassiveHeal.tscn")).bind(attacker).target(attacker)
			#TODO: Particle.create(preload("Ahri_passive_tar.tscn")).fow(host.team, 10).bind(target, "spine").target(host).more_flags(true)
			attacker.buffs.add(attacker, GlobalDrainBuff.new(0.35, false), 1, 1, 0.01)
			target.apply_damage(attacker, damage_amount, Enums.DamageType.MAGICAL, Enums.DamageSource.SPELL, 1, 0.35, 1, false, false, attacker)
			vars.seduce_is_active = 0
			attacker.buffs.remove_stacks(AhriSoulCrusherBuff, 1, attacker)
		else:
			if attacker.buffs.count(AhriSoulCrusherBuff, attacker) == 0:
				attacker.buffs.add(attacker, AhriSoulCrusherCounterBuff.new(), 9, 1, 25000, Enums.BuffAddType.STACKS_AND_RENEWS, Enums.BuffType.AURA)
			target.apply_damage(attacker, damage_amount, Enums.DamageType.MAGICAL, Enums.DamageSource.SPELL, 1, 0.35, 1, false, false, attacker)
		Particle.create(preload("Ahri_Charm_tar.tscn")).fow(host.team, 10).bind(target, "spine").target(host).more_flags(true)
		target.buffs.add(attacker, AhriSeduceBuff.new(slow_percent), 1, 1, taunt_length, Enums.BuffAddType.REPLACE_EXISTING, Enums.BuffType.STUN)
		target.buffs.add(attacker, TauntBuff.new(), 1, 1, taunt_length)
		missile.destroy()
	#get_point_by_unit_facing_offset(host, 0, 0)