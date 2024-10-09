class_name AIState
extends Node

@onready var ai := get_parent() as AI
@onready var me := ai.get_parent() as Unit

# ai.gd stub
var target: Unit:
	get: return ai.target
var target_position: Vector3:
	get: return ai.target_position
var animation_root_playback: AnimationNodeStateMachinePlayback:
	get: return ai.animation_root_playback
func on_reached_destination_for_going_to_last_location() -> void:
	ai.on_reached_destination_for_going_to_last_location()
func on_stop_move() -> void:
	ai.on_stop_move()
func switch_to_deffered_state() -> void:
	ai.switch_to_deffered_state()

func enter() -> void:
	pass

func exit() -> void:
	pass
