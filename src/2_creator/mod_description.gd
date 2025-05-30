extends TextEdit

signal data_changed(data)
var _data: Dictionary = {}



func _ready() -> void:
	text_changed.connect(_on_text_changed)



func _on_text_changed() -> void:
	_data.text = text
	data_changed.emit(_data)
