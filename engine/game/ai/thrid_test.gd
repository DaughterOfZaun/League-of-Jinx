class_name ThridTest extends Node

func _init() -> void:
	for path in get_all_files("res://", "gd"):
		script_path = path
		var gd: GDScript = ResourceLoader.load(path)
		gd.source_code = preprocess(gd.source_code)
		var err := gd.reload()
		#print(err)

const save_state_method_name = &"save_state"
@onready var root: Node = get_tree().current_scene #.find_child("Ahri", false, false)
func _physics_process(delta: float) -> void:
	root.propagate_call(save_state_method_name)

#var _vars: Array[Variant] = []
#var _history: Array[Variant] = []
#func save_state() -> void:
#	_history.assign(_vars)

var i: int
var script_path: String
var initial_values: String
var var_regex: RegEx = RegEx.create_from_string(r"(?<=\n)(?:@(onready|export) )?var (\w+)(?:: ([\w.\[\]]+))?(?: :?= (.*(?:\\\n.*)*))?(?=\n)")
var init_or_eof_regex: RegEx = RegEx.create_from_string(r"(?<=\n)func _init\((.*?)\) -> void:(?=\n)|$")
var comment_regex: RegEx = RegEx.create_from_string(r" *#.*?(?=\n)")
func preprocess(code: String) -> String:
	i = -1; initial_values = ""
	code = comment_regex.sub(code, "")
	code = str_replace(code, var_regex, preprocess_var)
	code += "\nvar _vars: Array[Variant] = [" + initial_values + "]\n"
	code += "\nvar _history: Array[Variant] = []\n"
	code += "\nfunc save_state() -> void:\n\t_history.assign(_vars)"
	code = init_or_eof_regex.sub(code, "\nfunc _init($1) -> void:\n\t_vars.resize(" + str(i + 1) + ")\n")
	#if code.begins_with("class_name Map1_LevelScript extends Level"):
	#	breakpoint
	return code

func preprocess_var(match: RegExMatch) -> String:
	i += 1;
	var var_decl := match.strings[0]
	var var_mod := match.strings[1]
	var var_name := match.strings[2]
	var var_type := match.strings[3]
	var var_value := match.strings[4]

	assert(var_type, script_path + ':' + var_name)
	#if !var_type: var_type = "Variant"
	
	if var_value:
		initial_values += var_value
	elif var_type:
		if var_type == "bool":
			initial_values += "false"
		elif var_type == "int":
			initial_values += "0"
		elif var_type == "float":
			initial_values += "0.0"
		else:
			initial_values += "null"
	initial_values += ", "
	var_decl = "var " + var_name + ": " + var_type
	var_decl += ":\n\tget: return _vars[" + str(i) + "]\n\tset(v): _vars[" + str(i) + "] = v\n"
	return var_decl

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
		file_name = dir.get_next()
	
	return files
