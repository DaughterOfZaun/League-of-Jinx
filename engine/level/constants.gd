@tool
class_name Constants
extends Data

@export_group("Attack Range variables", "ar_")
@export var ar_stop_attack_range_modifier: float
@export var ar_ai_charmed_acquisition_range: float # The acquisition range for charmed units.

@export_group("AI Attack target selection variables", "ai_")
@export var ai_target_distance_factor_per_neightbor: float # Impact of each neighbor on the cost to selecting this target 
@export var ai_target_distance_factor_per_attacker: float # Impact of each attacker on the cost to selecting this target 
@export var ai_target_range_factor: float # Impact o target strait line distance from source on cost estimate 
@export var ai_target_path_factor: float # Impact of actual path distance from source to target on final cost 
@export var ai_minion_targeting_hero_boost: float # Additional distance added to distance between to discourage minons attacking heroes
@export var ai_target_max_num_attackers: int # Maximun number of attackers already attacking target

@export_group("Spell Vamp variables", "sv_")
@export var sv_spell_ratio: float # Spell Vamp ratio for DAMAGESOURCE_SPELL
@export var sv_spell_aoe_ratio: float # Spell Vamp ratio for DAMAGESOURCE_SPELLAOE
@export var sv_spell_persist_ratio: float # Spell Vamp ratio for DAMAGESOURCE_SPELLPERSIST
@export var sv_periodic_ratio: float # Spell Vamp ratio for DAMAGESOURCE_PERIODIC
@export var sv_proc_ratio: float # Spell Vamp ratio for DAMAGESOURCE_PROC
@export var sv_reactive_ratio: float # Spell Vamp ratio for DAMAGESOURCE_REACTIVE
@export var sv_on_death_ratio: float # Spell Vamp ratio for DAMAGESOURCE_ONDEATH
@export var sv_pet_ratio: float # Spell Vamp ratio for DAMAGESOURCE_PET

@export_group("obj_AI_Hero variables", "ai_")
@export var ai_ambient_gold_delay: float # Delay before first ambient gold tick
@export var ai_ambient_gold_interval: float # Interval between ambient gold ticks
@export var ai_ambient_gold_amount: float # Gold granted on ambient gold tick
@export var ai_disable_ambient_gold_while_dead: bool # Disable ambient gold while dead
@export var ai_ambient_xp_delay: float # Delay before first ambient XP tick
@export var ai_ambient_xp_interval: float # Interval between ambient XP ticks
@export var ai_ambient_xp_amount: float # XP granted on ambient XP tick
@export var ai_disable_ambient_xp_while_dead: bool # Disable ambient XP while dead
@export var ai_gold_lost_per_level: float # Gold lost per level when you die
@export var ai_time_dead_per_level: float # Time in seconds spent dead per level
@export var ai_gold_handicap_coefficient: float # Coefficient for gold handicapping
@export var ai_minion_denial_percentage: float # Minion denial percentage

@export_group("Server Culling", "ser_")
@export var ser_closeness_line_of_sight_threshold_turret: float # Distances greater then this for turrets perform the LOS check, otherwise they don't.  This was put in because of all the collision around Turrets. 

@export_group("Spell global variables", "sg_")
@export var sg_spell_global_cooldown: float # Global Cooldown for spells in seconds
@export var sg_spell_global_cooldown_avatar: float # Global Cooldown for avatar spells in seconds

@export_group("Barracks Variables", "bar_")
@export var bar_spawn_enabled: bool # Enable/disable spawn from barracks
@export var bar_armor: int # armor
@export var bar_max_hp: int # max hp

@export_group("Spawn Point variables", "sp_")
@export var sp_regen_radius: float # The spawn point will heal units in this radius.
@export var sp_health_regen_percent: float # The percentage of max HP a unit will regenerate per tick.  A float value between 0.0 and 1.0.
@export var sp_mana_regen_percent: float # The percentage of max Mana a unit will regenerate per tick.  A float value between 0.0 and 1.0.
@export var sp_regen_tick_interval: float # Interval between spawn point regen ticks.

@export_group("Attack Flags", "ca_")
@export var ca_reveal_attacker_range: float # The range of reveal for attackers
@export var ca_reveal_attacker_time_out: float # The timeout for the reveal for attackers
@export var ca_min_cast_rotation_speed: float # Whats the minimum speed we will rotate to face a target during a spell cast?

@export_group("obj_BarracksDampener variables", "events_")
@export var events_time_for_multi_kill: float # Amount of time for something to be considered a multikill (double kill etc...)
@export var events_timer_for_assist: float # Amount of time for something to be considered a multikill (double kill etc...)

# obj_HQ variables
# obj_AI_Minion variables
# obj_AI_Turret variables

@export_group("Tutorial variables", "tut_")
@export var tut_tutorial_mode_on: bool # Flag to turn TutorialMode On/Off

@export_group("Audio variables", "aud_")
@export var aud_fmod_music_cue_id: int # FMOD ID for a music cue for the map's music.
@export var aud_fmod_ambient_event: String # FMOD event name for the map's ambient track.
@export var aud_fmod_victory_music_cue_id: int # FMOD ID for a Victory music cue for the map's music.
@export var aud_fmod_defeat_music_cue_id: int # FMOD ID for a Defeat music cue for the map's music.

@export_group("HUD variables", "hud_")
@export var hud_blink_frequency: int # Sets the 'peak to peak' duration (in ms) of one pulse of the HUD highlight glow.
@export var hud_default_blink_count: int # Sets the default number of pulses a HUD element will blink when highlighted.
@export var hud_targeting_reticle_height: float # Height of the location circular location casting reticle

@export_group("Camera Variables", "cam_")
@export var cam_keyboard_orbit_speed_x: float # Keyboard Orbit Speed x axis
@export var cam_keyboard_orbit_speed_y: float # Keyboard Orbit Speed y axis
@export var cam_min_x: float # Minimum X position of camera
@export var cam_min_y: float # Minimum Y position of camera
@export var cam_max_x: float # Maximum X position of camera
@export var cam_max_y: float # Maximum Y position of camera

@export_group("Cursor variables", "cr_")
@export var cr_spell_cast_flash_time: float # How long the cursor flashes when you cast a targeted spell
@export var cr_mouse_scroll_speed: float # Mouse Scroll Speed

# obj_AI_Base variables

@export_group("Item and Inventory variables", "it_")
@export var it_use_explicit_item_inclusion: bool # Only the items explicitly listed in LEVELS\[MapName]\Items.ini will be in the store.

@export_group("FOW", "ar_")
@export var ar_closing_attack_range_modifier: float

@export_group("Global Character Data constants", "gcd_")
@export var gcd_attack_delay: float # Attack delay coefficient
@export var gcd_attack_delay_cast_percent: float # Attack delay cast percent 0-1
@export var gcd_attack_min_delay: float # Attack min delay
@export var gcd_percent_attack_speed_mod_minimum: float # The lowest Attack Speed Percent Mod penalty can go
@export var gcd_attack_max_delay: float # Attack max delay
@export var gcd_cooldown_minimum: float # Minimum cooldown time for a spell.
@export var gcd_percent_cooldown_mod_minimum: float # The lowest Cooldown Percent Mod bonus can go.
@export var gcd_percent_respawn_time_mod_minimum: float # The lowest RespawnTime Percent Mod bonus can go.
@export var gcd_percent_gold_lost_on_death_mod_minimum: float # The lowest GoldLostOnDeath Percent Mod bonus can go.
@export var gcd_percent_exp_bonus_minimum: float # The lowest EXPBonus Percent Mod penalty can go.
@export var gcd_percent_exp_bonus_maximum: float # The highest EXPBonus Percent Mod bonus can go.

@export_group("Damage Ratios", "dr_")
@export var dr_hero_to_hero: float
@export var dr_building_to_hero: float
@export var dr_unit_to_hero: float
@export var dr_hero_to_unit: float
@export var dr_building_to_unit: float
@export var dr_unit_to_unit: float
@export var dr_hero_to_building: float
@export var dr_building_to_building: float
@export var dr_unit_to_building: float

@export_group("Call For Help variables", "cfh_")
@export var cfh_delay: float # How often a unit will issue a Call For Help
@export var cfh_stick: float # How long a unit should ignore lower prioty calls while the curent target is not activly attacking
@export var cfh_radius: float # Units within this radius will hear your Call For Help
@export var cfh_duration: float # How long a unit will consider a Call For Help.  Mainly used to track whether a unit has already responded.
@export var cfh_melee_radius: float # Attack range buffer distance for melee responders to a Call For Help
@export var cfh_ranged_radius: float # Attack range buffer distance for ranged responders to a Call For Help
@export var cfh_turret_radius: float # Attack range buffer distance for turret responders to a Call For Help

@export_group("AI variables", "ai_")
@export var ai_draw_target_lines: bool # Render AI Helper lines to targets
@export var ai_draw_path_lines: bool # Render Current Path
@export var ai_draw_bound_cylinder: bool # Render Bounding Cylinder
@export var ai_draw_acquisition_range: bool # Render acquisition range
@export var ai_draw_attack_radius: bool # Render Attack Radius
@export var ai_draw_bound_box: bool # Render Bounding Box
@export var ai_ai_toggle: bool # Enable/disable AI
@export var ai_draw_actual_position: bool # Draws the actual position a unit is at based on its pathfinding position.
@export var ai_path_ignores_buildings: bool # Should AI pathing ignore buildings and not take them into account in their lane positioning?
@export var ai_exp_radius2: float # Radius for Experience sharing 
@export var ai_starting_gold: float # Gold granted on startup
@export var ai_default_pet_return_radius: float # Default pet return radius

@export_group("Import", "import_")
@export_file("*.var") var import_path: String
@export_tool_button("Import") var import := func() -> void:
	var ini := ini_load(import_path, true)
	set_from_ini_section(ini["Default"])

func set_from_ini_entry(key_array: Array, value: String) -> void:
	match key_array:
		["ar_StopAttackRangeModifier"]: ar_stop_attack_range_modifier = float_parse(value)
		["ar_AICharmedAcquisitionRange"]: ar_ai_charmed_acquisition_range = float_parse(value)
		["ai_TargetDistanceFactorPerNeightbor"]: ai_target_distance_factor_per_neightbor = float_parse(value)
		["ai_TargetDistanceFactorPerAttacker"]: ai_target_distance_factor_per_attacker = float_parse(value)
		["ai_TargetRangeFactor"]: ai_target_range_factor = float_parse(value)
		["ai_TargetPathFactor"]: ai_target_path_factor = float_parse(value)
		["ai_MinionTargetingHeroBoost"]: ai_minion_targeting_hero_boost = float_parse(value)
		["ai_TargetMaxNumAttackers"]: ai_target_max_num_attackers = int_parse(value)
		["sv_SpellRatio"]: sv_spell_ratio = float_parse(value)
		["sv_SpellAoERatio"]: sv_spell_aoe_ratio = float_parse(value)
		["sv_SpellPersistRatio"]: sv_spell_persist_ratio = float_parse(value)
		["sv_PeriodicRatio"]: sv_periodic_ratio = float_parse(value)
		["sv_ProcRatio"]: sv_proc_ratio = float_parse(value)
		["sv_ReactiveRatio"]: sv_reactive_ratio = float_parse(value)
		["sv_OnDeathRatio"]: sv_on_death_ratio = float_parse(value)
		["sv_PetRatio"]: sv_pet_ratio = float_parse(value)
		["ai_AmbientGoldDelay"]: ai_ambient_gold_delay = float_parse(value)
		["ai_AmbientGoldInterval"]: ai_ambient_gold_interval = float_parse(value)
		["ai_AmbientGoldAmount"]: ai_ambient_gold_amount = float_parse(value)
		["ai_DisableAmbientGoldWhileDead"]: ai_disable_ambient_gold_while_dead = bool_parse(value)
		["ai_AmbientXPDelay"]: ai_ambient_xp_delay = float_parse(value)
		["ai_AmbientXPInterval"]: ai_ambient_xp_interval = float_parse(value)
		["ai_AmbientXPAmount"]: ai_ambient_xp_amount = float_parse(value)
		["ai_DisableAmbientXPWhileDead"]: ai_disable_ambient_xp_while_dead = bool_parse(value)
		["ai_GoldLostPerLevel"]: ai_gold_lost_per_level = float_parse(value)
		["ai_TimeDeadPerLevel"]: ai_time_dead_per_level = float_parse(value)
		["ai_GoldHandicapCoefficient"]: ai_gold_handicap_coefficient = float_parse(value)
		["ai_MinionDenialPercentage"]: ai_minion_denial_percentage = float_parse(value)
		["ser_ClosenessLineOfSightThresholdTurret"]: ser_closeness_line_of_sight_threshold_turret = float_parse(value)
		["sg_SpellGlobalCooldown"]: sg_spell_global_cooldown = float_parse(value)
		["sg_SpellGlobalCooldown_Avatar"]: sg_spell_global_cooldown_avatar = float_parse(value)
		["bar_bSpawnEnabled"]: bar_spawn_enabled = bool_parse(value)
		["bar_Armor"]: bar_armor = int_parse(value)
		["bar_MaxHP"]: bar_max_hp = int_parse(value)
		["sp_RegenRadius"]: sp_regen_radius = float_parse(value)
		["sp_HealthRegenPercent"]: sp_health_regen_percent = float_parse(value)
		["sp_ManaRegenPercent"]: sp_mana_regen_percent = float_parse(value)
		["sp_RegenTickInterval"]: sp_regen_tick_interval = float_parse(value)
		["ca_RevealAttackerRange"]: ca_reveal_attacker_range = float_parse(value)
		["ca_RevealAttackerTimeOut"]: ca_reveal_attacker_time_out = float_parse(value)
		["hud_targeting_reticle_height"]: hud_targeting_reticle_height = float_parse(value)
		["events_TimeForMultiKill"]: events_time_for_multi_kill = float_parse(value)
		["events_TimerForAssist"]: events_timer_for_assist = float_parse(value)
		["tut_TutorialModeOn"]: tut_tutorial_mode_on = bool_parse(value)
		["aud_FMODMusicCueID"]: aud_fmod_music_cue_id = int_parse(value)
		["aud_FMODAmbientEvent"]: aud_fmod_ambient_event = string_parse(value)
		["aud_FMODVictoryMusicCueID"]: aud_fmod_victory_music_cue_id = int_parse(value)
		["aud_FMODDefeatMusicCueID"]: aud_fmod_defeat_music_cue_id = int_parse(value)
		["hud_BlinkFrequency"]: hud_blink_frequency = int_parse(value)
		["hud_DefaultBlinkCount"]: hud_default_blink_count = int_parse(value)
		["cam_KeyboardOrbitSpeedX"]: cam_keyboard_orbit_speed_x = float_parse(value)
		["cam_KeyboardOrbitSpeedY"]: cam_keyboard_orbit_speed_y = float_parse(value)
		["cam_MinX"]: cam_min_x = float_parse(value)
		["cam_MinY"]: cam_min_y = float_parse(value)
		["cam_MaxX"]: cam_max_x = float_parse(value)
		["cam_MaxY"]: cam_max_y = float_parse(value)
		["cr_SpellCastFlashTime"]: cr_spell_cast_flash_time = float_parse(value)
		["cr_MouseScrollSpeed"]: cr_mouse_scroll_speed = float_parse(value)
		["ca_MinCastRotationSpeed"]: ca_min_cast_rotation_speed = float_parse(value)
		["it_UseExplicitItemInclusion"]: it_use_explicit_item_inclusion = bool_parse(value)
		["ar_ClosingAttackRangeModifier"]: ar_closing_attack_range_modifier = float_parse(value)
		["gcd_AttackDelay"]: gcd_attack_delay = float_parse(value)
		["gcd_AttackDelayCastPercent"]: gcd_attack_delay_cast_percent = float_parse(value)
		["gcd_AttackMinDelay"]: gcd_attack_min_delay = float_parse(value)
		["gcd_PercentAttackSpeedModMinimum"]: gcd_percent_attack_speed_mod_minimum = float_parse(value)
		["gcd_AttackMaxDelay"]: gcd_attack_max_delay = float_parse(value)
		["gcd_CooldownMinimum"]: gcd_cooldown_minimum = float_parse(value)
		["gcd_PercentCooldownModMinimum"]: gcd_percent_cooldown_mod_minimum = float_parse(value)
		["gcd_PercentRespawnTimeModMinimum"]: gcd_percent_respawn_time_mod_minimum = float_parse(value)
		["gcd_PercentGoldLostOnDeathModMinimum"]: gcd_percent_gold_lost_on_death_mod_minimum = float_parse(value)
		["gcd_PercentEXPBonusMinimum"]: gcd_percent_exp_bonus_minimum = float_parse(value)
		["gcd_PercentEXPBonusMaximum"]: gcd_percent_exp_bonus_maximum = float_parse(value)
		["dr_HeroToHero"]: dr_hero_to_hero = float_parse(value)
		["dr_BuildingToHero"]: dr_building_to_hero = float_parse(value)
		["dr_UnitToHero"]: dr_unit_to_hero = float_parse(value)
		["dr_HeroToUnit"]: dr_hero_to_unit = float_parse(value)
		["dr_BuildingToUnit"]: dr_building_to_unit = float_parse(value)
		["dr_UnitToUnit"]: dr_unit_to_unit = float_parse(value)
		["dr_HeroToBuilding"]: dr_hero_to_building = float_parse(value)
		["dr_BuildingToBuilding"]: dr_building_to_building = float_parse(value)
		["dr_UnitToBuilding"]: dr_unit_to_building = float_parse(value)
		["cfh_Delay"]: cfh_delay = float_parse(value)
		["cfh_Stick"]: cfh_stick = float_parse(value)
		["cfh_Radius"]: cfh_radius = float_parse(value)
		["cfh_Duration"]: cfh_duration = float_parse(value)
		["cfh_MeleeRadius"]: cfh_melee_radius = float_parse(value)
		["cfh_RangedRadius"]: cfh_ranged_radius = float_parse(value)
		["cfh_TurretRadius"]: cfh_turret_radius = float_parse(value)
		["ai_DrawTargetLines"]: ai_draw_target_lines = bool_parse(value)
		["ai_DrawPathLines"]: ai_draw_path_lines = bool_parse(value)
		["ai_DrawBoundCylinder"]: ai_draw_bound_cylinder = bool_parse(value)
		["ai_DrawAcquisitionRange"]: ai_draw_acquisition_range = bool_parse(value)
		["ai_DrawAttackRadius"]: ai_draw_attack_radius = bool_parse(value)
		["ai_DrawBoundBox"]: ai_draw_bound_box = bool_parse(value)
		["ai_AIToggle"]: ai_ai_toggle = bool_parse(value)
		["ai_DrawActualPosition"]: ai_draw_actual_position = bool_parse(value)
		["ai_PathIgnoresBuildings"]: ai_path_ignores_buildings = bool_parse(value)
		["ai_ExpRadius2"]: ai_exp_radius2 = float_parse(value)
		["ai_StartingGold"]: ai_starting_gold = float_parse(value)
		["ai_DefaultPetReturnRadius"]: ai_default_pet_return_radius = float_parse(value)
