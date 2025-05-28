extends HBoxContainer

signal text_set(new_text: String)

@export var default_text: String = ""

@onready var line_edit: LineEdit = $LineEdit
@onready var reset_button: Button = $ResetButton



func _ready() -> void:
	line_edit.text_changed.connect(_on_LineEdit_text_changed)
	reset_button.pressed.connect(_on_ResetButton_pressed)



func _on_LineEdit_text_changed(new_text: String) -> void:
	text_set.emit(new_text)
	
	if not reset_button.visible and not default_text.is_empty():
		reset_button.show()
	else:
		reset_button.hide()


func _on_ResetButton_pressed() -> void:
	line_edit.text = default_text
	text_set.emit(line_edit.text)
