class_name PriorityQueue

## Min heap priority queue
## https://blog.bigturtleworks.com/posts/gdscript-priority-queue-benchmarks/

var _data: Array[Variant] = []
var _cost: Array[float] = []

func insert(element: Variant, cost: float) -> void:
	# Add the element to the bottom level of the heap at the leftmost open space
	self._data.push_back(element)
	self._cost.push_back(cost)
	var new_element_index: int = self._data.size() - 1
	self._up_heap(new_element_index)

func extract() -> Variant:
	var size_minus_one := self._data.size() - 1
	#if size_minus_one < 0: return null
	var result: Variant = self._data[0]
	# If the tree is not empty,
	if size_minus_one == 0:
		self._data.resize(size_minus_one)
		self._cost.resize(size_minus_one)
	else:
		# replace the root of the heap with the last element on the last level.
		self._data[0] = self._data.back()
		self._cost[0] = self._cost.back()
		self._data.resize(size_minus_one)
		self._cost.resize(size_minus_one)
		self._down_heap(0)
	return result

func is_empty() -> bool:
	return self._data.is_empty()

func _swap(a_idx: int, b_idx: int) -> void:
	var a: Variant = self._data[a_idx]
	var b: Variant = self._data[b_idx]
	var c := self._cost[a_idx]
	var d := self._cost[b_idx]
	self._cost[a_idx] = d
	self._cost[b_idx] = c
	self._data[a_idx] = b
	self._data[b_idx] = a

func _up_heap(index: int) -> void:
	# Compare the added element with its parent; if they are in the correct order, stop.
	while true:
		@warning_ignore("INTEGER_DIVISION")
		var parent_idx: int = (index - 1) / 2
		if self._cost[index] >= self._cost[parent_idx]:
			return
		self._swap(index, parent_idx)
		index = parent_idx

func _down_heap(index: int) -> void:
	var size: int = self._data.size()
	while true:
		var left_idx: int = (2 * index) + 1
		var right_idx: int = (2 * index) +  2

		var smallest: int
		if right_idx < size and self._cost[right_idx] < self._cost[smallest]:
			smallest = right_idx
		elif left_idx < size and self._cost[left_idx] < self._cost[smallest]:
			smallest = left_idx
		else: return

		self._swap(index, smallest)
		index = smallest
