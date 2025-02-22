class_name CreateLevelProps

func create_level_props() -> void: pass

func enum_to_str(dict: Dictionary, value: int) -> String:
	return str(dict.keys()[dict.values().find(value)])

func create_child_turret(
	nav_point_name: String,
	character_name: String,
	team: Enums.Team,
	pos: Enums.Pos,
	lane: Enums.Lane
) -> void:

	var root: Node = null # := EditorInterface.get_edited_scene_root()
	var map := root.find_child("Map", false, false) #%Map
	var points := map.find_child("Points", false, false) #%Map/Points
	assert(map != null && points != null)

	var nav_point: Node3D = points.find_child(nav_point_name, false)
	assert(nav_point != null)

	var char: Turret = map.find_child(nav_point_name, false)
	if char == null:
		var pos_name := enum_to_str(Enums.Pos, pos).to_pascal_case()
		if pos in [Enums.Pos.HQ_TOWER_1, Enums.Pos.HQ_TOWER_2]:
			pos_name = "HQ"
		var team_name := enum_to_str(Enums.Team, team).to_pascal_case()

		var char_prefab: PackedScene = load("res://data/characters/Turrets/%s/%s/unit.tscn" % [pos_name, team_name])
		assert(char_prefab != null)

		char = char_prefab.instantiate()
		map.add_child(char)
		char.owner = root
		char.name = nav_point_name

	char.global_position = nav_point.global_position
	char.rotation_degrees.y = 90
	char.team = team
	char.lane = lane
	char.pos = pos
