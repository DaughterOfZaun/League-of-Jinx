class_name AI
extends Node

@onready var me := get_parent() as Unit
@onready var acquisition_range := me.find_child('AcquisitionRange') as Area3D
@onready var attack_range := me.find_child('AttackRange') as Area3D
@onready var cancel_attack_range := me.find_child('CancelAttackRange') as Area3D
@onready var navigation_agent := me.find_child("NavigationAgent3D") as NavigationAgent3D

@export var movement_speed := 330 #TODO: Move to Stats
@export var cursor: Node3D #TODO: Move to InputManager

var is_movement_allowed := false
func set_movement_allowed(to: bool):
	#if is_movement_allowed == to: return
	if to:
		if target != null:
			target_position = target.global_position
		if target_position != Vector3.ZERO and \
		   target_position != navigation_agent.target_position:
			navigation_agent.target_position = target_position
			navigation_agent.avoidance_priority = 0
			is_movement_allowed = true
			if target == null && cursor != null:
				cursor.global_position = target_position
				cursor.visible = true
	elif !to:
		navigation_agent.set_velocity(Vector3.ZERO)
		navigation_agent.avoidance_priority = 1
		is_movement_allowed = false
		if cursor != null:
			cursor.visible = false

var target: Unit = null
var target_position := Vector3.ZERO
var target_position_reached := false
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
	return target.find_child('GameplayRange').overlaps_area(attack_range)
func target_in_cancel_attack_range() -> bool:
	return target.find_child('GameplayRange').overlaps_area(cancel_attack_range)
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
func set_state_and_move_internal(state: Enums.AIState, target: Unit, position: Vector3 = Vector3.ZERO):
	set_state(state)
	self.target = target
	if target != null:
		position = target.global_position
	if !(target_position == position && target_position_reached):
		target_position = position
		target_position_reached = false
		#if is_autoattack_enabled:
		turn_off_auto_attack(Enums.ReasonToTurnOffAA.MOVING)
		#else:
		set_movement_allowed(true)

func _ready():
	me.ai = self
	navigation_agent.velocity_computed.connect(_on_velocity_computed)
	navigation_agent.navigation_finished.connect(_on_navigation_finished)
	on_init()

func _physics_process(delta: float):
	if is_movement_allowed: #and !navigation_agent.is_navigation_finished():
		var next_path_position := navigation_agent.get_next_path_position()
		var dir := me.global_position.direction_to(next_path_position)
		var new_velocity := dir * movement_speed * (1./70.) #* delta
		if navigation_agent.avoidance_enabled:
			navigation_agent.set_velocity(new_velocity)
		else:
			_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector3):
	if is_movement_allowed:
		me.look_at(me.global_position + me.velocity.normalized())
		me.velocity = safe_velocity
		me.move_and_slide()

func _on_navigation_finished():
	if is_movement_allowed:
		set_movement_allowed(false)
		on_reached_destination_for_going_to_last_location()
		on_stop_move()
		pass

var last_order := Enums.OrderType.NONE
func order(order_type: Enums.OrderType, target_position: Vector3, target_unit: Unit):
	if order_type != last_order || target_unit != self.target || target_position != self.target_position:
		print("on_order", ' ', Enums.OrderType.keys()[order_type], ' ', target_position, ' ', target_unit.name if target_unit else null)
		on_order(order_type, target_position, target_unit)
		last_order = order_type

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

var timers := {}
func init_timer(callback: Callable, time: float, oneshot: bool) -> void:
	var timer := timers.get(callback, null) as Timer
	if timer == null:
		timer = Timer.new()
		timer.name = callback.get_method()
		timer.timeout.connect(callback)
		timers[callback] = timer
		add_child(timer)
	timer.one_shot = oneshot
	timer.start(time)

func stop_timer(callback: Callable) -> void:
	var timer := timers.get(callback) as Timer
	if timer != null: timer.stop()

func reset_and_start_timer(callback: Callable) -> void:
	var timer := timers.get(callback) as Timer
	if timer != null: timer.start()

var is_autoattack_enabled := false
func turn_on_auto_attack(target: Unit) -> void:
	if !is_autoattack_enabled:
		is_autoattack_enabled = true
		print("turn_on_auto_attack", ' ', target.name if target else null)
		set_movement_allowed(false)
		self.target = target
func turn_off_auto_attack(reason: Enums.ReasonToTurnOffAA) -> void:
	if is_autoattack_enabled:
		is_autoattack_enabled = false
		print("turn_off_auto_attack", ' ', Enums.ReasonToTurnOffAA.keys()[reason])
		set_movement_allowed(true)
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
	target.buffs.remove(type)

func is_moving() -> bool:
	return is_movement_allowed
func is_movement_stopped() -> bool:
	return !is_movement_allowed

func distance_between_object_and_target_pos_sq(obj: Node3D) -> float:
	return target_position.distance_squared_to(obj.global_position)
