extends BaseWeapon
class_name RocketLauncherWeapon

const TARGET_DELTA: float = Global.ROCKET_LAUNCHER_LOCKON_DELTA
const COOLDOWN_DELTA: float = 1.50
var rocket_speed: float = 650
var rocket_turn_speed: float = 360.0

func _init() -> void:
	super._init(Global.WeaponType.ROCKET_LAUNCHER, COOLDOWN_DELTA)

func _handle_projectiles(position: Vector2, direction: float) -> void:
	Global.audio.play_sfx(&"weapon/rocket", 3, true)
	
	var node = await Global.nodes.get_node("res://scenes/unit/projectile/rocket.tscn")
	node.add_to_group(owner_group)
	node.position = position
	node.direction = direction
	node.speed = rocket_speed
	node.turn_speed = rocket_turn_speed
	node.target = _get_target()

func _get_target() -> BaseUnit:
	if owner_group == &"player":
		return _get_player_target()
	elif owner_group == &"enemy":
		return _get_enemy_target()
		
	return null

func _get_player_target() -> BaseUnit:
	if Global.cursor.current_target == null:
		return null
	
	if Global.cursor.current_target_time < TARGET_DELTA:
		return null
		
	var node = Global.cursor.current_target
	
	if not _is_valid_target(node):
		return null
		
	return node

func _get_enemy_target() -> BaseUnit:
	return Global.vehicle
	
func _is_valid_target(node: BaseUnit) -> bool:
	if node is ProjectileUnit:
		if node.projectile_type != Global.ProjectileType.ROCKET:
			return false
			
	return true
