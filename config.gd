extends Node

const DEFAULT_PATH: String = "user://sbtf_mod_manager.cfg"

var path_to_nwf: String = ""
var nwf: FileAccess = null
var mods: PackedStringArray = []



func create() -> Error:
	var config: ConfigFile = ConfigFile.new()
	
	config.set_value("General", "path_to_nwf", path_to_nwf)
	config.set_value("Mods", str("mod[0]"), null)
	return config.save(DEFAULT_PATH)


func save() -> Error:
	var config: ConfigFile = ConfigFile.new()
	var err_code: int = config.load(DEFAULT_PATH)
	
	if not err_code == OK:
		return err_code
	
	config.set_value("General", "path_to_nwf", path_to_nwf)
	
	for i in mods.size():
		config.set_value("Mods", str("mod[", i, "]"), mods[i])
	
	return err_code


func load() -> Error:
	var config: ConfigFile = ConfigFile.new()
	var err_code: Error = config.load(DEFAULT_PATH)
	
	if not err_code == OK:
		return err_code
	
	mods.clear()
	path_to_nwf = config.get_value("General", "path_to_nwf")
	
	for i in config.get_section_keys("Mods"):
		mods.append(config.get_value("Mods", i))
	
	return err_code
