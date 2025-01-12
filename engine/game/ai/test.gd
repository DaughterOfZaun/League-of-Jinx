extends Node

class UnitRepr:
    var health: float
    var position: Vector3
    var team: Enums.Team

func weighted_cost(time: float, gold: float, mana: float, health: float) -> float:
    return time * 1.3 + gold * 1 + mana * 1 + health * 2.62

class MyWorldState extends GOAP.WorldState:
    var time: float
    var gold: float
    var mana: float
    var health: float
    var position: Vector3
    var team: Enums.Team
    var units: Array[UnitRepr]
    var is_channeling: bool
    func copy(from: GOAP.WorldState) -> WorldState:
       return self

class MyAgent extends GOAP.Agent:
    func get_actions(unk_state: WorldState) -> Array[Action]:
        var state: MyWorldState = unk_state
        return []

class EarnGold extends GOAP.Goal:
    var max_gold := 100_000
    func is_reached(unk_state: WorldState) -> bool:
        var state: MyWorldState = unk_state
        return state.gold - max_gold

class OrderMove extends GOAP.Action:
    var target: Unit
    func execute(unk_state: WorldState) -> float:
        var state: MyWorldState = unk_state
        return 0

class OrderAttack extends GOAP.Action:
    var target: Unit
    func execute(unk_state: WorldState) -> float:
        var state: MyWorldState = unk_state
        return 0

class BeginChanneling extends GOAP.Action:
    func execute(unk_state: WorldState) -> float:
        var state: MyWorldState = unk_state
        return 0

class CancelChanneling extends GOAP.Action:
    func execute(unk_state: WorldState) -> float:
        var state: MyWorldState = unk_state
        state.is_channeling = false
        return 0

class FinishChanneling extends GOAP.Action:
    func execute(unk_state: WorldState) -> float:
        var state: MyWorldState = unk_state
        return 0

func _ready() -> void:
    var agent := MyAgent.new()
    var state := MyWorldState.new()
    state.gold = 0
    state.mana = 115.0
    state.health = 380.0
    var goal := EarnGold.new()
    var planner := GOAP.new()
    var plan := planner.get_plan(agent, state, goal)
