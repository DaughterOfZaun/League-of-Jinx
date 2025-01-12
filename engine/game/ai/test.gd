class_name Test extends Node

class MyAgent extends GOAP.Agent:
	
	var time := 0.0
	
	var exp := 0.0
	var level := 1
	var gold := 0.0
	var mana_initial := 115.0
	var mana := mana_initial
	var health_initial := 380.0
	var health := health_initial
	var respawn_time := 10.0
	var bounty := 300.0
	var attack_damage := 50.0
	var attack_interval := 1.6
	var attack_range := 625.0

	var position_initial := Vector3(0.746, 2.485, -3.787) * Data.GD2HW
	var position := position_initial
	
	var team := Enums.Team.ORDER
	
	var target: UnitRepr
	var units: Array[UnitRepr]
	class UnitRepr extends GOAP.Clonable:
		var team: Enums.Team
		var health: float
		var position: Vector3
		var invulnerable: bool
		var is_charmed: bool
		var is_visible: bool
		func copy(unk: Clonable) -> UnitRepr:
			var from: UnitRepr = unk
			team = from.team
			health = from.health
			position = from.position
			invulnerable = from.invulnerable
			is_charmed = from.is_charmed
			is_visible = from.is_visible
			return self
	
	var spell: SpellRepr
	var spells: Array[SpellRepr]
	class SpellRepr extends EffectRepr:
		var mana_cost: float
		var channelling_duration: float
		var cooldown_time: float
		var last_cast_time: float
		var is_targeted: bool
		var range: float
		func copy(unk: Clonable) -> SpellRepr:
			var from: SpellRepr = unk
			mana_cost = from.mana_cost
			channelling_duration = from.channelling_duration
			cooldown_time = from.cooldown_time
			last_cast_time = from.last_cast_time
			is_targeted = from.is_targeted
			range = from.range
			super.copy(unk)
			return self
	class EffectRepr extends GOAP.Clonable:
		var effect: Callable
		var effect_delay: float
		func copy(unk: Clonable) -> EffectRepr:
			var from: SpellRepr = unk
			effect = from.effect
			effect_delay = from.effect_delay
			return self

	var is_dead: bool:
		get: return health <= 0

	var interruptable_action_start_time: float
	var is_moving := false
	var is_attacking := false
	var is_channeling := false
	var is_charmed := false
	
	#var delayed_effects: Array[DelayedEffectRepr]
	class DelayedEffectRepr extends GOAP.Clonable:
		var start_time: float
		var effect: EffectRepr
		func copy(unk: Clonable) -> DelayedEffectRepr:
			var from: DelayedEffectRepr = unk
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

	func copy(unk: Clonable) -> MyAgent:
		var from: MyAgent = unk
		time = from.time
		exp = from.exp
		level = from.level
		gold = from.gold
		mana_initial = from.mana_initial
		mana = from.mana
		health_initial = from.health_initial
		health = from.health
		respawn_time = from.respawn_time
		bounty = from.bounty
		attack_damage = from.attack_damage
		attack_interval = from.attack_interval
		attack_range = from.attack_range
		position_initial = from.position_initial
		position = from.position
		team = from.team
		units = clone_array(from.units)
		target = self.units[from.units.find(from.target)] if from.target != null else null
		spells = clone_array(from.spells)
		spell = self.spells[from.spells.find(from.spell)] if from.spell != null else null
		is_dead = from.is_dead
		interruptable_action_start_time = from.interruptable_action_start_time
		is_moving = from.is_moving
		is_attacking = from.is_attacking
		is_channeling = from.is_channeling
		is_charmed = from.is_charmed
		#delayed_effects = clone_array(from.delayed_effects)
		return self

	func init() -> Agent:
		var enemy := UnitRepr.new()
		enemy.team = Enums.Team.CHAOS
		enemy.health = health_initial
		enemy.position = Vector3(199.472, 2.485, -202.911) * Data.GD2HW
		enemy.is_visible = true
		units = [
			enemy,
		]
		spells = []
		return self
	
	func get_actions() -> Array[Callable]:
		#print('get_actions')
		if is_charmed: return []
		if is_dead: return [ respawn ]
		if is_moving: return [ cancel_move, finish_move, ]
		if is_attacking: return [ cancel_attack, finish_attack, ]
		if is_channeling: return [ cancel_channel, finish_channel, ]
		var res: Array[Callable] = []
		for unit in units:
			res.append(order_move.bind(unit))
			if unit.team != team:
				res.append(order_attack.bind(unit))
				for spell in spells:
					if spell.is_targeted:
						res.append(order_cast.bind(spell, unit))
		for spell in spells:
			if !spell.is_targeted:
				res.append(order_cast.bind(spell, null))
		return res
	
	func respawn() -> float:
		#print('respawn')
		time += respawn_time
		mana = mana_initial
		health = health_initial
		position = position_initial
		target = null
		is_moving = false
		is_attacking = false
		is_channeling = false
		is_charmed = false
		return 0

	func weighted_cost(time := 0.0, gold := 0.0, mana := 0.0, health := 0.0) -> float:
		return time * 1.3 + gold * 1 + mana * 1 + health * 2.62

	func order_move(target: UnitRepr) -> float:
		#print('order_move')
		if target.position.distance_to(position) < 1: return INF
		is_moving = true
		self.target = target
		interruptable_action_start_time = time
		return 0
	func cancel_move() -> float:
		#print('cancel_move')
		var time_passed := time - interruptable_action_start_time
		if is_zero_approx(time_passed): return INF
		is_moving = false
		return weighted_cost(time_passed)
	func finish_move() -> float:
		#print('finish_move')
		is_moving = false
		var travel_time := 60.0
		time += travel_time
		position = target.position
		return weighted_cost(travel_time)
	
	func order_attack(target: UnitRepr) -> float:
		#print('order_attack')
		if !(target.is_visible && target.health > 0 && !target.invulnerable):
			return INF
		if !(target.position.distance_to(position) <= attack_range):
			return INF #TODO: return [ order_move, finish_move ]
		interruptable_action_start_time = time
		self.target = target
		is_attacking = true
		return 0
	func cancel_attack() -> float:
		#print('cancel_attack')
		var time_passed := time - interruptable_action_start_time
		if is_zero_approx(time_passed): return INF
		is_attacking = false
		return weighted_cost(time_passed)
	func finish_attack() -> float:
		#print('finish_attack')
		is_attacking = false
		time += attack_interval
		target.health -= attack_damage
		if target.health <= 0:
			gold += bounty
		return weighted_cost(attack_interval)
	
	func order_cast(spell: SpellRepr, target: UnitRepr = null) -> float:
		#print('order_cast')
		if target != null && target.position.distance_to(position) > spell.range:
			return INF #TODO: return [ order_move, finish_move ]
		if spell.channelling_duration > 0:
			is_channeling = true
			self.spell = spell
			self.target = target
			interruptable_action_start_time = time
			return 0
		spell.effect.call(target)
		return weighted_cost(spell.mana_cost)
	func cancel_channel() -> float:
		#print('cancel_channel')
		is_channeling = false
		var time_passed := time - interruptable_action_start_time
		return weighted_cost(time_passed)
	func finish_channel() -> float:
		#print('finish_channel')
		time += spell.channelling_duration
		mana -= spell.mana_cost
		is_channeling = false
		return weighted_cost(spell.channelling_duration, 0, spell.mana_cost)

class EarnGold extends GOAP.Goal:
	var max_gold := 100_000
	func get_heuristic(unk_state: Agent) -> float:
		var state: MyAgent = unk_state
		return max_gold - state.gold

class DoDamage extends GOAP.Goal:
	func get_heuristic(unk_state: Agent) -> float:
		return 0

func _ready() -> void:
	var planner := GOAP.new()
	var goal := EarnGold.new()
	var agent := MyAgent.new().init()
	var plan := planner.get_plan(agent, goal)
	print(plan)
