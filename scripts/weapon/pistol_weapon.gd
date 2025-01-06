extends BaseWeapon
class_name PistolWeapon

const COOLDOWN_DELTA = 0.5
var bullet_speed = 750

func _init() -> void:
	super._init(Global.WeaponType.PISTOL, COOLDOWN_DELTA)

func _handle_projectiles(position: Vector2, direction: float) -> void:
	Global.audio.play_sfx(&"weapon/pistol", 5, true)
	
	var node = await Global.nodes.get_node("res://scenes/unit/projectile/bullet.tscn")
	node.add_to_group(owner_group)
	node.position = position
	node.direction = direction
	node.speed = bullet_speed
