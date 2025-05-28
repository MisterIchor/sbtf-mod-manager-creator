extends Window

@onready var path_to_line_edit: LineEdit = $VBoxContainer/PathSelector/PathToLineEdit
@onready var file_dialog_button: Button = $VBoxContainer/PathSelector/FileDialogButton
@onready var ok_button: Button = $VBoxContainer/OKButton
@onready var file_dialog: FileDialog = $FileDialog



func _ready() -> void:
	ok_button.pressed.connect(_on_OKButton_pressed)
	file_dialog_button.pressed.connect(_on_FileDialogButton_pressed)
	file_dialog.file_selected.connect(_on_FileDialog_file_selected)



func _on_OKButton_pressed() -> void:
	if not SBTFTool.verify_nwf() == 0:
		var prompt: AcceptDialog = Prompt.invalid_file.instantiate()
		prompt.popup_exclusive_centered(self)
		return
	
	Config.path_to_nwf = path_to_line_edit.text
	queue_free()


func _on_FileDialogButton_pressed() -> void:
	file_dialog.popup()


func _on_FileDialog_file_selected(path: String) -> void:
	path_to_line_edit.text = path
