class_name AIIdleState
extends AIState

var is_running := false

func enter() -> void:
	animation_root_playback.travel("Idle")

func exit() -> void:
	pass
