class_name AIIdleState
extends AIState

func _ready() -> void:
	if Engine.is_editor_hint(): return

func try_enter(emote := Enums.EmoteType.NONE) -> void:
	if !current_state.can_cancel(): return
	switch_to_self()
	animation.set_default(&"Idle1")
	if emote != Enums.EmoteType.NONE:
		animation.play(Enums.EmoteType_to_string(emote))

func on_exit() -> void:
	pass
