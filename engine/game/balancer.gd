class_name Balancer extends Node

#var tick_rate: float = 0.25
#var physics_fps: int = Engine.physics_ticks_per_second
#var target_frame: int = max(2, floor(physics_fps * tick_rate))

#func _enter_tree() -> void:
#	Balancer.register(self)
#func _exit_tree() -> void:
#	Balancer.unregister(self)

static var free_ids: Array[int] = []
static var _objs: Array[Variant] = [ null ]
static var _vars: Array[Variant] = [ null ]
static var static_free_ids: Array[int] = []
static var _static_objs: Array[Variant] = [ null ]
static var _static_vars: Array[Variant] = [ null ]

static func register(obj: Object, obj_vars_size: int = 0) -> void:
	@warning_ignore("unsafe_property_access")
	obj._id = _register(obj, obj_vars_size, obj._id, free_ids, _objs, _vars)

static func register_static(obj: Object, obj_vars_size: int = 0) -> void:
	@warning_ignore("unsafe_property_access")
	obj._static_id = _register(obj, obj_vars_size, obj._static_id, static_free_ids, _static_objs, _static_vars)

static func _register(obj: Object, obj_vars_size: int, id: int, free_ids: Array[int], objs: Array, vars: Array) -> int:
	if id != 0: return id

	var obj_vars: Array[Variant] = []
	obj_vars.resize(obj_vars_size)
	if free_ids.size() == 0:
		id = objs.size()
		objs.push_back(obj)
		vars.push_back(obj_vars)
	else:
		id = free_ids.pop_back()
		objs[id] = obj
		vars[id] = obj_vars
	
	if save_method_name in obj:
		instance.save.connect(obj[save_method_name])
	if load_method_name in obj:
		instance.load.connect(obj[load_method_name])

	return id

static func unregister(obj: Object) -> void:

	@warning_ignore("unsafe_property_access")
	var id: Variant = obj._id
	if id == 0: return

	@warning_ignore("unsafe_property_access")
	obj._id = 0
	
	free_ids.push_back(id)
	_vars[id] = null
	_objs[id] = null

static var frame: int = -1
static func should_reset_stats(obj: Object) -> bool:
	return frame == 0
static func should_update_stats(obj: Object) -> bool:
	return frame == 1
static func should_sync_stats(obj: Object) -> bool:
	return frame == 2
static func should_update_actions(obj: Object) -> bool:
	return frame == 3

static var is_ff := false
#static var is_updating_stats: bool = false
func _physics_process(delta: float) -> void:
	#frame = (Engine.get_physics_frames() - 1) % 15
	frame = (frame + 1) % 4
	
	#is_updating_stats = true
	#root.propagate_call(&"_reset_stats")
	#root.propagate_call(&"_update_stats")
	#root.propagate_call(&"_sync_stats")
	#is_updating_stats = false
	#root.propagate_call(&"_update_actions")

	save_state()
	current_moment = (current_moment + 1) % history_length

	#pack_scene()

var generated_frames: bool = false
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
const history_length := ekko_r_afterimage_delay_sec * fps

static var instance: Balancer

var history_of_objs: Array[Array] = []
var history_of_vars: Array[Array] = []
var current_moment: int = 0
func _init() -> void:
	history_of_objs.resize(history_length)
	history_of_vars.resize(history_length)
	instance = self

	#var args := PackedStringArray()
	#var pid := OS.create_instance(args)
	#print(pid)

func _not_ready() -> void:
	var path := OS.get_executable_path()
	#var args := OS.get_cmdline_args()
	var args := PackedStringArray()

	var user_args := OS.get_cmdline_user_args()
	if user_args.has("--second"): return
	
	#args.append("--headless")
	
	#var loop: SceneTree = Engine.get_main_loop()
	#var res_scene_path := tree.current_scene.scene_file_path
	var res_scene_path := "res://"
	var global_scene_path := ProjectSettings.globalize_path(res_scene_path)
	
	args.append("--path")
	args.append(global_scene_path)
	
	args.append("--")
	args.append("--second")

	var pipe := OS.execute_with_pipe(path, args, true)
	print('OS.execute_with_pipe(', path, ', ', args, ', ', true, ') -> ', pipe)
	var stdio: FileAccess = pipe["stdio"]
	var stderr: FileAccess = pipe["stderr"]
	var pid: int = pipe["pid"]

	process_io = stdio
	var thread := Thread.new()
	thread.start(read_process_output)

var process_io: FileAccess
func read_process_output() -> void:
	while process_io.is_open() and process_io.get_error() == OK:
		print("STDIO: ", process_io.get_line())

@onready var tree := get_tree()
#const rollback_group_name := &"rollback"
signal save(); const save_method_name := &"_save"
signal load(); const load_method_name := &"_load"

func save_state() -> void:
	save.emit()
	history_of_objs[current_moment] = _objs.duplicate(false)
	history_of_vars[current_moment] = _vars.duplicate(true)

func load_state() -> void:
	_objs = history_of_objs[current_moment]
	_vars = history_of_vars[current_moment]
	load.emit()
