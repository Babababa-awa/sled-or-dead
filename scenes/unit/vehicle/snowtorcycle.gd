extends VehicleUnit

func _init() -> void:
	super._init(&"snowtorcyle", Global.VehicleType.SNOWTORCYCLE)
	
	min_speed = 100

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
	Global.audio.play_sfx(&"vehicle/explosion_snowtorcyle")
