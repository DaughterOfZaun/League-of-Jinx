@tool class_name NGT extends Node2D

const HW2GD := 1. / 70.
const GD_3D_to_2D := (70. / 50.) * (512. / 294.)

const null_array_of_array: Array[Array] = []
const null_array_of_vector2: Array[Vector2] = []

static func get_v3(fa: FileAccess) -> Vector3:
	return Vector3(fa.get_float(), fa.get_float(), fa.get_float())
static func get_v2i(fa: FileAccess) -> Vector2i:
	return Vector2i(fa.get_32(), fa.get_32())
static func get_v2(fa: FileAccess) -> Vector2:
	return Vector2(fa.get_float(), fa.get_float())
static func get_v2i_16(fa: FileAccess) -> Vector2i:
	return Vector2i(fa.get_16(), fa.get_16())

@export_file("*.aimesh_ngrid") var import_path: String
@export_tool_button("Import") var import := func() -> void:
	var fa := FileAccess.open(import_path, FileAccess.ModeFlags.READ)
	var ng := NavigationGrid.new(fa)

	#print(ng.cell_count); return

	var image: Array[Array] = []; image.resize(ng.cell_count.x)
	for x in range(ng.cell_count.x):
		image[x] = []; image[x].resize(ng.cell_count.y)
		for y in range(ng.cell_count.y):
			image[x][y] = occludes_light(get_cell(ng, x, y))
	var contours := find_contours(image, 0.5)

	var holder := get_node("Node2D")
	for child in holder.get_children():
		holder.remove_child(child)
	for contour: Array[Vector2] in contours:
		var lo := LightOccluder2D.new()
		holder.add_child(lo, true)
		lo.owner = self
		lo.occluder = OccluderPolygon2D.new()
		var polygon := PackedVector2Array()
		#for cell: NavigationGridCell in contour:
		#	polygon.append(Vector2(cell.locator) * ng.cell_size * HW2GD)

		var prev_dir := Vector2.ZERO
		var prev_point := Vector2.INF
		for point in contour:
			var should_add := true
			var dir := Vector2.ZERO
			if prev_point.is_finite():
				dir = (point - prev_point).normalized()
				if dir.is_equal_approx(prev_dir):
					should_add = false
			if should_add:
				var min_pos := Vector2(ng.min_grid_position.x, ng.min_grid_position.z)
				polygon.append((min_pos / 50. + point) * (512. / 293.) * Vector2(1, -1))
				prev_dir = dir
			prev_point = point

		lo.occluder.polygon = polygon
		lo.occluder.closed = true

func _ready() -> void:
	if Engine.is_editor_hint(): return
	#import.call()

func get_cell_index(ng: NavigationGrid, x: int, y: int) -> int:
	return y * ng.cell_count.x + x
func is_valid_cell_index(ng: NavigationGrid, index: int) -> bool:
	return index >= 0 && index < len(ng.cells)
func get_cell(ng: NavigationGrid, x: int, y: int) -> NavigationGridCell:
	var index := get_cell_index(ng, x, y)
	return ng.cells[index] if is_valid_cell_index(ng, index) else null
func occludes_light(cell: NavigationGridCell) -> bool:
	if cell == null: return false
	var has_grass := (cell.flags & NavigationGridCellFlags.HAS_GRASS) != 0
	var not_passable := (cell.flags & NavigationGridCellFlags.NOT_PASSABLE) != 0
	var see_through := (cell.flags & NavigationGridCellFlags.SEE_THROUGH) != 0
	var has_transparentterrain := (cell.flags & NavigationGridCellFlags.HAS_TRANSPARENTTERRAIN) != 0
	var has_anti_brush := (cell.flags & NavigationGridCellFlags.HAS_ANTI_BRUSH) != 0
	return (not_passable && !see_through) #|| has_grass

func find_contours(
	image: Array[Array],
	level: float,
	fully_connected := false,
	positive_orientation := false,
	mask: Array[Array] = null_array_of_array
) -> Array[Array]:
	var segments := _get_contour_segments(image, level, fully_connected, mask)
	var contours := _assemble_contours(segments)
	#if positive_orientation:
	#	contours = [c[::-1] for c in contours]
	return contours

func dict_pop(dict: Dictionary[Variant, Variant], key: Variant, default: Variant) -> Variant:
	var value: Variant = default
	if key in dict:
		value = dict[key]
		dict.erase(key)
	return value
func array_extendleft_reversed(a: Array, b: Array) -> void:
	var c := b.duplicate()
	c.append_array(a)
	a.assign(c)
func dict_sorted_items_values(dict: Dictionary[Variant, Variant]) -> Array[Variant]:
	var sorted_keys := dict.keys()
	sorted_keys.sort()
	var values := []
	for key: Variant in sorted_keys:
		values.append(dict[key])
	return values

func _assemble_contours(segments: Array[Array]) -> Array[Array]:
	var current_index := 0
	var contours := {}
	var starts := {}
	var ends := {}
	for segment: Array[Vector2] in segments:
		var from_point := segment[0]; var to_point := segment[1]
		if from_point == to_point:
			continue

		var start: Array = dict_pop(starts, to_point, [null_array_of_vector2, 0])
		var tail: Array[Vector2] = start[0]; var tail_num: int = start[1]
		var end: Array = dict_pop(ends, from_point, [null_array_of_vector2, 0])
		var head: Array[Vector2] = end[0]; var head_num: int = end[1]

		if tail != null_array_of_vector2 and head != null_array_of_vector2:
			if tail == head:
				head.append(to_point)
			else:
				if tail_num > head_num:
					head.append_array(tail)
					dict_pop(contours, tail_num, null)
					starts[head[0]] = [head, head_num]
					ends[head[-1]] = [head, head_num]
				else:
					array_extendleft_reversed(tail, head)
					dict_pop(starts, head[0], null)
					dict_pop(contours, head_num, null)
					starts[tail[0]] = [tail, tail_num]
					ends[tail[-1]] = [tail, tail_num]
		elif tail == null_array_of_vector2 and head == null_array_of_vector2:
			var new_contour: Array[Vector2] = [from_point, to_point]
			contours[current_index] = new_contour
			starts[from_point] = [new_contour, current_index]
			ends[to_point] = [new_contour, current_index]
			current_index += 1
		elif head == null_array_of_vector2:
			tail.push_front(from_point)
			starts[from_point] = [tail, tail_num]
		else:
			head.append(to_point)
			ends[to_point] = [head, head_num]

	var tmp: Array[Array] = []
	tmp.assign(dict_sorted_items_values(contours))
	return tmp

func _get_fraction(from_value: float, to_value: float, level: float) -> float:
	if to_value == from_value: return 0
	return ((level - from_value) / (to_value - from_value))

func _get_contour_segments(
	array: Array[Array],
	level: float,
	vertex_connect_high: bool,
	mask: Array[Array] = null_array_of_array
) -> Array[Array]:
	var segments: Array[Array] = []
	var use_mask := mask != null_array_of_array
	var array_shape := Vector2i(len(array), len(array[0]))
	for r0 in range(array_shape[0] - 1):
		for c0 in range(array_shape[1] - 1):
			var r1 := r0 + 1; var c1 := c0 + 1
			if use_mask and !(
				mask[r0][c0] and mask[r0][c1] and
				mask[r1][c0] and mask[r1][c1]
			): continue

			var ul: float = array[r0][c0]
			var ur: float = array[r0][c1]
			var ll: float = array[r1][c0]
			var lr: float = array[r1][c1]
			if is_nan(ul) or is_nan(ur) or is_nan(ll) or is_nan(lr):
				continue

			var square_case := 0
			if ul > level: square_case += 1
			if ur > level: square_case += 2
			if ll > level: square_case += 4
			if lr > level: square_case += 8

			if square_case in [0, 15]:
				continue

			var top := Vector2(r0, c0 + _get_fraction(ul, ur, level))
			var bottom := Vector2(r1, c0 + _get_fraction(ll, lr, level))
			var left := Vector2(r0 + _get_fraction(ul, ll, level), c0)
			var right := Vector2(r0 + _get_fraction(ur, lr, level), c1)

			if square_case == 1:
				segments.append([top, left])
			elif square_case == 2:
				segments.append([right, top])
			elif square_case == 3:
				segments.append([right, left])
			elif square_case == 4:
				segments.append([left, bottom])
			elif square_case == 5:
				segments.append([top, bottom])
			elif square_case == 6:
				if vertex_connect_high:
					segments.append([left, top])
					segments.append([right, bottom])
				else:
					segments.append([right, top])
					segments.append([left, bottom])
			elif square_case == 7:
				segments.append([right, bottom])
			elif square_case == 8:
				segments.append([bottom, right])
			elif square_case == 9:
				if vertex_connect_high:
					segments.append([top, right])
					segments.append([bottom, left])
				else:
					segments.append([top, left])
					segments.append([bottom, right])
			elif square_case == 10:
				segments.append([bottom, top])
			elif square_case == 11:
				segments.append([bottom, left])
			elif square_case == 12:
				segments.append([left, right])
			elif square_case == 13:
				segments.append([top, right])
			elif square_case == 14:
				segments.append([left, top])

	return segments

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
