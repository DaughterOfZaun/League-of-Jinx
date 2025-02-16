class_name SkipSomeFramesStage extends PreprocessorStage

#func _physics_process(delta: float) -> void:
var process_regex: RegEx = RegEx.create_from_string(r"(?<=^|\n)func _physics_process\((\w+)(?:: float)?\)(?: -> void)?:\n")
func process_class(cls: ClassRepr) -> void:
	if cls.name == "Balancer": return

	var repl := "$0\n"
	if cls.code.contains("#@rollback"):
		repl += "	if !Balancer.is_ff && Engine.get_physics_frames() % 16 != 1: return\n"
	else:
		repl += "	if Engine.get_physics_frames() % 16 != 1: return\n"
	repl += "	$1 *= 16 / Engine.time_scale\n"
	cls.code = process_regex.sub(cls.code, repl)