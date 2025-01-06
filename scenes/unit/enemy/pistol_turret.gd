extends "res://scenes/unit/enemy/component/turret.gd"

func reset_weapon() -> void:
	super.reset_weapon()
	
	primary_weapon.bullet_speed = 400
	primary_weapon.cooldown.cooldown_delta = 1.0
