@tool class_name AnimationController extends AnimationTree

@onready var me: Unit = get_parent()
@onready var anim_tree: AnimationTree = me.find_child("AnimationTree", false)
#@onready var anim_player: AnimationPlayer = anim_tree.get_node(anim_tree.anim_player)
@onready var anim_playback: AnimationNodeStateMachinePlayback = anim_tree.get("parameters/playback")

@export var nodes: Dictionary[StringName, StringName] = {}
@export_tool_button("Precompute") var precompute := func() -> void:
	nodes = {}
	#print((anim_tree.tree_root as AnimationNodeStateMachine).get_property_list())
	walk(anim_tree.tree_root, "", "")

func _ready() -> void:
	if Engine.is_editor_hint(): return
	me.animation = self

func path_join(node_path: String, node_name: String) -> String:
	if node_path != "" && node_name != "":
		return node_path + "/" + node_name
	elif node_path != "": return node_path
	elif node_name != "": return node_name
	else: assert(false); return ""

func walk(node: AnimationRootNode, node_name := "", node_path := "") -> void:
	if node is AnimationNodeStateMachine:
		var states := get_states(node)
		for state_name in states:
			var state := states[state_name]
			walk(state, state_name, path_join(node_path, state_name))
	elif node_name not in ["", "Start", "End"]:
		assert(!nodes.has(node_name))
		nodes[StringName(node_name)] = StringName(node_path)

var regex_state := RegEx.create_from_string(r"^states/(\w+)/node$")
func get_states(node: AnimationNodeStateMachine) -> Dictionary[String, AnimationRootNode]:
	var states: Dictionary[String, AnimationRootNode] = {}
	for prop_desc in node.get_property_list():
		var prop_name: String = prop_desc['name']
		var m := regex_state.search(prop_name)
		if m != null:
			var state_name := m.get_string(1)
			var state: AnimationRootNode = node.get(prop_name)
			assert(!states.has(state_name))
			states[state_name] = state
	return states

func play(anim_name: StringName, time_scale := 1.0, loop := false, blend := true, lock := false) -> void:
	anim_playback.travel(nodes[anim_name])

func set_default(anim_name: StringName) -> void:
	play(anim_name)

func set_time_scale(anim_name: StringName, time_scale: float) -> void:
	pass

func override(to_override_anim: StringName, override_anim: StringName) -> void:
	push_warning("unimplemented")

func stop_current_override(anim_name: StringName, blend := true) -> void:
	push_warning("unimplemented")

func clear_override(to_override_anim: StringName) -> void:
	push_warning("unimplemented")

func unlock(blend := true) -> void:
	push_warning("unimplemented")

func pause(pause: bool) -> void:
	push_warning("unimplemented")
