extends TextureRect

const NwfPath: PackedScene = preload("res://src/prompts/nwf_path/nwf_path.tscn")
const InvalidFile: PackedScene = preload("res://src/prompts/nwf_path/invalid_file.tscn")



func _ready() -> void:
	if not SBTFTool.verify_nwf() == 0:
		while true:
			var nwf_window: AcceptDialog = NwfPath.instantiate()
			
			nwf_window.popup_exclusive_centered.call_deferred(self)
			nwf_window.close_requested.connect(_on_close_requested)
			await nwf_window.confirmed
			nwf_window.queue_free()
			
			await get_tree().process_frame
			if not SBTFTool.verify_nwf() == 0:
				var invalid_window: AcceptDialog = InvalidFile.instantiate()
				
				invalid_window.popup_exclusive_centered.call_deferred(self)
				await invalid_window.confirmed
				continue
			
			break
	
	var cmdline_arguments: PackedStringArray = OS.get_cmdline_user_args()
	
	for i in cmdline_arguments:
		if "--start" in i:
			var section: String = i.get_slice("=", 1)
			
			if section.matchn("manager"):
				get_tree().change_scene_to_file("res://src/2_manager/manager.tscn")
				return
			
			if section.matchn("creator"):
				get_tree().change_scene_to_file("res://src/2_creator/create_a_mod.tscn")
				return
	
	get_tree().change_scene_to_file("res://src/1_start/start.tscn")



func _on_close_requested() -> void: 
	get_tree().quit()
