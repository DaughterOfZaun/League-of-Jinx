class_name AICastState extends AIState

var current_spell: Spell = null

var timer: Timer
var cancelled := false
signal timeout_or_canceled()
func timeout_or_canceled_emit(cancelled: bool) -> void:
	self.cancelled = cancelled
	timeout_or_canceled.emit()
	cancelled = false

func _ready() -> void:
	if Engine.is_editor_hint(): return
	timer = Timer.new()
	timer.timeout.connect(func() -> void: timeout_or_canceled.emit())
	add_child(timer)

func try_enter(spell: Spell, target_position: Vector3, target: Unit) -> void:
	var cast_time := spell.get_cast_time()
	var channel_duration := spell.get_channel_duration()

	var instant_cast := (spell.data.flags & Enums.SpellFlags.INSTANT_CAST) != 0
	var has_cast := !instant_cast && cast_time > 0
	var has_channel := !instant_cast && channel_duration > 0
	instant_cast = instant_cast || (!has_cast && !has_channel)
	var has_animation := false\
	|| !spell.data.animation_name.is_empty()\
	|| !spell.data.animation_loop_name.is_empty()\
	|| !spell.data.animation_winddown_name.is_empty()\
	|| spell.data.override_force_spell_animation
	var should_cancel := has_cast || has_channel\
	|| spell.data.override_force_spell_cancel

	#TODO: check range and move into range
	if should_cancel && !current_state.can_cancel(): return
	if !can_cast(spell, target): return

	me.stats.mana_current = me.stats.mana_current - spell.get_mana_cost()

	var deffered_animation := animation_playback.get_current_node()
	var deffered_state: AIState = idle_state
	if current_state in [run_state, attack_state]:
		deffered_state = current_state

	if should_cancel:
		switch_to_self()
		if current_spell != null:
			timeout_or_canceled_emit(true)
			current_spell.put_on_cooldown()
		current_spell = spell

	if should_cancel && target_position != me.position_3d:
		me.face_direction(target_position)

	var animation_changed := false
	if !spell.data.animation_name.is_empty():
		animation_playback.travel(spell.data.animation_name)
		animation_changed = true

	if !cancelled && has_cast:
		spell.state = Spell.State.CASTING
		timer.start(cast_time)
		await timeout_or_canceled

	if !cancelled && has_channel:
		spell.state = Spell.State.CHANNELING
		timer.start(channel_duration)
		spell.channeling_start()
		await timeout_or_canceled
		if cancelled: spell.channeling_cancel_stop()
		else: spell.channeling_success_stop()
		spell.channeling_stop()

	if !cancelled:
		spell.state = Spell.State.EXECUTING
		spell.cast(target, target_position)
		if should_cancel:
			current_spell.put_on_cooldown()
			current_spell = null
			match deffered_state: #TODO: try_enter_again
				run_state: run_state.try_enter()
				idle_state: idle_state.try_enter()
				attack_state: attack_state.try_enter()
			deffered_state = null
		elif animation_changed:
			animation_playback.travel(deffered_animation)

func can_cancel() -> bool:
	return (
		current_spell == null ||
		(current_spell.state == Spell.State.CASTING && !current_spell.data.cant_cancel_while_winding_up) ||
		(current_spell.state == Spell.State.CHANNELING && !current_spell.data.cant_cancel_while_channeling)
	)

func can_cast(spell: Spell, target: Unit = null) -> bool:
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
	if !me.stats.mana_current >= spell.get_mana_cost(): return false

	if !spell.can_cast(): return false

	return true
