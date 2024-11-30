extends Node2D

@onready var host: Unit = get_parent()
@onready var subviewport: SubViewportEx = get_node("/root/Node3D/SubViewport")
@onready var icons: Control = get_node("/root/Node3D/UI/Map/Control/MapTexture/SubViewportTexture/Icons")
func _ready() -> void:
	if Engine.is_editor_hint(): return
	switch_parent.call_deferred()

func switch_parent() -> void:
	host.remove_child(self)
	icons.add_child(self)

func _process(delta: float) -> void:
	self.position = subviewport.to_uv(host.global_position) * icons.size
