class_name Effect
extends Data

enum ColorLookupType { CONSTANT = 0, LIFETIME = 1, VELOCITY = 2, BIRTH_RANDOM = 3, COUNT = 4, }
enum BlendMode { ADD, UNKNOWN_1, UNKNOWN_2, UNKNOWN_3, UNKNOWN_4, }
enum TrailMode { DEFAULT = 0, WAKE = 1, }
enum FixedOrbitType { WORLD_X = 0, WORLD_Y = 1, WORLD_Z = 2, WORLD_NEG_X = 3, WORLD_NEG_Y = 4, WORLD_NEG_Z = 5, }
enum OrientationType { CAMERA = 0, WORLD_X = 1, WORLD_Y = 2, WORLD_Z = 3, }
enum UVMode { DEFAULT = 0, SCREEN_SPACE = 1, LOCK_ALPHA = 2, }
enum BeamMode { DEFAULT = 0, ARBITARY = 1, }
enum GroupImportance { INVALID = -1, LOW = 1, MEDIUM = 0, HIGH = 2, }
enum GroupType { INVALID = -1, SIMPLE = 0, COMPLEX = 1, }

@export_group("Material Override")
@export var MaterialOverrideTexture: Texture2D
@export var MaterialOverrideSubMesh: Texture2D
@export var MaterialOverridePriority: Texture2D
@export var MaterialOverrideBlendMode: BlendMode

func set_from_ini_entry(key_array: Array, value: String) -> void:
	match key_array:
		["MaterialOverride", var i, "BlendMode"]: pass
		["MaterialOverride", var i, "Priority"]: pass
		["MaterialOverride", var i, "SubMesh"]: pass
		["MaterialOverride", var i, "Texture"]: pass
		["MaterialOverrideTransMap"]: pass
