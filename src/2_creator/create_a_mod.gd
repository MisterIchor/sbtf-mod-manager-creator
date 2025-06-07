extends Control

enum ModeToolSelection {NONE_SELECTED, ACTION_THEME, GRAPHICS_REPLACER, AUDIO_REPLACER, DATA_CHANGER, MOD_DESCRIPTION}

var mod_name: String = "Untitled"
var type: ModeToolSelection = ModeToolSelection.NONE_SELECTED
var description: String = ""
var data: Dictionary = {}

@onready var mod_name_line_edit: LineEdit = $VBoxContainer/HBoxContainer/ModNameLineEdit
@onready var mod_tool_selection: OptionButton = $VBoxContainer/HBoxContainer/ModToolSelection
@onready var action_theme: VBoxContainer = $VBoxContainer/ToolsContainer/ActionTheme
@onready var none_selected_label: Label = $VBoxContainer/ToolsContainer/NoneSelectedLabel
@onready var tools_container: MarginContainer = $VBoxContainer/ToolsContainer
@onready var graphic_replacer: HSplitContainer = $VBoxContainer/ToolsContainer/GraphicReplacer
@onready var data_change: HBoxContainer = $VBoxContainer/ToolsContainer/DataChange
@onready var audio_replacer: HSplitContainer = $VBoxContainer/ToolsContainer/AudioReplacer
@onready var save_mod_button: Button = $VBoxContainer/SaveLoadContainer/SaveModButton
@onready var load_mod_interactable: PathToInteractable = $VBoxContainer/SaveLoadContainer/LoadModInteractable
@onready var mod_description: TextEdit = $VBoxContainer/ToolsContainer/ModDescription
@onready var back_to_menu_button: Button = $VBoxContainer/HBoxContainer/BackToMenuButton



func _ready() -> void:
	mod_name_line_edit.text_changed.connect(_on_ModNameLineEdit_text_changed)
	mod_tool_selection.item_selected.connect(_on_ModToolSelection_item_selected)
	save_mod_button.pressed.connect(save_mod)
	#load_mod_interactable.path_set.connect(load_mod)
	action_theme.data_changed.connect(_on_data_changed.bind("theme"))
	graphic_replacer.data_changed.connect(_on_data_changed.bind("graphic"))
	data_change.data_changed.connect(_on_data_changed.bind("data"))
	audio_replacer.data_changed.connect(_on_data_changed.bind("audio"))
	mod_description.data_changed.connect(_on_data_changed.bind("description"))
	back_to_menu_button.pressed.connect(_on_BackToMenuButton_pressed)
	SBTFTool.unpack_nwf()



func _get_file_path(global_path: String) -> String:
	return str(global_path, "/", mod_name.replace(" ", ""), ".sbtfmod")



func save_mod() -> void:
	if mod_name.is_empty():
		return
	
	var file_dialog: FileDialog = FileDialog.new()
	var path: String = ""
	
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	file_dialog.filters = ["*.sbtfmod"]
	file_dialog.title = "Choose a save location."
	file_dialog.popup_exclusive_centered(self)
	path = await file_dialog.dir_selected
	
	if path.is_empty():
		return
	
	var file_exists: = FileAccess.open(_get_file_path(path), FileAccess.READ)
	var zip_packer: ZIPPacker = ZIPPacker.new()
	
	if file_exists:
		file_exists.close()
		DirAccess.remove_absolute(_get_file_path(path))
	
	if not zip_packer.open(_get_file_path(path)) == OK:
		return
	
	for i in data:
		var section: Dictionary = data[i]
		
		match i:
			"audio", "graphic":
				for file in section:
					var replacer: FileAccess = FileAccess.open(section[file], FileAccess.READ)
					
					if not replacer:
						continue
					
					zip_packer.start_file(file.trim_prefix(Config.path_to_output))
					zip_packer.write_file(replacer.get_buffer(replacer.get_length()))
					zip_packer.close_file()
			"theme":
				for action_theme in section:
					var schema_string: String = ""
					var themes_string: String = ""
					
					for idx: int in section[action_theme].size():
						var layer: String = section[action_theme][idx]
						var replacer: FileAccess = FileAccess.open(layer, FileAccess.READ)
						var trimmed_path: String = layer.trim_prefix(str(Config.path_to_output, "/"))
						
						if not replacer:
							continue
						
						# Write the string that will be inserted into schema.xml.
						schema_string += "    <PackageFile>\n"
						schema_string += "      <FilePath>"
						schema_string += trimmed_path
						schema_string += "</FilePath>\n"
						schema_string += "      <Unknown1>115</Unknown1>\n"
						schema_string += "      <Unknown2>24556</Unknown2>\n"
						schema_string += "      <Unknown3>0</Unknown3>\n"
						schema_string += "    </PackageFile>\n"
						themes_string += str(action_theme, ".asset_", idx, "=", trimmed_path, "\n")
						
						zip_packer.start_file(layer.trim_prefix(Config.path_to_output))
						zip_packer.write_file(replacer.get_buffer(replacer.get_length()))
						zip_packer.close_file()
					
					zip_packer.start_file("theme_schemas.txt")
					zip_packer.write_file(schema_string.to_utf8_buffer())
					zip_packer.close_file()
					zip_packer.start_file("added_themes.txt")
					zip_packer.write_file(themes_string.to_utf8_buffer())
					zip_packer.close_file()
			"data":
				zip_packer.start_file("data_changes.txt")
				
				for data_file in section:
					zip_packer.write_file(str("[", data_file, "]\n").to_utf8_buffer())
					
					for value_name in section[data_file]:
						var value_dict: Dictionary = section[data_file][value_name]
						zip_packer.write_file(str(value_dict.value, "/", value_dict.line_position, "\n").to_utf8_buffer())
				
				zip_packer.close_file()
	
	zip_packer.start_file("description.txt")
	zip_packer.write_file(str(mod_name, "\n").to_utf8_buffer())
	
	if data.description:
		zip_packer.write_file("<~^W^~>\n".to_utf8_buffer())
		zip_packer.write_file(data.description.text.to_utf8_buffer())
	
	zip_packer.close_file()
	zip_packer.close()

# Canned, for now.
#func load_mod(path: String) -> void:
	#_temp_output_path = Config.path_to_output.path_join(path.get_file().get_basename())
	#
	#if not SBTFMod.decompile(path, _temp_output_path):
		#_temp_output_path = ""
		#return
	#
	#var output_dir: DirAccess = DirAccess.open(_temp_output_path)
	#var dirs_to_search: PackedStringArray = [_temp_output_path]
	#var current_file: String = ""
	#var valid_files: PackedStringArray = []
	#
	#if not output_dir.list_dir_begin() == OK:
		#print(error_string(output_dir.get_open_error()))
		#return
	#
	#while not dirs_to_search.is_empty():
		#current_file = output_dir.get_next()
		#
		#if output_dir.current_is_dir():
			#dirs_to_search.append(str(dirs_to_search[0], "/", current_file))
			#continue
		#
		#if current_file.get_extension() == "txt":
			#var file: FileAccess = FileAccess.open(output_dir.get_current_dir().path_join(current_file), FileAccess.READ)
			#
			#if "added_themes" in current_file:
				#if not file:
					#print("file ", current_file, " failed to open.")
					#continue
				#
				#var themes: Dictionary[String, Array] = {}
				#
				#while not file.eof_reached():
					#var line: String = file.get_line()
					#var theme_name: String = line.get_slice(".", 0)
					#var theme_path: String = line.get_slice("=", 1)
					#
					#themes.get_or_add(theme_name, [])
					#themes[theme_name].append(_temp_output_path.path_join(theme_path))
				#
				#action_theme._update(themes)
			#
			#if "description" in current_file:
				#var file_text: PackedStringArray = file.get_as_text().split("<~^W^~>\n")
				#mod_name_line_edit.text = file_text[0]
				#mod_description._update({text = file_text[1]})
			#continue
		#
		#
		#if current_file.is_empty():
			#dirs_to_search.remove_at(0)
			#
			#if dirs_to_search.is_empty():
				#break
			#
			#output_dir = output_dir.open(dirs_to_search[0])
			#
			#if not output_dir.list_dir_begin() == OK:
				#break



func _on_data_changed(changed_data: Dictionary, from: String) -> void:
	data[from] = changed_data


func _on_BackToMenuButton_pressed() -> void:
	get_tree().change_scene_to_file("res://src/1_start/start.tscn")


func _on_ModNameLineEdit_text_changed(new_text: String) -> void:
	mod_name = new_text


func _on_ModToolSelection_item_selected(new_option: int) -> void:
	type = new_option
	
	for i in tools_container.get_children():
		i.hide()
	
	match type:
		ModeToolSelection.NONE_SELECTED:
			none_selected_label.show()
		ModeToolSelection.ACTION_THEME:
			action_theme.show()
		ModeToolSelection.GRAPHICS_REPLACER:
			graphic_replacer.show()
		ModeToolSelection.AUDIO_REPLACER:
			audio_replacer.show()
		ModeToolSelection.DATA_CHANGER:
			data_change.show()
		ModeToolSelection.MOD_DESCRIPTION:
			mod_description.show()
