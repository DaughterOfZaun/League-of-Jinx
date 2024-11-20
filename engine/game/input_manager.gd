class_name InputManager
extends Node3D

@export var main_hero: Champion
@onready var nav_map_rid := get_world_3d().navigation_map
@onready var camera: Camera3D = %Camera
@onready var viewport := get_viewport()
@onready var window := get_tree().get_root()

enum CursorShape {
	DEFAULT, HOVER_ENEMY, HOVER_ENEMY_DISABLED, HOVER_FRIENDLY, HOVER_SHOP
}
@export var cursor_textures: Dictionary[CursorShape, Texture2D] = {}
@export var cursor_moveto_effect: PackedScene
#@export_group("Cursor", "cursor_texture_")
#@export var cursor_texture_default: Texture2D
#@export var cursor_texture_hover_enemy: Texture2D
#@export var cursor_texture_hover_enemy_disabled: Texture2D
#@export var cursor_texture_hover_friendly: Texture2D
#@export var cursor_texture_hover_shop: Texture2D
#@export_group("")
func set_cursor_shape(shape: CursorShape) -> void:
	Input.set_default_cursor_shape(int(shape))
	#Input.set_custom_mouse_cursor(cursor_textures[shape], Input.CURSOR_ARROW)
	#print(Engine.get_process_frames(), ' ', CursorShape.keys()[shape])

func on_unit_clicked(char: Unit, button: MouseButton) -> void:
	#if main_hero == null: return
	if char.team != main_hero.team:
		main_hero.order(Enums.OrderType.ATTACK_TO, char.global_position, char)
	viewport.set_input_as_handled()

var hovered_unit: Unit = null
var hovered_pos: Vector3:
	get:
		var event_position := viewport.get_mouse_position()
		var origin := camera.project_ray_origin(event_position)
		var normal := camera.project_ray_normal(event_position)
		var plane := Plane(Vector3.UP, main_hero.global_position)
		var intersection: Variant = plane.intersects_ray(origin, normal)
		return intersection if intersection != null else Vector3.INF
func on_unit_hovered(unit: Unit) -> void:
	var shape: CursorShape
	if unit.team == main_hero.team:
		shape = CursorShape.HOVER_FRIENDLY
	elif unit.status.targetable && unit.status.targetable_to_team.get(unit.team, true):
		shape = CursorShape.HOVER_ENEMY
	else:
		shape = CursorShape.HOVER_ENEMY_DISABLED
	set_cursor_shape(shape)
	viewport.set_input_as_handled()
	hovered_unit = unit

func on_ground_hovered() -> void:
	set_cursor_shape(CursorShape.DEFAULT)
	viewport.set_input_as_handled()
	hovered_unit = null

func _input(event: InputEvent) -> void:
	#if main_hero == null: return
	for letter in "qwerdfb":
		if event.is_action_released(letter.to_upper()):
			main_hero.cast(letter, hovered_pos, hovered_unit)
			viewport.set_input_as_handled()
			return
	for emote_index: int in Enums.EmoteType.values():
		if emote_index == Enums.EmoteType.NONE: continue
		var emote_name := Enums.EmoteType_to_string(emote_index)
		if event.is_action_pressed("Emote" + emote_name):
			main_hero.emote(emote_index)
			viewport.set_input_as_handled()
			return
	if event.is_action_pressed("ToggleFullscreen"):
		if window.mode != Window.MODE_EXCLUSIVE_FULLSCREEN:
			window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN
		else:
			window.mode = Window.MODE_WINDOWED
		viewport.set_input_as_handled()

const RAY_LENGTH = 1000.0
func _unhandled_input(unknown_event: InputEvent) -> void:
	if unknown_event is InputEventMouseButton:
		var event := unknown_event as InputEventMouseButton
		if event.pressed && event.button_index == MOUSE_BUTTON_RIGHT:
			on_ground_clicked_on_screen(event.position)

func on_ground_clicked_on_screen(event_position: Vector2) -> void:
	var origin := camera.project_ray_origin(event_position)
	var normal := camera.project_ray_normal(event_position)
	var nearest_reachable_point := NavigationServer3D.map_get_closest_point_to_segment(
		nav_map_rid, origin, origin + normal * RAY_LENGTH
	)
	on_ground_clicked(nearest_reachable_point)

func on_ground_clicked_on_minimap(pos: Vector3) -> void:
	var nearest_reachable_point := NavigationServer3D.map_get_closest_point(nav_map_rid, pos)
	on_ground_clicked(nearest_reachable_point)

func on_ground_clicked(nearest_reachable_point: Vector3) -> void:
	
	var root := get_tree().current_scene
	var effect: Node3D = cursor_moveto_effect.instantiate()
	root.add_child(effect)
	effect.owner = root
	effect.global_position = nearest_reachable_point

	main_hero.order(Enums.OrderType.MOVE_TO, nearest_reachable_point, null)
	#viewport.set_input_as_handled()
	on_ground_hovered()

func _ready() -> void:
	if Engine.is_editor_hint(): return

	#Input.use_accumulated_input = false
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

	#ProjectSettings.set_setting("display/mouse_cursor/custom_image", cursor_textures[CursorShape.DEFAULT])
	var hotspot: Vector2 = ProjectSettings.get_setting("display/mouse_cursor/custom_image_hotspot")
	for shape: CursorShape in cursor_textures.keys():
		#if shape != CursorShape.DEFAULT:
		Input.set_custom_mouse_cursor(cursor_textures[shape], int(shape), hotspot)
	
	await main_hero.ready
	var ui_center_panel: UICenterPanel = %UI/Center
	var ui_left_panel: UILeftPanel = %UI/Left
	ui_center_panel.bind_to(main_hero)
	ui_left_panel.bind_to(main_hero)
	
