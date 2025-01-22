@tool class_name Preprocessor extends EditorPlugin

func _build() -> bool:
	
	var in_files := get_all_files("res://", "gd")
	var size := in_files.size()
	
	print('reading...')
	var codes: PackedStringArray = []; codes.resize(size)
	for i in size:
		var fa := FileAccess.open(in_files[i], FileAccess.READ)
		codes[i] = fa.get_as_text()
		fa.close()
	var codes_orig := codes.duplicate()

	print('preprocessing...')
	for i in size:
		codes[i] = preprocess(codes[i])
	var codes_preprocessed := codes.duplicate()
	
	print('(1/3) processing...')
	var changed: PackedByteArray = []; changed.resize(size)
	for i in size:
		script_path = in_files[i]
		codes[i] = process_0(codes[i])
		#changed[i] = codes[i] != codes_orig[i]
	print('(2/3) processing...')
	for i in size:
		codes[i] = process_1(codes[i], changed[i])
		#changed[i] = codes[i] != codes_orig[i]
	print('(3/3) processing...')
	for i in size:
		codes[i] = process_2(codes[i], changed[i])
		#changed[i] = codes[i] != codes_orig[i]

	print('postprocessing...')
	for i in size:
		#if !changed[i]: continue
		codes[i] = postprocess(codes[i])

	print('writing...')
	var out_files: PackedStringArray = []; out_files.resize(size)
	for i in size:
		#if !changed[i]: continue
		out_files[i] = in_files[i].replace("res://", "res://engine/game/cache/scripts")
		DirAccess.make_dir_recursive_absolute(out_files[i].substr(0, out_files[i].rfind("/")))
		var fa := FileAccess.open(out_files[i], FileAccess.WRITE)
		if fa == null:
			push_error(out_files[i] + ": " + error_string(FileAccess.get_open_error()))
			return false
		fa.store_string(codes[i])
		fa.close()

	return false
		
	#print("Patching %s." % script_path)

	#for i in size:
	#	var gd: GDScript = ResourceLoader.load(out_files[i])
	#	gd.source_code = codes[i]
	#	var error := gd.reload()
	#	if error != Error.OK:
	#		print(gd.resource_path, ': ', error_string(error))
	#	gd.take_over_path(in_files[i])

var strings: Array[String]
var string_or_comment_regex: RegEx = RegEx.create_from_string(r"('|\"|\"\"\")(?:\\.|.|\n)*?\1|\n?[\t ]*#.*")
var linebreak_regex: RegEx = RegEx.create_from_string(r"\\\n[\t ]*")
var bracket_regex: RegEx = RegEx.create_from_string(r"([(\[])\n[\t ]*|[\t ]*\n([\])])")
var comma_regex: RegEx = RegEx.create_from_string(r"(,)\n[\t ]*")
func preprocess(code: String) -> String:
	code = str_replace(code, string_or_comment_regex, replace_str)
	code = linebreak_regex.sub(code, " ", true)
	code = bracket_regex.sub(code, "$1$2", true)
	code = comma_regex.sub(code, "$1 ", true)
	return code
func replace_str(match: RegExMatch) -> String:
	if !match.strings[1]: return ''
	var key := "STRING_" + str(strings.size())
	var value := match.strings[0]
	strings.append(value)
	return key

var replaced_string_regex: RegEx = RegEx.create_from_string(r"STRING_(\d+)")
func postprocess(code: String) -> String:
	code = str_replace(code, replaced_string_regex, restore_str)
	return code
func restore_str(match: RegExMatch) -> String:
	var key := int(match.strings[1])
	return strings[key]

var var_i: int
var static_var_i: int
var script_path: String
var initial_values: Array[String]
var onready_values: Dictionary[int, String]
var static_values: Array[String]
var var_regex: RegEx = RegEx.create_from_string(r"(?<=^|\n)(?:@?(onready|export|static) )?var (\w+)(?:: ([\w.\[,\]]+))?(?: :?= (.*))?(?<!:)(?=\n|$)")
var init_or_eof_regex_src: String = r"(?<=^|\n)func _init\((.*?)\) -> void:(?=\n)|$"
var init_or_eof_regex: RegEx = RegEx.create_from_string(init_or_eof_regex_src)
var ready_or_eof_regex: RegEx = RegEx.create_from_string(init_or_eof_regex_src.replace("_init", "_ready"))
var static_init_or_eof_regex: RegEx = RegEx.create_from_string(init_or_eof_regex_src.replace("func _init", "static func _static_init"))
func process_0(code: String) -> String:
	
	var_i = 0
	static_var_i = 0
	initial_values = []
	onready_values = {}
	static_values = []

	code = str_replace(code, var_regex, process_var)
	#if !code.ends_with("\n"): code += "\n"

	static_var_i = static_values.size()
	if static_var_i > 0:
		var init_code := "\n\n"
		init_code += "static var _static_vars: Array[Variant] = []\n"
		init_code += "static func _static_init($1) -> void:\n"
		init_code += "\t_static_vars.resize(" + str(static_var_i) + ")\n"
		for i in range(static_var_i):
			var initial_value := static_values[i].replace("$", "$$")
			init_code += "\t_static_vars[" + str(i) + "] = " + initial_value + "\n"
		code = static_init_or_eof_regex.sub(code, init_code, false)

	var_i = initial_values.size()
	if var_i > 0:
		var init_code := "\n\n"
		init_code += "var _vars: Array[Variant] = []\n"
		init_code += "func _init($1) -> void:\n"
		init_code += "\t_vars.resize(" + str(var_i) + ")\n"
		for i in range(var_i):
			var initial_value := initial_values[i].replace("$", "$$")
			init_code += "\t_vars[" + str(i) + "] = " + initial_value + "\n"
		code = init_or_eof_regex.sub(code, init_code, false)

	if !onready_values.is_empty():
		var init_code := "\n\n"
		init_code += "func _ready($1) -> void:\n"
		for i in onready_values:
			init_code += "\t_vars[" + str(i) + "] = " + onready_values[i].replace("$", "$$") + "\n"
		code = ready_or_eof_regex.sub(code, init_code, false)

	#if code.begins_with("class_name Unit"):
	#	breakpoint
	
	return code

func process_var(match: RegExMatch) -> String:
	var var_decl := match.strings[0]
	var var_mod := match.strings[1]
	var var_name := match.strings[2]
	var var_type := match.strings[3]
	var var_value := match.strings[4]

	assert(var_type, script_path + ':' + var_name)
	#if !var_type: var_type = "Variant"
	
	if var_mod == "onready" && var_value != "":
		onready_values[var_i] = var_value
		var_value = ""

	var initial_value: String
	if var_value: initial_value = var_value
	elif var_type: initial_value = get_initial_value(var_type)
	
	if var_type.begins_with("Array") || var_type.begins_with("Dictionary"):
		if initial_value != "null":
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

var rgxs: Array[RegEx] = []
var new_cls_names: Array[String] = []
var class_name_regex: RegEx = RegEx.create_from_string(r"^(?:@(tool)[\n ])?class_name (\w+)")
func process_1(code: String, changed: bool) -> String:
	rgxs.clear()
	new_cls_names.clear()
	var match := class_name_regex.search(code)
	if match != null:
		var cls_decl := match.strings[0]
		var cls_mod := match.strings[1]
		var cls_name := match.strings[2]
		var rgx := RegEx.create_from_string(r"\b" + cls_name + r"\b")
		var new_cls_name := cls_name + "Preprocessed"
		new_cls_names.append(new_cls_name)
		rgxs.append(rgx)
	return code
func process_2(code: String, changed: bool) -> String:
	for i in rgxs.size():
		var rgx := rgxs[i]
		var new_cls_name := new_cls_names[i]
		code = rgx.sub(code, new_cls_name, true)
	return code

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
func get_all_files(path: String, file_ext := "", files : PackedStringArray = []) -> PackedStringArray:
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
