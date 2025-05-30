class_name Config
extends Object

const DEFAULT_PATH: String = "user://sbtf_mod_manager.cfg"

static var path_to_nwf: String = "":
	set(value):
		path_to_nwf = value
		_save()
static var mods_folder: String = "":
	set(value):
		mods_folder = value
		_save()
static var mod_order: Array[Dictionary] = []:
	set(value):
		mod_order = value
		_save()

static var _is_save_queued: bool = false



static func _static_init() -> void:
	_load()



static func _save() -> void:
	if _is_save_queued:
		return
	
	_is_save_queued = true
	await Engine.get_main_loop().process_frame
	
	var config: ConfigFile = ConfigFile.new()
	
	config.set_value("General", "path_to_nwf", path_to_nwf)
	config.set_value("General", "mods_folder", mods_folder)
	
	for i in mod_order.size():
		config.set_value("Mod Order", str(i), mod_order[i].path)
	
	for i in mod_order.size():
		config.set_value("Mods Enabled", str(i), mod_order[i].enabled)
	
	_is_save_queued = false
	config.save(DEFAULT_PATH)


static func _load() -> Error:
	var config: ConfigFile = ConfigFile.new()
	var err_code: Error = config.load(DEFAULT_PATH)
	
	if not err_code == OK:
		return err_code
	
	path_to_nwf = config.get_value("General", "path_to_nwf")
	mods_folder = config.get_value("General", "mods_folder")
	mod_order.resize(config.get_section_keys("Mod Order").size())
	
	for i in config.get_section_keys("Mod Order"):
		mod_order[int(i)].path = config.get_value("Mod Order", i, "nil")
	
	for i in config.get_section_keys("Mods Enabled"):
		mod_order[int(i)].enabled = config.get_value("Mods Enabled", i, true)
	
	return err_code
