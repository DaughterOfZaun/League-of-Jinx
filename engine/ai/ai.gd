class_name AI
extends Node

@onready var me := get_parent() as Unit

@onready var animation_tree := me.find_child("AnimationTree") as AnimationTree
@onready var animation_root_playback := animation_tree.get("parameters/playback") as AnimationNodeStateMachinePlayback
@onready var animation_cast_playback := animation_tree.get("parameters/Cast/playback") as AnimationNodeStateMachinePlayback
@onready var animation_spell_playback := animation_tree.get("parameters/Cast/Spell/playback") as AnimationNodeStateMachinePlayback

@onready var acquisition_range := me.find_child('AcquisitionRange') as Area3D
@onready var attack_range := me.find_child('AttackRange') as Area3D
@onready var cancel_attack_range := me.find_child('CancelAttackRange') as Area3D

var target: Unit = null
var target_position := Vector3.INF:
	get:
		if target != null: return target.global_position
		else: return target_position
	set(to):
		target_position = to
		target = null
func set_target_and_target_position(target: Unit, target_position: Vector3) -> void:
	assert(target != null || target_position.is_finite())
	if target != null: self.target = target
	else: self.target_position = target_position

func get_target() -> Unit: return target
func get_target_or_find_target_in_ac_r() -> Unit:
	return target if target != null else find_target_in_ac_r()
func find_target_in_ac_r() -> Unit:
	var areas := acquisition_range.get_overlapping_areas()
	var min_dist := INF;
	var best_match: Unit = null;
	for area in areas:
		var char := area.get_parent() as Unit
		var dist := me.global_position.distance_squared_to(char.global_position)
		if dist < min_dist:
			min_dist = dist
			best_match = char
	return best_match

func target_in_attack_range() -> bool:
	return (target.find_child('GameplayRange') as Radius).overlaps_area(attack_range)
func target_in_cancel_attack_range() -> bool:
	return (target.find_child('GameplayRange') as Radius).overlaps_area(cancel_attack_range)
func get_taunt_target() -> Unit:
	return null
func is_target_lost() -> bool:
	return false
func get_lost_target_if_visible() -> Unit:
	return null

#var pos := Vector3.INF
func clear_target_pos_in_pos() -> void: pass #pos = Vector3.INF
func assign_target_pos_in_pos(position: Vector3) -> void: pass #pos = target.global_position

var state := Enums.AIState.IDLE
func get_state() -> Enums.AIState: return state
func net_set_state(to: Enums.AIState) -> void: set_state(to)
func set_state(to: Enums.AIState) -> void:
	if state != to:
		print("set_state", ' ', Enums.AIState.keys()[to])
		state = to

func set_state_and_close_to_target(state: Enums.AIState, target: Unit) -> void:
	set_state_and_move_internal(state, target)
func set_state_and_move_in_pos(state: Enums.AIState, position: Vector3) -> void:
	set_state_and_move_internal(state, null, position)
func set_state_and_move(state: Enums.AIState, position: Vector3) -> void:
	set_state_and_move_internal(state, null, position)
func set_state_and_move_internal(state: Enums.AIState, target: Unit, target_position: Vector3 = Vector3.INF) -> void:
	set_state(state)
	set_target_and_target_position(target, target_position)
	run_state.try_enter()

@onready var run_state := find_child("AIRunState") as AIRunState
@onready var idle_state := find_child("AIIdleState") as AIIdleState
@onready var cast_state := find_child("AICastState") as AICastState
@onready var attack_state := find_child("AIAttackState") as AIAttackState
@onready var current_state: AIState = idle_state
func switch_to(state: AIState) -> void:
	current_state.exit()
	current_state = state

func _ready() -> void:
	if Engine.is_editor_hint(): return
	me.ai = self
	on_init()

var last_order := Enums.OrderType.NONE
func order(order_type: Enums.OrderType, target_position: Vector3, target_unit: Unit) -> void:
	if order_type != last_order || target_unit != self.target || target_position != self.target_position:
		var target_unit_name := str(target_unit.name) if target_unit else "null"
		print("on_order", ' ', Enums.OrderType.keys()[order_type], ' ', target_position, ' ', target_unit_name)
		on_order(order_type, target_position, target_unit)
		last_order = order_type

func cast(letter: String, target_position: Vector3, target_unit: Unit) -> void:
	var spell: Spell = me.spells[letter]
	var target_unit_name := str(target_unit.name) if target_unit else "null"
	print("on_cast", ' ', letter.to_upper(), ' ', target_position, ' ', target_unit_name)
	cast_state.try_enter(spell, target_position, target_unit)

func on_init() -> bool: return false
func on_order(order_type: Enums.OrderType, target_position: Vector3, target_unit: Unit) -> bool: return false
func on_target_lost(reason: Enums.ReasonForTargetLoss, lost_target: Unit) -> void: pass
func on_taunt_begin() -> void: pass
func on_taunt_end() -> void: pass
func on_fear_begin() -> void: pass
func on_fear_end() -> void: pass
func on_charm_begin() -> void: pass
func on_charm_end() -> void: pass
func on_stop_move() -> void: pass
func on_AI_command() -> void: pass
func on_reached_destination_for_going_to_last_location() -> void: pass
func halt_AI() -> void: pass

var timers: Dictionary[Callable, Timer] = {}
func init_timer(callback: Callable, time: float, oneshot: bool) -> void:
	var timer: Timer = timers.get(callback, null)
	if timer == null:
		timer = Timer.new()
		timer.name = callback.get_method()
		timer.timeout.connect(callback)
		timers[callback] = timer
		add_child(timer)
	timer.one_shot = oneshot
	timer.start(time)

func stop_timer(callback: Callable) -> void:
	var timer: Timer = timers.get(callback)
	if timer != null: timer.stop()

func reset_and_start_timer(callback: Callable) -> void:
	var timer: Timer = timers.get(callback)
	if timer != null: timer.start()

func turn_on_auto_attack(target: Unit) -> void:
	var target_name := str(target.name) if target else "null"
	print("turn_on_auto_attack", ' ', target_name)
	attack_state.try_enter()

func turn_off_auto_attack(reason := Enums.ReasonToTurnOffAA.IMMEDIATELY) -> void:
	print("turn_off_auto_attack", ' ', Enums.ReasonToTurnOffAA.keys()[reason])
	attack_state.exit()

func last_auto_attack_finished() -> bool:
	return true

func get_fear_leash_point() -> Vector3:
	return Vector3.ZERO
func make_flee_point() -> Vector3:
	return Vector3.ZERO
func make_wander_point(leash_point: Vector3, distance: float) -> Vector3:
	return Vector3.ZERO


func can_see_me(target: Unit) -> bool:
	return true
func spell_buff_remove_type(target: Unit, type: Enums.BuffType) -> void:
	target.buffs.remove_by_type(type)

func is_moving() -> bool:
	return run_state.is_running
func is_movement_stopped() -> bool:
	return !run_state.is_running

func distance_between_object_and_target_pos_sq(obj: Node3D) -> float:
	return target_position.distance_squared_to(obj.global_position) * Data.HW2GD
