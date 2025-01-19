class_name Node3DExt extends Node3D

var position_3d: Vector3:
	get: return position * Data.GD2HW
	set(value): position = value * Data.HW2GD
