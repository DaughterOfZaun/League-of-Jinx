class_name Missile
extends Node3D

var spell: Spell
var target: Unit = null
var target_position := Vector3.INF
func _init(spell: Spell, target: Variant) -> void:
	self.spell = spell
	if target is Unit: self.target = target
	if target is Vector3: self.target_position = target

func _ready() -> void:
	global_position = spell.host.get_bone_global_position(spell.missile_bone_idx)
	var effect: System = spell.data.missile_effect.instantiate()
	add_child(effect)

var time_elapsed := 0.0
func _physics_process(delta: float) -> void:
	time_elapsed += delta
	spell.on_missile_update(self)

func linear_movement(delta: float, target_position: Vector3) -> bool:
	var fixed_travel_time := spell.data.missile_fixed_travel_time
	var initial_speed := spell.data.missile_speed
	var min_speed := spell.data.missile_min_speed
	var max_speed := spell.data.missile_max_speed
	if max_speed == 0: max_speed = INF
	var accel := spell.data.missile_accel
	
	var speed: float
	var dir := target_position - global_position
	var dir_len := dir.length()
	if fixed_travel_time > 0:
		speed = dir_len / (fixed_travel_time - time_elapsed)
	else:
		speed = clampf(initial_speed + (accel * time_elapsed), min_speed, max_speed)
	var dist := speed * delta * Data.HW2GD
	if dist < dir_len:
		global_position += (dir / dir_len) * dist
		return false
	else:
		global_position = target_position
		return true

func destroy_self() -> void:	
	spell.on_missile_end(self)
	queue_free()
