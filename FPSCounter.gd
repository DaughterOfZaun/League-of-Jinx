extends Label

var prev_fps := 0
func _physics_process(delta):
	var fps := Engine.get_frames_per_second()
	if fps != prev_fps:
		text = str(roundf(fps))
