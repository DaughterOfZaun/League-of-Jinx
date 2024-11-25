class_name AIAttackState
extends AIState

@onready var root := get_tree().current_scene
@onready var constants: Constants = root.get_node("%Constants")

func _ready() -> void:
	pass

var is_running := false
func try_enter() -> void:
	if !current_state.can_cancel(): return
	switch_to_self()
	is_running = true

var spell: Spell

var current_time := 0.0
var last_attack_time := 0.0
var last_windup_time := 0.0
var winding_up := false

func _process(delta: float) -> void:
	current_time += delta

	spell = me.spells.basic[0]

	var as_scale := 1.0 / me.stats.get_attack_speed()
	var cooldown_time := constants.gcd_attack_delay * as_scale * (1.0 + spell.data.delay_total_time_percent)
	var windup_time := constants.gcd_attack_delay * as_scale * (constants.gcd_attack_delay_cast_percent + spell.data.delay_cast_offset_percent)

	if !is_running: return

	var cooldown_time_left := cooldown_time - (current_time - last_attack_time)
	var windup_time_left := windup_time - (current_time - last_windup_time)

	if !winding_up && cooldown_time_left <= windup_time:
		winding_up = true
		last_windup_time = current_time
		if !spell.data.animation_name.is_empty():
			animation_playback.travel(spell.data.animation_name)
	if winding_up && windup_time_left <= 0 && cooldown_time_left <= 0:
		last_attack_time = current_time
		print('ATTACK!')

func on_exit() -> void:
	is_running = false
	winding_up = false
