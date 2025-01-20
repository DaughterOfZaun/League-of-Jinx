class_name ThridTest extends Node

func _init() -> void:
	var gds: Array[GDScript] = []
	#var files := get_all_files("res://", "gd")
	var files: Array[String] = [
		"res://engine/unit/unit.gd",
		#"res://engine/unit/champion.gd",
	]
	for path in files:
		var gd: GDScript = ResourceLoader.load(path)
		gds.append(gd)
	for gd in gds:
		script_path = gd.resource_path
		print("Patching %s." % script_path)
		gd.source_code = preprocess(gd.source_code)
	for gd in gds:
		var error := gd.reload()
		if error != Error.OK:
			print(gd.resource_path, ': ', error_string(error))

const save_state_method_name = &"save_state"
@onready var root: Node = get_tree().current_scene #.find_child("Ahri", false, false)
func _physics_process(delta: float) -> void:
	root.propagate_call(save_state_method_name)

var var_i: int
var static_var_i: int
var script_path: String
var initial_values: Array[String]
var onready_values: Dictionary[int, String]
var static_values: Array[String]
var strings: Array[String]

var string_or_comment_regex: RegEx = RegEx.create_from_string(r"('|\"|\"\"\")(?:\\.|.|\n)*?\1|\n?[\t ]*#.*")
var linebreak_regex: RegEx = RegEx.create_from_string(r"\\\n[\t ]*")
var bracket_regex: RegEx = RegEx.create_from_string(r"([(\[])\n[\t ]*|[\t ]*\n([\])])")
var comma_regex: RegEx = RegEx.create_from_string(r"(,)\n[\t ]*")
var var_regex: RegEx = RegEx.create_from_string(r"(?<=^|\n)(?:@?(onready|export|static) )?var (\w+)(?:: ([\w.\[,\]]+))?(?: :?= (.*))?(?<!:)(?=\n|$)")
var init_or_eof_regex_src: String = r"(?<=^|\n)func _init\((.*?)\) -> void:(?=\n)|$"
var init_or_eof_regex: RegEx = RegEx.create_from_string(init_or_eof_regex_src)
var ready_or_eof_regex: RegEx = RegEx.create_from_string(init_or_eof_regex_src.replace("_init", "_ready"))
var static_init_or_eof_regex: RegEx = RegEx.create_from_string(init_or_eof_regex_src.replace("func _init", "static func _static_init"))
var replaced_string_regex: RegEx = RegEx.create_from_string(r"STRING_(\d+)")

func preprocess(code: String) -> String:
	
	var_i = 0
	static_var_i = 0
	initial_values = []
	onready_values = {}
	static_values = []
	strings = []

	code = str_replace(code, string_or_comment_regex, replace_str)
	code = linebreak_regex.sub(code, " ", true)
	code = bracket_regex.sub(code, "$1$2", true)
	code = comma_regex.sub(code, "$1 ", true)
	code = str_replace(code, var_regex, preprocess_var)
	#if !code.ends_with("\n"): code += "\n"

	static_var_i = static_values.size()
	if static_var_i > 0:
		var init_code := "\n\n"
		init_code += "static var _static_vars: Array[Variant] = []\n"
		init_code += "static func _static_init($1) -> void:\n"
		init_code += "\t_static_vars.resize(" + str(static_var_i) + ")\n"
		for i in range(static_var_i):
			init_code += "\t_static_vars[" + str(i) + "] = " + static_values[i].replace("$", "$$") + "\n"
		code = static_init_or_eof_regex.sub(code, init_code, false)

	var_i = initial_values.size()
	if var_i > 0:
		var init_code := "\n\n"
		init_code += "var _vars: Array[Variant] = []\n"
		init_code += "func _init($1) -> void:\n"
		init_code += "\t_vars.resize(" + str(var_i) + ")\n"
		for i in range(var_i):
			init_code += "\t_vars[" + str(i) + "] = " + initial_values[i].replace("$", "$$") + "\n"
		code = init_or_eof_regex.sub(code, init_code, false)

	if !onready_values.is_empty():
		var init_code := "\n\n"
		init_code += "func _ready($1) -> void:\n"
		for i in onready_values:
			init_code += "\t_vars[" + str(i) + "] = " + onready_values[i].replace("$", "$$") + "\n"
		code = ready_or_eof_regex.sub(code, init_code, false)

	code = str_replace(code, replaced_string_regex, restore_str)
	
	if code.begins_with("class_name Unit extends Node3DExt"):
		breakpoint
	
	return code

func replace_str(match: RegExMatch) -> String:
	if !match.strings[1]: return ''
	var key := "STRING_" + str(strings.size())
	var value := match.strings[0]
	strings.append(value)
	return key

func restore_str(match: RegExMatch) -> String:
	var key := int(match.strings[1])
	return strings[key]

func preprocess_var(match: RegExMatch) -> String:
	var var_decl := match.strings[0]
	var var_mod := match.strings[1]
	var var_name := match.strings[2]
	var var_type := match.strings[3]
	var var_value := match.strings[4]

	assert(var_type, script_path + ':' + var_name)
	#if !var_type: var_type = "Variant"
	
	if var_mod == "onready":
		onready_values[var_i] = var_value
		var_value = ""

	var initial_value: String
	if var_value: initial_value = var_value
	elif var_type: initial_value = get_initial_value(var_type)
	
	if var_type.begins_with("Array") || var_type.begins_with("Dictionary"):
		initial_value = initial_value + " as " + var_type
	
	if var_mod == "static":
		static_values.append(initial_value)
	else:
		initial_values.append(initial_value)

	var_decl = ""
	#if var_mod in ["static", "export"]:
	if var_mod != "" && var_mod != "onready":
		#if var_mod in ["export", "onready"]:
		if var_mod == "export":
			var_decl += "@"
		var_decl += var_mod + " "
	
	var_decl += "var " + var_name + ": " + var_type + ":\n"
	if var_mod == "static":
		var_decl += "\tget: return _static_vars[" + str(static_var_i) + "]\n"
		var_decl += "\tset(v): _static_vars[" + str(static_var_i) + "] = v\n"
		static_var_i += 1
	else:
		var_decl += "\tget: return _vars[" + str(var_i) + "]\n"
		var_decl += "\tset(v): _vars[" + str(var_i) + "] = v\n"
		var_i += 1
	
	return var_decl

func get_initial_value(var_type: String) -> String:
	var initial_value := "null"
	if var_type == "bool": initial_value = "false"
	elif var_type == "int": initial_value = "0"
	elif var_type == "float": initial_value = "0.0"
	return initial_value

# https://gamedev.stackexchange.com/a/206584
func str_replace(target: String, regex: RegEx, cb: Callable) -> String:
	var out := ""
	var last_pos := 0
	for regex_match in regex.search_all(target):
		var start := regex_match.get_start()
		out += target.substr(last_pos, start - last_pos)
		out += str(cb.call(regex_match))
		last_pos = regex_match.get_end()
	out += target.substr(last_pos)
	return out

# https://gist.github.com/hiulit/772b8784436898fd7f942750ad99e33e?permalink_comment_id=5196503#gistcomment-5196503
func get_all_files(path: String, file_ext := "", files : Array[String] = []) -> Array[String]:
	var dir := DirAccess.open(path)
	#if file_ext.begins_with("."):
	#	file_ext = file_ext.substr(1, file_ext.length() - 1)
	
	if DirAccess.get_open_error() != OK:
		push_error("An error occurred when trying to access %s." % path)
		return files

	dir.list_dir_begin()

	while true:
		var file_name := dir.get_next()
		if file_name == "": break
		if dir.current_is_dir():
			files = get_all_files(dir.get_current_dir() + "/" + file_name, file_ext, files)
		elif !file_ext or file_name.get_extension() == file_ext:
			files.append(dir.get_current_dir() + "/" + file_name)
	
	return files
