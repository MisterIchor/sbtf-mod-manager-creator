class_name SBTFMod
extends Object



static func decompile(path: String, output_path: String) -> Error:
	var mod: ZIPReader = ZIPReader.new()
	
	if not mod.open(path) == OK:
		prints(path, "open failed.")
		return ERR_CANT_OPEN
	
	prints(path, "opened successfully.")
	var dir: DirAccess = DirAccess.open(output_path)
	
	if not dir:
		print("SBTFMod: could not open ", output_path, ".")
		return ERR_CANT_OPEN
	
	for file_path in mod.get_files():
		if file_path.ends_with("/"):
			dir.make_dir_recursive(dir.get_current_dir().path_join(file_path).get_base_dir())
			prints(file_path, "dir made recursively.")
			continue
		
		if "description" in file_path:
			continue
		
		if "theme_schemas" in file_path:
			var schema_file: FileAccess = FileAccess.open(dir.get_current_dir().path_join("schema.xml"), FileAccess.READ_WRITE)
			
			if not schema_file:
				prints("Schema not found at ", dir.get_current_dir().path_join("schema.xml"))
				continue
			
			var theme_schema_text: String = mod.read_file(file_path).get_string_from_utf8()
			var schema_file_text: String = schema_file.get_as_text()
		
			schema_file.store_string(schema_file_text.insert(169, theme_schema_text))
			schema_file.close()
			continue
		
		if "added_themes" in file_path:
			var themes_file: FileAccess = FileAccess.open(dir.get_current_dir().path_join("themes.txt"), FileAccess.READ_WRITE)
			
			if not themes_file:
				prints("Themes file not found at ", dir.get_current_dir().path_join("themes.txt"))
				continue
			
			var added_themes_text: String = mod.read_file(file_path).get_string_from_utf8()
			
			themes_file.seek(themes_file.get_length())
			themes_file.store_string(added_themes_text)
			themes_file.close()
			continue
		
		if "data_changes" in file_path:
			var data_changes: PackedStringArray = mod.read_file(file_path).get_string_from_utf8().split("\n", false)
			var current_file: String = ""
			var data_file: FileAccess = null
			var data_file_lines: PackedStringArray = []
			
			for line in data_changes:
				if line.begins_with("[") and line.ends_with("]"):
					if data_file:
						data_file.store_string("\n".join(data_file_lines))
					
					current_file = line.replace("[", "")
					current_file = current_file.replace("]", "")
					data_file = FileAccess.open(dir.get_current_dir().path_join(current_file), FileAccess.READ_WRITE)
					data_file_lines = data_file.get_as_text().split("\n", false)
					continue
				
				if not data_file:
					prints("No data file found at ", dir.get_current_dir().path_join(current_file))
					continue
				
				var change_pos_arr: PackedStringArray = line.split("/")
				var line_to_edit: PackedStringArray = data_file_lines[int(change_pos_arr[1])].split("=")
				
				line_to_edit[1] = change_pos_arr[0]
				data_file_lines[int(change_pos_arr[1])] = "=".join(line_to_edit)
			
			data_file.store_string("\n".join(data_file_lines))
			data_file.close()
			continue
		
		dir.make_dir_recursive(dir.get_current_dir().path_join(file_path).get_base_dir())
		var file: FileAccess = FileAccess.open(dir.get_current_dir().path_join(file_path), FileAccess.WRITE)
		
		if not file:
			prints(dir.get_current_dir().path_join(file_path).get_base_dir(), "failed to open.")
			continue
		
		var buffer: PackedByteArray = mod.read_file(file_path)
		file.resize(0)
		file.store_buffer(buffer)
		prints(file_path, "file created.")
	
	print(path, "decompilation complete!")
	return OK
