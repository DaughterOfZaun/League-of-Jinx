class_name SubViewportEx
extends SubViewport

@onready var camera3D: Camera3D = %Camera
@onready var camera2D: Camera2D = $Camera2D
@onready var viewport3D: Viewport = camera3D.get_viewport()
#@onready var material: ShaderMaterial = (%Camera/MeshInstance3D as MeshInstance3D).material_override
#@onready var material: ShaderMaterial = (%Map as MapTool).shadow_of_war_overlay_material

const GD_3D_to_2D := (70. / 50.) * (512. / 294.)

var A: Vector3
var B: Vector3
var C: Vector3
var D: Vector3

func _process(delta: float) -> void:
	var plane := Plane.PLANE_XZ
	var rect := viewport3D.get_visible_rect()
	var a := rect.position + Vector2.UP * 100
	var c := rect.end - Vector2.UP * 100
	var b := Vector2(c.x, a.y)
	var d := Vector2(a.x, c.y)
	A = plane.intersects_ray(camera3D.project_ray_origin(a), camera3D.project_ray_normal(a))
	B = plane.intersects_ray(camera3D.project_ray_origin(b), camera3D.project_ray_normal(b))
	C = plane.intersects_ray(camera3D.project_ray_origin(c), camera3D.project_ray_normal(c))
	D = plane.intersects_ray(camera3D.project_ray_origin(d), camera3D.project_ray_normal(d))

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

	# material.set_shader_parameter('a', A)
	# material.set_shader_parameter('b', B)
	# material.set_shader_parameter('c', C)
	# material.set_shader_parameter('d', D)
