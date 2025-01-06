extends "res://scenes/unit/enemy/component/turret.gd"

func reset_weapon() -> void:
	super.reset_weapon()

	primary_weapon.rocket_speed = 450
	primary_weapon.cooldown.cooldown_delta = 3
