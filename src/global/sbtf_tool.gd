class_name SBTFTool
extends Object

const EXEC_PATH: String = "res://sbtftool/sbtftool"
const OUTPUT_PATH: String = "user://output"

static var repacked_nwf_path: String = ""
static var _output: Array = []:
	set(value):
		_output = value
		
		if not _output.is_empty():
			print(_output)



static func _get_global_tool_path() -> String:
	return ProjectSettings.globalize_path(EXEC_PATH)


static func _get_global_user_path() -> String:
	return ProjectSettings.globalize_path(OUTPUT_PATH)



static func verify_nwf() -> int:
	return OS.execute(_get_global_tool_path(), ["verify", Config.path_to_nwf], _output, true)


static func unpack_nwf() -> int:
	return OS.execute(_get_global_tool_path(), ["unpack", Config.path_to_nwf, _get_global_user_path()], _output, true)


static func repack_nwf() -> int:
	return OS.execute(_get_global_tool_path(), ["repack", _get_global_user_path() + "schema.xml", _get_global_user_path(), repacked_nwf_path], _output, true)


static func generate_schema() -> int:
	return OS.execute(_get_global_tool_path(), ["schema", Config.path_to_nwf, _get_global_user_path()], _output, true)
