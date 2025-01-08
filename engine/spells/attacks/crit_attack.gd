class_name CritAttack extends Spell

func target_execute(target: Unit, missile: Missile) -> void:
    target.apply_damage(attacker, attacker.stats.get_attack_damage(), Enums.DamageType.PHYSICAL, Enums.DamageSource.ATTACK)