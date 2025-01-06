extends VehicleUnit

func _init() -> void:
	super._init(&"sled_hammer", Global.VehicleType.SLED_HAMMER)
	
	min_speed = 75.0
	max_speed = 400.0
	acceleration = 150.0
	deceleration = 150.0
	turn_speed = 90.0
	max_turn_angle = 52.0
	
	boost_activate_cooldown_delta = 6.0
	boost_mode = Global.BoostMode.DRAIN
	boost_speed = 250.0
	boost_turn_speed = 270.0
	max_boost_turn_angle = 62.0
	
	durability = 1.25

func _get_driver_position() -> Vector2:
	return Vector2(0, -15)
	
func _get_passenger_position() -> Vector2:
	return Vector2(0, 11)

func _boost_start() -> void:
	super._boost_start()
	%BoostEffect.play()

func _boost_stop() -> void:
	super._boost_stop()
	%BoostEffect.stop()

func _start_death() -> void:
	super._start_death()
	%VehicleExplosionEffect.play()
	Global.audio.play_sfx(&"vehicle/explosion_sled_hammer")
