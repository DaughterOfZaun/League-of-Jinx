class_name API

static func get_collision_mask(attacker: Unit, flags: Enums.SpellFlags) -> int:
	
	var affect_self := !!(flags & Enums.SpellFlags.ALWAYS_SELF)
	#var not_affect_self := !!(flags & Enums.SpellFlags.NOT_AFFECT_SELF)
	#assert(!(affect_self && not_affect_self))

	var affect_enemies := !!(flags & Enums.SpellFlags.AFFECT_ENEMIES)
	var affect_friends := !!(flags & Enums.SpellFlags.AFFECT_FRIENDS)
	var affect_neutral := !!(flags & Enums.SpellFlags.AFFECT_NEUTRAL)

	var result := 0
	var attacker_team_mask := 1 << attacker.team
	var neutral_team_mask := 1 << Enums.Team.NEUTRAL
	var unknown_team_mask := 1 << Enums.Team.UNKNOWN
	if affect_enemies: result |= ~(attacker_team_mask | unknown_team_mask | neutral_team_mask)
	if affect_friends || affect_self: result |= attacker_team_mask
	if affect_neutral: result |= neutral_team_mask

	return result

static func get_units_in_area(
	attacker: Unit,
	center: Vector3,
	range: float,
	flags: Enums.SpellFlags = Enums.SpellFlags.NONE,
	buff_type_filter: GDScript = null,
	inclusiveBuffFilter: bool = false,
	maximum_units_to_pick: int = 32
) -> Array[Unit]:
	var affect_self := !!(flags & Enums.SpellFlags.ALWAYS_SELF)
	var not_affect_self := !!(flags & Enums.SpellFlags.NOT_AFFECT_SELF)
	assert(!(affect_self && not_affect_self))

	#var shape := SphereShape3D.new()
	#shape.radius = range * Data.HW2GD
	var shape_rid := PhysicsServer3D.sphere_shape_create()
	PhysicsServer3D.shape_set_data(shape_rid, range * Data.HW2GD)

	var query := PhysicsShapeQueryParameters3D.new()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = get_collision_mask(attacker, flags & ~Enums.SpellFlags.ALWAYS_SELF)
	if not_affect_self:
		var radius: Radius = attacker.find_child('GameplayRange', false)
		query.exclude.append(radius.get_rid())
	query.margin = 0.04
	query.motion = Vector3.ZERO
	#query.shape = shape
	query.shape_rid = shape_rid
	query.transform = Transform3D.IDENTITY.translated(center * Data.HW2GD)

	var tree: SceneTree = Engine.get_main_loop()
	var scene: Node3D = tree.current_scene
	var space_state := scene.get_world_3d().direct_space_state
	var query_results := space_state.intersect_shape(query, maximum_units_to_pick)
	PhysicsServer3D.free_rid(shape_rid)

	var results: Array[Unit] = []
	for result in query_results:
		var collider: CollisionObject3D = result['collider']
		#var collider_id: Variant = result['collider_id']
		#var rid: RID = result['rid']
		#var shape: int = result['shape']
		var unit: Unit = collider.get_parent()
		results.append(unit)

	var affect_friends := !!(flags & Enums.SpellFlags.AFFECT_FRIENDS)
	#var gameplay_range: Area3D = attacker.find_child("GameplayRange", true, false)
	#var collision_shape: CollisionShape3D = gameplay_range.get_child(0)
	#var sphere_shape: SphereShape3D = collision_shape.shape
	#var gameplay_collision_radius := sphere_shape.radius
	var gameplay_collision_radius := attacker.data.gameplay_collision_radius
	if affect_self && !affect_friends &&\
		attacker.position_3d.distance_squared_to(center) <= gameplay_collision_radius ** 2:
		results.append(attacker)
	
	return results

static var by_distance_center: Vector3
static func sort_by_distance(units: Array[Unit], center: Vector3) -> void:
	by_distance_center = center
	units.sort_custom(by_distance)
static func by_distance(a: Unit, b: Unit) -> bool:
	return a.position_3d.distance_squared_to(by_distance_center) <\
		   b.position_3d.distance_squared_to(by_distance_center)

static func visible(unit: Unit) -> bool:
	return unit.visible

static func get_closest_units_in_area(
	attacker: Unit,
	center: Vector3,
	range: float,
	flags: Enums.SpellFlags,
	maximum_units_to_pick: int,
	buff_type_filter: GDScript = null,
	inclusive_buff_filter: bool = false
) -> Array[Unit]:
	var units := get_units_in_area(attacker, center, range, flags, buff_type_filter, inclusive_buff_filter)
	sort_by_distance(units, center)
	return units.slice(0, maximum_units_to_pick)

static func get_visible_units_in_area(
	attacker: Unit,
	center: Vector3,
	range: float,
	flags: Enums.SpellFlags,
	buff_type_filter: GDScript = null,
	inclusive_buff_filter: bool = false
) -> Array[Unit]:
	var units := get_units_in_area(attacker, center, range, flags, buff_type_filter, inclusive_buff_filter)
	units.filter(visible)
	return units

static func get_closest_visible_units_in_area(
	attacker: Unit,
	center: Vector3,
	range: float,
	flags: Enums.SpellFlags,
	maximum_units_to_pick: int,
	buff_type_filter: GDScript = null,
	inclusive_buff_filter: bool = false
) -> Array[Unit]:
	var units := get_units_in_area(attacker, center, range, flags, buff_type_filter, inclusive_buff_filter)
	sort_by_distance(units, center)
	units.filter(visible)
	return units.slice(0, maximum_units_to_pick)

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
	var units := get_units_in_area(attacker, center, range, flags, buff_type_filter, inclusive_buff_filter)
	units.filter(visible)
	units.shuffle()
	return units.slice(0, maximum_units_to_pick)
