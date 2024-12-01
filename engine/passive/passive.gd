class_name Passive extends PassiveData

@onready
var me: Unit = get_parent()
var host: Unit:
	get: return me
var attacker: Unit:
	get: return me
var target: Unit:
	get: return me
var caster: Unit:
	get: return me
var vars: Vars:
	get: return me.vars

func _ready() -> void:
	if Engine.is_editor_hint(): return
	on_activate()

func on_activate() -> void: pass
