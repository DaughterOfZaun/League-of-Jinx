extends Node2D

@onready var host: Unit = get_parent()
@onready var subviewport: SubViewportEx = get_node("/root/Node3D/SubViewport")
@onready var icons: Control = get_node("/root/Node3D/UI/Map/Control/MapTexture1/SubViewportTexture/Icons")
func _ready() -> void:
	if Engine.is_editor_hint(): return
	switch_parent.call_deferred()

func switch_parent() -> void:
	host.remove_child(self)
	icons.add_child(self)

func _process(delta: float) -> void:
	var pos := Vector2(host.global_position.x, host.global_position.z)
	var uv := (pos * subviewport.scale + subviewport.offset) / Vector2(subviewport.size)
	self.position = (uv + Vector2(0, 1)) * icons.size
