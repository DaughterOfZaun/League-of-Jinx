class_name Spell
extends Node

@export var data: SpellData

@onready var me := (
	get_parent() #as Spells
).get_parent() as Unit #HACK:
@onready var animation_tree := me.find_child("AnimationTree") as AnimationTree
@onready var animation_root_playback := animation_tree.get("parameters/playback") as AnimationNodeStateMachinePlayback
@onready var animation_cast_playback := animation_tree.get("parameters/Cast/playback") as AnimationNodeStateMachinePlayback
@onready var animation_spell_playback := animation_tree.get("parameters/Cast/Spell/playback") as AnimationNodeStateMachinePlayback

@onready var attacker := me
@onready var caster := me
@onready var host := me # owner -> host
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

var level := 0
var level_plus_one: int:
	get:
		return level + 1

var current_cost: float
var current_cooldown: float
var current_cast_range: float
var is_attack_override: bool

var state := State.READY
enum State {
	READY,
	CASTING,
	COOLDOWN,
	CHANNELING,
}

var timer: Timer
var cancelled: bool
signal timeout_or_canceled()

func _ready() -> void:
	if Engine.is_editor_hint(): return
	timer = Timer.new()
	timer.timeout.connect(func() -> void: timeout_or_canceled.emit())
	add_child(timer)

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

func try_cast(target: Unit, pos: Vector3) -> void:
	cast(target, pos, pos)

func get_cast_time() -> float:
	return data.cast_time

func get_channel_duration() -> float:
	return data.channel_duration

func get_cast_range() -> float:
	return data.cast_range

class CastInfo:
	var target: Unit
	var target_pos: Vector3
	var targets_hit: int
	var missile: Missile

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
			pos = target.global_position
		Enums.TargetingType.TARGET:
			assert(target != null)
			pos = target.global_position
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

	var cast_time := get_cast_time()
	var channel_duration := get_channel_duration()

	var instant_cast_flag := (data.flags & Enums.SpellFlags.INSTANT_CAST) != 0
	var instant_cast := (instant_cast_flag || fire_without_casting) && !force_casting_or_channelling
	var has_cast := !instant_cast && cast_time >= 0
	var has_channel := !instant_cast && channel_duration >= 0
	instant_cast = instant_cast || (!has_cast && !has_channel)
	var has_missile := data.cast_type != Enums.CastType.INSTANT

	if (has_cast || has_channel || has_missile) && target_position != me.global_position:
		me.face_direction(target_position)

	if !data.animation_name.is_empty():
		animation_root_playback.travel("Cast")
		animation_cast_playback.travel("Spell")
		animation_spell_playback.travel(data.animation_name)

	cancelled = false

	if !cancelled && has_cast:
		state = State.CASTING
		timer.start(cast_time)
		await timeout_or_canceled

	if !cancelled && has_channel:
		state = State.CHANNELING
		timer.start(channel_duration)
		channeling_start()
		await timeout_or_canceled
		if cancelled: channeling_cancel_stop()
		else: channeling_success_stop()
		channeling_stop()

	state = State.READY
	self_execute()

	if has_missile:
		var m: Missile
		match data.cast_type:
			Enums.CastType.TARGET_MISSILE: m = SpellTargetMissile.new(self, target);
			Enums.CastType.CHAIN_MISSILE: m = SpellChainMissile.new(self, target);
			Enums.CastType.CIRCLE_MISSILE: m = SpellCircleMissile.new(self, target);
			Enums.CastType.ARC_MISSILE: m = SpellLineMissile.new(self, pos);
			_: assert(false)
		get_tree().current_scene.add_child(m)
	else:
		var targets: Array[Unit] = []
		var cast_range := get_cast_range()
		match data.targetting_type:
			Enums.TargetingType.SELF: targets = [ caster ]
			Enums.TargetingType.TARGET: targets = [ target ]
			Enums.TargetingType.AREA,\
			Enums.TargetingType.SELF_AOE: targets = API.filter_units_in_range(
				caster, caster.position, cast_range, data.flags
			)
		for subtarget in targets:
			_target_execute(subtarget, null)

var targets_hit := 0
func _target_execute(target: Unit, missile: Missile) -> void:
	targets_hit = targets_hit + 1
	caster.spell_hit.emit(target, spell)
	target.being_spell_hit.emit(caster, spell)
	target_execute(target, missile)

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
	pass

func get_cost_inc_multiplicative(par_type: Enums.PARType) -> float:
	return 0

func set_cost_inc_multiplicative(cost: float, par_type: Enums.PARType) -> void:
	pass

func set_cooldown(src: float, broadcast_event := false) -> void:
	pass

func set_tool_tip_var(index: int, value: float) -> void:
	pass

func replace_with(script: Spell) -> void:
	pass