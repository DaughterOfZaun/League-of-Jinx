@tool
class_name Level
extends LuaScript

func on_level_init() -> void: pass
func on_post_level_load() -> void: pass
func _ready() -> void:
	if Engine.is_editor_hint(): return
	on_level_init()
	#on_post_level_load()

@export_tool_button("Create Level Props")
var post_level_load := func() -> void:
	on_post_level_load()

func preload_character(character_name: String) -> void:
	pass

func preload_spell(spell_name: String) -> void:
	pass

func get_turret(team: int, lane: int, pos: int) -> Turret:
	return null

func get_dampener(team: int, lane: int) -> Dampener:
	return null

func get_barracks(team: int, lane: int) -> Barrack:
	return null

func get_hq(team: int) -> HQ:
	return null

func get_total_team_minions_spawned() -> int:
	return 0

func create_child_turret(
	nav_point_name: String,
	character_name: String,
	team: Enums.Team,
	pos: Enums.Pos,
	lane: Enums.Lane
) -> void:
	var root := EditorInterface.get_edited_scene_root()
	var map := root.find_child("Map", false) #%Map
	var points := map.find_child("Points", false) #%Map/Points
	assert(map != null && points != null)
	var nav_point: Node3D = points.find_child(nav_point_name, false)
	var char_prefab: PackedScene = load("res://data/characters/%s/unit.tscn" % character_name)
	assert(nav_point != null && char_prefab != null)
	var char: Turret = char_prefab.instantiate()
	map.add_child(char)
	char.owner = root
	char.name = nav_point_name
	char.global_position = nav_point.global_position
	char.team = team
	char.lane = lane
	char.pos = pos
