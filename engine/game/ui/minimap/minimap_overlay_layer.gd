extends Control

@export var line_width: float = 1.0
@export var line_color: Color = Color.WHITE
@export var line_antialiased: bool = false

@onready var root: Node = get_tree().current_scene
@onready var camera: Camera = root.get_node("%Camera")
@onready var viewport: SubViewportEx = root.get_node("%SubViewport")
@onready var input_manager: InputManager = root.get_node("%InputManager")
@onready var hero: Champion = input_manager.main_hero
var navigation_agent: NavigationAgent3D
func _ready() -> void:
	await hero.ready
	navigation_agent = hero.ai.run_state.navigation_agent
	navigation_agent.path_changed.connect(on_path_changed)
	navigation_agent.waypoint_reached.connect(on_waypoint_reached)

var path_to_draw: PackedVector2Array = PackedVector2Array([ z ])
func on_path_changed() -> void:
	var path := navigation_agent.get_current_navigation_path()
	path_to_draw.resize(len(path) + 1)
	for i in len(path):
		path_to_draw[i + 1] = viewport.to_uv(path[i]) * size
	path_to_draw[0] = viewport.to_uv(hero.global_position) * size
	queue_redraw()

func on_waypoint_reached(details: Dictionary) -> void:
	path_to_draw.remove_at(1)
	queue_redraw()

const z: Vector2 = Vector2.ZERO
var rect_to_draw: PackedVector2Array = PackedVector2Array([ z, z, z, z, ])
var prev_camera_global_position: Vector3
var prev_hero_global_position: Vector3
func _process(delta: float) -> void:
	if camera.global_position != prev_camera_global_position:
		prev_camera_global_position = camera.global_position
		var rect := camera.get_rect_3d()
		for i in range(4):
			rect_to_draw[i] = viewport.to_uv(rect[i]) * size
		queue_redraw()
	if hero.global_position != prev_hero_global_position:
		prev_hero_global_position = hero.global_position
		path_to_draw[0] = viewport.to_uv(hero.global_position) * size
		queue_redraw()
	

func _draw() -> void:
	for i in len(rect_to_draw):
		draw_line(rect_to_draw[i], rect_to_draw[(i + 1) % 4], line_color, line_width, line_antialiased)
	for i in len(path_to_draw) - 1:
		draw_line(path_to_draw[i], path_to_draw[i + 1], line_color, line_width, line_antialiased)

func _gui_input(unk_event: InputEvent) -> void:
	if unk_event is InputEventMouse:
		var event: InputEventMouse = unk_event
		var left_click := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
		var right_click := Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
		if left_click || right_click:
			var pos := viewport.from_canvas(event.position / size * Vector2(viewport.size))
			pos += Vector3.UP * camera.ground_height
			if left_click:
				camera.locked = false
				camera.offset = Vector3.ZERO
				camera.target_position = pos
			if right_click:
				input_manager.on_ground_clicked_on_minimap(pos)
