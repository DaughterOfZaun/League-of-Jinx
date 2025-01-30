class_name Turret extends Unit #@rollback

@export var lane: Enums.Lane
@export var pos: Enums.Pos

func get_visible_in_fow() -> bool:
	return true
