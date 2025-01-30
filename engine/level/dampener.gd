class_name Dampener extends Unit #@rollback

var linked_barrack: Barrack
var lane: Enums.Lane

func enter_regeneration_state() -> void:
	push_warning("Dampener.enter_regeneration_state is unimplemented")

func _ready() -> void:
	super._ready()
	if SecondTest.is_clonning: return
	var ap: AnimationPlayer = find_child("AnimationPlayer", true, false)
	ap.play(ap.get_animation_list()[0])

func get_visible_in_fow() -> bool:
	return true