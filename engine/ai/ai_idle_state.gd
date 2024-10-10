class_name AIIdleState
extends AIState

func try_enter() -> void:
	switch_to_self()
	animation_root_playback.travel("Idle")

func exit() -> void:
	pass
