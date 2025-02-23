class_name Utils

static func split_tags(tags: String) -> PackedStringArray:
	return tags.strip_edges().substr(2).split(" #@", false)

# https://gamedev.stackexchange.com/a/206584
static func str_replace(target: String, regex: RegEx, cb: Callable) -> String:
	var out := ""
	var last_pos := 0
	for regex_match in regex.search_all(target):
		var start := regex_match.get_start()
		out += target.substr(last_pos, start - last_pos)
		out += str(cb.call(regex_match))
		last_pos = regex_match.get_end()
	out += target.substr(last_pos)
	return out

static func str_replace_once(target: String, regex: RegEx, cb: Callable) -> String:
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
static func get_all_files(path: String, file_ext := "", files : PackedStringArray = []) -> PackedStringArray:
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
