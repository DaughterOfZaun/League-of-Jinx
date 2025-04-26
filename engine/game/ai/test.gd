class_name Test extends Node

class MyAgent extends GOAP.Agent:
	
	var time := 0.0
	
	var exp := 0.0
	var level := 1
	var gold := 0.0
	var mana_max := 115.0
	var mana := mana_max
	var mana_regen_rate := 1.25
	var health_max := 380.0
	var health := health_max
	var health_regen_rate := 1.1
	var respawn_time := 10.0
	var bounty := 300.0
	var attack_damage := 50.0
	var attack_interval := 1.6
	var attack_range := 625.0
	var move_speed := 305.0

	var position_spawn := Vector3(0.746, 2.485, -3.787) * Data.GD2HW
	var position := position_spawn
	
	var team := Enums.Team.ORDER
	
	var target_i := -1
	var target_range: float
	var units: Array[UnitRepr]
	class UnitRepr extends GOAP.Clonable:
		var name: String
		var team: Enums.Team
		var health: float
		var health_max: float
		var position: Vector3
		var invulnerable: bool
		var is_charmed: bool
		var is_visible: bool
		func copy(unk_from: Clonable) -> UnitRepr:
			var from: UnitRepr = unk_from
			name = from.name
			team = from.team
			health = from.health
			health_max = health_max
			position = from.position
			invulnerable = from.invulnerable
			is_charmed = from.is_charmed
			is_visible = from.is_visible
			return self
	
	var spell_i := -1
	var spells: Array[SpellRepr]
	class SpellRepr extends GOAP.Clonable:
		var name: String
		var mana_cost: float
		var cast_duration: float
		var channelling_duration: float
		var cooldown_start_time: float
		var cooldown_duration: float
		var is_targeted: bool
		var range: float
		var effect: Callable
		func copy(unk_from: Clonable) -> SpellRepr:
			var from: SpellRepr = unk_from
			name = from.name
			mana_cost = from.mana_cost
			cast_duration = from.cast_duration
			channelling_duration = from.channelling_duration
			cooldown_start_time = from.cooldown_start_time
			cooldown_duration = from.cooldown_duration
			is_targeted = from.is_targeted
			range = from.range
			effect = from.effect
			return self

	var is_dead: bool:
		get: return health <= 0

	var interruptable_action_start_time: float
	var is_moving := false
	var is_attacking := false
	var is_channeling := false
	var is_charmed := false
	
	var delayed_effects: Array[DelayedEffectRepr]
	class DelayedEffectRepr extends GOAP.Clonable:
		var start_time: float
		var effect_delay: float
		var effect: Callable
		func copy(unk_from: Clonable) -> DelayedEffectRepr:
			var from: DelayedEffectRepr = unk_from
			start_time = from.start_time
			effect = from.effect
			return self

	func clone_array(array: Array) -> Array:
		var res := array.duplicate(false)
		for i in range(len(res)):
			res[i] = clone_array_element(res[i])
		return res
	func clone_array_element(e: Clonable) -> Clonable:
		return e.clone() if e != null else e

	func copy(unk_from: Clonable) -> MyAgent:
		var from: MyAgent = unk_from
		time = from.time
		exp = from.exp
		level = from.level
		gold = from.gold
		mana_max = from.mana_max
		mana = from.mana
		mana_regen_rate = from.mana_regen_rate
		health_max = from.health_max
		health = from.health
		health_regen_rate = from.health_regen_rate
		respawn_time = from.respawn_time
		bounty = from.bounty
		attack_damage = from.attack_damage
		attack_interval = from.attack_interval
		attack_range = from.attack_range
		position_spawn = from.position_spawn
		position = from.position
		team = from.team
		units = clone_array(from.units)
		target_i = from.target_i
		target_range = from.target_range
		spells = clone_array(from.spells)
		spell_i = from.spell_i
		is_dead = from.is_dead
		interruptable_action_start_time = from.interruptable_action_start_time
		is_moving = from.is_moving
		is_attacking = from.is_attacking
		is_channeling = from.is_channeling
		is_charmed = from.is_charmed
		delayed_effects = clone_array(from.delayed_effects)
		return self

	func init() -> Agent:
		var enemy := UnitRepr.new()
		enemy.name = "enemy"
		enemy.team = Enums.Team.CHAOS
		enemy.health = health_max
		enemy.health_max = health_max
		enemy.position = Vector3(199.472, 2.485, -202.911) * Data.GD2HW
		enemy.is_visible = true
		units = [
			enemy,
		]
		var q := SpellRepr.new()
		q.name = "q"
		q.mana_cost = 70.0
		q.cast_duration = 0.25
		q.channelling_duration = 0
		q.cooldown_start_time = -INF
		q.cooldown_duration = 7.0
		q.is_targeted = true
		q.range = 880.0
		q.effect = func(world: MyAgent, target_i: int) -> void:
			var target := world.units[target_i]
			target.health -= 40.0
		spells = [ q ]
		return self

	func get_actions() -> Array[Callable]:
		if is_charmed: return []
		if is_dead: return [ respawn ]
		if is_moving: return [ cancel_move, finish_move, ]
		if is_attacking: return [ cancel_attack, finish_attack, ]
		if is_channeling: return [ cancel_channel, finish_channel, ]
		var res: Array[Callable] = []
		for unit_i in range(units.size()):
			var unit := units[unit_i]
			res.append(order_move.bind(unit_i, attack_range))
			if unit.team != team:
				res.append(order_attack.bind(unit_i))
				for spell_i in range(spells.size()):
					var spell := spells[spell_i]
					res.append(order_move.bind(unit_i, spell.range))
					if spell.is_targeted:
						res.append(order_cast.bind(spell_i, unit_i))
		for spell_i in range(spells.size()):
			var spell := spells[spell_i]
			if !spell.is_targeted:
				res.append(order_cast.bind(spell_i, null))
		return res
	
	func respawn() -> float:
		time += respawn_time
		mana = mana_max
		health = health_max
		position = position_spawn
		target_i = -1
		is_moving = false
		is_attacking = false
		is_channeling = false
		is_charmed = false
		return 0

	func base_action(unk_prev_world_state: Agent) -> float:
		var prev_world_state: MyAgent = unk_prev_world_state
		var time_passed := time - prev_world_state.time
		var gold_spent := maxf(0, prev_world_state.gold - gold)
		var mana_spent := maxf(0, prev_world_state.mana - mana)
		var damage_taken := maxf(0, prev_world_state.health - health)
		mana += time_passed * mana_regen_rate
		health += time_passed * health_regen_rate
		return weighted_cost(time_passed, gold_spent, mana_spent, damage_taken)

	func weighted_cost(time: float = 0.0, gold: float = 0.0, mana: float = 0.0, health: float = 0.0) -> float:
		return time * 1.3 + gold * 1 + mana * 1 + health * 2.62

	func order_move(target_i: int, target_range: float) -> float:
		var target := units[target_i]
		if !(target.position.distance_to(position) >= target_range): return INF
		is_moving = true
		self.target_i = target_i
		self.target_range = target_range
		interruptable_action_start_time = time
		return 0
	func cancel_move() -> float:
		var time_passed := time - interruptable_action_start_time
		if is_zero_approx(time_passed): return INF
		var target := units[target_i]
		var diff := target.position - position
		var dir := diff.normalized()
		position += dir * move_speed * time_passed
		is_moving = false
		return 0
	func finish_move() -> float:
		is_moving = false
		var target := units[target_i]
		var diff := target.position - position
		var dist := diff.length()
		var dir := diff.normalized()
		var travel_time := maxf(0, dist - target_range) / move_speed
		time += travel_time
		position = target.position - dir * target_range
		return 0
	
	func order_attack(target_i: int) -> float:
		var target := units[target_i]
		if !(target.is_visible && target.health > 0 && !target.invulnerable):
			return INF
		if !(target.position.distance_to(position) <= attack_range):
			return INF #TODO: return [ order_move, finish_move ]
		interruptable_action_start_time = time
		self.target_i = target_i
		is_attacking = true
		return 0
	func cancel_attack() -> float:
		var time_passed := time - interruptable_action_start_time
		if is_zero_approx(time_passed): return INF
		is_attacking = false
		return 0
	func finish_attack() -> float:
		is_attacking = false
		time += attack_interval
		var target := units[target_i]
		target.health -= attack_damage
		if target.health <= 0:
			gold += bounty
		return 0
	
	func order_cast(spell_i: int, target_i: int = -1) -> float:
		var spell := spells[spell_i]
		var target := units[target_i] if target_i != -1 else null
		if !(spell.mana_cost <= mana && (time - spell.cooldown_start_time) >= spell.cooldown_duration):
			return INF
		if !(!spell.is_targeted || target.position.distance_to(position) <= spell.range):
			return INF #TODO: return [ order_move, finish_move ]
		time += spell.cast_duration
		if spell.channelling_duration > 0:
			is_channeling = true
			self.spell_i = spell_i
			self.target_i = target_i
			interruptable_action_start_time = time
			return 0
		spell.cooldown_start_time = time
		spell.effect.call(self, target_i)
		mana -= spell.mana_cost
		return 0
	func cancel_channel() -> float:
		is_channeling = false
		var time_passed := time - interruptable_action_start_time
		var spell := spells[spell_i]
		spell.cooldown_start_time = time
		return 0
	func finish_channel() -> float:
		var spell := spells[spell_i]
		time += spell.channelling_duration
		spell.cooldown_start_time = time
		spell.effect.call(self, target_i)
		mana -= spell.mana_cost
		is_channeling = false
		return 0

class MyGoal extends GOAP.Goal:
	func get_heuristic(unk_state: Agent) -> float:
		var state: MyAgent = unk_state
		var gold_max := 100_000
		var health := 0.0
		var health_max := 0.0
		for unit in state.units:
			health += unit.health
			health_max += unit.health_max
		return state.weighted_cost(0, gold_max - state.gold, health_max - health)

func _ready() -> void:
	var planner := GOAP.new()
	var goal := MyGoal.new()
	var agent := MyAgent.new().init()
	var plan := planner.get_plan(agent, goal)
	for action in plan:
		var args := action.get_bound_arguments()
		for i in range(args.size()):
			var arg: Variant = args[i]
			if arg is MyAgent.UnitRepr\
			or arg is MyAgent.SpellRepr:
				args[i] = arg.name
		print(action.get_method(), '(', ', '.join(args), ')')
