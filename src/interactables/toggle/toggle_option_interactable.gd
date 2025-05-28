@tool
class_name ToggleOptionInteractable
extends InteractableBase

signal toggled(is_toggled: bool)
@onready var check_button: CheckButton = $CheckButton



func _ready() -> void:
	check_button.toggled.connect(_on_CheckButton_toggled)



func _on_CheckButton_toggled(toggled_on: bool) -> void:
	toggled.emit(toggled_on)
