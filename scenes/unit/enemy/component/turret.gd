extends EnemyUnit

@onready var sprite: AnimatedSprite2D = $TurretSprite

@export var weapon_type: Global.WeaponType = Global.WeaponType.PISTOL

var is_focused: bool = false

func _init() -> void:
	super._init(&"turret", Global.UnitType.ENEMY)
	
	projectile_bullet_damage_amount = 45
	projectile_explosion_damage_amount = 5
	projectile_rocket_damage_amount = 99
	projectile_none_damage_amount = 100
	independant_projectile_bullet_damage = true
	independant_projectile_explosion_damage = true
	independant_projectile_rocket_damage = true


func reset() -> void:
	super.reset()

	is_focused = false

	sprite.play(&"default")

func reset_weapon() -> void:
	primary_weapon = Global.get_weapon(weapon_type)
	primary_weapon.owner_group = &"enemy"

func _ready() -> void:
	super._ready()
	
	reset_weapon()
	
#func _handle_damage(delta: float) -> void:
	#super._handle_damage(delta)
	#
	#if health == 0 or not is_enabled:
		#return
		
	#if health != 100 and not is_focused:
		#is_focused = true
		#_update_focus()
		
func _can_attack() -> bool:
	if not super._can_attack():
		return false
		
	if not is_focused:
		return false
		
	return true

func _update_default() -> void:
	if sprite == null:
		return
		
	if health == 100:
		sprite.play(&"default")
	elif health >= 50:
		sprite.play(&"default_1")
	elif health > 0:
		sprite.play(&"default_2")
	else:
		sprite.play(&"empty")

func _update_focus() -> void:
	if sprite == null:
		return
		
	if health == 100:
		sprite.play(&"focus")
	elif health >= 50:
		sprite.play(&"focus_1")
	elif health > 0:
		sprite.play(&"focus_2")
	else:
		sprite.play(&"empty")

func _deal_damage(amount: int) -> void:
	super._deal_damage(amount)
	
	if health >= 90:
		is_focused = false
	elif not is_focused:
		Global.audio.play_sfx(&"enemy/turret_focused", 3, true)
		is_focused = true
	
	if is_focused:
		_update_focus()
	else:
		_update_default()

func _complete_death() -> void:
	var node = await Global.nodes.get_node("res://scenes/unit/projectile/explosion.tscn")
	node.add_to_group(&"object")
	node.position = position
	node.radius = 1
	
	super._complete_death()
