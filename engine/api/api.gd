class_name API

static func get_units_in_area(
	attacker: Unit,
	center: Vector3,
	range: float,
	flags := Enums.SpellFlags.NONE,
	buff_type_filter: GDScript = null,
	inclusiveBuffFilter := false
) -> Array[Unit]:
	push_warning("API.get_units_in_area is unimplemented")
	return []

static func get_closest_units_in_area(
	attacker: Unit,
	center: Vector3,
	range: float,
	flags: Enums.SpellFlags,
	maximum_units_to_pick: int,
	buff_type_filter: GDScript = null,
	inclusive_buff_filter: bool = false
) -> Array[Unit]:
	push_warning("API.get_closest_units_in_area is unimplemented")
	return []

static func get_visible_units_in_area(
	attacker: Unit,
	center: Vector3,
	range: float,
	flags: Enums.SpellFlags,
	buff_type_filter: GDScript = null,
	inclusive_buff_filter: bool = false
) -> Array[Unit]:
	push_warning("API.get_visible_units_in_area is unimplemented")
	return []

static func get_closest_visible_units_in_area(
	attacker: Unit,
	center: Vector3,
	range: float,
	flags: Enums.SpellFlags,
	maximum_units_to_pick: int,
	buff_type_filter: GDScript = null,
	inclusive_buff_filter: bool = false
) -> Array[Unit]:
	push_warning("API.get_closest_visible_units_in_area is unimplemented")
	return []

static func get_champions(
	team: Enums.Team,
	buff_type_filter: GDScript = null,
	inclusive_buff_filter: bool = false
) -> Array[Champion]:
	push_warning("API.get_champions is unimplemented")
	return []

static func get_units_in_rectangle(
	attacker: Unit,
	center: Vector3,
	half_width: float,
	half_length: float,
	flags: Enums.SpellFlags,
	buff_type_filter: GDScript = null,
	inclusive_buff_filter: bool = false
) -> Array[Unit]:
	push_warning("API.get_units_in_rectangle is unimplemented")
	return []

static func get_random_visible_units_in_area(
	attacker: Unit,
	center: Vector3,
	range: float,
	flags: Enums.SpellFlags,
	maximum_units_to_pick: int,
	buff_type_filter: GDScript,
	inclusive_buff_filter: bool
) -> Array[Unit]:
	push_warning("API.get_random_visible_units_in_area is unimplemented")
	return []
