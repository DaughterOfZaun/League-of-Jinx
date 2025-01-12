class_name Stats extends Node

@export var temp := false

static var temp_property_list: Array[StringName] = []
static var non_temp_property_list: Array[StringName] = []

#static var reflected := false
#func _init() -> void:
#	if !reflected:
#		reflected = true
#		for prop in (get_script() as Script).get_script_property_list():
#			var prop_name: String = prop['name']
#			var prop_type: Variant.Type = prop['type']
#			if prop_name not in [
#				'health_current', '_health_current',
#				'mana_current', '_mana_current',
#				'time_since_last_regen',
#			] && prop_type in [TYPE_FLOAT, TYPE_INT]:
#				if prop_name.ends_with("_temp"):
#					temp_property_list.append(StringName(prop_name))
#				else:
#					non_temp_property_list.append(StringName(prop_name))

@onready var me: Unit = get_parent()
@onready var root := get_tree().current_scene
@onready var constants: Constants = root.get_node("%Constants")
func _ready() -> void:
	if Engine.is_editor_hint(): return
	if temp:
		me.stats_temp = self
	else:
		me.stats = self
		me.stats_perm = self
		set_physics_process(false)
		process_mode = Node.PROCESS_MODE_DISABLED

var time_since_last_regen := 0.0
func _physics_process(delta: float) -> void:
	time_since_last_regen += delta

	if Balancer.should_reset_stats(self):
		me.stats = me.stats_temp

		var stats := me.stats_perm
		#for prop in non_temp_property_list:
		#	self[prop] = me.stats_perm[prop]
		#for prop in temp_property_list:
		#	self[prop] = 0.0

		self.crit_damage_bonus = stats.crit_damage_bonus
		self.scale_percent = stats.scale_percent
		self.scale_percent_temp = 0
		self.acquisition_range_flat = stats.acquisition_range_flat
		self.acquisition_range_flat_temp = 0
		self.armor_base = stats.armor_base
		self.armor_base_per_level = stats.armor_base_per_level
		self.armor_flat = stats.armor_flat
		self.armor_flat_temp = 0
		self.armor_percent = stats.armor_percent
		self.armor_percent_temp = 0
		self.armor_penetration_flat = stats.armor_penetration_flat
		self.armor_penetration_flat_temp = 0
		self.armor_penetration_percent = stats.armor_penetration_percent
		self.armor_penetration_percent_temp = 0
		self.attack_range_flat = stats.attack_range_flat
		self.attack_range_flat_temp = 0
		self.attack_speed_base = stats.attack_speed_base
		self.attack_speed_base_per_level = stats.attack_speed_base_per_level
		self.attack_speed_percent = stats.attack_speed_percent
		self.attack_speed_percent_temp = 0
		self.attack_speed_percent_multiplicative = stats.attack_speed_percent_multiplicative
		self.attack_speed_percent_multiplicative_temp = 0
		self.attack_damage_base = stats.attack_damage_base
		self.attack_damage_base_per_level = stats.attack_damage_base_per_level
		self.attack_damage_flat = stats.attack_damage_flat
		self.attack_damage_flat_temp = 0
		self.attack_damage_percent = stats.attack_damage_percent
		self.attack_damage_percent_temp = 0
		self.bubble_radius_flat = stats.bubble_radius_flat
		self.bubble_radius_flat_temp = 0
		self.bubble_radius_percent = stats.bubble_radius_percent
		self.bubble_radius_percent_temp = 0
		self.cooldown_percent = stats.cooldown_percent
		self.cooldown_percent_temp = 0
		self.crit_chance_base = stats.crit_chance_base
		self.crit_chance_base_per_level = stats.crit_chance_base_per_level
		self.crit_chance_flat = stats.crit_chance_flat
		self.crit_chance_flat_temp = 0
		self.gold_per10_flat = stats.gold_per10_flat
		self.gold_per10_flat_temp = 0
		self.health_base = stats.health_base
		self.health_base_per_level = stats.health_base_per_level
		self.health_flat = stats.health_flat
		self.health_flat_temp = 0
		self.health_percent = stats.health_percent
		self.health_percent_temp = 0
		#self.health_current = stats.health_current
		self.health_current_percent = stats.health_current_percent
		self.health_regen_base = stats.health_regen_base
		self.health_regen_base_per_level = stats.health_regen_base_per_level
		self.health_regen_flat = stats.health_regen_flat
		self.health_regen_flat_temp = 0
		self.health_regen_percent = stats.health_regen_percent
		self.health_regen_percent_temp = 0
		self.mana_base = stats.mana_base
		self.mana_base_per_level = stats.mana_base_per_level
		self.mana_flat = stats.mana_flat
		self.mana_flat_temp = 0
		self.mana_percent = stats.mana_percent
		self.mana_percent_temp = 0
		#self.mana_current = stats.mana_current
		self.mana_current_percent = stats.mana_current_percent
		self.mana_regen_base = stats.mana_regen_base
		self.mana_regen_base_per_level = stats.mana_regen_base_per_level
		self.mana_regen_flat = stats.mana_regen_flat
		self.mana_regen_flat_temp = 0
		self.mana_regen_percent = stats.mana_regen_percent
		self.mana_regen_percent_temp = 0
		self.life_steal_percent = stats.life_steal_percent
		self.life_steal_percent_temp = 0
		self.magic_damage_base = stats.magic_damage_base
		self.magic_damage_base_per_level = stats.magic_damage_base_per_level
		self.magic_damage_flat = stats.magic_damage_flat
		self.magic_damage_flat_temp = 0
		self.magic_damage_percent = stats.magic_damage_percent
		self.magic_damage_percent_temp = 0
		self.magic_penetration_flat = stats.magic_penetration_flat
		self.magic_penetration_flat_temp = 0
		self.magic_penetration_percent = stats.magic_penetration_percent
		self.magic_penetration_percent_temp = 0
		self.movement_speed_base = stats.movement_speed_base
		self.movement_speed_flat = stats.movement_speed_flat
		self.movement_speed_flat_temp = 0
		self.movement_speed_percent = stats.movement_speed_percent
		self.movement_speed_percent_temp = 0
		self.movement_speed_percent_multiplicative = stats.movement_speed_percent_multiplicative
		self.movement_speed_percent_multiplicative_temp = 0
		self.movement_speed_floor = stats.movement_speed_floor
		self.exp_reward_flat = stats.exp_reward_flat
		self.exp_reward_flat_temp = 0
		self.exp_reward_percent = stats.exp_reward_percent
		self.exp_reward_percent_temp = 0
		self.gold_reward_flat = stats.gold_reward_flat
		self.gold_reward_flat_temp = 0
		self.spell_block_base = stats.spell_block_base
		self.spell_block_base_per_level = stats.spell_block_base_per_level
		self.spell_block_flat = stats.spell_block_flat
		self.spell_block_flat_temp = 0
		self.spell_block_percent = stats.spell_block_percent
		self.spell_block_percent_temp = 0
		self.spell_vamp_percent = stats.spell_vamp_percent
		self.spell_vamp_percent_temp = 0
		self.magic_reduction_temp = 0
		self.physical_reduction_flat = stats.physical_reduction_flat
		self.physical_reduction_flat_temp = 0
		self.physical_reduction_percent = stats.physical_reduction_percent
		self.physical_reduction_percent_temp = 0
		self.crit_damage_flat = stats.crit_damage_flat
		self.crit_damage_flat_temp = 0
		self.dodge_base = stats.dodge_base
		self.dodge_base_per_level = stats.dodge_base_per_level
		self.dodge_flat = stats.dodge_flat
		self.dodge_flat_temp = 0
		self.respawn_time_percent = stats.respawn_time_percent
		self.respawn_time_percent_temp = 0
		self.miss_chance_flat = stats.miss_chance_flat
		self.miss_chance_flat_temp = 0
		self.hardness_percent = stats.hardness_percent
		self.hardness_percent_temp = 0

	if Balancer.should_sync_stats(self):
		me.stats = me.stats_perm

		health_current = clampf(health_current + get_health_regen() * time_since_last_regen, 0, get_health())
		mana_current = clampf(mana_current + get_mana_regen() * time_since_last_regen, 0, get_mana())
		time_since_last_regen = 0

		var stats := me.stats_perm
		#for prop in non_temp_property_list:
		#	me.stats_perm[prop] = self[prop]
		#for prop in temp_property_list:
		#	me.stats_perm[prop] = self[prop]

		stats.crit_damage_bonus = self.crit_damage_bonus
		stats.scale_percent = self.scale_percent
		stats.scale_percent_temp = self.scale_percent_temp
		stats.acquisition_range_flat = self.acquisition_range_flat
		stats.acquisition_range_flat_temp = self.acquisition_range_flat_temp
		stats.armor_base = self.armor_base
		stats.armor_base_per_level = self.armor_base_per_level
		stats.armor_flat = self.armor_flat
		stats.armor_flat_temp = self.armor_flat_temp
		stats.armor_percent = self.armor_percent
		stats.armor_percent_temp = self.armor_percent_temp
		stats.armor_penetration_flat = self.armor_penetration_flat
		stats.armor_penetration_flat_temp = self.armor_penetration_flat_temp
		stats.armor_penetration_percent = self.armor_penetration_percent
		stats.armor_penetration_percent_temp = self.armor_penetration_percent_temp
		stats.attack_range_flat = self.attack_range_flat
		stats.attack_range_flat_temp = self.attack_range_flat_temp
		stats.attack_speed_base = self.attack_speed_base
		stats.attack_speed_base_per_level = self.attack_speed_base_per_level
		stats.attack_speed_percent = self.attack_speed_percent
		stats.attack_speed_percent_temp = self.attack_speed_percent_temp
		stats.attack_speed_percent_multiplicative = self.attack_speed_percent_multiplicative
		stats.attack_speed_percent_multiplicative_temp = self.attack_speed_percent_multiplicative_temp
		stats.attack_damage_base = self.attack_damage_base
		stats.attack_damage_base_per_level = self.attack_damage_base_per_level
		stats.attack_damage_flat = self.attack_damage_flat
		stats.attack_damage_flat_temp = self.attack_damage_flat_temp
		stats.attack_damage_percent = self.attack_damage_percent
		stats.attack_damage_percent_temp = self.attack_damage_percent_temp
		stats.bubble_radius_flat = self.bubble_radius_flat
		stats.bubble_radius_flat_temp = self.bubble_radius_flat_temp
		stats.bubble_radius_percent = self.bubble_radius_percent
		stats.bubble_radius_percent_temp = self.bubble_radius_percent_temp
		stats.cooldown_percent = self.cooldown_percent
		stats.cooldown_percent_temp = self.cooldown_percent_temp
		stats.crit_chance_base = self.crit_chance_base
		stats.crit_chance_base_per_level = self.crit_chance_base_per_level
		stats.crit_chance_flat = self.crit_chance_flat
		stats.crit_chance_flat_temp = self.crit_chance_flat_temp
		stats.gold_per10_flat = self.gold_per10_flat
		stats.gold_per10_flat_temp = self.gold_per10_flat_temp
		stats.health_base = self.health_base
		stats.health_base_per_level = self.health_base_per_level
		stats.health_flat = self.health_flat
		stats.health_flat_temp = self.health_flat_temp
		stats.health_percent = self.health_percent
		stats.health_percent_temp = self.health_percent_temp
		#self.health_current = self.health_current
		stats.health_current_percent = self.health_current_percent
		stats.health_regen_base = self.health_regen_base
		stats.health_regen_base_per_level = self.health_regen_base_per_level
		stats.health_regen_flat = self.health_regen_flat
		stats.health_regen_flat_temp = self.health_regen_flat_temp
		stats.health_regen_percent = self.health_regen_percent
		stats.health_regen_percent_temp = self.health_regen_percent_temp
		stats.mana_base = self.mana_base
		stats.mana_base_per_level = self.mana_base_per_level
		stats.mana_flat = self.mana_flat
		stats.mana_flat_temp = self.mana_flat_temp
		stats.mana_percent = self.mana_percent
		stats.mana_percent_temp = self.mana_percent_temp
		#self.mana_current = self.mana_current
		stats.mana_current_percent = self.mana_current_percent
		stats.mana_regen_base = self.mana_regen_base
		stats.mana_regen_base_per_level = self.mana_regen_base_per_level
		stats.mana_regen_flat = self.mana_regen_flat
		stats.mana_regen_flat_temp = self.mana_regen_flat_temp
		stats.mana_regen_percent = self.mana_regen_percent
		stats.mana_regen_percent_temp = self.mana_regen_percent_temp
		stats.life_steal_percent = self.life_steal_percent
		stats.life_steal_percent_temp = self.life_steal_percent_temp
		stats.magic_damage_base = self.magic_damage_base
		stats.magic_damage_base_per_level = self.magic_damage_base_per_level
		stats.magic_damage_flat = self.magic_damage_flat
		stats.magic_damage_flat_temp = self.magic_damage_flat_temp
		stats.magic_damage_percent = self.magic_damage_percent
		stats.magic_damage_percent_temp = self.magic_damage_percent_temp
		stats.magic_penetration_flat = self.magic_penetration_flat
		stats.magic_penetration_flat_temp = self.magic_penetration_flat_temp
		stats.magic_penetration_percent = self.magic_penetration_percent
		stats.magic_penetration_percent_temp = self.magic_penetration_percent_temp
		stats.movement_speed_base = self.movement_speed_base
		stats.movement_speed_flat = self.movement_speed_flat
		stats.movement_speed_flat_temp = self.movement_speed_flat_temp
		stats.movement_speed_percent = self.movement_speed_percent
		stats.movement_speed_percent_temp = self.movement_speed_percent_temp
		stats.movement_speed_percent_multiplicative = self.movement_speed_percent_multiplicative
		stats.movement_speed_percent_multiplicative_temp = self.movement_speed_percent_multiplicative_temp
		stats.movement_speed_floor = self.movement_speed_floor
		stats.exp_reward_flat = self.exp_reward_flat
		stats.exp_reward_flat_temp = self.exp_reward_flat_temp
		stats.exp_reward_percent = self.exp_reward_percent
		stats.exp_reward_percent_temp = self.exp_reward_percent_temp
		stats.gold_reward_flat = self.gold_reward_flat
		stats.gold_reward_flat_temp = self.gold_reward_flat_temp
		stats.spell_block_base = self.spell_block_base
		stats.spell_block_base_per_level = self.spell_block_base_per_level
		stats.spell_block_flat = self.spell_block_flat
		stats.spell_block_flat_temp = self.spell_block_flat_temp
		stats.spell_block_percent = self.spell_block_percent
		stats.spell_block_percent_temp = self.spell_block_percent_temp
		stats.spell_vamp_percent = self.spell_vamp_percent
		stats.spell_vamp_percent_temp = self.spell_vamp_percent_temp
		stats.magic_reduction_temp = self.magic_reduction_temp
		stats.physical_reduction_flat = self.physical_reduction_flat
		stats.physical_reduction_flat_temp = self.physical_reduction_flat_temp
		stats.physical_reduction_percent = self.physical_reduction_percent
		stats.physical_reduction_percent_temp = self.physical_reduction_percent_temp
		stats.crit_damage_flat = self.crit_damage_flat
		stats.crit_damage_flat_temp = self.crit_damage_flat_temp
		stats.dodge_base = self.dodge_base
		stats.dodge_base_per_level = self.dodge_base_per_level
		stats.dodge_flat = self.dodge_flat
		stats.dodge_flat_temp = self.dodge_flat_temp
		stats.respawn_time_percent = self.respawn_time_percent
		stats.respawn_time_percent_temp = self.respawn_time_percent_temp
		stats.miss_chance_flat = self.miss_chance_flat
		stats.miss_chance_flat_temp = self.miss_chance_flat_temp
		stats.hardness_percent = self.hardness_percent
		stats.hardness_percent_temp = self.hardness_percent_temp

@export var level := 1
func growth(stat_per_level: float) -> float:
	return stat_per_level * (level - 1)

#TODO: Group by offense, defense...

@export var crit_damage_bonus: float

@export_group('Scale', 'scale_')
@export var scale_percent: float
var scale_percent_temp: float
@export_group('Acquisition range', 'acquisition_range_')
@export var acquisition_range_flat: float
var acquisition_range_flat_temp: float
@export_group('Armor', 'armor_')
@export var armor_base: float
@export var armor_base_per_level: float
@export var armor_flat: float
var armor_flat_temp: float
@export var armor_percent: float
var armor_percent_temp: float
func get_armor() -> float:
	return (armor_base + growth(armor_base_per_level) + armor_flat + armor_flat_temp)\
		 * (1 + armor_percent + armor_percent_temp)
@export_group('Armor penetration', 'armor_penetration_')
@export var armor_penetration_flat: float
var armor_penetration_flat_temp: float
@export var armor_penetration_percent: float
var armor_penetration_percent_temp: float
func get_armor_penetration() -> float:
	return (armor_penetration_flat + armor_penetration_flat_temp)\
		 * (1 + armor_penetration_percent + armor_penetration_percent_temp)
@export_group('Attack range', 'attack_range_')
@export var attack_range_flat: float
var attack_range_flat_temp: float
func get_attack_range() -> float:
	return (attack_range_flat + attack_range_flat_temp)
@export_group('Attack speed', 'attack_speed_')
@export var attack_speed_base: float
@export var attack_speed_base_per_level: float
@export var attack_speed_percent: float
var attack_speed_percent_temp: float
@export var attack_speed_percent_multiplicative: float
var attack_speed_percent_multiplicative_temp: float
func get_attack_speed(delay_offset_percent: float = 0) -> float:
	var base_delay := constants.gcd_attack_delay * (1.0 + delay_offset_percent)
	var base := 1.0 / base_delay
	var base_percent := (attack_speed_base + growth(attack_speed_base_per_level)) * 0.01
	var bonus_percent := attack_speed_percent + attack_speed_percent_temp
	#TODO: var bonus_percent_multiplicative := attack_speed_percent_multiplicative + attack_speed_percent_multiplicative_temp
	return base + base_percent + bonus_percent #TODO: (1 + bonus_percent_multiplicative)
@export_group('Attack damage', 'attack_damage_')
@export var attack_damage_base: float
@export var attack_damage_base_per_level: float
@export var attack_damage_flat: float
var attack_damage_flat_temp: float
@export var attack_damage_percent: float
var attack_damage_percent_temp: float
func get_attack_damage() -> float:
	return (attack_damage_base + growth(attack_damage_base_per_level) + attack_damage_flat + attack_damage_flat_temp)\
		 * (1 + attack_damage_percent + attack_damage_percent_temp)
@export_group('Bubble radius', 'bubble_radius_')
@export var bubble_radius_flat: float
var bubble_radius_flat_temp: float
@export var bubble_radius_percent: float
var bubble_radius_percent_temp: float
func get_bubble_radius() -> float:
	return (bubble_radius_flat + bubble_radius_flat_temp)\
		 * (1 + bubble_radius_percent + bubble_radius_percent_temp)
@export_group('Cooldown', 'cooldown_')
@export var cooldown_percent: float
var cooldown_percent_temp: float
func get_cooldown_percent() -> float:
	return cooldown_percent + cooldown_percent_temp
func get_cooldown() -> float:
	return (1 + cooldown_percent + cooldown_percent_temp)
@export_group('Crit chance', 'crit_chance_')
@export var crit_chance_base: float
@export var crit_chance_base_per_level: float
@export var crit_chance_flat: float
var crit_chance_flat_temp: float
func get_crit_chance() -> float:
	return (crit_chance_base + growth(crit_chance_base_per_level) + crit_chance_flat + crit_chance_flat_temp)
@export_group('Gold', 'gold_per10_')
@export var gold_per10_flat: float
var gold_per10_flat_temp: float
func get_gold_per10() -> float:
	return (gold_per10_flat + gold_per10_flat_temp)
@export_group('Health', 'health_')
@export var health_base: float
@export var health_base_per_level: float
@export var health_flat: float
var health_flat_temp: float
@export var health_percent: float
var health_percent_temp: float
func get_health() -> float:
	return (health_base + growth(health_base_per_level) + health_flat + health_flat_temp)\
		 * (1 + health_percent + health_percent_temp)
@onready var _health_current := get_health()
var health_current: float:
	get: return me.stats_perm._health_current
	set(value): me.stats_perm._health_current = value
var health_current_percent: float:
	get: return health_current / get_health()
@export var health_regen_base: float
@export var health_regen_base_per_level: float
@export var health_regen_flat: float
var health_regen_flat_temp: float
@export var health_regen_percent: float
var health_regen_percent_temp: float
func get_health_regen() -> float:
	return (health_regen_base + growth(health_regen_base_per_level) + health_regen_flat + health_regen_flat_temp)\
		 * (1 + health_regen_percent + health_regen_percent_temp)
@export_group('Mana', 'mana_')
@export var mana_base: float
@export var mana_base_per_level: float
@export var mana_flat: float
var mana_flat_temp: float
@export var mana_percent: float
var mana_percent_temp: float
func get_mana() -> float:
	return (mana_base + growth(mana_base_per_level) + mana_flat + mana_flat_temp)\
		 * (1 + mana_percent + mana_percent_temp)
@onready var _mana_current := get_mana()
var mana_current: float:
	get: return me.stats_perm._mana_current
	set(value): me.stats_perm._mana_current = value
var mana_current_percent: float:
	get: return mana_current / get_mana()
@export var mana_regen_base: float
@export var mana_regen_base_per_level: float
@export var mana_regen_flat: float
var mana_regen_flat_temp: float
@export var mana_regen_percent: float
var mana_regen_percent_temp: float
func get_mana_regen() -> float:
	return (mana_regen_base + growth(mana_regen_base_per_level) + mana_regen_flat + mana_regen_flat_temp)\
		 * (1 + mana_regen_percent + mana_regen_percent_temp)
@export_group('Life steal', 'life_steal_')
@export var life_steal_percent: float
var life_steal_percent_temp: float
func get_life_steal() -> float:
	return (1 + life_steal_percent + life_steal_percent_temp)
@export_group('Magic damage', 'magic_damage_')
@export var magic_damage_base: float
@export var magic_damage_base_per_level: float
@export var magic_damage_flat: float
var magic_damage_flat_temp: float
@export var magic_damage_percent: float
var magic_damage_percent_temp: float
func get_magic_damage_flat() -> float:
	return magic_damage_flat + magic_damage_flat_temp
func get_magic_damage() -> float:
	return (magic_damage_base + growth(magic_damage_base_per_level) + magic_damage_flat + magic_damage_flat_temp)\
		 * (1 + magic_damage_percent + magic_damage_percent_temp)
@export_group('Magic penetration', 'magic_penetration_')
@export var magic_penetration_flat: float
var magic_penetration_flat_temp: float
@export var magic_penetration_percent: float
var magic_penetration_percent_temp: float
func get_magic_penetration() -> float:
	return (magic_penetration_flat + magic_penetration_flat_temp)\
		 * (1 + magic_penetration_percent + magic_penetration_percent_temp)
@export_group('Movement speed', 'movement_speed_')
@export var movement_speed_base: float
@export var movement_speed_flat: float
var movement_speed_flat_temp: float
@export var movement_speed_percent: float
var movement_speed_percent_temp: float
@export var movement_speed_percent_multiplicative: float
var movement_speed_percent_multiplicative_temp: float
@export var movement_speed_floor: float #TODO: use
func get_movement_speed() -> float:
	return (movement_speed_base + movement_speed_flat + movement_speed_flat_temp)\
		 * (1 + movement_speed_percent + movement_speed_percent_temp)\
		 * (1 + movement_speed_percent_multiplicative + movement_speed_percent_multiplicative_temp)
@export_group('EXP Reward', 'exp_reward_')
@export var exp_reward_flat: float
var exp_reward_flat_temp: float
@export var exp_reward_percent: float
var exp_reward_percent_temp: float
func get_exp_reward() -> float:
	return (exp_reward_flat + exp_reward_flat_temp)\
		 * (1 + exp_reward_percent + exp_reward_percent_temp)
@export_group('Gold reward', 'gold_reward_')
@export var gold_reward_flat: float
var gold_reward_flat_temp: float
func get_gold_reward() -> float:
	return (gold_reward_flat + gold_reward_flat_temp)
@export_group('Spell block', 'spell_block_')
@export var spell_block_base: float
@export var spell_block_base_per_level: float
@export var spell_block_flat: float
var spell_block_flat_temp: float
@export var spell_block_percent: float
var spell_block_percent_temp: float
func get_spell_block() -> float:
	return (spell_block_base + growth(spell_block_base_per_level) + spell_block_flat + spell_block_flat_temp)\
		 * (1 + spell_block_percent + spell_block_percent_temp)
@export_group('Spell vamp', 'spell_vamp_')
@export var spell_vamp_percent: float
var spell_vamp_percent_temp: float
func get_spell_vamp() -> float:
	return (1 + spell_vamp_percent + spell_vamp_percent_temp)
var magic_reduction_temp: float
@export_group('Physical reduction', 'physical_reduction_')
@export var physical_reduction_flat: float
var physical_reduction_flat_temp: float
@export var physical_reduction_percent: float
var physical_reduction_percent_temp: float
func get_physical_reduction() -> float:
	return (physical_reduction_flat + physical_reduction_flat_temp)\
		 * (1 + physical_reduction_percent + physical_reduction_percent_temp)
@export_group('Crit damage', 'crit_damage_')
@export var crit_damage_flat: float
var crit_damage_flat_temp: float
func get_crit_damage() -> float:
	return (crit_damage_flat + crit_damage_flat_temp)
@export_group('Dodge chance', 'dodge_')
@export var dodge_base: float
@export var dodge_base_per_level: float
@export var dodge_flat: float
var dodge_flat_temp: float
func get_dodge() -> float:
	return (dodge_base + growth(dodge_base_per_level) + dodge_flat + dodge_flat_temp)
@export_group('Respawn time', 'respawn_time_')
@export var respawn_time_percent: float
var respawn_time_percent_temp: float
func get_respawn_time() -> float:
	return (1 + respawn_time_percent + respawn_time_percent_temp)
@export_group('Miss chance', 'miss_chance_')
@export var miss_chance_flat: float
var miss_chance_flat_temp: float
func get_miss_chance() -> float:
	return (miss_chance_flat + miss_chance_flat_temp)
@export_group('Hardness', 'hardness_')
@export var hardness_percent: float
var hardness_percent_temp: float
func get_hardness() -> float:
	return (1 + hardness_percent + hardness_percent_temp)
