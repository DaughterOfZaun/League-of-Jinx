class_name BuffSlot

var mngr: Buffs
var max_stack := 0
var stacks: Array[Buff] = []
var time_remaining := 0.0

func _init(buffs: Buffs) -> void:
	self.mngr = buffs

signal updated(count: int, top_buff: Buff)
func update() -> void:
	var first_buff: Buff = null
	if len(stacks) > 0:
		sort_stacks()
		first_buff = stacks[0]
	updated.emit(len(stacks), first_buff)

func add(buff: Buff, count := 1, continious := false) -> BuffSlot:
	#var time_remaining := 0.0
	#if continious:
		#for stack: Buff in self.stacks:
			#time_remaining = max(time_remaining, stack.time_remaining)
	for i in range(count):
		var duplicate: Buff = buff if i == 0 else buff.clone().copy(buff)
		if continious:
			duplicate.delay = time_remaining
			time_remaining += duplicate.duration
		self.stacks.append(duplicate)
		self.mngr.add_child(duplicate) #TODO: Protect stacks from modification during iteration
	return self

func sort_stacks() -> void:
	stacks.sort_custom(by_duration_remaining)
func by_duration_remaining(a: Buff, b: Buff) -> bool:
	return a.duration_remaining > b.duration_remaining

func remove_stacks(count: int = len(stacks)) -> BuffSlot:
	if count == 0 && len(stacks) == 0:
		return self
	if count >= len(stacks):
		return clear()
	if count < 0:
		count += len(stacks)
	sort_stacks()
	for i in range(count):
		var buff: Buff = stacks.pop_back()
		self.adjust_delays_after_removal_of(buff)
		buff.on_deactivate(buff.expired) #TODO: Protect stacks from modification during iteration
		buff.queue_free()
	return self

## Can be called by scripts.
func remove(buff: Buff) -> void:
	self.stacks.erase(buff)
	adjust_delays_after_removal_of(buff)
	buff.on_deactivate(buff.expired)
	buff.queue_free()

func clear() -> BuffSlot:
	for i in len(stacks):
		var buff: Buff = stacks.pop_back()
		buff.on_deactivate(buff.expired)
		buff.queue_free()
	return self

func adjust_delays_after_removal_of(buff: Buff) -> void:
	if buff.delay_remaining == 0: return
	for stack: Buff in self.stacks:
		if stack.delay_remaining >= buff.delay_remaining:
			stack.delay_remaining -= buff.delay_remaining
	self.time_remaining -= buff.delay_remaining

func renew(reset_duration: float) -> BuffSlot:
	for buff: Buff in self.stacks:
		buff.renew(reset_duration)
	return self
