class_name Dampener extends Unit

var linked_barrack: Barrack
var lane: Enums.Lane

func enter_regeneration_state() -> void:
	push_warning("Dampener.enter_regeneration_state is unimplemented")

func _ready() -> void:
	var ap: AnimationPlayer = find_child("AnimationPlayer")
	ap.play(ap.get_animation_list()[0])
