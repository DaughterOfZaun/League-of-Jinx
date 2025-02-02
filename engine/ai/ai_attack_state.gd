class_name AIAttackState extends AIState #@rollback

@onready var root: Node = get_tree().current_scene
@onready var constants: Constants = root.get_node("%Constants")

var spell: Spell
var next_spell: Spell
func _ready() -> void:
	await me.ready
	spell = me.spells.basic[0]
	next_spell = me.spells.basic[1]

func try_enter() -> void:
	if current_state.can_cancel() && can_enter(): enter()

var is_running: bool = false
func enter() -> void:
	switch_to_self()
	is_running = true
	just_entered_state = true
	animation.switch_loop(&"Idle1")
	me.face_direction(target.position_3d)

var spell_i: int = 1
func _animation_finished(anim_name: StringName) -> void:
	spell = next_spell
	animation.play(spell.data.animation_name)
	spell_i = (spell_i + 1) % (len(me.spells.basic) + 1)
	if spell_i < len(me.spells.basic):
		next_spell = me.spells.basic[spell_i]
	else:
		next_spell = me.spells.crit

var current_time: float = 0.0
var last_attack_time: float = 0.0

var just_entered_state: bool = true
var state_enter_time_point: float = 0.0
var winding_up: bool = false

func _physics_process(delta: float) -> void:
	current_time += delta

	if !is_running: return

	var cooldown_time := 1.0 / me.stats_perm.get_attack_speed(spell.data.delay_total_time_percent)
	var windup_percent := constants.gcd_attack_delay_cast_percent * (1.0 + spell.data.delay_cast_offset_percent)
	var windup_time := cooldown_time * windup_percent

	var xfade := 0.2
	#var xfade_begin := xfade * windup_percent; var xfade_end := xfade * (1.0 - windup_percent)
	var xfade_begin := 0.0; var xfade_end := xfade

	#var length := attack_animation_playback.get_current_length()
	##var animation_windup_length := length * (spell.data.cast_frame / get_current_animation_frames_count())
	var animation_windup_length := spell.data.cast_frame * (1.0 / 30.0)
	##var time_scale := length / (cooldown_time + xfade_begin + xfade_end)
	##var time_scale := ((9.0/28.0)*0.9677) / (1.6*(1.0-0.065)*0.3*(1.0-0.236))
	var time_scale := 1.0
	#if winding_up:
	time_scale = animation_windup_length / (windup_time + xfade_begin)
	#else:
	#	time_scale = (length - animation_windup_length) / (cooldown_time - windup_time + xfade_end)
	animation.set_time_scale(spell.data.animation_name, time_scale)


	#if is not winding up and (animation is not playing or (animation xfade sec from finish and windup_start_point is > xfade sec from here))
	
	var cooldown_time_left := cooldown_time - (current_time - last_attack_time)

	if just_entered_state:
		just_entered_state = false
		state_enter_time_point = current_time
		if cooldown_time_left > windup_time + xfade_begin:
			animation.play("Idle1")

	if !winding_up && cooldown_time_left <= windup_time + xfade_begin:
		me.face_direction(target.position_3d)
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
