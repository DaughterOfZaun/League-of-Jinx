class_name SpellTargetMissile extends Missile

static func create(spell: Spell, target: Unit) -> SpellTargetMissile:
	var m := SpellTargetMissile.new()
	m.init(spell, target)
	return m

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if linear_movement(delta):
		if spell.data.apply_attack_damage:
			var attacker := spell.host
			#attacker.spell_hit.emit(target, spell)
			#target.being_spell_hit.emit(attacker, spell)
			target.apply_damage(attacker, attacker.stats.get_attack_damage(), Enums.DamageType.PHYSICAL, Enums.DamageSource.ATTACK)
		destroy_self()
