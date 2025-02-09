class_name AICastState extends AIState #@rollback

var current_spell: Spell = null

func try_enter(spell: Spell, target_position: Vector3, target: Unit) -> void:
	spell.try_cast(target_position, target)

func can_cancel() -> bool:
	return current_spell == null || current_spell.can_cancel()

func on_exit() -> void:
	if current_spell != null:
		current_spell.cancel()
