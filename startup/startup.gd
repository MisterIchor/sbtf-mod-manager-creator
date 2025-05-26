extends Window

const NwfPath: PackedScene = preload("res://prompts/nwf_path/nwf_path.tscn")

func _ready() -> void:
	NwfPath.instantiate().popup_exclusive(self)
	if not Config.load() == OK:
		pass
