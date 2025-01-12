class_name GOAP

#const MAX_NODES = 10_000
const MAX_ITER = 10_000
const UNSAFE = false

class Goal:
    func is_reached(state: WorldState) -> bool:
        return false
    func get_heuristic(state: WorldState) -> float:
        return 0

class Action:
    func execute(state: WorldState) -> float:
        return 0

class WorldState:
    func clone() -> WorldState:
        return new()
    func copy(from: WorldState) -> WorldState:
        return self

class ActionAndWorldState:
    var idx: int
    var prev: ActionAndWorldState
    var first: ActionAndWorldState
    var action: Action
    var world_state: WorldState
    var cost: float
    var heuristic: float

class Agent:
    func get_actions(state: WorldState) -> Array[Action]:
        return []

func _get_plan(agent: Agent, initial_state: WorldState, goal: Goal) -> ActionAndWorldState:
    var open_list := PriorityQueue.new()
    var anws := ActionAndWorldState.new()
    anws.idx = -1
    anws.world_state = initial_state
    anws.heuristic = goal.get_heuristic(initial_state)
    for iter in range(MAX_ITER):
        var current_state: WorldState = anws.world_state
        if goal.is_reached(current_state): break
        var actions := agent.get_actions(current_state)
        #if actions.is_empty(): continue
        var current_state_clone: WorldState
        var action_succeed := true
        for action in actions:
            if UNSAFE || action_succeed:
                current_state_clone = current_state.clone().copy(current_state)
            var action_cost := action.execute(current_state_clone)
            var dirty_state := current_state_clone
            action_succeed = is_finite(action_cost)
            if action_succeed:
                var new_anws := ActionAndWorldState.new()
                new_anws.idx = anws.idx + 1
                new_anws.prev = anws
                if anws.first: new_anws.first = anws.first
                else: new_anws.first = new_anws
                new_anws.action = action
                new_anws.world_state = dirty_state
                new_anws.cost = anws.cost + action_cost
                new_anws.heuristic = goal.get_heuristic(dirty_state)
                open_list.insert(anws, new_anws.cost + new_anws.heuristic)
        
        if open_list.is_empty(): break
        anws = open_list.extract()
    
    return anws

func get_action(agent: Agent, initial_state: WorldState, goal: Goal) -> Action:
    return self._get_plan(agent, initial_state, goal).first.action

func get_plan(agent: Agent, initial_state: WorldState, goal: Goal) -> Array[Action]:
    var plan: Array[Action] = []
    var anws := _get_plan(agent, initial_state, goal)
    plan.resize(anws.idx + 1)
    for i in range(anws.idx + 1):
        plan[i] = anws.action
        anws = anws.prev
    return plan