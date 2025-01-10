extends VehicleUnit

func _init() -> void:
	super._init(&"snowtorcycle", Global.VehicleType.SNOWTORCYCLE)

	min_speed = 100
	max_speed = 450.0
	acceleration = 200.0
	deceleration = 100.0
	turn_speed = 135.0
	max_turn_angle = 50.0

	boost_activate_cooldown_delta = 6.0
	boost_mode = Global.BoostMode.CONSUME
	boost_speed = 200.0
	boost_turn_speed = 180.0
	max_boost_turn_angle = 60.0

	durability = 1.0

func _get_driver_position() -> Vector2:
	return Vector2(0, -23)

func _get_passenger_position() -> Vector2:
	return Vector2(0, 5)

func _boost_start() -> void:
	super._boost_start()
	%BoostEffect1.play()
	%BoostEffect2.play()

func _boost_stop() -> void:
	super._boost_stop()
	%BoostEffect1.stop()
	%BoostEffect2.stop()

func _start_death() -> void:
	super._start_death()
	%VehicleExplosionEffect.play()
	Global.audio.play_sfx(&"vehicle/explosion_snowtorcycle")
