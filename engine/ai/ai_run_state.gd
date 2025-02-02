class_name AIRunState extends AIState #@rollback

@onready var character_body: CharacterBody3D = me as Variant #.find_child("CharacterBody3D", false, false)
@onready var navigation_agent: NavigationAgent3D = me.find_child("NavigationAgent3D", false, false)

func _ready() -> void:
	#if Engine.is_editor_hint(): return
	navigation_agent.velocity_computed.connect(_on_velocity_computed)
	navigation_agent.navigation_finished.connect(_on_navigation_finished)

var speed: float
var delta: float
func _physics_process(delta: float) -> void:
	#if Engine.is_editor_hint(): return

	if is_running: #and !navigation_agent.is_navigation_finished():
		
		#me.global_position = character_body.global_position
		
		var next_path_position := navigation_agent.get_next_path_position()
		var dir := me.global_position.direction_to(next_path_position)
		self.speed = me.stats_perm.get_movement_speed() * Data.HW2GD
		self.delta = delta
		
		var new_velocity := dir * speed #* delta
		if navigation_agent.avoidance_enabled:
			navigation_agent.velocity = new_velocity
		else:
			_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector3) -> void:
	if is_running:
		me.face_dir(safe_velocity)
		var velocity := safe_velocity.normalized() * speed
		character_body.velocity = velocity
		character_body.move_and_slide()
		#me.position += velocity * delta

func _on_navigation_finished() -> void:
	if is_running:
		idle_state.try_enter()
		on_reached_destination_for_going_to_last_location() #TODO: check
		on_stop_move()

func try_enter() -> void:
	if current_state.can_cancel() && can_enter(): enter()

var is_running: bool = false
func enter() -> void:
	switch_to_self()
	is_running = true
	animation.switch_loop(&"Run")
	animation.switch_to_loop()
	#character_body.top_level = true
	#character_body.global_position = me.global_position
	navigation_agent.target_position = target_position * Data.HW2GD
	navigation_agent.avoidance_priority = 0

func on_exit() -> void:
	is_running = false
	#character_body.top_level = false
	#character_body.global_position = me.global_position
	navigation_agent.velocity = Vector3.ZERO
	navigation_agent.avoidance_priority = 1
