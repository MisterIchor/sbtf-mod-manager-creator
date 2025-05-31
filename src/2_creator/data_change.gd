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
		Config.path_to_output.path_join(data_files_list.get_item_text(idx)),
		FileAccess.READ
	)
	if not data_file:
		return
	
	for i in data_property_list.get_children():
		i.queue_free()
	
	var data_file_lines: PackedStringArray = data_file.get_as_text().split("\n")
	
	for i in data_file_lines.size():
		var line: String = data_file_lines[i]
		
		if line.is_empty() or line.begins_with("\r"):
			continue
		
		var new_interactable: TextInteractable = Interactable.instantiate()
		
		new_interactable.label_name = line.get_slice("=", 0)
		new_interactable.default_text = line.get_slice("=", 1)
		new_interactable.text_set.connect(_on_TextInteractable_text_set.bind(new_interactable).bind(i))
		data_property_list.add_child(new_interactable)



func _on_TextInteractable_text_set(new_text: String, line_position: int, interactable: TextInteractable) -> void:
	var selected_data_file: String = data_files_list.get_item_text(data_files_list.get_selected_items()[0])
	var changes_dict: Dictionary = _data.get_or_add(selected_data_file, {})
	var value_name: String = interactable.label_name.trim_suffix(":")
	
	if not new_text == interactable.default_text:
		changes_dict[value_name] = {
			value = new_text.erase(new_text.length() - 1, 2),
			line_position = line_position
		}
	
	if new_text == interactable.default_text:
		changes_dict.erase(value_name)
		
		if changes_dict.is_empty():
			_data.erase(selected_data_file)
	
	data_changed.emit(_data)
