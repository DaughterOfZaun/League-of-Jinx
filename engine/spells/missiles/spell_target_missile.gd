class_name SpellTargetMissile
extends Missile

var spell: Spell
var target: Unit
func _init(spell: Spell, target: Unit) -> void:
	self.spell = spell
	self.target = target

func _ready() -> void:
	global_position = spell.host.get_bone_global_position(spell.missile_bone_idx)
	var effect: System = spell.data.missile_effect.instantiate()
	add_child(effect)

var time_elapsed := 0.0
func _physics_process(delta: float) -> void:
	time_elapsed += delta
	
	var fixed_travel_time := spell.data.missile_fixed_travel_time
	var initial_speed := spell.data.missile_speed
	var min_speed := spell.data.missile_min_speed
	var max_speed := spell.data.missile_max_speed
	if max_speed == 0: max_speed = INF
	var accel := spell.data.missile_accel
	
	var speed: float
	var dir := target.global_position - global_position
	var dir_len := dir.length()
	if fixed_travel_time > 0:
		speed = dir_len / (fixed_travel_time - time_elapsed)
	else:
		speed = clampf(initial_speed + (accel * time_elapsed), min_speed, max_speed)
	var dist := speed * Data.HW2GD * delta
	if dist < dir_len:
		global_position += (dir / dir_len) * dist
	else:
		#global_position = target.global_position
		queue_free()
	
