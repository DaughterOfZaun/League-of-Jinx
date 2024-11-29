class_name AIAttackState
extends AIState

@onready var root := get_tree().current_scene
@onready var constants: Constants = root.get_node("%Constants")

var spell: Spell
var next_spell: Spell
var attack_animation_playback: AnimationNodeStateMachinePlayback
func _ready() -> void:
	await me.ready
	spell = me.spells.basic[0]
	next_spell = me.spells.basic[1]
	attack_animation_playback = animation_tree.get("parameters/Attack/StateMachine/playback")

var is_running := false
func try_enter() -> void:
	if !current_state.can_cancel(): return
	switch_to_self()
	is_running = true

	me.face_direction(target.global_position)

	just_entered_state = true

var spell_i := 1
func _animation_finished(anim_name: StringName) -> void:
	spell = next_spell
	switch_to_spell_animation()
	spell_i = (spell_i + 1) % (len(me.spells.basic) + 1)
	if spell_i < len(me.spells.basic):
		next_spell = me.spells.basic[spell_i]
	else:
		next_spell = me.spells.crit

func switch_to_spell_animation() -> void:
	attack_animation_playback.travel(spell.data.animation_name)
	animation_playback.travel("Attack")
	#if !spell.data.animation_name.is_empty():
	#animation_playback.travel(spell.data.animation_name)

func set_current_animation_time_scale(scale: float) -> void:
	animation_tree.set("parameters/Attack/TimeScale/scale", scale)

func get_current_animation_frames_count() -> int:
	#var current_animation_node_name := attack_animation_playback.get_current_node()
	#var current_animation_node: AnimationNodeAnimation = animation_tree.get("parameters/Attack/StateMachine/" + current_animation_node_name)
	return 0

var current_time := 0.0
var last_attack_time := 0.0

var just_entered_state := true
var state_enter_time_point := 0.0
var winding_up := false

func _physics_process(delta: float) -> void:
	current_time += delta

	if !is_running: return

	var cooldown_time := 1.0 / me.stats.get_attack_speed(spell.data.delay_total_time_percent)
	var windup_percent := constants.gcd_attack_delay_cast_percent * (1.0 + spell.data.delay_cast_offset_percent)

	var xfade := 0.2
	var xfade_begin := xfade * windup_percent; var xfade_end := xfade * (1.0 - windup_percent)
	#var xfade_begin := 0.0; var xfade_end := xfade

	var length := attack_animation_playback.get_current_length()
	var time_scale := length / (cooldown_time + xfade_begin + xfade_end)
	#var time_scale := 1.0
	#if winding_up:
	#	time_scale = (length * windup_percent) / (cooldown_time * windup_percent + xfade_begin)
	#else:
	#	time_scale = (length * (1.0 - windup_percent)) / (cooldown_time * (1.0 - windup_percent) + xfade_end)
	set_current_animation_time_scale(time_scale)

	var windup_time := cooldown_time * windup_percent

	#if is not winding up and (animation is not playing or (animation xfade sec from finish and windup_start_point is > xfade sec from here))
	
	var cooldown_time_left := cooldown_time - (current_time - last_attack_time)

	if just_entered_state:
		just_entered_state = false
		state_enter_time_point = current_time
		if cooldown_time_left > windup_time + xfade_begin:
			animation_playback.travel("Idle1")

	if !winding_up && cooldown_time_left <= windup_time + xfade_begin:
		_animation_finished("")
		winding_up = true

	var first_windup_time_left := windup_time - (current_time - state_enter_time_point)
	if first_windup_time_left <= 0 && cooldown_time_left <= 0:
		last_attack_time = current_time
		spell.cast(target)
		winding_up = false

func on_exit() -> void:
	is_running = false
	winding_up = false
