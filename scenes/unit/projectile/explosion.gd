extends ProjectileUnit

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var collision_shape_damage: CollisionShape2D = $Area2DDamage/CollisionShape2DDamage

const DEATH_ANIMATION_DELTA = 1.5

var radius: int = 4:
	get:
		return radius
	set(value):
		radius = value
		_update_radius()

func _init() -> void:
	# Largest should be the longest needed
	death_cooldown_delta = DEATH_ANIMATION_DELTA
	
	super._init(&"explosion", Global.ProjectileType.EXPLOSION, 1.0)
	
func _ready() -> void:
	super._ready()
	_update_radius()

func reset() -> void:
	super.reset()
	
func _handle_ready() -> void:
	if is_ready:
		return
		
	super._handle_ready()
	
	if is_ready:
		is_dead = true
	
func _update_radius() -> void:
	# TODO: Collision shape shared amongst all instances so could be wonky if a lot of explosions
	
	if collision_shape != null:
		collision_shape.shape.radius = radius * Global.TILE_SIZE
	
	if collision_shape_damage != null:
		collision_shape_damage.shape.radius = radius * Global.TILE_SIZE
		
func _start_death() -> void:
	super._start_death()

	if radius < 2:
		%SmallExplosionEffect.play()
	elif radius < 3:
		%MediumExplosionEffect.play()
	else:
		%LargeExplosionEffect.play()
		
func _hide_projectile() -> void:
	sprite.visible = false
	collision_shape.disabled = true
	collision_shape_damage.disabled = true
	
func _show_projectile() -> void:
	sprite.visible = true
	collision_shape.disabled = false
	collision_shape_damage.disabled = false
