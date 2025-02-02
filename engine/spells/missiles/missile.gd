class_name Missile extends Node3DExt #@rollback

var spell: Spell
var target: Unit = null
var target_position: Vector3 = Vector3.INF
func init(spell: Spell, target: Unit, target_position: Vector3 = Vector3.INF) -> void:
	self.spell = spell
	if target != null:
		self.target = target
		self.target_position = target.position_3d
	elif target_position.is_finite():
		self.target_position = target_position
	else:
		assert(false)

var effect: System = null
func _ready() -> void:
	var bone_name := spell.data.missile_bone_name
	#TODO: bone_name == "root" or cast(override_cast_pos == true) ?
	if bone_name.is_empty() || bone_name == "root":
		position_3d = spell.cast_position
	else:
		global_position = spell.host.get_bone_global_position(spell.missile_bone_idx)

	effect = spell.data.missile_effect.instantiate()
	add_child(effect)

var time_elapsed: float = 0.0
func _physics_process(delta: float) -> void:
	time_elapsed += delta
	var lifetime := spell.data.missile_lifetime
	if is_zero_approx(lifetime): lifetime = INF
	if time_elapsed >= lifetime: destroy_self()
	else: spell.on_missile_update(self)

func calc_speed() -> float:
	var initial_speed := spell.data.missile_speed
	var min_speed := spell.data.missile_min_speed
	var max_speed := spell.data.missile_max_speed
	if max_speed == 0: max_speed = INF
	var accel := spell.data.missile_accel
	var speed := clampf(initial_speed + (accel * time_elapsed), min_speed, max_speed)
	return speed

var target_reached: bool = false
var last_dir_normalized: Vector3 = Vector3.ZERO
var last_speed: float = 0.0
func linear_movement(delta: float, ends_at_target_point := true) -> bool:

	var accel := spell.data.missile_accel
	var fixed_travel_time := spell.data.missile_fixed_travel_time
	assert(accel == 0 || fixed_travel_time == 0)

	if !target_reached:

		#TODO: spell.data.line_missile_target_height_augment
		var target_height_augment := spell.data.missile_target_height_augment
		var target_position := self.target_position
		if target_height_augment != 0:
			target_position.y += target_height_augment
		else:
			target_position.y = position_3d.y
		
		var dir := target_position - position_3d
		var dir_len := dir.length()

		if !is_zero_approx(dir_len):
			self.look_at(global_position + dir)

		var speed: float
		if fixed_travel_time > 0:
			speed = dir_len / (fixed_travel_time - time_elapsed)
		else:
			speed = calc_speed()
		last_speed = speed
		
		var dist := speed * delta
		target_reached = dist >= dir_len
		if target_reached && ends_at_target_point:
			position_3d = target_position
			return true
		else:
			last_dir_normalized = dir / dir_len
			position_3d += last_dir_normalized * dist
			return false
	
	#elif ends_at_target_point:
	#	assert(false)
	#	return true
	
	else:
		last_dir_normalized.y = 0 #HACK:

		var speed: float
		if fixed_travel_time > 0:
			speed = last_speed
		else:
			speed = calc_speed()

		var dist := speed * delta
		position_3d += last_dir_normalized * dist
		
		return false

func destroy_self() -> void:
	spell.on_missile_end(self)
	self.destroy()

#var is_being_destroyed := false
func destroy() -> void:
	if self.is_inside_tree(): get_parent().remove_child(self) #self.queue_free()
	#if is_being_destroyed: return
	#is_being_destroyed = true
	#if effect != null:
	#	for particle: GPUParticles3D in effect.find_children("*", "GPUParticles3D", true):
	#		particle.emitting = false

var _transform: Transform3D = Transform3D.IDENTITY
func _save() -> void:
	_transform = transform
func _load() -> void:
	transform = _transform
