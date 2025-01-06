extends BaseWeapon
class_name MachineGunWeapon

const COOLDOWN_DELTA = 0.2
var bullet_speed = 1000

func _init() -> void:
	super._init(Global.WeaponType.MACHINE_GUN, COOLDOWN_DELTA)

func _handle_projectiles(position: Vector2, direction: float) -> void:
	if owner_group != &"player":
		Global.audio.play_sfx(&"weapon/pistol", 5, true)
	else:
		Global.audio.play_sfx(&"weapon/pi", 6, true)
		
	var node = await Global.nodes.get_node("res://scenes/unit/projectile/bullet.tscn")
	node.add_to_group(owner_group)
	node.position = position
	node.direction = direction
	node.speed = bullet_speed
