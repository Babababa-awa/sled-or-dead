class_name MapSection

var _data: DataLoader

var area: Dictionary
var obstacles: Array
var nodes: Array[Node2D] = []

func _init(data_: DataLoader) -> void:
	_data = data_
	
func build_start() -> void:
	area = _data.get_area(&"start", -1, -1)

	_build_obstacles(1)

func build_next(section: MapSection, max_height: int, difficulty: int) -> void:
	area = _data.get_area(
		section.area.top,
		max_height,
		difficulty,
	)

	_build_obstacles(difficulty)

func build_end(section: MapSection) -> void:
	area = _data.get_area_end(section.area.top, -1, -1)
	_build_obstacles(10)

func _build_obstacles(difficulty: int) -> void:
	var filtered = _get_filtered_obstacles(difficulty)
	
	if filtered.size() == 0:
		return
	
	var obstacle_areas = filtered.pick_random().areas
	
	_build_obstacle_areas(obstacle_areas, difficulty)

func _build_obstacle_areas(obstacle_areas: Array, difficulty: int, types: Array = []) -> void:
	for obstacle_area in obstacle_areas:
		var obstacle: Dictionary
		var x: int
		var y: int
		
		if obstacle_area is Array:
			obstacle = _data.get_obstacle(
				_get_obstacle_type(obstacle_area, types),
				obstacle_area[2],
				obstacle_area[3],
				difficulty
			)
			
			if obstacle.is_empty():
				continue
				
			x = obstacle_area[0] + randi_range(0, obstacle_area[2] - obstacle.width)
			y = obstacle_area[1] + randi_range(0, obstacle_area[3] - obstacle.height)
		elif obstacle_area.has("alias"):
			obstacle = _data.get_obstacle_from_alias(obstacle_area.alias)
			
			if obstacle.is_empty():
				continue
			
			x = obstacle_area.position[0] + randi_range(0, obstacle_area.size[0] - obstacle.width)
			y = obstacle_area.position[1] + randi_range(0, obstacle_area.size[1] - obstacle.height)
		elif obstacle_area.has("generate"):
			var max_obstacle_size = obstacle_area.max_obstacle_size if obstacle_area.has("max_obstacle_size") else obstacle_area.size
			var areas = _generate_obstacle_areas(
				Vector2i(obstacle_area.position[0], obstacle_area.position[1]),
				Vector2i(obstacle_area.size[0], obstacle_area.size[1]),
				Vector2i(max_obstacle_size[0], max_obstacle_size[1]),
				Vector2i(obstacle_area.spacing[0], obstacle_area.spacing[1]),
			)
			
			if obstacle_area.has("volume"):
				var count = int(round(obstacle_area.volume * areas.size()))
				areas = Global.select_random_items(areas, count)
			
			var area_types = types
			
			if obstacle_area.has("type"):
				area_types = [obstacle_area.type]
			elif obstacle_area.has("types"):
				area_types = obstacle_area.types
				
			_build_obstacle_areas(areas, difficulty, area_types)
			continue
		else:
			obstacle = _data.get_obstacle(
				_get_obstacle_type(obstacle_area, types),
				obstacle_area.size[0],
				obstacle_area.size[1],
				difficulty
			)
			
			if obstacle.is_empty():
				continue
				
			x = obstacle_area.position[0] + randi_range(0, obstacle_area.size[0] - obstacle.width)
			y = obstacle_area.position[1] + randi_range(0, obstacle_area.size[1] - obstacle.height)
	
		x *= Global.TILE_SIZE
		y *= Global.TILE_SIZE
		
		var position = Vector2(x, y)
		
		if obstacle.has("centered"):
			position.x += obstacle.width * Global.TILE_SIZE / 2
			position.y += obstacle.height * Global.TILE_SIZE / 2
			
		obstacles.push_back(MapObstacle.new(position, obstacle))

func _get_obstacle_type(obstacle_area, types: Array) -> StringName:
	if obstacle_area is Array:
		if obstacle_area.size() == 5:
			return StringName(obstacle_area[5])
			
		return &""
		
	if obstacle_area.has("type"):
		return StringName(obstacle_area.type)
		
	if types.size() > 0:
		return types.pick_random()

	return &""

func _get_filtered_obstacles(difficulty: int) -> Array:
	if not area.has("obstacles"):
		return []
		
	var filtered = area.obstacles.filter(
		func(item): 
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
		return _get_filtered_obstacles(difficulty - 1)
	
	return filtered
	
func _generate_obstacle_areas(
	position: Vector2i,
	size: Vector2i, 
	max_obstacle_size: Vector2i = Vector2i(12, 12), 
	spacing: Vector2i = Vector2i(2, 2)
) -> Array:
	var areas = []
	var occupied = []

	for y in range(0, size.y):
		for x in range(0, size.x):
			if Vector2i(x, y) in occupied:
				continue
			
			# Randomize box size within the constraints.
			var box_width = max(2, randi() % max_obstacle_size.x + 1)
			var box_height = max(2, min(max(randi() % max_obstacle_size.y + 1, box_width / 2), box_width + (box_width / 2)))
			
			# Ensure the box fits within the area.
			if x + box_width > size.x or y + box_height > size.y:
				continue
			
			var is_occupied = false
			for i in range(x, x + box_width - 1):
				for j in range(y, y + box_height - 1):
					if Vector2i(i, j) in occupied:
						is_occupied = true;
						break;
				if is_occupied:
					break;
					
			if is_occupied:
				continue
			
			var rect = {
				"position": [position.x + x, position.y + y],
				"size": [box_width, box_height]
			}
			areas.append(rect)
			
			# Mark the area as occupied, including spacing.
			for j in range(y - spacing.y, y + box_height + spacing.y):
				for i in range(x - spacing.x, x + box_width + spacing.x):
					if i >= 0 and j >= 0 and i < size.x and j < size.y:
						occupied.append(Vector2i(i, j))
	
	return areas
