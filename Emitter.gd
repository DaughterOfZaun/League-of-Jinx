@tool
#class_name Particle
extends GPUParticles3D

enum ColorLookupType { CONSTANT = 0, LIFETIME = 1, VELOCITY = 2, BIRTH_RANDOM = 3, COUNT = 4, }
enum BlendMode { ADD, UNKNOWN_1, UNKNOWN_2, UNKNOWN_3, UNKNOWN_4, }
enum TrailMode { DEFAULT = 0, WAKE = 1, }
enum FixedOrbitType { WorldX = 0, WorldY = 1, WorldZ = 2, WorldNegX = 3, WorldNegY = 4, WorldNegZ = 5, }
enum Orientation { Camera = 0, WorldX = 1, WorldY = 2, WorldZ = 3, }
enum UVMode { Default = 0, ScreenSpace = 1, LockAlpha = 2, }
enum BeamMode { Default = 0, Arbitary = 1 }

@export_group("Emitter", "emitter_")
@export var emitter_enabled := true:
    set(value): emitter_enabled = value; update_fields()

@export_subgroup("Time", "emitter_")
@export var emitter_period: float
@export var emitter_time_active_during_period: float

@export var emitter_time_before_first_emission: float
@export var emitter_lifetime: float: #e-life
    set(value): emitter_lifetime = value; update_fields()
@export var emitter_life_is_infinite := false: #e-life == -1
    set(value): emitter_life_is_infinite = value; update_fields()
@export var emitter_does_lifetime_scale: bool
@export var emitter_linger: float: #e-linger
    set(value): emitter_linger = value; update_fields()

@export var emitter_rate: float: #e-rate
    set(value): emitter_rate = value; update_fields()
@export var emitter_rate_over_lifetime: Curve
@export var emitter_rate_prob: Curve
@export var emitter_rate_by_velocity: Vector2
@export var emitter_emit_single_particle: bool #single-particle

@export var emitter_framerate: float
@export var emitter_framerate_prob: Curve
@export_subgroup("")

@export_subgroup("Rotation", "emitter_")
@export var emitter_is_local_orientation: bool: #e-local-orient
    set(value): emitter_is_local_orientation = value; update_fields()
@export var emitter_rotation_angles: Array[float]
@export var emitter_rotation_axes: Array[Vector3]
@export var emitter_rotation_probs: Array[Curve]
@export var emitter_birth_rotational_acceleration: Vector3
@export_subgroup("")

@export_subgroup("Trail", "emitter_trail_")
@export var emitter_trail_tile_size: Vector3
@export var emitter_trail_tile_size_y_prob: Curve
@export var emitter_trail_cutoff: float
@export_subgroup("UV", "emitter_")
@export var emitter_birth_uv_offset: Vector2
@export var emitter_birth_uv_offset_x_prob: Curve
@export var emitter_birth_uv_offset_y_prob: Curve
@export var emitter_uv_scroll: Vector2
@export_subgroup("")

@export var emitter_birth_color: Color
@export var emitter_color_over_lifetime: Gradient
@export var emitter_alpha_ref: int

@export var emitter_beam_segments: int

@export var exclude_attachment_type: String

@export_group("Particle", "particle_")
@export var particle_lifetime: float:
    set(value): particle_lifetime = value; update_fields()
@export var particle_lifetime_over_lifetime: Curve
@export var particle_lifetime_prob: Curve
@export var particle_linger: float:
    set(value): particle_linger = value; update_fields()

@export var particle_texture: Texture2D:
    set(value): particle_texture = value; update_fields()
@export var particle_falloff_texture: String #TODO: Texture2D
@export var particle_normal_map_texture: String #TODO: Texture2D

@export_subgroup("Animation", "particle_")
@export var particle_texture_division: Vector2 = Vector2.ONE #p-texdiv
@export var particle_start_frame: int = 1 #p-startframe
@export var particle_number_of_frames: int = 1 #p-numframes
@export var particle_frame_rate: float #p-frameRate
@export var particle_start_frame_is_random: bool #p-randomstartframe
@export_subgroup("")

@export_subgroup("Color", "particle_color_")
@export var particle_color: Color
@export var particle_color_over_lifetime: Gradient
@export var particle_color_lookup_texture: Texture2D: #p-rgba
    set(value): particle_color_lookup_texture = value; update_fields()
@export var particle_color_lookup_type_x: ColorLookupType: #p-colortype
    set(value): particle_color_lookup_type_x = value; update_fields()
@export var particle_color_lookup_type_y: ColorLookupType: #p-colortype
    set(value): particle_color_lookup_type_y = value; update_fields()
@export var particle_color_lookup_scale: Vector2 = Vector2.ONE: #p-colorscale
    set(value): particle_color_lookup_scale = value; update_fields()
@export var particle_color_lookup_offset: Vector2: #p-coloroffset
    set(value): particle_color_lookup_offset = value; update_fields()

@export_subgroup("Position", "particle_")
@export var particle_bind_weight: Vector2 #p-bindtoemitter
@export var particle_bind_weight_over_lifetime: Curve
@export var particle_bind_weight_prob: Curve
@export var particle_locked_to_emitter: bool

@export var particle_emit_offset: Vector3 #p-offset
@export var particle_emit_offset_over_lifetime: Curve3D #p-offsetN
@export var particle_emit_offset_x_prob: Curve #p-offsetXPN
@export var particle_emit_offset_y_prob: Curve #p-offsetYPN
@export var particle_emit_offset_z_prob: Curve #p-offsetZPN
@export var particle_scale_emit_offset_by_bound_object_size: float

@export var particle_birth_translation: Vector3 #p-postoffset
@export var particle_birth_translation_over_lifetime: Curve3D
@export var particle_birth_translation_x_prob: Curve
@export var particle_birth_translation_y_prob: Curve
@export var particle_birth_translation_z_prob: Curve

@export var particle_birth_velocity: Vector3 #p-vel
@export var particle_velocity_over_lifetime: Curve3D #p-velN
@export var particle_velocity_x_prob: Curve #p-velXPN
@export var particle_velocity_y_prob: Curve #p-velYPN
@export var particle_velocity_z_prob: Curve #p-velZPN

@export var particle_birth_acceleration: Vector3
@export var particle_birth_acceleration_over_lifetime: Curve3D
@export var particle_birth_acceleration_x_prob: Curve
@export var particle_birth_acceleration_y_prob: Curve
@export var particle_birth_acceleration_z_prob: Curve

@export var particle_birth_drag: Vector3 #p-drag
@export var particle_drag_over_lifetime: Curve3D
@export var particle_drag_x_prob: Curve
@export var particle_drag_y_prob: Curve
@export var particle_drag_z_prob: Curve
@export_subgroup("")

@export_subgroup("Rotation", "particle_")
@export var particle_quad_type: int #TODO: enum
@export var particle_orientation: Vector3
@export var particle_simple_orientation: Orientation
@export var particle_is_local_orientation: bool #p-local-orient
@export var particle_is_direction_oriented: bool
@export var particle_xrotation_is_enabled: bool
@export var particle_xrotation: Vector3
@export var particle_xrotation_over_lifetime: Curve3D
@export var particle_xrotation_x_prob: Curve
@export var particle_birth_rotation: Vector3 #p-quadrot
@export var particle_rotation_over_lifetime: Curve3D #p-quadrotN
@export var particle_rotation_x_prob: Curve #p-quadrotXPN / p-quadrotPN
@export var particle_rotation_y_prob: Curve #p-quadrotYPN
@export var particle_rotation_z_prob: Curve #p-quadrotZPN
@export var particle_birth_rotational_velocity: Vector3 #p-rotvel
@export var particle_rotational_velocity_over_lifetime: Curve3D #p-rotvelN
@export var particle_rotational_velocity_x_prob: Curve #p-rotvelXPN / p-rotvelPN
@export var particle_rotational_velocity_y_prob: Curve #p-rotvelYPN
@export var particle_rotational_velocity_z_prob: Curve #p-rotvelZPN
@export_subgroup("")

@export_subgroup("Orbit", "particle_")
@export var particle_has_fixed_orbit: bool
@export var particle_fixed_orbit_type: FixedOrbitType
@export var particle_birth_orbit_velocity: Vector3
@export var particle_birth_orbit_velocity_over_lifetime: Curve3D
@export var particle_birth_orbit_velocity_y_prob: Curve
@export_subgroup("")

@export_subgroup("Scale", "particle_")
@export var particle_xscale: Vector3
@export var particle_birth_scale: Vector3 #p-scale
@export var particle_scale_bias: Vector2
@export var particle_scale_over_lifetime: Curve3D #p-scaleN
@export var particle_scale_x_prob: Curve
@export var particle_scale_y_prob: Curve
@export var particle_scale_z_prob: Curve
@export var particle_xscale_over_lifetime: Curve3D
@export var particle_xscale_x_prob: Curve #p-xscaleXPN / p-xscalePN
@export var particle_scale_up_from_origin: bool
@export var particle_scale_birth_scale_by_bound_object_size: float
@export_subgroup("")

@export_subgroup("Mesh", "particle_")
@export var particle_mesh: String #TODO: Mesh
@export var particle_mesh_texture: Texture2D
@export var particle_mesh_skeleton: String
@export var particle_mesh_skin_mesh: String
@export var particle_mesh_animation: String #TODO: Animation
@export var particle_mesh_disable_backface_cull: bool
@export_subgroup("")

@export var particle_distortion_mode: int #TODO: enum
@export var particle_distortion: float

@export var particle_projection_fading: float
@export var particle_projection_y_range: float

@export var particle_does_cast_shadow: bool

@export var particle_uv_mode: UVMode
@export var particle_uv_scroll_rate: Vector2
@export var particle_uv_scroll_rate_y_prob: Curve
@export var particle_uv_scroll_no_alpha: bool

@export var particle_alpha_slice_range: float

@export var particle_beam_mode: BeamMode

@export var particle_trail_mode: TrailMode #p-trailmode

@export var particle_trans_sample: int

@export var particle_world_acceleration: Vector3
@export var particle_world_acceleration_over_lifetime: Curve3D
@export var particle_world_acceleration_y_prob: Curve

@export_group("")

@export var blend_mode: BlendMode #rendermode
@export var team_color_correction: bool
@export var in_uniform_scale: bool

@export_group("System")
@export var sound_on_create: String
@export var sound_persistent: String
@export var voice_over_on_create: String
@export var voice_over_persistent: String

@export var persist_thru_death: bool

@export var simulate_every_frame: bool
@export var simulate_once_per_frame: bool
@export var simulate_while_off_screen: bool
@export var sounds_play_while_off_screen: bool

@export var build_up_time: float

@export var _pass: int
@export_group("")

#func _set(_property, _value):
#    update_fields()

var particle_color_lookup_type: Vector2

var updating_fields := false
func update_fields():
    if updating_fields: return
    else: updating_fields = true

    print('update_fields')

    particle_color_lookup_type = Vector2(particle_color_lookup_type_x, particle_color_lookup_type_y)

    var total_emitter_life: float
    if emitter_life_is_infinite || emitter_lifetime < 0:
        emitter_life_is_infinite = true
        total_emitter_life = 1
        one_shot = false
    else:
        total_emitter_life = emitter_lifetime + emitter_linger
        one_shot = true
        if total_emitter_life == 0:
            emitter_enabled = false
    
    emitting = emitter_enabled

    lifetime = total_emitter_life
    # OR
    #var total_particle_life := particle_lifetime + particle_linger
    #lifetime = total_emitter_life + total_particle_life
    #explosiveness = total_particle_life / lifetime
    
    amount = round(total_emitter_life * emitter_rate)

    var m = process_material as ShaderMaterial
    m.set_shader_parameter('amount', amount)
    m.set_shader_parameter('p_life', particle_lifetime)
    m.set_shader_parameter('p_linger', particle_linger)
    m.set_shader_parameter('p_colortype', Vector2i(particle_color_lookup_type_x, particle_color_lookup_type_y))
    m.set_shader_parameter('p_rgba', particle_color_lookup_texture)
    m.set_shader_parameter('p_coloroffset', particle_color_lookup_offset)
    m.set_shader_parameter('p_colorscale', particle_color_lookup_scale)

    m = material_override as StandardMaterial3D    
    m.transparency = true
    m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
    m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    m.vertex_color_use_as_albedo = true
    m.texture = particle_texture
    m.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES

    updating_fields = false

func _ready():
    update_fields()

func tex_parse(from: String) -> Texture2D: return null
func vec3_parse(from: String) -> Vector3: return Vector3.ZERO
func vec2_parse(from: String) -> Vector2: return Vector2.ZERO
func ivec2_parse(from: String) -> Vector2i: return Vector2i.ZERO
func string_parse(from: String) -> String: return ""
func float_parse(from: String) -> float: return 0
func bool_parse(from: String) -> bool: return false
func int_parse(from: String) -> int: return 0
func uint_parse(from: String) -> int: return 0
func color_parse(from: String) -> Color: return Color.BLACK

func curve_set(curve: Curve, from: String) -> Curve: return null
func curve3d_set(curve: Curve3D, from: String) -> Curve3D: return null
func gradient_set(curve: Gradient, from: String) -> Gradient: return null

func array_get(a: Array, i: int): return a[i]
func array_set(a: Array, i: int, v): a[i] = v

func set_from_ini(d: Dictionary):
    var key_array := []
    var value = ""
    match key_array:
        ["build-up-time"]: build_up_time = float_parse(value)
        ["e-active"]: emitter_time_active_during_period = float_parse(value)
        ["e-alpharef"]: emitter_alpha_ref = int_parse(value)
        ["e-beam-segments"]: emitter_beam_segments = int_parse(value)
        ["e-framerate"]: emitter_framerate = float_parse(value)
        ["e-framerateP", var i]: emitter_framerate_prob = curve_set(emitter_framerate_prob, value)
        ["e-life-scale"]: emitter_does_lifetime_scale = bool_parse(value)
        ["e-life"]: emitter_lifetime = float_parse(value)
        ["e-linger"]: emitter_linger = float_parse(value)
        ["e-local-orient"]: emitter_is_local_orientation = bool_parse(value)
        ["e-period"]: emitter_period = float_parse(value)
        #2 ["e-rate_flex", var i]: pass
        ["e-rate", var i]: emitter_rate_over_lifetime = curve_set(emitter_rate_over_lifetime, value)
        ["e-rate"]: emitter_rate = float_parse(value)
        ["e-ratebyvel"]: emitter_rate_by_velocity = vec2_parse(value)
        ["e-rateP", var i]: emitter_rate_prob = curve_set(emitter_rate_prob, value)
        ["e-rgba", var i]: emitter_color_over_lifetime = gradient_set(emitter_color_over_lifetime, value)
        ["e-rgba"]: emitter_birth_color = color_parse(value)
        ["e-rotation", var i]: array_set(emitter_rotation_angles, i, float_parse(value))
        ["e-rotation", var i, "-axis"]: array_set(emitter_rotation_axes, i, vec3_parse(value))
        ["e-rotation", var i, "P", var j]: array_set(emitter_rotation_probs, i, curve_set(array_get(emitter_rotation_probs, i), value))
        #1 ["e-rotation", var i, "P"]: pass
        ["e-tilesize"]: emitter_trail_tile_size = vec3_parse(value)
        ["e-tilesizeYP", var i]: emitter_trail_tile_size_y_prob = curve_set(emitter_trail_tile_size_y_prob, value)
        ["e-timeoffset"]: emitter_time_before_first_emission = float_parse(value)
        ["e-trail-cutoff"]: emitter_trail_cutoff = float_parse(value)
        #2 ["e-uvoffset_flex", var i]: pass
        #2 ["e-uvoffset", var i]: pass
        ["e-uvoffset"]: emitter_birth_uv_offset = vec2_parse(value)
        ["e-uvoffsetXP", var i]: emitter_birth_uv_offset_x_prob = curve_set(emitter_birth_uv_offset_x_prob, value)
        #["e-uvoffsetYP", var i]: emitter_birth_uv_offset_y_prob = curve_set(emitter_birth_uv_offset_y_prob, value)
        ["e-uvscroll"]: emitter_uv_scroll = vec2_parse(value)
        ["Emitter-BirthRotationalAcceleration"]: emitter_birth_rotational_acceleration = vec3_parse(value) # always v3.zero
        ["ExcludeAttachmentType"]: exclude_attachment_type = string_parse(value)
        #region F
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
        ["group-vis"]: pass
        ["GroupPart", var i, "Importance"]: pass
        ["GroupPart", var i, "Type"]: pass
        ["GroupPart", var i]: pass
        ["KeepOrientationAfterSpellCast"]: pass
        ["KeywordsExcluded"]: pass
        ["KeywordsIncluded"]: pass
        ["KeywordsRequired"]: pass
        ["MaterialOverride", var i, "BlendMode"]: pass
        ["MaterialOverride", var i, "Priority"]: pass
        ["MaterialOverride", var i, "SubMesh"]: pass
        ["MaterialOverride", var i, "Texture"]: pass
        ["MaterialOverrideTransMap"]: pass
        #6 ["p-accel", var i]: pass
        ["p-accel"]: particle_birth_acceleration = vec3_parse(value)
        ["p-accelXP", var i]: particle_birth_acceleration_x_prob = curve_set(particle_birth_acceleration_x_prob, value)
        ["p-accelYP", var i]: particle_birth_acceleration_y_prob = curve_set(particle_birth_acceleration_y_prob, value)
        ["p-accelZP", var i]: particle_birth_acceleration_z_prob = curve_set(particle_birth_acceleration_z_prob, value)
        ["p-alphaslicerange"]: particle_alpha_slice_range = float_parse(value)
        ["p-animation"]: particle_mesh_animation = string_parse(value)
        ["p-backfaceon"]: particle_mesh_disable_backface_cull = int_parse(value) !=0
        ["p-beammode"]: particle_beam_mode = uint_parse(value) as BeamMode
        ["p-bindtoemitter", var i]: particle_bind_weight_over_lifetime = curve_set(particle_bind_weight_over_lifetime, value)
        ["p-bindtoemitterP", var i]: particle_bind_weight_prob = curve_set(particle_bind_weight_prob, value)
        ["p-bindtoemitter"]: particle_bind_weight = vec2_parse(value)
        ["p-coloroffset"]: particle_color_lookup_offset = vec2_parse(value)
        ["p-colorscale"]: particle_color_lookup_scale = vec2_parse(value)
        ["p-colortype"]: particle_color_lookup_type = ivec2_parse(value) # String?
        ["p-distortion-mode"]: particle_distortion_mode = uint_parse(value)
        ["p-distortion-power"]: particle_distortion = float_parse(value)
        ["p-drag", var i]: particle_drag_over_lifetime = curve3d_set(particle_drag_over_lifetime, value)
        ["p-drag"]: particle_birth_drag = vec3_parse(value)
        ["p-dragXP", var i]: particle_drag_x_prob = curve_set(particle_drag_x_prob, value)
        ["p-dragYP", var i]: particle_drag_y_prob = curve_set(particle_drag_y_prob, value)
        ["p-dragZP", var i]: particle_drag_z_prob = curve_set(particle_drag_z_prob, value)
        ["p-falloff-texture"]: particle_falloff_texture = string_parse(value)
        ["p-fixedorbit"]: particle_has_fixed_orbit = bool_parse(value)
        ["p-fixedorbittype"]: particle_fixed_orbit_type = uint_parse(value) as FixedOrbitType
        ["p-flexoffset"]: particle_scale_emit_offset_by_bound_object_size = float_parse(value)
        ["p-flexscale"]: particle_scale_birth_scale_by_bound_object_size = float_parse(value)
        #0 ["p-followterrain"]: particle_is_following_terrain = bool_parse(value)
        ["p-frameRate"]: particle_frame_rate = float_parse(value)
        #2 ["p-life_flex", var i]: pass
        #0 ["p-life-scale"]: particle_does_particle_lifetime_scales = bool_parse(value)
        ["p-life", var i]: particle_lifetime_over_lifetime = curve_set(particle_lifetime_over_lifetime, value)
        ["p-life"]: particle_lifetime = float_parse(value)
        ["p-lifeP", var i]: particle_lifetime_prob = curve_set(particle_lifetime_prob, value)
        ["p-linger"]: particle_linger = float_parse(value)
        ["p-local-orient"]: particle_is_local_orientation = bool_parse(value)
        ["p-lockedtoemitter"]: particle_locked_to_emitter = bool_parse(value)
        ["p-mesh"]: particle_mesh = string_parse(value)
        ["p-meshtex"]: particle_mesh_texture = tex_parse(value)
        ["p-normal-map"]: particle_normal_map_texture = string_parse(value)
        ["p-numframes"]: particle_number_of_frames = int_parse(value)
        #4 ["p-offset_flex", var i]: pass
        ["p-offset", var i]: particle_emit_offset_over_lifetime = curve3d_set(particle_emit_offset_over_lifetime, value)
        ["p-offset"]: particle_emit_offset = vec3_parse(value)
        #0 ["p-offsetbyheight"]: particle_scale_emit_offset_by_bound_object_height = float_parse(value)
        #0 ["p-offsetbyradius"]: particle_scale_emit_offset_by_bound_object_radius = float_parse(value)
        ["p-offsetXP", var i]: particle_emit_offset_x_prob = curve_set(particle_emit_offset_x_prob, value)
        ["p-offsetYP", var i]: particle_emit_offset_y_prob = curve_set(particle_emit_offset_y_prob, value)
        ["p-offsetZP", var i]: particle_emit_offset_z_prob = curve_set(particle_emit_offset_z_prob, value)
        ["p-orbitvel", var i]: particle_birth_orbit_velocity_over_lifetime = curve3d_set(particle_birth_orbit_velocity_over_lifetime, value)
        ["p-orbitvel"]: particle_birth_orbit_velocity = vec3_parse(value)
        ["p-orbitvelYP", var i]: particle_birth_orbit_velocity_y_prob = curve_set(particle_birth_orbit_velocity_y_prob, value)
        ["p-orientation"]: particle_orientation = vec3_parse(value)
        #0 ["p-ostoffset"]: particle_birth_translation = vec3_parse(value)
        #2 ["p-postoffset_flex", var i]: pass
        ["p-postoffset", var i]: particle_birth_translation_over_lifetime = curve3d_set(particle_birth_translation_over_lifetime, value)
        ["p-postoffset"]: particle_birth_translation = vec3_parse(value)
        ["p-postoffsetXP", var i]: particle_birth_translation_x_prob = curve_set(particle_birth_translation_x_prob, value)
        #3 ["p-postoffsetXP"]: pass
        ["p-postoffsetYP", var i]: particle_birth_translation_y_prob = curve_set(particle_birth_translation_y_prob, value)
        #3 ["p-postoffsetYP"]: pass
        ["p-postoffsetZP", var i]: particle_birth_translation_z_prob = curve_set(particle_birth_translation_z_prob, value)
        #3 ["p-postoffsetZP"]: pass
        ["p-projection-fading"]: particle_projection_fading = float_parse(value)
        ["p-projection-y-range"]: particle_projection_y_range = float_parse(value)
        ["p-quadrot", var i]: particle_rotation_over_lifetime = curve3d_set(particle_rotation_over_lifetime, value)
        ["p-quadrot"]: particle_birth_rotation = vec3_parse(value) # float in simple
        ["p-quadrotP", var i]: particle_rotation_x_prob = curve_set(particle_rotation_x_prob, value)
        ["p-quadrotXP", var i]: particle_rotation_x_prob = curve_set(particle_rotation_x_prob, value)
        ["p-quadrotYP", var i]: particle_rotation_y_prob = curve_set(particle_rotation_y_prob, value)
        ["p-quadrotZP", var i]: particle_rotation_z_prob = curve_set(particle_rotation_z_prob, value)
        ["p-randomstartframe"]: particle_start_frame_is_random = bool_parse(value)
        ["p-rgba"]: particle_color_lookup_texture = tex_parse(value)
        #2 ["p-rotvel_flex", var i]: pass
        ["p-rotvel", var i]: particle_rotational_velocity_over_lifetime = curve3d_set(particle_rotational_velocity_over_lifetime, value)
        ["p-rotvel"]: particle_birth_rotational_velocity = vec3_parse(value) # float in simple
        ["p-rotvelP", var i]: particle_rotational_velocity_x_prob = curve_set(particle_rotational_velocity_x_prob, value)
        ["p-rotvelXP", var i]: particle_rotational_velocity_x_prob = curve_set(particle_rotational_velocity_x_prob, value)
        ["p-rotvelYP", var i]: particle_rotational_velocity_y_prob = curve_set(particle_rotational_velocity_y_prob, value)
        ["p-rotvelZP", var i]: particle_rotational_velocity_z_prob = curve_set(particle_rotational_velocity_z_prob, value)
        #4 ["p-scale_flex", var i]: pass
        ["p-scale", var i]: particle_scale_over_lifetime = curve3d_set(particle_scale_over_lifetime, value)
        ["p-scale"]: particle_birth_scale = vec3_parse(value) # float in simple
        ["p-scalebias"]: particle_scale_bias = vec2_parse(value)
        #0 ["p-scalebyheight"]: particle_scale_birth_scale_by_bound_object_height = float_parse(value)
        #0 ["p-scalebyradius"]: particle_scale_birth_scale_by_bound_object_radius = float_parse(value)
        #2 ["p-scaleEmitOffset_flex", var i]: pass
        ["p-scaleupfromorigin"]: particle_scale_up_from_origin = bool_parse(value)
        ["p-scaleP", var i]: particle_scale_x_prob = curve_set(particle_scale_x_prob, value)
        ["p-scaleXP", var i]: particle_scale_x_prob = curve_set(particle_scale_x_prob, value)
        ["p-scaleYP", var i]: particle_scale_y_prob = curve_set(particle_scale_y_prob, value)
        ["p-scaleZP", var i]: particle_scale_z_prob = curve_set(particle_scale_z_prob, value)
        ["p-shadow"]: particle_does_cast_shadow = bool_parse(value)
        ["p-simpleorient"]: particle_simple_orientation = uint_parse(value) as Orientation
        ["p-skeleton"]: particle_mesh_skeleton = string_parse(value)
        ["p-skin"]: particle_mesh_skin_mesh = string_parse(value)
        ["p-startframe"]: particle_start_frame = int_parse(value)
        ["p-texdiv"]: particle_texture_division = vec2_parse(value)
        ["p-texture"]: particle_texture = tex_parse(value)
        ["p-trailmode"]: particle_trail_mode = uint_parse(value) as TrailMode
        ["p-trans-sample"]: particle_trans_sample = uint_parse(value) 
        ["p-type"]: particle_quad_type = int_parse(value)
        ["p-uvmode"]: particle_uv_mode = uint_parse(value) as UVMode
        ["p-uvscroll-no-alpha"]: particle_uv_scroll_no_alpha = bool_parse(value)
        #0 ["p-uvscroll-rgb-clamp"]: particle_uv_scroll_clamp = bool_parse(value)
        ["p-uvscroll-rgb"]: particle_uv_scroll_rate = vec2_parse(value)
        ["p-uvscroll-rgbYP", var i]: particle_uv_scroll_rate_y_prob = curve_set(particle_uv_scroll_rate_y_prob, value)
        ["p-vecalign"]: particle_is_direction_oriented = bool_parse(value)
        #2 ["p-vel_flex", var i]: pass
        ["p-vel", var i]: particle_velocity_over_lifetime = curve3d_set(particle_velocity_over_lifetime, value)
        ["p-vel"]: particle_birth_velocity = vec3_parse(value)
        ["p-velXP", var i]: particle_velocity_x_prob = curve_set(particle_velocity_x_prob, value)
        ["p-velYP", var i]: particle_velocity_y_prob = curve_set(particle_velocity_y_prob, value)
        ["p-velZP", var i]: particle_velocity_z_prob = curve_set(particle_velocity_z_prob, value)
        ["p-worldaccel", var i]: particle_world_acceleration_over_lifetime = curve3d_set(particle_world_acceleration_over_lifetime, value)
        ["p-worldaccel"]: particle_world_acceleration = vec3_parse(value)
        ["p-worldaccelYP", var i]: particle_world_acceleration_y_prob = curve_set(particle_world_acceleration_y_prob, value)
        ["p-xquadrot-on"]: particle_xrotation_is_enabled = bool_parse(value)
        ["p-xquadrot", var i]: particle_xrotation_over_lifetime = curve3d_set(particle_xrotation_over_lifetime, value)
        ["p-xquadrot"]: particle_xrotation = vec3_parse(value) # float in simple
        ["p-xquadrotP", var i]: particle_xrotation_x_prob = curve_set(particle_xrotation_x_prob, value)
        ["p-xrgba", var i]: particle_color_over_lifetime = gradient_set(particle_color_over_lifetime, value)
        ["p-xrgba"]: particle_color = color_parse(value)
        ["p-xscale", var i]: particle_xscale_over_lifetime = curve3d_set(particle_xscale_over_lifetime, value)
        ["p-xscale"]: particle_xscale = vec3_parse(value) # float in simple
        ["p-xscaleP", var i]: particle_xscale_x_prob = curve_set(particle_xscale_x_prob, value)
        ["Particle-Acceleration", var i]: particle_birth_acceleration_over_lifetime = curve3d_set(particle_birth_acceleration_over_lifetime, value)
        ["Particle-Acceleration"]: particle_birth_acceleration = vec3_parse(value)
        ["Particle-AccelerationXP", var i]: particle_birth_acceleration_x_prob = curve_set(particle_birth_acceleration_x_prob, value)
        ["Particle-AccelerationYP", var i]: particle_birth_acceleration_y_prob = curve_set(particle_birth_acceleration_y_prob, value)
        ["Particle-AccelerationZP", var i]: particle_birth_acceleration_z_prob = curve_set(particle_birth_acceleration_z_prob, value)
        ["Particle-Drag"]: particle_birth_drag = vec3_parse(value)
        #0 ["Particle-ScaleAlongMovementVector"]: scale_along_movement_vector = float_parse(value)
        ["Particle-Velocity", var i]: particle_velocity_over_lifetime = curve3d_set(particle_velocity_over_lifetime, value)
        ["Particle-Velocity"]: particle_birth_velocity = vec3_parse(value)
        ["pass"]: _pass = int_parse(value)
        ["PersistThruDeath"]: persist_thru_death = bool_parse(value)
        ["rendermode"]: blend_mode = int_parse(value) as BlendMode
        #1 ["SelfIllumination"]: self_illumination = float_parse(value) # bool?
        ["SimulateEveryFrame"]: simulate_every_frame = bool_parse(value)
        ["SimulateOncePerFrame"]: simulate_once_per_frame = bool_parse(value)
        ["SimulateWhileOffScreen"]: simulate_while_off_screen = bool_parse(value)
        ["single-particle"]: emitter_emit_single_particle = int_parse(value)
        ["SoundOnCreate"]: sound_on_create = string_parse(value)
        ["SoundPersistent"]: sound_persistent = string_parse(value)
        ["SoundsPlayWhileOffScreen"]: sounds_play_while_off_screen = bool_parse(value)
        ["teamcolor-correction"]: team_color_correction = bool_parse(value)
        ["uniformscale"]: in_uniform_scale = int_parse(value) != 0
        ["VoiceOverOnCreate"]: voice_over_on_create = string_parse(value)
        ["VoiceOverPersistent"]: voice_over_persistent = string_parse(value)
