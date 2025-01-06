extends KillableUnit
class_name VehicleUnit

var vehicle_type: Global.VehicleType = Global.VehicleType.NONE

var is_in_kill_area: bool = false
var is_in_fall_area: bool = false
var is_in_fall_front_area: bool = false
var is_in_fall_back_area: bool = false
var is_in_ice_area: bool = false
var is_in_jump_area: bool = false
var is_in_win_area: bool = false

# Win
const WIN_COOLDOWN_DELTA = 1.0
var win_cooldown: CooldownTimer

# Boost
var boost_activate_cooldown_delta: float = 5.25
var boost_speed_cooldown_delta: float = 3.5
var boost_cooldown: CooldownTimer
var is_boosting: bool = false
var boost: float = 100.0
var boost_mode: Global.BoostMode = Global.BoostMode.CONSUME
var boost_drain_delta: float = 5.0
var boost_speed: float = 200.0
var boost_turn_speed: float = 180.0
var max_boost_turn_angle: float = 60


# Jumps
const MAX_JUMP_HEIGHT: float = 100.0
const MAX_JUMP_TRAVEL: float = 96.0 + 64.0
const JUMP_DECAY_DELTA: float = 0.5
var jump_height: float = 0.0
var jump_travel: float = 0.0

# Fall
var FALL_COOLDOWN_DELTA = 0.5
var fall_cooldown: CooldownTimer

# Ice
var ICE_COOLDOWN_DELTA = 0.125
var ice_cooldown: CooldownTimer
var ice_turn_speed: float = 580.0
var ice_direction: int = 0

# Swap
var SWAP_COOLDOWN_DELTA = 1.5
var swap_cooldown: CooldownTimer

# Speed
var speed: float = 0.0
var min_speed: float = 150.0
var max_speed: float = 450.0
var acceleration: float = 200.0
var deceleration: float = 100.0
var friction: float = 50.0

# Direction
var direction: float = 0.0
var turn_speed: float = 135.0
var max_turn_angle: float = 50.0


func _init(
	alias_: StringName,
	vehicle_type_: Global.VehicleType = Global.VehicleType.NONE
) -> void:
	death_cooldown_delta = 1.0
	
	projectile_bullet_damage_amount = 5
	projectile_explosion_damage_amount = 20
	projectile_rocket_damage_amount = 15
	projectile_none_damage_amount = 10
	
	independant_projectile_explosion_damage = true
	
	super._init(alias_, Global.UnitType.VEHICLE)
	
	vehicle_type = vehicle_type_

	win_cooldown = CooldownTimer.new(WIN_COOLDOWN_DELTA)

	fall_cooldown = CooldownTimer.new(FALL_COOLDOWN_DELTA)
	ice_cooldown = CooldownTimer.new(ICE_COOLDOWN_DELTA, true)

	boost_cooldown = CooldownTimer.new(boost_activate_cooldown_delta)
	boost_cooldown.add_step(&"boost", boost_speed_cooldown_delta)
	
	swap_cooldown = CooldownTimer.new(SWAP_COOLDOWN_DELTA, true)

func _ready() -> void:
	super._ready()

	%Area2DDamage.connect(&"body_entered", _on_damage_body_entered)
	%Area2DDamage.connect(&"body_exited", _on_damage_body_exited)

	%Area2DKill.connect(&"body_entered", _on_kill_body_entered)
	%Area2DKill.connect(&"body_exited", _on_kill_body_exited)

	%Area2DFallFront.connect(&"body_entered", _on_fall_front_body_entered)
	%Area2DFallFront.connect(&"body_exited", _on_fall_front_body_exited)

	%Area2DFallBack.connect(&"body_entered", _on_fall_back_body_entered)
	%Area2DFallBack.connect(&"body_exited", _on_fall_back_body_exited)

	%Area2DJump.connect(&"body_entered", _on_jump_body_entered)
	%Area2DJump.connect(&"body_exited", _on_jump_body_exited)

	%Area2DIce.connect(&"body_entered", _on_ice_body_entered)
	%Area2DIce.connect(&"body_exited", _on_ice_body_exited)

	%Area2DWin.connect(&"body_entered", _on_win_body_entered)
	%Area2DWin.connect(&"body_exited", _on_win_body_exited)

# Damage area
func _on_damage_body_entered(_body: Node2D) -> void:
	is_in_damage_area = true

func _on_damage_body_exited(_body: Node2D) -> void:
	is_in_damage_area = false

# Kill area
func _on_kill_body_entered(_body: Node2D) -> void:
	is_in_kill_area = true

func _on_kill_body_exited(_body: Node2D) -> void:
	is_in_kill_area = false

# Fall area
func _on_fall_front_body_entered(_body: Node2D) -> void:
	is_in_fall_front_area = true
	is_in_fall_area = is_in_fall_back_area

func _on_fall_front_body_exited(_body: Node2D) -> void:
	is_in_fall_front_area = false
	is_in_fall_area = false

func _on_fall_back_body_entered(_body: Node2D) -> void:
	is_in_fall_back_area = true
	is_in_fall_area = is_in_fall_front_area

func _on_fall_back_body_exited(_body: Node2D) -> void:
	is_in_fall_back_area = false
	is_in_fall_area = false

# Jump area
func _on_jump_body_entered(_body: Node2D) -> void:
	is_in_jump_area = true

func _on_jump_body_exited(_body: Node2D) -> void:
	is_in_jump_area = false

# Jump area
func _on_ice_body_entered(_body: Node2D) -> void:
	is_in_ice_area = true

func _on_ice_body_exited(_body: Node2D) -> void:
	is_in_ice_area = false

# Win area
func _on_win_body_entered(_body: Node2D) -> void:
	is_in_win_area = true

func _on_win_body_exited(_body: Node2D) -> void:
	is_in_win_area = false

func reset() -> void:
	super.reset()

	is_in_kill_area = false
	is_in_fall_area = false
	is_in_fall_front_area = false
	is_in_fall_back_area = false
	is_in_ice_area = false
	is_in_jump_area = false
	is_in_win_area = false

	boost = 100
	is_boosting = false

	win_cooldown.reset()
	fall_cooldown.reset()
	ice_cooldown.reset()
	boost_cooldown.reset()
	swap_cooldown.reset()

func _process(delta: float) -> void:
	super._process(delta)
	
	if not _can_process():
		return
	
	_handle_win(delta)

	_handle_fall(delta)

	_handle_jump(delta)
	
	swap_cooldown.process(delta)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if not _can_process():
		return

	_handle_boost(delta)

	_handle_ice(delta)

	_handle_speed(delta)

	_handle_direction(delta)

	_handle_movement(delta)

	move_and_slide()

func _handle_speed(delta: float) -> void:
	if health == 0:
		return

	# Slow down to zero.
	if not is_enabled:
		speed = lerp(speed, 0.0, delta)
		if round(speed) == 0.0:
			speed = 0.0
		return

	var vehicle_up: bool = Input.is_action_pressed(&"vehicle_up")
	var vehicle_down: bool = Input.is_action_pressed(&"vehicle_down")

	# Can't increase speed in air
	var decrease_only = (not is_in_jump_area and jump_height > 0.0 and not is_boosting)

	if is_boosting:
		if speed > max_speed:
			return
		else: # Only allow speeding up if boosting
			vehicle_down = false
			
	if speed > max_speed:
		speed = lerp(speed, max_speed, delta * 3)
		if round(speed) == max_speed:
			speed = max_speed
	elif vehicle_up and not vehicle_down and not decrease_only:
		speed = clamp(speed + acceleration * delta, min_speed, max_speed)
	elif vehicle_down and not vehicle_up:
		speed = clamp(speed - deceleration * delta, min_speed, max_speed)
	else:
		speed = clamp(speed - friction * delta, min_speed, max_speed)

func _handle_direction(delta: float) -> void:
	if health == 0:
		return

	# Can't steer in air
	# While realistic, it's less fun
	#if not is_in_jump_area and jump_height > 0.0:
		#return

	var vehicle_left: bool = Input.is_action_pressed(&"vehicle_left")
	var vehicle_right: bool = Input.is_action_pressed(&"vehicle_right")

	var current_turn_angle = max_turn_angle
	var current_turn_speed = turn_speed

	if is_boosting:
		current_turn_speed = boost_turn_speed
		current_turn_angle = max_boost_turn_angle

	if ice_cooldown.is_active:
		current_turn_speed = ice_turn_speed
		# When ice is on, reverse direction and ensure its held until timer is done
		if ice_direction == 1:
			vehicle_left = true
			vehicle_right = false
		elif ice_direction == -1:
			vehicle_left = false
			vehicle_right = true

	current_turn_speed *= delta

	if vehicle_left and not vehicle_right:
		if direction < -current_turn_angle:
			direction = lerp(direction, -current_turn_angle, delta * 2)
			if round(direction) == -current_turn_angle:
				direction = -current_turn_angle
		else:
			direction = clamp(direction - current_turn_speed, -current_turn_angle, current_turn_angle)
	elif vehicle_right and not vehicle_left:
		if direction > current_turn_angle:
			direction = lerp(direction, current_turn_angle, delta * 2)
			if round(direction) == current_turn_angle:
				direction = current_turn_angle
		else:
			direction = clamp(direction + current_turn_speed, -current_turn_angle, current_turn_angle)
	else:
		direction = lerp(direction, 0.0, delta * 2)

func _handle_movement(_delta: float) -> void:
	var current_speed = speed
	
	if (boost_mode == Global.BoostMode.DRAIN and is_boosting):
		current_speed += boost_speed
	
	if health == 0:
		velocity = Vector2.ZERO
	else:
		velocity = Vector2(0, -current_speed).rotated(deg_to_rad(direction))
	rotation = deg_to_rad(direction)

func _handle_boost(delta: float) -> void:
	if health == 0 or not is_enabled:
		is_boosting = false
		return
	
	if boost_mode == Global.BoostMode.CONSUME:
		_handle_boost_consume(delta)
	else:
		_handle_boost_drain(delta)
		
func _handle_boost_consume(delta: float) -> void:
	var vehicle_boost: bool = Input.is_action_just_pressed(&"vehicle_boost")

	boost_cooldown.process(delta)

	if vehicle_boost and boost_cooldown.start():
		speed += boost_speed
		is_boosting = true
		_boost_start()
	elif boost_cooldown.is_on_step("boost"):
		boost = 0
		is_boosting = false
		_boost_stop()
	elif boost_cooldown.is_complete:
		boost = 100
		boost_cooldown.complete()
	elif is_boosting:
		boost = 100 - (boost_cooldown.current_delta / boost_speed_cooldown_delta * 100)

func _handle_boost_drain(delta: float) -> void:
	var vehicle_boost: bool = Input.is_action_pressed(&"vehicle_boost")
	var vehicle_boost_stop: bool = Input.is_action_just_released(&"vehicle_boost")

	boost_cooldown.process(delta)
	
	if boost == 0.0:
		vehicle_boost = false
		vehicle_boost_stop = true
	
	if vehicle_boost:
		if not is_boosting:
			is_boosting = true
			_boost_start()
			boost_cooldown.reset()
			
		var amount = 100 / boost_drain_delta * delta
		
		boost -= amount
		if boost < 0.0:
			boost = 0.0
	elif vehicle_boost_stop and is_boosting:
		is_boosting = false
		_boost_stop()
		boost_cooldown.reset()
		boost_cooldown.start()
	elif boost_cooldown.is_complete:
		boost = 100
		boost_cooldown.complete()
		
			
func _boost_start() -> void:
	pass

func _boost_stop() -> void:
	pass

func _handle_jump(delta: float) -> void:
	if is_in_jump_area:
		# Calculate jump height based distance traveled on jump ramp
		jump_travel += (velocity.length() * delta)
		jump_travel = min(jump_travel, MAX_JUMP_TRAVEL)
		jump_height = clamp((jump_travel / MAX_JUMP_TRAVEL) * MAX_JUMP_HEIGHT, 0.0, MAX_JUMP_HEIGHT)
	elif jump_height > 0.0:
		jump_height = max(0.0, jump_height - (MAX_JUMP_HEIGHT / JUMP_DECAY_DELTA) * delta)

	if jump_height > 0.0:
		var scale_value = jump_height / MAX_JUMP_HEIGHT
		scale_value = 1.0 + scale_value * scale_value * 0.25
		scale = Vector2(scale_value, scale_value)
	elif jump_travel > 0.0:
		jump_travel = 0.0
		scale = Vector2(1.0, 1.0)

func _handle_fall(delta: float) -> void:
	if health == 0:
		return

	fall_cooldown.process(delta)

	if is_in_fall_area and jump_height == 0.0:
		if fall_cooldown.start():
			return
		else:
			var scale_value = fall_cooldown.current_delta / FALL_COOLDOWN_DELTA
			scale_value = 1.0 - scale_value * 0.25
			scale = Vector2(scale_value, scale_value)

			if fall_cooldown.is_complete:
				health = 0
				fall_cooldown.complete()
	elif fall_cooldown.is_active:
		health = 0
		fall_cooldown.complete()

func _handle_ice(delta: float) -> void:
	if health == 0 or not is_enabled:
		return

	ice_cooldown.process(delta)

	if not is_in_ice_area:
		ice_cooldown.complete()
		return

	var vehicle_left: bool = Input.is_action_pressed(&"vehicle_left")
	var vehicle_right: bool = Input.is_action_pressed(&"vehicle_right")

	if vehicle_left and not vehicle_right and ice_cooldown.start():
		ice_direction = -1
	elif vehicle_right and not vehicle_left and ice_cooldown.start():
		ice_direction = 1

func _handle_win(delta: float) -> void:
	if not is_in_win_area:
		return

	win_cooldown.process(delta)

	if not Global.game.is_win and win_cooldown.start():
		is_enabled = false
	elif win_cooldown.is_complete:
		win_cooldown.complete()
		Global.game.is_win = true

func _start_death() -> void:
	Global.driver.health = 0
	Global.passenger.health = 0
	
func _complete_death() -> void:
	Global.game.is_lose = true
	
func _deal_damage(amount: int) -> void:
	super._deal_damage(amount)
	
	if health != 0:
		Global.audio.play_sfx(&"vehicle/hit", 4, true)

func _is_killed() -> bool:
	if is_in_kill_area and jump_height == 0.0:
		return true
		
	return super._is_killed()

func set_driver(player: PlayerUnit) -> void:
	add_child(player)
	player.set_player_mode(Global.PlayerMode.DRIVER)
	player.position = _get_driver_position()

func set_passenger(player: PlayerUnit) -> void:
	add_child(player)
	player.set_player_mode(Global.PlayerMode.PASSENGER)
	player.position = _get_passenger_position()

func swap_players() -> void:
	if not Global.passenger or Global.passenger.health == 0:
		return
		
	if not swap_cooldown.start():
		return
		
	var driver = Global.driver
	Global.driver = Global.passenger
	Global.driver.set_player_mode(Global.PlayerMode.DRIVER)
	Global.driver.position = _get_driver_position()
	
	Global.passenger = driver	
	Global.passenger.set_player_mode(Global.PlayerMode.PASSENGER)
	Global.passenger.position = _get_passenger_position()
	
	if Global.active_player == Global.PlayerMode.PASSENGER:
		Global.cursor.weapon_type = Global.passenger.primary_weapon.weapon_type
	else:
		Global.cursor.weapon_type = Global.driver.secondary_weapon.weapon_type

func _get_driver_position() -> Vector2:
	return Vector2(0, -16)

func _get_passenger_position() -> Vector2:
	return Vector2(0, 16)
