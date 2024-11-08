class_name CustomLight2D
extends Node2D

#@export
var range := 100.0

var rect: CustomTextureRect
func _enter_tree() -> void:
	rect = %ColorRect
	rect.lights.append(self)
func _exit_tree() -> void:
	rect.lights.append(self)
	rect = null
