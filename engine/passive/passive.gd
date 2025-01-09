class_name Passive extends PassiveData

@onready var me: Unit = get_parent()
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
	if !host.is_ready: await host.ready
	host.connect_all(self)
	on_activate()

func on_activate() -> void: pass
