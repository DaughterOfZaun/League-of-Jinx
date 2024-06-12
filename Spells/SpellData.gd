class_name SpellData
extends Node

@export var inventory_icon: Array[Texture2D] = []
@export var spell_name := ""
@export var display_name := ""
@export var alternate_name := ""
@export var description := ""
@export var level_desc: Array[String] = [ "Level 1", "Level 2", "Level 3", "Level 4", "Level 5", "Level 6" ]

#region Tooltip
@export_group("Tooltip")
@export var dynamic_tooltip := ""
@export var dynamic_extended := ""
@export var float_statics_decimals: Array[int] = [ 2, 2, 2, 2, 2, 2 ]
@export var float_vars_decimals: Array[int] = [ 2, 2, 2, 2, 2, 2 ]
@export var effect_level_amount: Array[Array] = [
	[ 0, 0, 0, 0, 0, 0, 0 ],
	[ 0, 0, 0, 0, 0, 0, 0 ],
	[ 0, 0, 0, 0, 0, 0, 0 ],
	[ 0, 0, 0, 0, 0, 0, 0 ],
	[ 0, 0, 0, 0, 0, 0, 0 ],
	[ 0, 0, 0, 0, 0, 0, 0 ],
]
@export_group("")
#endregion

@export var cast_time := 0.0
@export var override_cast_time := 0.0
@export var channel_duration := 0.0
@export var channel_duration_by_level: Array[float] = [ 0, 0, 0, 0, 0, 0, 0 ]
@export var mana_cost_by_level: Array[float] = [ 0, 0, 0, 0, 0, 0, 0 ]

#region Cooldown
@export_subgroup("Cooldown")
@export var start_cooldown := 0.0
@export var cooldown_by_level: Array[float] = [ 0, 0, 0, 0, 0, 0, 0 ]
var auto_cooldown_by_level: Array[float]:
	get:
		return cooldown_by_level
	set(value):
		cooldown_by_level = value
@export var subject_to_global_cooldown := true
@export var triggers_global_cooldown := true
#endregion

#region Animation
@export_group("Animation")
@export var cast_frame := 7.5
@export var animation_name := ""
@export var animation_loop_name := ""
@export var animation_winddown_name := ""
@export var use_animator_framerate := false
@export_group("")
#endregion

#region Targetting
@export_group("Targetting")
@export var targetting_type := Enums.TargetingType.TARGET
@export var selection_preference := Enums.SpellSelectPref.NONE
@export var cast_target_additional_units_radius := 0.0
@export var location_targetting_width: Array[float] = [ 0, 0, 0, 0, 0, 0 ] #_by_level?
@export var location_targetting_length: Array[float] = [ 0, 0, 0, 0, 0, 0 ] #_by_level?
@export var use_minimap_targeting := false
#region Cast Cone
@export_subgroup("Cast Cone")
@export var cast_cone_angle := 45.0
@export var cast_cone_distance := 100.0
@export var lock_cone_to_player := false
#endregion
#region Cast Radius
@export_subgroup("Cast Radius", "cast_radius_")
@export var cast_radius_primary := 100.0 # renamed from cast_radius
@export var cast_radius_texture: Texture2D
@export var cast_radius_secondary := 0.0
@export var cast_radius_secondary_texture: Texture2D
#endregion
#region Cast Range
@export_subgroup("Cast Range", "cast_range_")
@export var cast_range_by_level: Array[float] = [ 0, 0, 0, 0, 0, 0, 0 ]
@export var cast_range_display_override_by_level: Array[float] = [ 0, 0, 0, 0, 0, 0 ]
@export var cast_range_use_bounding_boxes := false
@export var cast_range_use_map_scaling := false
@export var cast_range_indicator_texture: Texture2D # renamed from range_indicator_texture_name
#endregion
#region Flags
@export_subgroup("Flags", "flags")
@export_flags(
	"AUTO_CAST:2",
	"INSTANT_CAST:4",
	"PERSIST_THROUGH_DEATH:8",
	"NON_DISPELLABLE:16",
	"NO_CLICK:32",
	"AFFECT_IMPORTANT_BOT_TARGETS:64",
	"ALLOW_WHILE_TAUNTED:128",
	"NOT_AFFECT_ZOMBIE:256",
	"AFFECT_UNTARGETABLE:512",
	"AFFECT_ENEMIES:1024",
	"AFFECT_FRIENDS:2048",
	"AFFECT_NEUTRAL:16384",
	"AFFECT_BUILDINGS:4096",
	"AFFECT_MINIONS:32768",
	"AFFECT_HEROES:65536",
	"AFFECT_TURRETS:131072",
	"NOT_AFFECT_SELF:8192",
	"ALWAYS_SELF:262144",
	"AFFECT_DEAD:524288",
	"AFFECT_NOT_PET:1048576",
	"AFFECT_BARRACK_ONLY:2097152",
	"IGNORE_VISIBILITY_CHECK:4194304",
	"NON_TARGETABLE_ALLY:8388608",
	"NON_TARGETABLE_ENEMY:16777216",
	"TARGETABLE_TO_ALL:33554432",
	"AFFECT_WARDS:67108864",
	"AFFECT_USEABLE:134217728",
	"IGNORE_ALLY_MINION:268435456",
	"IGNORE_ENEMY_MINION:536870912",
	"IGNORE_LANE_MINION:1073741824",
	"IGNORE_CLONES:2147483648"
) var flags: int = Enums.SpellFlags.DEFAULT
#endregion
@export_group("")
#endregion

#region Effects
@export_group("Effects")
@export var have_after_effect := false
@export var after_effect_name := ""

@export var have_hit_bone := false
@export var hit_bone_name := ""

@export var have_hit_effect := false
@export var hit_effect_name := ""

@export var have_point_effect := false
@export var point_effect_name := ""

@export var particle_start_offset := Vector3.ZERO
@export var sound_cast_name := "none.wav"
@export var sound_hit_name := "none.wav"

@export var spell_fx_override_skins: Array[String] = []
@export var spell_vo_override_skins: Array[String] = []
@export_group("")
#endregion

#region Cast
@export_group("Cast")
@export var cast_type := Enums.CastType.INSTANT
#region Overrides
@export_subgroup("Overrides")
@export var override_force_spell_cancel := false
@export var override_force_spell_animation := false
@export_subgroup("")
#endregion
@export var delay_cast_offset_percent := -0.5
@export var delay_total_time_percent := 0.0
#region Flags
@export_subgroup("Flags")
@export var always_snap_facing := false
@export var spell_reveals_champion := true
@export var can_cast_while_disabled := false
@export var cannot_be_suppressed := false
@export var can_only_cast_while_dead := false
@export var cant_cancel_while_channeling := false
@export var cant_cancel_while_winding_up := true
@export var cant_cast_while_rooted := false
@export var is_disabled_while_dead := true
@export var is_toggle_spell := false
#endregion
#region Missile
@export_subgroup("Missile", "missile_")
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
@export var missile_update_distance_interval := 0.0
#endregion
#region Line Missile
@export_subgroup("Line Missile", "line_missile_")
@export var line_missile_bounces := false
@export var line_missile_bounce_radius := 450.0 # renamed from bounce_radius
@export var line_missile_collision_from_start_point := false
@export var line_missile_delay_destroy_at_end_seconds := false #?
@export var line_missile_ends_at_target_point := false
@export var line_missile_target_height_augment := 0.0
@export var line_missile_time_pulse_between_collision_spell_hits := false #?
@export var line_missile_track_units := false
@export var line_width := 0.0
@export var line_drag_length := 0.0
#endregion
#region Circle Missile
@export_subgroup("Circle Missile", "circle_missile_")
@export var circle_missile_angular_velocity := 0.0
@export var circle_missile_radial_velocity := 0.0
#endregion
#region Chain Missile
@export_subgroup("Chain Missile", "chain_missile_")
@export var chain_missile_can_hit_caster := false
@export var chain_missile_can_hit_enemies := false
@export var chain_missile_can_hit_friends := false
@export var chain_missile_can_hit_same_target := false
@export var chain_missile_can_hit_same_target_consecutively := false
@export var chain_missile_maximum_hits := 0
@export var chain_missile_maximum_hits_by_level: Array[int] = [ 0, 0, 0, 0, 0 ]
#endregion
@export_group("")
#endregion

#region Damage
@export_subgroup("Damage")
@export var apply_attack_damage := false
@export var auto_target_damage_by_level: Array[float] = [ 0.0, 0.0, 0.0, 0.0, 0.0 ]
@export var physical_damage_ratio := 0.0
@export var spell_damage_ratio := 0.0
@export var death_recap_priority := 0.0
@export_subgroup("")
#endregion

#region Metadata
@export_subgroup("Metadata")
@export var casting_breaks_stealth := false
@export var doesnt_break_shields := false
@export var is_damaging_spell := false
@export var not_single_target_spell := false
@export var triggers_spell_casts := false
var doesnt_trigger_spell_casts: bool:
	get:
		return !triggers_spell_casts
	set(value):
		triggers_spell_casts = !value
@export_subgroup("")
#endregion

#region Other
@export_group("Other")
@export var ranks := 1
@export var version := 1
@export var belongs_to_avatar := false
@export var platform_enabled := false #?
@export var coefficient: Array[float] = [ 0, 0 ]
@export var x: Array[float] = [ 0, 0, 0, 0, 0 ] #?
@export_group("")
#endregion
