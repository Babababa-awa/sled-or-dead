extends BaseLevel

@onready var sprite_jelly: AnimatedSprite2D = $AnimatedSprite2DJelly
@onready var sprite_remi: AnimatedSprite2D = $AnimatedSprite2DRemi
@onready var sprite_pippa: AnimatedSprite2D = $AnimatedSprite2DPippa
@onready var sprite_sled_hammer: AnimatedSprite2D = $AnimatedSprite2DSledHammer
@onready var sprite_snowtorcycle: AnimatedSprite2D = $AnimatedSprite2DSnowtorcycle
@onready var sprite_arrow: AnimatedSprite2D = $AnimatedSprite2DArrow
@onready var path_follow_camera: PathFollow2D = $Path2DCamera/PathFollow2DCamera


const SELECT_NONE: int = 0
const SELECT_DRIVER: int = 1
const SELECT_PASSENGER: int = 2
const SELECT_VEHICLE: int = 3
const SELECT_CAMERA: int = 4

var selectable_player_types: Array[Global.PlayerType]
var selectable_vehicle_types: Array[Global.VehicleType]
var current_select_state: int = SELECT_NONE
var current_player_type_index: int
var current_vehicle_type_index: int
var is_camera_moving: bool = false

const CAMERA_DELTA: float = 1.5
var _current_camera_delta: float = 0.0
var _camera_reverse: bool = false

const ARROW_DELTA: float = 1.0
const ARROW_LENGTH: float = 2.0
var _current_arrow_delta: float = 0.0
var _current_arrow_position: Vector2

func _init() -> void:
	super._init(&"start")
	Global.audio.play_sfx(&"ui/sled_or_dead")
	Global.audio.play_music(&"winter_sign")

func start_select() -> void:
	reset()
	#Global.game.show_ui(&"select")
	sprite_arrow.visible = true
	sprite_arrow.play(&"default")
	Global.audio.play_sfx(&"ui/choose_your_driver")
	#TODO: Playe choos your driver audio

func reset() -> void:
	Global.game.hide_ui(&"select")
	path_follow_camera.progress_ratio = 0.0
	sprite_arrow.visible = false
	current_player_type_index = 0
	current_vehicle_type_index = 0
	selectable_player_types = [
		Global.PlayerType.JELLY,
		Global.PlayerType.REMI,
		Global.PlayerType.PIPPA,
	]
	selectable_vehicle_types = [
		Global.VehicleType.SLED_HAMMER,
		Global.VehicleType.SNOWTORCYCLE,
	]
	current_select_state = SELECT_DRIVER
	
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	_update_arrow(delta)
	
	_update_camera(delta)
	
	if Input.is_action_just_pressed(&"select_confirm"):
		_confirm_select()
	elif Input.is_action_just_pressed(&"select_cancel"):
		_cancel_select()
	
func _update_arrow(delta: float) -> void:
	if current_select_state == SELECT_DRIVER or current_select_state == SELECT_PASSENGER:
		_update_player_arrow()
	elif current_select_state == SELECT_VEHICLE:
		_update_vehicle_arrow()
		
	_current_arrow_delta += delta
	if _current_arrow_delta > ARROW_DELTA:
		_current_arrow_delta = ARROW_DELTA
		
	var offset = Vector2(0, ARROW_LENGTH * sin((_current_arrow_delta / ARROW_DELTA) * PI * 2))
	sprite_arrow.position = _current_arrow_position + offset
	
	if _current_arrow_delta == ARROW_DELTA:
		_current_arrow_delta = 0.0
		
func _update_player_arrow() -> void:
	if Input.is_action_just_pressed(&"select_right"):
		Global.audio.play_sfx(&"ui/menu_select")
		if current_player_type_index >= selectable_player_types.size() - 1:
			current_player_type_index = 0
		else:
			current_player_type_index += 1	
	elif Input.is_action_just_pressed(&"select_left"):
		Global.audio.play_sfx(&"ui/menu_select")
		if current_player_type_index <= 0:
			current_player_type_index = selectable_player_types.size() - 1
		else:
			current_player_type_index -= 1
			
	_select_player()
	
func _update_vehicle_arrow() -> void:
	if Input.is_action_just_pressed(&"select_right"):
		Global.audio.play_sfx(&"ui/menu_select")
		if current_vehicle_type_index >= selectable_vehicle_types.size() - 1:
			current_vehicle_type_index = 0
		else:
			current_vehicle_type_index += 1	
	elif Input.is_action_just_pressed(&"select_left"):
		Global.audio.play_sfx(&"ui/menu_select")
		if current_vehicle_type_index <= 0:
			current_vehicle_type_index = selectable_vehicle_types.size() - 1
		else:
			current_vehicle_type_index -= 1
			
	
	_select_vehicle()
	
func _update_camera(delta: float) -> void:
	if current_select_state != SELECT_CAMERA:
		return
		
	_current_camera_delta += delta
		
	if _current_camera_delta > CAMERA_DELTA:
		_current_camera_delta = CAMERA_DELTA
		
	var eased_progress = 0.5 - 0.5 * cos((_current_camera_delta / CAMERA_DELTA) * PI)
	
	if _camera_reverse:
		eased_progress = 1.0 - eased_progress
	
	path_follow_camera.progress_ratio = eased_progress
	
	if _current_camera_delta == CAMERA_DELTA:
		sprite_arrow.visible = true
		if _camera_reverse:
			current_select_state = SELECT_PASSENGER
		else:
			current_select_state = SELECT_VEHICLE
			

func _select_player() -> void:	
	match selectable_player_types[current_player_type_index]:
		Global.PlayerType.JELLY:
			_select_jelly()
		Global.PlayerType.REMI:
			_select_remi()
		Global.PlayerType.PIPPA:
			_select_pippa()
	
func _select_jelly() -> void:
	_current_arrow_position = sprite_jelly.position - Vector2(0, 56)

func _select_remi() -> void:
	_current_arrow_position = sprite_remi.position - Vector2(0, 56)
	
func _select_pippa() -> void:
	_current_arrow_position = sprite_pippa.position - Vector2(0, 56)

func _select_vehicle() -> void:
	match selectable_vehicle_types[current_vehicle_type_index]:
		Global.VehicleType.SLED_HAMMER:
			_select_sled_hammer()
		Global.VehicleType.SNOWTORCYCLE:
			_select_snowtorcycle()
			
func _select_sled_hammer() -> void:
	_current_arrow_position = sprite_sled_hammer.position - Vector2(0, 80)

func _select_snowtorcycle() -> void:
	_current_arrow_position = sprite_snowtorcycle.position - Vector2(0, 92)
	
func _confirm_select() -> void:
	if current_select_state == SELECT_DRIVER:
		Global.audio.play_sfx(&"ui/menu_confirm")
		Global.audio.play_sfx(&"ui/choose_your_gunner")
		Global.driver_player_type = selectable_player_types[current_player_type_index]
		_play_player_select_sfx(Global.driver_player_type)
		selectable_player_types.remove_at(current_player_type_index)
		current_player_type_index = 0
		current_select_state = SELECT_PASSENGER
	elif current_select_state == SELECT_PASSENGER:
		Global.audio.play_sfx(&"ui/menu_confirm")
		Global.audio.play_sfx(&"ui/choose_your_sled")
		Global.passenger_player_type = selectable_player_types[current_player_type_index]
		_play_player_select_sfx(Global.passenger_player_type)
		selectable_player_types.remove_at(current_player_type_index)
		current_player_type_index = 0
		
		sprite_arrow.visible = false
		current_select_state = SELECT_CAMERA
		_current_camera_delta = 0.0
		_camera_reverse = false
	elif current_select_state == SELECT_VEHICLE:
		Global.audio.play_sfx(&"ui/menu_confirm")
		Global.vehicle_type = selectable_vehicle_types[current_vehicle_type_index]
		Global.game.start()

func _play_player_select_sfx(player_type: Global.PlayerType) -> void:
	match player_type:
		Global.PlayerType.JELLY:
			Global.audio.play_sfx(&"player/jelly_select", 3, true)
		Global.PlayerType.REMI:
			Global.audio.play_sfx(&"player/remi_select", 3, true)
		Global.PlayerType.PIPPA:
			Global.audio.play_sfx(&"player/pippa_select", 3, true)

func _cancel_select() -> void:
	reset()
	Global.game.show_ui(&"difficulty")

func start() -> void:
	super.start()
	
func stop() -> void:
	sprite_arrow.visible = false


func _on_area_2d_jelly_mouse_entered() -> void:
	if current_select_state != SELECT_DRIVER and current_select_state != SELECT_PASSENGER:
		return

	var index = selectable_player_types.find(Global.PlayerType.JELLY)
	
	if index != -1:
		current_player_type_index = index
		_select_player()

func _on_area_2d_remi_mouse_entered() -> void:
	if current_select_state != SELECT_DRIVER and current_select_state != SELECT_PASSENGER:
		return
	
	var index = selectable_player_types.find(Global.PlayerType.REMI)
	
	if index != -1:
		current_player_type_index = index
		_select_player()

func _on_area_2d_pippa_mouse_entered() -> void:
	if current_select_state != SELECT_DRIVER and current_select_state != SELECT_PASSENGER:
		return
		
	var index = selectable_player_types.find(Global.PlayerType.PIPPA)
	
	if index != -1:
		current_player_type_index = index
		_select_player()

func _on_area_2d_sled_hammer_mouse_entered() -> void:
	if current_select_state != SELECT_VEHICLE:
		return

	var index = selectable_vehicle_types.find(Global.VehicleType.SLED_HAMMER)
	
	if index != -1:
		current_vehicle_type_index = index
		_select_vehicle()

func _on_area_2d_snowtorcycle_mouse_entered() -> void:
	if current_select_state != SELECT_VEHICLE:
		return
	
	var index = selectable_vehicle_types.find(Global.VehicleType.SNOWTORCYCLE)
	
	if index != -1:
		current_vehicle_type_index = index
		_select_vehicle()

func _on_area_2d_jelly_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if current_select_state != SELECT_DRIVER and current_select_state != SELECT_PASSENGER:
		return
		
	if event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
		if selectable_player_types[current_player_type_index] == Global.PlayerType.JELLY:
			_confirm_select()

func _on_area_2d_remi_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if current_select_state != SELECT_DRIVER and current_select_state != SELECT_PASSENGER:
		return
		
	if event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
		if selectable_player_types[current_player_type_index] == Global.PlayerType.REMI:
			_confirm_select()

func _on_area_2d_pippa_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if current_select_state != SELECT_DRIVER and current_select_state != SELECT_PASSENGER:
		return
		
	if event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
		if selectable_player_types[current_player_type_index] == Global.PlayerType.PIPPA:
			_confirm_select()

func _on_area_2d_sled_hammer_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if current_select_state != SELECT_VEHICLE:
		return
	
	if event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
		if selectable_vehicle_types[current_vehicle_type_index] == Global.VehicleType.SLED_HAMMER:
			_confirm_select()

func _on_area_2d_snowtorcycle_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if current_select_state != SELECT_VEHICLE:
		return
		
	if event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
		if selectable_vehicle_types[current_vehicle_type_index] == Global.VehicleType.SNOWTORCYCLE:
			_confirm_select()
	
