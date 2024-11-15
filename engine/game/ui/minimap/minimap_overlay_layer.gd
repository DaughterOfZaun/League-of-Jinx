@tool
extends Control

@export var line_width := 1.0
@export var line_color := Color.WHITE
@export var line_antialiased := false

var camera: Camera
var viewport: SubViewportEx
func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	var root := get_tree().current_scene
	camera = root.get_node("%Camera")
	viewport = root.get_node("%SubViewport")

var prev_camera_global_position: Vector3
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
		return
	if camera.global_position != prev_camera_global_position:
		prev_camera_global_position = camera.global_position
		queue_redraw()

func _draw() -> void:
	if Engine.is_editor_hint():
		draw_line(Vector2(0, 0), Vector2(1000, 1000), line_color, line_width, line_antialiased)
		return
	var rect := camera.get_rect_3d()
	for i in range(4):
		rect[i] = viewport.to_uv(rect[i]) * size
	for i in range(4):
		draw_line(rect[i], rect[(i + 1) % 4], line_color, line_width, line_antialiased)

func _gui_input(unk_event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	if unk_event is InputEventMouseMotion:
		var event := unk_event as InputEventMouseMotion
