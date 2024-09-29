class_name Stats
extends Node

#TODO: Group by offense, defense...

@onready var me := get_parent() as Unit
func _ready() -> void:
	if Engine.is_editor_hint(): return
	me.stats = self

@export_group('Scale', 'scale_')
@export var scale_percent: float
var scale_percent_temp: float
@export_group('Acquisition range', 'acquisition_range_')
@export var acquisition_range_flat: float
var acquisition_range_flat_temp: float
@export_group('Armor', 'armor_')
@export var armor_flat: float
var armor_flat_temp: float
@export var armor_percent: float
var armor_percent_temp: float
func get_armor() -> float:
	return (armor_flat + armor_flat_temp)\
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
@export var attack_speed_percent: float
var attack_speed_percent_temp: float
@export var attack_speed_percent_multiplicative: float
var attack_speed_percent_multiplicative_temp: float
func get_attack_speed() -> float:
	return (1 + attack_speed_percent + attack_speed_percent_temp)\
		 * (1 + attack_speed_percent_multiplicative + attack_speed_percent_multiplicative_temp)
@export_group('Attack damage', 'attack_damage_')
var attack_damage_base: float
@export var attack_damage_flat: float
var attack_damage_flat_temp: float
@export var attack_damage_percent: float
var attack_damage_percent_temp: float
func get_attack_damage() -> float:
	return (attack_damage_flat + attack_damage_flat_temp)\
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
func get_cooldown() -> float:
	return (1 + cooldown_percent + cooldown_percent_temp)
@export_group('Crit chance', 'crit_chance_')
@export var crit_chance_flat: float
var crit_chance_flat_temp: float
func get_crit_chance() -> float:
	return (crit_chance_flat + crit_chance_flat_temp)
@export_group('Gold', 'gold_per10_')
@export var gold_per10_flat: float
var gold_per10_flat_temp: float
func get_gold_per10() -> float:
	return (gold_per10_flat + gold_per10_flat_temp)
@export_group('Health', 'health_')
@export var health_flat: float
var health_flat_temp: float
@export var health_percent: float
var health_percent_temp: float
func get_health() -> float:
	return (health_flat + health_flat_temp)\
		 * (1 + health_percent + health_percent_temp)
var health_current_temp: float
var health_current_percent_temp: float
@export var health_regen_flat: float
var health_regen_flat_temp: float
@export var health_regen_percent: float
var health_regen_percent_temp: float
func get_health_regen() -> float:
	return (health_regen_flat + health_regen_flat_temp)\
		 * (1 + health_regen_percent + health_regen_percent_temp)
@export_group('Life steal', 'life_steal_')
@export var life_steal_percent: float
var life_steal_percent_temp: float
func get_life_steal() -> float:
	return (1 + life_steal_percent + life_steal_percent_temp)
@export_group('Magic damage', 'magic_damage_')
@export var magic_damage_flat: float
var magic_damage_flat_temp: float
@export var magic_damage_percent: float
var magic_damage_percent_temp: float
func get_magic_damage() -> float:
	return (magic_damage_flat + magic_damage_flat_temp)\
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
@export var movement_speed_flat: float
var movement_speed_flat_temp: float
@export var movement_speed_percent: float
var movement_speed_percent_temp: float
@export var movement_speed_percent_multiplicative: float
var movement_speed_percent_multiplicative_temp: float
@export var movement_speed_floor: float
func get_movement_speed() -> float:
	return (movement_speed_flat + movement_speed_flat_temp)\
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
@export var spell_block_flat: float
var spell_block_flat_temp: float
@export var spell_block_percent: float
var spell_block_percent_temp: float
func get_spell_block() -> float:
	return (spell_block_flat + spell_block_flat_temp)\
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
@export var dodge_flat: float
var dodge_flat_temp: float
func get_dodge() -> float:
	return (dodge_flat + dodge_flat_temp)
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
