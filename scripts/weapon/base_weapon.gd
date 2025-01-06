class_name BaseWeapon

var weapon_type: Global.WeaponType
var projectile_type: Global.ProjectileType
var cooldown_delta: float
var cooldown: CooldownTimer

var owner_group: StringName = &"neutral"

func _init(
	weapon_type_: Global.WeaponType, 
	cooldown_delta_: float
) -> void:
	weapon_type = weapon_type_
	projectile_type = Global.get_projectile_type_from_weapon_type(weapon_type)
	cooldown_delta = cooldown_delta_
	cooldown = CooldownTimer.new(cooldown_delta, true)

func reset() -> void:
	cooldown.reset()
	
func process(delta: float) -> void:
	cooldown.process(delta)

func attack(from_position: Vector2, to_position: Vector2) -> void:
	if not cooldown.start():
		return
	
	var direction = rad_to_deg(from_position.angle_to_point(to_position)) + 90
	_handle_projectiles(from_position, direction)

func _handle_projectiles(_position: Vector2, _direction: float) -> void:
	pass
