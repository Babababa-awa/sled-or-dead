class_name DataLoader

var has_loaded: bool = false
var level_alias: StringName
var _data: Dictionary = {}

func _init(level_alias_: StringName) -> void:
	level_alias = level_alias_

func load() -> void:
	assert(has_loaded == false, "Data has already been loaded.")
	
	has_loaded = true
	
	_data[Global.DataType.AREA] = _load_data("res://data/" + level_alias + "/area")
	_data[Global.DataType.OBSTACLE] = _load_data("res://data/" + level_alias + "/obstacle")
	
func get_data(data_type: Global.DataType) -> Array:
	return _data[data_type]

func get_area(
	type: StringName,
	max_height: int,
	difficulty: int,
) -> Dictionary:
	assert(type != &"", "Type cannot be empty.")
	assert(max_height == -1 or max_height > 0, "Invalid max height.")
	assert(difficulty == -1 or difficulty > 0, "Invalid difficulty.")
	
	var filtered = _get_filtered_areas(type, max_height, difficulty, false)
		
	assert(
		filtered.size() != 0, 
		"A matching area was not found. (" + 
			type + ", " + 
			str(max_height) + ", " +
			str(difficulty) +
		")"
	)
	
	return filtered.pick_random()
	
func get_area_end(
	type: StringName,
	max_height: int,
	difficulty: int,
) -> Dictionary:
	assert(type != &"", "Type cannot be empty.")
	assert(max_height == -1 or max_height > 0, "Invalid max height.")
	assert(difficulty == -1 or difficulty > 0, "Invalid difficulty.")
	
	var filtered = _get_filtered_areas(type, max_height, difficulty, true)
	
	assert(
		filtered.size() != 0, 
		"A matching area was not found. (" + 
			type + ", " + 
			str(max_height) + ", " +
			str(difficulty) +
		")"
	)
	
	return filtered.pick_random()

func _get_filtered_areas(
	type: StringName,
	max_height: int,
	difficulty: int,
	end: bool = false
) -> Array:
	var filtered = _data[Global.DataType.AREA].filter(
		func(item): 
			if end:
				if item.top != "end":
					return false
			elif item.top == "end":
				return false
				
			if item.bottom != type:
				return false
								
			if max_height != -1 and item.height > max_height:
				return false
				
			if item.has("difficulty"):
				if item.difficulty != difficulty:
					return false
			
			if item.has("min_difficulty"):
				if difficulty < item.min_difficulty:
					return false
					
			if item.has("max_difficulty"):
				if difficulty > item.max_difficulty:
					return false
				
			return true
	)
	
	# Fall back to lower difficulty
	if filtered.size() == 0 and difficulty > 1:
		return _get_filtered_areas(type, max_height, difficulty - 1)
	
	return filtered
	
func get_obstacle(
	type: StringName,
	width: int,
	height: int,
	difficulty: int,
) -> Dictionary:
	var filtered = _data[Global.DataType.OBSTACLE].filter(
		func(item): 
			if type != &"":
				if not item.has("type") or item.type != type:
					return false
				
			if item.width > width or item.height > height:
				return false
			
			if item.has("difficulty"):
				if item.difficulty != difficulty:
					return false
			
			if item.has("min_difficulty"):
				if difficulty < item.min_difficulty:
					return false
					
			if item.has("max_difficulty"):
				if difficulty > item.max_difficulty:
					return false
				
			return true
	)
	
	# Fall back to lower difficulty
	if filtered.size() == 0 and difficulty > 1:
		return get_obstacle(type, width, height, difficulty - 1)
	
	assert(
		filtered.size() != 0, 
		"A matching obstacle was not found. (" + 
			type + ", " + 
			str(width) + ", " + 
			str(height) + ", " + 
			str(difficulty) + 
		")"
	)
	
	return _get_fitted_obstacle(filtered, width, height)
	
func get_obstacle_from_alias(alias: StringName) -> Dictionary:
	for obstacle in _data[Global.DataType.OBSTACLE]:
		if obstacle.alias == alias:
			return obstacle
			
	assert(false, "Obstacle not found. (" + alias + ")")
	return {}
	

func _get_fitted_obstacle(obstacles: Array, target_width: int, target_height: int) -> Dictionary:
	var matching = []
	var matching_all = []
	var min_area = int(round(target_width * target_height / 4.0))

	for item in obstacles:
		var item_width = item.width
		var item_height = item.height
		
		if item_width > target_width or item_height > target_height:
			continue
		
		var item_area = item_width * item_height
		
		matching_all.push_back(item)
		
		if item_area >= min_area:
			matching.push_back(item)

	if matching.size() > 0:
		return matching.pick_random()

	if matching_all.size() > 0:
		return matching_all.pick_random()
		
	return {}
	
func _load_data(base_path) -> Array:
	var data: Array = []
	
	var dir = DirAccess.open(base_path)
	
	assert(dir != null, "Data directory is empty.")

	dir.list_dir_begin()
	
	var file_name = dir.get_next()

	while file_name != "":
		if dir.current_is_dir():
			var sub_map = _load_data(base_path + "/" + file_name)
			data.append_array(sub_map)  # Merge results
		elif file_name.ends_with(".json"):
			var json = _load_json_file(base_path + "/" + file_name)
			if not json.is_empty():
				json.alias = file_name.get_basename()
				data.push_back(json)
				
		file_name = dir.get_next()

	dir.list_dir_end()
	
	return data

func _load_json_file(file: String) -> Dictionary:
	var handle = FileAccess.open(file, FileAccess.READ)
	if not handle:
		return {}
	
	var contents = handle.get_as_text()
	handle.close()

	var json = JSON.new()
	
	if json.parse(contents) != OK:
		return {}
	
	return json.data
