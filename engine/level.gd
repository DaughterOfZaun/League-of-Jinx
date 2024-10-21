class_name Level
extends Node3D

func PreloadCharacter(character_name: String) -> void:
	pass

func PreloadSpell(spell_name: String) -> void:
	pass

func GetTurret(team: int, lane: int, pos: int) -> Unit:
	return null

func GetTotalTeamMinionsSpawned() -> int:
	return 0
