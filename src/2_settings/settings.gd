extends Window

@onready var path_to_nwf: PathToInteractable = $VBoxContainer/PathToNwf
@onready var path_to_temp_output: PathToInteractable = $VBoxContainer/PathToTempOutput
@onready var path_to_mods_folder: PathToInteractable = $VBoxContainer/PathToModsFolder
@onready var ok_button: Button = $VBoxContainer/OkButton

var _blanket: ColorRect = ColorRect.new()



func _ready() -> void:
	path_to_nwf.path_set.connect(_on_PathToNwf_path_set)
	path_to_temp_output.path_set.connect(_on_PathToTempOutput_path_set)
	path_to_mods_folder.path_set.connect(_on_PathToModsFolder_path_set)
	ok_button.pressed.connect(_on_OkButton_pressed)
	_blanket.color = Color(Color.BLACK, 0.2)
	get_tree().current_scene.add_child(_blanket)
	path_to_nwf.line_edit.text = Config.path_to_nwf
	path_to_temp_output.line_edit.text = Config.path_to_output
	path_to_mods_folder.line_edit.text = Config.mods_folder



func _on_PathToNwf_path_set(path: String) -> void:
	Config.path_to_nwf = path


func _on_PathToTempOutput_path_set(path: String) -> void:
	Config.path_to_output = path


func _on_PathToModsFolder_path_set(path: String) -> void:
	Config.mods_folder = path


func _on_OkButton_pressed() -> void:
	_blanket.queue_free()
	queue_free()
