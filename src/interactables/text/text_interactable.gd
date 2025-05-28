extends HBoxContainer

signal text_set(new_text: String)

@onready var line_edit: LineEdit = $LineEdit



func _ready() -> void:
	line_edit.text_changed.connect(_on_LineEdit_text_changed)



func _on_LineEdit_text_changed(new_text: String) -> void:
	text_set.emit(new_text)
