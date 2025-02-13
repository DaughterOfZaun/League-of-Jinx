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
	#call_deferred("generate_frames")
	#generate_frames()
	
	#pack_scene()

	if history_slice_to_override > history_slices_count - 1:
		history_slice_to_override = 120
		load_state()
		generate_frames()
		history_slice_to_override = 0

	#const MAX_INT := (1 << 31) - 1
	#if history_slice_to_override > history_slices_count - 1:
	#	if !is_ff:
	#		history_slice_to_override = 120
	#		load_state()
	#		Engine.physics_ticks_per_second = MAX_INT
	#		Engine.max_physics_steps_per_frame = 128
	#		is_ff = true
	#		ff_start_frame = Engine.get_process_frames()
	#	else:
	#		history_slice_to_override = 0
	#		Engine.physics_ticks_per_second = 60
	#		Engine.max_physics_steps_per_frame = 8
	#		is_ff = false
	#		print(Engine.get_process_frames() - ff_start_frame)
	#	print(is_ff)
	
	if !is_ff: save_state()

	#if history_slice_to_override < 0:
	#	history_slice_to_override = 0
	#	root.propagate_call(&"set_physics_process", [true], true)
	#	self.set_physics_process(true)
	#	print('forward')
	#	time_dir = true
	#if history_slice_to_override > history_slices_count - 1:
	#	history_slice_to_override = history_slices_count - 1
	#	root.propagate_call(&"set_physics_process", [false], true)
	#	self.set_physics_process(true)
	#	print('backward')
	#	time_dir = false

	#if time_dir: save_state()
	#else: load_state()

	if time_dir: history_slice_to_override += 1
	else: history_slice_to_override -= 1

var time_dir := true
var is_ff := false
var ff_start_frame := 0

var pp: StringName = &"_physics_process"
var args: Array[Variant] = [ 1.0 / Engine.physics_ticks_per_second ]
@onready var root: Node = get_tree().current_scene #.find_child("Ahri", false, false)
func generate_frames() -> void:
	generated_frames = true
	for i in range(120):
		root.propagate_notification(NOTIFICATION_INTERNAL_PHYSICS_PROCESS)
		root.propagate_notification(NOTIFICATION_PHYSICS_PROCESS)
		#root.propagate_call(pp, args)
	generated_frames = false

var packed_scene: PackedScene = PackedScene.new()
func pack_scene() -> void:
	packed_scene.pack(root)

const fps := 60
const ekko_r_afterimage_delay_sec := 4
const history_slices_count := ekko_r_afterimage_delay_sec * fps
const max_objs_count := 1000
const max_obj_props_count := 30

var history_nodes: Array[Array] = []
var history_vars: Array[Array] = []
var history_slice_to_override := 0
func _init() -> void:
	history_nodes.resize(history_slices_count)
	history_vars.resize(history_slices_count)
	for i in range(history_slices_count):
		var a := []; a.resize(max_objs_count)
		history_vars[i] = a
		#for j in range(max_objs_count):
		#	var b := []; b.resize(max_obj_props_count)
		#	a[j] = b

@onready var tree := get_tree()
const rollback_group_name := &"rollback"
const save_method_name := &"_save"
const load_method_name := &"_load"
func save_state() -> void:
	
	tree.call_group(rollback_group_name, save_method_name)

	var nodes := tree.get_nodes_in_group(rollback_group_name)
	var history_slice: Array = history_vars[history_slice_to_override]
	
	history_nodes[history_slice_to_override] = nodes
	#history_slice_to_override = (history_slice_to_override + 1) % history_vars.size()
	
	for i in nodes.size():
		var node := nodes[i]
		@warning_ignore("unsafe_property_access")
		var node_vars: Array[Variant] = node._vars
		
		history_slice[i] = node_vars.duplicate(true)

		#var saved_vars: Array = history_slice[i]
		#saved_vars.assign(node_vars)
		
		#saved_vars.resize(node_vars.size())
		#for j in node_vars.size():
		#	var v: Variant = node_vars[j]
		#	match typeof(v):
		#		TYPE_ARRAY: saved_vars[j] = (v as Array).duplicate()
		#		TYPE_DICTIONARY: saved_vars[j] = (v as Dictionary).duplicate()
		#		_: saved_vars[j] = v

func load_state() -> void:
	
	var nodes := history_nodes[history_slice_to_override]
	var history_slice := history_vars[history_slice_to_override]

	#history_slice_to_override = (history_slice_to_override - 1) % history_vars.size()

	for i in nodes.size():
		var node: Node = nodes[i]
		#@warning_ignore("unsafe_property_access")
		#var node_vars: Array[Variant] = node._vars
		var saved_vars: Array = history_slice[i]
		
		@warning_ignore("unsafe_property_access")
		node._vars = saved_vars.duplicate(true)

		#node_vars.assign(saved_vars)
		
		#node_vars.resize(saved_vars.size())
		#for j in saved_vars.size():
		#	var v: Variant = saved_vars[j]
		#	match typeof(v):
		#		TYPE_ARRAY: (node_vars[j] as Array).assign(v)
		#		TYPE_DICTIONARY: (node_vars[j] as Dictionary).assign(v)
		#		_: node_vars[j] = v

	tree.call_group(rollback_group_name, load_method_name)
