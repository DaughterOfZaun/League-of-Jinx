extends SubViewport

@export var world_owner: SubViewport
func _ready() -> void:
	self.world_2d = world_owner.world_2d
