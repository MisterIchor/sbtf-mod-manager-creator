extends AcceptDialog

@onready var path_to_line_edit: LineEdit = $VBoxContainer/PathSelector/PathToLineEdit
@onready var file_dialog_button: Button = $VBoxContainer/PathSelector/FileDialogButton
@onready var file_dialog: FileDialog = $FileDialog



func _ready() -> void:
	confirmed.connect(_on_handled)
	canceled.connect(_on_handled)
	file_dialog_button.pressed.connect(_on_FileDialogButton_pressed)
	file_dialog.file_selected.connect(_on_FileDialog_file_selected)
	file_dialog.confirmed.connect(_on_FileDialog_handled)
	file_dialog.canceled.connect(_on_FileDialog_handled)



func _on_handled() -> void:
	Config.path_to_nwf = path_to_line_edit.text


func _on_FileDialog_handled() -> void:
	file_dialog_button.disabled = false


func _on_FileDialogButton_pressed() -> void:
	file_dialog.popup()
	file_dialog_button.disabled = true


func _on_FileDialog_file_selected(path: String) -> void:
	path_to_line_edit.text = path
	file_dialog_button.disabled = false
