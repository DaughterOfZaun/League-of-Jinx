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
	#animation_tree.animation_started.connect(func(anim_name: StringName) -> void: print('animation_started ', anim_name))

var is_running := false
func try_enter() -> void:
	if !current_state.can_cancel(): return
	switch_to_self()
	is_running = true
	me.face_direction(target.global_position)
	#animation_tree.animation_finished.connect(_animation_finished)

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
var last_windup_time := 0.0
var last_animation_change_time := 0.0

var animation_winding_up := false
var winding_up := false
var idling := false

func _physics_process(delta: float) -> void:
	current_time += delta

	if !is_running: return

	var cooldown_time := 1.0 / me.stats.get_attack_speed(spell.data.delay_total_time_percent)
	var windup_percent := constants.gcd_attack_delay_cast_percent * (1.0 + spell.data.delay_cast_offset_percent)

	var xfade := 0.2
	var xfade1 := 0.0 #xfade * windup_percent
	var xfade2 := xfade #xfade * (1.0 - windup_percent)

	var length := attack_animation_playback.get_current_length()
	var time_scale := 1.0 #length / (cooldown_time + xfade1 + xfade2)
	if winding_up:
		time_scale = (length * windup_percent) / (cooldown_time * windup_percent + xfade1)
	else:
		time_scale = (length * (1.0 - windup_percent)) / (cooldown_time * (1.0 - windup_percent) + xfade2)
	set_current_animation_time_scale(time_scale)

	var windup_time := cooldown_time * windup_percent
	
	var windup_time_left := windup_time - (current_time - last_windup_time)
	var cooldown_time_left := cooldown_time - (current_time - last_attack_time)
	var animation_time_left := (cooldown_time + xfade1 + xfade2) - (current_time - last_animation_change_time)

	if !animation_winding_up:
		if cooldown_time_left <= windup_time + xfade1:
			animation_winding_up = true
			last_animation_change_time = current_time
			switch_to_spell_animation()
			idling = false
		elif !idling:
			last_animation_change_time = current_time
			animation_playback.travel("Idle1")
			idling = true
	elif animation_time_left <= xfade1 + xfade2:
		last_animation_change_time = current_time
		_animation_finished("")
		idling = false

	if !winding_up:
		if cooldown_time_left <= windup_time:
			winding_up = true
			last_windup_time = current_time
	elif windup_time_left <= 0 && cooldown_time_left <= 0:
		last_attack_time = current_time
		winding_up = false
		print('ATTACK!')
		spell.cast(target, target.global_position)

func on_exit() -> void:
	#animation_tree.animation_finished.disconnect(_animation_finished)
	is_running = false
	animation_winding_up = false
	winding_up = false
	idling = false
