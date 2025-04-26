class_name AhriOrbDamageBuff extends Buff

const effect_0: Array[int] = [ 40, 65, 90, 115, 140 ]

var orb_of_deception_is_active: int
func _init(orb_of_deception_is_active: int = 0) -> void:
	self.orb_of_deception_is_active = orb_of_deception_is_active
func clone() -> Buff:
	return new(orb_of_deception_is_active)

func on_activate() -> void:
	var target_pos := Vector3.INF # UNITIALIZED. Verify
	#require_var(this.orb_of_deception_is_active)
	var team_id := attacker.team
	if orb_of_deception_is_active == 1:
		attacker.buffs.add(attacker, GlobalDrainBuff.new(0.1166, false), 1, 1, 0.01)
		#TODO: Particle.create(preload("Ahri_PassiveHeal.tscn")).bind(attacker).target(attacker)
		#TODO: Particle.create(preload("Ahri_passive_tar.tscn")).fow(team_id, 10).bind(host, "", target_pos).target(host).more_flags(true)
		attacker.buffs.remove_stacks(AhriSoulCrusherBuff, 1, attacker)
	elif attacker.buffs.count(AhriSoulCrusherBuff, attacker) == 0:
		attacker.buffs.add(attacker, AhriSoulCrusher5Buff.new(), 4, 1, 2, Enums.BuffAddType.STACKS_AND_RENEWS)
		if attacker.buffs.count(AhriSoulCrusher5Buff) <= 3:
			attacker.buffs.add(attacker, AhriSoulCrusherCounterBuff.new(), 9, 1, 25000, Enums.BuffAddType.STACKS_AND_RENEWS, Enums.BuffType.AURA)
	var level := attacker.spells.q.level
	host.apply_damage(attacker, effect_0[level - 1], get_damage_type(), Enums.DamageSource.SPELLAOE, 1, 0.325, 0, false, false, attacker)
	#TODO: Particle.create(preload("Ahri_Orb_tar.tscn")).fow(team_id, 10).bind(host, "", target_pos).target(host).more_flags(true)

func get_damage_type() -> Enums.DamageType:
	return Enums.DamageType.MAGICAL
