class_name Level
extends LuaScript

func _ready() -> void:
	if Engine.is_editor_hint(): return
	on_level_init()
	on_post_level_load()
	init_ambient_gold()

func on_level_init() -> void: pass
func on_post_level_load() -> void: pass

var champions: Array[Champion] = []
func register_champion(champion: Champion) -> void:
	champions.append(champion)

@onready var root := get_tree().current_scene
@onready var constants: Constants = root.get_node("%Constants")
func init_ambient_gold() -> void:
	var ambient_gold_timer := Timer.new()
	add_child(ambient_gold_timer)
	var accrue_ambient_gold := func accrue_ambient_gold() -> void:
		for champion in champions:
			if !(champion.status.is_dead && constants.ai_disable_ambient_gold_while_dead):
				champion.gold += constants.ai_ambient_gold_amount
		ambient_gold_timer.wait_time = constants.ai_ambient_gold_interval
	ambient_gold_timer.name = nameof(accrue_ambient_gold).to_pascal_case()
	ambient_gold_timer.wait_time = constants.ai_ambient_gold_delay
	ambient_gold_timer.timeout.connect(accrue_ambient_gold)
	ambient_gold_timer.one_shot = false
	ambient_gold_timer.start()

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
