class_name Champion extends Unit #@rollback

var level: int = 1
var level_ups_avaible: int = 1
var exp_to_current_level: int
var exp_to_next_level: int
var assists: int = 0
var deaths: int = 0
var kills: int = 0

@onready var root: Node = get_tree().current_scene #@ignore
@onready var constants: Constants = root.get_node("%Constants") #@ignore
@onready var gold: float = constants.ai_starting_gold #@ignore
@onready var level_script: Level = root.get_node("%Level") #@ignore
@onready var exp: float = 0.0:
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
	super._ready()
	exp = 0.0
	level_script.register_champion(self)
	
	for letter in "qwerdfb":
		var spell: Spell = spells[letter]
		spell.level = 1

func set_camera_position(position: Vector3) -> void:
	push_warning("unimplemented")
