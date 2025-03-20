class_name Balancer extends Node

static var free_ids: Array[int] = []
static var _objs: Array[Variant] = [ null ]
static var _vars: Array[Variant] = [ null ]

signal save();
const save_method_name := &"_save"
signal load();
const load_method_name := &"_load"
signal process(delta: float);
const process_method_name := &"_network_process"

static func register(obj: Object, obj_vars_size: int = 0) -> void:
	@warning_ignore("unsafe_property_access")
	obj._id = _register(obj, obj_vars_size, obj._id)
	@warning_ignore("unsafe_property_access")
	obj._vars = _vars[obj._id]

static func register_static(obj: Object, obj_vars_size: int = 0) -> void:
	@warning_ignore("unsafe_property_access")
	obj._static_id = _register(obj, obj_vars_size, obj._static_id)
	@warning_ignore("unsafe_property_access")
	obj._static_vars = _vars[obj._static_id]

static func _register(obj: Object, obj_vars_size: int, id: int) -> int:
	if id != 0: return id

	var obj_vars: Array[Variant] = []
	obj_vars.resize(obj_vars_size)
	#if free_ids.size() == 0:
	id = _objs.size()
	_objs.push_back(obj)
	_vars.push_back(obj_vars)
	#else:
	#	id = free_ids.pop_back()
	#	_objs[id] = obj
	#	_vars[id] = obj_vars

	#id = _vars.size()
	#_objs.push_back(obj)
	#_vars.resize(id + obj_vars_size)
	
	#if obj.has_method(save_method_name):
	#	instance.save.connect(obj[save_method_name])
	#if obj.has_method(load_method_name):
	#	instance.load.connect(obj[load_method_name])
	#if obj.has_method(process_method_name):
	#	instance.process.connect(obj[process_method_name])

	return id

static func unregister(obj: Object) -> void:

	#@warning_ignore("unsafe_property_access")
	#var id: Variant = obj._id
	#if id == 0: return

	var node := obj as Node
	if node:
		#if node.is_inside_tree():
		#	node.get_parent().remove_child(node)
		node.queue_free()

	#if obj.has_method(save_method_name):
	#	instance.save.disconnect(obj[save_method_name])
	#if obj.has_method(load_method_name):
	#	instance.load.disconnect(obj[load_method_name])
	#if obj.has_method(process_method_name):
	#	instance.process.disconnect(obj[process_method_name])

	#@warning_ignore("unsafe_property_access")
	#obj._id = 0
	
	#free_ids.push_back(id)
	#_vars[id] = null
	#_objs[id] = null

var frame := 0
static var is_updating_stats: bool = false
func _physics_process(delta: float) -> void:
	frame += 1

	generate_frames()

	is_updating_stats = true
	#root.propagate_call(&"_reset_stats")
	#root.propagate_call(&"_update_stats")
	#root.propagate_call(&"_sync_stats")
	is_updating_stats = false
	#root.propagate_call(&"_update_actions")

	#if Engine.get_physics_frames() == 10:
	#	var fa := FileAccess.open("res://engine/game/cache/dump.txt", FileAccess.WRITE)
	#	fa.store_string(var_to_str(bytes_to_var(var_to_bytes(_vars))))
	#	fa.close()

	#if frame % 8 == 0:
	#save_state.call_deferred()
	#save_state()

	#pack_scene()

var generated_frames: bool = false

var fixed_delta: float = 1.0 / fps
var process_args: Array[Variant] = [ fixed_delta ]
@onready var root: Node = get_tree().current_scene #.find_child("Ahri", false, false)

func _enter_tree() -> void:
	var tree: SceneTree = get_tree()
	tree.node_added.connect(func(obj: Node) -> void:
		if obj.has_method(process_method_name):
			instance.process.connect(obj[process_method_name])
	)
	tree.node_removed.connect(func(obj: Node) -> void:
		if obj.has_method(process_method_name):
			instance.process.disconnect(obj[process_method_name])
	)

func generate_frames() -> void:
	generated_frames = true
	for i in range(8):
		#root.propagate_notification(NOTIFICATION_INTERNAL_PHYSICS_PROCESS)
		#root.propagate_notification(NOTIFICATION_PHYSICS_PROCESS)
		#tree.call_group(&"rollback", process_method_name, fixed_delta)
		#root.propagate_call(process_method_name, process_args)
		process.emit(fixed_delta)
	generated_frames = false

var packed_scene: PackedScene = PackedScene.new()
func pack_scene() -> void:
	packed_scene.pack(root)

const fps := 30
const ekko_r_afterimage_delay_sec := 4
const history_length := ekko_r_afterimage_delay_sec * fps

static var instance: Balancer

var history_of_objs: Array[Array] = []
var history_of_vars: Array[Array] = []
#var history_of_vars: Array[PackedByteArray] = []
var current_moment: int = -1
static var is_in_thread := false
func _init() -> void:
	history_of_objs.resize(history_length)
	history_of_vars.resize(history_length)
	instance = self

#@onready var tree := get_tree()
#const rollback_group_name := &"rollback"

func save_state() -> void:

	current_moment = (current_moment + 1) % history_length
	
	save.emit()
	history_of_objs[current_moment] = _objs
	#history_of_objs[current_moment].assign(_objs)
	#history_of_vars[current_moment] = var_to_bytes(_vars)
	history_of_vars[current_moment] = _vars.duplicate(true)
	#history_of_vars[current_moment].assign(_vars)

func load_state() -> void:
	
	if current_moment == -1: return

	_objs = history_of_objs[current_moment]
	#_objs.assign(history_of_objs[current_moment])
	#_vars = bytes_to_var(history_of_vars[current_moment])
	_vars = history_of_vars[current_moment]
	#_vars.assign(history_of_vars[current_moment])
	load.emit()
