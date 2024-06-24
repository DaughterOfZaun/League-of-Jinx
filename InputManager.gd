class_name InputManager
extends Node3D

@export var main_hero: Unit
@onready var nav_map_rid := get_world_3d().navigation_map

func on_unit_clicked(char: Unit, button: MouseButton):
    if main_hero == null: return
    if char.team != main_hero.team:
        main_hero.on_order(Enums.OrderType.ATTACK_TO, char.global_position, char)

func on_ground_clicked(pos: Vector3, button: MouseButton):
    if main_hero == null: return
    var nearest_reachable_point := NavigationServer3D.map_get_closest_point(nav_map_rid, pos)
    main_hero.on_order(Enums.OrderType.MOVE_TO, nearest_reachable_point, null)

var hovered_unit: Unit = null
var hovered_pos := Vector3.ZERO
func on_unit_hovered(unit: Unit):
    hovered_pos = unit.global_position
    hovered_unit = unit
func on_ground_hovered(pos: Vector3):
    hovered_unit = null
    hovered_pos = pos

func _input(event):
    if main_hero == null: return
    var slot_letter := ""
    if event.is_action_pressed("Q"): slot_letter = 'q'
    if event.is_action_pressed("W"): slot_letter = 'w'
    if event.is_action_pressed("E"): slot_letter = 'e'
    if event.is_action_pressed("R"): slot_letter = 'r'
    if event.is_action_pressed("D"): slot_letter = 'd'
    if event.is_action_pressed("F"): slot_letter = 'f'
    if event.is_action_pressed("B"): slot_letter = 'b'
    if slot_letter != "":
        main_hero.on_cast(slot_letter, hovered_pos, hovered_unit)
