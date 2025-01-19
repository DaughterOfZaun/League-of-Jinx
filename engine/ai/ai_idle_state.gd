class_name AIIdleState
extends AIState

func _ready() -> void:
	if SecondTest.is_clonning: return
	#if Engine.is_editor_hint(): return
	pass

func try_enter(emote := Enums.EmoteType.NONE) -> void:
	if current_state.can_cancel() && can_enter(): enter(emote)

func enter(emote := Enums.EmoteType.NONE) -> void:
	switch_to_self()
	animation.switch_loop(&"Idle1")
	if emote != Enums.EmoteType.NONE:
		animation.play(Enums.EmoteType_to_string(emote))

func on_exit() -> void:
	pass
