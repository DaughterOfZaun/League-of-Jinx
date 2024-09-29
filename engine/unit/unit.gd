class_name Unit
extends Node3D

@export_range(1, 31, 1, "hide_slider") var team := 1
@export var data: UnitData

var stats: Stats
var buffs: Buffs
var spells: Spells
var passive: Passive
var vars: Vars
var ai: AI

func on_order(type: Enums.OrderType, pos: Vector3, unit: Unit) -> void:
	ai.order(type, pos, unit)

func on_cast(letter: String, pos: Vector3, unit: Unit) -> void:
	(spells[letter] as Spell).try_cast(unit, pos)

var tick_rate: float = 0.25
var physics_fps: int = Engine.physics_ticks_per_second
var target_frame: int = max(2, floor(physics_fps * tick_rate))
var should_update_stats := false
var should_update_actions := false
func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return

	var frame: int = Engine.get_physics_frames() % target_frame
	should_update_stats = frame == 0
	should_update_actions = frame == 1
	if should_update_stats:
		update_stats()
	if should_update_actions:
		update_actions()

func connect_all(to: Node) -> void:
	var signals := get_signal_list()
	for s in signals:
		var sname: String = s.name
		var mname: String = 'on_' + sname
		if mname in to:
			(self[sname] as Signal).connect(to[mname] as Callable)

signal allow_add(attacker: Unit, buff: Buff)

# UPDATE
#signal update_stats()
func update_stats() -> void: pass
#signal update_actions()
func update_actions() -> void: pass

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

#signal set_vars_by_level() #TODO: Specific to char_script and talent_script
#signal update_ammo() #TODO: Specific to buff_script
#signal update_buffs() #TODO: Specific to buff_script
