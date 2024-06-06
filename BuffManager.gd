class_name Buffs
extends Node

const DUPLICATE_ALL := \
	Node.DUPLICATE_SIGNALS |\
	Node.DUPLICATE_GROUPS |\
	Node.DUPLICATE_SCRIPTS |\
	Node.DUPLICATE_USE_INSTANTIATION

class Slot:
	
	var stacks: Array[Buff] = []
	
	func clear():
		stacks.clear()
		return self
		
	func add(buff: Buff, count := 1, continious := false):
		for i in range(count):
			stacks.append(buff if i == 0 else buff.duplicate(DUPLICATE_ALL))
		return self
	
	func remove_stacks(count := 0):
		if count == 0 || count == len(stacks):
			return clear()
		if count < 0:
			count += len(stacks)
		if count > 0:
			var final_len := len(stacks) - count
			stacks.sort_custom(func (a: Buff, b: Buff): a.duration_remain > b.duration_remain)
			stacks.resize(final_len)
		return self
		
signal slot_added(slot: Slot)

@onready var me := get_parent() as Character
func _ready():
	me.buffs = self

var slots := {}
func get_slot(type: Script, attacker: Character, create := false) -> Slot:
	var slot: Slot
	var slots_of_type: Dictionary = slots.get(type, null)
	if slots_of_type == null:
		if create:
			slots_of_type = {}
			slots[type] = slots_of_type
		else:
			return null
	else:
		slot = slots_of_type.get(attacker, null)

	if slot == null:
		if create:
			slot = Slot.new()
			slots_of_type[attacker] = slot
		else:
			return null
	
	if (attacker == null && len(slots_of_type.keys()) > 1)\
	|| (attacker != null && slots_of_type.has(null)):
		push_warning(type, ".stacks_exclusive value is inconsistent")
	
	return slot

func add(
	attacker: Character,
	buff: Buff,
	max_stack := 1,
	number_of_stacks := 1,
	duration := 25000.0,
	add_type := Enums.BuffAddType.REPLACE_EXISTING,
	type := Enums.BuffType.INTERNAL,
	tick_rate := 0.0,
	stacks_exclusive := true,
	can_mitigate_duration := false,
	is_hidden_on_client := false
):
	number_of_stacks = min(max_stack, number_of_stacks)
	match add_type:
		Enums.BuffAddType.REPLACE_EXISTING,\
		Enums.BuffAddType.RENEW_EXISTING\
		when number_of_stacks > 1 or max_stack > 1:
			push_warning()
	
	buff.attacker = attacker
	buff.caster = attacker
	buff.target = me
	buff.host = me
	buff.max_stack = max_stack
	buff.duration = duration
	buff.add_type = add_type
	buff.type = type
	buff.tick_rate = tick_rate
	buff.stacks_exclusive = stacks_exclusive
	buff.can_mitigate_duration = can_mitigate_duration
	buff.is_hidden_on_client = is_hidden_on_client
	
	var script: Script = buff.get_script()
	var slot := get_slot(script, attacker, true)
	match add_type:
		Enums.BuffAddType.REPLACE_EXISTING:
			slot.clear().add(buff, number_of_stacks)
		Enums.BuffAddType.RENEW_EXISTING:
			slot.remove_stacks(-max_stack).renew(duration)
		Enums.BuffAddType.STACKS_AND_RENEWS:
			slot.renew(duration).add(buff, number_of_stacks)
		Enums.BuffAddType.STACKS_AND_CONTINUE:
			slot.add(buff, number_of_stacks, true) #TODO
		Enums.BuffAddType.STACKS_AND_OVERLAPS:
			slot.add(buff, number_of_stacks)

func dispell_negative():
	pass

func clear(type):
	pass

func remove_and_renew(type, reset_duration: float, attacker: Character = null):
	remove(type, attacker);
	renew(type, reset_duration);

func renew(type, reset_duration: float):
	pass

func remove_stacks(type, num_stacks: int, attacker: Character = null):
	pass

func remove(type, attacker: Character = null):
	pass

func has(type) -> bool:
	return false

func count(type, caster: Character = null) -> int:
	return 0
