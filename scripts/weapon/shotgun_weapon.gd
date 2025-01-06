extends BaseWeapon
class_name ShotgunWeapon

const COOLDOWN_DELTA = 0.70
var bullet_speed = 1000

func _init() -> void:
	super._init(Global.WeaponType.SHOTGUN, COOLDOWN_DELTA)

func _handle_projectiles(position: Vector2, direction: float) -> void:
	Global.audio.play_sfx(&"weapon/shotgun", 3, true)
	
	var node = await Global.nodes.get_node("res://scenes/unit/projectile/bullet.tscn")
	node.add_to_group(owner_group)
	node.position = position
	node.direction = direction
	node.speed = bullet_speed

	node = await Global.nodes.get_node("res://scenes/unit/projectile/bullet.tscn")
	node.add_to_group(owner_group)
	node.position = position
	node.direction = direction + 2.5
	node.speed = bullet_speed

	node = await Global.nodes.get_node("res://scenes/unit/projectile/bullet.tscn")
	node.add_to_group(owner_group)
	node.position = position
	node.direction = direction - 2.5
	node.speed = bullet_speed

	node = await Global.nodes.get_node("res://scenes/unit/projectile/bullet.tscn")
	node.add_to_group(owner_group)
	node.position = position
	node.direction = direction + 5.0
	node.speed = bullet_speed

	node = await Global.nodes.get_node("res://scenes/unit/projectile/bullet.tscn")
	node.add_to_group(owner_group)
	node.position = position
	node.direction = direction - 5.0
	node.speed = bullet_speed
