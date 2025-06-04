class_name SBTFTool
extends Object

const EXEC_PATH: String = "res://sbtftool/sbtftool"
static var _output: Array = []:
	set(value):
		_output = value
		
		if not _output.is_empty():
			print(_output)



static func _get_config_path_to_output() -> String:
	return Config.path_to_output


static func _get_config_path_to_schema() -> String:
	return Config.path_to_output.path_join("schema.xml")


static func _get_config_path_to_nwf() -> String:
	return Config.path_to_nwf


static func _get_config_path_to_nwf_backup() -> String:
	return Config.path_to_nwf.get_base_dir().path_join("sbtf_pub_backup.nwf")


static func _get_relative_path_to_schema() -> String:
	return _get_config_path_to_output().split("/")[-1].path_join("schema.xml")



static func get_global_tool_path() -> String:
	return OS.get_executable_path().get_base_dir().path_join(EXEC_PATH.trim_prefix("res://"))


static func verify_nwf() -> int:
	return OS.execute(get_global_tool_path(), ["verify", _get_config_path_to_nwf()], _output, true)


static func unpack_nwf() -> int:
	if FileAccess.open(_get_config_path_to_nwf_backup(), FileAccess.READ):
		print("Backup nwf file found.")
		return OS.execute(get_global_tool_path(), ["unpack", _get_config_path_to_nwf_backup(), "-o", _get_config_path_to_output()], _output, true)
	
	DirAccess.remove_absolute(_get_config_path_to_output())
	DirAccess.make_dir_absolute(_get_config_path_to_output())
	return OS.execute(get_global_tool_path(), ["unpack", _get_config_path_to_nwf(), "-o", _get_config_path_to_output()], _output, true)


static func repack_nwf() -> int:
	return OS.execute(get_global_tool_path(), ["repack", _get_config_path_to_schema(), _get_config_path_to_output(), _get_config_path_to_nwf()], _output, true)


static func generate_schema() -> int:
	if FileAccess.open(_get_config_path_to_nwf_backup(), FileAccess.READ):
		print("Generating schema on backup nwf file.")
		return OS.execute(get_global_tool_path(), ["schema", _get_config_path_to_nwf_backup(), _get_relative_path_to_schema()], _output, true)
	
	return OS.execute(get_global_tool_path(), ["schema", _get_config_path_to_nwf(), _get_relative_path_to_schema()], _output, true)
