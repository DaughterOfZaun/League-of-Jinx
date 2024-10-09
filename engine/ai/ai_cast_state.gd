class_name AICastState
extends AIState

var spell: Spell = null
var data: SpellData:
	get: return spell.data
func get_cast_time() -> float: return spell.get_cast_time()
func get_channel_duration() -> float: return spell.get_channel_duration()
func channeling_start() -> void: spell.channeling_start()
func channeling_cancel_stop() -> void: spell.channeling_cancel_stop()
func channeling_success_stop() -> void: spell.channeling_success_stop()
func channeling_stop() -> void: spell.channeling_stop()

var timer: Timer
var cancelled: bool
signal timeout_or_canceled()

func _ready() -> void:
	if Engine.is_editor_hint(): return
	timer = Timer.new()
	timer.timeout.connect(func() -> void: timeout_or_canceled.emit())
	add_child(timer)

func enter(spell: Spell, target_position: Vector3, target: Unit) -> void:
	var cast_time := get_cast_time()
	var channel_duration := get_channel_duration()

	var instant_cast := (data.flags & Enums.SpellFlags.INSTANT_CAST) != 0
	var has_cast := !instant_cast && cast_time >= 0
	var has_channel := !instant_cast && channel_duration >= 0
	instant_cast = instant_cast || (!has_cast && !has_channel)
	var has_animation := false\
	|| !data.animation_name.is_empty()\
	|| !data.animation_loop_name.is_empty()\
	|| !data.animation_winddown_name.is_empty()\
	|| data.override_force_spell_animation
	var should_cancel := has_cast || has_channel\
	|| data.override_force_spell_cancel

	#TODO: check range and move into range
	if !can_cast(spell, target, should_cancel): return

	me.stats.mana_current = me.stats.mana_current - spell.get_mana_cost()

	if should_cancel:
		#TODO: cancel & switch state
		self.spell = spell

	if should_cancel && target_position != me.global_position:
		me.face_direction(target_position)

	if !data.animation_name.is_empty():
		animation_root_playback.travel("Cast")
		animation_cast_playback.travel("Spell")
		animation_spell_playback.travel(data.animation_name)

	var cancelled := false

	if !cancelled && has_cast:
		spell.state = Spell.State.CASTING
		timer.start(cast_time)
		await timeout_or_canceled

	if !cancelled && has_channel:
		spell.state = Spell.State.CHANNELING
		timer.start(channel_duration)
		channeling_start()
		await timeout_or_canceled
		if cancelled: channeling_cancel_stop()
		else: channeling_success_stop()
		channeling_stop()

	if !cancelled:
		spell.state = Spell.State.EXECUTING
		spell.cast(target, target_position)

func can_cast(spell: Spell, target: Unit = null, should_cancel := false) -> bool:
	var status := me.status
	var data := spell.data
	return (
		(target == null || !target.status.is_dead) &&
		(!status.rooted || !data.cant_cast_while_rooted) &&
		(!status.suppressed || data.cannot_be_suppressed) &&

		(!status.disabled || data.can_cast_while_disabled) && #FUTURE: can_only_cast_while_disabled
		(!status.is_dead || !data.is_disabled_while_dead || data.can_only_cast_while_dead) &&
		(!data.can_only_cast_while_dead || status.is_dead) &&

		#(!status.disarmed && status.can_attack) if is_auto_attack_or_override else
		(!status.silenced && status.can_cast) &&

		!spell.is_sealed &&
		spell.state == Spell.State.READY &&
		me.stats.mana_current >= spell.get_mana_cost() && (
			self.spell == null || !should_cancel ||
			(self.spell.state == Spell.State.CASTING && !data.cant_cancel_while_winding_up) ||
			(self.spell.state == Spell.State.CHANNELING && !data.cant_cancel_while_channeling)
		) &&

		spell.can_cast()
	)
