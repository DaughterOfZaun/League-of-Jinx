@tool class_name VarsToArrayStage extends PreprocessorStage

# Current limitations:
# - #@rollback class must be a Node in the SceneTree
# - no nested containers (Arrays/Dictionaries/Classes) allowed
# - no oneshot signals
# - no await

var var_regex: RegEx = RegEx.create_from_string(r"(?<=^|\n)(?:@?(onready|export|static) )?var (\w+)(?:: ([\w.\[, \]]+))?(?: :?= (.*))?(?=\n|$)(?<!:)")
var init_or_eof_regex_src: String = r"(?<=^|\n)func _init\((.*?)\) -> void:\n(?:\tsuper\._init\((.*?)\)(?=\n|$))?|$"
var init_or_eof_regex: RegEx = RegEx.create_from_string(init_or_eof_regex_src)
var ready_or_eof_regex: RegEx = RegEx.create_from_string(init_or_eof_regex_src.replace("_init", "_ready"))
var static_init_or_eof_regex: RegEx = RegEx.create_from_string(init_or_eof_regex_src.replace("func _init", "static func _static_init"))

func get_initial_value(var_type: String) -> String:
	var initial_value := "null"
	match var_type:

		"bool": initial_value = "false"
		"int": initial_value = "0"
		"float": initial_value = "0.0"
		"String": initial_value = "\"\""
		"Vector2", "Vector2i", "Vector3", "Vector3i", "Vector4", "Vector4i":
			initial_value = var_type + ".ZERO"
		"Rect2", "Rect2i",\
		"Transform2D", "Quaternion", "Basis", "Transform3D", "Projection":
			initial_value = var_type + ".IDENTITY"
		"Color": initial_value = "Color.BLACK"
		"StringName": initial_value = "&\"\""
		
		"Plane",\
		"AABB",\
		"NodePath",\
		"RID",\
		#"Object",\
		"Callable",\
		"Signal",\
		"PackedByteArray", "PackedInt32Array", "PackedInt64Array",\
		"PackedFloat32Array", "PackedFloat64Array",\
		"PackedStringArray",\
		"PackedVector2Array", "PackedVector3Array", "PackedVector4Array",\
		"PackedColorArray":
			initial_value = var_type + "()"

		_ when var_type.begins_with("Array"): initial_value = "[]"
		_ when var_type.begins_with("Dictionary"): initial_value = "{}"
		
		#TODO: Enums support
		_ when var_type.begins_with("Enums."): initial_value = "0"
		"MoveType": initial_value = "0" #HACK:

	return initial_value

var var_i: int
var static_var_i: int
func process_class(cls: ClassRepr) -> void:
	var code := cls.code
	
	var_i = 0
	static_var_i = 0
	var script_path := cls.in_path
	var initial_values: Array[String] = []
	var initial_names: Array[String] = []
	var onready_values: Dictionary[int, String] = {}
	var static_values: Array[String] = []
	var static_names: Array[String] = []
	
	var parent_var_i := cls.get_parent_vars_count()
	var parent_static_var_i := cls.get_parent_static_vars_count()
	
	if cls.is_rollback:\
	code = Utils.str_replace(code, var_regex, func process_var(match: RegExMatch) -> String:
		var var_decl := match.strings[0]
		var var_mod := match.strings[1]
		var var_name := match.strings[2]
		var var_type := match.strings[3]
		var var_value := match.strings[4]

		assert(var_type, script_path + ':' + var_name)
		#if !var_type: var_type = "Variant"
		
		var named_class: ClassRepr = named_classes.get(var_type)
		if named_class && !named_class.is_rollback:
			print('WARN:', cls.in_path, ':', var_name, ':', var_type)
		
		if var_mod == "onready" && var_value != "":
			onready_values[var_i] = var_value
			var_value = ""

		var initial_value: String
		if var_value: initial_value = var_value
		elif var_type:
			#if named_class && named_class.is_rollback:
			#	initial_value = "0"
			#else:
			initial_value = get_initial_value(var_type)
		
		if var_type.begins_with("Array") || var_type.begins_with("Dictionary"):
			if initial_value != "null":
				initial_value = initial_value + " as " + var_type

		var i := 0
		var vars_name := ""
		var id_name := ""
		if var_mod == "static":
			static_values.append(initial_value)
			static_names.append(var_name)
			i = parent_static_var_i + static_var_i
			vars_name = "_vars"
			id_name = "_static_id"
			static_var_i += 1
		else:
			initial_values.append(initial_value)
			initial_names.append(var_name)
			i = parent_var_i + var_i
			vars_name = "_vars"
			id_name = "_id"
			var_i += 1

		var_decl = ""
		if var_mod != "" && var_mod != "onready":
		##if var_mod in ["static", "export"]:
		#if var_mod == "static":
			##if var_mod in ["export", "onready"]:
			if var_mod == "export":
				var_decl += "@"
			var_decl += var_mod + " "
		
		var_decl += "var " + var_name + ": " + var_type + ":\n"
		#if named_class != null && named_class.is_rollback:
		#	var_decl += "	get: return Balancer.objs[" + vars_name + "[" + str(i) + "]]\n"
		#	var_decl += "	set(v): " + vars_name + "[" + str(i) + "] = v.get_meta(&\"id\") if v else 0\n"
		#else:
		var_decl += "	get: return Balancer." + vars_name + "[" + id_name + "][" + str(i) + "]\n"
		var_decl += "	set(v): Balancer." + vars_name + "[" + id_name + "][" + str(i) + "] = v\n"

		return var_decl
	)
		
	var_i = initial_values.size()
	cls.own_vars_count = var_i
	var has_init := code.contains("func _init")
	var parent_has_init := cls.parent.code.contains("func _init") if cls.parent else false
	if var_i > 0 || has_init && parent_has_init:
		code = Utils.str_replace_once(code, init_or_eof_regex, process_func.bind(
			"_vars", "_id", var_i, parent_var_i, initial_values, initial_names,
			"", "_init", parent_has_init,
			cls,
		))
		
	var has_ready := code.contains("func _ready")
	var parent_has_ready := cls.parent.code.contains("func _ready") if cls.parent else false
	if var_i > 0 && !onready_values.is_empty() || has_ready && parent_has_ready:
		code = Utils.str_replace_once(code, ready_or_eof_regex, process_func.bind(
			"_vars", "_id", 0, parent_var_i, onready_values, initial_names,
			"", "_ready", parent_has_ready,
			cls,
		))

	static_var_i = static_values.size()
	cls.own_static_vars_count = static_var_i
	var has_static_init := code.contains("static func _static_init")
	var parent_has_static_init := cls.parent.code.contains("static func _static_init") if cls.parent else false
	if static_var_i > 0 || has_static_init && parent_has_static_init:
		code = Utils.str_replace_once(code, static_init_or_eof_regex, process_func.bind(
			"_vars", "_static_id", static_var_i, parent_static_var_i, static_values, static_names,
			"static", "_static_init", parent_has_static_init,
			cls,
		))

	#if cls.is_rollback && !cls.contains("func _save"):
	#	code += "\n\nfunc _save() -> void: pass"
	#if cls.is_rollback && !cls.contains("func _load"):
	#	code += "\n\nfunc _load() -> void: pass"
	
	#code += "\n\n"
	#code += "func _notification(what: int) -> void:\n"
	#code += "	if what == NOTIFICATION_PREDELETE:\n"
	#code += "		Balancer.unregister(self)\n"

	cls.code = code

func process_func(
	match: RegExMatch,
	vars_name: String, id_name: String,
	var_i: int, parent_var_i: int,
	vars: Variant, names: Array[String],
	func_mod: String, func_name: String, parent_has_func: bool,
	cls: ClassRepr,
) -> String:

	var in_args := match.strings[1]
	var out_args := match.strings[2]

	var init_code := "\n\n"

	if func_name in ["_init", "_static_init"] && var_i > 0 && parent_var_i == 0:
		#if func_mod != "static":
		#	init_code += "@export "
		if func_mod: init_code += func_mod + " "
		#init_code += "var " + vars_name + ": Array[Variant] = []\n"
		init_code += "var " + id_name + ": int = 0\n"
	
	if func_mod: init_code += func_mod + " "
	init_code += "func " + func_name + "(" + in_args + ") -> void:\n"
	
	#if func_name in ["_init", "_static_init"]:	
	#	if var_i > 0:
	#		init_code += "	" + vars_name + ".resize(" + str(parent_var_i + var_i) + ")\n"

	if func_name == "_init":
		init_code += "	Balancer.register(self, " + str(parent_var_i + var_i) + ")\n"
	elif func_name == "_static_init":
		init_code += "	Balancer.register_static(" + cls.name + ", " + str(parent_var_i + var_i) + ")\n"

	if parent_has_func:
		init_code += "	super." + func_name + "(" + out_args + ")\n"
	
	var keys: Variant
	match typeof(vars):
		TYPE_ARRAY: keys = (vars as Array).size()
		TYPE_DICTIONARY: keys = (vars as Dictionary)
		_: assert(false)

	for i: int in keys:
		#init_code += "	" + vars_name + "[" + str(parent_var_i + i) + "] = " + vars[i] + "\n"
		init_code += "	" + names[i] + " = " + vars[i] + "\n"

	return init_code