class_name AIAttackState
extends AIState

func try_enter() -> void:
	if !current_state.can_cancel(): return
	switch_to_self()
func on_exit() -> void:
	pass
