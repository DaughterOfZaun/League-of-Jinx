@tool
class_name UnitData
extends Data

#@export var asset_category := "obj"

@export_group("Info")
@export var champion_id: int
@export var champion_name: String
@export_multiline var description: String
@export var friendly_tooltip: String
@export var enemy_tooltip: String
@export_multiline var lore: String
@export_multiline var tips: String
@export_multiline var opposing_tips: String
@export var classification: Classification
enum Classification {
	Arcane, Deadly, Strong, Hunter
}
@export var roles: Roles
enum Roles {
	ATTACKER, BRAWLER, MAGE, TANK, SUPPORT
}
@export var search_tags: SearchTags #TODO: flags? string?
enum SearchTags {
	support,
	ranged,
	assassin,
	stealth,
	melee,
	carry,
	fighter,
	jungler,
	recommended,
	heal,
	pusher,
	farmer,
	tough,
	stun,
	haste,
	mage,
	root,
	nuke,
	tank,
	snare,
	disabler,
	slow,
	teleport,
	flee,
}
@export_subgroup("Ranks")
@export var magic_rank: int
@export var attack_rank: int
@export var defense_rank: int
@export var difficulty_rank: int
@export_subgroup("")
@export_subgroup("Flags")
@export var bot_enabled: bool
@export var bot_enabled_mm: bool
@export var cs_easy: bool
@export var cs_hard: bool
@export var cs_medium: bool
@export var sr_easy: bool
@export var sr_medium: bool
@export_subgroup("")
@export_group("")

@export_group("Ranges")
@export var attack_range: float
@export var chasing_attack_range_percent: float
@export var acquisition_range: float
@export var experience_radius: float
@export var gameplay_collision_radius: float
@export var pathfinding_collision_radius: float
@export var perception_bubble_radius: float
@export var selection_radius: float
@export var selection_height: float
@export_group("")

@export_group("Stats")
@export_subgroup("Defense")
#@export var armor: float
#@export var armor_per_level: float
@export var armor_material: ArmorMaterial
enum ArmorMaterial {
	Flesh, Stone, Metal, Wood
}
#@export var hit_fx_scale: float

#@export var spell_block: float
#@export var spell_block_per_level: float

#@export var base_dodge: float
#@export var level_dodge: float

@export_subgroup("Offense")
#@export var attack_speed: float
#@export var attack_speed_per_level: float

#@export var base_damage: float
#@export var damage_per_level: float

#@export var base_crit_chance: float
#@export var crit_damage_bonus: float
#@export var crit_per_level: float

#@export var base_ability_power: float
#@export var ability_power_inc_per_level: float #:= 0
@export var base_spell_effectiveness: float # 0 or 1.0
@export var level_spell_effectiveness: float
@export_subgroup("")

@export_subgroup("Health")
#@export var base_hp: float
#@export var hp_per_level: float
#@export var hp_regen_per_level: float
@export var base_factor_hp_regen: float
#@export var base_static_hp_regen: float
@export_subgroup("")

@export_subgroup("Mana")
#@export var base_mp: float
#@export var mp_per_level: float
#@export var mp_regen_per_level: float
@export var base_factor_mp_regen: float
#@export var base_static_mp_regen: float
@export_subgroup("")

@export_subgroup("PAR")
@export var par_type: PARType
enum PARType {
		Shield, Energy, Other
}
@export var par_name_string: String

@export var par_color: Color
@export var par_fade_color: Color

@export var par_increments: float
@export var par_max_segments: int

@export var par_display_through_death: bool
@export var par_has_regen_text: bool
@export_subgroup("")

#@export var move_speed: float

@export_group("")

@export_group("Attacks")
#@export_subgroup("Base")
#@export var weapon_material: String
#@export var base_attack_probability: float
#@export var attack_delay_cast_offset_percent: float
#@export var attack_delay_offset_percent: float
#@export_subgroup("")
#@export_subgroup("Extra")
#@export var extra_attack: Array[String]
#@export var extra_attack_probability: Array[float]
#@export_subgroup("")
#@export_subgroup("Crit")
#@export var crit_attack: String
#@export var critical_attack: String
#@export var crit_attack_attack_cast_delay_offset_percent: float
#@export var crit_attack_attack_delay_offset_percent: float
#@export_subgroup("")
@export var post_attack_move_delay: float
@export_group("")

#@export_group("Passive", "passive_")
##@export var passive: int #?
#@export var passive_icon: String
#@export var passive_name: String
#@export var passive_lua_name: String
#@export_multiline var passive_desc: String
#@export var passive_level: Array[int]
##@export var passive_num_effects: int
##@export var passive_effect: Array[float]
##@export_multiline var pass_lev_desc: Array[String]
#@export_group("")

#@export_group("Spells")
#@export var spell: Array[String]
#@export var spell_desc: Array[String]
#@export var spell_display_name: Array[String]
#@export var spells_up_levels: Array[Array] #[int] #:= [[1, 3, 5, 7, 9, 11]]
#@export var max_levels: Vector4i #:= [5, 5, 5, 5] or [6, 6, 6, 1]
#@export var extra_spell: Array[String]
#@export var delay_cast_offset_percent: float
#@export var delay_total_time_percent: float
#@export_group("")

@export_group("Death")
@export var global_exp_given_on_death: float
@export var global_gold_given_on_death: float
@export var gold_given_on_death: float
@export var soul_given_on_death: float
@export var exp_given_on_death: float
@export_group("")

@export_group("Flags")
@export var is_melee: bool
@export var never_render: bool
@export var no_auto_attack: bool
@export var no_health_bar: bool
@export var platform_enabled: bool
@export var server_only: bool
@export var should_face_target: bool
@export_group("")

@export_group("Import", "import_")
var target: Unit
@export_file("*.ini") var import_path: String
@export_tool_button("Import") var import := func() -> void:
	print("importing...")
	target = get_parent()
	target.data = self
	var ini := ini_load(import_path)
	set_from_ini_section(ini["Data"])
	print("imported")
#@export_tool_button("Export to Stats") var import_to_stats := func() -> void:
#	target = get_parent()

	#stats.armor_base = armor
	#stats.armor_base_per_level = armor_per_level
	#stats.spell_block_base = spell_block
	#stats.spell_block_base_per_level = spell_block_per_level
	#stats.dodge_base = base_dodge
	#stats.dodge_base_per_level = level_dodge
	#stats.attack_speed_base = attack_speed
	#stats.attack_speed_base_per_level = attack_speed_per_level
	#stats.attack_damage_base = base_damage
	#stats.attack_damage_base_per_level = damage_per_level
	#stats.crit_chance_base = base_crit_chance
	#stats.crit_chance_base_per_level = crit_per_level
	#stats.crit_damage_bonus = crit_damage_bonus
	#stats.magic_damage_base = base_ability_power
	#stats.magic_damage_base_per_level = ability_power_inc_per_level
	#stats.health_base = base_hp
	#stats.health_base_per_level = hp_per_level
	#stats.health_regen_base = base_static_hp_regen
	#stats.health_regen_base_per_level = hp_regen_per_level
	#stats.mana_base = base_mp
	#stats.mana_base_per_level = mp_per_level
	#stats.mana_regen_base = base_static_mp_regen
	#stats.mana_regen_base_per_level = mp_regen_per_level
	#stats.movement_speed_base = move_speed

	#TODO: WTF is that?
	#stats.base_spell_effectiveness = base_spell_effectiveness
	#stats.level_spell_effectiveness = level_spell_effectiveness
	#stats.base_factor_hp_regen = base_factor_hp_regen
	#stats.base_factor_mp_regen = base_factor_mp_regen
@export_group("")

func get_target_child(type: GDScript, name: String) -> Variant:
	var child := target.find_child(name)
	if !child:
		child = type.new()
		target.add_child(child)
		child.name = name
		if Engine.is_editor_hint():
			child.owner = EditorInterface.get_edited_scene_root()
	return child

func get_target_spells() -> Spells:
	return get_target_child(Spells, "Spells")

func get_target_passive() -> Passive:
	return get_target_child(Passive, "Passive")

var stats: Stats:
	get: return get_target_child(Stats, "Stats")

func set_from_ini_entry(key_array: Array, value: String) -> void:
	var ignored := false
	match key_array:
		["AbilityPowerIncPerLevel"]:
			#ability_power_inc_per_level = int_parse(value)
			stats.magic_damage_base_per_level = int_parse(value)
		["AcquisitionRange"]: acquisition_range = float_parse(value)
		["Armor"]:
			#armor = float_parse(value)
			stats.armor_base = float_parse(value)
		["ArmorMaterial"]: armor_material = enum_parse(UnitData.ArmorMaterial, value) as UnitData.ArmorMaterial
		["ArmorPerLevel"]:
			#armor_per_level = float_parse(value)
			stats.armor_base_per_level = float_parse(value)
		["AssetCategory"]: ignored = true #asset_category = string_parse(value)
		["AttackDelayCastOffsetPercent"]:
			#attack_delay_cast_offset_percent = float_parse(value)
			get_target_spells().get_basic(0).data.delay_cast_offset_percent = float_parse(value)
		["AttackDelayOffsetPercent"]:
			#attack_delay_offset_percent = float_parse(value)
			get_target_spells().get_basic(0).data.delay_total_time_percent = float_parse(value)
		["AttackRange"]: attack_range = float_parse(value)
		["AttackRank"]: attack_rank = int_parse(value)
		["AttackSpeed"]:
			#attack_speed = float_parse(value)
			stats.attack_speed_base = float_parse(value)
		["AttackSpeedPerLevel"]:
			#attack_speed_per_level = float_parse(value)
			stats.attack_speed_base_per_level = float_parse(value)
		["BaseAbilityPower"]:
			#base_ability_power = float_parse(value)
			stats.magic_damage_base = float_parse(value)
		["BaseAttack_Probability"]:
			#base_attack_probability = float_parse(value)
			(get_target_spells().get_basic(0).data as BasicAttackData).probability = float_parse(value)
		["BaseCritChance"]:
			#base_crit_chance = float_parse(value)
			stats.crit_chance_base = float_parse(value)
		["BaseDamage"]:
			#base_damage = float_parse(value)
			stats.attack_damage_base = float_parse(value)
		["BaseDodge"]:
			#base_dodge = float_parse(value)
			stats.dodge_base = float_parse(value)
		["BaseFactorHPRegen"]: base_factor_hp_regen = float_parse(value)
		["BaseFactorMPRegen"]: base_factor_mp_regen = float_parse(value)
		["BaseHP"]:
			#base_hp = float_parse(value)
			stats.health_base = float_parse(value)
		["BaseMP"]:
			#base_mp = float_parse(value)
			stats.mana_base = float_parse(value)
		["BaseSpellEffectiveness"]: base_spell_effectiveness = float_parse(value)
		["BaseStaticHPRegen"]:
			#base_static_hp_regen = float_parse(value)
			stats.health_regen_base = float_parse(value)
		["BaseStaticMPRegen"]:
			#base_static_mp_regen = float_parse(value)
			stats.mana_regen_base = float_parse(value)
		["BotEnabled"]: bot_enabled = bool_parse(value)
		["BotEnabledMM"]: bot_enabled_mm = bool_parse(value)
		["ChampionId"]: champion_id = int_parse(value)
		["ChasingAttackRangePercent"]: chasing_attack_range_percent = float_parse(value)
		["Classification"]: classification = enum_parse(UnitData.Classification, value) as UnitData.Classification
		["CritAttack_AttackCastDelayOffsetPercent"]:
			#crit_attack_attack_cast_delay_offset_percent = float_parse(value)
			get_target_spells().get_crit().data.delay_cast_offset_percent = float_parse(value)
		["CritAttack_AttackDelayOffsetPercent"]:
			#crit_attack_attack_delay_offset_percent = float_parse(value)
			get_target_spells().get_crit().data.delay_total_time_percent = float_parse(value)
		["CritAttack"]:
			#crit_attack = string_parse(value)
			get_target_spells().get_crit(string_parse(value))
		["CritDamageBonus"]:
			#crit_damage_bonus = float_parse(value)
			stats.crit_damage_bonus = float_parse(value)
		["CriticalAttack"]: ignored = true #critical_attack = string_parse(value)
		["CritPerLevel"]:
			#crit_per_level = float_parse(value)
			stats.crit_chance_base_per_level = float_parse(value)
		["CS_easy"]: cs_easy = bool_parse(value)
		["CS_hard"]: cs_hard = bool_parse(value)
		["CS_medium"]: cs_medium = bool_parse(value)
		["DamagePerLevel"]:
			#damage_per_level = float_parse(value)
			stats.attack_damage_base_per_level = float_parse(value)
		["DefenseRank"]: defense_rank = int_parse(value)
		["DelayCastOffsetPercent"]: ignored = true #delay_cast_offset_percent = float_parse(value)
		["DelayTotalTimePercent"]: ignored = true #delay_total_time_percent = float_parse(value)
		["Description"]: description = string_parse(value)
		["DifficultyRank"]: difficulty_rank = int_parse(value)
		["EnemyTooltip"]: enemy_tooltip = string_parse(value)
		["ExperienceRadius"]: experience_radius = float_parse(value)
		["ExpGivenOnDeath"]: exp_given_on_death = float_parse(value)
		["ExtraAttack", var i, "_Probability"] when i > 0:
			#extra_attack_probability = array_set(extra_attack_probability, i - 1, float_parse(value))
			(get_target_spells().get_basic(i).data as BasicAttackData).probability = float_parse(value)
		["ExtraAttack", var i] when i > 0:
			#extra_attack = array_set(extra_attack, i - 1, string_parse(value))
			get_target_spells().get_basic(i, string_parse(value))
		["ExtraSpell", var i]:
			#extra_spell = array_set(extra_spell, i - 1, string_parse(value))
			get_target_spells().get_extra(i - 1, string_parse(value))
		["FriendlyTooltip"]: friendly_tooltip = string_parse(value)
		["GameplayCollisionRadius"]: gameplay_collision_radius = float_parse(value)
		["GlobalExpGivenOnDeath"]: global_exp_given_on_death = float_parse(value)
		["GlobalGoldGivenOnDeath"]: global_gold_given_on_death = float_parse(value)
		["GoldGivenOnDeath"]: gold_given_on_death = float_parse(value)
		["HitFxScale"]: ignored = true #hit_fx_scale = float_parse(value)
		["HPPerLevel"]:
			#hp_per_level = float_parse(value)
			stats.health_base_per_level = float_parse(value)
		["HPRegenPerLevel"]:
			#hp_regen_per_level = float_parse(value)
			stats.health_regen_base_per_level = float_parse(value)
		["IsMelee"]: is_melee = bool_parse(value)
		["LevelDodge"]:
			#level_dodge = float_parse(value)
			stats.dodge_base_per_level = float_parse(value)
		["LevelSpellEffectiveness"]: level_spell_effectiveness = float_parse(value)
		["Lore", 1]: lore = string_parse(value)
		["MagicRank"]: magic_rank = int_parse(value)
		["MaxLevels"]:
			var max_levels := Array(string_parse(value).split(' ', false)).map(int_parse)
			for i in len(max_levels):
				get_target_spells().get_spell(i).data.max_level = max_levels[i]
		["MoveSpeed"]:
			#move_speed = float_parse(value)
			stats.movement_speed_base = float_parse(value)
		["MPPerLevel"]:
			#mp_per_level = float_parse(value)
			stats.mana_base_per_level = float_parse(value)
		["MPRegenPerLevel"]:
			#mp_regen_per_level = float_parse(value)
			stats.mana_regen_base_per_level = float_parse(value)
		["Name"]: champion_name = string_parse(value)
		["NeverRender"]: never_render = bool_parse(value)
		["NoAutoAttack"]: no_auto_attack = bool_parse(value)
		["NoHealthBar"]: no_health_bar = bool_parse(value)
		["PARColor"]: par_color = string_parse(value)
		["PARDisplayThroughDeath"]: par_display_through_death = bool_parse(value)
		["PARFadeColor"]: par_fade_color = string_parse(value)
		["PARHasRegenText"]: par_has_regen_text = bool_parse(value)
		["PARIncrements"]: par_increments = float_parse(value)
		["PARMaxSegments"]: par_max_segments = int_parse(value)
		["PARNameString"]: par_name_string = string_parse(value)
		["PARType"]: par_type = enum_parse(UnitData.PARType, value) as UnitData.PARType
		#["Passive", 1, "Desc"]: passive_desc = string_parse(value) # PassLev1Desc1 is used instead
		["Passive", var i, "Desc"]: ignored = true
		#["Passive", 1, "Effect", var j]: passive_effect = array_set(passive_effect, j - 1, float_parse(value))
		["Passive", var i, "Effect", var j]: ignored = true
		["Passive", 1, "Icon"]:
			#passive_icon = string_parse(value)
			get_target_passive().icon = string_parse(value)
		["Passive", var i, "Icon"]: ignored = true
		["Passive", 1, "Level", var j]:
			#passive_level = array_set(passive_level, j - 1, int_parse(value))
			get_target_passive().level = array_set(get_target_passive().level, j - 1, int_parse(value))
		["Passive", var i, "Level", var j]: ignored = true
		["Passive", 1, "LuaName"]:
			#passive_lua_name = string_parse(value)
			get_target_passive().lua_name = string_parse(value)
		["Passive", var i, "LuaName"]: ignored = true
		["Passive", 1, "Name"]:
			#passive_name = string_parse(value)
			get_target_passive()._name = string_parse(value)
		["Passive", var i, "Name"]: ignored = true
		#["Passive", 1, "NumEffects"]: passive_num_effects = int_parse(value)
		["Passive", var i, "NumEffects"]: ignored = true
		#["Passive", 1]: passive = int_parse(value)
		["Passive", var i]: ignored = true
		["PassLev", 1, "Desc", 1]:
			#passive_desc = string_parse(value)
			get_target_passive().desc = string_parse(value)
		["PassLev", var i, "Desc", var j]: ignored = true #pass_lev_desc = array_set(pass_lev_desc, j - 1, string_parse(value))
		["PathfindingCollisionRadius"]: pathfinding_collision_radius = float_parse(value)
		["PerceptionBubbleRadius"]: perception_bubble_radius = float_parse(value)
		["PlatformEnabled"]: platform_enabled = bool_parse(value)
		["PostAttackMoveDelay"]: post_attack_move_delay = float_parse(value)
		["Roles"]: roles = enum_parse(UnitData.Roles, value) as UnitData.Roles
		["SearchTags"]: search_tags = enum_parse(UnitData.SearchTags, value) as UnitData.SearchTags
		["SelectionHeight"]: selection_height = float_parse(value)
		["SelectionRadius"]: selection_radius = float_parse(value)
		["ServerOnly"]: server_only = bool_parse(value)
		["ShouldFaceTarget"]: should_face_target = bool_parse(value)
		["SoulGivenOnDeath"]: soul_given_on_death = float_parse(value)
		["Spell", var i, "Desc"]: ignored = true #spell_desc = string_parse(value)
		["Spell", var i, "DisplayName"]: ignored = true #spell_display_name = string_parse(value)
		["Spell", var i]:
			#spell = array_set(spell, i - 1, string_parse(value))
			get_target_spells().get_spell(i - 1, string_parse(value))
		["SpellBlock"]:
			#spell_block = float_parse(value)
			stats.spell_block_base = float_parse(value)
		["SpellBlockPerLevel"]:
			#spell_block_per_level = float_parse(value)
			stats.spell_block_base_per_level = float_parse(value)
		["SpellsUpLevels", var i]:
			get_target_spells().get_spell(i - 1).data.up_levels = Array(string_parse(value).split(' ', false)).map(int_parse)
		["SR_easy"]: sr_easy = bool_parse(value)
		["SR_medium"]: sr_medium = bool_parse(value)
		["Tips", 1]: tips = string_parse(value)
		["Tips", 2]: tips = string_parse(value)
		["WeaponMaterial", var i] when i >= 2:
			#extra_attack = array_set(extra_attack, i - 2, string_parse(value))
			get_target_spells().get_basic(i - 1, string_parse(value))
		["WeaponMaterial", var i]: ignored = true
		["WeaponMaterial"]:
			#weapon_material = string_parse(value)
			get_target_spells().get_basic(0, string_parse(value))

		var key: print("ignored" if ignored else "unmatched", " ", key, " : ", value)
