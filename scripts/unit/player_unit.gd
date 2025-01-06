extends KillableUnit 
class_name PlayerUnit

var player_type: Global.PlayerType
var player_mode: Global.PlayerMode = Global.PlayerMode.NONE
var player_movement: Global.PlayerMovement = Global.PlayerMovement.IDLE

var primary_weapon: BaseWeapon
var secondary_weapon: BaseWeapon
var is_cursor_change: bool = false

func _init(
	alias_: StringName, 
	player_type_: Global.PlayerType = Global.PlayerType.NONE,
) -> void:
	super._init(alias_, Global.UnitType.PLAYER)
	player_type = player_type_

func _ready() -> void:
	super._ready()

func reset() -> void:
	super.reset()

func _process(delta: float) -> void:
	super._process(delta)
	
	if not _can_process():
		return
		
	if player_mode == Global.PlayerMode.PASSENGER:
		_handle_passenger(delta)
	elif player_mode == Global.PlayerMode.DRIVER:
		_handle_driver(delta)

func _handle_passenger(delta: float) -> void:
	if is_cursor_change:
		if Input.is_action_just_pressed("passenger_shoot"):
			is_cursor_change = false
		return
		
	if primary_weapon:
		primary_weapon.process(delta)
		if Input.is_action_pressed("passenger_shoot") and not Input.is_action_pressed("driver_shoot"):
			if Global.active_player != Global.PlayerMode.PASSENGER:
				Global.active_player = Global.PlayerMode.PASSENGER
				Global.cursor.weapon_type = primary_weapon.weapon_type
				is_cursor_change = true
			else:
				primary_weapon.attack(global_position, Global.cursor.global_position)
	elif secondary_weapon:
		secondary_weapon.process(delta)
		if Input.is_action_pressed("passenger_shoot") and not Input.is_action_pressed("driver_shoot"):
			if Global.active_player != Global.PlayerMode.PASSENGER:
				Global.active_player = Global.PlayerMode.PASSENGER
				Global.cursor.weapon_type = secondary_weapon.weapon_type
				is_cursor_change = true
			else:
				secondary_weapon.attack(global_position, Global.cursor.global_position)

func _handle_driver(delta: float) -> void:
	if is_cursor_change:
		if Input.is_action_just_pressed("driver_shoot"):
			is_cursor_change = false
		return
		
	if secondary_weapon:
		secondary_weapon.process(delta)
		if Input.is_action_pressed("driver_shoot") and not Input.is_action_pressed("passenger_shoot"):
			if Global.active_player != Global.PlayerMode.DRIVER:
				Global.cursor.weapon_type = secondary_weapon.weapon_type
				Global.active_player = Global.PlayerMode.DRIVER
				is_cursor_change = true
			else:
				secondary_weapon.attack(global_position, Global.cursor.global_position)

func _start_death() -> void:
	pass
	
func _complete_death() -> void:
	if alias == &"pippa":
		Global.audio.play_sfx(&"player/" + alias + &"_die", 4, true)
	else:
		Global.audio.play_sfx(&"player/" + alias + &"_die", 3, true)
	
func _deal_damage(amount: int) -> void:
	super._deal_damage(amount)
	
	if health != 0:
		Global.audio.play_sfx(&"player/" + alias + &"_hit", 3, true)
	
func set_player_mode(player_mode_: Global.PlayerMode) -> void:
	player_mode = player_mode_

func _can_process() -> bool:
	if not super._can_process():
		return false
		
	if Global.game.is_win or Global.game.is_lose:
		return false
		
	return true
	
