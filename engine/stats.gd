class_name Stats extends Node

var data: PackedFloat32Array
var data_temp: PackedFloat32Array
var data_temp_a: PackedFloat32Array
var data_temp_b: PackedFloat32Array
func _init() -> void:
	data = PackedFloat32Array(); data.resize(72)
	data_temp_a = PackedFloat32Array(); data_temp_a.resize(46)
	data_temp_b = PackedFloat32Array(); data_temp_b.resize(46)
	data_temp = data_temp_a
func swap_data_temps() -> void:
	var c := data_temp_a
	data_temp_a = data_temp_b
	data_temp_b = c
func reset_data_b() -> void:
	data_temp_b.resize(0)
	data_temp_b.resize(46)

@onready var me: Unit = get_parent()
@onready var root := get_tree().current_scene
@onready var constants: Constants = root.get_node("%Constants")
func _ready() -> void:
	if Engine.is_editor_hint(): return
	health_current = get_health()
	mana_current = get_mana()
	me.stats = self

var time_since_last_regen := 0.0
func _physics_process(delta: float) -> void:
	time_since_last_regen += delta

	if Balancer.should_reset_stats(self):
		reset_data_b()
	
	if Balancer.should_sync_stats(self):
		swap_data_temps()

		health_current = clampf(health_current + get_health_regen() * time_since_last_regen, 0, get_health())
		mana_current = clampf(mana_current + get_mana_regen() * time_since_last_regen, 0, get_mana())
		time_since_last_regen = 0

@export var level: int:
	get: return floori(data[0])
	set(v): data[0] = floori(v)
func growth(stat_per_level: float) -> float:
	return stat_per_level * (level - 1)

#TODO: Group by offense, defense...

@export var crit_damage_bonus: float:
	get: return data[1]
	set(v): data[1] = v

@export_group('Scale', 'scale_')
@export var scale_percent: float:
	get: return data[2]
	set(v): data[2] = v
var scale_percent_temp: float:
	get: return data_temp[0]
	set(v): data_temp[0] = v
@export_group('Acquisition range', 'acquisition_range_')
@export var acquisition_range_flat: float:
	get: return data[3]
	set(v): data[3] = v
var acquisition_range_flat_temp: float:
	get: return data_temp[1]
	set(v): data_temp[1] = v
@export_group('Armor', 'armor_')
@export var armor_base: float:
	get: return data[4]
	set(v): data[4] = v
@export var armor_base_per_level: float:
	get: return data[5]
	set(v): data[5] = v
@export var armor_flat: float:
	get: return data[6]
	set(v): data[6] = v
var armor_flat_temp: float:
	get: return data_temp[2]
	set(v): data_temp[2] = v
@export var armor_percent: float:
	get: return data[7]
	set(v): data[7] = v
var armor_percent_temp: float:
	get: return data_temp[3]
	set(v): data_temp[3] = v
func get_armor() -> float:
	return (armor_base + growth(armor_base_per_level) + armor_flat + armor_flat_temp)\
		 * (1 + armor_percent + armor_percent_temp)
@export_group('Armor penetration', 'armor_penetration_')
@export var armor_penetration_flat: float:
	get: return data[8]
	set(v): data[8] = v
var armor_penetration_flat_temp: float:
	get: return data_temp[4]
	set(v): data_temp[4] = v
@export var armor_penetration_percent: float:
	get: return data[9]
	set(v): data[9] = v
var armor_penetration_percent_temp: float:
	get: return data_temp[5]
	set(v): data_temp[5] = v
func get_armor_penetration() -> float:
	return (armor_penetration_flat + armor_penetration_flat_temp)\
		 * (1 + armor_penetration_percent + armor_penetration_percent_temp)
@export_group('Attack range', 'attack_range_')
@export var attack_range_flat: float:
	get: return data[10]
	set(v): data[10] = v
var attack_range_flat_temp: float:
	get: return data_temp[6]
	set(v): data_temp[6] = v
func get_attack_range() -> float:
	return (attack_range_flat + attack_range_flat_temp)
@export_group('Attack speed', 'attack_speed_')
@export var attack_speed_base: float:
	get: return data[11]
	set(v): data[11] = v
@export var attack_speed_base_per_level: float:
	get: return data[12]
	set(v): data[12] = v
@export var attack_speed_percent: float:
	get: return data[13]
	set(v): data[13] = v
var attack_speed_percent_temp: float:
	get: return data_temp[7]
	set(v): data_temp[7] = v
@export var attack_speed_percent_multiplicative: float:
	get: return data[14]
	set(v): data[14] = v
var attack_speed_percent_multiplicative_temp: float:
	get: return data_temp[8]
	set(v): data_temp[8] = v
func get_attack_speed(delay_offset_percent: float = 0) -> float:
	var base_delay := constants.gcd_attack_delay * (1.0 + delay_offset_percent)
	var base := 1.0 / base_delay
	var base_percent := (attack_speed_base + growth(attack_speed_base_per_level)) * 0.01
	var bonus_percent := attack_speed_percent + attack_speed_percent_temp
	#TODO: var bonus_percent_multiplicative := attack_speed_percent_multiplicative + attack_speed_percent_multiplicative_temp
	return base + base_percent + bonus_percent #TODO: (1 + bonus_percent_multiplicative)
@export_group('Attack damage', 'attack_damage_')
@export var attack_damage_base: float:
	get: return data[15]
	set(v): data[15] = v
@export var attack_damage_base_per_level: float:
	get: return data[16]
	set(v): data[16] = v
@export var attack_damage_flat: float:
	get: return data[17]
	set(v): data[17] = v
var attack_damage_flat_temp: float:
	get: return data_temp[9]
	set(v): data_temp[9] = v
@export var attack_damage_percent: float:
	get: return data[18]
	set(v): data[18] = v
var attack_damage_percent_temp: float:
	get: return data_temp[10]
	set(v): data_temp[10] = v
func get_attack_damage() -> float:
	return (attack_damage_base + growth(attack_damage_base_per_level) + attack_damage_flat + attack_damage_flat_temp)\
		 * (1 + attack_damage_percent + attack_damage_percent_temp)
@export_group('Bubble radius', 'bubble_radius_')
@export var bubble_radius_flat: float:
	get: return data[19]
	set(v): data[19] = v
var bubble_radius_flat_temp: float:
	get: return data_temp[11]
	set(v): data_temp[11] = v
@export var bubble_radius_percent: float:
	get: return data[20]
	set(v): data[20] = v
var bubble_radius_percent_temp: float:
	get: return data_temp[12]
	set(v): data_temp[12] = v
func get_bubble_radius() -> float:
	return (bubble_radius_flat + bubble_radius_flat_temp)\
		 * (1 + bubble_radius_percent + bubble_radius_percent_temp)
@export_group('Cooldown', 'cooldown_')
@export var cooldown_percent: float:
	get: return data[21]
	set(v): data[21] = v
var cooldown_percent_temp: float:
	get: return data_temp[13]
	set(v): data_temp[13] = v
func get_cooldown_percent() -> float:
	return cooldown_percent + cooldown_percent_temp
func get_cooldown() -> float:
	return (1 + cooldown_percent + cooldown_percent_temp)
@export_group('Crit chance', 'crit_chance_')
@export var crit_chance_base: float:
	get: return data[22]
	set(v): data[22] = v
@export var crit_chance_base_per_level: float:
	get: return data[23]
	set(v): data[23] = v
@export var crit_chance_flat: float:
	get: return data[24]
	set(v): data[24] = v
var crit_chance_flat_temp: float:
	get: return data_temp[14]
	set(v): data_temp[14] = v
func get_crit_chance() -> float:
	return (crit_chance_base + growth(crit_chance_base_per_level) + crit_chance_flat + crit_chance_flat_temp)
@export_group('Gold', 'gold_per10_')
@export var gold_per10_flat: float:
	get: return data[25]
	set(v): data[25] = v
var gold_per10_flat_temp: float:
	get: return data_temp[15]
	set(v): data_temp[15] = v
func get_gold_per10() -> float:
	return (gold_per10_flat + gold_per10_flat_temp)
@export_group('Health', 'health_')
@export var health_base: float:
	get: return data[26]
	set(v): data[26] = v
@export var health_base_per_level: float:
	get: return data[27]
	set(v): data[27] = v
@export var health_flat: float:
	get: return data[28]
	set(v): data[28] = v
var health_flat_temp: float:
	get: return data_temp[16]
	set(v): data_temp[16] = v
@export var health_percent: float:
	get: return data[29]
	set(v): data[29] = v
var health_percent_temp: float:
	get: return data_temp[17]
	set(v): data_temp[17] = v
func get_health() -> float:
	return (health_base + growth(health_base_per_level) + health_flat + health_flat_temp)\
		 * (1 + health_percent + health_percent_temp)
var health_current: float:
	get: return data[70]
	set(v): data[70] = v
var health_current_percent: float:
	get: return health_current / get_health()
@export var health_regen_base: float:
	get: return data[30]
	set(v): data[30] = v
@export var health_regen_base_per_level: float:
	get: return data[31]
	set(v): data[31] = v
@export var health_regen_flat: float:
	get: return data[32]
	set(v): data[32] = v
var health_regen_flat_temp: float:
	get: return data_temp[18]
	set(v): data_temp[18] = v
@export var health_regen_percent: float:
	get: return data[33]
	set(v): data[33] = v
var health_regen_percent_temp: float:
	get: return data_temp[19]
	set(v): data_temp[19] = v
func get_health_regen() -> float:
	return (health_regen_base + growth(health_regen_base_per_level) + health_regen_flat + health_regen_flat_temp)\
		 * (1 + health_regen_percent + health_regen_percent_temp)
@export_group('Mana', 'mana_')
@export var mana_base: float:
	get: return data[34]
	set(v): data[34] = v
@export var mana_base_per_level: float:
	get: return data[35]
	set(v): data[35] = v
@export var mana_flat: float:
	get: return data[36]
	set(v): data[36] = v
var mana_flat_temp: float:
	get: return data_temp[20]
	set(v): data_temp[20] = v
@export var mana_percent: float:
	get: return data[37]
	set(v): data[37] = v
var mana_percent_temp: float:
	get: return data_temp[21]
	set(v): data_temp[21] = v
func get_mana() -> float:
	return (mana_base + growth(mana_base_per_level) + mana_flat + mana_flat_temp)\
		 * (1 + mana_percent + mana_percent_temp)
var mana_current: float:
	get: return data[71]
	set(v): data[71] = v
var mana_current_percent: float:
	get: return mana_current / get_mana()
@export var mana_regen_base: float:
	get: return data[38]
	set(v): data[38] = v
@export var mana_regen_base_per_level: float:
	get: return data[39]
	set(v): data[39] = v
@export var mana_regen_flat: float:
	get: return data[40]
	set(v): data[40] = v
var mana_regen_flat_temp: float:
	get: return data_temp[22]
	set(v): data_temp[22] = v
@export var mana_regen_percent: float:
	get: return data[41]
	set(v): data[41] = v
var mana_regen_percent_temp: float:
	get: return data_temp[23]
	set(v): data_temp[23] = v
func get_mana_regen() -> float:
	return (mana_regen_base + growth(mana_regen_base_per_level) + mana_regen_flat + mana_regen_flat_temp)\
		 * (1 + mana_regen_percent + mana_regen_percent_temp)
@export_group('Life steal', 'life_steal_')
@export var life_steal_percent: float:
	get: return data[42]
	set(v): data[42] = v
var life_steal_percent_temp: float:
	get: return data_temp[24]
	set(v): data_temp[24] = v
func get_life_steal() -> float:
	return (1 + life_steal_percent + life_steal_percent_temp)
@export_group('Magic damage', 'magic_damage_')
@export var magic_damage_base: float:
	get: return data[43]
	set(v): data[43] = v
@export var magic_damage_base_per_level: float:
	get: return data[44]
	set(v): data[44] = v
@export var magic_damage_flat: float:
	get: return data[45]
	set(v): data[45] = v
var magic_damage_flat_temp: float:
	get: return data_temp[25]
	set(v): data_temp[25] = v
@export var magic_damage_percent: float:
	get: return data[46]
	set(v): data[46] = v
var magic_damage_percent_temp: float:
	get: return data_temp[26]
	set(v): data_temp[26] = v
func get_magic_damage_flat() -> float:
	return magic_damage_flat + magic_damage_flat_temp
func get_magic_damage() -> float:
	return (magic_damage_base + growth(magic_damage_base_per_level) + magic_damage_flat + magic_damage_flat_temp)\
		 * (1 + magic_damage_percent + magic_damage_percent_temp)
@export_group('Magic penetration', 'magic_penetration_')
@export var magic_penetration_flat: float:
	get: return data[47]
	set(v): data[47] = v
var magic_penetration_flat_temp: float:
	get: return data_temp[27]
	set(v): data_temp[27] = v
@export var magic_penetration_percent: float:
	get: return data[48]
	set(v): data[48] = v
var magic_penetration_percent_temp: float:
	get: return data_temp[28]
	set(v): data_temp[28] = v
func get_magic_penetration() -> float:
	return (magic_penetration_flat + magic_penetration_flat_temp)\
		 * (1 + magic_penetration_percent + magic_penetration_percent_temp)
@export_group('Movement speed', 'movement_speed_')
@export var movement_speed_base: float:
	get: return data[49]
	set(v): data[49] = v
@export var movement_speed_flat: float:
	get: return data[50]
	set(v): data[50] = v
var movement_speed_flat_temp: float:
	get: return data_temp[29]
	set(v): data_temp[29] = v
@export var movement_speed_percent: float:
	get: return data[51]
	set(v): data[51] = v
var movement_speed_percent_temp: float:
	get: return data_temp[30]
	set(v): data_temp[30] = v
@export var movement_speed_percent_multiplicative: float:
	get: return data[52]
	set(v): data[52] = v
var movement_speed_percent_multiplicative_temp: float:
	get: return data_temp[31]
	set(v): data_temp[31] = v
@export var movement_speed_floor: float #TODO: use
func get_movement_speed() -> float:
	return (movement_speed_base + movement_speed_flat + movement_speed_flat_temp)\
		 * (1 + movement_speed_percent + movement_speed_percent_temp)\
		 * (1 + movement_speed_percent_multiplicative + movement_speed_percent_multiplicative_temp)
@export_group('EXP Reward', 'exp_reward_')
@export var exp_reward_flat: float:
	get: return data[53]
	set(v): data[53] = v
var exp_reward_flat_temp: float:
	get: return data_temp[32]
	set(v): data_temp[32] = v
@export var exp_reward_percent: float:
	get: return data[54]
	set(v): data[54] = v
var exp_reward_percent_temp: float:
	get: return data_temp[33]
	set(v): data_temp[33] = v
func get_exp_reward() -> float:
	return (exp_reward_flat + exp_reward_flat_temp)\
		 * (1 + exp_reward_percent + exp_reward_percent_temp)
@export_group('Gold reward', 'gold_reward_')
@export var gold_reward_flat: float:
	get: return data[55]
	set(v): data[55] = v
var gold_reward_flat_temp: float:
	get: return data_temp[34]
	set(v): data_temp[34] = v
func get_gold_reward() -> float:
	return (gold_reward_flat + gold_reward_flat_temp)
@export_group('Spell block', 'spell_block_')
@export var spell_block_base: float:
	get: return data[56]
	set(v): data[56] = v
@export var spell_block_base_per_level: float:
	get: return data[57]
	set(v): data[57] = v
@export var spell_block_flat: float:
	get: return data[58]
	set(v): data[58] = v
var spell_block_flat_temp: float:
	get: return data_temp[35]
	set(v): data_temp[35] = v
@export var spell_block_percent: float:
	get: return data[59]
	set(v): data[59] = v
var spell_block_percent_temp: float:
	get: return data_temp[36]
	set(v): data_temp[36] = v
func get_spell_block() -> float:
	return (spell_block_base + growth(spell_block_base_per_level) + spell_block_flat + spell_block_flat_temp)\
		 * (1 + spell_block_percent + spell_block_percent_temp)
@export_group('Spell vamp', 'spell_vamp_')
@export var spell_vamp_percent: float:
	get: return data[60]
	set(v): data[60] = v
var spell_vamp_percent_temp: float:
	get: return data_temp[37]
	set(v): data_temp[37] = v
func get_spell_vamp() -> float:
	return (1 + spell_vamp_percent + spell_vamp_percent_temp)
var magic_reduction_temp: float:
	get: return data_temp[38]
	set(v): data_temp[38] = v
@export_group('Physical reduction', 'physical_reduction_')
@export var physical_reduction_flat: float:
	get: return data[61]
	set(v): data[61] = v
var physical_reduction_flat_temp: float:
	get: return data_temp[39]
	set(v): data_temp[39] = v
@export var physical_reduction_percent: float:
	get: return data[62]
	set(v): data[62] = v
var physical_reduction_percent_temp: float:
	get: return data_temp[40]
	set(v): data_temp[40] = v
func get_physical_reduction() -> float:
	return (physical_reduction_flat + physical_reduction_flat_temp)\
		 * (1 + physical_reduction_percent + physical_reduction_percent_temp)
@export_group('Crit damage', 'crit_damage_')
@export var crit_damage_flat: float:
	get: return data[63]
	set(v): data[63] = v
var crit_damage_flat_temp: float:
	get: return data_temp[41]
	set(v): data_temp[41] = v
func get_crit_damage() -> float:
	return (crit_damage_flat + crit_damage_flat_temp)
@export_group('Dodge chance', 'dodge_')
@export var dodge_base: float:
	get: return data[64]
	set(v): data[64] = v
@export var dodge_base_per_level: float:
	get: return data[65]
	set(v): data[65] = v
@export var dodge_flat: float:
	get: return data[66]
	set(v): data[66] = v
var dodge_flat_temp: float:
	get: return data_temp[42]
	set(v): data_temp[42] = v
func get_dodge() -> float:
	return (dodge_base + growth(dodge_base_per_level) + dodge_flat + dodge_flat_temp)
@export_group('Respawn time', 'respawn_time_')
@export var respawn_time_percent: float:
	get: return data[67]
	set(v): data[67] = v
var respawn_time_percent_temp: float:
	get: return data_temp[43]
	set(v): data_temp[43] = v
func get_respawn_time() -> float:
	return (1 + respawn_time_percent + respawn_time_percent_temp)
@export_group('Miss chance', 'miss_chance_')
@export var miss_chance_flat: float:
	get: return data[68]
	set(v): data[68] = v
var miss_chance_flat_temp: float:
	get: return data_temp[44]
	set(v): data_temp[44] = v
func get_miss_chance() -> float:
	return (miss_chance_flat + miss_chance_flat_temp)
@export_group('Hardness', 'hardness_')
@export var hardness_percent: float:
	get: return data[69]
	set(v): data[69] = v
var hardness_percent_temp: float:
	get: return data_temp[45]
	set(v): data_temp[45] = v
func get_hardness() -> float:
	return (1 + hardness_percent + hardness_percent_temp)
