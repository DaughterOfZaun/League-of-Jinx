@tool
#class_name Particle
extends GPUParticles3D

enum ColorLookupType {
    CONSTANT = 0,
    LIFETIME = 1,
    VELOCITY = 2,
    BIRTH_RANDOM = 3,
    COUNT = 4
}

enum BlendMode {
    UNKNOWN_0,
    UNKNOWN_1,
    UNKNOWN_2,
    UNKNOWN_3,
    UNKNOWN_4,
}

enum TrailMode {
    DEFAULT = 0,
    WAKE = 1,
}



@export_group("Emitter", "")
@export var emitter_enabled := true:
    set(value):
        emitter_enabled = value
        update_fields()
@export var emitter_rate: float:
    set(value):
        emitter_rate = value
        update_fields()
@export var emitter_life: float:
    set(value):
        emitter_life = value
        update_fields()
@export var emitter_life_is_infinite := false:
    set(value):
        emitter_life_is_infinite = value
        update_fields()
@export var emitter_linger: float:
    set(value):
        emitter_linger = value
        update_fields()
@export var emitter_orientation_is_local: bool: #e-local-orient
    set(value):
        emitter_orientation_is_local = value
        update_fields()

@export var emit_single_particle: bool #single-particle

@export_group("Particle", "")
@export var particle_life: float:
    set(value):
        particle_life = value
        update_fields()
@export var particle_life_curve: Curve
@export var particle_linger: float:
    set(value):
        particle_linger = value
        update_fields()

@export var particle_scale: float: #TODO: Deprecate
    set(value):
        particle_scale = value
        update_fields()

@export var particle_texture: Texture2D:
    set(value):
        particle_texture = value
        update_fields()

@export_subgroup("Animation")
@export var particle_texture_division: Vector2 #p-texdiv
@export var particle_start_frame: int #p-startframe
@export var particle_frame_number: int #p-numframes
@export var particle_frame_rate: float #p-frameRate
@export var particle_start_frame_is_random: bool #p-randomstartframe
@export_subgroup("")

@export_subgroup("Color Lookup", "color_lookup_")
@export var color_lookup_texture: Texture2D: #p-rgba
    set(value):
        color_lookup_texture = value
        update_fields()
@export var color_lookup_type_x: ColorLookupType: #p-colortype
    set(value):
        color_lookup_type_x = value
        update_fields()
@export var color_lookup_type_y: ColorLookupType: #p-colortype
    set(value):
        color_lookup_type_y = value
        update_fields()
@export var color_lookup_scale: Vector2 = Vector2.ONE:
    set(value):
        color_lookup_scale = value
        update_fields()
@export var color_lookup_offset: Vector2 #p-coloroffset

@export var blend_mode: BlendMode #rendermode
@export var trail_mode: TrailMode #p-trailmode

@export_subgroup("Position")
@export var particle_emit_offset: Vector3 #p-offset
@export var particle_emit_offset_curve: Curve3D

@export var particle_bind_weight: Vector2 #p-bindtoemitter
@export var particle_birth_translation: Vector3 #p-postoffset
@export var particle_birth_velocity: Vector3 #p-vel
@export var particle_velocity_curve: Curve3D
@export var particle_birth_drag: Vector3 #p-drag
@export_subgroup("")

@export_subgroup("Rotation")
@export var particle_orientation_is_local: bool #p-local-orient
@export var particle_birth_rotation: Vector3 #p-quadrot
@export var particle_rotation_curve: Curve3D #p-quadrotPN
@export var particle_birth_rotational_velocity: Vector3 #p-rotvel
@export var particle_rotational_velocity_curve: Curve3D #p-rotvelPN
@export_subgroup("")

@export_subgroup("Scale")
@export var particle_birth_scale: Vector3 #p-scale
@export var particle_scale_curve: Curve3D #p-xscaleN
@export_subgroup("")

#func _set(_property, _value):
#    update_fields()

var updating_fields := false
func update_fields():
    if updating_fields: return
    else: updating_fields = true

    print('update_fields')

    var total_emitter_life: float
    if emitter_life_is_infinite || emitter_life < 0:
        emitter_life_is_infinite = true
        total_emitter_life = 1
        one_shot = false
    else:
        total_emitter_life = emitter_life + emitter_linger
        one_shot = true
        if total_emitter_life == 0:
            emitter_enabled = false
    
    emitting = emitter_enabled

    lifetime = total_emitter_life
    # OR
    #var total_particle_life := particle_life + particle_linger
    #lifetime = total_emitter_life + total_particle_life
    #explosiveness = total_particle_life / lifetime
    
    amount = round(total_emitter_life * emitter_rate)

    var m = process_material as ShaderMaterial
    m.set_shader_parameter('amount', amount)
    m.set_shader_parameter('p_life', particle_life)
    m.set_shader_parameter('p_linger', particle_linger)
    m.set_shader_parameter('p_linger', particle_linger)
    m.set_shader_parameter('p_colortype', Vector2i(color_lookup_type_x, color_lookup_type_y))
    m.set_shader_parameter('p_rgba', color_lookup_texture)

    m = material_override as StandardMaterial3D
    m.vertex_color_use_as_albedo = true
    m.texture = particle_texture
    m.transparency = true

    updating_fields = false

func _ready():
    update_fields()
