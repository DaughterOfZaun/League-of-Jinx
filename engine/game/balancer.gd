class_name Balancer extends Node

#var tick_rate: float = 0.25
#var physics_fps: int = Engine.physics_ticks_per_second
#var target_frame: int = max(2, floor(physics_fps * tick_rate))

#func _enter_tree() -> void:
#	Balancer.register(self)
#func _exit_tree() -> void:
#	Balancer.unregister(self)

static func register(obj: Node) -> void:
	pass

static func unregister(obj: Node) -> void:
	pass

static var frame := -1
static func should_reset_stats(obj: Node) -> bool:
	return frame == 0
static func should_update_stats(obj: Node) -> bool:
	return frame == 1
static func should_sync_stats(obj: Node) -> bool:
	return frame == 2
static func should_update_actions(obj: Node) -> bool:
	return frame == 3

var first_frame := true
var generated_frames := false
func _physics_process(delta: float) -> void:
	#frame = (Engine.get_physics_frames() - 1) % 15
	frame = (frame + 1) % 15
	
	if first_frame:
		first_frame = false
		return

	if generated_frames: return
	generated_frames = true
	#call_deferred("generate_frames")
	#generate_frames()
	generated_frames = false

var pp := &"_physics_process"
var args := [ 1.0 / Engine.physics_ticks_per_second ]
@onready var root := get_tree().current_scene
func generate_frames() -> void:
	for i in range(30):
		#root.propagate_notification(NOTIFICATION_INTERNAL_PHYSICS_PROCESS)
		#root.propagate_notification(NOTIFICATION_PHYSICS_PROCESS)
		root.propagate_call(pp, args)
