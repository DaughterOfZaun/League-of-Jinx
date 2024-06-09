class_name Buff
extends Timer

var slot: Buffs.Slot
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
var can_mitigate_duration := false
var is_hidden_on_client := false

var delay_remaining := 0.0
var duration_remaining := 0.0
var time_remaining: float :
	get: 
		return self.delay_remaining + self.duration_remaining

func _ready():
	pass

## Can be called by scripts.
func remove():
	if !is_queued_for_deletion():
		remove_internal_0()

## Can be called on timeout. Calls buff manager.
func remove_internal_0(expired := false):
	slot.remove(self)
	remove_internal_1(expired)

## Can be called by buff manager.
func remove_internal_1(expired := false):
	on_deactivate(expired)
	queue_free()

func on_deactivate(expired := false):
	pass