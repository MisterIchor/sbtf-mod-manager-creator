extends Window

@onready var back_to_menu_button: Button = $VBoxContainer/GlobalSettingsContainer/BackToMenuButton
@onready var mods_folder_path_interactable: PathToInteractable = $VBoxContainer/GlobalSettingsContainer/ModsFolderPathInteractable
@onready var start_game_button: Button = $VBoxContainer/GlobalSettingsContainer/StartGameButton
@onready var mod_list: ItemList = $VBoxContainer/HSplitContainer/ModsContainer/ModListContainer/ModList
@onready var toggle_mod_button: Button = $VBoxContainer/HSplitContainer/ModsContainer/ModListContainer/ToggleModButton
@onready var mod_name_label: Label = $VBoxContainer/HSplitContainer/ModDetailContainer/ModNameLabel
@onready var description_label: Label = $VBoxContainer/HSplitContainer/ModDetailContainer/ScrollContainer/DescriptionLabel
@onready var up_one_button: Button = $VBoxContainer/HSplitContainer/ModsContainer/LoadOrderContainer/LoadOrderSettingsContainer/UpOneButton
@onready var send_to_top_button: Button = $VBoxContainer/HSplitContainer/ModsContainer/LoadOrderContainer/LoadOrderSettingsContainer/SendToTopButton
@onready var down_one_button: Button = $VBoxContainer/HSplitContainer/ModsContainer/LoadOrderContainer/LoadOrderSettingsContainer/DownOneButton
@onready var send_to_bottom_button: Button = $VBoxContainer/HSplitContainer/ModsContainer/LoadOrderContainer/LoadOrderSettingsContainer/SendToBottomButton

var _last_selected_mod: int = -1



func _ready() -> void:
	back_to_menu_button.pressed.connect(_on_BackToMenuButton_pressed)
	mods_folder_path_interactable.path_set.connect(_on_ModsFolderPathInteractable_path_set)
	start_game_button.pressed.connect(start_game)
	mod_list.item_selected.connect(_on_ModList_item_selected)
	toggle_mod_button.toggled.connect(_on_ToggleModButton_toggled)
	up_one_button.pressed.connect(_push_selected_mod.bind(-1))
	send_to_top_button.pressed.connect(_push_selected_mod.bind(-999))
	down_one_button.pressed.connect(_push_selected_mod.bind(1))
	send_to_bottom_button.pressed.connect(_push_selected_mod.bind(999))
	mods_folder_path_interactable.line_edit.text = Config.mods_folder
	_update_mod_list()


func _process(_delta: float) -> void:
	# That's right, we're gonna cheat.
	if not _last_selected_mod == -1:
		mod_list.select(_last_selected_mod)



func _update_mod_list() -> void:
	mod_list.clear()
	
	for mod_dict in Config.mod_order:
		var mod: ZIPReader = ZIPReader.new()
		
		if not mod.open(mod_dict.path) == OK:
			continue
		
		var description: String = mod.read_file("description.txt").get_string_from_utf8()
		
		mod_list.add_item(description.get_slice("<~^W^~>\n", 0).rstrip("\n"))
		mod_list.set_item_metadata(mod_list.item_count - 1, {
			description = description.get_slice("<~^W^~>\n", 1),
			path = mod_dict.path
		})
		
		if mod_dict.enabled:
			mod_list.set_item_custom_bg_color(mod_list.item_count - 1, Color(Color.GREEN, 0.2))
		else:
			mod_list.set_item_custom_bg_color(mod_list.item_count - 1, Color(0.0, 0.0, 0.0, 0.0))
		
		mod.close()


func _update_toggle_mod_button_text() -> void:
	if toggle_mod_button.button_pressed:
		toggle_mod_button.text = "Enable mod"
	else:
		toggle_mod_button.text = "Disable mod"


func _push_selected_mod(how_many: int) -> void:
	if how_many == 0 or _last_selected_mod == -1:
		return
	
	var mod_dict_selected: Dictionary = Config.mod_order[mod_list.get_selected_items()[0]]
	var target_idx: int = clampi(_last_selected_mod + how_many, 0, mod_list.item_count - 1)
	
	Config.mod_order.insert(target_idx, Config.mod_order.pop_at(_last_selected_mod))
	Config.save_file()
	_last_selected_mod = target_idx
	_update_mod_list()



func start_game() -> void:
	var exit_code: int = SBTFTool.unpack_nwf()
	prints("SBTFTool Unpack: ", exit_code)
	exit_code = SBTFTool.generate_schema()
	prints("SBTFTool Schema: ", exit_code)
	
	if not exit_code == 0:
		return
	
	for i in Config.mod_order:
		var mod: ZIPReader = ZIPReader.new()
		
		if not mod.open(i.path) == OK:
			prints(i.path, "open failed.")
			continue
		
		prints(i.path, "opened successfully.")
		var dir: DirAccess = DirAccess.open(Config.path_to_output)
		
		for file_path in mod.get_files():
			if file_path.ends_with("/"):
				dir.make_dir_recursive(dir.get_current_dir().path_join(file_path).get_base_dir())
				prints(file_path, "dir made recursively.")
				continue
			
			if "description" in file_path:
				continue
			
			if "theme_schemas" in file_path:
				var schema_file: FileAccess = FileAccess.open(dir.get_current_dir().path_join("schema.xml"), FileAccess.READ_WRITE)
				
				if not schema_file:
					prints("Schema not found at ", dir.get_current_dir().path_join("schema.xml"))
					continue
				
				var theme_schema_text: String = mod.read_file(file_path).get_string_from_utf8()
				var schema_file_text: String = schema_file.get_as_text()
			
				schema_file.store_string(schema_file_text.insert(168, theme_schema_text))
				schema_file.close()
				continue
			
			if "added_themes" in file_path:
				var themes_file: FileAccess = FileAccess.open(dir.get_current_dir().path_join("themes.txt"), FileAccess.READ_WRITE)
				
				if not themes_file:
					prints("Themes file not found at ", dir.get_current_dir().path_join("themes.txt"))
					continue
				
				var added_themes_text: String = mod.read_file(file_path).get_string_from_utf8()
				
				themes_file.seek(themes_file.get_length())
				themes_file.store_string(added_themes_text)
				themes_file.close()
				continue
			
			if "data_changes" in file_path:
				var data_changes: PackedStringArray = mod.read_file(file_path).get_string_from_utf8().split("\n", false)
				var current_file: String = ""
				var data_file: FileAccess = null
				var data_file_lines: PackedStringArray = []
				
				for line in data_changes:
					if line.begins_with("[") and line.ends_with("]"):
						if data_file:
							data_file.store_string("\n".join(data_file_lines))
						
						current_file = line.replace("[", "")
						current_file = current_file.replace("]", "")
						data_file = FileAccess.open(dir.get_current_dir().path_join(current_file), FileAccess.READ_WRITE)
						data_file_lines = data_file.get_as_text().split("\n", false)
						continue
					
					if not data_file:
						prints("No data file found at ", dir.get_current_dir().path_join(current_file))
						continue
					
					var change_pos_arr: PackedStringArray = line.split("/")
					var line_to_edit: PackedStringArray = data_file_lines[int(change_pos_arr[1])].split("=")
					
					line_to_edit[1] = change_pos_arr[0]
					data_file_lines[int(change_pos_arr[1])] = "=".join(line_to_edit)
				
				data_file.store_string("\n".join(data_file_lines))
				data_file.close()
				continue
			
			dir.make_dir_recursive(dir.get_current_dir().path_join(file_path).get_base_dir())
			var file: FileAccess = FileAccess.open(dir.get_current_dir().path_join(file_path), FileAccess.WRITE)
			
			if not file:
				prints(dir.get_current_dir().path_join(file_path).get_base_dir(), "failed to open.")
				continue
			
			var buffer: PackedByteArray = mod.read_file(file_path)
			file.resize(0)
			file.store_buffer(buffer)
			prints(file_path, "file created.")
	
	exit_code = SBTFTool.repack_nwf()
	prints("SBTFTool Repack: ", exit_code)
	print(OS.execute("steam", ["steam://rungameid/357330"]))



func _on_BackToMenuButton_pressed() -> void:
	get_tree().change_scene_to_file("res://src/1_start/start.tscn")


func _on_ModsFolderPathInteractable_path_set(path: String) -> void:
	var dir: DirAccess = DirAccess.open(path)
	
	if not dir.list_dir_begin() == OK:
		mods_folder_path_interactable.line_edit.text = ""
		return
	
	var mods: PackedStringArray = []
	var current_file: String = dir.get_next()
	
	while not current_file.is_empty():
		if current_file.get_extension() == "sbtfmod":
			mods.append(str(path, "/", current_file))
		
		current_file = dir.get_next()
	
	var mod_array: Array[Dictionary] = []
	
	for i in mods.size():
		mod_array.append({
			path = mods[i],
			enabled = true
		})
	
	Config.mod_order = mod_array
	Config.mods_folder = path
	_update_mod_list()


func _on_ModList_item_selected(idx: int) -> void:
	toggle_mod_button.disabled = false
	up_one_button.disabled = false
	send_to_top_button.disabled = false
	down_one_button.disabled = false
	send_to_bottom_button.disabled = false
	toggle_mod_button.set_pressed_no_signal(not Config.mod_order[idx].enabled)
	mod_name_label.text = mod_list.get_item_text(idx)
	description_label.text = mod_list.get_item_metadata(idx).description
	_last_selected_mod = idx
	_update_toggle_mod_button_text()


func _on_ToggleModButton_toggled(is_toggled: bool) -> void:
	var selected_mod_metadata: Dictionary = mod_list.get_item_metadata(mod_list.get_selected_items()[0])
	Config.mod_order[mod_list.get_selected_items()[0]].enabled = not is_toggled
	_update_mod_list()
	_update_toggle_mod_button_text()
	Config.save_file()
