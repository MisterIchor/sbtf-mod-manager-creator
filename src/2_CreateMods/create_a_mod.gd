extends Window

enum ModType {NONE_SELECTED = -1, ACTION_THEME, GRAPHICS_REPLACER, DATA_CHANGER}

var mod_name: String = ""
var type: ModType = ModType.NONE_SELECTED
var description: String = ""
var data: Dictionary = {}

@onready var mod_name_line_edit: LineEdit = $VBoxContainer/HBoxContainer/ModNameLineEdit
@onready var mod_type_option_button: OptionButton = $VBoxContainer/HBoxContainer/ModTypeOptionButton
@onready var action_theme: HBoxContainer = $VBoxContainer/ToolsContainer/ActionTheme
@onready var none_selected_label: Label = $VBoxContainer/ToolsContainer/NoneSelectedLabel
@onready var tools_container: MarginContainer = $VBoxContainer/ToolsContainer



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
	mod_type_option_button.item_selected.connect(_on_ModTypeOptionButton_item_selected)



func _on_ModNameLineEdit_text_submitted(new_text: String) -> void:
	mod_name = new_text


func _on_ModTypeOptionButton_item_selected(new_option: int) -> void:
	type = new_option
	
	for i in tools_container.get_children():
		i.hide()
	
	match type:
		ModType.NONE_SELECTED:
			none_selected_label.show()
		ModType.ACTION_THEME:
			action_theme.show()
			data.layer = Array().resize(8)
			data.overwrites_existing_theme = false
		ModType.GRAPHICS_REPLACER:
			return
		ModType.DATA_CHANGER:
			return
