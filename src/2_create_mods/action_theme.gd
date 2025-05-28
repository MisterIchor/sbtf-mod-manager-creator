extends HBoxContainer

signal data_changed(new_data: Dictionary)

var adrenaline: float = 0.0
var _data: Dictionary = {}
var _selected_theme: String = ""

@onready var theme_name_line_edit: LineEdit = $SettingsContainer/AddThemeContainer/ThemeNameLineEdit
@onready var selected_theme_option_button: OptionButton = $SettingsContainer/HBoxContainer/SelectedThemeOptionButton
@onready var remove_theme_button: Button = $SettingsContainer/HBoxContainer/RemoveThemeButton
@onready var add_theme_button: Button = $SettingsContainer/AddThemeContainer/AddThemeButton
@onready var test_music_player: AudioStreamPlayer = $TestMusicPlayer
@onready var test_music_player_stream: AudioStreamSynchronized = $TestMusicPlayer.stream
@onready var test_theme_toggle: ToggleOptionInteractable = $TestContainer/TestThemeToggle
@onready var space_beast_spawned_slider: SliderInteractable = $TestContainer/SpaceBeastSpawnedSlider
@onready var beast_distance_to_player_slider: SliderInteractable = $TestContainer/BeastDistanceToPlayerSlider
@onready var layers: Array[PathToInteractable] = [
	$SettingsContainer/Layer0, 
	$SettingsContainer/Layer1, 
	$SettingsContainer/Layer2, 
	$SettingsContainer/Layer3, 
	$SettingsContainer/Layer4, 
	$SettingsContainer/Layer5, 
	$SettingsContainer/Layer6, 
	$SettingsContainer/Layer7
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


func _update_audio_files() -> void:
	for i in _data[_selected_theme]:
		var audio_stream: AudioStreamWAV = AudioStreamWAV.load_from_file(i)
		
		# Enable loop and set the loop end to the end of the AudioStream.
		audio_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		audio_stream.loop_end = audio_stream.mix_rate * audio_stream.get_length()
		test_music_player_stream.set_sync_stream(i, audio_stream)



func _on_Layer_path_set(path: String, layer_idx: int) -> void:
	_update_audio_files()
	_data[_selected_theme][layer_idx] = path
	data_changed.emit(_data)
	
	if test_music_player.playing:
		test_music_player.play()


func _on_TestThemeToggle_toggled(is_toggled: bool) -> void:
	if is_toggled and not test_music_player.playing:
		test_music_player.play()
	else:
		test_music_player.stop()


func _on_AddThemeButton_pressed() -> void:
	_data.get_or_add(theme_name_line_edit.text, PackedStringArray().resize(8))
	selected_theme_option_button.add_item(theme_name_line_edit.text)
	theme_name_line_edit.text = ""
	remove_theme_button.disabled = false
	add_theme_button.disabled = true


func _on_RemoveThemeButton_pressed() -> void:
	var selected_theme_idx: int = selected_theme_option_button.selected
	var theme_to_remove: String = selected_theme_option_button.get_item_text(selected_theme_idx)
	
	selected_theme_option_button.remove_item(selected_theme_idx)
	selected_theme_option_button.select(selected_theme_option_button.get_selectable_item())
	_data.erase(theme_to_remove)
	data_changed.emit(_data)
	
	if not selected_theme_option_button.has_selectable_items():
		remove_theme_button.disabled = true


func _on_SelectedThemeOptionButton_item_selected(idx: int) -> void:
	_selected_theme = selected_theme_option_button.get_item_text(idx)
	_update_audio_files()


func _on_ThemeNameLineEdit_text_changed(new_text: String) -> void:
	add_theme_button.disabled = new_text.is_empty()
