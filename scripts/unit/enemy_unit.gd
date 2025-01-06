extends KillableUnit
class_name EnemyUnit

var primary_weapon: BaseWeapon
var max_attack_distance: int = 25
var bullet_leading_distance: int = 1

func _process(delta: float) -> void:
	super._process(delta)
		
	if not _can_process():
		return
	
	primary_weapon.process(delta)
		
	if _can_attack():
		primary_weapon.attack(position, _get_attack_position())

func _get_attack_position() -> Vector2:
	var attack_position = Global.vehicle.position
	
	# Hack for now to shoot infront
	#if primary_weapon.projectile_type == Global.ProjectileType.BULLET:
		#if Global.vehicle.position.distance_to(self.position) > 5 * Global.TILE_SIZE:
		#attack_position.y -= bullet_leading_distance * Global.TILE_SIZE
	
	return attack_position

func _can_attack() -> bool:
	if primary_weapon == null:
		return false
		
	if Global.vehicle == null:
		return false
		
	var distance = position.distance_to(Global.vehicle.position)
	if distance > max_attack_distance * Global.TILE_SIZE:
		return false
		
	return true
	
func _can_process() -> bool:
	if not super._can_process():
		return false
		
	if Global.game.is_win or Global.game.is_lose:
		return false
		
	return true
