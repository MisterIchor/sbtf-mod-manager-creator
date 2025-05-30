extends HBoxContainer

signal data_changed(new_data: Dictionary)

const Interactable: PackedScene = preload("res://src/interactables/text/text_interactable.tscn")

@onready var data_files_list: ItemList = $DataFiles/DataFilesList
@onready var data_property_list: VBoxContainer = $DataProperties/ScrollContainer/DataPropertyList

var _data: Dictionary = {}



func _ready() -> void:
	data_files_list.item_selected.connect(_on_DataFilesList_item_selected)



func _on_DataFilesList_item_selected(idx: int) -> void:
	var data_file: FileAccess = FileAccess.open(
		str(SBTFTool.OUTPUT_PATH, "/", data_files_list.get_item_text(idx)),
		FileAccess.READ
	)
	
	if not data_file:
		return
	
	for i in data_property_list.get_children():
		i.queue_free()
	
	while not data_file.eof_reached():
		var property_string: String = data_file.get_line()
		
		if property_string.is_empty():
			continue
		
		var new_interactable: TextInteractable = Interactable.instantiate()
		
		new_interactable.label_name = property_string.get_slice("=", 0)
		new_interactable.default_text = property_string.get_slice("=", 1)
		new_interactable.text_set.connect(_on_TextInteractable_text_set.bind(new_interactable).bind(data_file.get_position()))
		data_property_list.add_child(new_interactable)



func _on_TextInteractable_text_set(new_text: String, line_position: int, interactable: TextInteractable) -> void:
	if not new_text == interactable.default_text:
		_data[interactable.label_name.trim_suffix(":")] = {
			value = new_text,
			line_position = line_position
		}
	
	if new_text == interactable.default_text:
		_data.erase(interactable.label_name.trim_suffix(":"))
	
	data_changed.emit(_data)
