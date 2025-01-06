extends ProjectileUnit

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const DEATH_ANIMATION_DELTA = 1.5

var speed: float = 600
var turn_speed: float = 360.0
var target: BaseUnit = null
var direction: float = 0.0

func _init() -> void:
	death_cooldown_delta = DEATH_ANIMATION_DELTA
	
	super._init(&"rocket", Global.ProjectileType.ROCKET, 5.0)

func reset() -> void:
	super.reset()
		
	speed = 600
	turn_speed = 360.0
	target = null
	direction = 0.0
	
func _ready() -> void:
	super._ready()
	%BoostEffect.width = 8

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if not Global.game.is_enabled:
		return
		
	if not is_started or not is_enabled:
		return
	
	var guided_position = null
	
	if target != null:
		guided_position = target.global_position
	elif Global.cursor:
		guided_position = Global.cursor.global_position
		
	if guided_position != null:
		var current_turn_speed = turn_speed * delta
		
		var target_direction = rad_to_deg(position.angle_to_point(guided_position)) + 90
		
		target_direction = _clean_direction(target_direction)
		
		var angle_diff = target_direction - direction
		angle_diff = _clean_direction(angle_diff + 180.0) - 180.0
		
		if abs(angle_diff) > current_turn_speed:
			angle_diff = sign(angle_diff) * current_turn_speed
			
		direction = _clean_direction(direction + angle_diff)
		
	velocity = Vector2(0, -speed).rotated(deg_to_rad(direction))
	rotation = deg_to_rad(direction)

	move_and_slide()
	
func _clean_direction(direction_: float) -> float:
	if direction_ < 0.0:
		direction_ = 360 + direction_
	
	if direction_ >= 360.0:
		direction_ -= 360.0
		
	return direction_
	
func start() -> void:
	super.start()
	%BoostEffect.play()
	
func stop() -> void:
	super.stop()
	%BoostEffect.stop()
	
func _start_death() -> void:
	super._start_death()
	%SmallExplosionEffect.play()
	
func _hide_unit() -> void:
	sprite.visible = false
	%BoostEffect.visible = false
	$CollisionShape2D.disabled = true
	$Area2DDamage/CollisionShape2D.disabled = true
	
func _show_unit() -> void:
	sprite.visible = true
	%BoostEffect.visible = true
	$CollisionShape2D.disabled = false
	$Area2DDamage/CollisionShape2D.disabled = false
