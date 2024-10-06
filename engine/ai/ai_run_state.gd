class_name AIRunState
extends Node

@onready var ai := get_parent() as AI
@onready var me := ai.get_parent() as Unit
@onready var character_body := ai.get_parent() as CharacterBody3D
@onready var navigation_agent := me.find_child("NavigationAgent3D") as NavigationAgent3D
@onready var animation_tree := me.find_child("AnimationTree") as AnimationTree
@onready var animation_root_playback := animation_tree.get("parameters/playback") as AnimationNodeStateMachinePlayback

func _ready() -> void:
	if Engine.is_editor_hint(): return
	navigation_agent.velocity_computed.connect(_on_velocity_computed)
	navigation_agent.navigation_finished.connect(_on_navigation_finished)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return

	if is_running: #and !navigation_agent.is_navigation_finished():
		var next_path_position := navigation_agent.get_next_path_position()
		var dir := me.global_position.direction_to(next_path_position)
		var new_velocity := dir * me.stats.get_movement_speed() * Data.HW2GD #* delta
		if navigation_agent.avoidance_enabled:
			navigation_agent.set_velocity(new_velocity)
		else:
			_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector3) -> void:
	if is_running:
		me.face_dir(safe_velocity)
		character_body.velocity = safe_velocity
		character_body.move_and_slide()

func _on_navigation_finished() -> void:
	if is_running:
		exit()
		on_reached_destination_for_going_to_last_location()
		on_stop_move()

# ai.gd stub
var target: Unit:
	get: return ai.target
	set(v): ai.target = v
var target_position: Vector3:
	get: return ai.target_position
	set(v): ai.target_position = v
func on_reached_destination_for_going_to_last_location() -> void:
	ai.on_reached_destination_for_going_to_last_location()
func on_stop_move() -> void:
	ai.on_stop_move()

# Running is the only state where voluntary movement is allowed
var is_running := false
func enter() -> void:
	if target != null:
		target_position = target.global_position
	if target_position != Vector3.ZERO and \
		target_position != navigation_agent.target_position:
		navigation_agent.target_position = target_position
		navigation_agent.avoidance_priority = 0
		animation_root_playback.travel("Run")
		is_running = true
func exit() -> void:
	navigation_agent.set_velocity(Vector3.ZERO)
	navigation_agent.avoidance_priority = 1
	animation_root_playback.travel("Idle")
	is_running = false
