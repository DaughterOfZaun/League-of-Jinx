extends SubViewport

@export var world_owner: SubViewport
func _ready() -> void:
	if Engine.is_editor_hint(): return
	self.world_2d = world_owner.world_2d
