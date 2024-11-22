class_name Champion
extends Unit

var level := 1
var level_ups_avaible := 1
var exp_to_current_level: int
var exp_to_next_level: int
var assists := 0
var deaths := 0
var kills := 0

@onready var root := get_tree().current_scene
@onready var constants: Constants = root.get_node("%Constants")
@onready var gold: float = constants.ai_starting_gold
@onready var exp := 0.0:
	get: return exp
	set(value):
		assert(value >= exp)
		exp = value
		while true:
			exp_to_current_level = constants.exp_curve[level]
			exp_to_next_level = constants.exp_curve[level + 1]
			if exp >= exp_to_next_level:
				exp -= exp_to_next_level
				level_ups_avaible += 1
				level += 1
			else:
				break

func _ready() -> void:
	exp = 0.0
