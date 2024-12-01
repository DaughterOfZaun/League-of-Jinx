class_name HQ extends Unit

func _ready() -> void:
	var ap: AnimationPlayer = find_child("AnimationPlayer")
	ap.play(ap.get_animation_list()[0])