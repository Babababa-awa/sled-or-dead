extends YellowKillableUnit

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const DEATH_ANIMATION_DELTA = 1.5

func _init() -> void:
	death_cooldown_delta = DEATH_ANIMATION_DELTA
	
	super._init(&"medium_crate", Global.UnitType.OBJECT)
	
	projectile_bullet_damage_amount = 55
	projectile_explosion_damage_amount = 99
	projectile_rocket_damage_amount = 100
	projectile_none_damage_amount = 100
	independant_projectile_bullet_damage = true
	independant_projectile_explosion_damage = true
	independant_projectile_rocket_damage = true
	
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

func _update_yellow() -> void:
	if sprite == null:
		return
		
	if health == 100:
		sprite.play(&"yellow")
	elif health > 50:
		sprite.play(&"yellow_1")
	elif health > 0:
		sprite.play(&"yellow_2")
	else:
		sprite.play(&"empty")

func _deal_damage(amount: int) -> void:
	super._deal_damage(amount)
	
	if is_yellow:
		_update_yellow()
	else:
		_update_default()
		
func _start_death() -> void:
	super._start_death()
	%MediumExplosionEffect.play()

func _hide_unit() -> void:
	sprite.visible = false
	$CollisionShape2D.disabled = true
	$Area2DProjectile/CollisionShape2D.disabled = true
	
func _show_unit() -> void:
	sprite.visible = true
	$CollisionShape2D.disabled = false
	$Area2DProjectile/CollisionShape2D.disabled = false
