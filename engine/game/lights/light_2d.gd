class_name CustomLight2D extends Node

@export var enabled := true
@export var range := 1000.0

var host: Unit:
	get: return get_parent()

var rect: CustomTextureRect
func _enter_tree() -> void:
	if !enabled || host.team == Enums.Team.CHAOS: return #HACK:
	rect = get_node("/root/Node3D/SubViewport/MeshInstance2D")
	rect.lights.append(self)
func _exit_tree() -> void:
	if !enabled || host.team == Enums.Team.CHAOS: return #HACK:
	rect.lights.erase(self)
	rect = null
