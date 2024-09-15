class_name Buffs
extends Node

#TODO: Signals
#TODO: Remove empty slots

@onready var me := get_parent() as Unit
func _ready():
	if Engine.is_editor_hint(): return
	me.buffs = self

var slots := {}
func get_slot(script, attacker: Unit, create := false) -> BuffSlot:
	var slot: BuffSlot
	var slots_with_script = slots.get(script, null)
	if slots_with_script == null:
		if create:
			slots_with_script = {}
			slots[script] = slots_with_script
		else:
			return null
	else:
		slot = slots_with_script.get(null, slots_with_script.get(attacker, null))
		
		if len(slots_with_script.keys()) > 1 && (attacker == null || slots_with_script.has(null)):
			var warn := ".stacks_exclusive value is inconsistent. " +\
				"Either set it to false or pass the attacker to all methods that require it."
			push_warning(script, warn)

	if slot == null:
		if create:
			slot = BuffSlot.new(self)
			slots_with_script[attacker] = slot
		else:
			return null
	
	return slot

## Adds the passed buff.[br]
## If the number of stacks is more than one, duplicates it.[br]
## If stacks_exclusive = false, considers the attacker parameter equal to null.[br]
func add(
	attacker: Unit,
	buff: Buff,
	max_stack := 0,
	number_of_stacks := 1,
	duration := 0.0,
	add_type := Enums.BuffAddType.UNDEFINED,
	type := Enums.BuffType.UNDEFINED,
	tick_rate := 0.0,
	stacks_exclusive = null,
	can_mitigate_duration = null,
	is_hidden_on_client = null
) -> void:
	
	if max_stack == 0: max_stack = buff.max_stack
	if duration == 0.0: duration = buff.duration
	if add_type == Enums.BuffAddType.UNDEFINED: add_type = buff.add_type
	if type == Enums.BuffType.UNDEFINED: type = buff.type
	if tick_rate == 0.0: tick_rate = buff.tick_rate
	if stacks_exclusive == null: stacks_exclusive = buff.stacks_exclusive
	if can_mitigate_duration == null: can_mitigate_duration = buff.can_mitigate_duration
	if is_hidden_on_client == null: is_hidden_on_client = buff.is_hidden_on_client
	
	number_of_stacks = min(max_stack, number_of_stacks)
	match add_type:
		Enums.BuffAddType.REPLACE_EXISTING,\
		Enums.BuffAddType.RENEW_EXISTING\
		when number_of_stacks > 1 or max_stack > 1:
			push_warning()
	
	if stacks_exclusive && attacker == null:
		push_warning()
	
	var script: Script = buff.get_script()
	var slot := get_slot(script, attacker if stacks_exclusive else null, true)
	
	buff.slot = slot
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

	var min_count_to_rem := maxi(0, maxi(len(slot.stacks), number_of_stacks) - max_stack)
	var max_count_to_rem := maxi(0, len(slot.stacks) + number_of_stacks - max_stack)
	var min_count_to_add := maxi(0, number_of_stacks - len(slot.stacks))
	var max_count_to_add := number_of_stacks

	match add_type:
		Enums.BuffAddType.RENEW_EXISTING, Enums.BuffAddType.STACKS_AND_RENEWS:
			slot.add(buff, min_count_to_add).remove_stacks(min_count_to_rem).renew(duration)
		Enums.BuffAddType.REPLACE_EXISTING, Enums.BuffAddType.STACKS_AND_OVERLAPS:
			slot.add(buff, max_count_to_add).remove_stacks(max_count_to_rem)
		Enums.BuffAddType.STACKS_AND_CONTINUE:
			slot.add(buff, max_count_to_add, true).remove_stacks(max_count_to_rem) #TODO
		

## Removes all debuffs, regardless of the attacker who applied them.
func dispell_negative() -> void:
	remove_by_type(Enums.BuffType.NEGATIVE)

## Removes all buffs with the specified script, regardless of the attacker who applied them.
func clear(script) -> void:
	var slots_by_attacker: Dictionary = slots.get(script, [])
	for attacker: Unit in slots_by_attacker:
		var slot: BuffSlot = slots_by_attacker[attacker]
		slot.clear()

func remove_and_renew(script, reset_duration: float, attacker: Unit = null) -> void:
	remove(script, attacker); renew(script, reset_duration, attacker)

func renew(script, reset_duration: float, attacker: Unit = null) -> void:
	get_slot(script, attacker).renew(reset_duration)

func remove_stacks(script, num_stacks: int, attacker: Unit = null) -> void:
	get_slot(script, attacker).remove_stacks(num_stacks)

func remove(type_or_script, attacker: Unit = null) -> void:
	if type_or_script is Enums.BuffType:
		remove_by_type(type_or_script)
	else:
		remove_by_script(type_or_script, attacker)

## Removes one stack of buff with the specified script
func remove_by_script(script, attacker: Unit = null) -> void:
	get_slot(script, attacker).remove_stacks(1)

## Removes all buffs with the specified type, regardless of the attacker who applied them.
func remove_by_type(type: Enums.BuffType) -> void:
	for buff: Buff in get_children():
		if (type & buff.type) != 0:
			buff.remove()

func has(type: Enums.BuffType) -> bool:
	for buff: Buff in get_children():
		if (type & buff.type) != 0:
			return true
	return false

func count(script, caster: Unit = null) -> int:
	return len(get_slot(script, caster).stacks)
