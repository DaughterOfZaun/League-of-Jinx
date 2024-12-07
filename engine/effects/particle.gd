class_name Particle
extends Node3DExt

static var root: Node
func _ready() -> void:
	root = get_tree().current_scene

var bind_obj: Unit = null
var bind_bone_idx := -1
func _physics_process(delta: float) -> void:
	if bind_obj != null:
		if bind_bone_idx != -1:
			global_position = bind_obj.get_bone_global_position(bind_bone_idx)
		else:
			global_position = bind_obj.global_position

static func create(effect: PackedScene = null, effect_for_other_team: PackedScene = null) -> Particle:
	assert(effect != null || effect_for_other_team != null)
	var particle := Particle.new()
	var system: System = effect.instantiate()
	particle.add_child(system)
	root.add_child(particle)
	return particle

func remove() -> void:
	queue_free()

func fow(fow_team := Enums.Team.UNKNOWN, fow_visibility_radius := 0.0) -> Particle:
	return self
func flags(flags := 0) -> Particle:
	return self
func specific(
	specific_team_only := Enums.Team.UNKNOWN,
	specific_team_only_override := Enums.Team.UNKNOWN,
	specific_unit_only: Unit = null,
	use_specific_unit := false
) -> Particle:
	return self
func bind(
	bind_object: Unit = null,
	bone_name: StringName = "",
	pos := Vector3.INF,
) -> Particle:
	assert(bind_object != null || pos != Vector3.INF)
	if pos.is_finite():
		position_3d = pos
	elif bind_object != null:
		self.bind_obj = bind_object
		if bone_name != "":
			self.bind_bone_idx = bind_object.get_bone_idx(bone_name)
	return self
func target(
	target_object: Unit = null,
	target_bone_name: StringName = "",
	target_pos := Vector3.INF,
) -> Particle:
	return self
func more_flags(
	send_if_on_screen_or_discard := false,
	persists_through_reconnect := false,
	bind_flex_to_owner_par := false,
	follows_ground_tilt := false,
	faces_target := false,
) -> Particle:
	return self
func orient(orient_towards: Unit = null) -> Particle:
	return self
