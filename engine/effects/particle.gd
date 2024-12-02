class_name Particle
extends Node3DExt

static func create(effect: PackedScene = null, effect_for_other_team: PackedScene = null) -> Particle:
	push_warning("Particle.create is unimplemented")
	assert(effect != null || effect_for_other_team != null)
	return Particle.new() #TODO: add_child

func remove() -> void:
	push_warning("Particle.remove is unimplemented")

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
	bone_name := "",
	pos := Vector3.INF,
) -> Particle:
	return self
func target(
	target_object: Unit = null,
	target_bone_name := "",
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
