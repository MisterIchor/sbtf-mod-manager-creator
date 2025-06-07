extends Control

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
@onready var process_blanket: ColorRect = $ProcessBlanket

var _last_selected_mod: int = -1
var _sbtf_process_id: int = -1
var _is_monitoring: bool = false



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
	
	if not _is_monitoring:
		return
	
	prints("Monitoring...", _sbtf_process_id)
	
	if _sbtf_process_id == -1:
		_sbtf_process_id = _get_process_id()
	
	if not _sbtf_process_id == -1:
		if _get_process_id() == -1:
			prints("SBTF exited, ending monitor...")
			process_blanket.hide()
			_sbtf_process_id = -1
			_is_monitoring = false



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


func _get_process_id() -> int:
	var output: Array = []
	
	match OS.get_name():
		"Windows":
			var windows_output: Array = []
			OS.execute("CMD.exe", ["/C", 'tasklist /v /fo csv | findstr /i "sbtf_pub.exe"'], windows_output)
			output.append(windows_output[0].get_slice(",", 1))
		"Linux":
			OS.execute("pgrep", ["sbtf_pub.exe"], output)
	
	return int(output.front()) if not output.front().is_empty() else -1


func _launch_sbtf() -> void:
	var exit_code: int = - 1
	
	match OS.get_name():
		"Windows":
			var cmd_output: Array = []
			var steam_exe_path: String = ""
			
			OS.execute("cmd.exe", ["/c", "reg", "query", "HKEY_CURRENT_USER\\SOFTWARE\\Valve\\Steam", "/v", "SteamExe"], cmd_output)
			steam_exe_path = cmd_output[0].get_slice("    ", 3).strip_escapes()
			exit_code = OS.execute(steam_exe_path, ["steam://rungameid/357330"])
		"Linux":
			exit_code = OS.execute("steam", ["steam://rungameid/357330"])
	
	print("SBTF Launch: ", exit_code)



func start_game() -> void:
	process_blanket.show()
	await get_tree().process_frame
	await get_tree().process_frame
	
	if not FileAccess.open(Config.path_to_nwf.get_base_dir().path_join("sbtf_pub_backup.nwf"), FileAccess.READ):
		var nwf_file: FileAccess = FileAccess.open(Config.path_to_nwf, FileAccess.READ)
		var backup_file: FileAccess = FileAccess.open(Config.path_to_nwf.get_base_dir().path_join("sbtf_pub_backup.nwf"), FileAccess.WRITE)
		
		backup_file.store_buffer(nwf_file.get_buffer(nwf_file.get_length()))
	
	CleanUp.remove_output()
	var exit_code: int = SBTFTool.unpack_nwf()
	prints("SBTFTool Unpack: ", exit_code)
	exit_code = SBTFTool.generate_schema()
	prints("SBTFTool Schema: ", exit_code)
	
	if not exit_code == 0:
		process_blanket.hide()
		return
	
	for i in Config.mod_order:
		if i.enabled:
			SBTFMod.decompile(i.path, Config.path_to_output)
	
	exit_code = SBTFTool.repack_nwf()
	prints("SBTFTool Repack: ", exit_code)
	_launch_sbtf()
	_is_monitoring = true



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
