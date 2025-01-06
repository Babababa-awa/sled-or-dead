extends "res://scenes/unit/object/exploding_barrel.gd"

func _init() -> void:
	is_super = true
	
	super._init()
	
	projectile_bullet_damage_amount = 99
	projectile_explosion_damage_amount = 99
	projectile_rocket_damage_amount = 100
	projectile_none_damage_amount = 100
