class_name Level
extends LuaScript

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
	pass
