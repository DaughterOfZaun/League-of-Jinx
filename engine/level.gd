class_name Level
extends LuaScript

func on_level_init() -> void: pass
func on_post_level_load() -> void: pass
func _ready() -> void:
	if Engine.is_editor_hint(): return
	on_level_init()
	#on_post_level_load()

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
