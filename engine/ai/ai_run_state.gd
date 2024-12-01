class_name AIRunState extends AIState

@onready var character_body := ai.get_parent() as CharacterBody3D
@onready var navigation_agent := me.find_child("NavigationAgent3D") as NavigationAgent3D

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
		idle_state.try_enter()
		on_reached_destination_for_going_to_last_location() #TODO: check
		on_stop_move()

# Running is the only state where voluntary movement is allowed
var is_running := false
func try_enter() -> void:
	if !current_state.can_cancel(): return
	switch_to_self()
	is_running = true
	animation_playback.travel("Run")
	navigation_agent.target_position = target_position * Data.HW2GD
	navigation_agent.avoidance_priority = 0
func on_exit() -> void:
	is_running = false
	navigation_agent.set_velocity(Vector3.ZERO)
	navigation_agent.avoidance_priority = 1
