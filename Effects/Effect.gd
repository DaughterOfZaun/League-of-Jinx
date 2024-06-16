class_name Effect
extends Node3D

func tex_parse(from: String) -> Texture2D: return null
func vec3_parse(from: String) -> Vector3: return Vector3.ZERO
func vec2_parse(from: String) -> Vector2: return Vector2.ZERO
func ivec2_parse(from: String) -> Vector2i: return Vector2i.ZERO
func string_parse(from: String) -> String: return ""
func float_parse(from: String) -> float: return 0
func bool_parse(from: String) -> bool: return false
func int_parse(from: String) -> int: return 0
func uint_parse(from: String) -> int: return 0
func color_parse(from: String) -> Color: return Color.BLACK

func curve_set(curve: Curve, from: String) -> Curve: return null
func curve3d_set(curve: Curve3D, from: String) -> Curve3D: return null
func gradient_set(curve: Gradient, from: String) -> Gradient: return null

func array_get(a: Array, i: int): return a[i]
func array_set(a: Array, i: int, v): a[i] = v