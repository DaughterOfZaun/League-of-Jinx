class_name Missile extends Node3DExt

var spell: Spell
var target: Unit = null
var target_position := Vector3.INF
var start_position := Vector3.INF
func _init(spell: Spell, target: Unit, target_position: Vector3 = Vector3.INF) -> void:
	self.spell = spell
	if target != null:
		self.target = target
		self.target_position = target.position_3d
	elif target_position.is_finite():
		self.target_position = target_position
	else:
		assert(false)

func _ready() -> void:
	var bone_name := spell.data.missile_bone_name
	#TODO: bone_name == "root" or cast(override_cast_pos == true) ?
	if bone_name.is_empty() || bone_name == "root":
		position_3d = spell.cast_position
	else:
		global_position = spell.host.get_bone_global_position(spell.missile_bone_idx)
	start_position = position_3d

	var effect: System = spell.data.missile_effect.instantiate()
	add_child(effect)

var time_elapsed := 0.0
func _physics_process(delta: float) -> void:
	time_elapsed += delta
	spell.on_missile_update(self)

func linear_movement(delta: float) -> bool:
	
	#TODO: spell.data.line_missile_target_height_augment
	var target_height_augment := spell.data.missile_target_height_augment
	var target_position := self.target_position
	if target_height_augment != 0:
		target_position.y += target_height_augment
	else:
		target_position.y = position_3d.y

	var fixed_travel_time := spell.data.missile_fixed_travel_time
	var initial_speed := spell.data.missile_speed
	var min_speed := spell.data.missile_min_speed
	var max_speed := spell.data.missile_max_speed
	if max_speed == 0: max_speed = INF
	var accel := spell.data.missile_accel

	assert(accel == 0 || fixed_travel_time == 0)
	
	var dir := target_position - position_3d
	var dir_len := dir.length()

	self.look_at(global_position + dir)

	var speed: float
	if fixed_travel_time > 0:
		speed = dir_len / (fixed_travel_time - time_elapsed)
	else:
		speed = clampf(initial_speed + (accel * time_elapsed), min_speed, max_speed)
	
	var dist := speed * delta
	if dist < dir_len:
		position_3d += (dir / dir_len) * dist
		return false
	else:
		position_3d = target_position
		return true

func destroy_self() -> void:
	spell.on_missile_end(self)
	queue_free()

func destroy() -> void:
	push_warning("Missile.destroy is unimplemented")
