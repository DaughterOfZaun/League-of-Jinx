@tool
class_name NGT
extends Node2D

const HW2GD := 1. / 70.

static func get_v3(fa: FileAccess) -> Vector3:
	return Vector3(fa.get_float(), fa.get_float(), fa.get_float())
static func get_v2i(fa: FileAccess) -> Vector2i:
	return Vector2i(fa.get_32(), fa.get_32())
static func get_v2(fa: FileAccess) -> Vector2:
	return Vector2(fa.get_float(), fa.get_float())
static func get_v2i_16(fa: FileAccess) -> Vector2i:
	return Vector2i(fa.get_16(), fa.get_16())


var visited: Array[bool]
@export_file("*.aimesh_ngrid") var import_path: String
@export_tool_button("Import") var import := func() -> void:
	var fa := FileAccess.open(import_path, FileAccess.ModeFlags.READ)
	var ng := NavigationGrid.new(fa)
	#print_navgrid(ng); return
	visited = []; visited.resize(len(ng.cells))
	var contours: Array[Array] = []
	for x in range(ng.cell_count.x):
		for y in range(ng.cell_count.y):
			var contour: Array[NavigationGridCell] = []
			find_contour(ng, x, y, contour)
			if len(contour) >= 3:
				contours.append(contour)
	#return
	for contour in contours:
		var lo := LightOccluder2D.new()
		add_child(lo, true)
		lo.owner = self
		lo.occluder = OccluderPolygon2D.new()
		var polygon := PackedVector2Array()
		for cell: NavigationGridCell in contour:
			polygon.append(Vector2(cell.locator.x * ng.cell_size * HW2GD, cell.locator.y * ng.cell_size * HW2GD))
		lo.occluder.polygon = polygon
		lo.occluder.closed = true

func _ready() -> void:
	if Engine.is_editor_hint(): return
	import.call()

func get_cell_index(ng: NavigationGrid, x: int, y: int) -> int:
	return y * ng.cell_count.x + x
func is_valid_cell_index(ng: NavigationGrid, index: int) -> bool:
	return index >= 0 && index < len(ng.cells)
func get_cell(ng: NavigationGrid, x: int, y: int) -> NavigationGridCell:
	var index := get_cell_index(ng, x, y)
	return ng.cells[index] if is_valid_cell_index(ng, index) else null
var neighbor_offsets: Array[Vector2i] = [
	Vector2i(0, 1),
	Vector2i(1, 1),
	Vector2i(1, 0),
	Vector2i(1, -1),
	Vector2i(0, -1),
	Vector2i(-1, -1),
	Vector2i(-1, 0),
	Vector2i(-1, 1),
]
var neighbor_offsets_plus: Array[Vector2i] = [
	Vector2i(0, 1),
	Vector2i(1, 0),
	Vector2i(0, -1),
	Vector2i(-1, 0),
]
func get_neighbors(ng: NavigationGrid, x: int, y: int) -> Array[NavigationGridCell]:
	var neighbors: Array[NavigationGridCell] = []
	for offset in neighbor_offsets_plus:
		var neighbor := get_cell(ng, x + offset.x, y + offset.y)
		if neighbor != null:
			neighbors.append(neighbor)
	return neighbors
func is_on_edge(cell: NavigationGridCell, ng: NavigationGrid, x: int, y: int) -> bool:
	return occludes_light(cell) && get_neighbors(ng, x, y).any(func(neighbor: NavigationGridCell) -> bool: return !occludes_light(neighbor))

func find_contour(ng: NavigationGrid, x: int, y: int, a: Array[NavigationGridCell]) -> bool:
	var index := get_cell_index(ng, x, y)
	if !is_valid_cell_index(ng, index): return false
	if visited[index]: return false;
	visited[index] = true
	var cell := ng.cells[index]
	if is_on_edge(cell, ng, x, y):
		a.append(cell)
		var num_of_connections := 0
		for offset in neighbor_offsets:
			num_of_connections += int(find_contour(ng, x + offset.x, y + offset.y, a))
		return true
	return false

func occludes_light(cell: NavigationGridCell) -> bool:
	var has_grass := (cell.flags & NavigationGridCellFlags.HAS_GRASS) != 0
	var not_passable := (cell.flags & NavigationGridCellFlags.NOT_PASSABLE) != 0
	var see_through := (cell.flags & NavigationGridCellFlags.SEE_THROUGH) != 0
	var has_transparentterrain := (cell.flags & NavigationGridCellFlags.HAS_TRANSPARENTTERRAIN) != 0
	var has_anti_brush := (cell.flags & NavigationGridCellFlags.HAS_ANTI_BRUSH) != 0
	return has_grass || (not_passable && !see_through)

func print_navgrid(ng: NavigationGrid) -> void:
	for y in range(ng.cell_count.y):
		var str := ""
		for x in range(ng.cell_count.x):
			if x >= 100: break
			var cell := get_cell(ng, x, y)
			#var flags := cell.flags
			#if flags & NavigationGridCellFlags.NOT_PASSABLE:
			if is_on_edge(cell, ng, x, y):
				str += "O"
			else: str += "+"
		print(str)

enum NavigationGridCellFlags {
	NONE,
	HAS_GRASS = 1,
	NOT_PASSABLE = 2,
	BUSY = 4,
	TARGETTED = 8,
	MARKED = 16,
	PATHED_ON = 32,
	SEE_THROUGH = 64,
	HAS_TRANSPARENTTERRAIN = 66,
	OTHERDIRECTION_END_TO_START = 128,
	HAS_ANTI_BRUSH = 256
}

class NavigationGrid:
	var min_grid_position: Vector3
	var max_grid_position: Vector3
	var cell_size: float
	var cell_count: Vector2i
	var cells: Array[NavigationGridCell]
	var region_tags: Array[int]
	var groups: Array[NavigationRegionTagTableGroupTag]
	var sampled_heights_count: Vector2i
	var sampled_heights_distance: Vector2
	var sampled_heights: Array[float]
	var hint_nodes: Array[NavigationHintNode]
	func _init(fa: FileAccess) -> void:
		var major := fa.get_8()
		var minor := fa.get_16() if major != 2 else 0
		if !major in [2, 3, 5, 7]:
			print("Unsupported Navigation Grid Version: %d.%d" % [major, minor])
		min_grid_position = NGT.get_v3(fa)
		max_grid_position = NGT.get_v3(fa)
		cell_size = fa.get_float()
		cell_count = NGT.get_v2i(fa)
		cells = []; cells.resize(cell_count.x * cell_count.y)
		region_tags = []; region_tags.resize(cell_count.x * cell_count.y)
		if major in [2, 3, 5]:
			for i in range(len(cells)):
				cells[i] = NavigationGridCell.ReadVersion5(fa)
			if major == 5:
				for i in range(len(region_tags)):
					region_tags[i] = fa.get_16()
		elif major == 7:
			for i in range(len(cells)):
				cells[i] = NavigationGridCell.ReadVersion7(fa)
			for i in range(len(cells)):
				cells[i].SetFlags(fa.get_16())
			for i in range(len(region_tags)):
				region_tags[i] = fa.get_32()
		if major >= 5:
			var groupCount := 4 if major == 5 else 8
			groups = []; groups.resize(groupCount)
			for i in range(len(groups)):
				groups[i] = NavigationRegionTagTableGroupTag.new(fa)
		sampled_heights_count = NGT.get_v2i(fa)
		sampled_heights_distance = NGT.get_v2(fa)
		sampled_heights = []; sampled_heights.resize(sampled_heights_count.x * sampled_heights_count.y)
		for i in range(len(sampled_heights)):
			sampled_heights[i] = fa.get_float()
		hint_nodes = []; hint_nodes.resize(900)
		for i in range(len(hint_nodes)):
			hint_nodes[i] = NavigationHintNode.new(fa)
		#MapWidth := MaxGridPosition.x + MinGridPosition.x
		#MapHeight := MaxGridPosition.z + MinGridPosition.z
		#MiddleOfMap := Vector2(MapWidth * 0.5, MapHeight * 0.5)

class NavigationGridCell:
	var flags: NavigationGridCellFlags
	var center_height: float
	var session_id: int
	var arrival_cost: float
	var is_open: bool
	var heuristic: float
	var locator: Vector2i
	var additional_cost: float
	var hint_as_good_cell: float
	var additional_cost_ref_count: int
	var good_cell_session_id: int
	var ref_hint_weight: float
	var arrival_direction: int
	var ref_hint_node: Array[int]
	static func ReadVersion5(fa: FileAccess) -> NavigationGridCell:
		var c := NavigationGridCell.new()
		c.center_height = fa.get_float()
		c.session_id = fa.get_32()
		c.arrival_cost = fa.get_float()
		c.is_open = fa.get_32() == 1
		c.heuristic = fa.get_float()
		var actor_list := fa.get_32()
		c.locator = NGT.get_v2i_16(fa)
		c.additional_cost = fa.get_float()
		c.hint_as_good_cell = fa.get_float()
		c.additional_cost_ref_count = fa.get_32()
		c.good_cell_session_id = fa.get_32()
		c.ref_hint_weight = fa.get_float()
		c.arrival_direction = fa.get_16()
		c.flags = fa.get_16()
		c.ref_hint_node = [ fa.get_16(), fa.get_16() ]
		return c

	static func ReadVersion7(fa: FileAccess) -> NavigationGridCell:
		var c := NavigationGridCell.new()
		c.center_height = fa.get_float()
		c.session_id = fa.get_32()
		c.arrival_cost = fa.get_float()
		c.is_open = fa.get_32() == 1
		c.heuristic = fa.get_float()
		c.locator = NGT.get_v2i_16(fa)
		var actor_list := fa.get_32()
		fa.get_32()
		c.good_cell_session_id = fa.get_32()
		c.ref_hint_weight = fa.get_float()
		fa.get_16()
		c.arrival_direction = fa.get_16()
		c.ref_hint_node = [ fa.get_16(), fa.get_16() ]
		return c

	func SetFlags(flags: NavigationGridCellFlags) -> void:
		self.flags = self.flags | flags

class NavigationRegionTagTableGroupTag:
	var name: int
	var values: Array[Array]
	func _init(fa: FileAccess) -> void:
		name = fa.get_32()
		values = []; values.resize(16)
		for i in range(len(values)):
			values[i] = [fa.get_32(), fa.get_32()]

class NavigationHintNode:
	var locator: Vector2i
	var distances: Array[float]
	func _init(fa: FileAccess) -> void:
		distances = []; distances.resize(900)
		for i in range(len(distances)):
			distances[i] = fa.get_float()
		locator = NGT.get_v2i_16(fa)
