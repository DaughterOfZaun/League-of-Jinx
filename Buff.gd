class_name Buff
extends Timer

var metadata := BuffMetadata.new()

var slot: BuffSlot
var attacker: Character
var caster: Character
var target: Character
var host: Character
var max_stack := 1
var duration := 25000.0
var add_type := Enums.BuffAddType.REPLACE_EXISTING
var type := Enums.BuffType.INTERNAL
var tick_rate := 0.0
var stacks_exclusive := true
var can_mitigate_duration := false #TODO
var is_hidden_on_client := false

var delay := 0.0

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

var time_remaining: float :
	get: 
		return self.delay_remaining + self.duration_remaining

func _init():
	autostart = false
	one_shot = !can_mitigate_duration
	timeout.connect(remove_internal_0.bind(true))

func _ready():
	host.connect_all(self)
	start(self.delay + self.duration)

## Can be called by scripts.
func remove() -> void:
	if !is_queued_for_deletion():
		remove_internal_0()

## Can be called on timeout. Calls buff manager.
func remove_internal_0(expired := false) -> void:
	if !can_mitigate_duration:
		slot.remove(self)
	remove_internal_1(expired)

## Can be called by buff manager.
func remove_internal_1(expired := false) -> void:
	on_deactivate(expired)
	if !can_mitigate_duration:
		queue_free()

func on_deactivate(_expired: bool): pass
