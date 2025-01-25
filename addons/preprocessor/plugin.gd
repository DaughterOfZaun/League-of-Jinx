@tool extends EditorPlugin

const setting_replace_names := false

var classes: Array[ClassRepr] = []
var named_classes: Dictionary[String, ClassRepr] = {}
class ClassRepr:
	var name: String
	var name_regex: RegEx
	var name_replacement: String
	var parent_name: String
	var parent: ClassRepr = null
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
	var ignore: bool
	var changed: bool
	var _level: int = 0
	func get_level() -> int:
		if _level != 0: return _level
		var current := self
		while current != null:
			current = current.parent
			_level += 1
		return _level

func by_level(a: ClassRepr, b: ClassRepr) -> int:
	return a.get_level() < b.get_level()

func _build() -> bool:
	
	var in_files := get_all_files("res://", "gd", [])
	classes.resize(in_files.size())
	for i in in_files.size():
		var cls := ClassRepr.new()
		cls.in_path = in_files[i]
		classes[i] = cls
	
	print('reading...')
	for cls in classes:
		var fa := FileAccess.open(cls.in_path, FileAccess.READ)
		cls.code = fa.get_as_text()
		fa.close()
	
	print('preprocessing...')
	for cls in classes:
		cls.code = preprocess(cls.code)
		cls.code_after_preprocessing = cls.code
	
	print('(1/5) processing...')
	for cls in classes: parse_class_declaration(cls)
	for cls in classes: set_class_parent(cls)
	classes.sort_custom(by_level)
	print('(2/5) processing...')
	for cls in classes:
		if !cls.ignore:
			process_0(cls)
	print('(3/5) processing...')
	for cls in classes: fix_super_calls(cls)
	#for cls in classes:
	#	var vars_count := cls.own_vars_count + cls.get_parent_vars_count()
	#	var static_vars_count := cls.own_static_vars_count + cls.get_parent_static_vars_count()
	print('(4/5) processing...')
	replace_changed_class_names()
	#print('(5/5) processing...')
	#for cls in classes:
	#	if cls.changed:
	#		fix_relative_paths(cls)

	print('postprocessing...')
	for cls in classes:
		if cls.changed:
			cls.code = postprocess(cls.code)

	#var da := DirAccess.create_temp("LoJ-Preprocessor", false)
	#var da := DirAccess.create_temp("LoJ-Preprocessor")
	#var temp_path := da.get_current_dir() + "/"
	var temp_path := "/tmp/LoJ-Preprocessor/"
	var cache_path := "res://engine/game/cache/"
	print("Writing to %s." % temp_path)

	print('writing...')
	for cls in classes:
		if !cls.changed: continue
		cls.out_path = cls.in_path.replace("res://", temp_path) #.replace(".gd", ".txt")
		DirAccess.make_dir_recursive_absolute(cls.out_path.get_base_dir())
		var fa := FileAccess.open(cls.out_path, FileAccess.WRITE)
		if fa == null:
			push_error(cls.out_path + ": " + error_string(FileAccess.get_open_error()))
			return false
		fa.store_string(cls.code)
		fa.close()

	var pck_out_path := cache_path + "scripts.pck"

	var packer := PCKPacker.new()
	packer.pck_start(pck_out_path)
	for cls in classes:
		if cls.changed:
			packer.add_file(cls.in_path, cls.out_path)
	packer.flush()

	#edit_project_metadata(pck_out_path)

	#var code := "extends Node\n"
	#code += "\n"
	#code += "func _init() -> void:\n"
	#code += "	ProjectSettings.load_resource_pack(\"" + pck_out_path + "\")\n"
	#code += "\n"
	#var fa := FileAccess.open(cache_path + "loader.gd", FileAccess.WRITE)
	#fa.store_string(code)
	#fa.close()

	#setup_remaps()
	#generate_replacer_script()

	return true

func edit_project_metadata(pck_out_path: String) -> void:
	var es := EditorInterface.get_editor_settings()
	es.set_project_metadata("debug_options", "multiple_instances_enabled", true)
	es.set_project_metadata("debug_options", "run_instances_config", [{
		"override_args": true,
		"arguments": "--main-pack \"" + ProjectSettings.globalize_path(pck_out_path) + "\"",
		"override_features": false,
		"features": "",
	}] as Array[Dictionary])
	es.set_project_metadata("debug_options", "run_instance_count", 1.0)

func setup_remaps() -> void:
	const remaps_setting_name := "internationalization/locale/translation_remaps"
	var remaps = {} #ProjectSettings.get_setting(remaps_setting_name)
	for cls in classes:
		if cls.changed:
			remaps[cls.in_path] = PackedStringArray([ cls.out_path + ":en" ])
	ProjectSettings.set_setting(remaps_setting_name, remaps)
	ProjectSettings.save()

func generate_replacer_script() -> void:
	var out_path := "res://engine/game/cache/scripts/"

	var code := "extends Node\n"
	code += "\n"
	code += "func replace(path_a: String, path_b: String) -> void:\n"
	code += "	var gd_a: GDScript = load(path_a)\n"
	#code += "	var gd_b: GDScript = load(path_b)\n"
	#code += "	gd_a.source_code = gd_b.source_code\n"
	code += "	gd_a.source_code = FileAccess.get_file_as_string(path_b)\n"
	code += "	gd_a.reload(false)\n"
	code += "\n"
	code += "func _init() -> void:\n"
	for cls in classes:
		if cls.changed:
			code += '\treplace("' + cls.in_path + '", "' + cls.out_path + '")\n'
	
	var fa := FileAccess.open(out_path + "loader.gd", FileAccess.WRITE)
	fa.store_string(code)
	fa.close()
	
	#print("Patching %s." % script_path)

	#for i in size:
	#	var gd: GDScript = ResourceLoader.load(out_files[i])
	#	gd.source_code = codes[i]
	#	var error := gd.reload()
	#	if error != Error.OK:
	#		print(gd.resource_path, ': ', error_string(error))
	#	gd.take_over_path(in_files[i])

var strings: Array[StringRepr]
class StringRepr:
	var quote: String
	var value: String
	func _init(quote: String, value: String) -> void:
		self.quote = quote
		self.value = value
	#func _to_string() -> String:
	func raw() -> String:
		return quote + value + quote

var string_or_comment_regex: RegEx = RegEx.create_from_string(r"('|\"|\"\"\")((?:\\.|.|\n)*?)\1|\n?[\t ]*#.*")
var linebreak_regex: RegEx = RegEx.create_from_string(r"\\\n[\t ]*")
var bracket_regex: RegEx = RegEx.create_from_string(r"([(\[{])[\n\t ]*|[\n\t ]*([\]})])")
var comma_regex: RegEx = RegEx.create_from_string(r"(,)[\n\t ]*")
func preprocess(code: String) -> String:
	code = str_replace(code, string_or_comment_regex, replace_str)
	code = linebreak_regex.sub(code, " ", true)
	code = bracket_regex.sub(code, "$1$2", true)
	code = comma_regex.sub(code, "$1 ", true)
	return code
func replace_str(match: RegExMatch) -> String:
	if !match.strings[1]: return ''
	var key := "STRING_" + str(strings.size())
	var string := StringRepr.new(match.strings[1], match.strings[2])
	strings.append(string)
	return key

var replaced_string_regex: RegEx = RegEx.create_from_string(r"STRING_(\d+)")
func postprocess(code: String) -> String:
	code = str_replace(code, replaced_string_regex, restore_str)
	return code
func restore_str(match: RegExMatch) -> String:
	var key := int(match.strings[1])
	return strings[key].raw()

var var_i: int
var static_var_i: int
var script_path: String
var initial_values: Array[String]
var onready_values: Dictionary[int, String]
var static_values: Array[String]
var var_regex: RegEx = RegEx.create_from_string(r"(?<=^|\n)(?:@?(onready|export|static) )?var (\w+)(?:: ([\w.\[,\]]+))?(?: :?= (.*))?(?<!:)(?=\n|$)")
var preload_regex: RegEx = RegEx.create_from_string(r"\bpreload\(STRING_(\d+)\)")
var init_or_eof_regex_src: String = r"(?<=^|\n)func _init\((.*?)\) -> void:\n(\tsuper\._init\((.*?)\)(?=\n|$))?|$"
var init_or_eof_regex: RegEx = RegEx.create_from_string(init_or_eof_regex_src)
var ready_or_eof_regex: RegEx = RegEx.create_from_string(init_or_eof_regex_src.replace("_init", "_ready"))
var static_init_or_eof_regex: RegEx = RegEx.create_from_string(init_or_eof_regex_src.replace("func _init", "static func _static_init"))
var first_word_regex: RegEx = RegEx.create_from_string(r"^\w+\b")
func process_0(cls: ClassRepr) -> void:
	var code := cls.code
	var path := cls.in_path
	
	var_i = 0
	static_var_i = 0
	script_path = path
	initial_values = []
	onready_values = {}
	static_values = []
	
	var parent_var_i := cls.get_parent_vars_count()
	var parent_static_var_i := cls.get_parent_static_vars_count()
	code = str_replace(code, var_regex, process_var.bind(parent_var_i, parent_static_var_i))
	#if !code.ends_with("\n"): code += "\n"

	static_var_i = static_values.size()
	cls.own_static_vars_count = static_var_i
	if static_var_i > 0:
		var parent_has_static_init := cls.parent.code.contains("static func _init") if cls.parent else false
		code = str_replace_once(code, static_init_or_eof_regex, process_static_init.bind(parent_static_var_i, parent_has_static_init))
		
	var_i = initial_values.size()
	cls.own_vars_count = var_i
	if var_i > 0:
		var parent_has_init := cls.parent.code.contains("func _init") if cls.parent else false
		code = str_replace_once(code, init_or_eof_regex, process_init.bind(parent_var_i, parent_has_init))
		
		if !onready_values.is_empty():
			var parent_has_ready := cls.parent.code.contains("func _ready") if cls.parent else false
			code = str_replace_once(code, ready_or_eof_regex, process_ready.bind(parent_var_i, parent_has_ready))

	#if code.begins_with("class_name Unit"):
	#	breakpoint
	
	cls.code = code

func process_static_init(match: RegExMatch, parent_static_var_i: int, parent_has_static_init: bool) -> String:
	var in_args := match.strings[1]
	var out_args := match.strings[2]

	#TODO: assert(in_args.is_empty() == out_args.is_empty())

	var init_code := "\n\n"
	if static_var_i > 0 && parent_static_var_i == 0:
		init_code += "static var _static_vars: Array[Variant] = []\n"
	init_code += "static func _static_init(" + in_args + ") -> void:\n"
	if parent_has_static_init:
		init_code += "\tsuper._static_init(" + out_args + ")\n"
	if static_var_i > 0:
		init_code += "\t_static_vars.resize(" + str(parent_static_var_i + static_var_i) + ")\n"
		for i in range(static_var_i):
			init_code += "\t_static_vars[" + str(parent_static_var_i + i) + "] = " + static_values[i] + "\n"
	return init_code

func process_init(match: RegExMatch, parent_var_i: int, parent_has_init: bool) -> String:
	var in_args := match.strings[1]
	var out_args := match.strings[2]
	
	#TODO: assert(in_args.is_empty() == out_args.is_empty())
	
	var init_code := "\n\n"
	if var_i > 0 && parent_var_i == 0:
		init_code += "var _vars: Array[Variant] = []\n"
	init_code += "func _init(" + in_args + ") -> void:\n"
	init_code += "\tprint(\"patched _init called\")\n"
	if parent_has_init:
		init_code += "\tsuper._init(" + out_args + ")\n"
	if var_i > 0:
		init_code += "\t_vars.resize(" + str(parent_var_i + var_i) + ")\n"
		for i in range(var_i):
			init_code += "\t_vars[" + str(parent_var_i + i) + "] = " + initial_values[i] + "\n"
	return init_code

func process_ready(match: RegExMatch, parent_var_i: int, parent_has_ready: bool) -> String:
	var in_args := "" #match.strings[1]
	var out_args := "" #match.strings[2]
	
	#TODO: assert(in_args.is_empty() == out_args.is_empty())

	var init_code := "\n\n"
	init_code += "func _ready(" + in_args + ") -> void:\n"
	if parent_has_ready:
		init_code += "\tsuper._ready(" + out_args + ")\n"
	if var_i > 0:
		for i in onready_values:
			init_code += "\t_vars[" + str(parent_var_i + i) + "] = " + onready_values[i] + "\n"
	return init_code

func process_var(match: RegExMatch, parent_var_i: int, parent_static_var_i: int) -> String:
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
		var_decl += "\tget: return _static_vars[" + str(parent_static_var_i + static_var_i) + "]\n"
		var_decl += "\tset(v): _static_vars[" + str(parent_static_var_i + static_var_i) + "] = v\n"
		static_var_i += 1
	else:
		var_decl += "\tget: return _vars[" + str(parent_var_i + var_i) + "]\n"
		var_decl += "\tset(v): _vars[" + str(parent_var_i + var_i) + "] = v\n"
		var_i += 1
	
	return var_decl

func get_initial_value(var_type: String) -> String:
	var initial_value := "null"
	if var_type == "bool": initial_value = "false"
	elif var_type == "int": initial_value = "0"
	elif var_type == "float": initial_value = "0.0"
	elif var_type.begins_with("Array"): initial_value = "[]"
	elif var_type.begins_with("Dictionary"): initial_value = "{}"
	elif var_type == "String": initial_value = "\"\""
	elif var_type == "Vector3": initial_value = "Vector3.ZERO"
	return initial_value

var class_name_regex: RegEx = RegEx.create_from_string(r"^(?:@(tool)[\n ])?(?:class_name (\w+)[\n ])?(?:extends (\w+)[\n ])?")
func parse_class_declaration(cls: ClassRepr) -> void:
	var match := class_name_regex.search(cls.code)
	#if match != null:
	var cls_decl := match.strings[0]
	var cls_mod := match.strings[1]
	var cls_name := match.strings[2]
	var cls_parent := match.strings[3]
	if cls_name:
		cls.name = cls_name
		#cls.name_regex = RegEx.create_from_string(r"(?<!\.|var |const |func |enum |signal |class )\b" + cls_name + r"\b")
		#cls.name_regex = RegEx.create_from_string(r"(?<!\.|\b(?:var|const|func|enum|signal|class|class_name|extends) )\b" + cls_name + r"\b")
		cls.name_regex = RegEx.create_from_string(r"(?<=: ?)" + cls_name + r"\b(\.\w+)*")
		cls.name_replacement = cls_name + "Preprocessed"
		named_classes[cls_name] = cls
	if cls_parent:
		cls.parent_name = cls_parent
	#cls.ignore = cls_name != "Unit"

func set_class_parent(cls: ClassRepr) -> void:
	if cls.parent_name:
		cls.parent = named_classes.get(cls.parent_name, null)
	
func fix_relative_paths(cls: ClassRepr) -> void:
	var base_dir := cls.in_path.get_base_dir()
	for match in preload_regex.search_all(cls.code):
		var key := int(match.strings[1])
		var string := strings[key]
		if !string.value.begins_with("res://"):
			strings[key].value = base_dir + "/" + string.value

func fix_super_calls(cls: ClassRepr) -> void:
	var_i = cls.own_vars_count
	static_var_i = cls.own_static_vars_count
	var code := cls.code
	var parent_var_i := cls.get_parent_vars_count()
	var parent_static_var_i := cls.get_parent_static_vars_count()
	var has_init := cls.code.contains("func _init")
	var has_ready := cls.code.contains("func _ready")
	var has_static_init := cls.code.contains("static func _init")
	var parent_has_init := cls.parent.code.contains("func _init") if cls.parent else false
	var parent_has_ready := cls.parent.code.contains("func _ready") if cls.parent else false
	var parent_has_static_init := cls.parent.code.contains("static func _init") if cls.parent else false
	if var_i == 0 && has_init && parent_has_init:
		code = str_replace_once(code, init_or_eof_regex, process_init.bind(parent_var_i, parent_has_init))
	if var_i == 0 && has_ready && parent_has_ready:
		code = str_replace_once(code, ready_or_eof_regex, process_ready.bind(parent_var_i, parent_has_ready))
	if static_var_i == 0 && has_static_init && parent_has_static_init:
		code = str_replace_once(code, static_init_or_eof_regex, process_static_init.bind(parent_static_var_i, parent_has_static_init))
	cls.code = code

func replace_changed_class_names() -> void:
	while true:
		var changes_made := false
		for cls_a in classes:
			
			#for cls_b in classes:
			#	if cls_b.name && cls_b.name_regex:
			#		cls_a.code = cls_b.name_regex.sub(cls_a.code, "Variant", true)
			#cls_a.code = cls_a.code.replace("@export ", "")
			#cls_a.code = cls_a.code.replace(":=", "=")
			#cls_a.code = '@warning_ignore_start("unsafe_property_access")\n' + cls_a.code
			#cls_a.code = '@warning_ignore_start("unsafe_method_access")\n' + cls_a.code
			#cls_a.code = '@warning_ignore_start("untyped_declaration")\n' + cls_a.code

			if !cls_a.changed && cls_a.code != cls_a.code_after_preprocessing:
				cls_a.changed = true
				#if setting_replace_names:
				#if cls_a.name && cls_a.name_regex && cls_a.name_replacement:
				#	for cls_b in classes:
				#		cls_b.code = cls_a.name_regex.sub(cls_b.code, cls_a.name_replacement, true)
				#	changes_made = true
		if !changes_made: break

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

func str_replace_once(target: String, regex: RegEx, cb: Callable) -> String:
	var out := ""
	var last_pos := 0
	var regex_match := regex.search(target)
	if regex_match:
		var start := regex_match.get_start()
		out += target.substr(last_pos, start - last_pos)
		out += str(cb.call(regex_match))
		last_pos = regex_match.get_end()
	out += target.substr(last_pos)
	return out

# https://gist.github.com/hiulit/772b8784436898fd7f942750ad99e33e?permalink_comment_id=5196503#gistcomment-5196503
func get_all_files(path: String, file_ext := "", files : PackedStringArray = []) -> PackedStringArray:
	if path.ends_with("/engine/game/cache"): return files #HACK:
	
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
		var file_path := dir.get_current_dir().path_join(file_name)
		if dir.current_is_dir():
			files = get_all_files(file_path, file_ext, files)
		elif !file_ext or file_name.get_extension() == file_ext:
			files.append(file_path)
	
	return files
