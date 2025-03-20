class_name Data extends Node

static var GD2HW: float = 70.
static var HW2GD: float = 1. / GD2HW #0.014285714

func string_parse(from: String) -> String:
	return from

var res_paths: Array[String] = []
var res_cache: Dictionary[String, String] = {}
var res_cache_is_null: bool = true
func get_from_cache(key: String) -> String:
	if res_cache_is_null:
		res_cache_is_null = false
		for res_path in res_paths:
			var dir := DirAccess.open(res_path)
			dir.list_dir_begin()
			while true:
				var fname := dir.get_next()
				if fname == "": break
				if dir.current_is_dir(): continue
				var fname_lc := fname.to_lower()
				if fname_lc.ends_with(tex_ext)\
				|| fname_lc.ends_with(mesh_ext)\
				|| fname_lc.ends_with(effect_ext):
					res_cache[fname_lc] = res_path + '/' + fname
	return res_cache[key]

const tex_ext := ".webp"
func tex_parse(from: String) -> Texture2D:
	return res_parse(from, ".dds", ".tga", tex_ext) as Texture2D

const mesh_ext := ".obj"
func mesh_parse(from: String) -> Mesh:
	return res_parse(from, ".scb", ".sco", mesh_ext) as Mesh

const effect_ext = ".tscn"
func effect_parse(from: String) -> PackedScene:
	return res_parse(from, ".troybin", ".troy", effect_ext) as PackedScene

func res_parse(from: String, bin_ext: String, txt_ext: String, out_ext: String) -> Resource:
	from = string_parse(from)
	from = from.to_lower().replace(bin_ext, out_ext).replace(txt_ext, out_ext)
	return load(get_from_cache(from))

enum VectorUsage { UNDEFINED, SCALE, ROTATION }
func vec3_parse(from: String, u := VectorUsage.UNDEFINED) -> Vector3:
	from = string_parse(from)
	var v := from.split(' ')
	assert(len(v) == 3 || (len(v) == 1 && u != VectorUsage.UNDEFINED), from)
	if len(v) == 1:
		match u:
			VectorUsage.SCALE: return Vector3.ONE * float_parse(v[0])
			VectorUsage.ROTATION: return Vector3.BACK * float_parse(v[0])
	return Vector3(float_parse(v[0]), float_parse(v[1]), float_parse(v[2]))

func vec2_parse(from: String, u := VectorUsage.UNDEFINED) -> Vector2:
	from = string_parse(from)
	var v := from.split(' ')
	assert(len(v) == 2 || (len(v) == 1 && u != VectorUsage.UNDEFINED), from)
	if len(v) == 1:
		match u:
			VectorUsage.SCALE: return Vector2.ONE * float_parse(v[0])
			VectorUsage.ROTATION: return Vector2.DOWN * float_parse(v[0])
	return Vector2(float_parse(v[0]), float_parse(v[1]))

func ivec2_parse(from: String) -> Vector2i:
	from = string_parse(from)
	var v := from.split(' ')
	assert(len(v) == 2, from)
	return Vector2i(int_parse(v[0]), int_parse(v[1]))

var regex_float: RegEx = RegEx.create_from_string(r'^[+-]?[0-9.]*$')
func float_parse(from: String) -> float:
	from = string_parse(from)
	assert(regex_float.search(from), from)
	return float(from)

func bool_parse(from: String, strict := true) -> bool:
	from = string_parse(from).to_lower()
	if from == "yes": return true
	elif from == "no": return false
	else:
		var i := int_parse(from)
		assert(!strict || i == 0 || i == 1, from)
		return i > 0

#var regex_int = RegEx.create_from_string(r'^[+-]?[0-9]*$')
func int_parse(from: String) -> int:
	var f := float_parse(from)
	assert(fmod(f, 1) == 0)
	return int(f)
	#from = string_parse(from)
	#assert(regex_int.search(from), from)
	#return int(from)

#var regex_uint = RegEx.create_from_string(r'^[+]?[0-9]*$')
func uint_parse(from: String) -> int:
	var i := int_parse(from)
	assert(i >= 0)
	return i
	#from = string_parse(from)
	#assert(regex_uint.search(from), from)
	#return int(from)

func color_parse(from: String) -> Color:
	from = string_parse(from)
	var v := from.split(' ')
	assert(len(v) == 4, from)
	var c: Array[float] = [ 0, 1, 2, 3 ]
	for i in c:
		c[i] = float_parse(v[i])
	for e in c:
		if e > 1:
			for i in range(4): c[i] /= 255
			break
	return Color(c[0], c[1], c[2], c[3])

func curve_set(curve: Curve, i: Variant, from: String) -> Curve:
	assert(typeof(i) == TYPE_INT)
	from = string_parse(from)
	if !curve: curve = Curve.new()
	curve.add_point(vec2_parse(from))
	return curve

func vec3_to_color(v: Vector3) -> Color:
	return Color(v.x, v.y, v.z)

func curve3d_set(curve: PackedVector4Array, i: Variant, from: String, u := VectorUsage.UNDEFINED) -> PackedVector4Array:
	assert(typeof(i) == TYPE_INT)
	from = string_parse(from)
	if !curve: curve = PackedVector4Array()
	var s := from.split(' ', false, 1)
	assert(len(s) == 2, from)
	var t := float_parse(s[0])
	var v := vec3_parse(s[1], u)
	curve.append(Vector4(v.x, v.y, v.z, t))
	return curve

func curve2d_set(curve: PackedVector3Array, i: Variant, from: String, u := VectorUsage.UNDEFINED) -> PackedVector3Array:
	assert(typeof(i) == TYPE_INT)
	from = string_parse(from)
	if !curve: curve = PackedVector3Array()
	var s := from.split(' ', false, 1)
	assert(len(s) == 2, from)
	var t := float_parse(s[0])
	var v := vec2_parse(s[1], u)
	curve.append(Vector3(v.x, v.y, t))
	return curve

func gradient_set(grad: Gradient, i: Variant, from: String) -> Gradient:
	assert(typeof(i) == TYPE_INT)
	from = string_parse(from)
	if !grad: grad = Gradient.new()
	var s := from.split(' ', false, 1)
	assert(len(s) == 2, from)
	grad.add_point(float_parse(s[0]), color_parse(s[1]))
	return grad

var return_null: Callable = func() -> Object: return null
var return_array: Callable = func() -> Array: return []

func array_resize_to_fit(a: Array, i: Variant, f: Callable) -> void:
	assert(typeof(i) == TYPE_INT)
	var len_a := len(a)
	if len_a <= i:
		a.resize(i + 1)
		if f != return_null:
			for j in range(len_a, i + 1): a[j] = f.call()

func array_get(a: Array[Variant], i: Variant, f := return_null) -> Variant:
	assert(a != null)
	assert(typeof(i) == TYPE_INT)
	array_resize_to_fit(a, i, f)
	var res: Variant = a[i]
	if res == null: #&& f != return_null:
		res = f.call()
		a[i] = res
	return res

func array_set(a: Array, i: Variant, v: Variant, f := return_null) -> Array:
	assert(i >= 0)
	assert(typeof(i) == TYPE_INT)
	if a == null: a = []
	array_resize_to_fit(a, i, f)
	a[i] = v
	return a

func set_from_ini(ini: Dictionary[String, Array]) -> void: pass

func set_from_ini_section(section: Array) -> void:
	for entry: Array in section:
		self.set_from_ini_entry(entry[0], entry[1])

func set_from_ini_entry(key_array: Array, value: String) -> void: pass

func ini_load(import_path: String, strip_semicolons := false) -> Dictionary[String, Array]:
	var section: Array[Array] = []
	var section_name: String = "Default"
	var result: Dictionary[String, Array] = { "Default": section }
	var regex_section := RegEx.create_from_string(r'^\[(.*?)\]$')
	var regex_entry := RegEx.create_from_string(r'^(.*?)=("?)(.*?)\2$')
	var regex_key := RegEx.create_from_string(r'^([a-zA-Z\-_]*)(\d*)([a-zA-Z\-_]*)(\d*)([a-zA-Z\-_]*)(\d*)$')
	var regex_unk := RegEx.create_from_string(r'unk[0-9A-Z]{8}')
	var file := FileAccess.open(import_path, FileAccess.READ).get_as_text(true).split('\n', false)
	for line in file:

		if strip_semicolons:
			line = line.split(";", true, 2)[0]

		if line.is_empty() || line.begins_with("'"):
			continue

		var m: RegExMatch
		m = regex_section.search(line)
		if m:
			section = []
			section_name = m.strings[1]
			result[section_name] = section
			continue

		if regex_unk.search(line):
			continue

		m = regex_entry.search(line)
		assert(m != null)
		var key := m.strings[1].strip_edges()
		var value := m.strings[3].strip_edges()

		m = regex_key.search(key)
		assert(m != null, key)
		var key_array := []
		for i in range(1, len(m.strings)):
			if m.strings[i]:
				var t: Variant
				if i % 2: t = m.strings[i]
				else: t = int(m.strings[i])
				key_array.append(t)
		section.append([key_array, value])

	return result

func curve_is_invalid_or_is_always_equal_to_one(c: Curve) -> bool:
	if c && c.point_count > 0:
		for i in range(c.point_count):
			if c.get_point_position(i).y != 1:
				return false
	return true

func enum_parse(dict: Dictionary, from: String) -> int:
	from = string_parse(from)
	var d: Dictionary[String, int] = {}
	for key: String in dict.keys():
		d[key.to_lower()] = dict[key]
	var result := 0
	for key in from.split(",", false):
		key = key.to_lower()
		assert(key in d, 'Expected one of ["' + '", "'.join(d.keys()) + '"], got "' + key + '"')
		result = result | d[key]
	return result
