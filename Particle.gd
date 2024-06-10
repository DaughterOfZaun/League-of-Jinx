class_name Particle
extends GPUParticles2D

static func create(effect_name := "", effect_name_for_other_team := ""):
	pass
func fow(fow_team := Enums.TeamID.UNKNOWN, fow_visibility_radius := 0.0) -> Particle:
	return self
func flags(flags := 0) -> Particle:
	return self
func specific(
	specific_team_only := Enums.TeamID.UNKNOWN,
	specific_team_only_override := Enums.TeamID.UNKNOWN,
	specific_unit_only: Character = null,
	use_specific_unit := false
) -> Particle:
	return self
func bind(
	bind_object: Character = null,
	bone_name := "",
	pos := Vector3.INF,
) -> Particle:
	return self
func target(
	target_object: Character = null,
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
func orient(orient_towards: Character = null) -> Particle:
	return self

func remove() -> void:
	pass
