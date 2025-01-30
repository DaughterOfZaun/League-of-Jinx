class_name Buffs extends Node #@rollback

signal slot_created(slot: BuffSlot, buff: Buff)

#TODO: Remove empty slots

@onready var me: Unit = get_parent()
func _ready() -> void:
	if SecondTest.is_clonning: return
	#if Engine.is_editor_hint(): return
	me.buffs = self

var time: float
func _physics_process(delta: float) -> void:
	time += delta

var slots: Dictionary[GDScript, Dictionary] = {}
var empty_Dictionary_Unit_BuffSlot: Dictionary[Unit, BuffSlot] = {} #HACK:
func get_slot(script: GDScript, attacker: Unit, create := false, buff: Buff = null) -> BuffSlot:
	var slot: BuffSlot = null
	var slots_with_script: Dictionary[Unit, BuffSlot] = slots.get(script, empty_Dictionary_Unit_BuffSlot)
	if slots_with_script == empty_Dictionary_Unit_BuffSlot:
		if create:
			slots_with_script = {}
			slots[script] = slots_with_script
		else:
			return null
	else:
		if attacker == null:
			slot = slots_with_script.values()[0]
		else:
			slot = slots_with_script.get(attacker, null)
			if slot == null: slot = slots_with_script.get(null, null)

		if len(slots_with_script.keys()) > 1 && (slots_with_script.has(null) || attacker == null):
			var warn := ".stacks_exclusive value is inconsistent. " +\
				"Either set it to false or pass the attacker to all methods that require it."
			push_warning(script, warn)

	if slot == null:
		if create:
			slot = BuffSlot.new(self)
			slots_with_script[attacker] = slot
			slot_created.emit(slot, buff)
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
	stacks_exclusive: Variant = null,
	can_mitigate_duration: Variant = null,
	is_hidden_on_client: Variant = null
) -> void:

	if max_stack == 0: max_stack = buff.max_stack
	if duration == 0.0: duration = buff.duration
	if add_type == Enums.BuffAddType.UNDEFINED: add_type = buff.add_type
	if type == Enums.BuffType.UNDEFINED: type = buff.type
	if tick_rate == 0.0: tick_rate = buff.tick_rate
	if stacks_exclusive == null: stacks_exclusive = buff.stacks_exclusive
	if can_mitigate_duration == null: can_mitigate_duration = buff.can_mitigate_duration
	if is_hidden_on_client == null: is_hidden_on_client = buff.is_hidden_on_client

	#match add_type:
	#	Enums.BuffAddType.REPLACE_EXISTING,\
	#	Enums.BuffAddType.RENEW_EXISTING\
	#	when number_of_stacks > 1 or max_stack > 1:
	#		push_warning()
	#if stacks_exclusive && attacker == null:
	#	push_warning()

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

	if !stacks_exclusive:
		attacker = null

	var script: Script = buff.get_script()
	var slot := get_slot(script, attacker, true, buff)
	slot.max_stack = max_stack
	buff.slot = slot

	var min_count_to_rem := maxi(0, len(slot.stacks) - max_stack)
	var min_count_to_add := mini(number_of_stacks, max_stack - len(slot.stacks))
	var max_count_to_rem := mini(len(slot.stacks), number_of_stacks - min_count_to_add)
	var max_count_to_add := mini(number_of_stacks, max_stack)

	match add_type:
		Enums.BuffAddType.RENEW_EXISTING, Enums.BuffAddType.STACKS_AND_RENEWS:
			slot.remove_stacks(min_count_to_rem).add(buff, min_count_to_add).renew(duration)
		Enums.BuffAddType.REPLACE_EXISTING, Enums.BuffAddType.STACKS_AND_OVERLAPS:
			slot.remove_stacks(max_count_to_rem).add(buff, max_count_to_add)
		Enums.BuffAddType.STACKS_AND_CONTINUE:
			slot.remove_stacks(max_count_to_rem).add(buff, max_count_to_add, true) #TODO
	slot.update()

## Removes all debuffs, regardless of the attacker who applied them.
func dispell_negative() -> void:
	remove_by_type(Enums.BuffType.NEGATIVE)

## Removes all buffs with the specified script, regardless of the attacker who applied them.
func clear(script: GDScript) -> void:
	var slots_by_attacker: Dictionary[Unit, BuffSlot] = slots.get(script, empty_Dictionary_Unit_BuffSlot)
	for attacker: Unit in slots_by_attacker:
		var slot: BuffSlot = slots_by_attacker[attacker]
		slot.clear()
		slot.update()

func remove_and_renew(script: GDScript, reset_duration: float, attacker: Unit = null) -> void:
	var slot := get_slot(script, attacker)
	if slot != null:
		slot.remove_stacks(1)
		slot.renew(reset_duration)
		slot.update()

func renew(script: GDScript, reset_duration: float, attacker: Unit = null) -> void:
	var slot := get_slot(script, attacker)
	if slot != null:
		slot.renew(reset_duration)
		slot.update()

func remove_stacks(script: GDScript, num_stacks: int, attacker: Unit = null) -> void:
	var slot := get_slot(script, attacker)
	if slot != null:
		if num_stacks == 0: slot.clear()
		else: slot.remove_stacks(num_stacks)
		slot.update()

#func remove(type_or_script: Variant, attacker: Unit = null) -> void:
#	if type_or_script is Enums.BuffType:
#		remove_by_type(type_or_script)
#	else:
#		remove_by_script(type_or_script, attacker)

## Removes one stack of buff with the specified script
func remove_by_script(script: GDScript, attacker: Unit = null) -> void:
	var slot := get_slot(script, attacker)
	if slot != null:
		slot.remove_stacks(1)
		slot.update()

## Removes all buffs with the specified type, regardless of the attacker who applied them.
func remove_by_type(type: Enums.BuffType) -> void:
	for d: Dictionary[Unit, BuffSlot] in slots.values():
		for slot: BuffSlot in d.values():
			var removed := false
			for buff: Buff in slot.stacks:
				if (type & buff.type) != 0:
					slot.remove(buff)
					removed = true
			if removed: slot.update()

func remove_by_instance(buff: Buff) -> void:
	buff.slot.remove(buff)
	buff.slot.update()

func has(type: Enums.BuffType) -> bool:
	for buff: Buff in get_children():
		if (type & buff.type) != 0:
			return true
	return false

func count(script: GDScript, caster: Unit = null) -> int:
	var slot := get_slot(script, caster)
	if slot != null: return slot.stacks.size()
	return 0

func get_remaining_duration(script: GDScript) -> float:
	var slot := get_slot(script, null)
	if slot != null: return slot.duration_remaining
	return 0.0
