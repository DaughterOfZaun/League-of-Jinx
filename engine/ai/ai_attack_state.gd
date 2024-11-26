class_name AIAttackState
extends AIState

@onready var root := get_tree().current_scene
@onready var constants: Constants = root.get_node("%Constants")

var spell: Spell
var attack_animation_playback: AnimationNodeStateMachinePlayback
func _ready() -> void:
	await me.ready
	spell = me.spells.basic[0]
	attack_animation_playback = animation_tree.get("parameters/Attack/StateMachine/playback")

var is_running := false
func try_enter() -> void:
	if !current_state.can_cancel(): return
	switch_to_self()
	is_running = true
	me.face_direction(target.global_position)
	animation_tree.animation_finished.connect(_animation_finished)

var spell_i := 0
func _animation_finished(anim_name: StringName) -> void:
	spell_i = (spell_i + 1) % (len(me.spells.basic) + 1)
	if spell_i < len(me.spells.basic):
		spell = me.spells.basic[spell_i]
	else:
		spell = me.spells.crit
	switch_to_spell_animation()

func switch_to_spell_animation() -> void:
	animation_playback.travel("Attack")
	#if !spell.data.animation_name.is_empty():
	attack_animation_playback.travel(spell.data.animation_name)
	#animation_playback.travel(spell.data.animation_name)

func set_current_animation_time_scale(scale: float) -> void:
	animation_tree.set("parameters/Attack/TimeScale/scale", scale)

func get_current_animation_frames_count() -> int:
	#var current_animation_node_name := attack_animation_playback.get_current_node()
	#var current_animation_node: AnimationNodeAnimation = animation_tree.get("parameters/Attack/StateMachine/" + current_animation_node_name)
	return 0

var current_time := 0.0
var last_attack_time := 0.0
var last_windup_time := 0.0
var winding_up := false
var idling := false

func _physics_process(delta: float) -> void:
	current_time += delta

	var cooldown_time := 1.0 / me.stats.get_attack_speed(spell.data.delay_total_time_percent)
	var windup_time := cooldown_time * constants.gcd_attack_delay_cast_percent * (1.0 + spell.data.delay_cast_offset_percent)

	var length := attack_animation_playback.get_current_length()
	var time_scale := length / cooldown_time
	set_current_animation_time_scale(time_scale)

	if !is_running: return

	var cooldown_time_left := cooldown_time - (current_time - last_attack_time)
	var windup_time_left := windup_time - (current_time - last_windup_time)

	if !winding_up:
		if cooldown_time_left <= windup_time:
			winding_up = true
			last_windup_time = current_time
			switch_to_spell_animation()
		elif !idling:
			idling = true
			animation_playback.travel("Idle1")
	elif windup_time_left <= 0 && cooldown_time_left <= 0:
		last_attack_time = current_time
		print('ATTACK!')

func on_exit() -> void:
	animation_tree.animation_finished.disconnect(_animation_finished)
	is_running = false
	winding_up = false
	idling = false
