class_name SpellLineMissile extends Missile

static func create(spell: Spell, target: Unit, target_position: Vector3) -> SpellLineMissile:
	var m := SpellLineMissile.new()
	m.init(spell, target, target_position)
	var a := Area3D.new()
	#TODO: think about replacing with RayCast3D
	a.area_entered.connect(m._area_entered)
	a.monitoring = true
	a.monitorable = false
	a.input_ray_pickable = false
	a.collision_mask = API.get_collision_mask(spell.host, spell.data.flags)
	a.collision_layer = 0
	var cs := CollisionShape3D.new()
	var s := CapsuleShape3D.new()
	s.radius = spell.data.line_width * Data.HW2GD
	s.height = (spell.data.line_width * 2 + spell.data.line_drag_length) * Data.HW2GD
	cs.shape = s
	cs.position.y -= spell.data.line_drag_length * 0.5 * Data.HW2GD
	a.add_child(cs)
	a.rotation_degrees.x = -90
	m.add_child(a)
	return m

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	var track_units := spell.data.line_missile_track_units
	if track_units && target != null:
		target_position = target.position_3d
	
	#var ends_at_target_point := spell.data.line_missile_ends_at_target_point
	if linear_movement(delta):
		#if ends_at_target_point:
		#	spell.on_missile_end(self)
		destroy_self()

func _area_entered(area: Area3D) -> void:
	if area.name == 'GameplayRange':
		var target: Unit = area.get_parent()
		spell._target_execute(target, self)
