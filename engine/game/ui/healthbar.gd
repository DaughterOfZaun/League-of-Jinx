class_name Healthbar
extends Control

@export var height := 2.5
@onready var host: Node3D = get_parent()
@onready var camera: Camera3D = get_tree().current_scene.get_node("%Camera")
func _process(delta: float) -> void:
	global_position = camera.unproject_position(host.global_position + Vector3.UP * height) - pivot_offset
