class_name Buffs
extends Node

@onready var me := get_parent() as Character
func _ready():
	me.buffs = self

func add(
	attacker: Character,
	buff: Buff,
	max_stack := 1,
	number_of_stacks := 1,
	duration := 25000.0,
	buff_add_type := Enums.BuffAddType.REPLACE_EXISTING,
	buff_type := Enums.BuffType.INTERNAL,
	tickRate := 0.0,
	stacks_exclusive := true,
	can_mitigate_duration := false,
	is_hidden_on_client := false
):
	pass

func dispell_negative():
	pass

func clear(type):
	pass

func remove_and_renew(type, resetDuration: float, attacker: Character = null):
	remove(type, attacker);
	renew(type, resetDuration);

func renew(type, resetDuration: float):
	pass

func remove_stacks(type, numStacks: int, attacker: Character = null):
	pass

func remove(type, attacker: Character = null):
	pass

func has(type) -> bool:
	return false

func count(type, caster: Character = null) -> int:
	return 0
