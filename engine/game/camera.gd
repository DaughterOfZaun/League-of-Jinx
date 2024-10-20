extends Camera3D

@onready var viewport := get_viewport()

@export var target: Node3D
var target_position := Vector3.ZERO:
	get:
		if locked:
			target_position = target.global_position
		return target_position
@export var lerp_speed := 3.0
@export var move_speed := 27.0
var offset_initial := Vector3.ZERO
var offset := Vector3.ZERO

@export var max_zoom := 3.0
@export var min_zoom := 0.4
@export_range(0.05, 1.0) var zoom_speed := 0.09
var zoom := 1.0:
	get: return zoom
	set(value): zoom = clamp(value, min_zoom, max_zoom)

@export var locked := true

func _ready() -> void:
	offset_initial = self.global_position - target.global_position

var move_dir := Vector3.ZERO
func _input(unk_event: InputEvent) -> void:
	if unk_event is InputEventMouseMotion:
		var event := unk_event as InputEventMouseMotion
		const thresold := 10
		var rect := viewport.get_visible_rect()
		var d_start: Vector2 = abs(event.position - rect.position)
		var d_end: Vector2 = abs(event.position - rect.end)
		move_dir = Vector3(
			int(d_end.x <= thresold) - int(d_start.x <= thresold), 0,
			int(d_end.y <= thresold) - int(d_start.y <= thresold),
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
