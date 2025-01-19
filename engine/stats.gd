class_name Stats extends Node

var temp: PackedFloat32Array
var temp_a: PackedFloat32Array
var temp_b: PackedFloat32Array
func _init() -> void:
	temp_a = PackedFloat32Array(); temp_a.resize(STATS_COUNT)
	temp_b = PackedFloat32Array(); temp_b.resize(STATS_COUNT)
	temp = temp_a
func swap_temps() -> void:
	var c := temp_a
	temp_a = temp_b
	temp_b = c
func reset_data_b() -> void:
	temp_b.resize(0)
	temp_b.resize(STATS_COUNT)

@onready var me: Unit = get_parent()
@onready var root := get_tree().current_scene
@onready var constants: Constants = root.get_node("%Constants")
func _ready() -> void:
	#if Engine.is_editor_hint(): return
	health_current = get_health()
	mana_current = get_mana()
	me.stats = self

var time_since_last_regen := 0.0
func _physics_process(delta: float) -> void:
	time_since_last_regen += delta

	if Balancer.should_reset_stats(self):
		reset_data_b()
	
	if Balancer.should_sync_stats(self):
		swap_temps()

		health_current = clampf(health_current + get_health_regen() * time_since_last_regen, 0, get_health())
		mana_current = clampf(mana_current + get_mana_regen() * time_since_last_regen, 0, get_mana())
		time_since_last_regen = 0

@export var level := 1
func growth(stat_per_level: float) -> float:
	return stat_per_level * (level - 1)

#TODO: Group by offense, defense...

@export var crit_damage_bonus: float

@export_group('Scale', 'scale_')
@export var scale_percent: float
var scale_percent_temp: float:
	get: return temp[SCALE_PERCENT]
	set(v): temp[SCALE_PERCENT] = v
@export_group('Acquisition range', 'acquisition_range_')
@export var acquisition_range_flat: float
var acquisition_range_flat_temp: float:
	get: return temp[ACQUISITION_RANGE_FLAT]
	set(v): temp[ACQUISITION_RANGE_FLAT] = v
@export_group('Armor', 'armor_')
@export var armor_base: float
@export var armor_base_per_level: float
@export var armor_flat: float
var armor_flat_temp: float:
	get: return temp[ARMOR_FLAT]
	set(v): temp[ARMOR_FLAT] = v
@export var armor_percent: float
var armor_percent_temp: float:
	get: return temp[ARMOR_PERCENT]
	set(v): temp[ARMOR_PERCENT] = v
func get_armor() -> float:
	return (armor_base + growth(armor_base_per_level) + armor_flat + temp[ARMOR_FLAT])\
		 * (1 + armor_percent + temp[ARMOR_PERCENT])
@export_group('Armor penetration', 'armor_penetration_')
@export var armor_penetration_flat: float
var armor_penetration_flat_temp: float:
	get: return temp[ARMOR_PENETRATION_FLAT]
	set(v): temp[ARMOR_PENETRATION_FLAT] = v
@export var armor_penetration_percent: float
var armor_penetration_percent_temp: float:
	get: return temp[ARMOR_PENETRATION_PERCENT]
	set(v): temp[ARMOR_PENETRATION_PERCENT] = v
func get_armor_penetration() -> float:
	return (armor_penetration_flat + temp[ARMOR_PENETRATION_FLAT])\
		 * (1 + armor_penetration_percent + temp[ARMOR_PENETRATION_PERCENT])
@export_group('Attack range', 'attack_range_')
@export var attack_range_flat: float
var attack_range_flat_temp: float:
	get: return temp[ATTACK_RANGE_FLAT]
	set(v): temp[ATTACK_RANGE_FLAT] = v
func get_attack_range() -> float:
	return (attack_range_flat + temp[ATTACK_RANGE_FLAT])
@export_group('Attack speed', 'attack_speed_')
@export var attack_speed_base: float
@export var attack_speed_base_per_level: float
@export var attack_speed_percent: float
var attack_speed_percent_temp: float:
	get: return temp[ATTACK_SPEED_PERCENT]
	set(v): temp[ATTACK_SPEED_PERCENT] = v
@export var attack_speed_percent_multiplicative: float
var attack_speed_percent_multiplicative_temp: float:
	get: return temp[ATTACK_SPEED_PERCENT_MULTIPLICATIVE]
	set(v): temp[ATTACK_SPEED_PERCENT_MULTIPLICATIVE] = v
func get_attack_speed(delay_offset_percent: float = 0) -> float:
	var base_delay := constants.gcd_attack_delay * (1.0 + delay_offset_percent)
	var base := 1.0 / base_delay
	var base_percent := (attack_speed_base + growth(attack_speed_base_per_level)) * 0.01
	var bonus_percent := attack_speed_percent + temp[ATTACK_SPEED_PERCENT]
	#TODO: var bonus_percent_multiplicative := attack_speed_percent_multiplicative + temp[ATTACK_SPEED_PERCENT_MULTIPLICATIVE]
	return base + base_percent + bonus_percent #TODO: (1 + bonus_percent_multiplicative)
@export_group('Attack damage', 'attack_damage_')
@export var attack_damage_base: float
@export var attack_damage_base_per_level: float
@export var attack_damage_flat: float
var attack_damage_flat_temp: float:
	get: return temp[ATTACK_DAMAGE_FLAT]
	set(v): temp[ATTACK_DAMAGE_FLAT] = v
@export var attack_damage_percent: float
var attack_damage_percent_temp: float:
	get: return temp[ATTACK_DAMAGE_PERCENT]
	set(v): temp[ATTACK_DAMAGE_PERCENT] = v
func get_attack_damage() -> float:
	return (attack_damage_base + growth(attack_damage_base_per_level) + attack_damage_flat + temp[ATTACK_DAMAGE_FLAT])\
		 * (1 + attack_damage_percent + temp[ATTACK_DAMAGE_PERCENT])
@export_group('Bubble radius', 'bubble_radius_')
@export var bubble_radius_flat: float
var bubble_radius_flat_temp: float:
	get: return temp[BUBBLE_RADIUS_FLAT]
	set(v): temp[BUBBLE_RADIUS_FLAT] = v
@export var bubble_radius_percent: float
var bubble_radius_percent_temp: float:
	get: return temp[BUBBLE_RADIUS_PERCENT]
	set(v): temp[BUBBLE_RADIUS_PERCENT] = v
func get_bubble_radius() -> float:
	return (bubble_radius_flat + temp[BUBBLE_RADIUS_FLAT])\
		 * (1 + bubble_radius_percent + temp[BUBBLE_RADIUS_PERCENT])
@export_group('Cooldown', 'cooldown_')
@export var cooldown_percent: float
var cooldown_percent_temp: float:
	get: return temp[COOLDOWN_PERCENT]
	set(v): temp[COOLDOWN_PERCENT] = v
func get_cooldown_percent() -> float:
	return cooldown_percent + temp[COOLDOWN_PERCENT]
func get_cooldown() -> float:
	return (1 + cooldown_percent + temp[COOLDOWN_PERCENT])
@export_group('Crit chance', 'crit_chance_')
@export var crit_chance_base: float
@export var crit_chance_base_per_level: float
@export var crit_chance_flat: float
var crit_chance_flat_temp: float:
	get: return temp[CRIT_CHANCE_FLAT]
	set(v): temp[CRIT_CHANCE_FLAT] = v
func get_crit_chance() -> float:
	return (crit_chance_base + growth(crit_chance_base_per_level) + crit_chance_flat + temp[CRIT_CHANCE_FLAT])
@export_group('Gold', 'gold_per10_')
@export var gold_per10_flat: float
var gold_per10_flat_temp: float:
	get: return temp[GOLD_PER10_FLAT]
	set(v): temp[GOLD_PER10_FLAT] = v
func get_gold_per10() -> float:
	return (gold_per10_flat + temp[GOLD_PER10_FLAT])
@export_group('Health', 'health_')
@export var health_base: float
@export var health_base_per_level: float
@export var health_flat: float
var health_flat_temp: float:
	get: return temp[HEALTH_FLAT]
	set(v): temp[HEALTH_FLAT] = v
@export var health_percent: float
var health_percent_temp: float:
	get: return temp[HEALTH_PERCENT]
	set(v): temp[HEALTH_PERCENT] = v
func get_health() -> float:
	return (health_base + growth(health_base_per_level) + health_flat + temp[HEALTH_FLAT])\
		 * (1 + health_percent + temp[HEALTH_PERCENT])
var health_current: float
var health_current_percent: float:
	get: return health_current / get_health()
@export var health_regen_base: float
@export var health_regen_base_per_level: float
@export var health_regen_flat: float
var health_regen_flat_temp: float:
	get: return temp[HEALTH_REGEN_FLAT]
	set(v): temp[HEALTH_REGEN_FLAT] = v
@export var health_regen_percent: float
var health_regen_percent_temp: float:
	get: return temp[HEALTH_REGEN_PERCENT]
	set(v): temp[HEALTH_REGEN_PERCENT] = v
func get_health_regen() -> float:
	return (health_regen_base + growth(health_regen_base_per_level) + health_regen_flat + temp[HEALTH_REGEN_FLAT])\
		 * (1 + health_regen_percent + temp[HEALTH_REGEN_PERCENT])
@export_group('Mana', 'mana_')
@export var mana_base: float
@export var mana_base_per_level: float
@export var mana_flat: float
var mana_flat_temp: float:
	get: return temp[MANA_FLAT]
	set(v): temp[MANA_FLAT] = v
@export var mana_percent: float
var mana_percent_temp: float:
	get: return temp[MANA_PERCENT]
	set(v): temp[MANA_PERCENT] = v
func get_mana() -> float:
	return (mana_base + growth(mana_base_per_level) + mana_flat + temp[MANA_FLAT])\
		 * (1 + mana_percent + temp[MANA_PERCENT])
var mana_current: float
var mana_current_percent: float:
	get: return mana_current / get_mana()
@export var mana_regen_base: float
@export var mana_regen_base_per_level: float
@export var mana_regen_flat: float
var mana_regen_flat_temp: float:
	get: return temp[MANA_REGEN_FLAT]
	set(v): temp[MANA_REGEN_FLAT] = v
@export var mana_regen_percent: float
var mana_regen_percent_temp: float:
	get: return temp[MANA_REGEN_PERCENT]
	set(v): temp[MANA_REGEN_PERCENT] = v
func get_mana_regen() -> float:
	return (mana_regen_base + growth(mana_regen_base_per_level) + mana_regen_flat + temp[MANA_REGEN_FLAT])\
		 * (1 + mana_regen_percent + temp[MANA_REGEN_PERCENT])
@export_group('Life steal', 'life_steal_')
@export var life_steal_percent: float
var life_steal_percent_temp: float:
	get: return temp[LIFE_STEAL_PERCENT]
	set(v): temp[LIFE_STEAL_PERCENT] = v
func get_life_steal() -> float:
	return (1 + life_steal_percent + temp[LIFE_STEAL_PERCENT])
@export_group('Magic damage', 'magic_damage_')
@export var magic_damage_base: float
@export var magic_damage_base_per_level: float
@export var magic_damage_flat: float
var magic_damage_flat_temp: float:
	get: return temp[MAGIC_DAMAGE_FLAT]
	set(v): temp[MAGIC_DAMAGE_FLAT] = v
@export var magic_damage_percent: float
var magic_damage_percent_temp: float:
	get: return temp[MAGIC_DAMAGE_PERCENT]
	set(v): temp[MAGIC_DAMAGE_PERCENT] = v
func get_magic_damage_flat() -> float:
	return magic_damage_flat + temp[MAGIC_DAMAGE_FLAT]
func get_magic_damage() -> float:
	return (magic_damage_base + growth(magic_damage_base_per_level) + magic_damage_flat + temp[MAGIC_DAMAGE_FLAT])\
		 * (1 + magic_damage_percent + temp[MAGIC_DAMAGE_PERCENT])
@export_group('Magic penetration', 'magic_penetration_')
@export var magic_penetration_flat: float
var magic_penetration_flat_temp: float:
	get: return temp[MAGIC_PENETRATION_FLAT]
	set(v): temp[MAGIC_PENETRATION_FLAT] = v
@export var magic_penetration_percent: float
var magic_penetration_percent_temp: float:
	get: return temp[MAGIC_PENETRATION_PERCENT]
	set(v): temp[MAGIC_PENETRATION_PERCENT] = v
func get_magic_penetration() -> float:
	return (magic_penetration_flat + temp[MAGIC_PENETRATION_FLAT])\
		 * (1 + magic_penetration_percent + temp[MAGIC_PENETRATION_PERCENT])
@export_group('Movement speed', 'movement_speed_')
@export var movement_speed_base: float
@export var movement_speed_flat: float
var movement_speed_flat_temp: float:
	get: return temp[MOVEMENT_SPEED_FLAT]
	set(v): temp[MOVEMENT_SPEED_FLAT] = v
@export var movement_speed_percent: float
var movement_speed_percent_temp: float:
	get: return temp[MOVEMENT_SPEED_PERCENT]
	set(v): temp[MOVEMENT_SPEED_PERCENT] = v
@export var movement_speed_percent_multiplicative: float
var movement_speed_percent_multiplicative_temp: float:
	get: return temp[MOVEMENT_SPEED_PERCENT_MULTIPLICATIVE]
	set(v): temp[MOVEMENT_SPEED_PERCENT_MULTIPLICATIVE] = v
@export var movement_speed_floor: float #TODO: use
func get_movement_speed() -> float:
	return (movement_speed_base + movement_speed_flat + temp[MOVEMENT_SPEED_FLAT])\
		 * (1 + movement_speed_percent + temp[MOVEMENT_SPEED_PERCENT])\
		 * (1 + movement_speed_percent_multiplicative + temp[MOVEMENT_SPEED_PERCENT_MULTIPLICATIVE])
@export_group('EXP Reward', 'exp_reward_')
@export var exp_reward_flat: float
var exp_reward_flat_temp: float:
	get: return temp[EXP_REWARD_FLAT]
	set(v): temp[EXP_REWARD_FLAT] = v
@export var exp_reward_percent: float
var exp_reward_percent_temp: float:
	get: return temp[EXP_REWARD_PERCENT]
	set(v): temp[EXP_REWARD_PERCENT] = v
func get_exp_reward() -> float:
	return (exp_reward_flat + temp[EXP_REWARD_FLAT])\
		 * (1 + exp_reward_percent + temp[EXP_REWARD_PERCENT])
@export_group('Gold reward', 'gold_reward_')
@export var gold_reward_flat: float
var gold_reward_flat_temp: float:
	get: return temp[GOLD_REWARD_FLAT]
	set(v): temp[GOLD_REWARD_FLAT] = v
func get_gold_reward() -> float:
	return (gold_reward_flat + temp[GOLD_REWARD_FLAT])
@export_group('Spell block', 'spell_block_')
@export var spell_block_base: float
@export var spell_block_base_per_level: float
@export var spell_block_flat: float
var spell_block_flat_temp: float:
	get: return temp[SPELL_BLOCK_FLAT]
	set(v): temp[SPELL_BLOCK_FLAT] = v
@export var spell_block_percent: float
var spell_block_percent_temp: float:
	get: return temp[SPELL_BLOCK_PERCENT]
	set(v): temp[SPELL_BLOCK_PERCENT] = v
func get_spell_block() -> float:
	return (spell_block_base + growth(spell_block_base_per_level) + spell_block_flat + temp[SPELL_BLOCK_FLAT])\
		 * (1 + spell_block_percent + temp[SPELL_BLOCK_PERCENT])
@export_group('Spell vamp', 'spell_vamp_')
@export var spell_vamp_percent: float
var spell_vamp_percent_temp: float:
	get: return temp[SPELL_VAMP_PERCENT]
	set(v): temp[SPELL_VAMP_PERCENT] = v
func get_spell_vamp() -> float:
	return (1 + spell_vamp_percent + temp[SPELL_VAMP_PERCENT])
var magic_reduction_temp: float:
	get: return temp[MAGIC_REDUCTION]
	set(v): temp[MAGIC_REDUCTION] = v
@export_group('Physical reduction', 'physical_reduction_')
@export var physical_reduction_flat: float
var physical_reduction_flat_temp: float:
	get: return temp[PHYSICAL_REDUCTION_FLAT]
	set(v): temp[PHYSICAL_REDUCTION_FLAT] = v
@export var physical_reduction_percent: float
var physical_reduction_percent_temp: float:
	get: return temp[PHYSICAL_REDUCTION_PERCENT]
	set(v): temp[PHYSICAL_REDUCTION_PERCENT] = v
func get_physical_reduction() -> float:
	return (physical_reduction_flat + temp[PHYSICAL_REDUCTION_FLAT])\
		 * (1 + physical_reduction_percent + temp[PHYSICAL_REDUCTION_PERCENT])
@export_group('Crit damage', 'crit_damage_')
@export var crit_damage_flat: float
var crit_damage_flat_temp: float:
	get: return temp[CRIT_DAMAGE_FLAT]
	set(v): temp[CRIT_DAMAGE_FLAT] = v
func get_crit_damage() -> float:
	return (crit_damage_flat + temp[CRIT_DAMAGE_FLAT])
@export_group('Dodge chance', 'dodge_')
@export var dodge_base: float
@export var dodge_base_per_level: float
@export var dodge_flat: float
var dodge_flat_temp: float:
	get: return temp[DODGE_FLAT]
	set(v): temp[DODGE_FLAT] = v
func get_dodge() -> float:
	return (dodge_base + growth(dodge_base_per_level) + dodge_flat + temp[DODGE_FLAT])
@export_group('Respawn time', 'respawn_time_')
@export var respawn_time_percent: float
var respawn_time_percent_temp: float:
	get: return temp[RESPAWN_TIME_PERCENT]
	set(v): temp[RESPAWN_TIME_PERCENT] = v
func get_respawn_time() -> float:
	return (1 + respawn_time_percent + temp[RESPAWN_TIME_PERCENT])
@export_group('Miss chance', 'miss_chance_')
@export var miss_chance_flat: float
var miss_chance_flat_temp: float:
	get: return temp[MISS_CHANCE_FLAT]
	set(v): temp[MISS_CHANCE_FLAT] = v
func get_miss_chance() -> float:
	return (miss_chance_flat + temp[MISS_CHANCE_FLAT])
@export_group('Hardness', 'hardness_')
@export var hardness_percent: float
var hardness_percent_temp: float:
	get: return temp[HARDNESS_PERCENT]
	set(v): temp[HARDNESS_PERCENT] = v
func get_hardness() -> float:
	return (1 + hardness_percent + temp[HARDNESS_PERCENT])

enum {
	SCALE_PERCENT = 0,
	ACQUISITION_RANGE_FLAT = 1,
	ARMOR_FLAT = 2,
	ARMOR_PERCENT = 3,
	ARMOR_PENETRATION_FLAT = 4,
	ARMOR_PENETRATION_PERCENT = 5,
	ATTACK_RANGE_FLAT = 6,
	ATTACK_SPEED_PERCENT = 7,
	ATTACK_SPEED_PERCENT_MULTIPLICATIVE = 8,
	ATTACK_DAMAGE_FLAT = 9,
	ATTACK_DAMAGE_PERCENT = 10,
	BUBBLE_RADIUS_FLAT = 11,
	BUBBLE_RADIUS_PERCENT = 12,
	COOLDOWN_PERCENT = 13,
	CRIT_CHANCE_FLAT = 14,
	GOLD_PER10_FLAT = 15,
	HEALTH_FLAT = 16,
	HEALTH_PERCENT = 17,
	HEALTH_REGEN_FLAT = 18,
	HEALTH_REGEN_PERCENT = 19,
	MANA_FLAT = 20,
	MANA_PERCENT = 21,
	MANA_REGEN_FLAT = 22,
	MANA_REGEN_PERCENT = 23,
	LIFE_STEAL_PERCENT = 24,
	MAGIC_DAMAGE_FLAT = 25,
	MAGIC_DAMAGE_PERCENT = 26,
	MAGIC_PENETRATION_FLAT = 27,
	MAGIC_PENETRATION_PERCENT = 28,
	MOVEMENT_SPEED_FLAT = 29,
	MOVEMENT_SPEED_PERCENT = 30,
	MOVEMENT_SPEED_PERCENT_MULTIPLICATIVE = 31,
	EXP_REWARD_FLAT = 32,
	EXP_REWARD_PERCENT = 33,
	GOLD_REWARD_FLAT = 34,
	SPELL_BLOCK_FLAT = 35,
	SPELL_BLOCK_PERCENT = 36,
	SPELL_VAMP_PERCENT = 37,
	MAGIC_REDUCTION = 38,
	PHYSICAL_REDUCTION_FLAT = 39,
	PHYSICAL_REDUCTION_PERCENT = 40,
	CRIT_DAMAGE_FLAT = 41,
	DODGE_FLAT = 42,
	RESPAWN_TIME_PERCENT = 43,
	MISS_CHANCE_FLAT = 44,
	HARDNESS_PERCENT = 45,
	STATS_COUNT = 46,
}