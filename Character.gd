class_name Unit
extends CharacterBody3D

@export_range(1, 31, 1, "hide_slider") var team := 1
var stats: Stats #@onready var stats := find_child("Stats") as Stats
var buffs: Buffs #@onready var buffs := find_child("Buffs") as Buffs
var spells: Spells #@onready var spells := find_child("Spells") as Spells
var char_vars: CharVars #@onready var char_vars := find_child("CharVars") as CharVars

@onready var input_manager := get_node("%InputManager") as InputManager
signal order(type: Enums.OrderType, unit: Unit, pos: Vector3)
func _ready():
	input_manager.order.connect(func (type, unit = null, pos = Vector3.ZERO): order.emit(type, unit, pos))
	get_tree().physics_frame.connect(_pre_physics_process)

var on_update_stats_time_tracker := API.TimeTracker.new(0.25, true)
func _pre_physics_process():
	if on_update_stats_time_tracker.execute():
		update_stats.emit()

var on_update_time_tracker := API.TimeTracker.new(0.25, true)
func _physics_process(_delta):
	update_actions.emit()

func connect_all(to):
	var signals = get_signal_list()
	for s in signals:
		var sname: String = s.name
		if sname != 'order' and ('on_' + sname) in to:
			connect(sname, Callable(to, sname))

signal allow_add(attacker: Unit, buff: Buff)

# UPDATE
signal update_stats()
signal update_actions()

signal dodge(attacker: Unit)
signal being_dodged(target: Unit)

# HIT
signal hit_unit(target: Unit, damage: DamageData)
signal being_hit(attacker: Unit, damage: DamageData)
signal spell_hit(target: Unit, spell: Spell)
signal being_spell_hit(attacker: Unit, spell: Spell)
signal miss(target: Unit)

signal move_end()
signal move_failure()
signal move_success()
signal collision()
signal collision_terrain()

# DEATH
signal kill(target: Unit)
signal assist(attacker: Unit, target: Unit)
signal death(attacker: Unit)
signal nearby_death(attacker: Unit, target: Unit)
signal zombie(attacker: Unit)
signal resurrect()

# CONNECTION
signal disconnect()
signal reconnect()

# LEVEL
signal level_up()
signal level_up_spell(slot: int)

signal pre_attack(target: Unit)
signal launch_attack(target: Unit)
signal launch_missile(spell: Spell, missile: Missile)
signal missile_update(spell: Spell, missile: Missile)
signal missile_end(spell: Spell, missile: Missile)

# DAMAGE
signal pre_deal_damage(target: Unit, damage: DamageData)
signal pre_mitigation_damage(target: Unit, damage: DamageData)
signal pre_damage(target: Unit, damage: DamageData)
signal take_damage(attacker: Unit, damage: DamageData)
signal deal_damage(target: Unit, damage: DamageData)

signal heal(heal: HealData)

signal spell_cast(spell: Spell)

signal set_vars_by_level() #TODO: it'specific: s char_script: for talent_script: and
signal update_ammo() #TODO: it'specific: s buff_script: for
signal update_buffs() #TODO: it'specific: s buff_script: for

