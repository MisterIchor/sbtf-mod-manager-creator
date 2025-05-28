extends HBoxContainer

var adrenaline: float = 0.0

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
	
	#print("-------------------------------------")
	
	for i: int in test_music_player_stream.stream_count:
		test_music_player_stream.set_sync_stream_volume(i, linear_to_db(layer_volume[i]))



func _on_Layer_path_set(path: String, layer_idx: int) -> void:
	var audio_stream: AudioStreamWAV = AudioStreamWAV.load_from_file(path)
	
	audio_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	audio_stream.loop_end = audio_stream.mix_rate * audio_stream.get_length()
	(test_music_player.stream as AudioStreamSynchronized).set_sync_stream(layer_idx, audio_stream)
	
	if test_music_player.playing:
		test_music_player.play()


func _on_TestThemeToggle_toggled(is_toggled: bool) -> void:
	if is_toggled and not test_music_player.playing:
		test_music_player.play()
	else:
		test_music_player.stop()
