class_name Map1_LevelScript extends Level

const max_minions_ever = 180
const initial_time_to_spawn = 90.0
const increase_cannon_rate_timer_time = 2090.0
const upgrade_minion_timer_time = 180.0
const minion_health_denial_percent = 0.0
const exp_given_radius = 1250.0
const disable_minion_spawn_base_time = 300.0
const disable_minion_spawn_mag_time = 0.0

var caster_minion_spawn_frequency: int = 3

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

const MELEE := Enums.MinionType.MELEE
const ARCHER := Enums.MinionType.ARCHER
const CASTER := Enums.MinionType.CASTER
const SUPER := Enums.MinionType.SUPER

var g: Dictionary[Enums.MinionType, G] = (
	func() -> Dictionary[Enums.MinionType, G]:
		var g: Dictionary[Enums.MinionType, G] = {}

		var g_melee := G.new()
		g[MELEE] = g_melee
		g_melee.exp_given = 64.0
		g_melee.gold_given = 22.0
		g_melee.health_upgrade = 20.0
		g_melee.damage_upgrade = 1.0
		g_melee.gold_upgrade = 0.5
		g_melee.exp_upgrade = 5.0
		g_melee.armor_upgrade = 2.0
		g_melee.mr_upgrade = 1.25
		g_melee.health_inhibitor = 100.0
		g_melee.damage_inhibitor = 10.0
		g_melee.gold_inhibitor = 0.0
		g_melee.exp_inhibitor = 0.0
		g_melee.maximum_gold_bonus = 10.0

		var g_archer := G.new()
		g[ARCHER] = g_archer
		g_archer.exp_given = 32.0
		g_archer.gold_given = 16.0
		g_archer.health_upgrade = 15.0
		g_archer.damage_upgrade = 2.0
		g_archer.gold_upgrade = 0.5
		g_archer.exp_upgrade = 3.0
		g_archer.armor_upgrade = 1.25
		g_archer.mr_upgrade = 2.0
		g_archer.health_inhibitor = 60.0
		g_archer.damage_inhibitor = 18.0
		g_archer.gold_inhibitor = 0.0
		g_archer.exp_inhibitor = 0.0
		g_archer.maximum_gold_bonus = 10.0

		var g_caster := G.new()
		g[CASTER] = g_caster
		g_caster.exp_given = 100.0
		g_caster.gold_given = 27.0
		g_caster.health_upgrade = 27.0
		g_caster.damage_upgrade = 3.0
		g_caster.gold_upgrade = 1.0
		g_caster.exp_upgrade = 7.0
		g_caster.armor_upgrade = 3.0
		g_caster.mr_upgrade = 3.0
		g_caster.health_inhibitor = 200.0
		g_caster.damage_inhibitor = 25.0
		g_caster.gold_inhibitor = 0.0
		g_caster.exp_inhibitor = 0.0
		g_caster.maximum_gold_bonus = 20.0

		var g_syper := G.new()
		g[SUPER] = g_syper
		g_syper.exp_given = 100.0
		g_syper.gold_given = 27.0
		g_syper.health_upgrade = 200.0
		g_syper.damage_upgrade = 10.0
		g_syper.gold_upgrade = 0.0
		g_syper.exp_upgrade = 0.0
		g_syper.armor_upgrade = 0.0
		g_syper.mr_upgrade = 0.0
		g_syper.health_inhibitor = 0.0
		g_syper.damage_inhibitor = 0.0
		g_syper.gold_inhibitor = 0.0
		g_syper.exp_inhibitor = 0.0
		g_syper.maximum_gold_bonus = 20.0
		return g
).call()

var last_wave: int = -1
var special_minion_mode: SpecialMinionMode = SpecialMinionMode.NONE
enum SpecialMinionMode {
	NONE,
	THREE_ARCHERS,
	SPECIAL_POWER_MINION,
	UNDEFINED,
}
var hq_turret_attackable: bool = false

const CHAOS := Enums.Team.CHAOS
const ORDER := Enums.Team.ORDER

var names: Dictionary[Enums.MinionType, Dictionary] = (
	func() -> Dictionary[Enums.MinionType, Dictionary]:
		var names: Dictionary[Enums.MinionType, Dictionary] = {}
		names[CHAOS] = {}
		names[CHAOS][MELEE] = "Red_Minion_Basic"
		names[CHAOS][ARCHER] = "Red_Minion_Wizard"
		names[CHAOS][CASTER] = "Red_Minion_Mech_Cannon"
		names[CHAOS][SUPER] = "Red_Minion_Mech_Melee"
		names[ORDER] = {}
		names[ORDER][MELEE] = "Blue_Minion_Basic"
		names[ORDER][ARCHER] = "Blue_Minion_Wizard"
		names[ORDER][CASTER] = "Blue_Minion_Mech_Cannon"
		names[ORDER][SUPER] = "Blue_Minion_Mech_Melee"
		return names
).call()

var spawn_table: SpawnTable = SpawnTable.new()
class SpawnTable:
	var wave_spawn_rate := 0
	var num_of_minions_per_wave: Dictionary[Enums.MinionType, int] = {
		MELEE: 0,
		ARCHER: 0,
		CASTER: 0,
		SUPER: 0,
	}
	var single_minion_spawn_delay := 0.0
	var did_power_group := false
	var exp_radius := 0.0

var barracks_bonuses: Dictionary[Enums.Team, Dictionary] = {
	ORDER: {
		Enums.Lane.RIGHT: LuaBarrack.new(g),
		Enums.Lane.CENTER: LuaBarrack.new(g),
		Enums.Lane.LEFT: LuaBarrack.new(g),
	},
	CHAOS: {
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
		var exp_bonus := 0.0
		var gold_bonus := 0.0
		var exp_given := 0.0
		var gold_given := 0.0
	func _init(g: Dictionary[Enums.MinionType, G]) -> void:
		for type: Enums.MinionType in [MELEE, ARCHER, CASTER, SUPER]:
			l[type] = L.new()
			l[type].exp_given = g[type].exp_given
			l[type].exp_given = g[type].gold_given

const RIGHT := Enums.Lane.RIGHT
const CENTER := Enums.Lane.CENTER
const LEFT := Enums.Lane.LEFT

var building_status: Dictionary[Enums.Team, BuildingStatus] = {
	ORDER: BuildingStatus.new(),
	CHAOS: BuildingStatus.new(),
}
class BuildingStatus:
	var hq_tower_2 := true
	var hq_tower_1 := true
	var hq := true
	var lanes: Dictionary[Enums.Lane, LaneBuildingTable] = {
		RIGHT: LaneBuildingTable.new(),
		CENTER: LaneBuildingTable.new(),
		LEFT: LaneBuildingTable.new(),
	}
	class LaneBuildingTable:
		var turret_3 := true
		var turret_2 := true
		var turret_1 := true
		var barracks := true

var total_number_of_barracks: Dictionary[Enums.Team, int] = {
	ORDER: 3,
	CHAOS: 3,
}
func on_level_init() -> void:
	#for r_3_2, r_4_2 in pairs(order_names):
	#	preload_character(r_4_2)
	#for r_3_2, r_4_2 in pairs(chaos_names):
	#	preload_character(r_4_2)
	#preload_character("order_turret_angel")
	#preload_character("order_turret_dragon")
	#preload_character("order_turret_normal_2")
	#preload_character("order_turret_normal")
	#preload_character("chaos_turret_worm")
	#preload_character("chaos_turret_worm_2")
	#preload_character("chaos_turret_giant")
	#preload_character("chaos_turret_normal")
	#preload_spell("respawn_classic")
	#preload_spell("spell_shield_marker")
	#math.randomseed(os.time())
	preload("NeutralMinionSpawn.gd").new().neutral_minion_init()
	spawn_table.wave_spawn_rate = 30000
	spawn_table.num_of_minions_per_wave[MELEE] = 3
	spawn_table.num_of_minions_per_wave[ARCHER] = 3
	spawn_table.single_minion_spawn_delay = 800
	spawn_table.did_power_group = false
	init_timer(upgrade_minion_timer, upgrade_minion_timer_time, true)
	init_timer(increase_cannon_minion_spawn_rate, increase_cannon_rate_timer_time, false)
	init_timer(allow_damage_on_buildings, 10, false)

#func on_post_level_load() -> void:
#	preload("CreateLevelProps.gd").new().create_level_props()

func opposite_team(team: int) -> int:
	if team == Enums.Team.CHAOS:
		return Enums.Team.ORDER
	else:
		return Enums.Team.CHAOS

func upgrade_minion_timer() -> void:
	for lane: Enums.Lane in [RIGHT, CENTER, LEFT]:
		for team: Enums.Team in [ORDER, CHAOS]:
			for type: Enums.MinionType in [MELEE, ARCHER, CASTER, SUPER]:
				var lua_barrack: LuaBarrack = barracks_bonuses[team][lane]
				var l := lua_barrack.l[type]
				l.hp_bonus += g[type].health_upgrade
				l.damage_bonus += g[type].damage_upgrade
				l.gold_bonus += g[type].gold_upgrade
				l.minion_armor += g[type].armor_upgrade
				l.minion_magic_resistance += g[type].mr_upgrade
				if g[type].maximum_gold_bonus < l.gold_bonus:
					l.gold_bonus = g[type].maximum_gold_bonus
				l.exp_bonus += g[type].exp_upgrade
				l.gold_given = l.gold_bonus + g[type].gold_given
				l.exp_given = l.exp_bonus + g[type].exp_given

const BACK := Enums.Pos.BACK
const MIDDLE := Enums.Pos.MIDDLE
const FRONT := Enums.Pos.FRONT
const HQ_TOWER_1 := Enums.Pos.HQ_TOWER_1
const HQ_TOWER_2 := Enums.Pos.HQ_TOWER_2

func allow_damage_on_buildings() -> void:
	for lane: Enums.Lane in [RIGHT, CENTER, LEFT]:
		for pos: Enums.Pos in [BACK, MIDDLE, FRONT, HQ_TOWER_1, HQ_TOWER_2]:
			for team: Enums.Team in [ORDER, CHAOS]:
				var turret := get_turret(team, lane, pos)
				if turret != null:
					if pos == Enums.Pos.FRONT:
						turret.status.invulnerable = false
						turret.status.targetable = true
					else:
						turret.status.invulnerable = true
						turret.status.set_not_targetable_to_team(true, opposite_team(team))

func get_minion_spawn_info(lane: int, wave_1: int, unused: Variant, team: int, wave_2: int) -> SpawnInfo:
	var table_for_barrack := spawn_table
	if table_for_barrack.did_power_group:
		table_for_barrack.num_of_minions_per_wave[CASTER] -= 1
		table_for_barrack.did_power_group = false

	if wave_1 % caster_minion_spawn_frequency == 0:
		table_for_barrack.num_of_minions_per_wave[CASTER] += 1
		table_for_barrack.did_power_group = true

	var lua_barrack: LuaBarrack = barracks_bonuses[team][lane]

	table_for_barrack.exp_radius = exp_given_radius
	var l_num_of_minions_per_wave := table_for_barrack.num_of_minions_per_wave.duplicate()

	if wave_2 != last_wave:
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

		last_wave = wave_2

	if special_minion_mode == SpecialMinionMode.THREE_ARCHERS:
		l_num_of_minions_per_wave[MELEE] = 0
		l_num_of_minions_per_wave[ARCHER] = 3
		l_num_of_minions_per_wave[CASTER] = 0
		l_num_of_minions_per_wave[SUPER] = 0
	elif special_minion_mode == SpecialMinionMode.SPECIAL_POWER_MINION:
		l_num_of_minions_per_wave[MELEE] = 0
		l_num_of_minions_per_wave[ARCHER] = 0
		l_num_of_minions_per_wave[CASTER] = 0
		l_num_of_minions_per_wave[SUPER] = 2
	elif special_minion_mode == SpecialMinionMode.NONE:
		l_num_of_minions_per_wave[MELEE] = 0
		l_num_of_minions_per_wave[ARCHER] = 0
		l_num_of_minions_per_wave[CASTER] = 0
		l_num_of_minions_per_wave[SUPER] = 0

	if lua_barrack.will_spawn_super_minion == 1:
		if total_number_of_barracks[opposite_team(team)] == 0:
			l_num_of_minions_per_wave[SUPER] = 2
		else:
			l_num_of_minions_per_wave[SUPER] = 1

		l_num_of_minions_per_wave[CASTER] = 0

	for type: Enums.MinionType in [MELEE, ARCHER, CASTER, SUPER]:
		var l := lua_barrack.l[type]
		l.minion_name = names[team][type]

	var return_table := SpawnInfo.new()
	return_table.num_of_minions_per_wave = l_num_of_minions_per_wave.duplicate()
	return_table.wave_spawn_rate = table_for_barrack.wave_spawn_rate
	return_table.single_minion_spawn_delay = table_for_barrack.single_minion_spawn_delay
	return_table.is_destroyed = lua_barrack.is_destroyed
	return_table.experience_radius = table_for_barrack.exp_radius
	for type: Enums.MinionType in [MELEE, ARCHER, CASTER, SUPER]:
		var l := lua_barrack.l[type]
		return_table.l[type].minion_name = l.minion_name
		return_table.l[type].minion_armor = l.minion_armor
		return_table.l[type].minion_magic_resistance = l.minion_magic_resistance
		return_table.l[type].hp_bonus = l.hp_bonus
		return_table.l[type].damage_bonus = l.damage_bonus
		return_table.l[type].exp_given = l.exp_given
		return_table.l[type].gold_given = l.gold_given
	return return_table

class SpawnInfo:
	var l: Dictionary[Enums.MinionType, L] = {}
	var num_of_minions_per_wave: Dictionary[Enums.MinionType, int]
	var wave_spawn_rate: int
	var single_minion_spawn_delay: float
	var is_destroyed: bool
	var experience_radius: float
	class L:
		var minion_name: String
		var minion_armor: float
		var minion_magic_resistance: float
		var hp_bonus: float
		var damage_bonus: float
		var exp_given: float
		var gold_given: float

func deactivate_correct_structure(team: int, lane: int, pos: int) -> void:
	var building_status_team := building_status[team]
	if pos == Enums.Pos.FRONT:
		building_status_team.lanes[lane].turret_3 = false
		var turret := get_turret(team, lane, Enums.Pos.MIDDLE)
		turret.status.invulnerable = false
		turret.status.targetable = true
	elif pos == Enums.Pos.MIDDLE:
		building_status_team.lanes[lane].turret_2 = false
		var turret := get_turret(team, lane, Enums.Pos.BACK)
		turret.status.invulnerable = false
		turret.status.targetable = true
	elif pos == Enums.Pos.BACK:
		building_status_team.lanes[lane].turret_1 = false
		var dampener := get_dampener(team, lane)
		dampener.status.invulnerable = false
		dampener.status.targetable = true
	elif pos == Enums.Pos.HQ_TOWER_2:
		building_status_team.hq_tower_2 = false
		if building_status_team.hq_tower_1 == false:
			var hq := get_hq(team)
			hq.status.invulnerable = false
			hq.status.targetable = true
	elif pos == Enums.Pos.HQ_TOWER_1:
		building_status_team.hq_tower_1 = false
		if building_status_team.hq_tower_2 == false:
			var hq := get_hq(team)
			hq.status.invulnerable = false
			hq.status.targetable = true

func get_lua_barracks(team: int, lane: int) -> LuaBarrack:
	return barracks_bonuses[team][lane]

func get_disable_minion_spawn_time(lane: int, team: int) -> float:
	var barrack := get_lua_barracks(team, lane)
	return disable_minion_spawn_base_time + disable_minion_spawn_mag_time * barrack.num_of_spawn_disables

func disable_barracks_spawn(lane: int, team: int) -> void:
	var c_lang_barracks := get_barracks(team, lane)
	var lua_barrack := get_lua_barracks(team, lane)
	c_lang_barracks.disable_minion_spawn(get_disable_minion_spawn_time(lane, team))
	lua_barrack.num_of_spawn_disables += 1

var bonuses_counter: int = 0
func apply_barracks_destruction_bonuses(team: int, barrack_lane: int) -> void:
	bonuses_counter += 1
	var opposing_team := opposite_team(team)
	for lane: Enums.Lane in [RIGHT, CENTER, LEFT]:
		var lua_barrack: LuaBarrack = barracks_bonuses[team][lane]

		for type: Enums.MinionType in [MELEE, ARCHER, CASTER, SUPER]:
			var l := lua_barrack.l[type]
			l.hp_bonus += g[type].health_inhibitor
			l.damage_bonus += g[type].damage_inhibitor
			l.exp_given -= g[type].exp_inhibitor
			l.gold_given -= g[type].gold_inhibitor
		#lua_barrack.l[ARCHER].gold_given = lua_barrack.l[MELEE].gold_given - g[ARCHER].gold_inhibitor
		#lua_barrack.l[CASTER].gold_given = lua_barrack.l[MELEE].gold_given - g[CASTER].exp_inhibitor
		#lua_barrack.l[SUPER].gold_given = lua_barrack.l[MELEE].gold_given - g[SUPER].exp_inhibitor

		if lane == barrack_lane:
			total_number_of_barracks[opposing_team] -= 1
			lua_barrack.will_spawn_super_minion = 1

var reduction_counter: int = 0
func apply_barracks_respawn_reductions(team: int, barrack_lane: int) -> void:
	reduction_counter += 1
	var opposing_team := opposite_team(team)
	for lane: Enums.Lane in [RIGHT, CENTER, LEFT]:
		var lua_barrack: LuaBarrack = barracks_bonuses[team][lane]

		for type: Enums.MinionType in [MELEE, ARCHER, CASTER, SUPER]:
			var l := lua_barrack.l[type]
			l.hp_bonus -= g[type].health_inhibitor
			l.damage_bonus -= g[type].damage_inhibitor
			l.exp_given += g[type].exp_inhibitor
			l.gold_given += g[type].gold_inhibitor
		#lua_barrack.l[ARCHER].gold_given = lua_barrack.l[MELEE].gold_given + g[ARCHER].gold_inhibitor
		#lua_barrack.l[CASTER].gold_given = lua_barrack.l[MELEE].gold_given + g[CASTER].exp_inhibitor
		#lua_barrack.l[SUPER].gold_given = lua_barrack.l[MELEE].gold_given + g[SUPER].exp_inhibitor

		if lane == barrack_lane:
			total_number_of_barracks[opposing_team] += 1
			lua_barrack.will_spawn_super_minion = 0

	if total_number_of_barracks[opposing_team] == 3:
		var hq := get_hq(opposing_team)
		hq.status.invulnerable = true
		hq.status.targetable = false
		for lane: Enums.Lane in [RIGHT, CENTER, LEFT]:
			var hq_turret_1 := get_turret(opposing_team, lane, Enums.Pos.HQ_TOWER_1)
			var hq_turret_2 := get_turret(opposing_team, lane, Enums.Pos.HQ_TOWER_2)
			if hq_turret_1 != null:
				hq_turret_1.status.invulnerable = true
				hq_turret_1.status.targetable = false

			if hq_turret_2 != null:
				hq_turret_2.status.invulnerable = true
				hq_turret_2.status.targetable = false

var reactive_counter: int = 0
func barrack_reactive_event(team: int, lane: int) -> void:
	reactive_counter += 1
	var dampener := get_dampener(team, lane)
	dampener.status.invulnerable = false
	dampener.status.targetable = true
	apply_barracks_respawn_reductions(opposite_team(team), lane)

var disactivated_counter: int = 0
func handle_destroyed_object(unk_obj: Unit) -> void:
	if unk_obj is HQ:
		var obj := unk_obj as HQ
		preload("res://data/scripts/EndOfGame.gd").new().end_of_game_ceremony(opposite_team(obj.team), obj)

	elif unk_obj is Dampener:
		var obj := unk_obj as Dampener
		var barrack := obj.linked_barrack
		var barrack_team := barrack.team
		var barrack_lane := obj.lane
		disable_barracks_spawn(barrack_lane, barrack_team)
		obj.enter_regeneration_state()
		obj.status.invulnerable = true
		obj.status.targetable = false
		disactivated_counter += 1
		var hq_turret_1 := get_turret(barrack_team, 1, Enums.Pos.HQ_TOWER_1)
		var hq_turret_2 := get_turret(barrack_team, 1, Enums.Pos.HQ_TOWER_2)

		if hq_turret_1 != null:
			hq_turret_1.status.invulnerable = false
			hq_turret_1.status.targetable = true

		if hq_turret_2 != null:
			hq_turret_2.status.invulnerable = false
			hq_turret_2.status.targetable = true

		if hq_turret_1 == null and hq_turret_2 == null:
			var hq := get_hq(barrack_team)
			hq.status.invulnerable = false
			hq.status.targetable = true

		apply_barracks_destruction_bonuses(opposite_team(barrack_team), barrack_lane)

	elif unk_obj is Turret:
		var obj := unk_obj as Turret
		deactivate_correct_structure(obj.team, obj.lane, obj.pos)

	elif unk_obj is Dampener:
		var obj := unk_obj as Dampener
		building_status[obj.team].lanes[obj.lane].barracks = false

	else:
		print("Could not find linking barracks!")

func increase_cannon_minion_spawn_rate() -> void:
	caster_minion_spawn_frequency = 2
