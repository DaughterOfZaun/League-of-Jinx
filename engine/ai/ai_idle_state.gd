class_name AIIdleState
extends AIState

func enter() -> void:
	animation_root_playback.travel("Idle")

func exit() -> void:
	pass
