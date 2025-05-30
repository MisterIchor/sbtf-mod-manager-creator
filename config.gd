class_name Config
extends Object

const DEFAULT_PATH: String = "user://sbtf_mod_manager.cfg"

static var path_to_nwf: String = "":
	set(value):
		path_to_nwf = value
		save()
static var mods_folder: String = "":
	set(value):
		mods_folder = value
		save()
static var mod_order: Dictionary[String, bool] = {}:
	set(value):
		mod_order = value
		save()

static var _is_save_queued: bool = false



static func save() -> void:
	if _is_save_queued:
		return
	
	_is_save_queued = true
	await Engine.get_main_loop().process_frame
	
	var config: ConfigFile = ConfigFile.new()
	
	config.set_value("General", "path_to_nwf", path_to_nwf)
	config.set_value("General", "mods_folder", mods_folder)
	
	for i in mod_order.size():
		config.set_value("Mod Order", str("mod[", i, "]"), mod_order.keys()[i])
	
	for i in mod_order.size():
		config.set_value("Mods Enabled", str(i), mod_order.values()[i])
	
	_is_save_queued = false
	config.save(DEFAULT_PATH)


static func load() -> Error:
	var config: ConfigFile = ConfigFile.new()
	var err_code: Error = config.load(DEFAULT_PATH)
	
	if not err_code == OK:
		return err_code
	
	path_to_nwf = config.get_value("General", "path_to_nwf")
	mods_folder = config.get_value("General", "mods_folder")
	
	for i in config.get_section_keys("Mod Order"):
		mod_order[config.get_value("Mod Order", i, "nil")] = true
	
	for i in config.get_section_keys("Mods Enabled"):
		mod_order[mod_order.keys()[int(i)]] = config.get_value("Mods Enabled", i, true)
	
	return err_code
