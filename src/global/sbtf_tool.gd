class_name SBTFTool
extends Object

const EXEC_PATH: String = "res://src/sbtftool/sbtftool"

static var repacked_nwf_path: String = "/home/misterichor/.steam/steam/ubuntu12_32/steamapps/content/app_357330/depot_357331/sbtf_pub.nwf"
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


static func _get_relative_path_to_schema() -> String:
	return _get_config_path_to_output().split("/")[-1].path_join("schema.xml")



static func get_global_tool_path() -> String:
	return str('"', OS.get_executable_path().get_base_dir().path_join(EXEC_PATH.trim_prefix("res://")), '"')



static func verify_nwf() -> int:
	return OS.execute(get_global_tool_path(), ["verify", _get_config_path_to_nwf()], _output, true)


static func unpack_nwf() -> int:
	prints(get_global_tool_path(), ["unpack", _get_config_path_to_nwf(), "-o", _get_config_path_to_output()])
	return OS.execute(get_global_tool_path(), ["unpack", _get_config_path_to_nwf(), "-o", _get_config_path_to_output()], _output, true)


static func repack_nwf() -> int:
	return OS.execute(get_global_tool_path(), ["repack", _get_config_path_to_schema(), _get_config_path_to_output(), repacked_nwf_path], _output, true)


static func generate_schema() -> int:
	return OS.execute(get_global_tool_path(), ["schema", _get_config_path_to_nwf(), _get_relative_path_to_schema()], _output, true)
