class_name GOAP

#const MAX_NODES = 10_000
const MAX_ITER = 10_000
const UNSAFE = false

class Goal extends RefCounted:
	func is_reached(state: Agent) -> bool:
		return false
	func get_heuristic(state: Agent) -> float:
		return 0

class Clonable extends RefCounted:
	func clone() -> Clonable:
		return new().copy(self)
	func copy(from: Clonable) -> Clonable:
		return self

class Agent extends Clonable:
	func base_action(prev_world_state: Agent) -> float:
		return 0
	func get_actions() -> Array[Callable]:
		return []

class ActionAndWorldState extends RefCounted:
	var idx: int
	var prev: ActionAndWorldState
	var first: ActionAndWorldState
	var action: Callable
	var world_state: Agent
	var cost: float
	var heuristic: float

func _get_plan(agent: Agent, goal: Goal) -> ActionAndWorldState:
	var initial_state: Agent = agent
	var open_list := PriorityQueue.new()
	var anws := ActionAndWorldState.new()
	anws.idx = -1
	anws.world_state = initial_state
	anws.heuristic = goal.get_heuristic(initial_state)
	for iter in range(MAX_ITER):
		var current_state := anws.world_state
		if goal.is_reached(current_state): break
		#anws.cost += current_state.base_action()
		var actions := current_state.get_actions()
		#if actions.is_empty(): continue
		var current_state_clone: Agent
		var action_succeed := true
		for action in actions:
			if UNSAFE || action_succeed:
				current_state_clone = current_state.clone()
			var action_cost: float = Callable.create(current_state_clone, action.get_method()).bindv(action.get_bound_arguments()).call()
			var dirty_state := current_state_clone
			action_succeed = is_finite(action_cost)
			if action_succeed:
				var base_cost := dirty_state.base_action(current_state)
				var new_anws := ActionAndWorldState.new()
				new_anws.idx = anws.idx + 1
				new_anws.prev = anws
				if anws.first: new_anws.first = anws.first
				else: new_anws.first = new_anws
				new_anws.action = action
				new_anws.world_state = dirty_state
				new_anws.cost = anws.cost + action_cost + base_cost
				new_anws.heuristic = goal.get_heuristic(dirty_state)
				open_list.insert(new_anws, new_anws.cost + new_anws.heuristic)
		
		anws.world_state = null

		if open_list.is_empty(): break
		anws = open_list.extract()
	
	return anws

func get_action(agent: Agent, goal: Goal) -> Callable:
	return self._get_plan(agent, goal).first.action

func get_plan(agent: Agent, goal: Goal) -> Array[Callable]:
	var plan: Array[Callable] = []
	var anws := _get_plan(agent, goal)
	plan.resize(anws.idx + 1)
	while anws.idx >= 0:
		plan[anws.idx] = anws.action
		anws = anws.prev
	return plan
