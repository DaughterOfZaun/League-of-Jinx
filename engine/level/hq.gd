class_name HQ extends Unit

func _ready() -> void:
	var ap: AnimationPlayer = find_child("AnimationPlayer", true)
	ap.play(ap.get_animation_list()[0])

func get_visible_in_fow() -> bool:
	return true