class_name AIIdleState
extends AIState

func try_enter() -> void:
	if !current_state.can_cancel(): return
	switch_to_self()
	animation_playback.travel("Idle1")

func on_exit() -> void:
	pass
