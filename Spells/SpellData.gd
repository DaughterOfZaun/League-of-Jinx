class_name SpellData
extends Node

@export var after_effect_name := ""
@export var alternate_name := ""
@export var always_snap_facing := false
@export var animation_loop_name := ""
@export var animation_name := ""
@export var animation_winddown_name := ""
@export var apply_attack_damage := false
@export var belongs_to_avatar := false
@export var bounce_radius := 450.0
@export var can_cast_while_disabled := false
@export var cannot_be_suppressed := false
@export var can_only_cast_while_dead := false
@export var cant_cancel_while_channeling := false
@export var cant_cancel_while_winding_up := true
@export var cant_cast_while_rooted := false
@export var cast_cone_angle := 45.0
@export var cast_cone_distance := 100.0
@export var cast_frame := 7.5
@export var cast_radius := 100.0
@export var cast_radius_texture := "AOE.tga"
@export var cast_radius_secondary := 0.0
@export var cast_radius_secondary_texture := ""
@export var cast_range_by_level: Array[float] = [ 0, 0, 0, 0, 0, 0, 0 ]
@export var cast_range_display_override_by_level: Array[float] = [ 0, 0, 0, 0, 0, 0 ]
@export var cast_range_use_bounding_boxes := false
@export var cast_range_use_map_scaling := false
@export var cast_target_additional_units_radius := 0.0
@export var cast_type := Enums.CastType.INSTANT
@export var channel_duration_by_level: Array[float] = [ 0, 0, 0, 0, 0, 0, 0 ]
@export var circle_missile_angular_velocity := 0.0
@export var circle_missile_radial_velocity := 0.0
@export var coefficient: Array[float] = [ 0, 0 ]
@export var cooldown_by_level: Array[float] = [ 0, 0, 0, 0, 0, 0, 0 ]
@export var death_recap_priority := 0.0
@export var delay_cast_offset_percent := -0.5
@export var delay_total_time_percent := 0.0
@export var description := ""
@export var display_name := ""
@export var dynamic_extended := ""
@export var dynamic_tooltip := ""
@export var effect_level_amount: Array[Array] = [
	[ 0, 0, 0, 0, 0, 0, 0 ],
	[ 0, 0, 0, 0, 0, 0, 0 ],
	[ 0, 0, 0, 0, 0, 0, 0 ],
	[ 0, 0, 0, 0, 0, 0, 0 ],
	[ 0, 0, 0, 0, 0, 0, 0 ],
	[ 0, 0, 0, 0, 0, 0, 0 ],
]
@export var flags := Enums.SpellFlags.DEFAULT
@export var float_statics_decimals: Array[int] = [ 0, 0, 0, 0, 0, 0 ]
@export var float_vars_decimals: Array[int] = [ 0, 0, 0, 0, 0, 0 ]
@export var have_after_effect := false
@export var have_hit_bone := false
@export var have_hit_effect := false
@export var have_point_effect := false
@export var hit_bone_name := ""
@export var hit_effect_name := ""
@export var inventory_icon: Array[String] = [ "", "", "" ]
@export var is_disabled_while_dead := true
@export var is_toggle_spell := false
@export var level_desc: Array[String] = [ "", "", "", "", "", "" ]
@export var line_drag_length := 0.0
@export var line_missile_bounces := false
@export var line_missile_collision_from_start_point := false
@export var line_missile_delay_destroy_at_end_seconds := false #?
@export var line_missile_ends_at_target_point := false
@export var line_missile_target_height_augment := 0.0
@export var line_missile_time_pulse_between_collision_spell_hits := false #?
@export var line_missile_track_units := false
@export var line_width := 0.0
@export var location_targetting_length: Array[float] = [ 0, 0, 0, 0, 0, 0 ] #_by_level?
@export var location_targetting_width: Array[float] = [ 0, 0, 0, 0, 0, 0 ] #_by_level?
@export var lock_cone_to_player := false
@export var on_missile_update_distance_interval := 0.0
@export var mana_cost_by_level: Array[float] = [ 0, 0, 0, 0, 0, 0, 0 ]
@export var missile_accel := 0.0
@export var missile_bone_name := ""
@export var missile_effect := ""
@export var missile_fixed_travel_time := 0.0
@export var missile_gravity := 0.0
@export var missile_lifetime := 0.0
@export var missile_max_speed := 0.0
@export var missile_min_speed := 0.0
@export var missile_perception_bubble_radius := 0.0
@export var missile_perception_bubble_reveals_stealth := false
@export var missile_speed := 0.0
@export var missile_target_height_augment := 100.0
#@export var name := ""
@export var override_cast_time := 0.0
@export var override_force_spell_animation := false
@export var override_force_spell_cancel := false
@export var particle_start_offset := Vector3.ZERO
@export var platform_enabled := false #?
@export var point_effect_name := ""
@export var range_indicator_texture_name := ""
@export var ranks := 1
@export var selection_preference := Enums.SpellSelectPref.NONE
@export var sound_cast_name := "none.wav"
@export var sound_hit_name := "none.wav"
@export var spell_reveals_champion := true
@export var start_cooldown := 0.0
@export var subject_to_global_cooldown := true
@export var targetting_type := Enums.TargetingType.TARGET
#@export var text_flags
@export var triggers_global_cooldown := true
@export var use_animator_framerate := false
@export var use_minimap_targeting := false
@export var version := 1
@export var x1: Array[float] = [ 0, 0, 0, 0, 0 ] #?
