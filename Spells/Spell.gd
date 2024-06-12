class_name Spell
extends SpellData

var attacker: Unit
var caster: Unit
var host: Unit
var spell := self

var target: Unit
var offset_target: Unit
var target_position := Vector3.INF
var drag_end_position: Vector3
var targets_hit: int
var targets_hit_plus_one:
	get:
		return targets_hit + 1
var targeting_type: Enums.TargetingType

var slot: SpellSlot
var is_sealed := false
var icon_index := 0

var level := 0
var level_plus_one:
	get:
		return level + 1

var cost: float
var cooldown: float # <- current
var cast_range: float
var is_attack_override: bool

var state := State.READY
enum State {
	READY,
	CASTING,
	COOLDOWN,
	CHANNELING,
}

func _ready():
	host = (get_parent() as Spells).get_parent() as Unit #HACK
	host.update_actions.connect(on_update_actions)
	host.update_stats.connect(on_update_stats)
	attacker = host
	caster = host

func on_update_stats():
	if state == State.CHANNELING:
		channeling_update_stats()
		update_tooltip(slot)

func on_update_actions():
	if state == State.CHANNELING:
		channeling_update_actions()

func self_execute(): pass
func target_execute(_target: Unit, _missile: Missile): pass
func adjust_cast_info(): pass
func adjust_cooldown():
	return NAN
func can_cast():
	return true
func channeling_start(): pass
func channeling_cancel_stop(): pass
func channeling_success_stop(): pass
func channeling_stop(): pass
func channeling_update_stats(): pass
func channeling_update_actions(): pass
func update_tooltip(_slot: SpellSlot): pass

func on_missile_update(_missile: Missile): pass
func on_missile_end(_missile: Missile): pass

func get_cost_inc(par_type: Enums.PARType) -> float:
	return 0

func set_cost_inc(cost: float, par_type: Enums.PARType) -> void:
	pass

func get_cost_inc_multiplicative(par_type: Enums.PARType) -> float:
	return 0

func set_cost_inc_multiplicative(cost: float, par_type: Enums.PARType) -> void:
	pass

func set_cooldown(src: float, broadcast_event := false) -> void:
	pass

func set_tool_tip_var(index: int, value: float) -> void:
	pass

func replace_with(script) -> void:
	pass

func cast(
	target: Unit,
	pos: Vector3,
	end_pos: Vector3,
	override_force_level := 0,
	override_cool_down_check := false,
	fire_without_casting := false,
	use_auto_attack_spell := false,
	force_casting_or_channelling := false,
	update_auto_attack_timer := false,
	override_cast_position := false,
	override_cast_pos: Vector3 = Vector3.INF
) -> void:
	pass
