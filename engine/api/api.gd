class_name API

static func get_point_by_unit_facing_offset(unit: Unit, distance: float, offsetAngle: float) -> Vector3:
	var v2 := unit.direction.rotated(deg_to_rad(offsetAngle)) * distance
	return unit.position_3d + Vector3(v2.x, 0, v2.y)

static func filter_units_in_range(caster: Unit, pos: Vector3, radius: float, flags: Enums.SpellFlags) -> Array[Unit]:
	return [] #TODO:

static func get_units_in_area(
	attacker: Unit,
	center: Vector3,
	range: float,
	flags := Enums.SpellFlags.NONE,
	buffTypeFilter: GDScript = null,
	inclusiveBuffFilter := false
) -> Array[Unit]:
	return [] #TODO:
