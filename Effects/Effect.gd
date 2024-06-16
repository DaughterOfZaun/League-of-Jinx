@tool
class_name Effect
extends Node3D

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

func string_parse(from: String) -> String:
    return from

var tex_cache = null
const tex_format := ".webp"
func tex_parse(from: String) -> Texture2D:
    from = string_parse(from)
    var path := "res://Data/Particles"

    if tex_cache == null:
        tex_cache = {}
        var dir = DirAccess.open(path)
        dir.list_dir_begin()
        while true:
            var fname = dir.get_next()
            if fname == "": break
            if dir.current_is_dir(): continue
            var fname_lc := fname.to_lower()
            if fname_lc.ends_with(tex_format):
                tex_cache[fname_lc] = fname
    
    return load(path + "/" + tex_cache[from.to_lower().replace(".tga", tex_format)])

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
    if a == null: a = []
    array_resize_to_fit(a, i, f)
    a[i] = v
    return a

func set_from_ini_entry(key_array: Array, value: String):
    match key_array:
        ["MaterialOverride", var i, "BlendMode"]: pass
        ["MaterialOverride", var i, "Priority"]: pass
        ["MaterialOverride", var i, "SubMesh"]: pass
        ["MaterialOverride", var i, "Texture"]: pass
        ["MaterialOverrideTransMap"]: pass

func ini_load(import_path: String) -> Dictionary:
    var result := {}
    var section: Array[Array]
    var section_name: String
    var regex_section := RegEx.create_from_string(r'^\[(.*?)\]$')
    var regex_entry := RegEx.create_from_string(r'^(.*?)=("?)(.*?)\2$')
    var regex_key := RegEx.create_from_string(r'^([a-zA-Z\-]*)(\d*)([a-zA-Z\-]*)(\d*)([a-zA-Z\-]*)(\d*)$')
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
