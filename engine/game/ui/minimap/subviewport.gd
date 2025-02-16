class_name SubViewportEx extends SubViewport

const GD_3D_to_2D := (70. / 50.) * (512. / 294.)

@onready var camera: Camera2D = get_camera_2d()

func vec2(pos: Variant) -> Vector2:
	if pos is Vector2: return pos
	elif pos is Vector3: return Vector2(pos.x, pos.z)
	else: assert(false); return Vector2.INF

func vec3(pos: Vector2) -> Vector3:
	return Vector3(pos.x, 0, pos.y)

func to_2d(pos: Variant) -> Vector2:
	return vec2(pos) * GD_3D_to_2D

func from_2d(pos: Vector2) -> Vector3:
	return vec3(pos) / GD_3D_to_2D

func get_camera_view_upper_left_corner_position() -> Vector2:
	return camera.global_position - Vector2(size.x, size.y) * 0.5

#TODO: multiply by camera zoom
func to_canvas(pos: Variant) -> Vector2:
	return to_2d(pos) - get_camera_view_upper_left_corner_position()

func from_canvas(pos: Vector2) -> Vector3:
	return from_2d(pos + get_camera_view_upper_left_corner_position())

func to_uv(pos: Variant) -> Vector2:
	return to_canvas(pos) / Vector2(size)
