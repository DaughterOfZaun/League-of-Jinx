class_name API

static func get_point_by_unit_facing_offset(unit: Unit, distance: float, offsetAngle: float) -> Vector3:
	return Vector3.ZERO #TODO:

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
	return []
