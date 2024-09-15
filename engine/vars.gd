class_name Vars
extends Node

@onready var me := get_parent() as Unit
func _ready():
	if Engine.is_editor_hint(): return
	me.vars = self

@export var orb_of_deception_is_active: int
@export var fox_fire_is_active: int
@export var seduce_is_active: int
@export var tumble_is_active: int
@export var dance_timer_cooldown: float
@export var vamp_percent: float
@export var base_block_amount: float
@export var magic_resist_reduction: int
@export var stun_duration: float
@export var num_seconds_since_last_crit: float
@export var crit_per_second: float
@export var last_crit: float
@export var cast_point: Vector3
#@export var wildfire_count: int # unused
@export var tooltip_amount: float
@export var percent_of_attack: float
#@export var second_skin_armor: int # unused
@export var charge_cooldown: float
@export var barrage_counter: float
@export var malice_heal: float
#@export var dark_wind_count: int # unused
#@export var regen_mod: int # unused
@export var command_bonus: float
@export var total_bonus: float
#@export var command_ready: int # unused
@export var max_bonus: float
@export var armor_amount: float
#@export var passive_duration: int # unused
#@export var passive_max_stacks: int # unused
#@export var time1: int # unused
#@export var time2: int # unused
#@export var time3: int # unused
#@export var time4: int # unused
#@export var time5: int # unused
#@export var time6: int # unused
#@export var level1: int # unused
#@export var level2: int # unused
#@export var level3: int # unused
#@export var level4: int # unused
#@export var level5: int # unused
#@export var level6: int # unused
@export var ccreduction: float
@export var num_swings: float
@export var last_hit_time: float
@export var ult_stacks: int
@export var mantra_timer_cooldown: float
@export var magic_absorb: float
@export var count: float
@export var last_cast: int
@export var first_target_hit: bool
@export var illuminate_damage: float
@export var tally: float
@export var damage_bonus: float
#@export var dripping_wound_duration: int # unused
#@export var dripping_wound_max: int # unused
@export var takedown_damage: float
@export var pounce_damage: float
@export var swipe_damage: float
@export var heal_amount: float
@export var last_hit: float
@export var ghost_alive: bool
@export var missile: Missile
@export var damage_count: float
@export var armor_count: float
#@export var kills_per_armor: int # unused
#@export var armor_per_champion_kill: int # unused
@export var num_minions_killed: float
#@export var scavenge_armor_total: int # unused
#@export var per_percent: float # unused
@export var rage_threshold: float
#@export var bonus_damage: int # unused
#@export var rage_bonus_damage: int # unused
#@export var autoattack_rage: int # unused
@export var danger_zone: int
#@export var shield_amount: int # unused
@export var frost_duration: float
@export var hit_count: float
@export var block_chance: float
@export var last_time_executed: float
#@export var attack_counter: int # unused
@export var missile_number: float
@export var mushroom_cooldown: float
@export var trail_duration: float
@export var bonus_range: float
@export var regen_value: float
#@export var disease_counter: int # unused
@export var damage_amount: float
@export var base_crit_chance: float
@export var apgain: float
@export var has_removed: bool
@export var regen_percent: float
@export var regen_tooltip: float
@export var life_steal_amount: float
@export var combo_counter: float
#@export var spectral_counter: int # unused
@export var tear_bonus_mana: float
@export var bonus_for_item: float
@export var attack_speed_increase: float
@export var life_time: float
#@export var bonus_mr: float # unitialized
#@export var life_loss_percent: float # unitialized
@export var last_life_loss_percent: float
#@export var last_tooltip: float # unused
#@export var mini_crit_chance: float # unitialized
@export var cannibalism_max_hpmod: float
#@export var second_skin: float # unitialized
#@export var second_skin_mr: float # unitialized
#@export var mundo_percent: float # unitialized
#@export var add_spell_damage: object # unitialized
@export var hpgain: float
@export var do_once: bool
@export var jump_buffer: Vector3
#@export var ult_missile: object # unused
#@export var ult_fired: bool # unused
@export var count_mana_potion: int
#@export var dodge_chance: float # unitialized
@export var flurry_scalar: float
@export var briggs_cast_pos: Vector3
@export var armor_amount_neg: float
@export var spell_will_stun: bool
@export var starting_damage: float
@export var num_counter: float
@export var increment_gain: float
@export var stored_damage: float
@export var ball_position: Vector3
@export var ultimate_type: int
@export var ultimate_target_pos: Vector3
@export var ghost_initialized: bool
@export var temp_skin: int
@export var izuna_percent: float
@export var target_pos: Vector3
#@export var particle: object # unitialized
@export var count_health_potion: int
#@export var ticks: int # unused
#@export var swung: bool # unused
#@export var counter: int # unused
#@export var owner_pos: Vector3 # unused
#@export var bubble_radius: float # unitialized
@export var magic_damage_mod: float
@export var spectral_count: float
@export var teleport_cancelled: bool
@export var missile2: Missile
#@export var has_cast_r: bool # unused
@export var samissile_number: float
#@export var missile: Missile # same name after lowercasing
@export var hit_once: bool
#@export var lhand: particle # unitialized
#@export var rhand: particle # unitialized
#@export var curr_speed: float # unused
@export var mana_to_add: float
@export var health_to_add: float
@export var total_damage: float
@export var is_champ_target: bool
@export var num_tide_stacks: float
@export var bounce_pos: Vector3
