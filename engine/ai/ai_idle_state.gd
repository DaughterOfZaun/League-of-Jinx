class_name AIIdleState
extends AIState

func _ready() -> void:
	await ai.ready
	ai.animation_tree.animation_finished.connect(on_animation_finished)

func try_enter(emote := Enums.EmoteType.NONE) -> void:
	if !current_state.can_cancel(): return
	switch_to_self()
	var anim_to_play := Enums.EmoteType_to_string(emote) if emote else "Idle1"
	animation_playback.travel(anim_to_play)

func on_animation_finished(anim_name: StringName) -> void:
	if current_state == self:
		animation_playback.travel("Idle1")

func on_exit() -> void:
	pass
