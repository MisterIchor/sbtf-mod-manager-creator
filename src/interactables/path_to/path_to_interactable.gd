@tool
class_name PathToInteractable
extends InteractableBase

signal path_set(new_path: String)

@export var file_type_filter: PackedStringArray = []
@export var file_mode: FileDialog.FileMode = FileDialog.FileMode.FILE_MODE_OPEN_FILE
@onready var dir_button: Button = $Button
@onready var line_edit: LineEdit = $LineEdit

var _blanket: ColorRect = null



func _ready() -> void:
	dir_button.pressed.connect(_on_Button_pressed)



func set_text(new_text: String) -> void:
	line_edit.text = new_text
	line_edit.caret_column = line_edit.text.length()



func _on_Button_pressed() -> void:
	var file_dialog: FileDialog = FileDialog.new()
	
	_blanket = ColorRect.new()
	_blanket.size = get_window().size
	_blanket.color = Color(Color.BLACK, 0.2)
	_blanket.mouse_filter = Control.MOUSE_FILTER_STOP
	get_tree().current_scene.add_child(_blanket)
	file_dialog.filters = file_type_filter
	file_dialog.file_mode = file_mode
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.size = Vector2(900, 360)
	file_dialog.file_selected.connect(_on_FileDialog_file_selected.bind(file_dialog))
	file_dialog.dir_selected.connect(_on_FileDialog_file_selected.bind(file_dialog))
	file_dialog.canceled.connect(_on_FileDialog_file_selected.bind(file_dialog).bind(""))
	file_dialog.popup_exclusive_centered(owner)


func _on_FileDialog_file_selected(path : String, file_dialog: FileDialog) -> void:
	set_text(path)
	path_set.emit(path)
	file_dialog.hide()
	file_dialog.queue_free()
	_blanket.queue_free()
