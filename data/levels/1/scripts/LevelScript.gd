extends Level

const max_minions_ever = 180

const order_hq = 1
const chaos_hq = 2

const initial_time_to_spawn = 90.0
const increase_cannon_rate_timer_time = 2090.0
const upgrade_minion_timer_time = 180.0
const minion_health_denial_percent = 0.0
const exp_given_radius = 1250.0
const disable_minion_spawn_base_time = 300.0
const disable_minion_spawn_mag_time = 0.0

var caster_minion_spawn_frequency := 3

class G:
	var exp_given := 0.0
	var gold_given := 0.0
	var health_upgrade := 0.0
	var damage_upgrade := 0.0
	var gold_upgrade := 0.0
	var exp_upgrade := 0.0
	var armor_upgrade := 0.0
	var mr_upgrade := 0.0
	var health_inhibitor := 0.0
	var damage_inhibitor := 0.0
	var gold_inhibitor := 0.0
	var exp_inhibitor := 0.0
	var maximum_gold_bonus := 0.0

const melee := Enums.MinionType.MELEE
const archer := Enums.MinionType.ARCHER
const caster := Enums.MinionType.CASTER
const syper := Enums.MinionType.SUPER

var g: Dictionary[Enums.MinionType, G] = (
	func() -> Dictionary[Enums.MinionType, G]:
		var g: Dictionary[Enums.MinionType, G] = {}

		g[melee] = G.new()
		g[melee].exp_given = 64.0
		g[melee].gold_given = 22.0
		g[melee].health_upgrade = 20.0
		g[melee].damage_upgrade = 1.0
		g[melee].gold_upgrade = 0.5
		g[melee].exp_upgrade = 5.0
		g[melee].armor_upgrade = 2.0
		g[melee].mr_upgrade = 1.25
		g[melee].health_inhibitor = 100.0
		g[melee].damage_inhibitor = 10.0
		g[melee].gold_inhibitor = 0.0
		g[melee].exp_inhibitor = 0.0
		g[melee].maximum_gold_bonus = 10.0

		g[archer] = G.new()
		g[archer].exp_given = 32.0
		g[archer].gold_given = 16.0
		g[archer].health_upgrade = 15.0
		g[archer].damage_upgrade = 2.0
		g[archer].gold_upgrade = 0.5
		g[archer].exp_upgrade = 3.0
		g[archer].armor_upgrade = 1.25
		g[archer].mr_upgrade = 2.0
		g[archer].health_inhibitor = 60.0
		g[archer].damage_inhibitor = 18.0
		g[archer].gold_inhibitor = 0.0
		g[archer].exp_inhibitor = 0.0
		g[archer].maximum_gold_bonus = 10.0

		g[caster] = G.new()
		g[caster].exp_given = 100.0
		g[caster].gold_given = 27.0
		g[caster].health_upgrade = 27.0
		g[caster].damage_upgrade = 3.0
		g[caster].gold_upgrade = 1.0
		g[caster].exp_upgrade = 7.0
		g[caster].armor_upgrade = 3.0
		g[caster].mr_upgrade = 3.0
		g[caster].health_inhibitor = 200.0
		g[caster].damage_inhibitor = 25.0
		g[caster].gold_inhibitor = 0.0
		g[caster].exp_inhibitor = 0.0
		g[caster].maximum_gold_bonus = 20.0

		g[syper] = G.new()
		g[syper].exp_given = 100.0
		g[syper].gold_given = 27.0
		g[syper].health_upgrade = 200.0
		g[syper].damage_upgrade = 10.0
		g[syper].gold_upgrade = 0.0
		g[syper].exp_upgrade = 0.0
		g[syper].armor_upgrade = 0.0
		g[syper].mr_upgrade = 0.0
		g[syper].health_inhibitor = 0.0
		g[syper].damage_inhibitor = 0.0
		g[syper].gold_inhibitor = 0.0
		g[syper].exp_inhibitor = 0.0
		g[syper].maximum_gold_bonus = 20.0
		return g
).call()

var last_wave := -1
var special_minion_mode: SpecialMinionMode = SpecialMinionMode.NONE
enum SpecialMinionMode {
	NONE,
	THREE_ARCHERS,
	SPECIAL_POWER_MINION,
	UNDEFINED,
}
var hq_turret_attackable := false

const chaos := Enums.Team.CHAOS
const order := Enums.Team.ORDER

var names: Dictionary[Enums.MinionType, Dictionary] = (
	func() -> Dictionary[Enums.MinionType, Dictionary]:
		var names: Dictionary[Enums.MinionType, Dictionary] = {}
		names[chaos] = {}
		names[chaos][melee] = "Red_Minion_Basic"
		names[chaos][archer] = "Red_Minion_Wizard"
		names[chaos][caster] = "Red_Minion_Mech_Cannon"
		names[chaos][syper] = "Red_Minion_Mech_Melee"
		names[order] = {}
		names[order][melee] = "Blue_Minion_Basic"
		names[order][archer] = "Blue_Minion_Wizard"
		names[order][caster] = "Blue_Minion_Mech_Cannon"
		names[order][syper] = "Blue_Minion_Mech_Melee"
		return names
).call()

var spawn_table := SpawnTable.new()
class SpawnTable:
	var wave_spawn_rate := 0
	var num_of_minions_per_wave: Dictionary[Enums.MinionType, int] = {
		melee: 0,
		archer: 0,
		caster: 0,
		syper: 0,
	}
	var single_minion_spawn_delay := 0.0
	var did_power_group := false
	var exp_radius := 0.0

var barracks_bonuses: Dictionary[Enums.Team, Dictionary] = {
	order: {
		Enums.Lane.RIGHT: LuaBarrack.new(g),
		Enums.Lane.CENTER: LuaBarrack.new(g),
		Enums.Lane.LEFT: LuaBarrack.new(g),
	},
	chaos: {
		Enums.Lane.RIGHT: LuaBarrack.new(g),
		Enums.Lane.CENTER: LuaBarrack.new(g),
		Enums.Lane.LEFT: LuaBarrack.new(g),
	}
}
class LuaBarrack:
	var is_destroyed := false
	var num_of_spawn_disables := 0.0
	var will_spawn_super_minion := 0.0
	var l: Dictionary[Enums.MinionType, L] = {}
	class L:
		var minion_name: String
		var minion_armor := 0.0
		var minion_magic_resistance := 0.0
		var hp_bonus := 0.0
		var damage_bonus := 0.0
		var gold_bonus := 0.0
		var exp_bonus := 0.0
		var exp_given := 0.0
		var gold_given := 0.0
	func _init(g: Dictionary[Enums.MinionType, G]) -> void:
		for type: Enums.MinionType in Enums.MinionType:
			l[type] = L.new()
			l[type].exp_given = g[type].exp_given
			l[type].exp_given = g[type].gold_given

const right := Enums.Lane.RIGHT
const center := Enums.Lane.CENTER
const left := Enums.Lane.LEFT

var building_status: Dictionary[Enums.Team, BuildingStatus] = {
	order: BuildingStatus.new(),
	chaos: BuildingStatus.new(),
}
class BuildingStatus:
	var hq_tower_2 := true
	var hq_tower_1 := true
	var hq := true
	var lanes: Dictionary[Enums.Lane, LaneBuildingTable] = {
		right: LaneBuildingTable.new(),
		center: LaneBuildingTable.new(),
		left: LaneBuildingTable.new(),
	}
	class LaneBuildingTable:
		var turret_3 := true
		var turret_2 := true
		var turret_1 := true
		var barracks := true

var total_number_of_chaos_barracks := 3
var total_number_of_order_barracks := 3
func on_level_init() -> void:
	#for r_3_2, r_4_2 in pairs(order_names):
	#	preload_character(r_4_2)
	#for r_3_2, r_4_2 in pairs(chaos_names):
	#	preload_character(r_4_2)
	preload_character("order_turret_angel")
	preload_character("order_turret_dragon")
	preload_character("order_turret_normal_2")
	preload_character("order_turret_normal")
	preload_character("chaos_turret_worm")
	preload_character("chaos_turret_worm_2")
	preload_character("chaos_turret_giant")
	preload_character("chaos_turret_normal")
	preload_spell("respawn_classic")
	preload_spell("spell_shield_marker")
	#math.randomseed(os.time())
	#load_script_into_script("neutral_minion_spawn.lua")
	#neutral_minion_init()
	#load_script_into_script("data\\scripts\\end_of_game.lua")
	spawn_table.wave_spawn_rate = 30000
	spawn_table.num_of_minions_per_wave[melee] = 3
	spawn_table.num_of_minions_per_wave[archer] = 3
	spawn_table.single_minion_spawn_delay = 800
	spawn_table.did_power_group = false
	init_timer(upgrade_minion_timer, upgrade_minion_timer_time, true)
	init_timer(increase_cannon_minion_spawn_rate, increase_cannon_rate_timer_time, false)
	init_timer(allow_damage_on_buildings, 10, false)

func on_post_level_load() -> void:
	#load_script_into_script("create_level_props.lua")
	#create_level_props()
	pass

func opposite_team(team: int) -> int:
	if team == Enums.Team.CHAOS:
		return Enums.Team.ORDER
	else:
		return Enums.Team.CHAOS

func upgrade_minion_timer() -> void:
	for lane: Enums.Lane in [right, center, left]:
		for team: Enums.Team in [order, chaos]:
			for type: Enums.MinionType in [melee, archer, caster, syper]:
				barracks_bonuses[team][lane].melee_hp_bonus += g[type].health_upgrade
				barracks_bonuses[team][lane].melee_damage_bonus += g[type].damage_upgrade
				barracks_bonuses[team][lane].melee_gold_bonus += g[type].gold_upgrade
				barracks_bonuses[team][lane].melee_minion_armor += g[type].armor_upgrade
				barracks_bonuses[team][lane].melee_minion_magic_resistance += g[type].mr_upgrade
				if g[type].maximum_gold_bonus < barracks_bonuses[team][lane].melee_gold_bonus:
					barracks_bonuses[team][lane].melee_gold_bonus = g[type].maximum_gold_bonus
				barracks_bonuses[team][lane].melee_exp_bonus += g[type].exp_upgrade
				barracks_bonuses[team][lane].melee_gold_given = barracks_bonuses[team][lane].melee_gold_bonus + g[type].gold_given
				barracks_bonuses[team][lane].melee_exp_given = barracks_bonuses[team][lane].melee_exp_bonus + g[type].exp_given

const back := Enums.Pos.BACK
const middle := Enums.Pos.MIDDLE
const front := Enums.Pos.FRONT
const hq1 := Enums.Pos.HQ_TOWER1
const hq2 := Enums.Pos.HQ_TOWER2

func allow_damage_on_buildings() -> void:
	for lane: Enums.Lane in [right, center, left]:
		for pos: Enums.Pos in [back, middle, front, hq1, hq2]:
			for team: Enums.Team in [order, chaos]:
				var turret := get_turret(team, lane, pos)
				if turret != null:
					if pos == Enums.Pos.FRONT:
						turret.status.invulnerable = false
						turret.status.targetable = true
					else:
						turret.status.invulnerable = true
						turret.status.set_not_targetable_to_team(true, opposite_team(team))

func get_minion_spawn_info(lane: int, r_1_7: int, r_2_7: Variant, team: int, wave: int) -> Dictionary:
	var table_for_barrack := spawn_table
	if table_for_barrack.did_power_group:
		table_for_barrack.num_of_minions_per_wave[caster] -= 1
		table_for_barrack.did_power_group = false

	if r_1_7 % caster_minion_spawn_frequency == 0:
		table_for_barrack.num_of_minions_per_wave[caster] += 1
		table_for_barrack.did_power_group = true

	var r_5_7: LuaBarrack = barracks_bonuses[team][lane]

	table_for_barrack.exp_radius = exp_given_radius
	var l_num_of_minions_per_wave := table_for_barrack.num_of_minions_per_wave.duplicate()

	if wave != last_wave:
		const barrackscount = 6
		var total_minions_remaining := max_minions_ever - get_total_team_minions_spawned()
		if total_minions_remaining <= barrackscount * 7:
			if total_minions_remaining <= 0:
				special_minion_mode = SpecialMinionMode.NONE
			elif barrackscount * 3 <= total_minions_remaining:
				special_minion_mode = SpecialMinionMode.THREE_ARCHERS
			elif barrackscount <= total_minions_remaining:
				special_minion_mode = SpecialMinionMode.SPECIAL_POWER_MINION
			else:
				special_minion_mode = SpecialMinionMode.NONE
		else:
			special_minion_mode = SpecialMinionMode.UNDEFINED

		last_wave = wave

	if special_minion_mode == SpecialMinionMode.THREE_ARCHERS:
		l_num_of_minions_per_wave[melee] = 0
		l_num_of_minions_per_wave[archer] = 3
		l_num_of_minions_per_wave[caster] = 0
		l_num_of_minions_per_wave[syper] = 0
	elif special_minion_mode == SpecialMinionMode.SPECIAL_POWER_MINION:
		l_num_of_minions_per_wave[melee] = 0
		l_num_of_minions_per_wave[archer] = 0
		l_num_of_minions_per_wave[caster] = 0
		l_num_of_minions_per_wave[syper] = 2
	elif special_minion_mode == SpecialMinionMode.NONE:
		l_num_of_minions_per_wave[melee] = 0
		l_num_of_minions_per_wave[archer] = 0
		l_num_of_minions_per_wave[caster] = 0
		l_num_of_minions_per_wave[syper] = 0

	if r_5_7.will_spawn_super_minion == 1:
		if team == Enums.Team.ORDER and total_number_of_chaos_barracks == 0 \
		or team == Enums.Team.CHAOS and total_number_of_order_barracks == 0:
			l_num_of_minions_per_wave[syper] = 2
		else:
			l_num_of_minions_per_wave[syper] = 1

		l_num_of_minions_per_wave[caster] = 0

	for type: Enums.MinionType in [melee, archer, caster, syper]:
		r_5_7.l[type].minion_name = names[team][type]

	var return_table := {
		num_of_minions_per_wave = l_num_of_minions_per_wave.duplicate(),

		wave_spawn_rate = table_for_barrack.wave_spawn_rate,
		single_minion_spawn_delay = table_for_barrack.single_minion_spawn_delay,

		is_destroyed = r_5_7.is_destroyed,

		melee_minion_name = r_5_7.melee_minion_name,
		melee_minion_armor = r_5_7.melee_minion_armor,
		melee_minion_magic_resistance = r_5_7.melee_minion_magic_resistance,
		melee_hp_bonus = r_5_7.melee_hp_bonus,
		melee_damage_bonus = r_5_7.melee_damage_bonus,
		melee_exp_given = r_5_7.melee_exp_given,
		melee_gold_given = r_5_7.melee_gold_given,

		archer_minion_name = r_5_7.archer_minion_name,
		archer_minion_armor = r_5_7.archer_minion_armor,
		archer_minion_magic_resistance = r_5_7.archer_minion_magic_resistance,
		archer_hp_bonus = r_5_7.archer_hp_bonus,
		archer_damage_bonus = r_5_7.archer_damage_bonus,
		archer_exp_given = r_5_7.archer_exp_given,
		archer_gold_given = r_5_7.archer_gold_given,

		caster_minion_name = r_5_7.caster_minion_name,
		caster_minion_armor = r_5_7.caster_minion_armor,
		caster_minion_magic_resistance = r_5_7.caster_minion_magic_resistance,
		caster_hp_bonus = r_5_7.caster_hp_bonus,
		caster_damage_bonus = r_5_7.caster_damage_bonus,
		caster_exp_given = r_5_7.caster_exp_given,
		caster_gold_given = r_5_7.caster_gold_given,

		super_minion_name = r_5_7.super_minion_name,
		super_minion_armor = r_5_7.super_minion_armor,
		super_minion_magic_resistance = r_5_7.super_minion_magic_resistance,
		super_hp_bonus = r_5_7.super_hp_bonus,
		super_damage_bonus = r_5_7.super_damage_bonus,
		super_exp_given = r_5_7.super_exp_given,
		super_gold_given = r_5_7.super_gold_given,

		experience_radius = table_for_barrack.exp_radius,
	}
	return return_table #todo:

func deactivate_correct_structure(team: int, lane: int, pos: int) -> void:
	var r_3_8: BuildingStatus	# notice: implicit variable refs by block#[4, 6, 8, 10, 13]
	if team == Enums.Team.ORDER:
		r_3_8 = order_building_status
	else:
		r_3_8 = chaos_building_status

	if pos == enums.pos.front:
		r_3_8[lane].turret_3 = false
		var r_4_8 := get_turret(team, lane, enums.pos.middle)
		set_invulnerable(r_4_8, false)
		set_targetable(r_4_8, true)
	elif pos == enums.pos.middle:
		r_3_8[lane].turret_2 = false
		var r_4_8 := get_turret(team, lane, enums.pos.back)
		set_invulnerable(r_4_8, false)
		set_targetable(r_4_8, true)
	elif pos == enums.pos.back:
		r_3_8[lane].turret_1 = false
		var r_4_8 := get_dampener(team, lane)
		set_invulnerable(r_4_8, false)
		set_targetable(r_4_8, true)
	elif pos == enums.pos.hq_tower_2:
		r_3_8.hq_tower_2 = false
		if r_3_8.hq_tower_1 == false:
			var r_4_8 := get_hq(team)
			set_invulnerable(r_4_8, false)
			set_targetable(r_4_8, true)

	elif pos == enums.pos.hq_tower_1:
		r_3_8.hq_tower_1 = false
		if r_3_8.hq_tower_2 == false:
			var r_4_8 := get_hq(team)
			set_invulnerable(r_4_8, false)
			set_targetable(r_4_8, true)

func get_lua_barracks(team: int, lane: int) -> LuaBarrack:
	var r_2_9: LuaBarrack	# notice: implicit variable refs by block#[3]
	if team == Enums.Team.ORDER:
		r_2_9 = barracks_bonuses[order][lane]
	else:
		r_2_9 = barracks_bonuses[chaos][lane]
	return r_2_9

func get_disable_minion_spawn_time(lane: int, team: int) -> float:
	var barrack := get_lua_barracks(team, lane)
	return disable_minion_spawn_base_time + disable_minion_spawn_mag_time * barrack.num_of_spawn_disables

func disable_barracks_spawn(lane: int, team: int) -> void:
	var c_lang_barracks := get_barracks(team, lane)
	var lua_barrack := get_lua_barracks(team, lane)
	set_disable_minion_spawn(c_lang_barracks, get_disable_minion_spawn_time(lane, team))
	lua_barrack.num_of_spawn_disables += 1

var bonuses_counter := 0
func apply_barracks_destruction_bonuses(team: int, barrack_lane: int) -> void:
	bonuses_counter += 1
	for lane in range(3):
		if team == Enums.Team.ORDER:
			barracks_bonuses[order][lane].melee_hp_bonus += g[Enums.MinionType.MELEE].health_inhibitor
			barracks_bonuses[order][lane].melee_damage_bonus += g[Enums.MinionType.MELEE].damage_inhibitor
			barracks_bonuses[order][lane].archer_hp_bonus += archer_health_inhibitor
			barracks_bonuses[order][lane].archer_damage_bonus += archer_damage_inhibitor
			barracks_bonuses[order][lane].caster_hp_bonus += caster_health_inhibitor
			barracks_bonuses[order][lane].caster_damage_bonus += caster_damage_inhibitor
			barracks_bonuses[order][lane].super_hp_bonus += super_health_inhibitor
			barracks_bonuses[order][lane].super_damage_bonus += super_damage_inhibitor
			barracks_bonuses[order][lane].melee_exp_given -= g[Enums.MinionType.MELEE].exp_inhibitor
			barracks_bonuses[order][lane].melee_gold_given -= g[Enums.MinionType.MELEE].gold_inhibitor
			barracks_bonuses[order][lane].archer_exp_given -= archer_exp_inhibitor
			barracks_bonuses[order][lane].archer_gold_given = barracks_bonuses[order][lane].melee_gold_given - archer_gold_inhibitor
			barracks_bonuses[order][lane].caster_exp_given -= caster_exp_inhibitor
			barracks_bonuses[order][lane].caster_gold_given = barracks_bonuses[order][lane].melee_gold_given - caster_exp_inhibitor
			barracks_bonuses[order][lane].super_exp_given -= super_exp_inhibitor
			barracks_bonuses[order][lane].super_gold_given = barracks_bonuses[order][lane].melee_gold_given - super_exp_inhibitor
			if lane == barrack_lane:
				total_number_of_chaos_barracks -= 1
				barracks_bonuses[order][lane].will_spawn_super_minion = 1

		elif team == Enums.Team.CHAOS:
			barracks_bonuses[chaos][lane].melee_hp_bonus += g[Enums.MinionType.MELEE].health_inhibitor
			barracks_bonuses[chaos][lane].melee_damage_bonus += g[Enums.MinionType.MELEE].damage_inhibitor
			barracks_bonuses[chaos][lane].archer_hp_bonus += archer_health_inhibitor
			barracks_bonuses[chaos][lane].archer_damage_bonus += archer_damage_inhibitor
			barracks_bonuses[chaos][lane].caster_hp_bonus += caster_health_inhibitor
			barracks_bonuses[chaos][lane].caster_damage_bonus += caster_damage_inhibitor
			barracks_bonuses[chaos][lane].super_hp_bonus += super_health_inhibitor
			barracks_bonuses[chaos][lane].super_damage_bonus += super_damage_inhibitor
			barracks_bonuses[chaos][lane].melee_exp_given -= g[Enums.MinionType.MELEE].exp_inhibitor
			barracks_bonuses[chaos][lane].melee_gold_given -= g[Enums.MinionType.MELEE].gold_inhibitor
			barracks_bonuses[chaos][lane].archer_exp_given -= archer_exp_inhibitor
			barracks_bonuses[chaos][lane].archer_gold_given = barracks_bonuses[chaos][lane].melee_gold_given - archer_gold_inhibitor
			barracks_bonuses[chaos][lane].caster_exp_given -= caster_exp_inhibitor
			barracks_bonuses[chaos][lane].caster_gold_given = barracks_bonuses[chaos][lane].melee_gold_given - caster_exp_inhibitor
			barracks_bonuses[chaos][lane].super_exp_given -= super_exp_inhibitor
			barracks_bonuses[chaos][lane].super_gold_given = barracks_bonuses[chaos][lane].melee_gold_given - super_exp_inhibitor
			if lane == barrack_lane:
				total_number_of_order_barracks -= 1
				barracks_bonuses[chaos][lane].will_spawn_super_minion = 1

var reduction_counter := 0
func apply_barracks_respawn_reductions(team: int, barrack_lane: int) -> void:
	reduction_counter += 1
	for lane in range(3):
		if team == Enums.Team.ORDER:
			barracks_bonuses[order][lane].melee_hp_bonus -= g[Enums.MinionType.MELEE].health_inhibitor
			barracks_bonuses[order][lane].melee_damage_bonus -= g[Enums.MinionType.MELEE].damage_inhibitor
			barracks_bonuses[order][lane].archer_hp_bonus -= archer_health_inhibitor
			barracks_bonuses[order][lane].archer_damage_bonus -= archer_damage_inhibitor
			barracks_bonuses[order][lane].caster_hp_bonus -= caster_health_inhibitor
			barracks_bonuses[order][lane].caster_damage_bonus -= caster_damage_inhibitor
			barracks_bonuses[order][lane].super_hp_bonus -= super_health_inhibitor
			barracks_bonuses[order][lane].super_damage_bonus -= super_damage_inhibitor
			barracks_bonuses[order][lane].melee_exp_given += g[Enums.MinionType.MELEE].exp_inhibitor
			barracks_bonuses[order][lane].melee_gold_given += g[Enums.MinionType.MELEE].gold_inhibitor
			barracks_bonuses[order][lane].archer_exp_given += archer_exp_inhibitor
			barracks_bonuses[order][lane].archer_gold_given = barracks_bonuses[order][lane].melee_gold_given + archer_gold_inhibitor
			barracks_bonuses[order][lane].caster_exp_given += caster_exp_inhibitor
			barracks_bonuses[order][lane].caster_gold_given = barracks_bonuses[order][lane].melee_gold_given + caster_exp_inhibitor
			barracks_bonuses[order][lane].super_exp_given += super_exp_inhibitor
			barracks_bonuses[order][lane].super_gold_given = barracks_bonuses[order][lane].melee_gold_given + super_exp_inhibitor
			if lane == barrack_lane:
				total_number_of_chaos_barracks += 1
				barracks_bonuses[order][lane].will_spawn_super_minion = 0

			if total_number_of_chaos_barracks == 3:
				hq = get_hq(Enums.Team.CHAOS)
				set_invulnerable(hq, true)
				set_targetable(hq, false)
				for r_9_13: Enums.Lane in Enums.Lane:
					var r_10_13 := get_turret(Enums.Team.CHAOS, r_9_13, enums.pos.hq_tower_1)
					var r_11_13 := get_turret(Enums.Team.CHAOS, r_9_13, enums.pos.hq_tower_2)
					if r_10_13 != nil:
						set_invulnerable(r_10_13, true)
						set_targetable(r_10_13, false)

					if r_11_13 != nil:
						set_invulnerable(r_11_13, true)
						set_targetable(r_11_13, false)

		elif team == Enums.Team.CHAOS:
			barracks_bonuses[chaos][lane].melee_hp_bonus -= g[Enums.MinionType.MELEE].health_inhibitor
			barracks_bonuses[chaos][lane].melee_damage_bonus -= g[Enums.MinionType.MELEE].damage_inhibitor
			barracks_bonuses[chaos][lane].archer_hp_bonus -= archer_health_inhibitor
			barracks_bonuses[chaos][lane].archer_damage_bonus -= archer_damage_inhibitor
			barracks_bonuses[chaos][lane].caster_hp_bonus -= caster_health_inhibitor
			barracks_bonuses[chaos][lane].caster_damage_bonus -= caster_damage_inhibitor
			barracks_bonuses[chaos][lane].super_hp_bonus -= super_health_inhibitor
			barracks_bonuses[chaos][lane].super_damage_bonus -= super_damage_inhibitor
			barracks_bonuses[chaos][lane].melee_exp_given += g[Enums.MinionType.MELEE].exp_inhibitor
			barracks_bonuses[chaos][lane].melee_gold_given += g[Enums.MinionType.MELEE].gold_inhibitor
			barracks_bonuses[chaos][lane].archer_exp_given += archer_exp_inhibitor
			barracks_bonuses[chaos][lane].archer_gold_given = barracks_bonuses[chaos][lane].melee_gold_given + archer_gold_inhibitor
			barracks_bonuses[chaos][lane].caster_exp_given += caster_exp_inhibitor
			barracks_bonuses[chaos][lane].caster_gold_given = barracks_bonuses[chaos][lane].melee_gold_given + caster_exp_inhibitor
			barracks_bonuses[chaos][lane].super_exp_given += super_exp_inhibitor
			barracks_bonuses[chaos][lane].super_gold_given = barracks_bonuses[chaos][lane].melee_gold_given + super_exp_inhibitor
			if lane == barrack_lane:
				total_number_of_order_barracks += 1
				barracks_bonuses[chaos][lane].will_spawn_super_minion = 0

			if total_number_of_order_barracks == 3:
				var r_6_13 := get_hq(Enums.Team.ORDER)
				set_invulnerable(r_6_13, true)
				set_targetable(r_6_13, false)
				for r_10_13: Enums.Lane in Enums.Lane:
					var r_11_13 := get_turret(Enums.Team.ORDER, r_10_13, enums.pos.hq_tower_1)
					var r_12_13 := get_turret(Enums.Team.ORDER, r_10_13, enums.pos.hq_tower_2)
					if r_11_13 != nil:
						set_invulnerable(r_11_13, true)
						set_targetable(r_11_13, false)

					if r_12_13 != nil:
						set_invulnerable(r_12_13, true)
						set_targetable(r_12_13, false)

var reactive_counter := 0
func barrack_reactive_event(team: int, lane: int) -> void:
	reactive_counter += 1
	var r_2_14 := opposite_team(team)
	var dampener = get_dampener(team, lane)
	set_invulnerable(dampener, false)
	set_targetable(dampener, true)
	apply_barracks_respawn_reductions(r_2_14, lane)

var disactivated_counter := 0
func handle_destroyed_object(r_0_15: unit):
	hq_type = get_hq_type(r_0_15)
	if hq_type == order_hq or hq_type == chaos_hq:
		if hq_type == chaos_hq:
			end_of_game_ceremony(Enums.Team.ORDER, r_0_15)
		else:
			end_of_game_ceremony(Enums.Team.CHAOS, r_0_15)
		return

	if is_dampener(r_0_15):
		barrack = get_linked_barrack(r_0_15)
		barrack_team = get_team_id(barrack)
		barrack_lane = get_lane(r_0_15)
		disable_barracks_spawn(barrack_lane, barrack_team)
		set_dampener_state(r_0_15, dampener_regeneration_state)
		set_invulnerable(r_0_15, true)
		set_targetable(r_0_15, false)
		disactivated_counter += 1
		var r_1_15 := get_turret(barrack_team, 1, enums.pos.hq_tower_1)
		var r_2_15 := get_turret(barrack_team, 1, enums.pos.hq_tower_2)
		if r_1_15 != nil:
			set_invulnerable(r_1_15, false)
			set_targetable(r_1_15, true)

		if r_2_15 != nil:
			set_invulnerable(r_2_15, false)
			set_targetable(r_2_15, true)

		if r_1_15 == nil and r_2_15 == nil:
			var r_3_15 := get_hq(barrack_team)
			set_invulnerable(r_3_15, false)
			set_targetable(r_3_15, true)

		var r_3_15 := null
		if barrack_team == Enums.Team.CHAOS:
			r_3_15 = Enums.Team.ORDER
		else:
			r_3_15 = Enums.Team.CHAOS

		apply_barracks_destruction_bonuses(r_3_15, barrack_lane)

	if is_turret_ai(r_0_15):
		deactivate_correct_structure(get_team_id(r_0_15), get_object_lane_id(r_0_15), get_turret_position(r_0_15))
		return

	var r_1_15 := get_dampener_type(r_0_15)
	if r_1_15 > -1:
		var r_2_15 := 0
		var r_3_15 := Enums.Team.ORDER
		var r_4_15 := Enums.Team.CHAOS
		var r_5_15 := r_1_15 % Enums.Team.CHAOS
		if enums.lane.right <= r_5_15 and r_5_15 <= enums.lane.left:
			r_2_15 = barracks_bonuses[chaos][r_5_15 + 1]
			chaos_building_status[r_5_15 + 1].barracks = false
		else:
			r_5_15 -= Enums.Team.ORDER
			r_3_15 = Enums.Team.CHAOS
			r_4_15 = Enums.Team.ORDER
			r_2_15 = barracks_bonuses[order][r_5_15 + 1]
			order_building_status[r_5_15 + 1].barracks = false

	else:
		log("could not find linking barracks!")

	return true

func increase_cannon_minion_spawn_rate() -> void:
	caster_minion_spawn_frequency = 2
