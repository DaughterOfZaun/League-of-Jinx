class_name BuffSlot

const DUPLICATE_ALL := \
	Node.DUPLICATE_SIGNALS |\
	Node.DUPLICATE_GROUPS |\
	Node.DUPLICATE_SCRIPTS |\
	Node.DUPLICATE_USE_INSTANTIATION

var mngr: Buffs
var stacks: Array[Buff] = []
var time_remaining := 0.0

func _init(buffs: Buffs) -> void:
	self.mngr = buffs

func clear() -> BuffSlot:
	self.stacks.clear()
	return self

func add(buff: Buff, count := 1, continious := false) -> BuffSlot:
	#var time_remaining := 0.0
	#if continious:
		#for stack: Buff in self.stacks:
			#time_remaining = max(time_remaining, stack.time_remaining)
	for i in range(count):
		var duplicate: Buff = buff if i == 0 else buff.duplicate(DUPLICATE_ALL)
		if continious:
			duplicate.delay = time_remaining
			time_remaining += duplicate.duration
		self.stacks.append(duplicate)
		self.mngr.add_child(buff) #TODO: Protect stacks from modification during iteration
	return self

func sort_stacks() -> void:
	stacks.sort_custom(func (a: Buff, b: Buff) -> bool: return a.duration_remaining > b.duration_remaining)

func remove_stacks(count := 0) -> BuffSlot:
	if len(stacks) == 0 || count <= -len(stacks):
		return self
	if count == 0 || count >= len(stacks):
		return clear()
	if count < 0:
		count += len(stacks)
	var final_len := len(stacks) - count
	sort_stacks()
	for i: int in range(len(stacks), final_len):
		var buff := stacks[i]
		self.post_removal(buff)
		buff.remove_internal_1() #TODO: Protect stacks from modification during iteration
	stacks.resize(final_len)
	return self

## Can be called by scripts.
func remove(buff: Buff) -> void:
	post_removal(buff)
	self.stacks.erase(buff)

func post_removal(buff: Buff) -> void:
	if buff.delay_remaining == 0: return
	for stack: Buff in self.stacks:
		if stack.delay_remaining >= buff.delay_remaining:
			stack.delay_remaining -= buff.delay_remaining
	self.time_remaining -= buff.delay_remaining

func renew(reset_duration: float) -> BuffSlot:
	for buff: Buff in self.stacks:
		buff.renew(reset_duration)
	return self
