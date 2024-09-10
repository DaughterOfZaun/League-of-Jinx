class_name Data
extends Node3D

const HW2GD := 1. / 70. #0.014285714

func string_parse(from: String) -> String:
	return from

var res_path := "res://Data/Particles"
var res_cache = null
func get_from_cache(key: String) -> String:
	if res_cache == null:
		res_cache = {}
		var dir = DirAccess.open(res_path)
		dir.list_dir_begin()
		while true:
			var fname = dir.get_next()
			if fname == "": break
			if dir.current_is_dir(): continue
			var fname_lc := fname.to_lower()
			if fname_lc.ends_with(tex_ext)\
			|| fname_lc.ends_with(mesh_ext)\
			|| fname_lc.ends_with(effect_ext):
				res_cache[fname_lc] = fname
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
	return null #TODO:
	from = string_parse(from)
	from = from.to_lower().replace(bin_ext, out_ext).replace(txt_ext, out_ext)
	return load(res_path + "/" + get_from_cache(from))

enum VectorUsage { UNDEFINED, SCALE, ROTATION }
func vec3_parse(from: String, u := VectorUsage.UNDEFINED) -> Vector3:
	from = string_parse(from)
	var v := from.split(' ')
	assert(len(v) == 3 || (len(v) == 1 && u != VectorUsage.UNDEFINED))
	if len(v) == 1: match u:
		VectorUsage.SCALE:
			return Vector3.ONE * float_parse(v[0])
		VectorUsage.ROTATION:
			return Vector3.BACK * float_parse(v[0])
	return Vector3(float_parse(v[0]), float_parse(v[1]), float_parse(v[2]))

func vec2_parse(from: String) -> Vector2:
	from = string_parse(from)
	var v := from.split(' ')
	assert(len(v) == 2)
	return Vector2(float_parse(v[0]), float_parse(v[1]))

func ivec2_parse(from: String) -> Vector2i:
	from = string_parse(from)
	var v := from.split(' ')
	assert(len(v) == 2)
	return Vector2i(int_parse(v[0]), int_parse(v[1]))

var regex_float = RegEx.create_from_string(r'^[+-]?[0-9.]*$')
func float_parse(from: String) -> float:
	from = string_parse(from)
	assert(regex_float.search(from))
	return float(from)

func bool_parse(from: String) -> bool:
	from = string_parse(from)
	return int_parse(from) != 0

var regex_int = RegEx.create_from_string(r'^[+-]?[0-9]*$')
func int_parse(from: String) -> int:
	from = string_parse(from)
	assert(regex_int.search(from))
	return int(from)

var regex_uint = RegEx.create_from_string(r'^[+]?[0-9]*$')
func uint_parse(from: String) -> int:
	from = string_parse(from)
	assert(regex_uint.search(from))
	return int(from)

func color_parse(from: String) -> Color:
	from = string_parse(from)
	var v := from.split(' ')
	assert(len(v) == 4)
	var c: Array[float] = []; c.resize(4); for i in range(4): c[i] = float_parse(v[i])
	for e in c:
		if e > 1:
			for i in range(4): c[i] /= 255
			break
	return Color(c[0], c[1], c[2], c[3])

func curve_set(curve: Curve, i: int, from: String) -> Curve:
	from = string_parse(from)
	if !curve: curve = Curve.new()
	curve.add_point(vec2_parse(from))
	return curve

func vec3_to_color(v: Vector3) -> Color:
	return Color(v.x, v.y, v.z)

func curve3d_set(curve: Gradient, i: int, from: String, u := VectorUsage.UNDEFINED) -> Gradient:
	from = string_parse(from)
	if !curve: curve = Gradient.new()
	var s := from.split(' ', false, 1)
	assert(len(s) == 2)
	curve.add_point(float_parse(s[0]), vec3_to_color(vec3_parse(s[1], u)))
	return curve

func gradient_set(grad: Gradient, i: int, from: String) -> Gradient:
	from = string_parse(from)
	if !grad: grad = Gradient.new()
	var s := from.split(' ', false, 1)
	assert(len(s) == 2)
	grad.add_point(float_parse(s[0]), color_parse(s[1]))
	return grad

var return_null := func(): return null
var return_array := func(): return []

func array_resize_to_fit(a: Array, i: int, f: Callable):
	var len_a := len(a)
	if len_a <= i:
		a.resize(i + 1)
		if f != return_null:
			for j in range(len_a, i + 1): a[j] = f.call()

func array_get(a: Array, i: int, f := return_null):
	assert(a != null)
	array_resize_to_fit(a, i, f)
	var res = a[i]
	if res == null: #&& f != return_null:
		res = f.call()
		a[i] = res
	return res

func array_set(a: Array, i: int, v, f := return_null):
	assert(i >= 0)
	if a == null: a = []
	array_resize_to_fit(a, i, f)
	a[i] = v
	return a

func set_from_ini(ini: Dictionary):
	pass

func set_from_ini_section(section: Array):
	for entry in section:
		self.set_from_ini_entry(entry[0], entry[1])

func set_from_ini_entry(key_array: Array, value: String):
	pass

func ini_load(import_path: String) -> Dictionary:
	var result := {}
	var section: Array[Array]
	var section_name: String
	var regex_section := RegEx.create_from_string(r'^\[(.*?)\]$')
	var regex_entry := RegEx.create_from_string(r'^(.*?)=("?)(.*?)\2$')
	var regex_key := RegEx.create_from_string(r'^([a-zA-Z\-_]*)(\d*)([a-zA-Z\-_]*)(\d*)([a-zA-Z\-_]*)(\d*)$')
	var regex_unk := RegEx.create_from_string(r'unk[0-9A-Z]{8}')
	var file := FileAccess.open(import_path, FileAccess.READ).get_as_text(true).split('\n', false)
	for line in file:

		if line.begins_with("'"):
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
		var key := m.strings[1]
		var value := m.strings[3]

		m = regex_key.search(key)
		assert(m != null)
		var key_array := []
		for i in range(1, len(m.strings)):
			if m.strings[i]:
				var t; if i % 2: t = m.strings[i]
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
