class_name Spell extends TimerEx #@rollback

@export var data: SpellData
@export var indicator: SpellIndicator

@onready var me: Unit = (
	get_parent() #as Spells
).get_parent() #HACK:
@onready var attacker: Unit = me
@onready var caster: Unit = me
@onready var host: Unit = me # owner -> host
var vars: Vars:
	get: return me.vars
var spell: Spell = self

var target: Unit
#var offset_target: Unit
var cast_position: Vector3 = Vector3.INF
var target_position: Vector3 = Vector3.INF
var drag_end_position: Vector3 = Vector3.INF
# var targets_hit: int
var targets_hit_plus_one: int:
	get:
		return targets_hit + 1
var targeting_type: Enums.TargetingType

var slot: SpellSlot
var is_sealed: bool = false
var icon_index: int = 0
var icon: Texture2D:
	get:
		if icon_index < data.inventory_icon.size():
			return data.inventory_icon[icon_index]
		else: return null

var level: int = 0
#	get:
#		if level == 0: push_warning("level is 0")
#		return max(1, level)
#var level_plus_one: int:
#	get: return level + 1

var cost: float
var cooldown_wait_time: float:
	get: return self.wait_time if state == State.COOLDOWN else 0.0
var cooldown_time_left: float:
	get: return self.time_left if state == State.COOLDOWN else 0.0
var cast_range: float
var is_attack_override: bool

var state: State = State.READY
enum State {
	READY,
	CASTING,
	CHANNELING,
	EXECUTING,
	COOLDOWN,
}

var missile_bone_idx: int = -1

func _ready() -> void:
	#if Engine.is_editor_hint(): return

	await me.ready
	missile_bone_idx = me.get_bone_idx(data.missile_bone_name)

func _physics_process(delta: float) -> void:
	#if Engine.is_editor_hint(): return
	super._physics_process(delta)

#if Balancer.should_update_actions(self):
func _update_actions() -> void:
	if state == State.CHANNELING:
		channeling_update_actions()

#if Balancer.should_update_stats(self):
func _update_stats() -> void:
	if state == State.CHANNELING:
		channeling_update_stats()
		update_tooltip(slot)

func get_by_level(a: Array) -> float:
	return 0. if len(a) == 0 else a[clampi(level, 0, len(a) - 1)]

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
	return (data.mana_cost + get_by_level(data.mana_cost_by_level) + cost_inc) * (1.0 + cost_inc_multiplicative)

func get_chain_missile_maximum_hits() -> float:
	return data.chain_missile_maximum_hits + get_by_level(data.chain_missile_maximum_hits_by_level)

var has_missile: bool:
	get:
		match data.cast_type:
			Enums.CastType.INSTANT:
				return false
			Enums.CastType.TARGET_MISSILE,\
			Enums.CastType.CHAIN_MISSILE:
				return target != me
		return true

func can_cancel() -> bool:
	var current_spell := self
	return \
	(current_spell.state == Spell.State.CASTING && !current_spell.data.cant_cancel_while_winding_up) ||\
	(current_spell.state == Spell.State.CHANNELING && !current_spell.data.cant_cancel_while_channeling)

func can_cast_internal(target: Unit = null) -> bool:
	var status := me.status
	var data := spell.data

	if !(target == null || !target.status.is_dead): return false
	if !(!status.rooted || !data.cant_cast_while_rooted): return false
	if !(!status.suppressed || data.cannot_be_suppressed): return false

	if !(!status.disabled || data.can_cast_while_disabled): return false #FUTURE: can_only_cast_while_disabled
	if !(!status.is_dead || !data.is_disabled_while_dead || data.can_only_cast_while_dead): return false
	if !(!data.can_only_cast_while_dead || status.is_dead): return false

	#if !(!status.disarmed && status.can_attack): return false if is_auto_attack_or_override else
	if !(!status.silenced && status.can_cast): return false

	if !!spell.is_sealed: return false
	if !spell.state == Spell.State.READY: return false
	if !spell.is_enough_mana_to_cast(): return false

	if !spell.can_cast(): return false

	return true

func try_cast(target_position: Vector3, target: Unit) -> void:
	var cast_time := spell.get_cast_time()
	var channel_duration := spell.get_channel_duration()

	var instant_cast := (spell.data.flags & Enums.SpellFlags.INSTANT_CAST) != 0
	var has_cast := !instant_cast && cast_time > 0
	var has_channel := !instant_cast && channel_duration > 0
	#instant_cast = instant_cast || (!has_cast && !has_channel)
	#var has_animation := false\
	#|| !spell.data.animation_name.is_empty()\
	#|| !spell.data.animation_loop_name.is_empty()\
	#|| !spell.data.animation_winddown_name.is_empty()\
	#|| spell.data.override_force_spell_animation
	var should_cancel := has_cast || has_channel\
	|| spell.data.override_force_spell_cancel

	#TODO: check range and move into range
	if should_cancel && !me.ai.current_state.can_cancel(): return
	if !can_cast_internal(target): return
	
	if should_cancel:
		me.ai.cast_state.switch_to_self()
		me.ai.cast_state.current_spell = spell

	if should_cancel &&\
	   target_position != me.position_3d &&\
	   spell.data.targetting_type != Enums.TargetingType.SELF:
		me.face_direction(target_position)

	if !spell.data.animation_name.is_empty():
		me.animation.play(spell.data.animation_name)

	self.cancelled = false

	self.tea_target_position = target_position
	self.tea_target = target
	self.tev_has_cast = has_cast
	self.tev_cast_time = cast_time
	self.tev_has_channel = has_channel
	self.tev_channel_duration = channel_duration
	self.tev_should_cancel = should_cancel

	self.state = State.READY
	_on_timeout_or_canceled()

var tea_target_position: Vector3
var tea_target: Unit
var tev_has_cast: bool
var tev_cast_time: float
var tev_has_channel: bool
var tev_channel_duration: float
var tev_should_cancel: bool

func _on_timeout_or_canceled() -> void:
	var timer := self

	var target_position := self.tea_target_position
	var target := self.tea_target

	var has_cast := self.tev_has_cast
	var cast_time := self.tev_cast_time
	var has_channel := self.tev_has_channel
	var channel_duration := self.tev_channel_duration
	var should_cancel := self.tev_should_cancel

	match state:
		
		State.READY:
			spell.state = Spell.State.CASTING
			if !timer.cancelled && has_cast:
				timer.start(cast_time)
			else:
				_on_timeout_or_canceled()
		
		State.CASTING:
			if !timer.cancelled && has_channel:
				spell.state = Spell.State.CHANNELING
				timer.start(channel_duration)
				spell.channeling_start()
			else:
				spell.state = Spell.State.EXECUTING
				_on_timeout_or_canceled()
		
		State.CHANNELING:
			if timer.cancelled: spell.channeling_cancel_stop()
			else: spell.channeling_success_stop()
			spell.channeling_stop()
			
			spell.state = Spell.State.EXECUTING
			_on_timeout_or_canceled()
		
		State.EXECUTING:
			spell.put_on_cooldown()
			if should_cancel:
				me.ai.cast_state.current_spell = null

			if !timer.cancelled:
				var cost := maxf(0, spell.get_mana_cost())
				me.stats_perm.mana_current -= cost
				spell.cast(target, target_position)

			if should_cancel:
				if !timer.cancelled:
					me.ai.switch_to_deffered()
				else:
					me.ai.idle_state.switch_to_self()
			
		State.COOLDOWN:
			state = State.READY

func cast(
	target: Unit = null,
	pos := Vector3.INF,
	end_pos := Vector3.INF,
	override_force_level := -1,
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
		-1: #Enums.TargetingType.DRAG_DIRECTION:
			assert(pos.is_finite())
			assert(data.cast_type not in [
				Enums.CastType.TARGET_MISSILE,
				Enums.CastType.CHAIN_MISSILE,
			])
			target = null
	if data.targetting_type == -1: #Enums.TargetingType.DRAG_DIRECTION:
		assert(end_pos.is_finite())
	else:
		end_pos = Vector3.INF
	
	var cast_pos := host.position_3d
	if override_cast_pos:
		cast_pos = override_cast_pos

	if override_force_level != -1:
		level = override_force_level
	#endregion

	var cast_range_display_override := get_cast_range_display_override()
	if data.targetting_type == Enums.TargetingType.LOCATION && data.line_width > 0 && cast_range_display_override > 0: # settings.enable_line_missile_display
		pos = (pos - host.position_3d).normalized() * cast_range_display_override + host.position_3d

	self.target = target
	self.target_position = pos
	self.cast_position = cast_pos
	self.drag_end_position = end_pos
	self.targets_hit = 0

	me.spell_cast.emit(self)
	
	self_execute()

	if has_missile:
		var m: Missile
		match data.cast_type:
			Enums.CastType.TARGET_MISSILE: m = SpellTargetMissile.create(self, target)
			Enums.CastType.CHAIN_MISSILE: m = SpellChainMissile.create(self, target)
			Enums.CastType.CIRCLE_MISSILE: m = SpellCircleMissile.create(self, target, pos)
			Enums.CastType.ARC_MISSILE: m = SpellLineMissile.create(self, target, pos)
			_: assert(false)
		get_tree().current_scene.add_child(m)
	else:
		"""#TODO:
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
		"""
var targets_hit: int = 0
func _target_execute(target: Unit, missile: Missile) -> void:
	targets_hit = targets_hit + 1
	caster.spell_hit.emit(target, spell)
	target.being_spell_hit.emit(caster, spell)
	#TODO: data.apply_attack_damage
	target_execute(target, missile)

func put_on_cooldown(time_sec := get_cooldown()) -> void:
	state = State.COOLDOWN
	if !is_zero_approx(time_sec):
		self.start(time_sec)
	else:
		_on_timeout_or_canceled()

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

var cost_inc: float = 0.0
var cost_inc_multiplicative: float = 0.0
func get_cost_inc(par_type: Enums.PARType) -> float:
	return cost_inc if par_type == me.data.par_type else 0.0
func set_cost_inc(cost: float, par_type: Enums.PARType) -> void:
	if par_type == me.data.par_type: cost_inc = cost
func get_cost_inc_multiplicative(par_type: Enums.PARType) -> float:
	return cost_inc_multiplicative if par_type == me.data.par_type else 0.0
func set_cost_inc_multiplicative(cost: float, par_type: Enums.PARType) -> void:
	if par_type == me.data.par_type: cost_inc_multiplicative = cost

func set_cooldown(src: float, broadcast_event := false) -> void:
	if state == State.READY:
		put_on_cooldown(src)
	elif state == State.COOLDOWN:
		if is_zero_approx(src):
			self.cancel()
		else:
			self.start(src)
	else:
		# Should I cancel the cast/channel
		# or just use a different cooldown later?
		assert(false)

func set_tool_tip_var(index: int, value: float) -> void:
	push_warning("Spell.set_tool_tip_var is unimplemented")

func replace_with(script: Spell) -> void:
	push_warning("Spell.replace_with is unimplemented")

func is_enough_mana_to_cast() -> bool:
	return me.stats_perm.mana_current >= spell.get_mana_cost()
