class_name InputManager
extends Node3D

@export var main_hero: Unit
@onready var nav_map_rid := get_world_3d().navigation_map

func on_unit_clicked(char: Unit, button: MouseButton) -> void:
	#if main_hero == null: return
	if char.team != main_hero.team:
		main_hero.order(Enums.OrderType.ATTACK_TO, char.global_position, char)

func on_ground_clicked(pos: Vector3, button_index: MouseButton) -> void:
	#if main_hero == null: return
	if button_index != MOUSE_BUTTON_RIGHT: return
	var nearest_reachable_point := NavigationServer3D.map_get_closest_point(nav_map_rid, pos)
	main_hero.order(Enums.OrderType.MOVE_TO, nearest_reachable_point, null)

var hovered_unit: Unit = null
var hovered_pos := Vector3.INF
func on_unit_hovered(unit: Unit) -> void:
	hovered_pos = unit.global_position
	hovered_unit = unit
func on_ground_hovered(pos: Vector3) -> void:
	hovered_unit = null
	hovered_pos = pos

func _input(event: InputEvent) -> void:
	#if main_hero == null: return
	for letter in "qwerdfb":
		if event.is_action_released(letter.to_upper()):
			main_hero.cast(letter, hovered_pos, hovered_unit)
	for emote_index: int in Enums.EmoteType.values():
		if emote_index == Enums.EmoteType.NONE: continue
		var emote_name := Enums.EmoteType_to_string(emote_index)
		if event.is_action_pressed("Emote" + emote_name):
			main_hero.emote(emote_index)

func _ready() -> void:
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
