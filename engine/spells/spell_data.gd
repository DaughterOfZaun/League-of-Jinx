@tool
class_name SpellData
extends Data

@export var inventory_icon: Array[Texture2D] #=[]
@export var spell_name: String
@export var display_name: String
@export var alternate_name: String
@export var description: String
@export var level_desc: Array[String] #= [ "Level 1", "Level 2", "Level 3", "Level 4", "Level 5", "Level 6" ]

#region Tooltip
@export_group("Tooltip")
@export var dynamic_tooltip: String
@export var dynamic_extended: String
@export var float_statics_decimals: Array[int] #= [ 2, 2, 2, 2, 2, 2 ]
@export var float_vars_decimals: Array[int] #= [ 2, 2, 2, 2, 2, 2 ]
@export var effect_level_amount: Array[Array] #= [
#    [ 0, 0, 0, 0, 0, 0, 0 ],
#    [ 0, 0, 0, 0, 0, 0, 0 ],
#    [ 0, 0, 0, 0, 0, 0, 0 ],
#    [ 0, 0, 0, 0, 0, 0, 0 ],
#    [ 0, 0, 0, 0, 0, 0, 0 ],
#    [ 0, 0, 0, 0, 0, 0, 0 ],
#]
@export_group("")
#endregion

@export var cast_time: float
@export var override_cast_time: float
@export var channel_duration: float
@export var channel_duration_by_level: Array[float] #= [ 0, 0, 0, 0, 0, 0, 0 ]
@export var mana_cost: float
@export var mana_cost_by_level: Array[float] #= [ 0, 0, 0, 0, 0, 0, 0 ]

#region Cooldown
@export_subgroup("Cooldown")
@export var cooldown: float # renamed from start_cooldown
@export var cooldown_by_level: Array[float] #= [ 0, 0, 0, 0, 0, 0, 0 ]
var auto_cooldown_by_level: Array[float]:
	get:
		return cooldown_by_level
	set(value):
		cooldown_by_level = value
@export var subject_to_global_cooldown: bool #= true
@export var triggers_global_cooldown: bool #= true
#endregion

#region Animation
@export_group("Animation")
@export var cast_frame: float #= 7.5
@export var animation_name: String
@export var animation_loop_name: String
@export var animation_winddown_name: String
@export var use_animator_framerate: bool
@export_group("")
#endregion

#region Targetting
@export_group("Targetting")
@export var targetting_type: Enums.TargetingType #= Enums.TargetingType.TARGET
@export var selection_preference: Enums.SpellSelectPref #= Enums.SpellSelectPref.NONE
@export var cast_target_additional_units_radius: float
@export var location_targetting_width: float
@export var location_targetting_width_by_level: Array[float] #= [ 0, 0, 0, 0, 0, 0 ]
@export var location_targetting_length: float
@export var location_targetting_length_by_level: Array[float] #= [ 0, 0, 0, 0, 0, 0 ]
@export var use_minimap_targeting: bool
#region Cast Cone
@export_subgroup("Cast Cone")
@export var cast_cone_angle: float #= 45.0
@export var cast_cone_distance: float #= 100.0
@export var lock_cone_to_player: bool
#endregion
#region Cast Radius
@export_subgroup("Cast Radius", "cast_radius_")
@export var cast_radius_primary: float #= 100.0 # renamed from cast_radius
@export var cast_radius_texture_name: String
@export var cast_radius_texture: Texture2D
@export var cast_radius_secondary: float
@export var cast_radius_secondary_texture_name: String
@export var cast_radius_secondary_texture: Texture2D
#endregion
#region Cast Range
@export_subgroup("Cast Range", "cast_range_")
@export var cast_range: float
@export var cast_range_by_level: Array[float] #= [ 0, 0, 0, 0, 0, 0, 0 ]
@export var cast_range_display_override: float
@export var cast_range_display_override_by_level: Array[float] #= [ 0, 0, 0, 0, 0, 0 ]
@export var cast_range_use_bounding_boxes: bool
@export var cast_range_use_map_scaling: bool
@export var cast_range_indicator_texture_name: String
@export var cast_range_indicator_texture: Texture2D
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
) var flags: int #= Enums.SpellFlags.DEFAULT
#endregion
@export_group("")
#endregion

#region Effects
@export_group("Effects")
var have_after_effect: bool
@export var after_effect_name: String
@export var after_effect: PackedScene

var have_hit_bone: bool
@export var hit_bone_name: String

var have_hit_effect: bool
@export var hit_effect_name: String
@export var hit_effect: PackedScene

var have_point_effect: bool
@export var point_effect_name: String
@export var point_effect: PackedScene

@export var particle_start_offset: Vector3
@export var sound_cast_name: String #= "none.wav"
@export var sound_hit_name: String  #= "none.wav"

@export var spell_fx_override_skins: Array[String] #=[]
@export var spell_vo_override_skins: Array[String] #=[]
@export_group("")
#endregion

#region Cast
@export_group("Cast")
@export var cast_type: Enums.CastType #= Enums.CastType.INSTANT
#region Overrides
@export_subgroup("Overrides")
@export var override_force_spell_cancel: bool
@export var override_force_spell_animation: bool
@export_subgroup("")
#endregion
@export var delay_cast_offset_percent: float #= -0.5
@export var delay_total_time_percent: float
#region Flags
@export_subgroup("Flags")
@export var always_snap_facing: bool
@export var spell_reveals_champion: bool #= true
@export var can_cast_while_disabled: bool
@export var cannot_be_suppressed: bool
@export var can_only_cast_while_dead: bool
@export var cant_cancel_while_channeling: bool
@export var cant_cancel_while_winding_up: bool #= true
@export var cant_cast_while_rooted: bool
@export var is_disabled_while_dead: bool #= true
@export var is_toggle_spell: bool
#endregion
#region Missile
@export_subgroup("Missile", "missile_")
@export var missile_accel: float
@export var missile_bone_name: String
@export var missile_effect: String
@export var missile_fixed_travel_time: float
@export var missile_gravity: float
@export var missile_lifetime: float
@export var missile_max_speed: float
@export var missile_min_speed: float
@export var missile_perception_bubble_radius: float
@export var missile_perception_bubble_reveals_stealth: bool
@export var missile_speed: float
@export var missile_target_height_augment: float #= 100.0
@export var missile_update_distance_interval: float
#endregion
#region Line Missile
@export_subgroup("Line Missile", "line_missile_")
@export var line_missile_bounces: bool
@export var line_missile_bounce_radius: float #= 450.0 # renamed from bounce_radius
@export var line_missile_collision_from_start_point: bool
@export var line_missile_delay_destroy_at_end_seconds: float
@export var line_missile_ends_at_target_point: bool
@export var line_missile_target_height_augment: float
@export var line_missile_time_pulse_between_collision_spell_hits: float
@export var line_missile_track_units: bool
@export var line_width: float
@export var line_drag_length: float
#endregion
#region Circle Missile
@export_subgroup("Circle Missile", "circle_missile_")
@export var circle_missile_angular_velocity: float
@export var circle_missile_radial_velocity: float
#endregion
#region Chain Missile
@export_subgroup("Chain Missile", "chain_missile_")
@export var chain_missile_can_hit_caster: bool
@export var chain_missile_can_hit_enemies: bool
@export var chain_missile_can_hit_friends: bool
@export var chain_missile_can_hit_same_target: bool
@export var chain_missile_can_hit_same_target_consecutively: bool
@export var chain_missile_maximum_hits: int
@export var chain_missile_maximum_hits_by_level: Array[int] #= [ 0, 0, 0, 0, 0 ]
#endregion
@export_group("")
#endregion

#region Damage
@export_subgroup("Damage")
@export var apply_attack_damage: bool
@export var auto_target_damage: float
@export var auto_target_damage_by_level: Array[float] #= [ 0.0, 0.0, 0.0, 0.0, 0.0 ]
@export var physical_damage_ratio: float
@export var spell_damage_ratio: float
@export var death_recap_priority: float
@export_subgroup("")
#endregion

#region Metadata
@export_subgroup("Metadata")
@export var casting_breaks_stealth: bool
@export var doesnt_break_shields: bool
@export var is_damaging_spell: bool
@export var not_single_target_spell: bool
@export var triggers_spell_casts: bool
var doesnt_trigger_spell_casts: bool:
	get:
		return !triggers_spell_casts
	set(value):
		triggers_spell_casts = !value
@export_subgroup("")
#endregion

#region Other
@export_group("Other")
@export var ranks: int #= 1
@export var version: int #= 1
@export var belongs_to_avatar: bool
@export var platform_enabled: bool #?
@export var coefficient: Array[float] #= [ 0, 0 ]
@export var x: Array[float] #= [ 0, 0, 0, 0, 0 ] #?
@export_group("")
#endregion

#region Import
@export_group("Import")
@export_file("*.ini") var import_path: String
@export var import: bool:
	set(value):
		if value && !import:
			import = true
			var ini = ini_load(import_path)
			set_from_ini_section(ini["SpellData"])
			import = false
@export_group("")

func set_from_ini_entry(key_array: Array, value: String):
	match key_array:
		["AfterEffectName"]:
			after_effect_name = string_parse(value)
			after_effect = effect_parse(value)
		["AlternateName"]: alternate_name = string_parse(value)
		["AlwaysSnapFacing"]: always_snap_facing = bool_parse(value)
		["AnimationLoopName"]: animation_loop_name = string_parse(value)
		["AnimationName"]: animation_name = string_parse(value)
		["AnimationWinddownName"]: animation_winddown_name = string_parse(value)
		["ApplyAttackDamage"]: apply_attack_damage = bool_parse(value)
		["BelongsToAvatar"]: belongs_to_avatar = bool_parse(value)
		["BounceRadius"]: line_missile_bounce_radius = float_parse(value)
		["CanCastWhileDisabled"]: can_cast_while_disabled = bool_parse(value)
		["CannotBeSuppressed"]: cannot_be_suppressed = bool_parse(value)
		["CanOnlyCastWhileDead"]: can_only_cast_while_dead = bool_parse(value)
		["CantCancelWhileChanneling"]: cant_cancel_while_channeling = bool_parse(value)
		["CantCancelWhileWindingUp"]: cant_cancel_while_winding_up = bool_parse(value)
		["CantCastWhileRooted"]: cant_cast_while_rooted = bool_parse(value)
		["CastConeAngle"]: cast_cone_angle = float_parse(value)
		["CastConeDistance"]: cast_cone_distance = float_parse(value)
		["CastFrame"]: cast_frame = float_parse(value)
		["CastRadius"]: cast_radius_primary = float_parse(value)
		["CastRadiusSecondary"]: cast_radius_secondary = float_parse(value)
		["CastRadiusSecondaryTexture"]:
			cast_radius_secondary_texture_name = string_parse(value)
			cast_radius_secondary_texture = tex_parse(value)
		["CastRadiusTexture"]:
			cast_radius_texture_name = string_parse(value)
			cast_radius_texture = tex_parse(value)
		["CastRange"]: cast_range = float_parse(value)
		["CastRange", var i]: array_set(cast_range_by_level, i - 1, value)
		["CastRangeDisplayOverride"]: cast_range_display_override = float_parse(value)
		["CastRangeDisplayOverride", var i]: array_set(cast_range_display_override_by_level, i - 1, value)
		["CastRangeUseBoundingBoxes"]: cast_range_use_bounding_boxes = bool_parse(value)
		["CastRangeUseMapScaling"]: cast_range_use_map_scaling = bool_parse(value)
		["CastTargetAdditionalUnitsRadius"]: cast_target_additional_units_radius = float_parse(value)
		["CastType"]: cast_type = int_parse(value) as Enums.CastType
		["ChannelDuration"]: channel_duration = float_parse(value)
		["ChannelDuration", var i]: array_set(channel_duration_by_level, i - 1, value)
		["CircleMissileAngularVelocity"]: circle_missile_angular_velocity = float_parse(value)
		["CircleMissileRadialVelocity"]: circle_missile_radial_velocity = float_parse(value)
		["Coefficient"]: array_set(coefficient, 0, value)
		["Coefficient", var i]: array_set(coefficient, i - 1, value)
		["Cooldown"]: cooldown = float_parse(value)
		["Cooldown", var i]: array_set(cooldown_by_level, i - 1, value)
		["DeathRecapPriority"]: death_recap_priority = float_parse(value)
		["DelayCastOffsetPercent"]: delay_cast_offset_percent = float_parse(value)
		["DelayTotalTimePercent"]: delay_total_time_percent = float_parse(value)
		["Description"]: description = string_parse(value)
		["DisplayName"]: display_name = string_parse(value)
		["DynamicExtended"]: dynamic_extended = string_parse(value)
		["DynamicTooltip"]: dynamic_tooltip = string_parse(value)
		["Effect", var i, "Level", var j, "Amount"]: array_set(effect_level_amount, i - 1, array_set(array_get(effect_level_amount, i - 1), j, value))
		["Flags"]: flags = int_parse(value) as Enums.SpellFlags
		["FloatStaticsDecimals", var i]: array_set(float_statics_decimals, i - 1, value)
		["FloatVarsDecimals", var i]: array_set(float_vars_decimals, i - 1, value)
		["HaveAfterEffect"]: have_after_effect = bool_parse(value)
		["HaveHitBone"]: have_hit_bone = bool_parse(value)
		["HaveHitEffect"]: have_hit_effect = bool_parse(value)
		["HavePointEffect"]: have_point_effect = bool_parse(value)
		["HitBoneName"]: hit_bone_name = string_parse(value)
		["HitEffectName"]:
			hit_effect_name = string_parse(value)
			hit_effect = effect_parse(value)
		["InventoryIcon"]: array_set(inventory_icon, 0, value)
		["InventoryIcon", var i]: array_set(inventory_icon, i, value)
		["IsDisabledWhileDead"]: is_disabled_while_dead = bool_parse(value)
		["IsToggleSpell"]: is_toggle_spell = bool_parse(value)
		["Level", var i, "Desc"]: array_set(level_desc, i - 1, value)
		["LineDragLength"]: line_drag_length = float_parse(value)
		["LineMissileBounces"]: line_missile_bounces = bool_parse(value)
		["LineMissileCollisionFromStartPoint"]: line_missile_collision_from_start_point = bool_parse(value)
		["LineMissileDelayDestroyAtEndSeconds"]: line_missile_delay_destroy_at_end_seconds = bool_parse(value)
		["LineMissileEndsAtTargetPoint"]: line_missile_ends_at_target_point = bool_parse(value)
		["LineMissileTargetHeightAugment"]: line_missile_target_height_augment = float_parse(value)
		["LineMissileTimePulseBetweenCollisionSpellHits"]: line_missile_time_pulse_between_collision_spell_hits = bool_parse(value)
		["LineMissileTrackUnits"]: line_missile_track_units = bool_parse(value)
		["LineWidth"]: line_width = float_parse(value)
		["LocationTargettingLength", var i]: array_set(location_targetting_length_by_level, i - 1, value)
		["LocationTargettingWidth", var i]: array_set(location_targetting_width_by_level, i - 1, value)
		["LockConeToPlayer"]: lock_cone_to_player = bool_parse(value)
		["LuaOnMissileUpdateDistanceInterval"]: missile_update_distance_interval = float_parse(value)
		["ManaCost"]: mana_cost = float_parse(value)
		["ManaCost", var i]: array_set(mana_cost_by_level, i - 1, value)
		["MissileAccel"]: missile_accel = float_parse(value)
		["MissileBoneName"]: missile_bone_name = string_parse(value)
		["MissileEffect"]: missile_effect = string_parse(value)
		["MissileFixedTravelTime"]: missile_fixed_travel_time = float_parse(value)
		["MissileGravity"]: missile_gravity = float_parse(value)
		["MissileLifetime"]: missile_lifetime = float_parse(value)
		["MissileMaxSpeed"]: missile_max_speed = float_parse(value)
		["MissileMinSpeed"]: missile_min_speed = float_parse(value)
		["MissilePerceptionBubbleRadius"]: missile_perception_bubble_radius = float_parse(value)
		["MissilePerceptionBubbleRevealsStealth"]: missile_perception_bubble_reveals_stealth = bool_parse(value)
		["MissileSpeed"]: missile_speed = float_parse(value)
		["MissileTargetHeightAugment"]: missile_target_height_augment = float_parse(value)
		["Name"]: spell_name = string_parse(value)
		["OverrideCastTime"]: override_cast_time = float_parse(value)
		["OverrideForceSpellAnimation"]: override_force_spell_animation = bool_parse(value)
		["OverrideForceSpellCancel"]: override_force_spell_cancel = bool_parse(value)
		["ParticleStartOffset"]: particle_start_offset = vec3_parse(value)
		["PlatformEnabled"]: platform_enabled = bool_parse(value)
		["PointEffectName"]:
			point_effect_name = string_parse(value)
			point_effect = effect_parse(value)
		["RangeIndicatorTextureName"]:
			cast_range_indicator_texture_name = string_parse(value)
			cast_range_indicator_texture = tex_parse(value)
		["Ranks"]: ranks = int_parse(value)
		["SelectionPreference"]:
			var options := ["none", "foe", "friend"]
			var res = options.find(string_parse(value).to_lower())
			assert(res != -1, 'Expected one of [' + ','.join(options.map(func(e): return '"' + e + '"')) + '], got "' + value + '"')
			selection_preference = res as Enums.SpellSelectPref
		["Sound_CastName"]: sound_cast_name = string_parse(value)
		["Sound_HitName"]: sound_hit_name = string_parse(value)
		["SpellRevealsChampion"]: spell_reveals_champion = bool_parse(value)
		["StartCooldown"]: cooldown = float_parse(value)
		["SubjectToGlobalCooldown"]: subject_to_global_cooldown = bool_parse(value)
		["TargettingType"]: targetting_type = int_parse(value) as Enums.TargetingType
		#["TextFlags"]: text_flags = string_parse(value)
		["TriggersGlobalCooldown"]: triggers_global_cooldown = bool_parse(value)
		["UseAnimatorFramerate"]: use_animator_framerate = bool_parse(value)
		["UseMinimapTargeting"]: use_minimap_targeting = bool_parse(value)
		["Version"]: version = int_parse(value)
		["x", var i]: array_set(x, i - 1, value)
#endregion
