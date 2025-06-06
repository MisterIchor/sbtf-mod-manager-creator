class_name Config
extends Object

const DEFAULT_PATH: String = "user://sbtf_mod_manager.cfg"

static var path_to_nwf: String = "":
	set(value):
		path_to_nwf = value
		save_file()
static var path_to_output: String = "":
	set(value):
		path_to_output = value
		save_file()
static var mods_folder: String = "":
	set(value):
		mods_folder = value
		save_file()
static var mod_order: Array[Dictionary] = []:
	set(value):
		mod_order = value
		save_file()

static var _is_save_queued: bool = false



static func _static_init() -> void:
	load_file()
	
	if not DirAccess.dir_exists_absolute(path_to_output):
		path_to_output = ""
	
	if not FileAccess.open(path_to_nwf, FileAccess.READ):
		path_to_nwf = ""
	
	if not DirAccess.dir_exists_absolute(mods_folder):
		mods_folder = ""
	
	if path_to_output.is_empty():
		var dir: DirAccess = DirAccess.open(OS.get_executable_path().get_base_dir())
		
		if not dir.dir_exists(".temp"):
			dir.make_dir(".temp")
		
		path_to_output = OS.get_executable_path().get_base_dir().path_join(".temp")
	
	if mods_folder.is_empty():
		var dir: DirAccess = DirAccess.open(OS.get_executable_path().get_base_dir())
		
		if not dir.dir_exists("mods"):
			dir.make_dir("mods")
		
		mods_folder = OS.get_executable_path().get_base_dir().path_join("mods")
		mod_order.clear()



static func save_file() -> void:
	if _is_save_queued:
		return
	
	_is_save_queued = true
	await Engine.get_main_loop().process_frame
	
	var config: ConfigFile = ConfigFile.new()
	
	config.set_value("General", "path_to_nwf", path_to_nwf)
	config.set_value("General", "path_to_output", path_to_output)
	config.set_value("General", "mods_folder", mods_folder)
	
	for i in mod_order.size():
		config.set_value("Mod Order", str(i), mod_order[i].path)
	
	for i in mod_order.size():
		config.set_value("Mods Enabled", str(i), mod_order[i].enabled)
	
	_is_save_queued = false
	config.save(DEFAULT_PATH)


static func load_file() -> Error:
	var config: ConfigFile = ConfigFile.new()
	var err_code: Error = config.load(DEFAULT_PATH)
	
	if not err_code == OK:
		return err_code
	
	path_to_nwf = config.get_value("General", "path_to_nwf", "")
	path_to_output = config.get_value("General", "path_to_output", OS.get_executable_path().get_base_dir().path_join(".temp"))
	mods_folder = config.get_value("General", "mods_folder", OS.get_executable_path().get_base_dir().path_join("mods"))
	
	for i in config.get_section_keys("Mod Order"):
		var path: String = config.get_value("Mod Order", i, "nil")
		var file_exists: FileAccess = FileAccess.open(path, FileAccess.READ)
		
		if file_exists:
			file_exists.close()
			mod_order.append({
				path = path,
				enabled = config.get_value("Mods Enabled", i, true)
			})
	
	return err_code
