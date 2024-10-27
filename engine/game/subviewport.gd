extends SubViewport

@onready var camera3D: Camera3D = %Camera
@onready var camera2D: Camera2D = $Camera2D
@onready var viewport3D: Viewport = camera3D.get_viewport()

const GD_3D_to_2D := (70. / 50.) * (512. / 294.)

func _process(delta: float) -> void:
	var plane := Plane.PLANE_XZ
	var rect := viewport3D.get_visible_rect()
	var a := rect.position
	var b := Vector2(rect.end.x, rect.position.y)
	var c := rect.end
	var d := Vector2(rect.position.x, rect.end.y)
	var A: Vector3 = plane.intersects_ray(camera3D.project_ray_origin(a), camera3D.project_ray_normal(a))
	var B: Vector3 = plane.intersects_ray(camera3D.project_ray_origin(b), camera3D.project_ray_normal(b))
	var C: Vector3 = plane.intersects_ray(camera3D.project_ray_origin(c), camera3D.project_ray_normal(c))
	var D: Vector3 = plane.intersects_ray(camera3D.project_ray_origin(d), camera3D.project_ray_normal(d))
	var C2D := C.distance_to(D)
	var A2B := A.distance_to(B)
	var B2C := B.distance_to(C)
	var unit_to_pixel := rect.size.x / C2D

	var scale := 1
	size.x = roundi(A2B * unit_to_pixel * scale)
	size.y = roundi(B2C * unit_to_pixel * scale)

	#camera2D.zoom = Vector2.ONE * size.x / (C2D * GD_3D_to_2D)

	camera2D.global_position = Vector2(camera3D.global_position.x, camera3D.global_position.z) * GD_3D_to_2D
