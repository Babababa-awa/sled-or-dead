extends BaseUnit
class_name ProjectileUnit

var is_dead: bool = false
var death_cooldown_delta = 0.0
var death_cooldown: CooldownTimer
var death_handled: bool = false

var is_colliding: bool = false

# Wait a bit of time before testing for collision to ensure checking at new position
var _current_collide_delta: float = 0.0
var COLLIDE_DELTA = 0.125

var projectile_type: Global.ProjectileType
var lifespan_delta: float
var _current_lifespan: float

var hide_on_complete_death = false

func _init(
	alias_: StringName, 
	projectile_type_: Global.ProjectileType,
	lifespan_delta_: float,
) -> void:
	super._init(alias_, Global.UnitType.PROJECTILE)
	
	projectile_type = projectile_type_
	lifespan_delta = lifespan_delta_
	
	death_cooldown_delta = max(Global.MIN_COLLISION_WAIT_DELTA, death_cooldown_delta)
	
	death_cooldown = CooldownTimer.new(death_cooldown_delta)
	death_cooldown.add_step(&"hide", Global.MIN_COLLISION_WAIT_DELTA)

func reset() -> void:
	super.reset()
	
	is_dead = false
	death_handled = false
	
	_current_lifespan = 0.0
	
	death_cooldown.reset()

func _ready() -> void:
	%Area2DDamage.connect("body_entered", _on_damage_body_entered)

func _on_damage_body_entered(body: Node2D) -> void:
	if not _can_process():
		return

	if not is_enabled:
		return
	
	if Global.is_enemies(self, body):
		is_dead = true

func _process(delta: float) -> void:
	super._process(delta)
	
	if not _can_process():
		return
	
	if is_enabled:
		_current_lifespan += delta
		if _current_lifespan > lifespan_delta:
			is_dead = true
		
	_handle_death(delta)
	
func _physics_process(delta: float) -> void:
	if not _can_process():
		return
		
	if not is_enabled:
		return
	
	if _current_collide_delta > COLLIDE_DELTA:
		is_colliding = get_slide_collision_count() > 0
		if is_colliding:
			is_dead = true
	else:
		_current_collide_delta += delta

func _handle_death(delta) -> void:
	if not is_dead or death_handled:
		return

	death_cooldown.process(delta)
	
	if death_cooldown.start():
		is_enabled = false
		_start_death()
	elif death_cooldown.is_on_step(&"hide"):
		if not is_hidden and not hide_on_complete_death:
			_hide_unit()
	elif death_cooldown.is_complete:
		death_handled = true
		death_cooldown.complete()
		_complete_death()


func _start_death() -> void:
	pass
	
func _complete_death() -> void:
	if not is_hidden and hide_on_complete_death:
		_hide_unit()

	Global.nodes.free_node(self)

func start() -> void:
	super.start()
	Global.clear_groups(self)
	_current_collide_delta = 0.0
	is_enabled = true
	is_colliding = false
	
func stop() -> void:
	super.stop()
	velocity = Vector2.ZERO
