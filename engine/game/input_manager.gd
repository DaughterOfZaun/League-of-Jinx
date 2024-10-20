class_name InputManager
extends Node3D

@export var main_hero: Unit
@onready var nav_map_rid := get_world_3d().navigation_map
@onready var camera: Camera3D = %Camera
@onready var viewport := get_viewport()
@onready var window := get_tree().get_root()

func on_unit_clicked(char: Unit, button: MouseButton) -> void:
	#if main_hero == null: return
	if char.team != main_hero.team:
		main_hero.order(Enums.OrderType.ATTACK_TO, char.global_position, char)

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
	hovered_unit = unit
func on_ground_hovered() -> void:
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

const RAY_LENGTH = 1000.0
func _unhandled_input(unknown_event: InputEvent) -> void:
	if unknown_event is InputEventMouseButton:
		var event := unknown_event as InputEventMouseButton
		if event.pressed && event.button_index == MOUSE_BUTTON_RIGHT:
			var origin := camera.project_ray_origin(event.position)
			var normal := camera.project_ray_normal(event.position)
			var nearest_reachable_point := NavigationServer3D.map_get_closest_point_to_segment(
				nav_map_rid, origin, origin + normal * RAY_LENGTH
			)
			main_hero.order(Enums.OrderType.MOVE_TO, nearest_reachable_point, null)
			viewport.set_input_as_handled()
		on_ground_hovered()
	elif unknown_event is InputEventMouseMotion:
		var event := unknown_event as InputEventMouseMotion
		on_ground_hovered()

func _ready() -> void:
	Input.use_accumulated_input = false
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

	var spells: Dictionary[String, UISpell] = {
		"q": get_node("%UI/Center/ChampionSpells/Spell1"),
		"w": get_node("%UI/Center/ChampionSpells/Spell2"),
		"e": get_node("%UI/Center/ChampionSpells/Spell3"),
		"r": get_node("%UI/Center/ChampionSpells/Spell4"),
		"d": get_node("%UI/Center/SummonerSpells/Spell1"),
		"f": get_node("%UI/Center/SummonerSpells/Spell2"),
		"b": get_node("%UI/Center/Recall"),
	}
	await main_hero.ready
	for letter in spells:
		spells[letter].bind_to(main_hero.spells[letter])
