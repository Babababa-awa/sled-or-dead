extends KillableUnit

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_super: bool = false

func _init() -> void:
	super._init(&"exploding_barrel", Global.UnitType.OBJECT)
	
	projectile_bullet_damage_amount = 100
	projectile_explosion_damage_amount = 99
	projectile_rocket_damage_amount = 100
	projectile_none_damage_amount = 100
	independant_projectile_bullet_damage = true
	independant_projectile_explosion_damage = true
	independant_projectile_rocket_damage = true

func _ready() -> void:
	super._ready()
	if is_super:
		_update_super()

func _update_default() -> void:
	if sprite == null:
		return
		
	if health == 100:
		sprite.play(&"default")
	elif health > 0:
		sprite.play(&"default_1")
	else:
		sprite.play(&"empty")

func _update_super() -> void:
	if sprite == null:
		return
		
	if health == 100:
		sprite.play(&"super")
	elif health > 0:
		sprite.play(&"super_1")
	else:
		sprite.play(&"empty")

func _deal_damage(amount: int) -> void:
	super._deal_damage(amount)
	
	if is_super:
		_update_super()
	else:
		_update_default()

func _start_death() -> void:
	super._start_death()

	var node = await Global.nodes.get_node("res://scenes/unit/projectile/explosion.tscn")
	node.add_to_group(&"object")
	node.position = global_position

	if is_super:
		node.radius = 4
	else:
		node.radius = 2
	
func _hide_unit() -> void:
	sprite.visible = false
	$CollisionShape2D.disabled = true
	$Area2DProjectile/CollisionShape2D.disabled = true
	
func _show_unit() -> void:
	sprite.visible = true
	$CollisionShape2D.disabled = false
	$Area2DProjectile/CollisionShape2D.disabled = false
