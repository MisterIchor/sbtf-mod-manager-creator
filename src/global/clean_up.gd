extends Node



func _exit_tree() -> void:
	DirAccess.remove_absolute(Config.path_to_output)
