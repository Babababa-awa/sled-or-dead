extends WeaponCursor

@onready var sprite_cursor: AnimatedSprite2D = $AnimatedSprite2DCursor

func _process(delta: float) -> void:
	super._process(delta)
	
	_handle_lockon()
		
func _handle_lockon() -> void:
	var default_name
	var lockon_name
	var delta
	
	match weapon_type:
		Global.WeaponType.PISTOL:
			default_name = &"pistol"
			lockon_name = &"pistol_lockon"
			delta = Global.PISTOL_LOCKON_DELTA
		Global.WeaponType.MACHINE_GUN:
			default_name = &"machine_gun"
			lockon_name = &"machine_gun_lockon"
			delta = Global.MACHINE_GUN_LOCKON_DELTA
		Global.WeaponType.SHOTGUN:
			default_name = &"shotgun"
			lockon_name = &"shotgun_lockon"
			delta = Global.SHOTGUN_LOCKON_DELTA
		Global.WeaponType.ROCKET_LAUNCHER:
			default_name = &"rocket_launcher"
			lockon_name = &"rocket_launcher_lockon"
			delta = Global.ROCKET_LAUNCHER_LOCKON_DELTA
				
	if current_target_time < delta:
		if sprite_cursor.animation != default_name:
			sprite_cursor.play(default_name)
		return
	
	if sprite_cursor.animation != lockon_name:
		sprite_cursor.play(lockon_name)

func _update_cursor() -> void:
	match weapon_type:
		Global.WeaponType.PISTOL:
			sprite_cursor.play("pistol")
		Global.WeaponType.MACHINE_GUN:
			sprite_cursor.play("machine_gun")
		Global.WeaponType.SHOTGUN:
			sprite_cursor.play("shotgun")
		Global.WeaponType.ROCKET_LAUNCHER:
			sprite_cursor.play("rocket_launcher")
