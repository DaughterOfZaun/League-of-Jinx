@tool class_name System extends Effect

@export var visibility_radius: float

@export_group("Simulation")
@export var build_up_time: float
@export var simulate_every_frame: bool
@export var simulate_once_per_frame: bool
@export var simulate_while_off_screen: bool
@export_group("Voice And Sound")
@export var sound_on_create: String
@export var sound_persistent: String
@export var voice_over_on_create: String
@export var voice_over_persistent: String
@export var sounds_play_while_off_screen: bool
@export_group("Metadata")
@export var keep_orientation_after_spell_cast: bool
@export var persist_thru_death: bool

#region Import
@export_group("Import", "import_")
@export_file("*.troy") var import_path: String
@export_dir var import_res_path_1: String
@export_dir var import_res_path_2: String
@export_dir var import_res_path_3: String
@export_dir var import_res_path_4: String
@export_dir var import_res_path_5: String
@export_tool_button("Import") var import := func() -> void:
	var ini := ini_load(import_path)
	res_paths = [
		'/'.join(import_path.split('/').slice(0, -1)),
		import_res_path_1,
		import_res_path_2,
		import_res_path_3,
		import_res_path_4,
		import_res_path_5,
	]; res_paths.reverse()
	set_from_ini_section(ini["System"])
	recreate_groups(ini)
@export_group("")

var groups: Array[Array] = []
func set_from_ini_entry(key_array: Array, value: String) -> void:
	super.set_from_ini_entry(key_array, value)
	match key_array:
		["build-up-time"]: build_up_time = float_parse(value)
		["group-vis"]: visibility_radius = float_parse(value)
		["GroupPart", var i, "Importance"]: array_set(array_get(groups, i, return_array), 2, ["low", "medium", "high"].find(string_parse(value).to_lower()) as GroupImportance)
		["GroupPart", var i, "Type"]: array_set(array_get(groups, i, return_array), 1, ["simple", "complex"].find(string_parse(value).to_lower()) as GroupType)
		["GroupPart", var i]: array_set(array_get(groups, i, return_array), 0, string_parse(value))
		["KeepOrientationAfterSpellCast"]: keep_orientation_after_spell_cast = bool_parse(value)
		["PersistThruDeath"]: persist_thru_death = bool_parse(value)
		#1 ["SelfIllumination"]: self_illumination = float_parse(value) # bool?
		["SimulateEveryFrame"]: simulate_every_frame = bool_parse(value)
		["SimulateOncePerFrame"]: simulate_once_per_frame = bool_parse(value)
		["SimulateWhileOffScreen"]: simulate_while_off_screen = bool_parse(value)
		["SoundOnCreate"]: sound_on_create = string_parse(value)
		["SoundPersistent"]: sound_persistent = string_parse(value)
		["SoundsPlayWhileOffScreen"]: sounds_play_while_off_screen = bool_parse(value)
		["VoiceOverOnCreate"]: voice_over_on_create = string_parse(value)
		["VoiceOverPersistent"]: voice_over_persistent = string_parse(value)

func recreate_groups(ini: Dictionary[String, Array]) -> void:
	for child in get_children():
		child.queue_free()
	for info: Array in groups:
		if len(info) == 0: continue

		#var group := Group.new()
		var group_node := Node3D.new(); group_node.set_script(Group)
		var group: Group = group_node as Variant
		
		group.updating_fields += 1

		group.name = info[0]
		if len(info) > 1: group.group_type = info[1]
		if len(info) > 2: group.group_importance = info[2]

		group.res_paths = res_paths
		group.res_cache = res_cache
		group.res_cache_is_null = res_cache_is_null
		group.set_from_ini_section(ini[group.name])
		
		add_child(group, true)
		group.owner = owner if owner else self

		group.updating_fields -= 1
		group.update_fields()

@onready var particles: Array = find_children("*", "GPUParticles3D", true)
func _ready() -> void:
	for child: GPUParticles3D in particles:
		child.emitting = true

func emit(pos: Vector3) -> void:
	var xfrom := Transform3D.IDENTITY.translated(pos)
	for child: GPUParticles3D in particles:
		var flags := GPUParticles3D.EmitFlags.EMIT_FLAG_POSITION | GPUParticles3D.EmitFlags.EMIT_FLAG_ROTATION_SCALE
		child.emit_particle(xfrom, Vector3.ZERO, Color.WHITE, Color(0, 0, 0, 0), flags)