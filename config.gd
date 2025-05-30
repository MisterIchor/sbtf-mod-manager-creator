extends Node

const DEFAULT_PATH: String = "user://sbtf_mod_manager.cfg"

var path_to_nwf: String = "":
	set(value):
		path_to_nwf = value
		save()
var mods_folder: String = "":
	set(value):
		mods_folder = value
		save()
var mod_order: PackedStringArray = []:
	set(value):
		mod_order = value
		save()



func create() -> Error:
	var config: ConfigFile = ConfigFile.new()
	return config.save(DEFAULT_PATH)


func save() -> Error:
	var config: ConfigFile = ConfigFile.new()
	var err_code: int = config.load(DEFAULT_PATH)
	
	if not err_code == OK:
		return err_code
	
	config.set_value("General", "path_to_nwf", path_to_nwf)
	config.set_value("General", "mods_folder", mods_folder)
	
	for i in mod_order.size():
		config.set_value("Mod Order", str("mod[", i, "]"), mod_order[i])
	
	return err_code


func load() -> Error:
	var config: ConfigFile = ConfigFile.new()
	var err_code: Error = config.load(DEFAULT_PATH)
	
	if not err_code == OK:
		return err_code
	
	path_to_nwf = config.get_value("General", "path_to_nwf")
	mods_folder = config.get_value("General", "mods_folder")
	
	for i in config.get_section_keys("Mod Order"):
		mod_order.append(config.get_value("Mod Order", i))
	
	return err_code
