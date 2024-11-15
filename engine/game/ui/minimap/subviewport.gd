class_name SubViewportEx
extends SubViewport

const GD_3D_to_2D := (70. / 50.) * (512. / 294.)

@onready var camera := get_camera_2d()

func vec2(pos: Variant) -> Vector2:
	if pos is Vector2: return pos
	else: return Vector2(pos.x, pos.z)

func to_2d(pos: Variant) -> Vector2:
	return vec2(pos) * GD_3D_to_2D

#TODO: multiply by camera zoom
func to_canvas(pos: Variant) -> Vector2:
	var camera_view_upper_left_corner_position := \
		camera.global_position - Vector2(size.x, size.y) * 0.5
	return to_2d(pos) - camera_view_upper_left_corner_position

func to_uv(pos: Variant) -> Vector2:
	return to_canvas(pos) / Vector2(size)
