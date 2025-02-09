class_name BuffSlot extends Node #@rollback

var mngr: Buffs
var max_stack: int = 0
var stacks: Array[Buff] = []
var duration: float = 0.0
var start_time: float
var duration_remaining: float:
	get: return duration - (mngr.time - start_time)

func _init(buffs: Buffs) -> void:
	self.mngr = buffs

signal updated(count: int, top_buff: Buff)
func update() -> void:
	var first_buff: Buff = null
	if len(stacks) > 0:
		first_buff = get_first_expiring_buff()
	updated.emit(len(stacks), first_buff)

func add(buff: Buff, count := 1, continious := false) -> BuffSlot:
	for i in range(count):
		if i > 0: buff = buff.clone()
		self.stacks.append(buff)
		buff.start_time = mngr.time
		adjust_duration_and_delay_for(buff)
		self.mngr.add_child(buff) #TODO: Protect stacks from modification during iteration
	return self

func get_first_expiring_buff() -> Buff:
	return stacks.reduce(by_time_remaining, stacks[0])
func by_time_remaining(accum: Buff, buff: Buff) -> Buff:
	if buff.delay_remaining < accum.delay_remaining \
	&& buff.duration_remaining < accum.duration_remaining:
		return buff
	return accum

func remove_stacks(count: int = len(stacks)) -> BuffSlot:
	if count == 0 && len(stacks) == 0:
		return self
	if count >= len(stacks):
		return clear()
	if count < 0:
		count += len(stacks)
	for i in range(count):
		var buff: Buff = stacks.pop_back()
		buff.on_deactivate(buff.expired) #TODO: Protect stacks from modification during iteration
		if buff.is_inside_tree(): get_parent().remove_child(buff) #buff.queue_free()
	adjust_duration_and_delays()
	return self

## Can be called by scripts.
func remove(buff: Buff) -> void:
	self.stacks.erase(buff)
	buff.on_deactivate(buff.expired)
	adjust_duration_and_delays()
	if buff.is_inside_tree(): get_parent().remove_child(buff) #buff.queue_free()

func clear() -> BuffSlot:
	for i in len(stacks):
		var buff: Buff = stacks.pop_back()
		buff.on_deactivate(buff.expired)
		if buff.is_inside_tree(): get_parent().remove_child(buff) #buff.queue_free()
	return self

func adjust_duration_and_delays() -> void:
	duration = 0
	for buff in stacks:
		adjust_duration_and_delay_for(buff)
func adjust_duration_and_delay_for(buff: Buff) -> void:
	if buff == stacks[0]:
		start_time = buff.start_time
	if buff.add_type == Enums.BuffAddType.STACKS_AND_CONTINUE:
		buff.delay = duration
		duration += buff.duration
	else:
		duration = max(duration, buff.duration)

func renew(reset_duration: float) -> BuffSlot:
	for buff: Buff in self.stacks:
		buff.renew(reset_duration)
	return self
