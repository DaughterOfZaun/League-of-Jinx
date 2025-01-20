class_name SecondTest extends Node

@export var player: Champion
@export var enemy: Champion

func _ready() -> void:
	set_physics_process(false)

var first_frame: bool = true
var player_clone: Champion
var enemy_clone: Champion
static var is_clonning: bool = false
func _physics_process(delta: float) -> void:
	if first_frame:
		first_frame = false
		is_clonning = true
		annotate(player)
		#annotate(enemy)
		var root := get_tree().current_scene
		player_clone = _duplicate(player)
		#enemy_clone = _duplicate(enemy)
		var group := create_thread_group()
		group.add_child(player_clone)
		#group.add_child(enemy_clone)
		root.add_child(group)
		#_set_scripts(player, player_clone)
		#_duplicate_properties(player, player, player_clone)
		_duplicate_properties_v2(player_clone)
		#_duplicate_properties(enemy, enemy, enemy_clone)
		is_clonning = false
	else:
		#_duplicate_properties(player, player, player_clone)
		_duplicate_properties_v2(player_clone)

const DUPLICATE_FROM_EDITOR = 16

const DUPLICATE_ALL = 0 \
	| DUPLICATE_SIGNALS \
	| DUPLICATE_GROUPS \
	| DUPLICATE_SCRIPTS \
	#| DUPLICATE_USE_INSTANTIATION \
	#| DUPLICATE_FROM_EDITOR \
	| 0

func should_skip_obj(node: Node) -> bool:
	return node is UnitData \
		or node is SpellData \
		or node is Node2D \
		or node is Control \
		or node is CustomLight2D \
		or node is NavigationAgent3D \
		or node is CharacterBody3D \
		or node.name == "SkinnedMesh" \
		or node is AnimationTree \
		or node is SpellIndicator \
		or node is Radius \
		or node is Skeleton3D #HACK:

func should_skip_prop(prop: Dictionary) -> bool:
	return (prop.usage & (PROPERTY_USAGE_GROUP | PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SUBGROUP)) \
		|| (prop.type == TYPE_OBJECT || prop.type == TYPE_ARRAY) \
		|| (prop.name == script_property_name || prop.name == owner_property_name) \
		|| (prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE == 0)

const should_skip_meta_name := &"should_skip_obj"
const props_to_duplicate_meta_name := &"props_to_duplicate"
func annotate(from: Node) -> void:
	var skip := should_skip_obj(from)
	from.set_meta(should_skip_meta_name, skip)
	if skip: return
	var props_to_duplicate: Array[StringName] = []
	for prop in from.get_property_list():
		if should_skip_prop(prop): continue
		props_to_duplicate.append(prop.name)
	from.set_meta(props_to_duplicate_meta_name, props_to_duplicate)
	for i in range(from.get_child_count()):
		annotate(from.get_child(i))

const cloned_from_meta_name := &"cloned_from"
func _duplicate(from: Node) -> Node:
	#return node.duplicate(DUPLICATE_ALL)
	var node: Node
	var script: GDScript = from.get_script()
	if script != null: node = script.new()
	else: node = ClassDB.instantiate(from.get_class())

	node.set_meta(cloned_from_meta_name, from)
	node.set_physics_process(false)
	node.set_process(false)
	
	node.name = from.name
	var j := 0
	for i in range(from.get_child_count()):
		var from_child := from.get_child(i)
		#if should_skip_obj(from_child):
		if from_child.get_meta(should_skip_meta_name):
			j += 1; continue
		var dup := _duplicate(from_child)
		node.add_child(dup)
		#node.move_child(dup, i)
	return node

func _set_scripts(from: Node, to: Node) -> void:
	var j := 0
	for i in range(from.get_child_count()):
		var from_child := from.get_child(i)
		if should_skip_obj(from_child):
			j += 1; continue
		to.get_child(i - j).set_script(from_child.get_script())

const script_property_name = &"script"
const owner_property_name = &"owner"
func _duplicate_properties_v2(to: Node) -> void:
	var from: Node = to.get_meta(cloned_from_meta_name)
	for prop_name: StringName in from.get_meta(props_to_duplicate_meta_name):
		var value: Variant = from[prop_name]
		to.set(prop_name, value)
	for i in range(to.get_child_count()):
		_duplicate_properties_v2(to.get_child(i))

func _duplicate_properties(from_root: Node, from: Node, to: Node) -> void:
	for prop in from.get_property_list():
		if should_skip_prop(prop): continue
		var prop_name: StringName = prop.name
		var value: Variant = from[prop_name]
		var type := typeof(value)
		if type == TYPE_OBJECT:
			#push_warning('Object properties are not supported in duplicate. ', from_root.get_path_to(from), ':', prop_name)
			value = _duplicate_obj_property(from_root, from, to, value)
		elif type == TYPE_ARRAY:
			#push_warning('Array properties are not supported in duplicate. ', from_root.get_path_to(from), ':', prop_name)
			pass
		
		to[prop_name] = value
		#to.set(prop_name, value)
	
	var j := 0
	for i in range(from.get_child_count()):
		var from_child := from.get_child(i)
		if should_skip_obj(from_child):
			j += 1; continue
		_duplicate_properties(from_root, from_child, to.get_child(i - j))

func _duplicate_obj_property(from_root: Node, from: Node, to: Node, value: Variant) -> Variant:
	var property_node := value as Node
	if property_node && !should_skip_obj(property_node) && (from_root == property_node || from_root.is_ancestor_of(property_node)):
		value = to.get_node(from.get_path_to(property_node))
	return value

func create_thread_group() -> Node:
	var node := Node.new()
	#node.process_thread_group = PROCESS_THREAD_GROUP_SUB_THREAD
	return node
