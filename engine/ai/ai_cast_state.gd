class_name AICastState
extends AIState

@onready var ai := get_parent() as AI
@onready var me := ai.get_parent() as Unit

func can_cast(spell: Spell, target: Unit = null, is_auto_attack_or_override := false) -> bool:
	var status := me.status
	var data := spell.data
	var disabled := false\
	|| status.charmed\
	|| status.feared\
	|| status.pacified\
	|| status.silenced\
	|| status.sleep\
	|| status.stunned\
	|| status.suppressed\
	|| status.taunted
	if is_auto_attack_or_override: if !(!status.disarmed && status.can_attack): return false
	else: if !(!status.silenced && status.can_cast): return false
	return (
		(target == null || !target.status.is_dead) &&
		(!status.rooted || !data.cant_cast_while_rooted) &&
		(!status.suppressed || data.cannot_be_suppressed) &&

		(!disabled || data.can_cast_while_disabled) && #FUTURE: can_only_cast_while_disabled
		(!status.is_dead || !data.is_disabled_while_dead || data.can_only_cast_while_dead) &&
		(!data.can_only_cast_while_dead || status.is_dead)
	)
