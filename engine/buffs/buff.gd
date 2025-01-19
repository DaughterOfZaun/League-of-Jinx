class_name Buff extends Timer

var slot: BuffSlot
var attacker: Unit
var caster: Unit
var target: Unit
var host: Unit
var max_stack: int = 1
var duration: float = 25000.0
var add_type: Enums.BuffAddType = Enums.BuffAddType.REPLACE_EXISTING
var type: Enums.BuffType = Enums.BuffType.INTERNAL
var tick_rate: float = 0.25
var stacks_exclusive: bool = true
var can_mitigate_duration: bool = false
var is_hidden_on_client: bool = false

func copy(from: Buff) -> Buff:
	slot = from.slot
	attacker = from.attacker
	caster = from.caster
	target = from.target
	host = from.host
	max_stack = from.max_stack
	duration = from.duration
	add_type = from.add_type
	type = from.type
	tick_rate = from.tick_rate
	stacks_exclusive = from.stacks_exclusive
	can_mitigate_duration = from.can_mitigate_duration
	is_hidden_on_client = from.is_hidden_on_client
	return self

func clone() -> Buff:
	return new().copy(self)

var vars: Vars:
	get: return host.vars

var start_time: float

var delay: float = 0.0
var delay_remaining := 0.0:
	get:
		return maxf(0, self.time_left - self.duration)
	set(value):
		self.delay = value
		start(self.delay + self.duration)

var duration_remaining := 0.0:
	get:
		return minf(self.duration, self.time_left)
	set(value):
		self.duration = value
		start(self.delay + self.duration)

func _init() -> void:
	autostart = false
	one_shot = true

func _ready() -> void:
	if SecondTest.is_clonning: return
	#if Engine.is_editor_hint(): return
	start(self.delay + self.duration)
	timeout.connect(on_timeout)
	if !host.is_ready: await host.ready
	host.connect_all(self)
	on_activate()

func remove_self() -> void:
	slot.mngr.remove_by_instance(self)

var expired: bool = false
func on_timeout() -> void:
	expired = true
	if !can_mitigate_duration:
		remove_self()

func on_activate() -> void: pass
func on_deactivate(_expired: bool) -> void: pass

func renew(reset_duration: float) -> void:
	self.delay = 0
	self.duration = reset_duration
	self.start(reset_duration)

func get_data() -> BuffData:
	return self[&'data'] if &'data' in self else null
