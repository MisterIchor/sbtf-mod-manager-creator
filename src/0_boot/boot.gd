extends Window

const SBTFToolExecutationPath: String = "res://sbtftool/sbtftool"
const NwfPath: PackedScene = preload("res://src/prompts/nwf_path/nwf_path.tscn")



func _ready() -> void:
	var output: Array = []
	
	if not Config.load() == OK:
		var path_window: PopupPanel = NwfPath.instantiate()
		
		Config.create()
		path_window.instantiate().popup_exclusive_centered(self)
		
		while true:
			await path_window.popup_hide
			
			if not OS.execute(ProjectSettings.globalize_path(SBTFToolExecutationPath), ["verify", Config.path_to_nwf], output, true) == 115:
				break
			
			path_window = NwfPath.instantiate().popup_exclusive_centered(self)
	
