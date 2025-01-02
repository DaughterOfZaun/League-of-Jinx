class_name SpellLineMissile extends Missile

static func create(spell: Spell, target: Unit, target_position: Vector3) -> SpellLineMissile:
	var m := SpellLineMissile.new()
	m.init(spell, target, target_position)
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