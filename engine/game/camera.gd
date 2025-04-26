class_name Camera extends Node3DExt

@onready var camera: Camera3D = self as Variant
@onready var viewport: Viewport = camera.get_viewport()

@export var target: Unit
var target_position: Vector3 = Vector3.ZERO:
	get:
		if locked:
			target_position = target.global_position
		return target_position
@export var lerp_speed: float = 3.0
@export var move_speed: float = 27.0
var offset_initial: Vector3 = Vector3.ZERO
var offset: Vector3 = Vector3.ZERO

@export var max_zoom: float = 3.0
@export var min_zoom: float = 0.4
@export_range(0.05, 1.0) var zoom_speed: float = 0.09
var zoom: float = 1.0:
	get: return zoom
	set(value): zoom = clamp(value, min_zoom, max_zoom)

@export var locked: bool = true

@export var ground_height: float = 1.35

@export var screen_edge_thresold: float = 10

func _ready() -> void:
	#if Engine.is_editor_hint(): return
	offset_initial = self.global_position - target.global_position

var move_dir: Vector3 = Vector3.ZERO
func _input(unk_event: InputEvent) -> void:
	if locked: return
	if unk_event is InputEventMouseMotion:
		var event := unk_event as InputEventMouseMotion
		var rect := viewport.get_visible_rect()
		var d_start: Vector2 = abs(event.position - rect.position)
		var d_end: Vector2 = abs(event.position - rect.end)
		move_dir = Vector3(
			int(d_end.x <= screen_edge_thresold) - int(d_start.x <= screen_edge_thresold), 0,
			int(d_end.y <= screen_edge_thresold) - int(d_start.y <= screen_edge_thresold),
		)
		locked = locked && move_dir.length_squared() == 0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ZoomIn"):
		zoom -= zoom_speed
	if event.is_action_pressed("ZoomOut"):
		zoom += zoom_speed
	if event.is_action_pressed("CameraLockToggle"):
		locked = !locked
		if locked: offset = Vector3.ZERO

func _physics_process(delta: float) -> void:
	offset += move_dir * move_speed * delta
	global_position = global_position.lerp(target_position + offset_initial * zoom + offset, lerp_speed * delta)

func get_rect_3d() -> PackedVector2Array:
	var plane := Plane(Vector3.UP, ground_height)
	var rect := viewport.get_visible_rect()
	var a := rect.position
	var c := rect.end
	var b := Vector2(c.x, a.y)
	var d := Vector2(a.x, c.y)
	var array := PackedVector2Array([a, b, c, d])
	for i in len(array):
		var v := array[i]
		var p: Vector3 = plane.intersects_ray(camera.project_ray_origin(v), camera.project_ray_normal(v))
		array[i] = Vector2(p.x, p.z)
	return array
