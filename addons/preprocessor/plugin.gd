@tool class_name Preprocessor extends EditorPlugin

func _build() -> bool:

	var classes: Array[ClassRepr] = []
	var named_classes: Dictionary[String, ClassRepr] = {}
	var stages: Array[PreprocessorStage] = [
		VarsToArrayStage.new(),
		#SkipSomeFramesStage.new(),
	]
	
	var in_files := Utils.get_all_files("res://", "gd", [])
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
	for cls in classes: parse_class_declaration(cls, named_classes)
	for cls in classes: set_class_parent(cls, named_classes)
	classes.sort_custom(func by_level(a: ClassRepr, b: ClassRepr) -> int:
		return a.get_level() < b.get_level())
	
	for i in stages.size():
		print('(%d/%d) processing...' % [ i + 1, stages.size() ])
		stages[i].process(classes, named_classes)
	
	print('postprocessing...')
	for cls in classes:
		cls.changed = cls.code != cls.code_after_preprocessing
		if cls.changed:
			cls.code = postprocess(cls.code)

	var da := DirAccess.create_temp("LoJ-Preprocessor")
	var temp_path := da.get_current_dir() + "/"
	#var temp_path := "/tmp/LoJ-Preprocessor/"
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

	#var packer := PCKPacker.new()
	#packer.pck_start(cache_path + "scripts.pck")
	#for cls in classes:
	#	if !cls.changed: continue
	#	packer.add_file(cls.in_path, cls.out_path)
	#packer.flush()

	var packer := ZIPPacker.new()
	packer.open(cache_path + "scripts.zip")
	for cls in classes:
		if !cls.changed: continue
		packer.start_file(cls.out_path.replace(temp_path, ""))
		packer.write_file(cls.code.to_utf8_buffer())
		packer.close_file()
	packer.close()
	
	return true

var strings: Array[StringRepr]
class StringRepr extends RefCounted:
	var quote: String
	var value: String
	func _init(quote: String, value: String) -> void:
		self.quote = quote
		self.value = value
	#func _to_string() -> String:
	func raw() -> String:
		return quote + value + quote

var string_or_comment_regex: RegEx = RegEx.create_from_string(r"('|\"|\"\"\")((?:\\.|.|\n)*?)\1|\n?[\t ]*#(?!@).*")
var linebreak_regex: RegEx = RegEx.create_from_string(r"\\\n[\t ]*")
var bracket_regex: RegEx = RegEx.create_from_string(r"([(\[{])[\n\t ]*|[\n\t ]*([\]})])")
var comma_regex: RegEx = RegEx.create_from_string(r"(,)[\n\t ]*")
func preprocess(code: String) -> String:
	code = Utils.str_replace(code, string_or_comment_regex, func replace_str(match: RegExMatch) -> String:
		if !match.strings[1]: return ''
		var key := "STRING_" + str(strings.size())
		var string := StringRepr.new(match.strings[1], match.strings[2])
		strings.append(string)
		return key)
	code = linebreak_regex.sub(code, " ", true)
	code = bracket_regex.sub(code, "$1$2", true)
	code = comma_regex.sub(code, "$1 ", true)
	return code.strip_edges() + "\n"

var replaced_string_regex: RegEx = RegEx.create_from_string(r"STRING_(\d+)")
func postprocess(code: String) -> String:
	code = Utils.str_replace(code, replaced_string_regex, func restore_str(match: RegExMatch) -> String:
		var key := int(match.strings[1])
		return strings[key].raw())
	return code

var class_name_regex: RegEx = RegEx.create_from_string(r"^(?:@(tool)[\n ])?(?:class_name (\w+)[\n ])?(?:extends (\w+)[\n ])?((?:#@\w+[\n ])*)")
func parse_class_declaration(cls: ClassRepr, named_classes: Dictionary[String, ClassRepr]) -> void:
	var match := class_name_regex.search(cls.code)
	#if match != null:
	#var cls_decl := match.strings[0]
	#var cls_mod := match.strings[1]
	var cls_name := match.strings[2]
	var cls_parent := match.strings[3]
	var cls_tags := match.strings[4]
	if cls_name:
		cls.name = cls_name
		named_classes[cls_name] = cls
	if cls_parent:
		cls.parent_name = cls_parent
	cls.tags = Utils.split_tags(cls_tags)
	cls.is_rollback = cls.tags.has("rollback") || cls.in_path.begins_with("res://data/")
	#print("class_name ", cls.name, " extends ", cls.parent_name, " #@" + " #@".join(cls.tags))

func set_class_parent(cls: ClassRepr, named_classes: Dictionary[String, ClassRepr]) -> void:
	if cls.parent_name:
		cls.parent = named_classes.get(cls.parent_name, null)
