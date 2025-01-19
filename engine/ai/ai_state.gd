class_name AIState extends Node

@onready var ai: AI = get_parent()
@onready var me: Unit = ai.get_parent()

# ai.gd stub
var target: Unit:
	get: return ai.target
var target_position: Vector3:
	get: return ai.target_position
var animation: AnimationController:
	get: return ai.animation
var idle_state: AIIdleState:
	get: return ai.idle_state
var attack_state: AIAttackState:
	get: return ai.attack_state
var cast_state: AICastState:
	get: return ai.cast_state
var run_state: AIRunState:
	get: return ai.run_state
var move_state: AIMoveState:
	get: return ai.move_state
var current_state: AIState:
	get: return ai.current_state
func on_reached_destination_for_going_to_last_location() -> void:
	ai.on_reached_destination_for_going_to_last_location()
func on_stop_move() -> void:
	ai.on_stop_move()
func switch_to_self() -> void:
	ai.switch_to(self)
func switch_to_deffered() -> void:
	ai.switch_to_deffered()

func can_enter() -> bool:
	return true

func can_cancel() -> bool:
	return true

func on_exit() -> void:
	pass
