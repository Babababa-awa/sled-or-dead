extends PlayerUnit

@onready var sprite_body: AnimatedSprite2D = $AnimatedSprite2DBody

func _init() -> void:
	super._init(&"pippa", Global.PlayerType.PIPPA)
	primary_weapon = MachineGunWeapon.new()
	primary_weapon.owner_group = &"player"
	secondary_weapon = PistolWeapon.new()
	secondary_weapon.owner_group = &"player"
