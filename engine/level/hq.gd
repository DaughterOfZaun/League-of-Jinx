class_name HQ extends Unit

func _ready() -> void:
	super._ready()
	if SecondTest.is_clonning: return
	var ap: AnimationPlayer = find_child("AnimationPlayer", true, false)
	ap.play(ap.get_animation_list()[0])

func get_visible_in_fow() -> bool:
	return true