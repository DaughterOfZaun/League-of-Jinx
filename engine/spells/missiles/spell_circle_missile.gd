class_name SpellCircleMissile extends Missile #@rollback

static func create(spell: Spell, target: Unit, target_position: Vector3) -> SpellCircleMissile:
	var m := SpellCircleMissile.new()
	m.init(spell, target, target_position)
	return m

var angle: float = 0.0
var radius: float = 0.0
func _ready() -> void:
	super._ready()
	var cast_position := spell.cast_position
	var dir := cast_position - target.position_3d
	angle = atan2(dir.z, dir.x)
	radius = Vector2(dir.x, dir.z).length()
	position_3d = cast_position

func _network_process(delta: float) -> void:
	super._network_process(delta)

	if target != null:
		target_position = target.position_3d

	var target_height_augment := spell.data.missile_target_height_augment
	var target_position_augmented: Vector3 = self.target_position
	if target_height_augment != 0:
		target_position_augmented.y += target_height_augment
	else:
		target_position_augmented.y = position_3d.y
	
	#var accel := spell.data.missile_accel
	#var fixed_travel_time := spell.data.missile_fixed_travel_time
	#assert(accel == 0 || fixed_travel_time == 0)

	#var speed: float
	#if fixed_travel_time > 0:
	#	speed = 360 / fixed_travel_time
	#else:
	#	speed = calc_speed()

	angle += spell.data.circle_missile_angular_velocity * delta
	radius += spell.data.circle_missile_radial_velocity * delta
	var r := Vector2.from_angle(angle)
	position_3d = target_position_augmented + Vector3(r.x, 0, r.y) * radius
