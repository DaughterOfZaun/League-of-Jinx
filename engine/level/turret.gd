class_name Turret extends Unit #@rollback

@export var lane: Enums.Lane = 0
@export var pos: Enums.Pos = 0

func get_visible_in_fow() -> bool:
	return true
