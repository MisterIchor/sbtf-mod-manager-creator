@tool
class_name PathToInteractable
extends InteractableBase

signal path_set(new_path: String)

@export var file_type_filter: PackedStringArray = []
@onready var dir_button: Button = $Button
@onready var line_edit: LineEdit = $LineEdit

static var _is_in_dialog: bool = false



func _ready() -> void:
	dir_button.pressed.connect(_on_Button_pressed)



func _on_Button_pressed() -> void:
	if _is_in_dialog:
		return
	
	var file_dialog: FileDialog = FileDialog.new()
	
	file_dialog.filters = file_type_filter
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.size = Vector2(900, 360)
	file_dialog.file_selected.connect(_on_FileDialog_file_selected.bind(file_dialog))
	file_dialog.popup_exclusive_centered(owner)
	_is_in_dialog = true


func _on_FileDialog_file_selected(path : String, file_dialog: FileDialog) -> void:
	line_edit.text = path
	file_dialog.hide()
	file_dialog.queue_free()
	_is_in_dialog = false
	path_set.emit(path)
