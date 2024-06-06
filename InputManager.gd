class_name InputManager
extends Node3D

@export var main_hero: Character
@onready var nav_map_rid := get_world_3d().navigation_map

signal order(type: Enums.OrderType, unit: Character, pos: Vector3)

func on_unit_clicked(char: Character, button: MouseButton):
	if char.team != main_hero.team:
		order.emit(Enums.OrderType.ATTACK_TO, char, char.global_position)
	
func on_ground_clicked(pos: Vector3, button: MouseButton):
	var nearest_reachable_point := NavigationServer3D.map_get_closest_point(nav_map_rid, pos)
	order.emit(Enums.OrderType.MOVE_TO, null, nearest_reachable_point)
