extends Node2D

@export_enum("Driver", "Passenger", "Vehicle") var type: String = "Driver"

var _portrait_player_type: Global.PlayerType = Global.PlayerType.NONE
var _portrait_health: int = 0
var _portrait_x_index: int = 0
var _portrait_y_index: int = 0

func _ready() -> void:
	_update_overlay()
	_update()

func _process(_delta: float) -> void:
	_update()
			
func _update_overlay() -> void:
	match type:
		"Driver":
			$TileMapLayerOverlay.set_cell(Vector2i(0, 0), $TileMapLayerOverlay.tile_set.get_source_id(0), Vector2i(0, 0))
		"Passenger":
			$TileMapLayerOverlay.set_cell(Vector2i(0, 0), $TileMapLayerOverlay.tile_set.get_source_id(0), Vector2i(1, 0))
		"Vehicle":
			$TileMapLayerOverlay.set_cell(Vector2i(0, 0), $TileMapLayerOverlay.tile_set.get_source_id(0), Vector2i(2, 0))
			

func _update() -> void:
	match type:
		"Driver":
			_update_driver()
		"Passenger":
			_update_passenger()
		"Vehicle":
			_update_vehicle()
	
func _update_driver() -> void:
	var driver_health = 0 if Global.driver == null else Global.driver.health
	var update_portrait: bool
	
	if Global.driver == null:
		update_portrait = (_portrait_player_type != Global.PlayerType.NONE)
		_portrait_player_type = Global.PlayerType.NONE
	else:
		update_portrait = (_portrait_player_type != Global.driver.player_type)
		_portrait_player_type = Global.driver.player_type
	
	if driver_health == _portrait_health and not update_portrait:
		return
	
	_portrait_health = driver_health
	_portrait_x_index = _player_type_to_portrait_x_index(_portrait_player_type)
	_portrait_y_index = _health_to_portrait_y_index(_portrait_health)

	_update_portrait()
	_update_health(0)
	
func _update_passenger() -> void:
	var passenger_health = 0 if Global.passenger == null else Global.passenger.health
	var update_portrait: bool
	
	if Global.passenger == null:
		update_portrait = (_portrait_player_type != Global.PlayerType.NONE)
		_portrait_player_type = Global.PlayerType.NONE
	else:
		update_portrait = (_portrait_player_type != Global.passenger.player_type)
		_portrait_player_type = Global.passenger.player_type
	
	if passenger_health == _portrait_health and not update_portrait:
		return
	
	_portrait_health = passenger_health
	_portrait_x_index = _player_type_to_portrait_x_index(_portrait_player_type)
	_portrait_y_index = _health_to_portrait_y_index(_portrait_health)
	
	_update_portrait()
	_update_health(0)
	
func _update_vehicle() -> void:
	var vehicle_health = 0 if Global.vehicle == null else Global.vehicle.health
	
	if vehicle_health == _portrait_health:	
		return
		
	_portrait_health = vehicle_health
	_portrait_x_index = _vehicle_type_to_portrait_x_index(Global.vehicle_type)
	_portrait_y_index = _health_to_portrait_y_index(_portrait_health)
	
	_update_portrait()
	_update_health(2)
	
func _update_portrait() -> void:
	$TileMapLayerPortrait.set_cell(Vector2i(0, 0), $TileMapLayerPortrait.tile_set.get_source_id(0), Vector2i(_portrait_x_index, _portrait_y_index))

func _update_health(offset_x: int) -> void:
	if _portrait_health == 100:
		$TileMapLayerHealth1.set_cell(Vector2i(0, 0), $TileMapLayerHealth1.tile_set.get_source_id(0), Vector2i(offset_x, 0))
		$TileMapLayerHealth2.set_cell(Vector2i(0, 0), $TileMapLayerHealth2.tile_set.get_source_id(0), Vector2i(offset_x, 0))
		$TileMapLayerHealth3.set_cell(Vector2i(0, 0), $TileMapLayerHealth3.tile_set.get_source_id(0), Vector2i(offset_x, 0))
	elif _portrait_health == 0:
		$TileMapLayerHealth1.set_cell(Vector2i(0, 0))
		$TileMapLayerHealth2.set_cell(Vector2i(0, 0))
		$TileMapLayerHealth3.set_cell(Vector2i(0, 0))
	else:
		var count = get_health_count(_portrait_health)
		
		if count <= 8:
			$TileMapLayerHealth3.set_cell(Vector2i(0, 0))
		
		if count <= 4:
			$TileMapLayerHealth2.set_cell(Vector2i(0, 0))
		
		match count:
			1:
				$TileMapLayerHealth1.set_cell(Vector2i(0, 0), $TileMapLayerHealth1.tile_set.get_source_id(0), Vector2i(offset_x + 1, 1))
			2:
				$TileMapLayerHealth1.set_cell(Vector2i(0, 0), $TileMapLayerHealth1.tile_set.get_source_id(0), Vector2i(offset_x, 1))
			3:
				$TileMapLayerHealth1.set_cell(Vector2i(0, 0), $TileMapLayerHealth1.tile_set.get_source_id(0), Vector2i(offset_x + 1, 0))
			4:
				$TileMapLayerHealth1.set_cell(Vector2i(0, 0), $TileMapLayerHealth1.tile_set.get_source_id(0), Vector2i(offset_x, 0))
			5:
				$TileMapLayerHealth1.set_cell(Vector2i(0, 0), $TileMapLayerHealth1.tile_set.get_source_id(0), Vector2i(offset_x, 0))
				$TileMapLayerHealth2.set_cell(Vector2i(0, 0), $TileMapLayerHealth2.tile_set.get_source_id(0), Vector2i(offset_x + 1, 1))
			6:
				$TileMapLayerHealth1.set_cell(Vector2i(0, 0), $TileMapLayerHealth1.tile_set.get_source_id(0), Vector2i(offset_x, 0))
				$TileMapLayerHealth2.set_cell(Vector2i(0, 0), $TileMapLayerHealth2.tile_set.get_source_id(0), Vector2i(offset_x, 1))
			7:
				$TileMapLayerHealth1.set_cell(Vector2i(0, 0), $TileMapLayerHealth1.tile_set.get_source_id(0), Vector2i(offset_x, 0))
				$TileMapLayerHealth2.set_cell(Vector2i(0, 0), $TileMapLayerHealth2.tile_set.get_source_id(0), Vector2i(offset_x + 1, 0))
			8:
				$TileMapLayerHealth1.set_cell(Vector2i(0, 0), $TileMapLayerHealth1.tile_set.get_source_id(0), Vector2i(offset_x, 0))
				$TileMapLayerHealth2.set_cell(Vector2i(0, 0), $TileMapLayerHealth2.tile_set.get_source_id(0), Vector2i(offset_x, 0))
			9:
				$TileMapLayerHealth1.set_cell(Vector2i(0, 0), $TileMapLayerHealth1.tile_set.get_source_id(0), Vector2i(offset_x, 0))
				$TileMapLayerHealth2.set_cell(Vector2i(0, 0), $TileMapLayerHealth2.tile_set.get_source_id(0), Vector2i(offset_x, 0))
				$TileMapLayerHealth3.set_cell(Vector2i(0, 0), $TileMapLayerHealth3.tile_set.get_source_id(0), Vector2i(offset_x + 1, 1))
			10:
				$TileMapLayerHealth1.set_cell(Vector2i(0, 0), $TileMapLayerHealth1.tile_set.get_source_id(0), Vector2i(offset_x, 0))
				$TileMapLayerHealth2.set_cell(Vector2i(0, 0), $TileMapLayerHealth2.tile_set.get_source_id(0), Vector2i(offset_x, 0))
				$TileMapLayerHealth3.set_cell(Vector2i(0, 0), $TileMapLayerHealth3.tile_set.get_source_id(0), Vector2i(offset_x, 1))
			11:
				$TileMapLayerHealth1.set_cell(Vector2i(0, 0), $TileMapLayerHealth1.tile_set.get_source_id(0), Vector2i(offset_x, 0))
				$TileMapLayerHealth2.set_cell(Vector2i(0, 0), $TileMapLayerHealth2.tile_set.get_source_id(0), Vector2i(offset_x, 0))
				$TileMapLayerHealth3.set_cell(Vector2i(0, 0), $TileMapLayerHealth3.tile_set.get_source_id(0), Vector2i(offset_x + 1, 0))
			12:
				$TileMapLayerHealth1.set_cell(Vector2i(0, 0), $TileMapLayerHealth1.tile_set.get_source_id(0), Vector2i(offset_x, 0))
				$TileMapLayerHealth2.set_cell(Vector2i(0, 0), $TileMapLayerHealth2.tile_set.get_source_id(0), Vector2i(offset_x, 0))
				$TileMapLayerHealth3.set_cell(Vector2i(0, 0), $TileMapLayerHealth3.tile_set.get_source_id(0), Vector2i(offset_x, 0))
	
func _player_type_to_portrait_x_index(player_type: Global.PlayerType) -> int:
	match player_type:
		Global.PlayerType.JELLY:
			return 0
		Global.PlayerType.PIPPA:
			return 1
		Global.PlayerType.REMI:
			return 2
	
	return 0
	
func _vehicle_type_to_portrait_x_index(vehicle_type: Global.VehicleType) -> int:
	match vehicle_type:
		Global.VehicleType.SLED_HAMMER:
			return 3
		Global.VehicleType.SNOWTORCYCLE:
			return 4
	
	return 3

func _health_to_portrait_y_index(health: int) -> int:
	var count = get_health_count(health)
	
	if count > 8:
		return 0
	
	if count > 4:
		return 1
		
	if count > 0:
		return 2
		
	return 3

func get_health_count(health: int) -> int:
	if health == 100:
		return 12
	
	if health == 0:
		return 0
	
	var count = int(round(12.0 * health / 100))
	
	# Only show full or empty if actually full or empty
	if count == 12:
		return 11
		
	if count == 0:
		return 1
	
	return count
