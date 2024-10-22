class_name Level
extends Node3D

func preload_character(character_name: String) -> void:
	pass

func preload_spell(spell_name: String) -> void:
	pass

func get_turret(team: int, lane: int, pos: int) -> Unit:
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
