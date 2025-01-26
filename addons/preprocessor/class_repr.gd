class_name ClassRepr

var name: String
var parent_name: String
var parent: ClassRepr = null

var ignore: bool
var own_vars_count: int
var own_static_vars_count: int
func get_parent_vars_count() -> int:
    return (parent.get_parent_vars_count() + parent.own_vars_count) if parent else 0
func get_parent_static_vars_count() -> int:
    return (parent.get_parent_static_vars_count() + parent.own_static_vars_count) if parent else 0

var code: String
var code_after_preprocessing: String
var in_path: String
var out_path: String
var changed: bool
var _level: int = 0
func get_level() -> int:
    if _level != 0: return _level
    var current := self
    while current != null:
        current = current.parent
        _level += 1
    return _level