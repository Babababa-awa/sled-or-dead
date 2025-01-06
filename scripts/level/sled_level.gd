extends BaseLevel
class_name SledLevel

var total_height: int
var map: Map

var _data: DataLoader
var _loaded_sections: Array = []
var _loaded_height: int = 0
var _unloaded_height: int = 0

var _update_map_cooldown = 0
const UPDATE_MAP_COOLDOWN_DELTA = 1.0

func _init(alias_: StringName, total_height_: int = -1) -> void:
	super._init(alias_)
	
	if Global.game_mode == Global.GameMode.INFINITE:
		total_height = -1
	else:
		total_height = total_height_

	_data = DataLoader.new(alias_)
	_data.load()
	
	map = Map.new(_data, total_height)

func _process(delta: float) -> void:
	if not Global.game.is_enabled:
		return

	_update_map_cooldown += delta
	if _update_map_cooldown > UPDATE_MAP_COOLDOWN_DELTA:
		_update_map_cooldown = 0.0
		_update_map()

func reset() -> void:
	map.reset()
	_loaded_sections = []
	_loaded_height = 0
	_unloaded_height = 0
	
func start() -> void:
	await _load_sections()
	
	_start_map()
	_start_units()
	
	super.start()
	
func restart() -> void:
	reset()

	_start_map()
	_start_units()
	
	super.restart()

func _start_units() -> void:
	match Global.vehicle_type:
		Global.VehicleType.SLED_HAMMER:
			await Global.game.change_vehicle(&"sled_hammer")
		Global.VehicleType.SNOWTORCYCLE:
			await Global.game.change_vehicle(&"snowtorcycle")
			
	Global.game.set_vehicle_position(0, -8)
	
	match Global.driver_player_type:
		Global.PlayerType.JELLY:
			await Global.game.change_driver(&"jelly")
		Global.PlayerType.PIPPA:
			await Global.game.change_driver(&"pippa")
		Global.PlayerType.REMI:
			await Global.game.change_driver(&"remi")
	
	match Global.passenger_player_type:
		Global.PlayerType.JELLY:
			await Global.game.change_passenger(&"jelly")
		Global.PlayerType.PIPPA:
			await Global.game.change_passenger(&"pippa")
		Global.PlayerType.REMI:
			await Global.game.change_passenger(&"remi")
	
	
	await Global.game.change_cursor(&"weapon")
	
	Global.active_player = Global.PlayerMode.PASSENGER
	Global.cursor.weapon_type = Global.passenger.primary_weapon.weapon_type
	
	Global.game.show_ui(&"hud")
	
func _load_sections() -> void:
	var areas = _data.get_data(Global.DataType.AREA)

	for area in areas:
		if area.bottom == "start" or area.top == "end":
			Global.nodes.load(area.scene, 1)
		else:
			Global.nodes.load(area.scene, 3)

	# Preload objects
	Global.nodes.load("res://scenes/level/mountain/obstacle/medium_bush2.tscn", 12)
	Global.nodes.load("res://scenes/level/mountain/obstacle/medium_bush.tscn", 12)
	Global.nodes.load("res://scenes/level/mountain/obstacle/medium_jump.tscn", 12)
	Global.nodes.load("res://scenes/level/mountain/obstacle/medium_rock.tscn", 12)
	Global.nodes.load("res://scenes/level/mountain/obstacle/medium_rock_jump.tscn", 6)
	Global.nodes.load("res://scenes/level/mountain/obstacle/medium_stump.tscn", 12)
	Global.nodes.load("res://scenes/level/mountain/obstacle/medium_tree.tscn", 12)
	Global.nodes.load("res://scenes/level/mountain/obstacle/small_ice2.tscn", 12)
	Global.nodes.load("res://scenes/level/mountain/obstacle/small_ice3.tscn", 12)
	Global.nodes.load("res://scenes/level/mountain/obstacle/small_ice.tscn", 12)
	Global.nodes.load("res://scenes/level/mountain/obstacle/small_jump.tscn", 12)
	Global.nodes.load("res://scenes/level/mountain/obstacle/small_rock2.tscn", 12)
	Global.nodes.load("res://scenes/level/mountain/obstacle/small_rock.tscn", 12)
	
	
	Global.nodes.load("res://scenes/unit/object/medium_crate.tscn", 12)
	Global.nodes.load("res://scenes/unit/object/small_crate.tscn", 12)

	# Preload projectiles
	Global.nodes.load("res://scenes/unit/projectile/bullet.tscn", 32)
	Global.nodes.load("res://scenes/unit/projectile/rocket.tscn", 16)
	Global.nodes.load("res://scenes/unit/projectile/explosion.tscn", 8)
	
	while Global.nodes.is_loading:
		await get_tree().process_frame
	

func _start_map() -> void:
	while _loaded_height < Global.MIN_MAP_LOAD_HEIGHT:
		var section = map.pop_section()
		_add_section(section)

func _add_section(section: MapSection) -> void:
	var loaded_nodes: Array[Node2D] = []
	
	_loaded_height += section.area.height
	var area_position = Vector2(0, -_loaded_height * Global.TILE_SIZE)
	
	var node = await Global.nodes.get_node(section.area.scene)
	node.position = area_position
	loaded_nodes.push_back(node)
	
	for obstacle in section.obstacles:
		var obstacle_node = await Global.nodes.get_node(obstacle.scene)
		obstacle_node.position = node.position + obstacle.position
		loaded_nodes.push_back(obstacle_node)
	
	section.nodes = loaded_nodes
	
	_loaded_sections.push_back(section)

func _remove_section() -> void:
	var section = _loaded_sections.pop_front()
	_unloaded_height += section.area.height

	Global.nodes.free_nodes(section.nodes)
	
func _update_map() -> void:
	_unload_completed_map()
		
	var travel_distance = _loaded_height * Global.TILE_SIZE
	var current_distance = abs(Global.vehicle.position.y - (Global.MIN_MAP_LOAD_HEIGHT * Global.TILE_SIZE))
		
	while travel_distance < current_distance:
		var section = map.pop_section()
		if section == null:
			break
		_add_section(section)
		travel_distance = _loaded_height * Global.TILE_SIZE
		break

	
func _unload_completed_map() -> void:
	if not _loaded_sections.size():
		return
		
	while true:
		var section = _loaded_sections.front()
		if section == null or section.nodes.size() == 0:
			break
		
		# First node is always the area scene
		if section.nodes[0].position.y > Global.vehicle.position.y + (Global.MIN_MAP_UNLOAD_HEIGHT * Global.TILE_SIZE):
			_remove_section()
		else:
			break
	
