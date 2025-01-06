extends ProjectileUnit

var speed: float = 600
var direction: float = 0.0

func _init() -> void:
	super._init(&"bullet", Global.ProjectileType.BULLET, 2.0)

func reset() -> void:
	super.reset()
	speed = 600
	direction = 0.0

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if not Global.game.is_enabled:
		return
		
	if not is_started or not is_enabled:
		return
		
	velocity = Vector2(0, -speed).rotated(deg_to_rad(direction))

	move_and_slide()
