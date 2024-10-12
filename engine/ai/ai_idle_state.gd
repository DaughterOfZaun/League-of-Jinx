class_name AIIdleState
extends AIState

func try_enter(emote := Enums.EmoteType.NONE) -> void:
	if !current_state.can_cancel(): return
	switch_to_self()
	var anim_to_play := Enums.EmoteType_to_string(emote) if emote else "Idle1"
	animation_playback.travel(anim_to_play)

func on_exit() -> void:
	pass
