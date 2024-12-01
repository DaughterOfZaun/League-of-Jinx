class_name Status extends Node

@onready var me: Unit = get_parent()
func _ready() -> void:
	if Engine.is_editor_hint(): return
	me.status = self

@export var call_for_help_suppresser: bool
@export var can_attack: bool
@export var can_cast: bool
@export var can_move: bool
@export var can_move_ever: bool
@export var charmed: bool
@export var disable_ambient_gold: bool
@export var disarmed: bool
@export var feared: bool
@export var force_render_particles: bool
@export var ghosted: bool
@export var ghost_proof: bool
@export var ignore_call_for_help: bool
@export var invulnerable: bool
@export var lifesteal_immune: bool
@export var magic_immune: bool
@export var near_sight: bool
@export var netted: bool
@export var no_render: bool
@export var pacified: bool
@export var physical_immune: bool
@export var reveal_specific_unit: bool
@export var rooted: bool
@export var silenced: bool
@export var sleep: bool
@export var stealthed: bool
@export var stunned: bool
@export var suppress_call_for_help: bool
@export var suppressed: bool
@export var targetable: bool
@export var taunted: bool
@export var immovable: bool
@export var is_dead: bool
@export var is_zombie: bool
@export var is_clone: bool
@export var is_moving: bool

@export var targetable_to_team: Dictionary[int, bool] = {
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
