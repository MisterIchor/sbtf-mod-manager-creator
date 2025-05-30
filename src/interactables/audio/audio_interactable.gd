@tool
class_name AudioInteractable
extends InteractableBase

var stream: AudioStream = null:
	set(value):
		stream = value
		music_control_button.disabled = (stream == null)
		
		if not stream:
			return
		
		if not is_node_ready():
			await ready
		
		audio_stream_player.stream = stream
		file_name_label.text = stream.resource_path.get_file()
		time_slider.max_value = stream.get_length()
		time_slider.value = 0.0
		music_control_button.button_pressed = false

@onready var time_slider: HSlider = $TimeSlider
@onready var file_name_label: Label = $TimeSlider/FileNameLabel
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var music_control_button: Button = $MusicControlButton



func _ready() -> void:
	music_control_button.toggled.connect(_on_MusicControlButton_toggled)
	audio_stream_player.finished.connect(_on_AudioStreamPlayer_finished)


func _process(delta: float) -> void:
	if audio_stream_player.playing:
		time_slider.value = audio_stream_player.get_playback_position()



func _on_MusicControlButton_toggled(is_toggled: bool) -> void:
	if is_toggled:
		music_control_button.text = "Stop"
	else:
		music_control_button.text = "Play"
		time_slider.value = 0.0
	
	audio_stream_player.playing = is_toggled


func _on_AudioStreamPlayer_finished() -> void:
	music_control_button.button_pressed = false
	time_slider.value = 0.0
