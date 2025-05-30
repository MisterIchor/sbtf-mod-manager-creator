extends HSplitContainer

signal data_changed(new_data: Dictionary)

@onready var selected_audio_interactable: AudioInteractable = $AudioSection/SelectedAudioInteractable
@onready var replacer_audio_interactable: AudioInteractable = $AudioSection/ReplacerAudioInteractable
@onready var file_list: ItemList = $FileSelector/VSplitContainer/FileList
@onready var replacer_list: ItemList = $FileSelector/VSplitContainer/ReplacerList
@onready var clear_replacer_button: Button = $FileSelector/ClearReplacerButton
@onready var replacer_path: PathToInteractable = $AudioSection/ReplacerPath

var _list: ItemList = null
var _data: Dictionary = {}
var _initialized: bool = false


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed, CONNECT_DEFERRED)
	file_list.item_selected.connect(_on_item_selected.bind(file_list))
	replacer_list.item_selected.connect(_on_item_selected.bind(replacer_list))
	replacer_path.path_set.connect(_on_ReplacerPath_set)
	clear_replacer_button.pressed.connect(_on_ClearReplacerButton_pressed)



func _update_audio(metadata: Dictionary) -> void:
	var sound: AudioStreamWAV = AudioStreamWAV.load_from_file(metadata.path_to)
	selected_audio_interactable.stream = sound
	
	if not metadata.replacer.is_empty():
		var replacer_sound: AudioStreamWAV = AudioStreamWAV.load_from_file(metadata.replacer)
		replacer_audio_interactable.stream = replacer_sound
	else:
		replacer_audio_interactable.stream = null
	
	replacer_path.set_text(metadata.replacer)


func _update_list() -> void:
	var idx: int = 0
	
	while idx < file_list.item_count:
		var metadata: Dictionary = file_list.get_item_metadata(idx)
		
		if not metadata.replacer.is_empty():
			replacer_list.add_item(metadata.path_to.trim_prefix(SBTFTool.OUTPUT_PATH))
			replacer_list.set_item_metadata(replacer_list.item_count - 1, metadata)
			replacer_list.set_item_custom_bg_color(replacer_list.item_count - 1, Color(Color.YELLOW, 0.1))
			file_list.remove_item(idx)
			continue
		
		idx += 1
	
	idx = 0
	
	while idx < replacer_list.item_count:
		var metadata: Dictionary = replacer_list.get_item_metadata(idx)
		
		if metadata.replacer.is_empty():
			file_list.add_item(metadata.path_to.trim_prefix(SBTFTool.OUTPUT_PATH))
			file_list.set_item_metadata(file_list.item_count - 1, metadata)
			replacer_list.remove_item(idx)
			continue
		
		idx += 1
	
	replacer_list.sort_items_by_text()
	file_list.sort_items_by_text()



func _on_visibility_changed() -> void:
	if not is_visible_in_tree() or _initialized:
		return
	
	var output_dir: DirAccess = DirAccess.open(str(SBTFTool.OUTPUT_PATH, "/sound"))
	var dirs_to_search: PackedStringArray = [str(SBTFTool.OUTPUT_PATH, "/sound")]
	var current_file: String = ""
	var valid_files: PackedStringArray = []
	
	if not output_dir.list_dir_begin() == OK:
		print(error_string(output_dir.get_open_error()))
		return
	
	# Do a recursive search for .tga files.
	while not dirs_to_search.is_empty():
		current_file = output_dir.get_next()
		
		if output_dir.current_is_dir():
			dirs_to_search.append(str(dirs_to_search[0], "/", current_file))
			continue
		
		if current_file.get_extension() == "wav":
			valid_files.append(str(dirs_to_search[0], "/", current_file))
			continue
		
		if current_file.is_empty():
			dirs_to_search.remove_at(0)
			
			if dirs_to_search.is_empty():
				break
			
			output_dir = output_dir.open(dirs_to_search[0])
			
			if not output_dir.list_dir_begin() == OK:
				break
	
	file_list.clear()
	
	for i in valid_files:
		file_list.add_item(i.trim_prefix(SBTFTool.OUTPUT_PATH))
		file_list.set_item_metadata(file_list.item_count - 1, {
			path_to = i,
			replacer = "",
		})
	
	file_list.sort_items_by_text()
	_initialized = true


func _on_item_selected(idx: int, item_list: ItemList) -> void:
	var metadata: Dictionary = item_list.get_item_metadata(idx)
	var previous_list: ItemList = _list
	_list = item_list
	_update_audio(metadata)
	
	if previous_list:
		if not previous_list == _list:
			var selected_items: PackedInt32Array = previous_list.get_selected_items()
			
			if selected_items:
				previous_list.deselect(selected_items[0])
	
	clear_replacer_button.disabled = (not _list == replacer_list)



func _on_ReplacerPath_set(new_path: String) -> void:
	var selected_items: PackedInt32Array = _list.get_selected_items()
	
	if not selected_items.is_empty():
		var metadata: Dictionary = _list.get_item_metadata(selected_items[0])
		metadata.replacer = new_path
		
		_update_list()
		_update_audio(metadata)
		_data[metadata.path_to] = metadata.replacer
		data_changed.emit(_data)


func _on_ClearReplacerButton_pressed() -> void:
	var selected_items: PackedInt32Array = replacer_list.get_selected_items()
	var metadata: Dictionary = {}
	
	if selected_items.is_empty():
		return
	
	metadata = replacer_list.get_item_metadata(selected_items[0])
	metadata.replacer = ""
	_update_list()
	_update_audio(metadata)
	_data.erase(metadata.path_to)
	data_changed.emit(_data)
	
	if replacer_list.item_count == 0:
		clear_replacer_button.disabled = true
	else:
		replacer_list.select(replacer_list.get_selected_items()[0])
