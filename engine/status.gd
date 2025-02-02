class_name Status extends Node #@rollback

var null_callable: Callable = func() -> void: pass

@onready var me: Unit = get_parent()
func _ready() -> void:
	#if Engine.is_editor_hint(): return
	me.status = self

func set_ref(ref_count: int, value: bool) -> int:
	return max(0, ref_count + int(value) * 2 - 1)

#var can_move_ever := true
#var lifesteal_immune := false

var _can_attack_ref_count: int = 0
var can_attack := true:
	get: return _can_attack_ref_count == 0
	set(value): _can_attack_ref_count =\
	set_ref(_can_attack_ref_count, !value)

var _can_cast_ref_count: int = 0
var can_cast := true:
	get: return _can_cast_ref_count == 0
	set(value): _can_cast_ref_count =\
	set_ref(_can_cast_ref_count, !value)

var _can_move_ref_count: int = 0
var can_move := true:
	get: return _can_move_ref_count == 0
	set(value): _can_move_ref_count =\
	set_ref(_can_move_ref_count, !value)

var _targetable_ref_count: int = 0
var targetable := true:
	get: return _targetable_ref_count == 0
	set(value): _targetable_ref_count =\
	set_ref(_targetable_ref_count, !value)

var _call_for_help_suppresser_ref_count: int = 0
var call_for_help_suppresser := false:
	get: return _call_for_help_suppresser_ref_count > 0
	set(value): _call_for_help_suppresser_ref_count =\
	set_ref(_call_for_help_suppresser_ref_count, value)

var _disable_ambient_gold_ref_count: int = 0
var disable_ambient_gold := false:
	get: return _disable_ambient_gold_ref_count > 0
	set(value): _disable_ambient_gold_ref_count =\
	set_ref(_disable_ambient_gold_ref_count, value)

var _disarmed_ref_count: int = 0
var disarmed := false:
	get: return _disarmed_ref_count > 0
	set(value): _disarmed_ref_count =\
	set_ref(_disarmed_ref_count, value)

var _force_render_particles_ref_count: int = 0
var force_render_particles := false:
	get: return _force_render_particles_ref_count > 0
	set(value): _force_render_particles_ref_count =\
	set_ref(_force_render_particles_ref_count, value)

var _ghosted_ref_count: int = 0
var ghosted := false:
	get: return _ghosted_ref_count > 0
	set(value): _ghosted_ref_count =\
	set_ref(_ghosted_ref_count, value)

var _ghost_proof_ref_count: int = 0
var ghost_proof := false:
	get: return _ghost_proof_ref_count > 0
	set(value): _ghost_proof_ref_count =\
	set_ref(_ghost_proof_ref_count, value)

var _ignore_call_for_help_ref_count: int = 0
var ignore_call_for_help := false:
	get: return _ignore_call_for_help_ref_count > 0
	set(value): _ignore_call_for_help_ref_count =\
	set_ref(_ignore_call_for_help_ref_count, value)

var _immovable_ref_count: int = 0
var immovable := false:
	get: return _immovable_ref_count > 0
	set(value): _immovable_ref_count =\
	set_ref(_immovable_ref_count, value)

var _invulnerable_ref_count: int = 0
var invulnerable := false:
	get: return _invulnerable_ref_count > 0
	set(value): _invulnerable_ref_count =\
	set_ref(_invulnerable_ref_count, value)

var _magic_immune_ref_count: int = 0
var magic_immune := false:
	get: return _magic_immune_ref_count > 0
	set(value): _magic_immune_ref_count =\
	set_ref(_magic_immune_ref_count, value)

var _near_sight_ref_count: int = 0
var near_sight := false:
	get: return _near_sight_ref_count > 0
	set(value): _near_sight_ref_count =\
	set_ref(_near_sight_ref_count, value)

var _netted_ref_count: int = 0
var netted := false:
	get: return _netted_ref_count > 0
	set(value): _netted_ref_count =\
	set_ref(_netted_ref_count, value)

var _no_render_ref_count: int = 0
var no_render := false:
	get: return _no_render_ref_count > 0
	set(value): _no_render_ref_count =\
	set_ref(_no_render_ref_count, value)

var _pacified_ref_count: int = 0
var pacified := false:
	get: return _pacified_ref_count > 0
	set(value): _pacified_ref_count =\
	set_ref(_pacified_ref_count, value)

var _physical_immune_ref_count: int = 0
var physical_immune := false:
	get: return _physical_immune_ref_count > 0
	set(value): _physical_immune_ref_count =\
	set_ref(_physical_immune_ref_count, value)

var _reveal_specific_unit_ref_count: int = 0
var reveal_specific_unit := false:
	get: return _reveal_specific_unit_ref_count > 0
	set(value): _reveal_specific_unit_ref_count =\
	set_ref(_reveal_specific_unit_ref_count, value)

var _rooted_ref_count: int = 0
var rooted := false:
	get: return _rooted_ref_count > 0
	set(value): _rooted_ref_count =\
	set_ref(_rooted_ref_count, value)

var _silenced_ref_count: int = 0
var silenced := false:
	get: return _silenced_ref_count > 0
	set(value): _silenced_ref_count =\
	set_ref(_silenced_ref_count, value)

var _sleep_ref_count: int = 0
var sleep := false:
	get: return _sleep_ref_count > 0
	set(value): _sleep_ref_count =\
	set_ref(_sleep_ref_count, value)

var _stealthed_ref_count: int = 0
var stealthed := false:
	get: return _stealthed_ref_count > 0
	set(value): _stealthed_ref_count =\
	set_ref(_stealthed_ref_count, value)

var _stunned_ref_count: int = 0
var stunned := false:
	get: return _stunned_ref_count > 0
	set(value): _stunned_ref_count =\
	set_ref(_stunned_ref_count, value)

var _suppress_call_for_help_ref_count: int = 0
var suppress_call_for_help := false:
	get: return _suppress_call_for_help_ref_count > 0
	set(value): _suppress_call_for_help_ref_count =\
	set_ref(_suppress_call_for_help_ref_count, value)

var _suppressed_ref_count: int = 0
var suppressed := false:
	get: return _suppressed_ref_count > 0
	set(value): _suppressed_ref_count =\
	set_ref(_suppressed_ref_count, value)

var is_dead: bool = false
var is_zombie: bool = false
var is_clone: bool = false
var is_moving: bool

var targetable_to_team: Dictionary[Enums.Team, bool] = {
	Enums.Team.ORDER: true,
	Enums.Team.CHAOS: true,
	Enums.Team.NEUTRAL: true,
}
func set_not_targetable_to_team(to: bool, team: Enums.Team) -> void:
	targetable_to_team[team] = !to

var disabled: bool:
	get:
		var status := self
		return false\
		|| status.charmed\
		|| status.feared\
		|| status.pacified\
		|| status.silenced\
		|| status.sleep\
		|| status.stunned\
		|| status.suppressed\
		|| status.taunted

var taunted_ref_count: int = 0
var on_taunt_begin: Callable:
	get: return me.ai.on_taunt_begin if me.ai != null else null_callable
var on_taunt_end: Callable:
	get: return me.ai.on_taunt_end if me.ai != null else null_callable
var taunted: bool:
	get: return taunted_ref_count > 0
	set(value): taunted_ref_count =\
	set_ref_and_call(
		taunted_ref_count, value,
		on_taunt_begin, on_taunt_end,
	)

var feared_ref_count: int = 0
var on_fear_begin: Callable:
	get: return me.ai.on_fear_begin if me.ai != null else null_callable
var on_fear_end: Callable:
	get: return me.ai.on_fear_end if me.ai != null else null_callable
var feared: bool:
	get: return feared_ref_count > 0
	set(value): feared_ref_count =\
	set_ref_and_call(
		feared_ref_count, value,
		on_fear_begin, on_fear_end,
	)

var charmed_ref_count: int = 0
var on_charm_begin: Callable:
	get: return me.ai.on_charm_begin if me.ai != null else null_callable
var on_charm_end: Callable:
	get: return me.ai.on_charm_end if me.ai != null else null_callable
var charmed: bool:
	get: return charmed_ref_count > 0
	set(value): charmed_ref_count =\
	set_ref_and_call(
		charmed_ref_count, value,
		on_charm_begin, on_charm_end,
	)

func set_ref_and_call(ref_count: int, value: bool, on_begin: Callable, on_end: Callable) -> int:
	if value:
		ref_count += 1
		#if charmed_ref_count == 1:
		on_begin.call()
	elif ref_count > 0:
		ref_count -= 1
		if ref_count == 0:
			on_end.call()
	return ref_count
