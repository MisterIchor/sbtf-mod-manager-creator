extends VBoxContainer

signal data_changed(new_data: Dictionary)

var adrenaline: float = 0.0
var _data: Dictionary = {}
var _selected_theme: String = ""

@onready var theme_settings_container: HBoxContainer = $ThemeSettingsContainer
@onready var selected_theme_option_button: OptionButton = $GlobalThemeSettingsContainer/SelectedThemeOptionButton
@onready var remove_theme_button: Button = $GlobalThemeSettingsContainer/RemoveThemeButton
@onready var theme_name_line_edit: LineEdit = $GlobalThemeSettingsContainer/ThemeNameLineEdit
@onready var add_theme_button: Button = $GlobalThemeSettingsContainer/AddThemeButton
@onready var overwrite_theme_toggle: ToggleOptionInteractable = $ThemeSettingsContainer/LayerSettings/OverwriteThemeToggle
@onready var test_theme_toggle: ToggleOptionInteractable = $ThemeSettingsContainer/TestContainer/TestThemeToggle
@onready var space_beast_spawned_slider: SliderInteractable = $ThemeSettingsContainer/TestContainer/SpaceBeastSpawnedSlider
@onready var beast_distance_to_player_slider: SliderInteractable = $ThemeSettingsContainer/TestContainer/BeastDistanceToPlayerSlider
@onready var test_music_player: AudioStreamPlayer = $TestMusicPlayer
@onready var test_music_player_stream: AudioStreamSynchronized = $TestMusicPlayer.stream
@onready var layers: Array[PathToInteractable] = [
	$ThemeSettingsContainer/LayerSettings/Layer0, 
	$ThemeSettingsContainer/LayerSettings/Layer1, 
	$ThemeSettingsContainer/LayerSettings/Layer2,
	$ThemeSettingsContainer/LayerSettings/Layer3,
	$ThemeSettingsContainer/LayerSettings/Layer4,
	$ThemeSettingsContainer/LayerSettings/Layer5,
	$ThemeSettingsContainer/LayerSettings/Layer6,
	$ThemeSettingsContainer/LayerSettings/Layer7
]


func _ready() -> void:
	for i in layers:
		i.path_set.connect(_on_Layer_path_set.bind(int(i.name)))
	
	test_theme_toggle.toggled.connect(_on_TestThemeToggle_toggled)
	beast_distance_to_player_slider.value_changed.connect(_update_adrenaline.unbind(1))
	space_beast_spawned_slider.value_changed.connect(_update_adrenaline.unbind(1))
	add_theme_button.pressed.connect(_on_AddThemeButton_pressed)
	selected_theme_option_button.item_selected.connect(_on_SelectedThemeOptionButton_item_selected)
	theme_name_line_edit.text_changed.connect(_on_ThemeNameLineEdit_text_changed)
	theme_name_line_edit.text_submitted.connect(_on_AddThemeButton_pressed.unbind(1))
	remove_theme_button.pressed.connect(_on_RemoveThemeButton_pressed)
	overwrite_theme_toggle.toggled.connect(_on_OverwriteThemeToggle_toggled)



func _update_adrenaline() -> void:
	adrenaline = 0
	adrenaline += 0.5 * (space_beast_spawned_slider.value / space_beast_spawned_slider.max_value)
	adrenaline += (1.0 - adrenaline) * ease(1 - (beast_distance_to_player_slider.value / beast_distance_to_player_slider.max_value), 0.4)
	
	var section: float = 1.0 / 8.0
	var layer_volume: PackedFloat32Array = []
	layer_volume.resize(8)
	
	for i in 8:
		var section_start: float = section * i
		var section_end: float = section * (i + 1)
		var adrenaline_modulo: float = fmod(adrenaline, section)
		
		# Linearly scale volume if between sections.
		if adrenaline > section_start and adrenaline < section_end:
			layer_volume[i] = adrenaline_modulo / section
		elif adrenaline > section_start:
			layer_volume[i] = 1.0
	
	for i: int in test_music_player_stream.stream_count:
		test_music_player_stream.set_sync_stream_volume(i, linear_to_db(layer_volume[i]))


func _update_settings() -> void:
	for i in _data[_selected_theme].layers.size():
		var path: String = _data[_selected_theme].layers[i]
		
		if path.is_empty():
			continue
		
		var audio_stream: AudioStreamWAV = AudioStreamWAV.load_from_file(path)
		
		# Enable loop and set the loop end to the end of the AudioStream.
		audio_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		audio_stream.loop_end = audio_stream.mix_rate * audio_stream.get_length()
		test_music_player_stream.set_sync_stream(i, audio_stream)
		layers[i].line_edit.text = path
	
	overwrite_theme_toggle.check_button.button_pressed = _data[_selected_theme].overwrites_existing_theme



func _on_Layer_path_set(path: String, layer_idx: int) -> void:
	_data[_selected_theme].layers[layer_idx] = path
	data_changed.emit(_data)
	_update_settings()
	
	if test_music_player.playing:
		test_music_player.play()


func _on_TestThemeToggle_toggled(is_toggled: bool) -> void:
	if is_toggled and not test_music_player.playing:
		test_music_player.play()
		_update_adrenaline()
	else:
		test_music_player.stop()


func _on_AddThemeButton_pressed() -> void:
	if not _data.get(theme_name_line_edit.text):
		var array: PackedStringArray = []
		array.resize(8)
		_data[theme_name_line_edit.text] = {
			layers = array,
			overwrites_existing_theme = false
		}
		data_changed.emit(_data)
	
	selected_theme_option_button.add_item(theme_name_line_edit.text)
	selected_theme_option_button.select(selected_theme_option_button.item_count - 1)
	theme_settings_container.show()
	_selected_theme = theme_name_line_edit.text
	theme_name_line_edit.text = ""
	remove_theme_button.disabled = false
	add_theme_button.disabled = true
	_update_settings()


func _on_RemoveThemeButton_pressed() -> void:
	var selected_theme_idx: int = selected_theme_option_button.selected
	var theme_to_remove: String = selected_theme_option_button.get_item_text(selected_theme_idx)
	
	selected_theme_option_button.remove_item(selected_theme_idx)
	selected_theme_option_button.select(selected_theme_option_button.get_selectable_item())
	_data.erase(theme_to_remove)
	data_changed.emit(_data)
	
	if not selected_theme_option_button.has_selectable_items():
		remove_theme_button.disabled = true
		theme_settings_container.hide()
	else:
		var next_item_idx: int = selected_theme_option_button.get_selectable_item()
		_selected_theme = selected_theme_option_button.get_item_text(next_item_idx)
		_update_settings()


func _on_SelectedThemeOptionButton_item_selected(idx: int) -> void:
	_selected_theme = selected_theme_option_button.get_item_text(idx)
	_update_settings()


func _on_ThemeNameLineEdit_text_changed(new_text: String) -> void:
	add_theme_button.disabled = new_text.is_empty()


func _on_OverwriteThemeToggle_toggled(is_toggled: bool) -> void:
	_data[_selected_theme].overwrites_existing_theme = is_toggled
	data_changed.emit(_data)
