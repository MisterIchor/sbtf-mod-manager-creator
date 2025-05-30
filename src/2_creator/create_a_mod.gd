extends Window

enum ModeToolSelection {NONE_SELECTED, ACTION_THEME, GRAPHICS_REPLACER, AUDIO_REPLACER, DATA_CHANGER}

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
@onready var load_mod_button: Button = $VBoxContainer/SaveLoadContainer/LoadModButton



func _ready() -> void:
	if not SBTFTool.verify_nwf() == 0:
		var prompt: Window = Prompt.nwf_path.instantiate()
		prompt.popup_exclusive_centered(self)
		
		while true:
			await prompt.close_requested
			
			if not Config.path_to_nwf.is_empty():
				if not SBTFTool.verify_nwf() == 0:
					break
			
			prompt = Prompt.nwf_path.instantiate()
			prompt.popup_exclusive(self)
	
	mod_name_line_edit.text_submitted.connect(_on_ModNameLineEdit_text_submitted)
	mod_tool_selection.item_selected.connect(_on_ModToolSelection_item_selected)
	save_mod_button.pressed.connect(compile_mod)
	action_theme.data_changed.connect(_on_data_changed.bind("theme"))
	graphic_replacer.data_changed.connect(_on_data_changed.bind("graphic"))
	data_change.data_changed.connect(_on_data_changed.bind("data"))
	audio_replacer.data_changed.connect(_on_data_changed.bind("audio"))



func _get_file_path(global_path: String) -> String:
	return str(global_path, "/", mod_name, ".sbtfmod")



func compile_mod() -> void:
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
	
	var file_exists: FileAccess = FileAccess.open(_get_file_path(path), FileAccess.READ)
	var zip_packer: ZIPPacker = ZIPPacker.new()
	
	if file_exists:
		file_exists.close()
		print(OS.move_to_trash(_get_file_path(path)))
	
	if not zip_packer.open(_get_file_path(path)) == OK:
		return
	
	zip_packer.start_file("description.txt")
	zip_packer.write_file(description.to_utf8_buffer())
	zip_packer.close_file()
	
	for i in data:
		var section: Dictionary = data[i]
		
		match i:
			"audio", "graphic":
				for file in section:
					var replacer: FileAccess = FileAccess.open(section[file], FileAccess.READ)
					
					if not replacer:
						continue
					
					zip_packer.start_file(file.trim_prefix(SBTFTool.OUTPUT_PATH))
					zip_packer.write_file(replacer.get_buffer(replacer.get_length()))
					zip_packer.close_file()
			"theme":
				for action_theme in section:
					var schema_string: String = ""
					
					for layer in section[action_theme]:
						var replacer: FileAccess = FileAccess.open(layer, FileAccess.READ)
						
						if not replacer:
							continue
						
						# Write the string that will be inserted into schema.xml.
						schema_string += "    <PackageFile>\n"
						schema_string += "      <FilePath>"
						schema_string += layer.trim_prefix(str(SBTFTool.get_global_user_path(), "/"))
						schema_string += "</FilePath>\n"
						schema_string += "      <Unknown1>115</Unknown1>\n"
						schema_string += "      <Unknown2>24556</Unknown2>\n"
						schema_string += "      <Unknown3>0</Unknown3>\n"
						schema_string += "    </PackageFile>\n"
						
						zip_packer.start_file(layer.trim_prefix(SBTFTool.get_global_user_path()))
						zip_packer.write_file(replacer.get_buffer(replacer.get_length()))
						zip_packer.close_file()
					
					zip_packer.start_file("theme_schemas.txt")
					zip_packer.write_file(schema_string.to_utf8_buffer())
					zip_packer.close_file()
			"data":
				for data in section:
					var line: Dictionary = section[data]
					
					zip_packer.start_file("data_changes.txt")
					zip_packer.write_file(str(line.value, "/", line.line_position, "\n").to_utf8_buffer())
					zip_packer.close_file()
	
	zip_packer.close()



func _on_data_changed(changed_data: Dictionary, from: String) -> void:
	data[from] = changed_data


func _on_ModNameLineEdit_text_submitted(new_text: String) -> void:
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
