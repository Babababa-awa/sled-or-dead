class_name Map

var _data: DataLoader
var _height: int

var _sections: Array[MapSection] = []
var _current_height: int = 0
var _max_height: int = 0
var _has_start: bool = false
var _has_end: bool = false
var _last_section: MapSection = null
var current_difficulty: int = 1

func _init(data_: DataLoader, height_: int) -> void:
	_data = data_
	_height = height_
	_max_height = _height
	
func reset() -> void:
	_sections = []
	_current_height = 0
	_max_height = _height
	_has_start = false
	_has_end = false
	_last_section = null
	current_difficulty = 1
	
func pop_section() -> MapSection:
	if _sections.size() == 0:
		if not _has_start:
			_start_map()
		elif _max_height == -1 or _current_height < _max_height:
			_continue_map()
		elif not _has_end:
			_end_map()
			
	_last_section = _sections.pop_front()
	return _last_section
	
func _start_map() -> void:
	assert(_has_start == false, "Map has already started.")
	_has_start = true
	
	var section = MapSection.new(_data)
	section.build_start()
	_sections.push_back(section)
	
	_current_height += section.area.height
	
	# Dont count start as part of height.
	if _max_height != -1:
		_max_height += section.area.height
	
func _continue_map() -> void:
	assert(_has_start == true, "Map has not started.")
	assert(_has_end == false, "Map has already ended.")
	assert(_max_height == -1 or _current_height < _max_height, "Map can't be continued.")
	
	var current_max_height: int = _max_height
	if current_max_height != -1:
		current_max_height -= _current_height
		
	var difficulty: int = 1
	if _max_height == -1:
		difficulty = _get_random_difficulty(min(1.0, float(_current_height) / Global.MAX_MAP_HEIGHT))
	else:
		difficulty = _get_random_difficulty(float(_current_height) / _max_height)
		
	#difficulty = 10
	
	current_difficulty = difficulty
	
	if _sections.size() > 0:
		_last_section = _sections.back()
		
	var section = MapSection.new(_data)
	section.build_next(
		_last_section, 
		current_max_height,
		difficulty
	)
	_sections.push_back(section)
	_current_height += section.area.height
		
func _end_map() -> void:
	assert(_has_start == true, "Map has not started.")
	assert(_has_end == false, "Map has already ended.")
	
	if _sections.size() > 0:
		_last_section = _sections.back()
	
	var section = MapSection.new(_data)
	section.build_end(_last_section)
	_sections.push_back(section)
	
	_has_end = true
	
func _get_random_difficulty(value: float) -> int:
	value = clamp(value, 0.0, 1.0)

	#var random_value = pow(randf(), 1.0 / (1.0 + bias * 9.0))
	
	return int(round(value * 9.0)) + 1
