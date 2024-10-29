extends SubViewport

@onready var camera3D: Camera3D = %Camera
@onready var camera2D: Camera2D = $Camera2D
@onready var viewport3D: Viewport = camera3D.get_viewport()
@onready var material: ShaderMaterial = (%Camera/MeshInstance3D as MeshInstance3D).material_override

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

	#var scale := 1.
	#var unit_to_pixel := rect.size.x / C2D
	#size.x = roundi(A2B * unit_to_pixel * scale)
	#size.y = roundi(B2C * unit_to_pixel * scale)

	size = Vector2(720, 1280)

	camera2D.zoom = Vector2(
		size.x / (absf(A.x - B.x) * GD_3D_to_2D),
		size.y / (absf(B.z - C.z) * GD_3D_to_2D),
	)

	var A2 := Vector2(A.x, A.z)
	var B2 := Vector2(B.x, B.z)
	var C2 := Vector2(C.x, C.z)
	var D2 := Vector2(D.x, D.z)
	camera2D.global_position = (A2 + B2 + C2 + D2) * 0.25 * GD_3D_to_2D

	material.set_shader_parameter('a', A)
	material.set_shader_parameter('b', B)
	material.set_shader_parameter('c', C)
	material.set_shader_parameter('d', D)
