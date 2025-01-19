class_name Level extends LuaScript

func _ready() -> void:
	if SecondTest.is_clonning: return
	#if Engine.is_editor_hint(): return
	on_level_init()
	on_post_level_load()
	init_ambient(
		'gold',
		constants.ai_ambient_gold_amount,
		constants.ai_ambient_gold_interval,
		constants.ai_ambient_gold_delay,
		constants.ai_disable_ambient_gold_while_dead,
		func(champion: Champion, amount: float) -> void:
			champion.gold += amount
	)
	init_ambient(
		'exp',
		constants.ai_ambient_xp_amount,
		constants.ai_ambient_xp_interval,
		constants.ai_ambient_xp_delay,
		constants.ai_disable_ambient_xp_while_dead,
		func(champion: Champion, amount: float) -> void:
			champion.exp += amount
	)

func on_level_init() -> void: pass
func on_post_level_load() -> void: pass

var champions: Array[Champion] = []
func register_champion(champion: Champion) -> void:
	champions.append(champion)

@onready var root: Node = get_tree().current_scene
@onready var constants: Constants = root.get_node("%Constants")
func init_ambient(
	resource_name: String,
	amount: float,
	interval: float,
	delay: float,
	disable_while_dead: bool,
	set_resource_func: Callable
) -> void:
	if amount == 0: return
	var ambient_timer := Timer.new()
	add_child(ambient_timer)
	var accrue_ambient := func accrue_ambient() -> void:
		if is_equal_approx(ambient_timer.wait_time, delay):
			ambient_timer.start(interval)
		for champion in champions:
			if !(champion.status.is_dead && disable_while_dead):
				set_resource_func.call(champion, amount)
				#champion[resource_name] += amount
	ambient_timer.name = (nameof(accrue_ambient) + '_' + resource_name).to_pascal_case()
	ambient_timer.timeout.connect(accrue_ambient)
	ambient_timer.one_shot = false
	ambient_timer.start(delay)

func preload_character(character_name: String) -> void:
	pass

func preload_spell(spell_name: String) -> void:
	pass

func get_turret(team: int, lane: int, pos: int) -> Turret:
	return null

func get_dampener(team: int, lane: int) -> Dampener:
	return null

func get_barracks(team: int, lane: int) -> Barrack:
	return null

func get_hq(team: int) -> HQ:
	return null

func get_total_team_minions_spawned() -> int:
	return 0
