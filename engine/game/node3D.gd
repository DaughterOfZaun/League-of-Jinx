class_name Node3DExt
extends Node3D

var position_3d: Vector3:
	get: return global_position * Data.GD2HW
	set(value): global_position = value * Data.HW2GD
