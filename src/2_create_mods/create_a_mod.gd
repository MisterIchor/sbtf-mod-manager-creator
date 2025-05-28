extends Window

enum ModeToolSelection {NONE_SELECTED, ACTION_THEME, GRAPHICS_REPLACER, DATA_CHANGER}

var mod_name: String = ""
var type: ModeToolSelection = ModeToolSelection.NONE_SELECTED
var description: String = ""
var data: Dictionary = {}

@onready var mod_name_line_edit: LineEdit = $VBoxContainer/HBoxContainer/ModNameLineEdit
@onready var mod_tool_selection: OptionButton = $VBoxContainer/HBoxContainer/ModToolSelection
@onready var action_theme: HBoxContainer = $VBoxContainer/ToolsContainer/ActionTheme
@onready var none_selected_label: Label = $VBoxContainer/ToolsContainer/NoneSelectedLabel
@onready var tools_container: MarginContainer = $VBoxContainer/ToolsContainer
@onready var graphic_replacer: HSplitContainer = $VBoxContainer/ToolsContainer/GraphicReplacer
@onready var data_change: HBoxContainer = $VBoxContainer/ToolsContainer/DataChange



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
	action_theme.data_changed.connect(_on_data_changed.bind("theme"))
	graphic_replacer.data_changed.connect(_on_data_changed.bind("graphic"))
	data_change.data_changed.connect(_on_data_changed.bind("data"))
	



func compile_mod() -> void:
	return



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
		ModeToolSelection.DATA_CHANGER:
			data_change.show()
