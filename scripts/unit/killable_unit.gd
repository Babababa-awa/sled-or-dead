extends BaseUnit
class_name KillableUnit

var health: int = 100
var armor: int = 0
var durability: float = 1.0

# Death
var death_cooldown_delta = 0.1
var death_cooldown: CooldownTimer
var death_handled: bool = false

var is_colliding: bool = false
var is_in_damage_area: bool = false
var is_projectile_hit: bool = false
var projectile_count: Dictionary

var is_damage_hit: bool = false

# Damage
var area_damage_amount = 10
var projectile_bullet_damage_amount = 5
var projectile_explosion_damage_amount = 20
var projectile_rocket_damage_amount = 15
var projectile_none_damage_amount = 75 # Vehicles
var independant_projectile_bullet_damage: bool = false
var independant_projectile_explosion_damage: bool = false
var independant_projectile_rocket_damage: bool = false
var damage_cooldown_delta = 1.0
var damage_cooldown: CooldownTimer

var hide_on_complete_death = false

func _init(alias_: StringName, unit_type_: Global.UnitType) -> void:
	super._init(alias_, unit_type_)
	
	death_cooldown_delta = max(Global.MIN_COLLISION_WAIT_DELTA, death_cooldown_delta)
	
	death_cooldown = CooldownTimer.new(death_cooldown_delta)
	death_cooldown.add_step(&"hide", Global.MIN_COLLISION_WAIT_DELTA)
	damage_cooldown = CooldownTimer.new(damage_cooldown_delta)
	
	reset_projectile_count()

func reset() -> void:
	super.reset()

	health = 100
	armor = 0
	
	death_handled = false

	is_colliding = false
	is_in_damage_area = false
	is_projectile_hit = false
	reset_projectile_count()
	is_damage_hit = false
	
	death_cooldown.reset()
	damage_cooldown.reset()

func reset_projectile_count() -> void:
	projectile_count = {
		Global.ProjectileType.BULLET: 0,
		Global.ProjectileType.ROCKET: 0,
		Global.ProjectileType.EXPLOSION: 0,
		Global.ProjectileType.NONE: 0,
	}

func _ready() -> void:
	super._ready()
	
	%Area2DProjectile.connect(&"body_entered", _on_projectile_body_entered)

func _on_projectile_body_entered(body: Node2D) -> void:
	if not _can_process():
		return
		
	if Global.is_enemies(self, body):
		if is_projectile_hit == false:
			reset_projectile_count()
		
		is_projectile_hit = true
		
		
		if body is ProjectileUnit:
			projectile_count[body.projectile_type] += 1
		else:
			projectile_count[Global.ProjectileType.NONE] += 1
			
	
func _process(delta: float) -> void:
	super._process(delta)
	
	if not _can_process():
		return

	_handle_damage(delta)
	
	_handle_death(delta)

	is_colliding = false
	
func _physics_process(_delta: float) -> void:
	if not _can_process():
		return

	if not is_colliding:
		is_colliding = get_slide_collision_count() > 0

func _handle_damage(delta: float) -> void:
	if health == 0 or not is_enabled:
		return
		
	damage_cooldown.process(delta)
	
	if is_damage_hit and damage_cooldown.is_active and not is_in_damage_area:
		is_damage_hit = false
		damage_cooldown.reset()
	elif damage_cooldown.is_complete:
		is_damage_hit = false
		damage_cooldown.complete()

	if _is_killed():
		health = 0
		return
		
	if is_projectile_hit:
		var damage: int = 0
		
		for projectile_type in projectile_count:
			if projectile_type == Global.ProjectileType.BULLET:
				if independant_projectile_bullet_damage or damage_cooldown.start():
					damage += projectile_bullet_damage_amount
			elif projectile_type == Global.ProjectileType.ROCKET:
				if independant_projectile_rocket_damage or damage_cooldown.start():
					damage += projectile_rocket_damage_amount
			elif projectile_type == Global.ProjectileType.EXPLOSION:
				if independant_projectile_explosion_damage or damage_cooldown.start():
					damage += projectile_explosion_damage_amount
			elif projectile_type == Global.ProjectileType.NONE:
				if damage_cooldown.start():
					damage += projectile_none_damage_amount
		
		if damage > 0:
			_deal_damage(damage)
		
		is_projectile_hit = false
	
	if is_in_damage_area and damage_cooldown.start():
		is_damage_hit = true
		_deal_damage(area_damage_amount)
	
func _is_killed() -> bool:
	if is_colliding and Global.game_difficulty != Global.GameDifficulty.EASY:
		return true
		
	return false

func _deal_damage(amount: int) -> void:
	var damage: float

	if is_in_group("enemy") or is_in_group("object"):
		damage = float(Global.apply_difficulty_modifier(amount, true))
	else:
		damage = float(Global.apply_difficulty_modifier(amount))

	damage /= durability

	if armor > 0:
		damage /= 2;
		armor -= int(floor(damage));
		armor = max(0, armor)

	health -= int(floor(damage))
	health = max(0, health)
	
func _handle_death(delta: float) -> void:
	if health != 0 or death_handled:
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
