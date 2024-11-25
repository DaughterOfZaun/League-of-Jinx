class_name AIAttackState
extends AIState

@onready var root := get_tree().current_scene
@onready var constants: Constants = root.get_node("%Constants")

var spell: Spell
var cast_timer: Timer
var windup_timer: Timer
var cooldown_timer: Timer
func _ready() -> void:
	windup_timer = Timer.new()
	add_child(windup_timer)
	windup_timer.timeout.connect(windup)

	cast_timer = Timer.new()
	add_child(cast_timer)
	cast_timer.timeout.connect(cast)

	cooldown_timer = Timer.new()
	add_child(cooldown_timer)

var is_running := false
func try_enter() -> void:
	if !current_state.can_cancel(): return
	switch_to_self()

	is_running = true

	var as_scale := 1.0 / me.stats.get_attack_speed()
	var cooldown_time := constants.gcd_attack_delay * as_scale
	var windup_time := cooldown_time * (constants.gcd_attack_delay_cast_percent + spell.data.delay_cast_offset_percent)
	
	var cooldown_time_left := cooldown_timer.time_left if !cooldown_timer.is_stopped() else 0.0
	if cooldown_time_left <= windup_time:
		cast_timer.start(windup_time)
		windup_timer.start(cooldown_time)
		windup()

func windup() -> void:
	if !spell.data.animation_name.is_empty():
		animation_playback.travel(spell.data.animation_name)
		animation_tree.animation_finished.connect(idle)

func cast() -> void:
	#cast_timer.wait_time = cooldown_time
	pass

func idle() -> void:
	animation_playback.travel("Idle1")

func on_exit() -> void:
	is_running = false
	windup_timer.stop()
	cast_timer.stop()
	cooldown_timer.start()