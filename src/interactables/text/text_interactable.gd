class_name TextInteractable
extends InteractableBase

signal text_set(new_text: String)

@export var default_text: String = ""

@onready var line_edit: LineEdit = $LineEdit
@onready var reset_button: Button = $MarginContainer/ResetButton




func _ready() -> void:
	line_edit.text_changed.connect(_on_LineEdit_text_changed)
	reset_button.pressed.connect(_on_ResetButton_pressed)
	line_edit.text = default_text


func _update_reset_button() -> void:
	if not reset_button.visible and not default_text.is_empty():
		if not line_edit.text == default_text:
			reset_button.show()
			return
	
	if reset_button.visible:
		if line_edit.text == default_text:
			reset_button.hide()



func _on_LineEdit_text_changed(new_text: String) -> void:
	text_set.emit(new_text)
	_update_reset_button()



func _on_ResetButton_pressed() -> void:
	line_edit.text = default_text
	text_set.emit(line_edit.text)
	_update_reset_button()
