extends Node



func _exit_tree() -> void:
	remove_output()


func remove_output() -> void:
	var output_dir: DirAccess = DirAccess.open(Config.path_to_output)
	var dirs_to_search: PackedStringArray = [Config.path_to_output]
	var dirs_to_remove: PackedStringArray = []
	var current_file: String = ""
	
	if not output_dir.list_dir_begin() == OK:
		print(error_string(output_dir.get_open_error()))
		return
	
	while not dirs_to_search.is_empty():
		current_file = output_dir.get_next()
		
		if output_dir.current_is_dir():
			# For some reason, an empty string is considered a directory. If we don't catch this, 
			# it creates a massive memory leak capable of devouring all of your RAM.
			if not current_file.is_empty():
				dirs_to_search.append(str(dirs_to_search[0], "/", current_file))
				continue
		
		output_dir.remove(current_file)
		
		if current_file.is_empty():
			dirs_to_remove.append(output_dir.get_current_dir())
			dirs_to_search.remove_at(0)
			
			if dirs_to_search.is_empty():
				break
			
			output_dir = output_dir.open(dirs_to_search[0])
			
			if not output_dir.list_dir_begin() == OK:
				print("CleanUp: failed to open dir, ending clean up.")
				break
	
	dirs_to_remove.reverse()
	
	for i in dirs_to_remove:
		output_dir.remove_absolute(i)
