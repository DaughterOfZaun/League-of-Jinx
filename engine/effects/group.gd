@tool class_name Group extends Effect

var Curve_ONE := new_one()
func new_one() -> Curve:
	var c := Curve.new()
	c.add_point(Vector2(0, 1))
	c.add_point(Vector2(1, 1))
	return c
func or_one(c: Curve) -> Curve:
	return c if c else Curve_ONE

func set_shader_parameter_curve(m: ShaderMaterial, key: String, value_x: Curve = null, value_y: Curve = null, value_z: Curve = null) -> void:
	var t := m.get_shader_parameter(key) as CurveXYZTexture
	if !t: t = CurveXYZTexture.new()
	t.curve_x = or_one(value_x)
	t.curve_y = or_one(value_y)
	t.curve_z = or_one(value_z)
	m.set_shader_parameter(key, t)

func set_shader_parameter_curve3d(m: ShaderMaterial, key: String, value: PackedVector4Array) -> void:
	if len(value) == 0:
		set_shader_parameter_curve(m, key)
		return
	var value_x := Curve.new()
	var value_y := Curve.new()
	var value_z := Curve.new()
	for v in value:
		value_x.add_point(Vector2(v.w, v.x))
		value_y.add_point(Vector2(v.w, v.y))
		value_z.add_point(Vector2(v.w, v.z))
	set_shader_parameter_curve(m, key, value_x, value_y, value_z)

@export var group_type: GroupType:
	set(value): group_type = value; update_fields()
@export var group_importance: GroupImportance:
	set(value): group_importance = value; update_fields()

@export_group("Emitter", "emitter_")
@export var emitter_enabled := true:
	set(value): emitter_enabled = value; update_fields()

@export_subgroup("Time", "emitter_")
@export var emitter_time_before_first_emission: float:
	set(value): emitter_time_before_first_emission = value; update_fields()
@export var emitter_period: float:
	set(value): emitter_period = value; update_fields()
@export var emitter_time_active_during_period: float:
	set(value): emitter_time_active_during_period = value; update_fields()
@export var emitter_lifetime: float: #e-life
	set(value): emitter_lifetime = value; update_fields()
@export var emitter_life_is_infinite := false: #e-life == -1
	set(value): emitter_life_is_infinite = value; update_fields()
@export var emitter_does_lifetime_scale: bool:
	set(value): emitter_does_lifetime_scale = value; update_fields()
@export var emitter_linger: float: #e-linger
	set(value): emitter_linger = value; update_fields()

@export var emitter_emit_single_particle: bool: #single-particle
	set(value): emitter_emit_single_particle = value; update_fields()
@export var emitter_rate: float: #e-rate
	set(value): emitter_rate = value; update_fields()
@export var emitter_rate_prob: Curve:
	set(value): emitter_rate_prob = value; update_fields()
@export var emitter_rate_over_lifetime: Curve:
	set(value): emitter_rate_over_lifetime = value; update_fields()
@export var emitter_rate_by_velocity: Vector2:
	set(value): emitter_rate_by_velocity = value; update_fields()

@export var emitter_framerate: float:
	set(value): emitter_framerate = value; update_fields()
@export var emitter_framerate_prob: Curve:
	set(value): emitter_framerate_prob = value; update_fields()
@export_subgroup("")

@export_subgroup("Rotation", "emitter_")
@export var emitter_is_local_orientation: bool: #e-local-orient
	set(value): emitter_is_local_orientation = value; update_fields()
@export var emitter_rotation_angles: Array[float]:
	set(value): emitter_rotation_angles = value; update_fields()
@export var emitter_rotation_axes: Array[Vector3]:
	set(value): emitter_rotation_axes = value; update_fields()
@export var emitter_rotation_probs: Array[Curve]:
	set(value): emitter_rotation_probs = value; update_fields()
@export var emitter_rotational_acceleration: Vector3:
	set(value): emitter_rotational_acceleration = value; update_fields()
@export_subgroup("")

@export_subgroup("Trail", "emitter_trail_")
@export var emitter_trail_tile_size: Vector3:
	set(value): emitter_trail_tile_size = value; update_fields()
@export var emitter_trail_tile_size_y_prob: Curve:
	set(value): emitter_trail_tile_size_y_prob = value; update_fields()
@export var emitter_trail_cutoff: float:
	set(value): emitter_trail_cutoff = value; update_fields()
@export_subgroup("UV", "emitter_")
@export var emitter_uv_offset: Vector2:
	set(value): emitter_uv_offset = value; update_fields()
@export var emitter_uv_offset_x_prob: Curve:
	set(value): emitter_uv_offset_x_prob = value; update_fields()
@export var emitter_uv_offset_y_prob: Curve:
	set(value): emitter_uv_offset_y_prob = value; update_fields()
@export var emitter_uv_scroll: Vector2:
	set(value): emitter_uv_scroll = value; update_fields()
@export_subgroup("")

@export var emitter_color: Color = Color.WHITE:
	set(value): emitter_color = value; update_fields()
@export var emitter_color_over_lifetime: Gradient:
	set(value): emitter_color_over_lifetime = value; update_fields()
@export var emitter_alpha_ref: int:
	set(value): emitter_alpha_ref = value; update_fields()

@export var emitter_beam_segments: int:
	set(value): emitter_beam_segments = value; update_fields()

@export_group("Particle", "particle_")
@export var particle_lifetime: float:
	set(value): particle_lifetime = value; update_fields()
@export var particle_lifetime_over_lifetime: Curve:
	set(value): particle_lifetime_over_lifetime = value; update_fields()
@export var particle_lifetime_prob: Curve:
	set(value): particle_lifetime_prob = value; update_fields()
@export var particle_linger: float:
	set(value): particle_linger = value; update_fields()

@export var particle_texture_name: String
@export var particle_texture: Texture2D:
	set(value): particle_texture = value; update_fields()
@export var particle_falloff_texture: String: #TODO Texture2D
	set(value): particle_falloff_texture = value; update_fields()
@export var particle_normal_map_texture: String: #TODO Texture2D
	set(value): particle_normal_map_texture = value; update_fields()

@export_subgroup("Animation", "particle_")
@export var particle_texture_division: Vector2 = Vector2.ONE: #p-texdiv
	set(value): particle_texture_division = value; update_fields()
@export var particle_start_frame: int = 0: #p-startframe
	set(value): particle_start_frame = value; update_fields()
@export var particle_number_of_frames: int = 1: #p-numframes
	set(value): particle_number_of_frames = value; update_fields()
@export var particle_frame_rate: float: #p-frameRate
	set(value): particle_frame_rate = value; update_fields()
@export var particle_start_frame_is_random: bool: #p-randomstartframe
	set(value): particle_start_frame_is_random = value; update_fields()
@export_subgroup("")

@export_subgroup("Color", "particle_color_")
@export var particle_color: Color = Color.WHITE:
	set(value): particle_color = value; update_fields()
@export var particle_color_over_lifetime: Gradient:
	set(value): particle_color_over_lifetime = value; update_fields()
@export var particle_color_lookup_texture_name: String
@export var particle_color_lookup_texture: Texture2D: #p-rgba
	set(value): particle_color_lookup_texture = value; update_fields()
@export var particle_color_lookup_type_x := ColorLookupType.LIFETIME: #p-colortype
	set(value): particle_color_lookup_type_x = value; update_fields()
@export var particle_color_lookup_type_y := ColorLookupType.LIFETIME: #p-colortype
	set(value): particle_color_lookup_type_y = value; update_fields()
var particle_color_lookup_type: Vector2i:
	get:
		return Vector2i(particle_color_lookup_type_x, particle_color_lookup_type_y)
	set(value):
		particle_color_lookup_type_x = value.x as ColorLookupType
		particle_color_lookup_type_y = value.y as ColorLookupType
@export var particle_color_lookup_scale: Vector2 = Vector2.ONE: #p-colorscale
	set(value): particle_color_lookup_scale = value; update_fields()
@export var particle_color_lookup_offset: Vector2: #p-coloroffset
	set(value): particle_color_lookup_offset = value; update_fields()

@export_subgroup("Position", "particle_")
@export var particle_bind_weight: Vector2:
	set(value): particle_bind_weight = value; update_fields()
@export var particle_bind_weight_over_lifetime: Curve:
	set(value): particle_bind_weight_over_lifetime = value; update_fields()
@export var particle_bind_weight_prob: Curve:
	set(value): particle_bind_weight_prob = value; update_fields()
@export var particle_locked_to_emitter: bool:
	set(value): particle_locked_to_emitter = value; update_fields()

@export var particle_emit_offset: Vector3: #p-offset
	set(value): particle_emit_offset = value; update_fields()
@export var particle_emit_offset_over_lifetime: PackedVector4Array: #Curve3D #p-offsetN
	set(value): particle_emit_offset_over_lifetime = value; update_fields()
@export var particle_emit_offset_x_prob: Curve: #p-offsetXPN
	set(value): particle_emit_offset_x_prob = value; update_fields()
@export var particle_emit_offset_y_prob: Curve: #p-offsetYPN
	set(value): particle_emit_offset_y_prob = value; update_fields()
@export var particle_emit_offset_z_prob: Curve: #p-offsetZPN
	set(value): particle_emit_offset_z_prob = value; update_fields()
@export var particle_scale_emit_offset_by_bound_object_size: float:
	set(value): particle_scale_emit_offset_by_bound_object_size = value; update_fields()

@export var particle_translation: Vector3: #p-postoffset
	set(value): particle_translation = value; update_fields()
@export var particle_translation_over_lifetime: PackedVector4Array: #Curve3D
	set(value): particle_translation_over_lifetime = value; update_fields()
@export var particle_translation_x_prob: Curve:
	set(value): particle_translation_x_prob = value; update_fields()
@export var particle_translation_y_prob: Curve:
	set(value): particle_translation_y_prob = value; update_fields()
@export var particle_translation_z_prob: Curve:
	set(value): particle_translation_z_prob = value; update_fields()

@export var particle_velocity: Vector3: #p-vel
	set(value): particle_velocity = value; update_fields()
@export var particle_velocity_over_lifetime: PackedVector4Array: #Curve3D #p-velN
	set(value): particle_velocity_over_lifetime = value; update_fields()
@export var particle_velocity_x_prob: Curve: #p-velXPN
	set(value): particle_velocity_x_prob = value; update_fields()
@export var particle_velocity_y_prob: Curve: #p-velYPN
	set(value): particle_velocity_y_prob = value; update_fields()
@export var particle_velocity_z_prob: Curve: #p-velZPN
	set(value): particle_velocity_z_prob = value; update_fields()

@export var particle_acceleration: Vector3:
	set(value): particle_acceleration = value; update_fields()
@export var particle_acceleration_over_lifetime: PackedVector4Array: #Curve3D
	set(value): particle_acceleration_over_lifetime = value; update_fields()
@export var particle_acceleration_x_prob: Curve:
	set(value): particle_acceleration_x_prob = value; update_fields()
@export var particle_acceleration_y_prob: Curve:
	set(value): particle_acceleration_y_prob = value; update_fields()
@export var particle_acceleration_z_prob: Curve:
	set(value): particle_acceleration_z_prob = value; update_fields()

@export var particle_drag: Vector3: #p-drag
	set(value): particle_drag = value; update_fields()
@export var particle_drag_over_lifetime: PackedVector4Array: #Curve3D
	set(value): particle_drag_over_lifetime = value; update_fields()
@export var particle_drag_x_prob: Curve:
	set(value): particle_drag_x_prob = value; update_fields()
@export var particle_drag_y_prob: Curve:
	set(value): particle_drag_y_prob = value; update_fields()
@export var particle_drag_z_prob: Curve:
	set(value): particle_drag_z_prob = value; update_fields()
@export_subgroup("")

@export_subgroup("Rotation", "particle_")
@export var particle_quad_type: int: #TODO: enum
	set(value): particle_quad_type = value; update_fields()
@export var particle_orientation: Vector3:
	set(value): particle_orientation = value; update_fields()
@export var particle_simple_orientation: OrientationType:
	set(value): particle_simple_orientation = value; update_fields()
@export var particle_is_local_orientation: bool: #p-local-orient
	set(value): particle_is_local_orientation = value; update_fields()
@export var particle_is_direction_oriented: bool:
	set(value): particle_is_direction_oriented = value; update_fields()
@export var particle_xrotation_is_enabled: bool:
	set(value): particle_xrotation_is_enabled = value; update_fields()
@export var particle_xrotation: Vector3:
	set(value): particle_xrotation = value; update_fields()
@export var particle_xrotation_over_lifetime: PackedVector4Array: #Curve3D
	set(value): particle_xrotation_over_lifetime = value; update_fields()
@export var particle_xrotation_z_prob: Curve:
	set(value): particle_xrotation_z_prob = value; update_fields()
@export var particle_rotation: Vector3: #p-quadrot
	set(value): particle_rotation = value; update_fields()
@export var particle_rotation_over_lifetime: PackedVector4Array: #Curve3D #p-quadrotN
	set(value): particle_rotation_over_lifetime = value; update_fields()
@export var particle_rotation_x_prob: Curve: #p-quadrotXPN
	set(value): particle_rotation_x_prob = value; update_fields()
@export var particle_rotation_y_prob: Curve: #p-quadrotYPN
	set(value): particle_rotation_y_prob = value; update_fields()
@export var particle_rotation_z_prob: Curve: #p-quadrotZPN / p-quadrotPN
	set(value): particle_rotation_z_prob = value; update_fields()
@export var particle_rotational_velocity: Vector3: #p-rotvel
	set(value): particle_rotational_velocity = value; update_fields()
@export var particle_rotational_velocity_over_lifetime: PackedVector4Array: #Curve3D #p-rotvelN
	set(value): particle_rotational_velocity_over_lifetime = value; update_fields()
@export var particle_rotational_velocity_x_prob: Curve: #p-rotvelXPN
	set(value): particle_rotational_velocity_x_prob = value; update_fields()
@export var particle_rotational_velocity_y_prob: Curve: #p-rotvelYPN
	set(value): particle_rotational_velocity_y_prob = value; update_fields()
@export var particle_rotational_velocity_z_prob: Curve: #p-rotvelZPN / p-rotvelPN
	set(value): particle_rotational_velocity_z_prob = value; update_fields()
@export_subgroup("")

@export_subgroup("Orbit", "particle_")
@export var particle_has_fixed_orbit: bool:
	set(value): particle_has_fixed_orbit = value; update_fields()
@export var particle_fixed_orbit_type: FixedOrbitType:
	set(value): particle_fixed_orbit_type = value; update_fields()
@export var particle_orbit_velocity: Vector3:
	set(value): particle_orbit_velocity = value; update_fields()
@export var particle_orbit_velocity_over_lifetime: PackedVector4Array: #Curve3D
	set(value): particle_orbit_velocity_over_lifetime = value; update_fields()
@export var particle_orbit_velocity_y_prob: Curve:
	set(value): particle_orbit_velocity_y_prob = value; update_fields()
@export_subgroup("")

@export_subgroup("Scale", "particle_")
@export var particle_scale: Vector3: #p-scale
	set(value): particle_scale = value; update_fields()
@export var particle_scale_bias: Vector2:
	set(value): particle_scale_bias = value; update_fields()
@export var particle_scale_over_lifetime: PackedVector4Array: #Curve3D #p-scaleN
	set(value): particle_scale_over_lifetime = value; update_fields()
@export var particle_scale_prob: PackedVector4Array:
	set(value): particle_scale_prob = value; update_fields()
@export var particle_scale_x_prob: Curve:
	set(value): particle_scale_x_prob = value; update_fields()
@export var particle_scale_y_prob: Curve:
	set(value): particle_scale_y_prob = value; update_fields()
@export var particle_scale_z_prob: Curve:
	set(value): particle_scale_z_prob = value; update_fields()
@export var particle_xscale: Vector3:
	set(value): particle_xscale = value; update_fields()
@export var particle_xscale_over_lifetime: PackedVector4Array: #Curve3D
	set(value): particle_xscale_over_lifetime = value; update_fields()
@export var particle_xscale_prob: Curve: #p-xscalePN
	set(value): particle_xscale_prob = value; update_fields()
@export var particle_scale_up_from_origin: bool:
	set(value): particle_scale_up_from_origin = value; update_fields()
@export var particle_scale_scale_by_bound_object_size: float:
	set(value): particle_scale_scale_by_bound_object_size = value; update_fields()
@export_subgroup("")

@export_subgroup("Mesh", "particle_")
@export var particle_mesh_name: String
@export var particle_mesh: Mesh:
	set(value): particle_mesh = value; update_fields()
@export var particle_mesh_texture_name: String
@export var particle_mesh_texture: Texture2D:
	set(value): particle_mesh_texture = value; update_fields()
@export var particle_mesh_skeleton: String:
	set(value): particle_mesh_skeleton = value; update_fields()
@export var particle_mesh_skin_mesh: String:
	set(value): particle_mesh_skin_mesh = value; update_fields()
@export var particle_mesh_animation: String: #TODO: Animation
	set(value): particle_mesh_animation = value; update_fields()
@export var particle_mesh_disable_backface_cull: bool:
	set(value): particle_mesh_disable_backface_cull = value; update_fields()
@export_subgroup("")

@export var particle_distortion_mode: int: #TODO: enum
	set(value): particle_distortion_mode = value; update_fields()
@export var particle_distortion: float:
	set(value): particle_distortion = value; update_fields()

@export var particle_projection_fading: float:
	set(value): particle_projection_fading = value; update_fields()
@export var particle_projection_y_range: float:
	set(value): particle_projection_y_range = value; update_fields()

@export var particle_does_cast_shadow: bool:
	set(value): particle_does_cast_shadow = value; update_fields()

@export var particle_uv_mode: UVMode:
	set(value): particle_uv_mode = value; update_fields()
@export var particle_uv_scroll_rate: Vector2:
	set(value): particle_uv_scroll_rate = value; update_fields()
@export var particle_uv_scroll_rate_y_prob: Curve:
	set(value): particle_uv_scroll_rate_y_prob = value; update_fields()
@export var particle_uv_scroll_no_alpha: bool:
	set(value): particle_uv_scroll_no_alpha = value; update_fields()

@export var particle_alpha_slice_range: float:
	set(value): particle_alpha_slice_range = value; update_fields()

@export var particle_beam_mode: BeamMode:
	set(value): particle_beam_mode = value; update_fields()

@export var particle_trail_mode: TrailMode: #p-trailmode
	set(value): particle_trail_mode = value; update_fields()

@export var particle_trans_sample: int:
	set(value): particle_trans_sample = value; update_fields()

@export var particle_world_acceleration: Vector3:
	set(value): particle_world_acceleration = value; update_fields()
@export var particle_world_acceleration_over_lifetime: PackedVector4Array: #Curve3D
	set(value): particle_world_acceleration_over_lifetime = value; update_fields()
@export var particle_world_acceleration_y_prob: Curve:
	set(value): particle_world_acceleration_y_prob = value; update_fields()

@export_group("")

@export var blend_mode: BlendMode: #rendermode
	set(value): blend_mode = value; update_fields()
@export var team_color_correction: bool:
	set(value): team_color_correction = value; update_fields()
@export var in_uniform_scale: bool:
	set(value): in_uniform_scale = value; update_fields()

@export var _pass: int:
	set(value): _pass = value; update_fields()

@export var exclude_attachment_type: String:
	set(value): exclude_attachment_type = value; update_fields()
@export var keywords_included: String:
	set(value): keywords_included = value; update_fields()
@export var keywords_excluded: String:
	set(value): keywords_excluded = value; update_fields()
@export var keywords_required: String:
	set(value): keywords_required = value; update_fields()

#func _set(_property, _value):
#	update_fields()

var updating_fields := 1
func _ready() -> void:
	updating_fields -= 1
	#update_fields()

var p: GPUParticles3D
func update_fields() -> void:
	if updating_fields: return
	else: updating_fields += 1

	if !p:
		p = find_child("GPUParticles3D")
	if !p:
		p = GPUParticles3D.new()
		add_child(p, true)
		p.owner = owner if owner else self

	print('update_fields')

	var total_emitter_life: float
	if emitter_life_is_infinite || emitter_lifetime < 0:
		emitter_life_is_infinite = true
		total_emitter_life = 1
		p.one_shot = false
	else:
		total_emitter_life = emitter_lifetime + emitter_linger
		p.one_shot = true
		if total_emitter_life == 0:
			emitter_enabled = false

	p.emitting = emitter_enabled

	p.lifetime = total_emitter_life
	# OR
	#var total_particle_life := particle_lifetime + particle_linger
	#lifetime = total_emitter_life + total_particle_life
	#explosiveness = total_particle_life / lifetime

	p.amount = 1 if emitter_emit_single_particle else round(total_emitter_life * emitter_rate)

	#TODO:
	p.draw_pass_1 = particle_mesh if particle_mesh else preload("res://engine/effects/new_quad_mesh.tres")
	#p.draw_pass_1 = preload("res://engine/effects/new_sphere_mesh.tres") if particle_mesh \
			   #else preload("res://engine/effects/new_quad_mesh.tres")

	p.cast_shadow = int(particle_does_cast_shadow) as GeometryInstance3D.ShadowCastingSetting;

	if true:
		var m := p.process_material as ShaderMaterial
		if !m:
			m = ShaderMaterial.new()
			p.process_material = m

		var s := process_shader
		# SET process_shader PARAMS HERE
		m.shader = s.get_shader()

		m.set_shader_parameter('amount', p.amount)

		m.set_shader_parameter('p_life_i', particle_lifetime)
		set_shader_parameter_curve(m, 'p_life_p', particle_lifetime_prob)

		m.set_shader_parameter('p_linger', particle_linger)

		m.set_shader_parameter('p_rgba', particle_color_lookup_texture)
		m.set_shader_parameter('p_colortype', particle_color_lookup_type)
		m.set_shader_parameter('p_colorscale', particle_color_lookup_scale)
		m.set_shader_parameter('p_coloroffset', particle_color_lookup_offset)

		m.set_shader_parameter('p_bindweight', particle_bind_weight)

		m.set_shader_parameter('p_scale_i', particle_scale)
		set_shader_parameter_curve3d(m, 'p_scale_p', particle_scale_prob)
		set_shader_parameter_curve(m, 'p_scale_a_p', particle_scale_x_prob, particle_scale_y_prob, particle_scale_z_prob)

		m.set_shader_parameter('p_quadrot_i', particle_rotation)
		set_shader_parameter_curve(m, 'p_quadrot_a_p', particle_rotation_x_prob, particle_rotation_y_prob, particle_rotation_z_prob)
		m.set_shader_parameter('p_rotvel_i', particle_rotational_velocity)
		set_shader_parameter_curve(m, 'p_rotvel_a_p', particle_rotational_velocity_x_prob, particle_rotational_velocity_y_prob, particle_rotational_velocity_z_prob)

		m.set_shader_parameter('p_vel_i', particle_velocity)
		set_shader_parameter_curve(m, 'p_vel_a_p', particle_velocity_x_prob, particle_velocity_y_prob, particle_velocity_z_prob)

		set_shader_parameter_curve3d(m, 'p_xscale_ol', particle_xscale_over_lifetime)

	if true:
		var m := p.material_override as ShaderMaterial
		if !m:
			m = ShaderMaterial.new()
			p.material_override = m

		var s := material_shader
		# SET material_shader PARAMS HERE
		s.blend_mode = blend_mode
		s.billboard_enabled = particle_mesh == null
		m.shader = s.get_shader()

		m.set_shader_parameter('albedo', particle_color)
		m.set_shader_parameter('texture_albedo',
			particle_mesh_texture if particle_mesh and particle_mesh_texture
			else particle_texture if particle_texture
			else particle_mesh_texture #?
		)
		m.set_shader_parameter('texdiv', particle_texture_division)
		m.set_shader_parameter('random_start_frame', particle_start_frame_is_random)
		m.set_shader_parameter('start_frame', float(particle_start_frame))
		m.set_shader_parameter('num_frames', float(particle_number_of_frames))
		m.set_shader_parameter('frame_rate', particle_frame_rate)

		m.set_shader_parameter('uv_scroll', particle_uv_scroll_rate)

		# UV-offset is probably set once for all particles
		#set_shader_parameter_curve(m, 'uv_offset_a_p', emitter_uv_offset_x_prob, emitter_uv_offset_y_prob)

		#TODO:
		#m.transparency = true
		#m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	updating_fields -= 1

class MyShader:

	static var cache: Dictionary[int, ShaderAndUsage] = {}
	var entry: ShaderAndUsage
	class ShaderAndUsage:
		var shader: Shader = null
		var users: int = 1
		var hash: int = 0
	var code: String
	var hash: int

	func gen_code() -> String: return ""
	func define(k: String, v: String = '') -> String:
		return '#define ' + k + ((' ' + v) if v else '') + '\n'
	func include(p: String) -> String:
		return '#include "' + p + '"\n'

	#func _init():
	#	gen_code_hash()
	#	get_entry()

	func gen_code_hash() -> void:
		code = gen_code()
		hash = code.hash()

	func get_shader() -> Shader:
		gen_code_hash()
		if !entry:
			get_entry()
		elif entry.hash != hash:
			entry.users -= 1
			if entry.users == 0:
				cache.erase(entry.hash)
			get_entry()
		return entry.shader

	func get_entry() -> void:
		entry = cache.get(hash)
		if entry:
			entry.users += 1
		else:
			entry = ShaderAndUsage.new()
			entry.shader = Shader.new()
			entry.shader.code = code
			entry.users = 1
			entry.hash = hash
			cache[hash] = entry

var material_shader := MaterialShader.new()
class MaterialShader extends MyShader:
	var blend_mode: BlendMode
	var billboard_enabled: bool
	func gen_code() -> String:
		var render_mode: Array[String] = []

		var bm: String;
		match blend_mode:
			BlendMode.ADD: bm = "blend_add"
			BlendMode.UNKNOWN_1: bm = "blend_mix"
			BlendMode.UNKNOWN_2: pass
			BlendMode.UNKNOWN_3: pass
			BlendMode.UNKNOWN_4: pass
		if bm: render_mode.append(bm)

		render_mode.append("depth_draw_opaque")
		render_mode.append("cull_back")
		render_mode.append("diffuse_burley")
		render_mode.append("unshaded")
		render_mode.append("specular_disabled")
		render_mode.append("ambient_light_disabled")
		render_mode.append("fog_disabled")

		return \
		"shader_type spatial;\n" +\
		"render_mode " + ",".join(render_mode) + ";\n" +\
		(define('BILLBOARD') if billboard_enabled else '') +\
		include('res://engine/effects/material.gdshaderinc')

var process_shader := ProcessShader.new()
class ProcessShader extends MyShader:
	func gen_code() -> String:
		return \
		"shader_type particles;\n" +\
		include('res://engine/effects/process.gdshaderinc')

func set_from_ini_section(section: Array) -> void:
	updating_fields += 1
	for entry: Array in section:
		self.set_from_ini_entry(entry[0], entry[1])
	updating_fields -= 1

func set_from_ini_entry(key_array: Array, value: String) -> void:
	super.set_from_ini_entry(key_array, value)
	match key_array:
		["e-active"]: emitter_time_active_during_period = float_parse(value)
		["e-alpharef"]: emitter_alpha_ref = int_parse(value)
		["e-beam-segments"]: emitter_beam_segments = int_parse(value)
		["e-framerate"]: emitter_framerate = float_parse(value)
		["e-framerateP", var i]: emitter_framerate_prob = curve_set(emitter_framerate_prob, i, value)
		["e-life-scale"]: emitter_does_lifetime_scale = bool_parse(value)
		["e-life"]: emitter_lifetime = float_parse(value)
		["e-linger"]: emitter_linger = float_parse(value)
		["e-local-orient"]: emitter_is_local_orientation = bool_parse(value)
		["e-period"]: emitter_period = float_parse(value)
		#2 ["e-rate_flex", var i]: pass
		["e-rate", var i]: emitter_rate_over_lifetime = curve_set(emitter_rate_over_lifetime, i, value)
		["e-rate"]: emitter_rate = float_parse(value)
		["e-ratebyvel"]: emitter_rate_by_velocity = vec2_parse(value)
		["e-rateP", var i]: emitter_rate_prob = curve_set(emitter_rate_prob, i, value)
		["e-rgba", var i]: emitter_color_over_lifetime = gradient_set(emitter_color_over_lifetime, i, value)
		["e-rgba"]: emitter_color = color_parse(value)
		["e-rotation", var i]: emitter_rotation_angles = array_set(emitter_rotation_angles, i, float_parse(value))
		["e-rotation", var i, "-axis"]: emitter_rotation_axes = array_set(emitter_rotation_axes, i, vec3_parse(value))
		["e-rotation", var i, "P", var j]: emitter_rotation_probs = array_set(emitter_rotation_probs, i, curve_set(array_get(emitter_rotation_probs, i), j, value))
		#1 ["e-rotation", var i, "P"]: pass
		["e-tilesize"]: emitter_trail_tile_size = vec3_parse(value)
		["e-tilesizeYP", var i]: emitter_trail_tile_size_y_prob = curve_set(emitter_trail_tile_size_y_prob, i, value)
		["e-timeoffset"]: emitter_time_before_first_emission = float_parse(value)
		["e-trail-cutoff"]: emitter_trail_cutoff = float_parse(value)
		#2 ["e-uvoffset_flex", var i]: pass
		#2 ["e-uvoffset", var i]: pass
		["e-uvoffset"]: emitter_uv_offset = vec2_parse(value)
		["e-uvoffsetXP", var i]: emitter_uv_offset_x_prob = curve_set(emitter_uv_offset_x_prob, i, value)
		["e-uvoffsetYP", var i]: emitter_uv_offset_y_prob = curve_set(emitter_uv_offset_y_prob, i, value)
		["e-uvscroll"]: emitter_uv_scroll = vec2_parse(value)
		["Emitter-BirthRotationalAcceleration"]: emitter_rotational_acceleration = vec3_parse(value) # always v3.zero
		["ExcludeAttachmentType"]: exclude_attachment_type = string_parse(value)
		#region Fields
		["f-accel"]: pass
		["f-accelXP", var i]: pass
		["f-accelYP", var i]: pass
		["f-accelZP", var i]: pass
		["f-axisfrac"]: pass
		["f-buoyancy"]: pass
		["f-denseforce"]: pass
		["f-diffusion"]: pass
		["f-direction"]: pass
		["f-dissipation"]: pass
		["f-drag"]: pass
		["f-dragP", var i]: pass
		["f-initdensity"]: pass
		["f-jetdir", var i]: pass
		["f-jetdirdiff", var i]: pass
		["f-jetpos", var i]: pass
		["f-jetspeed", var i]: pass
		["f-life"]: pass
		["f-localspace"]: pass
		["f-movement-x"]: pass
		["f-movement-y"]: pass
		["f-period"]: pass
		["f-periodP", var i]: pass
		["f-pos"]: pass
		["f-radius"]: pass
		["f-rate"]: pass
		["f-rendersize"]: pass
		["f-startkick"]: pass
		["f-veldelta", var i]: pass
		["f-veldelta"]: pass
		["f-viscosity"]: pass
		["field-accel-", var i]: pass
		["field-attract-", var i]: pass
		["field-drag-", var i]: pass
		["field-noise-", var i]: pass
		["field-orbit-", var i]: pass
		#endregion F
		["flag-disable-z"]: pass
		["flag-projected"]: pass
		["fluid-params"]: pass
		["KeywordsExcluded"]: keywords_excluded = string_parse(value)
		["KeywordsIncluded"]: keywords_included = string_parse(value)
		["KeywordsRequired"]: keywords_required = string_parse(value)
		#6 ["p-accel", var i]: pass
		["p-accel"]: particle_acceleration = vec3_parse(value)
		["p-accelXP", var i]: particle_acceleration_x_prob = curve_set(particle_acceleration_x_prob, i, value)
		["p-accelYP", var i]: particle_acceleration_y_prob = curve_set(particle_acceleration_y_prob, i, value)
		["p-accelZP", var i]: particle_acceleration_z_prob = curve_set(particle_acceleration_z_prob, i, value)
		["p-alphaslicerange"]: particle_alpha_slice_range = float_parse(value)
		["p-animation"]: particle_mesh_animation = string_parse(value)
		["p-backfaceon"]: particle_mesh_disable_backface_cull = bool_parse(value)
		["p-beammode"]: particle_beam_mode = uint_parse(value) as BeamMode
		["p-bindtoemitter", var i]: particle_bind_weight_over_lifetime = curve_set(particle_bind_weight_over_lifetime, i, value)
		["p-bindtoemitterP", var i]: particle_bind_weight_prob = curve_set(particle_bind_weight_prob, i, value)
		["p-bindtoemitter"]: particle_bind_weight = vec2_parse(value, VectorUsage.SCALE)
		["p-coloroffset"]: particle_color_lookup_offset = vec2_parse(value)
		["p-colorscale"]: particle_color_lookup_scale = vec2_parse(value)
		["p-colortype"]: particle_color_lookup_type = ivec2_parse(value) # String?
		["p-distortion-mode"]: particle_distortion_mode = uint_parse(value)
		["p-distortion-power"]: particle_distortion = float_parse(value)
		["p-drag", var i]: particle_drag_over_lifetime = curve3d_set(particle_drag_over_lifetime, i, value)
		["p-drag"]: particle_drag = vec3_parse(value)
		["p-dragXP", var i]: particle_drag_x_prob = curve_set(particle_drag_x_prob, i, value)
		["p-dragYP", var i]: particle_drag_y_prob = curve_set(particle_drag_y_prob, i, value)
		["p-dragZP", var i]: particle_drag_z_prob = curve_set(particle_drag_z_prob, i, value)
		["p-falloff-texture"]: particle_falloff_texture = string_parse(value)
		["p-fixedorbit"]: particle_has_fixed_orbit = bool_parse(value)
		["p-fixedorbittype"]: particle_fixed_orbit_type = uint_parse(value) as FixedOrbitType
		["p-flexoffset"]: particle_scale_emit_offset_by_bound_object_size = float_parse(value)
		["p-flexscale"]: particle_scale_scale_by_bound_object_size = float_parse(value)
		#0 ["p-followterrain"]: particle_is_following_terrain = bool_parse(value)
		["p-frameRate"]: particle_frame_rate = float_parse(value)
		#2 ["p-life_flex", var i]: pass
		#0 ["p-life-scale"]: particle_does_particle_lifetime_scales = bool_parse(value)
		["p-life", var i]: particle_lifetime_over_lifetime = curve_set(particle_lifetime_over_lifetime, i, value)
		["p-life"]: particle_lifetime = float_parse(value)
		["p-lifeP", var i]: particle_lifetime_prob = curve_set(particle_lifetime_prob, i, value)
		["p-linger"]: particle_linger = float_parse(value)
		["p-local-orient"]: particle_is_local_orientation = bool_parse(value)
		["p-lockedtoemitter"]: particle_locked_to_emitter = bool_parse(value)
		["p-mesh"]:
			particle_mesh_name = string_parse(value)
			particle_mesh = mesh_parse(value)
		["p-meshtex"]:
			particle_mesh_texture_name = string_parse(value)
			particle_mesh_texture = tex_parse(value)
		["p-normal-map"]: particle_normal_map_texture = string_parse(value)
		["p-numframes"]: particle_number_of_frames = int_parse(value)
		#4 ["p-offset_flex", var i]: pass
		["p-offset", var i]: particle_emit_offset_over_lifetime = curve3d_set(particle_emit_offset_over_lifetime, i, value)
		["p-offset"]: particle_emit_offset = vec3_parse(value)
		#0 ["p-offsetbyheight"]: particle_scale_emit_offset_by_bound_object_height = float_parse(value)
		#0 ["p-offsetbyradius"]: particle_scale_emit_offset_by_bound_object_radius = float_parse(value)
		["p-offsetXP", var i]: particle_emit_offset_x_prob = curve_set(particle_emit_offset_x_prob, i, value)
		["p-offsetYP", var i]: particle_emit_offset_y_prob = curve_set(particle_emit_offset_y_prob, i, value)
		["p-offsetZP", var i]: particle_emit_offset_z_prob = curve_set(particle_emit_offset_z_prob, i, value)
		["p-orbitvel", var i]: particle_orbit_velocity_over_lifetime = curve3d_set(particle_orbit_velocity_over_lifetime, i, value)
		["p-orbitvel"]: particle_orbit_velocity = vec3_parse(value)
		["p-orbitvelYP", var i]: particle_orbit_velocity_y_prob = curve_set(particle_orbit_velocity_y_prob, i, value)
		["p-orientation"]: particle_orientation = vec3_parse(value)
		#2 ["p-postoffset_flex", var i]: pass
		["p-postoffset", var i]: particle_translation_over_lifetime = curve3d_set(particle_translation_over_lifetime, i, value)
		["p-postoffset"]: particle_translation = vec3_parse(value)
		["p-postoffsetXP", var i]: particle_translation_x_prob = curve_set(particle_translation_x_prob, i, value)
		#3 ["p-postoffsetXP"]: pass
		["p-postoffsetYP", var i]: particle_translation_y_prob = curve_set(particle_translation_y_prob, i, value)
		#3 ["p-postoffsetYP"]: pass
		["p-postoffsetZP", var i]: particle_translation_z_prob = curve_set(particle_translation_z_prob, i, value)
		#3 ["p-postoffsetZP"]: pass
		["p-projection-fading"]: particle_projection_fading = float_parse(value)
		["p-projection-y-range"]: particle_projection_y_range = float_parse(value)
		["p-quadrot", var i]: particle_rotation_over_lifetime = curve3d_set(particle_rotation_over_lifetime, i, value, VectorUsage.ROTATION)
		["p-quadrot"]: particle_rotation = vec3_parse(value, VectorUsage.ROTATION) # float in simple
		["p-quadrotP", var i]: particle_rotation_z_prob = curve_set(particle_rotation_z_prob, i, value)
		["p-quadrotXP", var i]: particle_rotation_x_prob = curve_set(particle_rotation_x_prob, i, value)
		["p-quadrotYP", var i]: particle_rotation_y_prob = curve_set(particle_rotation_y_prob, i, value)
		["p-quadrotZP", var i]: particle_rotation_z_prob = curve_set(particle_rotation_z_prob, i, value)
		["p-randomstartframe"]: particle_start_frame_is_random = bool_parse(value, false)
		["p-rgba"]:
			particle_color_lookup_texture_name = string_parse(value)
			particle_color_lookup_texture = tex_parse(value)
		#2 ["p-rotvel_flex", var i]: pass
		["p-rotvel", var i]: particle_rotational_velocity_over_lifetime = curve3d_set(particle_rotational_velocity_over_lifetime, i, value, VectorUsage.ROTATION)
		["p-rotvel"]: particle_rotational_velocity = vec3_parse(value, VectorUsage.ROTATION) # float in simple
		["p-rotvelP", var i]: particle_rotational_velocity_z_prob = curve_set(particle_rotational_velocity_z_prob, i, value)
		["p-rotvelXP", var i]: particle_rotational_velocity_x_prob = curve_set(particle_rotational_velocity_x_prob, i, value)
		["p-rotvelYP", var i]: particle_rotational_velocity_y_prob = curve_set(particle_rotational_velocity_y_prob, i, value)
		["p-rotvelZP", var i]: particle_rotational_velocity_z_prob = curve_set(particle_rotational_velocity_z_prob, i, value)
		#4 ["p-scale_flex", var i]: pass
		["p-scale", var i]: particle_scale_over_lifetime = curve3d_set(particle_scale_over_lifetime, i, value, VectorUsage.SCALE)
		["p-scale"]: particle_scale = vec3_parse(value, VectorUsage.SCALE) # float in simple
		["p-scalebias"]: particle_scale_bias = vec2_parse(value)
		#0 ["p-scalebyheight"]: particle_scale_scale_by_bound_object_height = float_parse(value)
		#0 ["p-scalebyradius"]: particle_scale_scale_by_bound_object_radius = float_parse(value)
		#2 ["p-scaleEmitOffset_flex", var i]: pass
		["p-scaleupfromorigin"]: particle_scale_up_from_origin = bool_parse(value)
		["p-scaleP", var i]: particle_scale_prob = curve3d_set(particle_scale_prob, i, value, VectorUsage.SCALE)
		["p-scaleXP", var i]: particle_scale_x_prob = curve_set(particle_scale_x_prob, i, value)
		["p-scaleYP", var i]: particle_scale_y_prob = curve_set(particle_scale_y_prob, i, value)
		["p-scaleZP", var i]: particle_scale_z_prob = curve_set(particle_scale_z_prob, i, value)
		["p-shadow"]: particle_does_cast_shadow = bool_parse(value)
		["p-simpleorient"]: particle_simple_orientation = uint_parse(value) as OrientationType
		["p-skeleton"]: particle_mesh_skeleton = string_parse(value)
		["p-skin"]: particle_mesh_skin_mesh = string_parse(value)
		["p-startframe"]: particle_start_frame = int_parse(value)
		["p-texdiv"]: particle_texture_division = vec2_parse(value)
		["p-texture"]:
			particle_texture_name = string_parse(value)
			particle_texture = tex_parse(value)
		["p-trailmode"]: particle_trail_mode = uint_parse(value) as TrailMode
		["p-trans-sample"]: particle_trans_sample = uint_parse(value)
		["p-type"]: particle_quad_type = int_parse(value)
		["p-uvmode"]: particle_uv_mode = uint_parse(value) as UVMode
		["p-uvscroll-no-alpha"]: particle_uv_scroll_no_alpha = bool_parse(value)
		#0 ["p-uvscroll-rgb-clamp"]: particle_uv_scroll_clamp = bool_parse(value)
		["p-uvscroll-rgb"]: particle_uv_scroll_rate = vec2_parse(value)
		["p-uvscroll-rgbYP", var i]: particle_uv_scroll_rate_y_prob = curve_set(particle_uv_scroll_rate_y_prob, i, value)
		["p-vecalign"]: particle_is_direction_oriented = bool_parse(value)
		#2 ["p-vel_flex", var i]: pass
		["p-vel", var i]: particle_velocity_over_lifetime = curve3d_set(particle_velocity_over_lifetime, i, value)
		["p-vel"]: particle_velocity = vec3_parse(value)
		["p-velXP", var i]: particle_velocity_x_prob = curve_set(particle_velocity_x_prob, i, value)
		["p-velYP", var i]: particle_velocity_y_prob = curve_set(particle_velocity_y_prob, i, value)
		["p-velZP", var i]: particle_velocity_z_prob = curve_set(particle_velocity_z_prob, i, value)
		["p-worldaccel", var i]: particle_world_acceleration_over_lifetime = curve3d_set(particle_world_acceleration_over_lifetime, i, value)
		["p-worldaccel"]: particle_world_acceleration = vec3_parse(value)
		["p-worldaccelYP", var i]: particle_world_acceleration_y_prob = curve_set(particle_world_acceleration_y_prob, i, value)
		["p-xquadrot-on"]: particle_xrotation_is_enabled = bool_parse(value)
		["p-xquadrot", var i]: particle_xrotation_over_lifetime = curve3d_set(particle_xrotation_over_lifetime, i, value, VectorUsage.SCALE)
		["p-xquadrot"]: particle_xrotation = vec3_parse(value, VectorUsage.SCALE) # float in simple
		["p-xquadrotP", var i]: particle_xrotation_z_prob = curve_set(particle_xrotation_z_prob, i, value)
		["p-xrgba", var i]: particle_color_over_lifetime = gradient_set(particle_color_over_lifetime, i, value)
		["p-xrgba"]: particle_color = color_parse(value)
		["p-xscale", var i]: particle_xscale_over_lifetime = curve3d_set(particle_xscale_over_lifetime, i, value, VectorUsage.SCALE)
		["p-xscale"]: particle_xscale = vec3_parse(value, VectorUsage.SCALE) # float in simple
		["p-xscaleP", var i]: particle_xscale_prob = curve_set(particle_xscale_prob, i, value)
		["Particle-Acceleration", var i]: particle_acceleration_over_lifetime = curve3d_set(particle_acceleration_over_lifetime, i, value)
		["Particle-Acceleration"]: particle_acceleration = vec3_parse(value)
		["Particle-AccelerationXP", var i]: particle_acceleration_x_prob = curve_set(particle_acceleration_x_prob, i, value)
		["Particle-AccelerationYP", var i]: particle_acceleration_y_prob = curve_set(particle_acceleration_y_prob, i, value)
		["Particle-AccelerationZP", var i]: particle_acceleration_z_prob = curve_set(particle_acceleration_z_prob, i, value)
		["Particle-Drag"]: particle_drag = vec3_parse(value)
		#0 ["Particle-ScaleAlongMovementVector"]: scale_along_movement_vector = float_parse(value)
		["Particle-Velocity", var i]: particle_velocity_over_lifetime = curve3d_set(particle_velocity_over_lifetime, i, value)
		["Particle-Velocity"]: particle_velocity = vec3_parse(value)
		["pass"]: _pass = int_parse(value)
		["rendermode"]: blend_mode = int_parse(value) as BlendMode
		["single-particle"]: emitter_emit_single_particle = int_parse(value)
		["teamcolor-correction"]: team_color_correction = bool_parse(value)
		["uniformscale"]: in_uniform_scale = int_parse(value) != 0
