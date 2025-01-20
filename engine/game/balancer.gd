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

static var frame: int = -1
static func should_reset_stats(obj: Node) -> bool:
	return frame == 0
static func should_update_stats(obj: Node) -> bool:
	return frame == 1
static func should_sync_stats(obj: Node) -> bool:
	return frame == 2
static func should_update_actions(obj: Node) -> bool:
	return frame == 3

var first_frame: bool = true
var generated_frames: bool = false
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
	
	#pack_scene()

var pp: StringName = &"_physics_process"
var args: Array[Variant] = [ 1.0 / Engine.physics_ticks_per_second ]
@onready var root: Node = get_tree().current_scene.find_child("Ahri", false, false)
func generate_frames() -> void:
	for i in range(60):
		#root.propagate_notification(NOTIFICATION_INTERNAL_PHYSICS_PROCESS)
		#root.propagate_notification(NOTIFICATION_PHYSICS_PROCESS)
		root.propagate_call(pp, args)

var packed_scene: PackedScene = PackedScene.new()
func pack_scene() -> void:
	packed_scene.pack(root)