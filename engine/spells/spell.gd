class_name Spell extends Node

@export var data: SpellData

@onready var me := (
	get_parent() #as Spells
).get_parent() as Unit #HACK:
@onready var attacker := me
@onready var caster := me
@onready var host := me # owner -> host
@onready var vars := me.vars
var spell := self

var target: Unit
#var offset_target: Unit
var cast_position := Vector3.INF
var target_position := Vector3.INF
var drag_end_position := Vector3.INF
# var targets_hit: int
var targets_hit_plus_one: int:
	get:
		return targets_hit + 1
var targeting_type: Enums.TargetingType

var slot: SpellSlot
var is_sealed := false
var icon_index := 0
var icon: Texture2D:
	get:
		#if icon_index < len(data.inventory_icon):
		return data.inventory_icon[icon_index]
		#else: return null

var level := 0
var level_plus_one: int:
	get:
		return level + 1

var cost: float
var cooldown_wait_time: float:
	get: return timer.wait_time if state == State.COOLDOWN else 0.0
var cooldown_time_left: float:
	get: return timer.time_left if state == State.COOLDOWN else 0.0
var cast_range: float
var is_attack_override: bool

var state := State.READY
enum State {
	READY,
	CASTING,
	CHANNELING,
	EXECUTING,
	COOLDOWN,
}

var timer := Timer.new()
signal timeout_or_canceled()

var missile_bone_idx := -1

func _ready() -> void:
	if Engine.is_editor_hint(): return

	timer.timeout.connect(func() -> void: timeout_or_canceled.emit())
	add_child(timer)

	await me.ready
	missile_bone_idx = me.skeleton.find_bone(data.missile_bone_name.replace("_CSTM_", "_GLB_"))

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return

	if host.should_update_actions:
		on_update_actions()
	if host.should_update_stats:
		on_update_stats()

func on_update_stats() -> void:
	if state == State.CHANNELING:
		channeling_update_stats()
		update_tooltip(slot)

func on_update_actions() -> void:
	if state == State.CHANNELING:
		channeling_update_actions()

func get_by_level(a: Array) -> float:
	return 0. if len(a) == 0 else a[clampi(0, len(a) - 1, level)]

func get_cooldown() -> float:
	return data.cooldown + get_by_level(data.cooldown_by_level)

func get_location_targetting_width() -> float:
	return data.location_targetting_width + get_by_level(data.location_targetting_width_by_level)

func get_location_targetting_length() -> float:
	return data.location_targetting_length + get_by_level(data.location_targetting_length_by_level)

func get_cast_range() -> float:
	return data.cast_range + get_by_level(data.cast_range_by_level)

func get_cast_range_display_override() -> float:
	return data.cast_range_display_override + get_by_level(data.cast_range_display_override_by_level)

func get_cast_time() -> float:
	return data.override_cast_time if data.override_cast_time > 0 else data.cast_time

func get_channel_duration() -> float:
	return data.channel_duration + get_by_level(data.channel_duration_by_level)

func get_mana_cost() -> float:
	return data.mana_cost + get_by_level(data.mana_cost_by_level)

func get_chain_missile_maximum_hits() -> float:
	return data.chain_missile_maximum_hits + get_by_level(data.chain_missile_maximum_hits_by_level)

class CastInfo:
	var target: Unit
	var target_pos: Vector3
	var targets_hit: int
	var missile: Missile

var has_missile: bool:
	get:
		match data.cast_type:
			Enums.CastType.INSTANT:
				return false
			Enums.CastType.TARGET_MISSILE,\
			Enums.CastType.CHAIN_MISSILE:
				return target != me
		return true

func cast(
	target: Unit = null,
	pos := Vector3.INF,
	end_pos := Vector3.INF,
	override_force_level := 0,
	override_cool_down_check := false,
	fire_without_casting := false,
	use_auto_attack_spell := false,
	force_casting_or_channelling := false,
	update_auto_attack_timer := false,
	override_cast_position := false,
	override_cast_pos := Vector3.INF
) -> void:

	#region process params
	match data.targetting_type:
		Enums.TargetingType.SELF,\
		Enums.TargetingType.SELF_AOE:
			target = caster
			pos = target.position_3d
		Enums.TargetingType.TARGET:
			assert(target != null)
			pos = target.position_3d
		Enums.TargetingType.AREA,\
		Enums.TargetingType.CONE,\
		Enums.TargetingType.LOCATION,\
		Enums.TargetingType.DIRECTION,\
		Enums.TargetingType.DRAG_DIRECTION:
			assert(pos.is_finite())
			assert(data.cast_type not in [
				Enums.CastType.TARGET_MISSILE,
				Enums.CastType.CHAIN_MISSILE,
			])
			target = null
	if data.targetting_type == Enums.TargetingType.DRAG_DIRECTION:
		assert(end_pos.is_finite())
	else:
		end_pos = Vector3.INF
	var cast_pos := override_cast_pos if override_cast_position else pos
	#endregion

	self.target = target
	self.target_position = pos
	self.cast_position = cast_pos
	self.drag_end_position = end_pos
	self.targets_hit = 0

	state = State.READY
	self_execute()

	if has_missile:
		var m: Missile
		match data.cast_type:
			Enums.CastType.TARGET_MISSILE: m = SpellTargetMissile.new(self, target)
			Enums.CastType.CHAIN_MISSILE: m = SpellChainMissile.new(self, target)
			Enums.CastType.CIRCLE_MISSILE: m = SpellCircleMissile.new(self, target, pos)
			Enums.CastType.ARC_MISSILE: m = SpellLineMissile.new(self, target, pos)
			_: assert(false)
		get_tree().current_scene.add_child(m)
	else:
		var targets: Array[Unit] = []
		var cast_range := get_cast_range()
		match data.targetting_type:
			Enums.TargetingType.SELF: targets = [ caster ]
			Enums.TargetingType.TARGET: targets = [ target ]
			Enums.TargetingType.AREA,\
			Enums.TargetingType.SELF_AOE: targets = API.get_units_in_area(
				caster, caster.position_3d, cast_range, data.flags
			)
		for subtarget in targets:
			_target_execute(subtarget, null)

var targets_hit := 0
func _target_execute(target: Unit, missile: Missile) -> void:
	targets_hit = targets_hit + 1
	caster.spell_hit.emit(target, spell)
	target.being_spell_hit.emit(caster, spell)
	target_execute(target, missile)

func put_on_cooldown() -> void:
	state = State.COOLDOWN
	timer.start(get_cooldown())
	await timeout_or_canceled
	state = State.READY

func self_execute() -> void: pass
func target_execute(_target: Unit, _missile: Missile) -> void: pass
func adjust_cast_info() -> void: pass
func adjust_cooldown() -> float:
	return NAN
func can_cast() -> bool:
	return true
func channeling_start() -> void: pass
func channeling_cancel_stop() -> void: pass
func channeling_success_stop() -> void: pass
func channeling_stop() -> void: pass
func channeling_update_stats() -> void: pass
func channeling_update_actions() -> void: pass
func update_tooltip(_slot: SpellSlot) -> void: pass

func on_missile_update(_missile: Missile) -> void: pass
func on_missile_end(_missile: Missile) -> void: pass

func get_cost_inc(par_type: Enums.PARType) -> float:
	return 0

func set_cost_inc(cost: float, par_type: Enums.PARType) -> void:
	push_warning("Spell.set_cost_inc is unimplemented")

func get_cost_inc_multiplicative(par_type: Enums.PARType) -> float:
	push_warning("Spell.get_cost_inc_multiplicative is unimplemented")
	return 0

func set_cost_inc_multiplicative(cost: float, par_type: Enums.PARType) -> void:
	push_warning("Spell.set_cost_inc_multiplicative is unimplemented")

func set_cooldown(src: float, broadcast_event := false) -> void:
	push_warning("Spell.set_cooldown is unimplemented")

func set_tool_tip_var(index: int, value: float) -> void:
	push_warning("Spell.set_tool_tip_var is unimplemented")

func replace_with(script: Spell) -> void:
	push_warning("Spell.replace_with is unimplemented")
