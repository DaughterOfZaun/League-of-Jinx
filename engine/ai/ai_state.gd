class_name AIState
extends Node

@onready var ai := get_parent() as AI
@onready var me := ai.get_parent() as Unit

# ai.gd stub
var target: Unit:
	get: return ai.target
var target_position: Vector3:
	get: return ai.target_position
var animation_tree: AnimationTree:
	get: return ai.animation_tree
var animation_playback: AnimationNodeStateMachinePlayback:
	get: return ai.animation_playback
var idle_state: AIIdleState:
	get: return ai.idle_state
var attack_state: AIAttackState:
	get: return ai.attack_state
var cast_state: AICastState:
	get: return ai.cast_state
var run_state: AIRunState:
	get: return ai.run_state
var current_state: AIState:
	get: return ai.current_state
func on_reached_destination_for_going_to_last_location() -> void:
	ai.on_reached_destination_for_going_to_last_location()
func on_stop_move() -> void:
	ai.on_stop_move()
func switch_to_self() -> void:
	ai.switch_to(self)

func can_cancel() -> bool:
	return true

func on_exit() -> void:
	pass
