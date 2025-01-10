extends BaseGame
class_name Game

var current_vehicle: VehicleUnit = null
var current_driver: PlayerUnit = null
var current_passenger: PlayerUnit = null
var current_cursor: WeaponCursor = null

var snowing: bool = true
var is_outside: bool = true

func start_select() -> void:
	hide_uis(Global.UIType.MENU)
	current_level.start_select()

func reset_game() -> void:
	reset_cursor()
	reset_players()
	reset_vehicle()
	super.reset_game()
	
func reset_vehicle() -> void:
	if current_vehicle != null:		
		# Camera could be a child of vehicle
		if Global.camera and current_vehicle.is_ancestor_of(Global.camera):
			current_vehicle.remove_child(Global.camera)
			Global.camera.queue_free()
			Global.camera = null
		
		$Level.remove_child(current_vehicle)
		current_vehicle.queue_free()
		current_vehicle = null
		Global.vehicle = null

func reset_players() -> void:
	reset_driver()
	reset_passenger()
	
func reset_driver() -> void:
	if current_driver != null:
		if current_vehicle:
			current_vehicle.remove_child(current_driver)
		current_driver.queue_free()
		current_driver = null
		Global.driver = null

	
func reset_passenger() -> void:
	if current_passenger != null:
		if current_vehicle:
			current_vehicle.remove_child(current_passenger)
		current_passenger.queue_free()
		current_passenger = null
		Global.passenger = null
	
func reset_cursor() -> void:
	if current_cursor != null:
		$Level.remove_child(current_cursor)
		current_cursor.queue_free()
		current_cursor = null
		Global.cursor = null
	

func change_vehicle(vehicle_alias: StringName) -> void:
	if current_vehicle and current_vehicle.alias == vehicle_alias:
		current_vehicle.reset()
		return
		
	reset_vehicle()
	
	var vehicle_path = "res://scenes/unit/vehicle/" + vehicle_alias + ".tscn"
	
	var vehicle = await load(vehicle_path).instantiate()
	
	var camera = Camera2D.new()
	camera.zoom.x = 1.75
	camera.zoom.y = 1.75
	camera.position.y = -8 * Global.TILE_SIZE
	camera.limit_smoothed = true
	camera.position_smoothing_enabled = true
	
	Global.camera = camera
	
	vehicle.add_child(camera)

	$Level.add_child(vehicle)
	current_vehicle = vehicle
	Global.vehicle = vehicle
	
	if current_driver != null:
		vehicle.set_driver(current_driver)
	
	if current_passenger != null:
		vehicle.set_passenge(current_passenger)
		
	
	vehicle.start()

func set_vehicle_position(x: int, y: int) -> void:
	assert(current_vehicle != null, "Vehicle is not loaded.")
	Global.camera.position_smoothing_enabled = false
	Global.vehicle.position = Vector2(x * Global.TILE_SIZE, y * Global.TILE_SIZE)
	await get_tree().process_frame
	Global.camera.position_smoothing_enabled = true

func change_driver(player_alias: StringName) -> void:
	if current_driver and current_driver.alias == player_alias:
		current_driver.reset()
		return
		
	reset_driver()
	
	var player_path = "res://scenes/unit/player/" + player_alias + ".tscn"
	
	var player = await load(player_path).instantiate()

	current_driver = player
	Global.driver = player
	
	if current_vehicle != null:
		current_vehicle.set_driver(player)
	
	player.start()
	
func change_passenger(player_alias: StringName) -> void:
	if current_passenger and current_passenger.alias == player_alias:
		current_passenger.reset()
		return
		
	reset_passenger()
	
	var player_path = "res://scenes/unit/player/" + player_alias + ".tscn"
	
	var player = await load(player_path).instantiate()

	current_passenger = player
	Global.passenger = player
	
	if current_vehicle != null:
		current_vehicle.set_passenger(player)
	
	player.start()
	
func change_cursor(cursor_alias: StringName) -> void:
	if current_cursor and current_cursor.alias == cursor_alias:
		current_cursor.reset()
		return
		
	reset_cursor()
	
	var cursor_path = "res://scenes/cursor/" + cursor_alias + ".tscn"
	
	var cursor = await load(cursor_path).instantiate()

	current_cursor = cursor
	Global.cursor = cursor
	
	$Level.add_child(cursor)
	
	cursor.start()

func _process(delta):
	super._process(delta)
	
	if current_level != null and current_level.alias != Global.MENU_LEVEL:
		if Global.vehicle != null and Input.is_action_just_pressed("player_position_swap"):
			Global.vehicle.swap_players()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

func _can_pause() -> bool:
	if not super._can_pause():
		return false
	
	if is_ui_visible(&"win"):
		return false
	
	if is_ui_visible(&"lose"):
		return false
		
	return true
	
